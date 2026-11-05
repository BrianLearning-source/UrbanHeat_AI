"""Read-only assessment of temperature observation calibration readiness."""

from __future__ import annotations

from collections import Counter
from dataclasses import dataclass
from datetime import datetime, timezone
from enum import Enum
from math import asin, cos, isfinite, radians, sin, sqrt
from typing import Iterable, Mapping

from temperature_validation import (
    ProductSpec,
    RecordValidation,
    ValidationReport,
    ValidationStatus,
    normalize_temperature_unit,
    validate_temperature_records,
)

class CalibrationReadinessStatus(str, Enum):
    READY = "READY"
    PARTIALLY_READY = "PARTIALLY_READY"
    NOT_READY = "NOT_READY"


@dataclass(frozen=True)
class CalibrationConfig:
    max_spatial_distance_meters: float
    max_temporal_difference_seconds: float
    minimum_matched_pairs: int

    def __post_init__(self) -> None:
        if (
            isinstance(self.max_spatial_distance_meters, bool)
            or not isinstance(self.max_spatial_distance_meters, (int, float))
            or not isfinite(self.max_spatial_distance_meters)
            or self.max_spatial_distance_meters <= 0
        ):
            raise ValueError("Spatial distance threshold must be positive.")
        if (
            isinstance(self.max_temporal_difference_seconds, bool)
            or not isinstance(
                self.max_temporal_difference_seconds, (int, float)
            )
            or not isfinite(self.max_temporal_difference_seconds)
            or self.max_temporal_difference_seconds < 0
        ):
            raise ValueError("Temporal difference threshold cannot be negative.")
        if (
            isinstance(self.minimum_matched_pairs, bool)
            or not isinstance(self.minimum_matched_pairs, int)
            or self.minimum_matched_pairs < 1
        ):
            raise ValueError("Minimum matched pairs must be at least one.")


@dataclass(frozen=True)
class MatchedObservationPair:
    satellite_index: int
    reference_index: int
    satellite_record_id: str | int | float | None
    reference_record_id: str | int | float | None
    distance_meters: float
    time_difference_seconds: float

    def to_dict(self) -> dict[str, object]:
        return {
            "satellite_index": self.satellite_index,
            "reference_index": self.reference_index,
            "satellite_record_id": self.satellite_record_id,
            "reference_record_id": self.reference_record_id,
            "distance_meters": self.distance_meters,
            "time_difference_seconds": self.time_difference_seconds,
        }


@dataclass(frozen=True)
class ObservationExclusion:
    side: str
    record_index: int
    record_id: str | int | float | None
    reasons: tuple[str, ...]

    def to_dict(self) -> dict[str, object]:
        return {
            "side": self.side,
            "record_index": self.record_index,
            "record_id": self.record_id,
            "reasons": list(self.reasons),
        }


@dataclass(frozen=True)
class CalibrationReadinessReport:
    total_satellite_observations: int
    total_reference_observations: int
    matched_pairs: tuple[MatchedObservationPair, ...]
    unmatched_satellite_observations: tuple[ObservationExclusion, ...]
    unmatched_reference_observations: tuple[ObservationExclusion, ...]
    invalid_observations: int
    missing_metadata_counts: Mapping[str, int]
    exclusion_reasons: Mapping[str, int]
    readiness_status: CalibrationReadinessStatus
    minimum_matched_pairs: int
    valid_observations: int = 0
    warning_observations: int = 0
    unknown_observations: int = 0

    def to_dict(self) -> dict[str, object]:
        return {
            "total_satellite_observations": self.total_satellite_observations,
            "total_reference_observations": self.total_reference_observations,
            "matched_pairs": [pair.to_dict() for pair in self.matched_pairs],
            "unmatched_satellite_observations": [
                item.to_dict()
                for item in self.unmatched_satellite_observations
            ],
            "unmatched_reference_observations": [
                item.to_dict()
                for item in self.unmatched_reference_observations
            ],
            "valid_observations": self.valid_observations,
            "invalid_observations": self.invalid_observations,
            "warning_observations": self.warning_observations,
            "unknown_observations": self.unknown_observations,
            "missing_metadata_counts": dict(self.missing_metadata_counts),
            "exclusion_reasons": dict(self.exclusion_reasons),
            "readiness_status": self.readiness_status.value,
            "minimum_matched_pairs": self.minimum_matched_pairs,
        }


