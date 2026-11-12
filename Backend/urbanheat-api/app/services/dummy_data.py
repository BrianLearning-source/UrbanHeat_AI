"""Data tetap untuk endpoint hotspots dan detail area (menggantikan MockUrbanHeatData di Flutter).
Nanti bisa diganti hasil query dari tabel Supabase atau hasil model."""
from ..schemas import Hotspot, Indicator

HOTSPOTS: list[Hotspot] = [
    Hotspot(rank=1, grid_id="MC-204", title="Arterial Commercial Axis (Central Malang)",
            district="Kecamatan Klojen", tag="High NDBI / Low NDVI", temp_celsius=35.1,
            status="POTENTIAL HOTSPOT", risk_level="HIGH", latitude=-7.9797, longitude=112.6304),
    Hotspot(rank=2, grid_id="BL-102", title="Industrial & Transit Corridor",
            district="Kecamatan Blimbing", tag="High Impervious Surface", temp_celsius=34.6,
            status="POTENTIAL HOTSPOT", risk_level="HIGH", latitude=-7.9370, longitude=112.6520),
    Hotspot(rank=3, grid_id="LW-A12", title="Dense Built-up Residential Sector",
            district="Kecamatan Lowokwaru", tag="Moderate-High Heat", temp_celsius=34.2,
            status="ELEVATED RISK", risk_level="ELEVATED", latitude=-7.9460, longitude=112.6150),
]

INDICATORS: dict[str, list[Indicator]] = {
    "MC-204": [
        Indicator(title="NDVI (Vegetation Index)", subtitle="Low green canopy coverage", value="0.19"),
        Indicator(title="NDBI (Built-up Indicator)", subtitle="Dense impervious structures", value="0.74"),
        Indicator(title="Land Cover", subtitle="Satellite taxonomy", value="Urban Commercial",
                  value_subtitle="High Density"),
    ],
    "BL-102": [
        Indicator(title="NDVI (Vegetation Index)", subtitle="Very low canopy", value="0.15"),
        Indicator(title="NDBI (Built-up Indicator)", subtitle="Impervious surfaces", value="0.68"),
    ],
    "LW-A12": [
        Indicator(title="NDVI (Vegetation Index)", subtitle="Sparse vegetation", value="0.27"),
        Indicator(title="NDBI (Built-up Indicator)", subtitle="Dense residential", value="0.55"),
    ],
}
