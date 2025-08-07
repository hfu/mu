# Makefile for mu project

SRC_DIR := src
SRC_SHAPE := $(SRC_DIR)/ne_110m_coastline.shp

.PHONY: all pmtiles

all: pmtiles

pmtiles:
	ogr2ogr -f GeoJSONSeq /vsistdout/ $(SRC_SHAPE) | \
	jq -c -f transform.jq | \
	tippecanoe -f --attribution="Natural Earth" \
	--detect-longitude-wraparound \
	--maximum-zoom=10 -o docs/mu.pmtiles
	mv docs/mu.pmtiles docs/mu.pmtiles.gz 