@dataclass
class _PreparedObservation:
    record: Mapping[str, object] | object
    validation: RecordValidation
    side: str
    measurand: str | None
    measurand_definition_reference: str | None
    unit: str | None
    product: str | None
    footprint_id: str | None
    timestamp: datetime | None
    latitude: float | None
    longitude: float | None
    independence_basis: str | None
    source_identity: tuple[object, ...] | None
    reasons: set[str]

    @property
    def record_id(self) -> str | int | float | None:
        if not isinstance(self.record, Mapping):
            return None
        value = self.record.get("id")
        if isinstance(value, bool) or not isinstance(value, (str, int, float)):
            return None
        if isinstance(value, float) and not isfinite(value):
            return None
        return value

    @property
    def eligible(self) -> bool:
        return (
            not self.reasons
            and self.validation.status is ValidationStatus.VALID
            and self.measurand is not None
            and self.measurand_definition_reference is not None
            and self.unit is not None
            and self.product is not None
            and self.footprint_id is not None
            and self.timestamp is not None
            and self.latitude is not None
            and self.longitude is not None
        )


def assess_calibration_readiness(
    satellite_observations: Iterable[object],
    reference_observations: Iterable[object],
    *,
    satellite_product_catalog: Mapping[str, ProductSpec] | None,
    reference_product_catalog: Mapping[str, ProductSpec] | None,
    config: CalibrationConfig,
) -> CalibrationReadinessReport:
    """Validate and collocate independent observations without fitting a model.

    Inputs use the canonical fields accepted by ``validate_temperature_records``
    plus ``measurand``, ``measurand_definition_reference``, and
    ``footprint_compatibility_id``. Reference records must also provide
    ``reference_independence_basis``. These references and declarations are
    caller-provided, not independently verified scientific evidence.
    """

    satellites = list(satellite_observations)
    references = list(reference_observations)
    satellite_validation = validate_temperature_records(
        satellites, product_catalog=satellite_product_catalog
    )
    reference_validation = validate_temperature_records(
        references, product_catalog=reference_product_catalog
    )

    missing_metadata: Counter[str] = Counter()
    _collect_validation_missing_metadata(
        missing_metadata, "satellite", satellite_validation
    )
    _collect_validation_missing_metadata(
        missing_metadata, "reference", reference_validation
    )
    satellite_items = _prepare_observations(
        satellites, satellite_validation, "satellite", missing_metadata
    )
    reference_items = _prepare_observations(
        references, reference_validation, "reference", missing_metadata
    )
    _mark_duplicate_source_observations(satellite_items)
    _mark_duplicate_source_observations(reference_items)

    candidate_pairs: list[tuple[float, float, int, int]] = []
    satellite_pair_reasons: dict[int, set[str]] = {}
    reference_pair_reasons: dict[int, set[str]] = {}

    def add_pair_reasons(
        satellite_index: int,
        reference_index: int,
        reasons: set[str],
    ) -> None:
        satellite_pair_reasons.setdefault(satellite_index, set()).update(reasons)
        reference_pair_reasons.setdefault(reference_index, set()).update(reasons)

    for satellite in satellite_items:
        for reference in reference_items:
            if not satellite.eligible or not reference.eligible:
                continue
            pair_reasons: set[str] = set()
            if satellite.measurand != reference.measurand:
                pair_reasons.add("measurand_mismatch")
            if (
                satellite.measurand_definition_reference
                != reference.measurand_definition_reference
            ):
                pair_reasons.add("measurand_definition_mismatch")
            if satellite.unit != reference.unit:
                pair_reasons.add("unit_mismatch")
            if satellite.footprint_id != reference.footprint_id:
                pair_reasons.add("footprint_compatibility_mismatch")
            if satellite.product == reference.product:
                pair_reasons.add("reference_not_independent_source")
            if reference.independence_basis is None:
                pair_reasons.add("missing_reference_independence_basis")

            if pair_reasons:
                add_pair_reasons(
                    satellite.validation.record_index,
                    reference.validation.record_index,
                    pair_reasons,
                )
                continue

            distance = _distance_meters(
                satellite.latitude,
                satellite.longitude,
                reference.latitude,
                reference.longitude,
            )
            time_difference = abs(
                (satellite.timestamp - reference.timestamp).total_seconds()
            )
            if distance > config.max_spatial_distance_meters:
                add_pair_reasons(
                    satellite.validation.record_index,
                    reference.validation.record_index,
                    {"spatial_tolerance_exceeded"},
                )
            elif time_difference > config.max_temporal_difference_seconds:
                add_pair_reasons(
                    satellite.validation.record_index,
                    reference.validation.record_index,
                    {"temporal_tolerance_exceeded"},
                )
            else:
                candidate_pairs.append(
                    (
                        distance,
                        time_difference,
                        satellite.validation.record_index,
                        reference.validation.record_index,
                    )
                )

    eligible_satellites = [item for item in satellite_items if item.eligible]
    eligible_references = [item for item in reference_items if item.eligible]
    if reference_items and not eligible_references:
        for item in eligible_satellites:
            item.reasons.add("no_eligible_reference_observations")
    if satellite_items and not eligible_satellites:
        for item in eligible_references:
            item.reasons.add("no_eligible_satellite_observations")

    satellite_by_index = {
        item.validation.record_index: item for item in satellite_items
    }
    reference_by_index = {
        item.validation.record_index: item for item in reference_items
    }
    candidates_by_satellite: dict[
        int, list[tuple[float, float, int]]
    ] = {}
    candidate_costs: dict[tuple[int, int], tuple[float, float]] = {}
    satellites_with_candidates: set[int] = set()
    references_with_candidates: set[int] = set()
    for distance, time_difference, satellite_index, reference_index in sorted(
        candidate_pairs
    ):
        candidates_by_satellite.setdefault(satellite_index, []).append(
            (distance, time_difference, reference_index)
        )
        candidate_costs[(satellite_index, reference_index)] = (
            distance,
            time_difference,
        )
        satellites_with_candidates.add(satellite_index)
        references_with_candidates.add(reference_index)

    reference_matches: dict[int, tuple[int, float, float]] = {}
    satellite_matches: dict[int, int] = {}
    for satellite_index in sorted(candidates_by_satellite):
        if satellite_index in satellite_matches:
            continue
        pending_satellites = [satellite_index]
        visited_satellites = {satellite_index}
        parent_reference: dict[int, int] = {}
        parent_satellite: dict[int, int] = {}
        free_reference: int | None = None
        cursor = 0
        while cursor < len(pending_satellites) and free_reference is None:
            current_satellite = pending_satellites[cursor]
            cursor += 1
            for _, _, reference_index in candidates_by_satellite.get(
                current_satellite, []
            ):
                if reference_index in parent_reference:
                    continue
                parent_reference[reference_index] = current_satellite
                existing = reference_matches.get(reference_index)
                if existing is None:
                    free_reference = reference_index
                    break
                matched_satellite = existing[0]
                if matched_satellite not in visited_satellites:
                    visited_satellites.add(matched_satellite)
                    parent_satellite[matched_satellite] = reference_index
                    pending_satellites.append(matched_satellite)
        if free_reference is None:
            continue

        reference_index = free_reference
        while True:
            matched_satellite = parent_reference[reference_index]
            distance, time_difference = candidate_costs[
                (matched_satellite, reference_index)
            ]
            reference_matches[reference_index] = (
                matched_satellite,
                distance,
                time_difference,
            )
            satellite_matches[matched_satellite] = reference_index
            if matched_satellite == satellite_index:
                break
            reference_index = parent_satellite[matched_satellite]

    matched_satellites = set(satellite_matches)
    matched_references = set(reference_matches)
    matched_pairs = [
        MatchedObservationPair(
            satellite_index=satellite_index,
            reference_index=reference_index,
            satellite_record_id=satellite_by_index[
                satellite_index
            ].record_id,
            reference_record_id=reference_by_index[
                reference_index
            ].record_id,
            distance_meters=distance,
            time_difference_seconds=time_difference,
        )
        for reference_index, (
            satellite_index,
            distance,
            time_difference,
        ) in sorted(
            reference_matches.items(),
            key=lambda item: item[1][0],
        )
    ]
    for item in satellite_items:
        index = item.validation.record_index
        if index not in matched_satellites and index in satellites_with_candidates:
            item.reasons.add("one_to_one_match_capacity")
    for item in reference_items:
        index = item.validation.record_index
        if index not in matched_references and index in references_with_candidates:
            item.reasons.add("one_to_one_match_capacity")
    for item in satellite_items:
        index = item.validation.record_index
        if index not in matched_satellites:
            item.reasons.update(satellite_pair_reasons.get(index, set()))
    for item in reference_items:
        index = item.validation.record_index
        if index not in matched_references:
            item.reasons.update(reference_pair_reasons.get(index, set()))

    unmatched_satellites = _unmatched_observations(
        satellite_items, matched_satellites
    )
    unmatched_references = _unmatched_observations(
        reference_items, matched_references
    )
    if not satellite_items or not reference_items:
        for item in satellite_items:
            if item.validation.record_index not in matched_satellites:
                item.reasons.add("no_opposite_observations")
        for item in reference_items:
            if item.validation.record_index not in matched_references:
                item.reasons.add("no_opposite_observations")
        unmatched_satellites = _unmatched_observations(
            satellite_items, matched_satellites
        )
        unmatched_references = _unmatched_observations(
            reference_items, matched_references
        )
    exclusions = Counter(
        reason
        for item in unmatched_satellites + unmatched_references
        for reason in item.reasons
    )
    validation_status_counts = Counter(
        item.validation.status for item in satellite_items + reference_items
    )
    if len(matched_pairs) >= config.minimum_matched_pairs:
        readiness = CalibrationReadinessStatus.READY
    elif matched_pairs:
        readiness = CalibrationReadinessStatus.PARTIALLY_READY
    else:
        readiness = CalibrationReadinessStatus.NOT_READY

    return CalibrationReadinessReport(
        total_satellite_observations=len(satellites),
        total_reference_observations=len(references),
        matched_pairs=tuple(matched_pairs),
        unmatched_satellite_observations=unmatched_satellites,
        unmatched_reference_observations=unmatched_references,
        valid_observations=validation_status_counts[ValidationStatus.VALID],
        invalid_observations=validation_status_counts[ValidationStatus.INVALID],
        warning_observations=validation_status_counts[ValidationStatus.WARNING],
        unknown_observations=validation_status_counts[ValidationStatus.UNKNOWN],
        missing_metadata_counts=dict(missing_metadata),
        exclusion_reasons=dict(exclusions),
        readiness_status=readiness,
        minimum_matched_pairs=config.minimum_matched_pairs,
    )


