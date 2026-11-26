"""Lapisan prediksi.

IDE UTAMA: API hanya tahu 'HeatPredictor'. Selama model asli belum jadi, kita
pakai DummyPredictor. Setelah ML Engineer selesai, kamu cukup membuat
RealPredictor dengan method predict() yang sama, lalu ganti 1 baris di main.py.
Kode endpoint dan aplikasi Flutter tidak perlu diubah.
"""
import hashlib
import random
from dataclasses import dataclass
from datetime import date
from typing import Protocol


@dataclass
class FactorResult:
    feature: str
    title: str
    value: float
    contribution_celsius: float


@dataclass
class PredictionResult:
    lst_celsius: float
    base_value_celsius: float
    factors: list[FactorResult]


class HeatPredictor(Protocol):
    model_version: str
    is_dummy: bool

    def predict(self, latitude: float, longitude: float, on_date: date) -> PredictionResult: ...


class DummyPredictor:
    """Prediktor palsu tapi KONSISTEN: input sama -> output sama.
    Meniru cara kerja SHAP: base_value + jumlah semua kontribusi = prediksi."""

    model_version = "dummy-0.2"
    is_dummy = True

    BASE = 30.5
    # (feature, judul tampilan, nilai rata-rata, koefisien, rentang nilai)
    # CATATAN: fitur SEMENTARA yang disamakan dengan UI. Daftar final dari ML Engineer.
    FEATURES = [
        ("ndbi", "Built-up Surface Area", 0.35, 7.0, (0.00, 0.80)),
        ("ndvi", "Low Canopy Deficit (NDVI)", 0.45, -6.0, (0.10, 0.80)),
        ("road_density", "Paved Transportation Grid", 0.50, 2.0, (0.00, 1.00)),
        ("baseline_temperature", "Historical Temperature Baseline", 31.0, 0.5, (28.0, 34.0)),
    ]

    def predict(self, latitude: float, longitude: float, on_date: date) -> PredictionResult:
        # Seed dari hash supaya hasilnya tetap sama untuk input yang sama.
        key = f"{latitude:.4f}|{longitude:.4f}|{on_date.isoformat()}"
        seed = int(hashlib.sha256(key.encode()).hexdigest(), 16) % (2**32)
        rng = random.Random(seed)

        factors: list[FactorResult] = []
        for feature, title, mean, coef, (low, high) in self.FEATURES:
            value = rng.uniform(low, high)
            factors.append(
                FactorResult(feature, title, round(value, 3), round(coef * (value - mean), 3))
            )

        lst = self.BASE + sum(f.contribution_celsius for f in factors)
        return PredictionResult(round(lst, 2), self.BASE, factors)
