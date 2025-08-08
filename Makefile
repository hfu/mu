# Makefile for mu project

SRC_DIR := src
SRC_SHAPE := $(SRC_DIR)/ne_110m_coastline.shp

.PHONY: all pmtiles aq

all: pmtiles

pmtiles:
	ogr2ogr -f GeoJSONSeq /vsistdout/ $(SRC_SHAPE) | \
	jq -c -f transform.jq | \
	tippecanoe -f --attribution="Natural Earth" \
	--detect-longitude-wraparound \
	--maximum-zoom=10 -o docs/mu.pmtiles
	mv docs/mu.pmtiles docs/mu.pmtiles.gz 

# Build aggregated PMTiles from ../gmaq10/wgs84_*.shp
# Streams all inputs to tippecanoe and assigns layers from filenames
# Usage: make aq
# Requires: Ruby, GDAL (ogr2ogr), jq, tippecanoe

aq:
	ruby scripts/build_aq.rb