def _collect_validation_missing_metadata(
    counts: Counter[str],
    side: str,
    report: ValidationReport,
) -> None:
    for field_name, count in report.missing_metadata_counts.items():
        if count:
            counts[f"{side}.{field_name}"] += count


def _prepare_observations(
    records: list[object],
    report: ValidationReport,
    side: str,
    missing_metadata: Counter[str],
) -> list[_PreparedObservation]:
    prepared: list[_PreparedObservation] = []
    for index, record in enumerate(records):
        validation = report.records[index]
        reasons: set[str] = set()
        record_data = record if isinstance(record, Mapping) else {}
        if not isinstance(record, Mapping):
            reasons.add("malformed_record")
        if validation.status is not ValidationStatus.VALID:
            reasons.add(f"validation_{validation.status.value.casefold()}")
            reasons.update(issue.code for issue in validation.issues)

        measurand = _nonempty_string(record_data.get("measurand"))
        measurand_definition_reference = _nonempty_string(
            record_data.get("measurand_definition_reference")
        )
        footprint_id = _nonempty_string(
            record_data.get("footprint_compatibility_id")
        )
        independence_basis = (
            _nonempty_string(
                record_data.get("reference_independence_basis")
            )
            if side == "reference"
            else None
        )
        for name, value in (
            ("measurand", measurand),
            ("measurand_definition_reference", measurand_definition_reference),
            ("footprint_compatibility_id", footprint_id),
        ):
            if value is None:
                missing_metadata[f"{side}.{name}"] += 1
                reasons.add(f"missing_{name}")
        if side == "reference" and independence_basis is None:
            missing_metadata["reference.reference_independence_basis"] += 1
            reasons.add("missing_reference_independence_basis")

        timestamp, time_reason = _parse_aware_datetime(
            record_data.get("observation_datetime")
        )
        if time_reason is not None:
            reasons.add(time_reason)
        unit = normalize_temperature_unit(record_data.get("temperature_unit"))
        product = _nonempty_string(record_data.get("source_product"))
        latitude = _finite_coordinate(record_data.get("latitude"))
        longitude = _finite_coordinate(record_data.get("longitude"))
        source_identity = _source_observation_identity(
            record_data,
            side=side,
            product=product,
            missing_metadata=missing_metadata,
        )
        if source_identity is None and isinstance(record, Mapping):
            reasons.add("source_observation_identity_unavailable")

        prepared.append(
            _PreparedObservation(
                record=record_data,
                validation=validation,
                side=side,
                measurand=measurand.casefold() if measurand else None,
                measurand_definition_reference=measurand_definition_reference,
                unit=unit,
                product=product,
                footprint_id=footprint_id,
                timestamp=timestamp,
                latitude=latitude,
                longitude=longitude,
                independence_basis=independence_basis,
                source_identity=source_identity,
                reasons=reasons,
            )
        )
    return prepared


