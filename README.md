# mu
A prototype with muTransformation

## What is muTransformation?
muTransformation (μ変換) is a coordinate transformation that:
- Moves the North Pole to the intersection of the Prime Meridian and the Equator
- Moves the South Pole to the intersection of the Anti-Meridian and the Equator  
- Represents a spherical coordinate system rotation that rotates 90° latitude to the equator while keeping 0° longitude unchanged
- Results in the North Pole appearing in the Gulf of Guinea and the South Pole in the Pacific Ocean, hence called "Mu Transformation"

## Prototype design
- This is an implementation of https://github.com/UNopenGIS/7/issues/760
- All the process is controlled by Makefile
- The `pmtiles` task will:
  - Create GeoJSON Text Sequence from the shapefile in `src` directory.
  - Filter the sequence using `jq` that apply muTransformation suggested in https://github.com/UNopenGIS/7/issues/760.
  - Generate PMTiles file with tippecanoe containing the transformed coastline data.

## Mathematical transformation
The transformation converts spherical coordinates through:
1. lat/lng → spherical coordinates (x, y, z)
2. Y-axis rotation by -90° (X→Z, Z→-X)  
3. spherical coordinates → lat/lng

Example transformations:
- North Pole (0, 90) → ≈ (0, 0)
- South Pole (0, -90) → ≈ (180, 0)
- Equator (90, 0) → ≈ (0, -90)

## Demo

View the transformed coastline data: https://pmtiles.io/?url=https://hfu.github.io/mu/mu.pmtiles.gz

