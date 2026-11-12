from datetime import datetime, timezone

from fastapi import APIRouter, Depends, FastAPI
from fastapi.middleware.cors import CORSMiddleware

from . import config
from .errors import ApiError, register_error_handlers
from .schemas import (AreaDetailResponse, ErrorResponse, HotspotsResponse, Location,
                      PredictRequest, PredictResponse)
from .services import dummy_data
from .services.explain import build_dimensions, build_factors, build_mitigations
from .services.predictor import DummyPredictor, HeatPredictor

app = FastAPI(title="UrbanHeat AI API", version="0.1.0",
              description="Prediction API untuk aplikasi UrbanHeat AI.")
register_error_handlers(app)

# CORS dibutuhkan hanya jika diuji dari browser/Flutter web. Aplikasi Android tidak memerlukannya.
app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_methods=["*"], allow_headers=["*"])

# ====== BARIS YANG DIGANTI SAAT MODEL ASLI SIAP ======
_predictor: HeatPredictor = DummyPredictor()
# nanti: _predictor = RealPredictor("models/xgb_v1.joblib")
# =====================================================


def get_predictor() -> HeatPredictor:
    return _predictor


router = APIRouter(prefix="/v1")


@app.get("/health", tags=["system"])
def health(predictor: HeatPredictor = Depends(get_predictor)):
    """Dipakai untuk mengecek server hidup, dan oleh Flutter untuk mendeteksi API down."""
    return {"status": "ok", "model_version": predictor.model_version, "is_dummy": predictor.is_dummy}


@router.post("/predict", response_model=PredictResponse,
             responses={422: {"model": ErrorResponse}}, tags=["prediction"])
def predict(req: PredictRequest, predictor: HeatPredictor = Depends(get_predictor)):
    a = config.STUDY_AREA
    if not (a["lat_min"] <= req.latitude <= a["lat_max"] and a["lng_min"] <= req.longitude <= a["lng_max"]):
        raise ApiError(422, "OUT_OF_STUDY_AREA", "Lokasi berada di luar area studi UrbanHeat AI.")

    result = predictor.predict(req.latitude, req.longitude, req.date)
    return PredictResponse(
        location=Location(latitude=req.latitude, longitude=req.longitude),
        date=req.date,
        predicted_lst_celsius=result.lst_celsius,
        base_value_celsius=result.base_value_celsius,
        risk_level=config.risk_level_from_lst(result.lst_celsius),
        factors=build_factors(result.factors),
        dimensions=build_dimensions(result.factors),
        mitigations=build_mitigations(result.factors),
        model_version=predictor.model_version,
        is_dummy=predictor.is_dummy,
        generated_at=datetime.now(timezone.utc),
    )


@router.get("/hotspots", response_model=HotspotsResponse, tags=["areas"])
def hotspots(predictor: HeatPredictor = Depends(get_predictor)):
    return HotspotsResponse(hotspots=dummy_data.HOTSPOTS, is_dummy=True)


@router.get("/areas/{grid_id}", response_model=AreaDetailResponse,
            responses={404: {"model": ErrorResponse}}, tags=["areas"])
def area_detail(grid_id: str, predictor: HeatPredictor = Depends(get_predictor)):
    spot = next((h for h in dummy_data.HOTSPOTS if h.grid_id == grid_id), None)
    if spot is None:
        raise ApiError(404, "AREA_NOT_FOUND", f"Area '{grid_id}' tidak ditemukan.")

    result = predictor.predict(spot.latitude, spot.longitude, datetime.now(timezone.utc).date())
    return AreaDetailResponse(
        grid_id=grid_id,
        indicators=dummy_data.INDICATORS.get(grid_id, []),
        factors=build_factors(result.factors),
        dimensions=build_dimensions(result.factors),
        mitigations=build_mitigations(result.factors),
        is_dummy=predictor.is_dummy,
    )


app.include_router(router)