def _source_observation_identity(
    record: Mapping[str, object],
    *,
    side: str,
    product: str | None,
    missing_metadata: Counter[str],
) -> tuple[object, ...] | None:
    source_id = _identity_value(record.get("source_observation_id"))
    if source_id is None:
        missing_metadata[f"{side}.source_observation_id"] += 1
        return None

    source_dataset = _identity_value(record.get("source_dataset_id"))
    if source_dataset is None:
        source_dataset = _identity_value(record.get("source_dataset"))
    if source_dataset is None:
        missing_metadata[f"{side}.source_dataset_id"] += 1
        return None

    version = _nonempty_string(record.get("product_version"))
    band = _nonempty_string(record.get("source_band"))
    if product is None or version is None or band is None:
        return None

    return (side, source_dataset, product, version, band, source_id)


def _identity_value(value: object) -> tuple[str, object] | None:
    if isinstance(value, bool):
        return None
    if isinstance(value, str) and value.strip():
        return ("str", value.strip())
    if isinstance(value, int):
        return ("int", value)
    if isinstance(value, float) and isfinite(value):
        return ("float", value)
    return None


def _mark_duplicate_source_observations(
    observations: list[_PreparedObservation],
) -> None:
    identity_groups: dict[tuple[object, ...], list[_PreparedObservation]] = {}
    for item in observations:
        if item.source_identity is None:
            continue
        identity_groups.setdefault(item.source_identity, []).append(item)

    for group in identity_groups.values():
        if len(group) < 2:
            continue
        for item in group:
            item.reasons.add("duplicate_source_observation_id")


