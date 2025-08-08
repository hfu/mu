#!/usr/bin/env ruby
# Build docs/aq.pmtiles from ../gmaq10/wgs84_*.shp
# - Streams all shapefiles as GeoJSON Text Sequence
# - Applies muTransformation via transform.jq
# - Injects tippecanoe layer metadata based on filename (wgs84_*.shp -> layer "*")
# - Feeds everything to tippecanoe via stdin

require 'open3'
require 'shellwords'
require 'fileutils'

script_dir = File.expand_path(__dir__)
repo_root  = File.expand_path('..', script_dir)

transform_jq = File.join(repo_root, 'transform.jq')
# Validate transform filter presence
unless File.exist?(transform_jq)
  warn "Missing transform filter: #{transform_jq}"
  exit 1
end

docs_dir     = File.join(repo_root, 'docs')
FileUtils.mkdir_p(docs_dir)

glob = File.expand_path('../gmaq10/wgs84_*.shp', repo_root)
shapefiles = Dir.glob(glob).sort
if shapefiles.empty?
  warn "No shapefiles found for #{glob}"
  exit 1
end

output_pmtiles = File.join(docs_dir, 'aq.pmtiles')

# Tippecanoe command reading from stdin
tippecanoe_cmd = [
  'tippecanoe',
  '-f',
  '--detect-longitude-wraparound',
  '--maximum-zoom=10',
  '-o', output_pmtiles
]

warn "Writing #{output_pmtiles}"
warn "Applying muTransformation using #{File.basename(transform_jq)}"

# Launch tippecanoe with stdin using Open3 to obtain a wait handle
tip_status = nil
Open3.popen3(*tippecanoe_cmd) do |tip_in, tip_out, tip_err, tip_wait|
  # Forward tippecanoe outputs so progress is visible and buffers don't block
  tout = Thread.new { begin IO.copy_stream(tip_out, STDOUT) rescue nil end }
  terr = Thread.new { begin IO.copy_stream(tip_err, STDERR) rescue nil end }

  begin
    shapefiles.each do |shp|
      layer = File.basename(shp).sub(/^wgs84_/, '').sub(/\.shp$/, '')
      warn "Processing layer=#{layer} from #{File.basename(shp)}"

      # Build shell pipeline per shapefile and stream into tippecanoe stdin
      cmd = %Q{ogr2ogr -f GeoJSONSeq /vsistdout/ #{Shellwords.escape(shp)} | jq -c -f #{Shellwords.escape(transform_jq)} | jq -c --arg layer #{Shellwords.escape(layer)} '.tippecanoe = (.tippecanoe // {}) | .tippecanoe.layer = $layer'}

      Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
        stdin.close
        IO.copy_stream(stdout, tip_in)
        stdout.close
        unless wait_thr.value.success?
          err = stderr.read
          warn err unless err.nil? || err.empty?
          raise "Failed processing #{shp}"
        end
      end
    end
  ensure
    tip_in.close
  end

  tip_status = tip_wait.value
  tout.join; terr.join
end

# Handle tippecanoe exit status and rename output to .gz
if tip_status && tip_status.success?
  gz_output = output_pmtiles + '.gz'
  begin
    FileUtils.rm_f(gz_output)
    FileUtils.mv(output_pmtiles, gz_output)
    warn "Renamed #{output_pmtiles} -> #{gz_output}"
    exit 0
  rescue => e
    warn "Failed to rename to #{gz_output}: #{e}"
    exit 1
  end
else
  code = tip_status&.exitstatus || 1
  exit(code)
end
