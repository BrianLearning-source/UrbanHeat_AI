"""KONTRAK JSON: bentuk data yang masuk dan keluar dari API.

Pydantic otomatis memeriksa data. Kalau Flutter mengirim latitude "abc",
FastAPI langsung menolaknya dengan error 422 sebelum kodemu dijalankan.
"""
from datetime import date as Date
from datetime import datetime
from typing import Literal

from pydantic import BaseModel, Field

RiskLevel = Literal["LOW", "MODERATE", "ELEVATED", "HIGH"]


# ---------- REQUEST ----------
class PredictRequest(BaseModel):
    latitude: float = Field(ge=-90, le=90, examples=[-7.9797])
    longitude: float = Field(ge=-180, le=180, examples=[112.6304])
    date: Date = Field(examples=["2026-11-12"])


# ---------- RESPONSE (potongan-potongan kecil) ----------
class Location(BaseModel):
    latitude: float
    longitude: float


class Factor(BaseModel):
    """Satu faktor penyebab panas (nanti diisi nilai SHAP dari model)."""
    feature: str            # nama teknis, mis. "ndvi"
    title: str              # nama untuk ditampilkan, mis. "Vegetation (NDVI)"
    value: float            # nilai fitur di lokasi ini
    contribution_celsius: float  # + menaikkan suhu, - menurunkan suhu
    percentage: int         # porsi pengaruh, 0-100
    direction: Literal["increase", "decrease"]
    impact_label: str


class Mitigation(BaseModel):
    """Sama dengan entity Mitigation di Flutter (7 field), ditambah 2 field bantu."""
    category: str            # teks tampilan, mis. "Urban Greening"
    title: str
    target: str
    impact: str              # teks bebas, bukan angka
    description: str
    badge: str
    details: str
    category_code: Literal["greening", "permeable", "roofing", "shading"]  # untuk memilih ikon
    related_feature: str     # fitur model yang memicu saran ini


class Dimension(BaseModel):
    """Sama dengan entity ShapDimension di Flutter (kartu 'key dimensions')."""
    title: str
    subtitle: str
    badge: str
    description: str


class Indicator(BaseModel):
    title: str
    subtitle: str
    value: str
    value_subtitle: str | None = None


# ---------- RESPONSE (endpoint utama) ----------
class PredictResponse(BaseModel):
    location: Location
    date: Date
    predicted_lst_celsius: float
    base_value_celsius: float   # rata-rata model; base + semua kontribusi = prediksi
    risk_level: RiskLevel
    factors: list[Factor]
    dimensions: list[Dimension]
    mitigations: list[Mitigation]
    model_version: str
    is_dummy: bool              # True selama model asli belum dipasang
    generated_at: datetime


class Hotspot(BaseModel):
    rank: int
    grid_id: str
    title: str
    district: str
    tag: str
    temp_celsius: float
    status: str
    risk_level: RiskLevel
    latitude: float
    longitude: float


class HotspotsResponse(BaseModel):
    hotspots: list[Hotspot]
    is_dummy: bool


class AreaDetailResponse(BaseModel):
    grid_id: str
    indicators: list[Indicator]
    factors: list[Factor]
    dimensions: list[Dimension]
    mitigations: list[Mitigation]
    is_dummy: bool


# ---------- FORMAT ERROR (selalu sama) ----------
class ErrorBody(BaseModel):
    code: str
    message: str


class ErrorResponse(BaseModel):
    error: ErrorBody