def _unmatched_observations(
    observations: list[_PreparedObservation],
    matched_indices: set[int],
) -> tuple[ObservationExclusion, ...]:
    exclusions: list[ObservationExclusion] = []
    for item in observations:
        index = item.validation.record_index
        if index in matched_indices:
            continue
        reasons = set(item.reasons)
        if not reasons:
            reasons.add("no_compatible_match")
        exclusions.append(
            ObservationExclusion(
                side=item.side,
                record_index=index,
                record_id=item.record_id,
                reasons=tuple(sorted(reasons)),
            )
        )
    return tuple(exclusions)


def _parse_aware_datetime(
    value: object,
) -> tuple[datetime | None, str | None]:
    if isinstance(value, datetime):
        parsed = value
    elif isinstance(value, str):
        text = value.strip()
        if not text or len(text) == 10:
            return None, "observation_datetime_missing_or_date_only"
        try:
            parsed = datetime.fromisoformat(text.replace("Z", "+00:00"))
        except ValueError:
            return None, "observation_datetime_unparseable"
    else:
        return None, "observation_datetime_missing_or_date_only"

    if parsed.tzinfo is None or parsed.utcoffset() is None:
        return None, "observation_datetime_timezone_missing"
    return parsed.astimezone(timezone.utc), None


def _finite_coordinate(value: object) -> float | None:
    if isinstance(value, bool):
        return None
    try:
        coordinate = float(value)
    except (TypeError, ValueError, OverflowError):
        return None
    return coordinate if isfinite(coordinate) else None


def _nonempty_string(value: object) -> str | None:
    if not isinstance(value, str) or not value.strip():
        return None
    return value.strip()


def _distance_meters(
    first_latitude: float,
    first_longitude: float,
    second_latitude: float,
    second_longitude: float,
) -> float:
    earth_radius_meters = 6_371_008.8
    lat1 = radians(first_latitude)
    lat2 = radians(second_latitude)
    delta_lat = lat2 - lat1
    delta_lon = radians(second_longitude - first_longitude)
    haversine = (
        sin(delta_lat / 2) ** 2
        + cos(lat1) * cos(lat2) * sin(delta_lon / 2) ** 2
    )
    return earth_radius_meters * 2 * asin(sqrt(min(1.0, haversine)))
