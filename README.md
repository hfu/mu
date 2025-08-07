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

- **Interactive Globe Visualization**: View the transformed coastline data in 3D globe mode using MapLibre GL JS v5.0.0
- **PMTiles Format**: Efficient vector tile format for web mapping
- **Longitude Wraparound Handling**: Uses tippecanoe with longitude wraparound detection for proper coordinate handling
- **Auto-rotation**: Press 'R' key to toggle automatic globe rotation

機能：

- **インタラクティブなグローブ表示**: MapLibre GL JS v5.0.0を使用して変換された海岸線データを3Dグローブモードで表示
- **PMTilesフォーマット**: ウェブマッピング用の効率的なベクトルタイル形式
- **経度回り込み処理**: 適切な座標処理のために経度回り込み検出機能を備えたtippecanoeを使用
- **自動回転**: 'R'キーで自動グローブ回転の切り替え

## Prototype design / プロトタイプ設計

- This is an implementation of <https://github.com/UNopenGIS/7/issues/760>
- All the process is controlled by Makefile
- The `pmtiles` task will:
  - Create GeoJSON Text Sequence from the shapefile in `src` directory.
  - Filter the sequence using `jq` that apply muTransformation suggested in <https://github.com/UNopenGIS/7/issues/760>.
  - Generate PMTiles file with tippecanoe containing the transformed coastline data with longitude wraparound detection.

プロトタイプ設計：

- これは <https://github.com/UNopenGIS/7/issues/760> の実装です
- すべての処理はMakefileで制御されています
- `pmtiles`タスクは以下を実行します：
  - `src`ディレクトリのシェープファイルからGeoJSON Text Sequenceを作成
  - <https://github.com/UNopenGIS/7/issues/760> で提案されたムー変換を適用する`jq`によるシーケンスフィルタリング
  - 経度回り込み検出機能を備えたtippecanoeで変換済み海岸線データを含むPMTilesファイルを生成

## Build Process / ビルドプロセス

```bash
# Generate PMTiles with spherical optimization
# 球面最適化でPMTilesを生成
make pmtiles

# Serve locally for testing
# ローカルでテスト用サーバーを起動
cd docs
python3 -m http.server 8000
```

The build process includes: / ビルドプロセスには以下が含まれます：

- `--detect-longitude-wraparound`: Detects and handles longitude wraparound issues / 経度の回り込み問題を検出・処理
- `--maximum-zoom=10`: Sets the maximum zoom level to 10 / 最大ズームレベルを10に設定

## Mathematical transformation / 数学的変換

The transformation converts spherical coordinates through: / 変換は以下の手順で球面座標を変換します：

1. lat/lng → spherical coordinates (x, y, z) / 緯度経度 → 球面座標 (x, y, z)
2. Y-axis rotation by -90° (X→Z, Z→-X) / Y軸周りに-90°回転 (X→Z, Z→-X)
3. spherical coordinates → lat/lng / 球面座標 → 緯度経度

Example transformations: / 変換例：

- North Pole (0, 90) → ≈ (0, 0) / 北極 (0, 90) → ≈ (0, 0)
- South Pole (0, -90) → ≈ (180, 0) / 南極 (0, -90) → ≈ (180, 0)
- Equator (90, 0) → ≈ (0, -90) / 赤道 (90, 0) → ≈ (0, -90)

## Demo / デモ

- **Interactive Globe**: <https://hfu.github.io/mu/> - MapLibre GL JS globe visualization / MapLibre GL JSグローブ表示
- **PMTiles Viewer**: <https://pmtiles.io/?url=https://hfu.github.io/mu/mu.pmtiles.gz> - External PMTiles viewer / 外部PMTilesビューア

## Technical Stack / 技術スタック

- **MapLibre GL JS v5.0.0**: For interactive globe visualization / インタラクティブなグローブ表示用
- **PMTiles v3.0.6**: For efficient vector tile delivery / 効率的なベクトルタイル配信用
- **tippecanoe**: Vector tile generation with longitude wraparound detection / 経度回り込み検出によるベクトルタイル生成
- **jq**: Coordinate transformation processing / 座標変換処理
- **GDAL/OGR**: Shapefile to GeoJSON conversion / シェープファイルからGeoJSONへの変換

