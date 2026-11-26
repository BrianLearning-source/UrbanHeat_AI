# UrbanHeat AI: API Contract v0.2 (DRAFT, untuk disepakati tim)

Base URL (dev): `http://localhost:8000`  |  Endpoint data berawalan `/v1`.
`is_dummy: true` = data masih palsu (model ML belum terpasang).

## Keputusan yang sudah diambil
- Input waktu hanya `date` (tanpa jam / periode waktu).
- Output model: Land Surface Temperature (LST). Heatmap dan mitigasi diturunkan dari LST dan faktor model.
- Bentuk `mitigations` mengikuti entity `Mitigation` di Flutter (halaman mitigation).

## Keputusan yang masih terbuka
1. **Daftar fitur input model** (NDVI, NDBI, kepadatan jalan, suhu baseline, cuaca, dst.), dari ML Engineer.
2. **Endpoint heatmap** (banyak titik sekaligus): ditunda sampai tim memutuskan.
3. **Bentuk final mitigasi**: sementara memakai 7 field di UI.

## GET /health
`{"status":"ok","model_version":"dummy-0.2","is_dummy":true}`

## POST /v1/predict
Request:
```json
{"latitude": -7.9797, "longitude": 112.6304, "date": "2026-11-12"}
```
Response 200:
```json
{
  "location": {"latitude": -7.9797, "longitude": 112.6304},
  "date": "2026-11-12",
  "predicted_lst_celsius": 34.64,
  "base_value_celsius": 30.5,
  "risk_level": "ELEVATED",
  "factors": [
    {"feature": "ndbi", "title": "Built-up Surface Area", "value": 0.77,
     "contribution_celsius": 2.9, "percentage": 62,
     "direction": "increase", "impact_label": "+62% impact"}
  ],
  "dimensions": [
    {"title": "Built-up Surface", "subtitle": "NDBI Index: 0.77",
     "badge": "High Density", "description": "..."}
  ],
  "mitigations": [
    {"category": "Permeable Infrastructure",
     "title": "Permeable Pavements & Cool Surfaces",
     "target": "Built-up zones with dense paved surfaces",
     "impact": "Built-up surfaces add about +2.9°C to the predicted heat here",
     "description": "...", "badge": "Recommended for high-NDBI areas", "details": "...",
     "category_code": "permeable", "related_feature": "ndbi"}
  ],
  "model_version": "dummy-0.2",
  "is_dummy": true,
  "generated_at": "2026-11-12T03:25:41Z"
}
```
- `risk_level`: `LOW | MODERATE | ELEVATED | HIGH` (ambang di `app/config.py`).
- `percentage` semua faktor berjumlah 100; `base_value + sum(contribution) = predicted_lst`.
- `factors` ~ `ShapFactor`, `dimensions` ~ `ShapDimension`, `mitigations` ~ `Mitigation` di Flutter.
- `category_code`: `greening | permeable | roofing | shading`. **Flutter sebaiknya memilih ikon dari
  `category_code`, bukan dari teks `category`** (saat ini UI memakai `category.contains('Greening')`).
- `impact` hanya berisi kontribusi dari model, bukan klaim penurunan suhu karangan.

## GET /v1/hotspots
`{"hotspots":[{"rank":1,"grid_id":"MC-204","title":"...","district":"...","tag":"...","temp_celsius":35.1,"status":"POTENTIAL HOTSPOT","risk_level":"HIGH","latitude":-7.9797,"longitude":112.6304}],"is_dummy":true}`

## GET /v1/areas/{grid_id}
`{"grid_id":"MC-204","indicators":[...],"factors":[...],"dimensions":[...],"mitigations":[...],"is_dummy":true}`
404 jika `grid_id` tidak dikenal. (Beda dengan mock Flutter yang menampilkan data MC-204 untuk semua ID.)

## Format error (semua endpoint)
```json
{"error": {"code": "OUT_OF_STUDY_AREA", "message": "..."}}
```
| HTTP | code | Arti |
|---|---|---|
| 422 | `INVALID_INPUT` | Field salah tipe / hilang / di luar rentang |
| 422 | `OUT_OF_STUDY_AREA` | Koordinat di luar area studi |
| 404 | `AREA_NOT_FOUND` | grid_id tidak dikenal |
| 500 | `INTERNAL_ERROR` | Kesalahan server |
Flutter sebaiknya menampilkan pesan berdasarkan `code`, bukan menampilkan `message` apa adanya.
