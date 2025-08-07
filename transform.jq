def deg2rad: . * (3.141592653589793 / 180);
def rad2deg: . * (180 / 3.141592653589793);
def muTransformCoord($coords):
  $coords as [$lng, $lat]
  | ($lat | deg2rad) as $latRad
  | ($lng | deg2rad) as $lngRad
  | ( ($latRad | cos) * ($lngRad | cos) ) as $x
  | ( ($latRad | cos) * ($lngRad | sin) ) as $y
  | ($latRad | sin) as $z
  | ($z) as $xRot
  | ($y) as $yRot
  | (-$x) as $zRot
  | (($zRot | asin) | rad2deg) as $latNew
  | (atan2($yRot; $xRot) | rad2deg) as $lngNew
  | [$lngNew, $latNew];
def muTransformCoords($type; $coords):
  if $type == "Point" then
    muTransformCoord($coords)
  elif $type == "LineString" or $type == "MultiPoint" then
    $coords | map(muTransformCoord(.))
  elif $type == "Polygon" or $type == "MultiLineString" then
    $coords | map(map(muTransformCoord(.)))
  elif $type == "MultiPolygon" then
    $coords | map(map(map(muTransformCoord(.))))
  else
    $coords
  end;
def muTransform:
  . as $f
  | $f.geometry.type as $type
  | $f.geometry.coordinates as $coords
  | $f
  | .geometry.coordinates = muTransformCoords($type; $coords)
  | .tippecanoe = {"layer": "prototype"};
muTransform
