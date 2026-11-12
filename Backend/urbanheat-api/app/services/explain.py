"""Mengubah hasil mentah model menjadi bentuk yang siap dikirim ke Flutter,
lalu membuat saran mitigasi BERBASIS ATURAN (sesuai proposal: bukan model ML terpisah)."""
from ..schemas import Dimension, Factor, Mitigation
from .predictor import FactorResult

# Kontribusi minimal (°C) agar aturan roofing aktif. Sesuaikan setelah model asli ada.
ROOFING_MIN_CONTRIBUTION = 0.8


def build_factors(results: list[FactorResult]) -> list[Factor]:
    total = sum(abs(r.contribution_celsius) for r in results) or 1.0
    percentages = [round(abs(r.contribution_celsius) / total * 100) for r in results]

    # Pembulatan bisa membuat total 99 atau 101; koreksi di faktor terbesar.
    diff = 100 - sum(percentages)
    if diff and percentages:
        percentages[percentages.index(max(percentages))] += diff

    factors = []
    for r, pct in zip(results, percentages):
        increase = r.contribution_celsius >= 0
        sign = "+" if increase else "-"
        factors.append(
            Factor(
                feature=r.feature,
                title=r.title,
                value=r.value,
                contribution_celsius=r.contribution_celsius,
                percentage=pct,
                direction="increase" if increase else "decrease",
                impact_label=f"{sign}{pct}% impact",  # sama dengan format mock di Flutter
            )
        )
    return sorted(factors, key=lambda f: f.percentage, reverse=True)


def build_dimensions(results: list[FactorResult]) -> list[Dimension]:
    """Kartu 'key dimensions' di halaman Contributing Factors."""
    by = {r.feature: r for r in results}
    out: list[Dimension] = []

    if "ndvi" in by:
        v = by["ndvi"].value
        badge = "Low Coverage" if v < 0.3 else "Moderate Coverage" if v < 0.5 else "Healthy Coverage"
        out.append(Dimension(
            title="Vegetation Density", subtitle=f"NDVI Index: {v:.2f}", badge=badge,
            description={
                "Low Coverage": "Sparse vegetation limits shade and evaporative cooling in this area.",
                "Moderate Coverage": "Some vegetation is present, but cooling benefit is partial.",
                "Healthy Coverage": "Good vegetation cover helps moderate surface temperature.",
            }[badge]))

    if "ndbi" in by:
        v = by["ndbi"].value
        badge = "High Density" if v >= 0.5 else "Moderate Density" if v >= 0.3 else "Low Density"
        out.append(Dimension(
            title="Built-up Surface", subtitle=f"NDBI Index: {v:.2f}", badge=badge,
            description={
                "High Density": "Dense built-up surfaces absorb and retain heat, especially around midday.",
                "Moderate Density": "A mix of built-up and open surfaces gives moderate heat retention.",
                "Low Density": "Limited built-up surface keeps heat retention low.",
            }[badge]))

    if "road_density" in by:
        v = by["road_density"].value
        badge = "High Coverage" if v >= 0.6 else "Moderate Coverage" if v >= 0.3 else "Low Coverage"
        out.append(Dimension(
            title="Paved Road Network", subtitle=f"Coverage: {v * 100:.1f}%", badge=badge,
            description="Dark paved roads absorb solar radiation and release it slowly, raising local heat."
            if v >= 0.6 else "Road coverage has a moderate to small effect on local heat here."))

    if "baseline_temperature" in by:
        v = by["baseline_temperature"].value
        badge = "Mod-High" if v >= 31 else "Moderate"
        out.append(Dimension(
            title="Historical Temp Baseline", subtitle=f"Baseline LST: {v:.1f}°C", badge=badge,
            description="Past surface temperature in this area sets the starting point for the prediction."))

    return out


def build_mitigations(results: list[FactorResult]) -> list[Mitigation]:
    """Aturan sederhana. Teks 'impact' memakai kontribusi dari model, BUKAN angka pendinginan
    karangan: kita hanya boleh menyatakan apa yang memang dihitung model."""
    by = {r.feature: r for r in results}
    found: list[tuple[float, Mitigation]] = []

    ndvi = by.get("ndvi")
    if ndvi and ndvi.contribution_celsius > 0:
        c = ndvi.contribution_celsius
        found.append((c, Mitigation(
            category="Urban Greening",
            title="Urban Greening & Tree Canopy",
            target="Streets and corridors with low vegetation cover",
            impact=f"Low vegetation adds about +{c:.1f}°C to the predicted heat here",
            description="Add vegetative buffers and shaded walkways where vegetation is low. "
                        "More greenery may help reduce heat exposure.",
            badge="Recommended for low-NDVI areas",
            details="Prioritize shade trees along streets and pedestrian routes with the least canopy.",
            category_code="greening", related_feature="ndvi")))

    ndbi = by.get("ndbi")
    if ndbi and ndbi.contribution_celsius > 0:
        c = ndbi.contribution_celsius
        found.append((c, Mitigation(
            category="Permeable Infrastructure",
            title="Permeable Pavements & Cool Surfaces",
            target="Built-up zones with dense paved surfaces",
            impact=f"Built-up surfaces add about +{c:.1f}°C to the predicted heat here",
            description="Use permeable or lighter-colored surfaces to reduce heat retention "
                        "and allow natural ground moisture exchange.",
            badge="Recommended for high-NDBI areas",
            details="Consider porous pavers in parking areas and walkways.",
            category_code="permeable", related_feature="ndbi")))
        if c >= ROOFING_MIN_CONTRIBUTION:
            found.append((c * 0.9, Mitigation(
                category="High-Albedo Roofing",
                title="High-Albedo Roofing Materials",
                target="Dense commercial or industrial rooftop clusters",
                impact=f"Built-up surfaces add about +{c:.1f}°C; reflective roofs address part of it",
                description="Reflective roof coatings can reduce heat absorbed by buildings "
                            "in dense built-up clusters.",
                badge="Recommended for dense built-up clusters",
                details="Consider reflective coatings on large flat rooftops.",
                category_code="roofing", related_feature="ndbi")))

    road = by.get("road_density")
    if road and road.contribution_celsius > 0.5:
        c = road.contribution_celsius
        found.append((c, Mitigation(
            category="Street Shading",
            title="Shade Along Road Corridors",
            target="High-density road corridors",
            impact=f"Road density adds about +{c:.1f}°C to the predicted heat here",
            description="Shade trees or canopies along busy corridors may reduce heat from paved roads.",
            badge="Recommended for high road density",
            details="Start with the most exposed road segments and pedestrian crossings.",
            category_code="shading", related_feature="road_density")))

    found.sort(key=lambda t: t[0], reverse=True)  # paling berpengaruh di atas
    return [m for _, m in found]
