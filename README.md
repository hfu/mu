# mu
A prototype with muTransformation

## Prototype design
- This is an implementation of https://github.com/UNopenGIS/7/issues/760
- All the process is controlled by Makefile
- The `download` task will:
  - Download by aria2c https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/physical/ne_10m_coastline.zip
  - Unzip the file above into src directory.
- The `pmtiles` task will:
  - Create GeoJSON Text Sequence from the file above.
  - Filter the sequence using `jq` that apply muTransformation suggested in https://github.com/UNopenGIS/7/issues/760.

