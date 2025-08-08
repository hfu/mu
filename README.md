# mu

A prototype with muTransformation / ムー変換のプロトタイプ

## What is muTransformation? / ムー変換とは？

muTransformation (ムー変換) is a coordinate transformation that:

- Moves the North Pole to the intersection of the Prime Meridian and the Equator
- Moves the South Pole to the intersection of the Anti-Meridian and the Equator  
- Represents a spherical coordinate system rotation that rotates 90° latitude to the equator while keeping 0° longitude unchanged
- Results in the North Pole appearing in the Gulf of Guinea and the South Pole in the Pacific Ocean, hence called "Mu Transformation"

ムー変換は以下のような座標変換です：

- 北極を本初子午線と赤道の交点に移動
- 南極を日付変更線と赤道の交点に移動
- 経度0度を保ったまま、緯度90度を赤道に回転させる球面座標系の回転
- 北極がギニア湾、南極が太平洋に現れることから「ムー変換」と呼ばれます

## Features / 機能

- Interactive Globe Visualization: View the transformed coastline and AQ layers in 3D globe mode using MapLibre GL JS v5.0.0
- PMTiles Format: Efficient vector tile format for web mapping
- Longitude Wraparound Handling: Uses tippecanoe with longitude wraparound detection
- Auto-rotation: Press 'R' to toggle globe rotation

機能：

- インタラクティブなグローブ表示: MapLibre GL JS v5.0.0で海岸線とAQレイヤを3D表示
- PMTilesフォーマット: ウェブマッピング用の効率的なベクトルタイル
- 経度回り込み処理: tippecanoeのwraparound検出を使用
- 自動回転: 'R'キーで切り替え

## Prototype design / プロトタイプ設計

- This is an implementation of <https://github.com/UNopenGIS/7/issues/760>
- All the process is controlled by Makefile
- The `pmtiles` task will:
  - Create GeoJSON Text Sequence from the coastline shapefile in `src`
  - Filter with `jq` applying muTransformation in `transform.jq`
  - Generate `docs/mu.pmtiles.gz` with tippecanoe (wraparound detection)
- The `aq` task will:
  - Stream-convert all `../gmaq10/wgs84_*.shp` with `ogr2ogr`
  - Apply muTransformation with `transform.jq`
  - Inject per-feature `.tippecanoe.layer` from filename (`wgs84_*.shp` -> `*`)
  - Pipe to one tippecanoe process and output `docs/aq.pmtiles.gz`

プロトタイプ設計：

- これは <https://github.com/UNopenGIS/7/issues/760> の実装です
- すべての処理はMakefileで制御
- `pmtiles` タスク:
  - `src` の海岸線SHPをGeoJSONテキストシーケンスへ
  - `transform.jq` でムー変換
  - tippecanoeで `docs/mu.pmtiles.gz` を生成
- `aq` タスク:
  - `../gmaq10/wgs84_*.shp` を逐次 `ogr2ogr` でストリーム変換
  - `transform.jq` でムー変換
  - ファイル名から `.tippecanoe.layer` を設定（例: bnda, bndl, hydroa, hydrol, popp, transl, transp）
  - 1プロセスのtippecanoeへstdinで投入し `docs/aq.pmtiles.gz` を生成

## Build Process / ビルドプロセス

```bash
# Coastline PMTiles
make pmtiles

# AQ PMTiles
make aq

# Serve locally
cd docs
python3 -m http.server 8000
```

The build process includes: / ビルドプロセスには以下が含まれます：

- `--detect-longitude-wraparound`: Detects and handles longitude wraparound issues / 経度の回り込み検出
- `--maximum-zoom=10`: Sets maximum zoom level to 10 / 最大ズーム10

## Visualization / 可視化

- Data order: mu.pmtiles.gz first, aq.pmtiles.gz second / データの描画順は mu → aq
- Layer order in aq: polygons (bnda, hydroa) → lines (bndl, hydrol, transl) → points (transp) → labels (popp)
- Styles:
  - page/canvas background: near-black, globe background layer: dark gray `#1f1f1f`
  - bnda fill: off-white `#f7f7f5` (no stroke)
  - hydroa fill: ice-like pale `#eef6ff` (slightly higher opacity 0.5)
  - hydrol line: thicker widths (0.4/1.0/2.0 by zoom)
  - transl line: dark gray `#444444`
  - popp labels: `NAM` attribute with halo
- Initial view: center [180, 0], zoom 4 / 初期表示: 中心 [180, 0], ズーム 4

## Mathematical transformation / 数学的変換

The transformation converts spherical coordinates through: / 変換は以下の手順で球面座標を変換します：

1. lat/lng → spherical coordinates (x, y, z)
2. Y-axis rotation by -90° (X→Z, Z→-X)
3. spherical coordinates → lat/lng

Example transformations: / 変換例：

- North Pole (0, 90) → ≈ (0, 0)
- South Pole (0, -90) → ≈ (180, 0)
- Equator (90, 0) → ≈ (0, -90)

## Demo / デモ

- Interactive Globe: <https://hfu.github.io/mu/>
- PMTiles Viewer: <https://pmtiles.io/?url=https://hfu.github.io/mu/mu.pmtiles.gz>

## Technical Stack / 技術スタック

- MapLibre GL JS v5.0.0
- PMTiles v3.0.6
- tippecanoe
- jq
- GDAL/OGR

