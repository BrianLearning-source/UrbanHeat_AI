"""Pengaturan terpusat. Ubah angka di sini, jangan tersebar di banyak file."""

# Batas area studi (bounding box). SEMENTARA: kira-kira Kota Malang.
# Setelah tim mengunci area studi (hasil feasibility Minggu 1-3), ganti angkanya.
STUDY_AREA = {
    "lat_min": -8.06,
    "lat_max": -7.90,
    "lng_min": 112.59,
    "lng_max": 112.68,
}

# Ambang batas risiko berdasarkan suhu permukaan (LST) dalam derajat Celsius.
# Cocok dengan label di mock Flutter: HIGH / ELEVATED. Sesuaikan dengan data asli.
RISK_THRESHOLDS = [
    (35.0, "HIGH"),
    (33.0, "ELEVATED"),
    (30.0, "MODERATE"),
]
RISK_DEFAULT = "LOW"


def risk_level_from_lst(lst_celsius: float) -> str:
    for threshold, label in RISK_THRESHOLDS:
        if lst_celsius >= threshold:
            return label
    return RISK_DEFAULT
