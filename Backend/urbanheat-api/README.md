# UrbanHeat AI API (kerangka awal)

## Menjalankan
```bash
python -m venv .venv
# Windows: .venv\Scripts\activate    |  Mac/Linux: source .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```
- Dokumentasi interaktif (bisa langsung dicoba): http://localhost:8000/docs
- Tes otomatis: `python -m pytest -q`

## Struktur
| File | Fungsi |
|---|---|
| `app/main.py` | Daftar endpoint |
| `app/schemas.py` | Kontrak JSON (bentuk request/response) |
| `app/config.py` | Batas area studi, ambang risiko |
| `app/errors.py` | Format error seragam |
| `app/services/predictor.py` | Prediktor (sekarang dummy; nanti diganti model asli) |
| `app/services/explain.py` | Faktor (SHAP), dimensi, dan saran mitigasi |
| `app/services/dummy_data.py` | Data tetap hotspot dan indikator |

## Menguji dari HP/emulator Android
- Emulator Android: pakai `http://10.0.2.2:8000` (bukan localhost).
- HP asli: satu Wi-Fi dengan laptop, pakai `http://IP-LAPTOP:8000`.
