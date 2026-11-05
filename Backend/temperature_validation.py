"""Non-destructive validation for provenance-aware temperature observations."""

from __future__ import annotations

from collections import Counter, defaultdict
from dataclasses import dataclass, field
from datetime import date, datetime, time, timezone
from enum import Enum
from math import isfinite
from typing import Iterable, Mapping


class ValidationStatus(str, Enum):
    VALID = "VALID"
    WARNING = "WARNING"
    INVALID = "INVALID"
    UNKNOWN = "UNKNOWN"


@dataclass(frozen=True)
class ProductSpec:
    """Caller-verified product metadata used to interpret provenance fields."""

    versions: frozenset[str]
    bands: frozenset[str] = frozenset()
    temperature_units: frozenset[str] = frozenset()
    scale_metadata: Mapping[tuple[str, str], tuple[float, float]] = field(
        default_factory=dict
    )
    quality_flag_statuses: Mapping[
        tuple[str, str], Mapping[object, ValidationStatus]
    ] = field(default_factory=dict)

    def __post_init__(self) -> None:
        for key, scale in self.scale_metadata.items():
            if (
                not isinstance(key, tuple)
                or len(key) != 2
                or not all(isinstance(part, str) and part for part in key)
                or not isinstance(scale, (tuple, list))
                or len(scale) != 2
            ):
                raise ValueError(
                    "Scale metadata keys must be (version, band) pairs and "
                    "values must be (factor, offset) pairs."
                )
            try:
                factor, offset = (float(value) for value in scale)
            except (TypeError, ValueError, OverflowError) as error:
                raise ValueError(
                    "Scale factors and offsets must be finite numbers."
                ) from error
            if (
                any(isinstance(value, bool) for value in scale)
                or not isfinite(factor)
                or not isfinite(offset)
            ):
                raise ValueError(
                    "Scale factors and offsets must be finite numbers."
                )
        for key, statuses in self.quality_flag_statuses.items():
            if (
                not isinstance(key, tuple)
                or len(key) != 2
                or not all(isinstance(part, str) and part for part in key)
                or not isinstance(statuses, Mapping)
                or not all(
                    isinstance(status, ValidationStatus)
                    for status in statuses.values()
                )
            ):
                raise ValueError(
                    "QA specifications must map (version, band) pairs to "
                    "quality flag status mappings."
                )


@dataclass(frozen=True)
class ValidationIssue:
    code: str
    status: ValidationStatus
    field: str | None
    message: str

    def to_dict(self) -> dict[str, str | None]:
        return {
            "code": self.code,
            "status": self.status.value,
            "field": self.field,
            "message": self.message,
        }


@dataclass(frozen=True)
class RecordValidation:
    record_index: int
    record_id: str | int | float | None
    status: ValidationStatus
    issues: tuple[ValidationIssue, ...] = field(default_factory=tuple)

    def to_dict(self) -> dict[str, object]:
        return {
            "record_index": self.record_index,
            "record_id": self.record_id,
            "status": self.status.value,
            "issues": [issue.to_dict() for issue in self.issues],
        }


@dataclass(frozen=True)
class ValidationReport:
    total_records: int
    valid_records: int
    invalid_records: int
    warning_records: int
    unknown_records: int
    missing_metadata_counts: Mapping[str, int]
    duplicate_key_count: int
    duplicate_record_count: int
    records: tuple[RecordValidation, ...]

    def to_dict(self) -> dict[str, object]:
        return {
            "total_records": self.total_records,
            "valid_records": self.valid_records,
            "invalid_records": self.invalid_records,
            "warning_records": self.warning_records,
            "unknown_records": self.unknown_records,
            "missing_metadata_counts": dict(self.missing_metadata_counts),
            "duplicate_key_count": self.duplicate_key_count,
            "duplicate_record_count": self.duplicate_record_count,
            "records": [record.to_dict() for record in self.records],
        }


_DEFAULT_FIELD_MAP = {
    "record_id": "id",
    "temperature_value": "temperature_value",
    "latitude": "latitude",
    "longitude": "longitude",
    "observation_datetime": "observation_datetime",
    "temperature_unit": "temperature_unit",
    "source_product": "source_product",
    "product_version": "product_version",
    "source_band": "source_band",
    "raw_or_scaled": "raw_or_scaled",
    "scale_factor": "scale_factor",
    "scale_offset": "scale_offset",
    "quality_flag": "quality_flag",
    "processing_version": "processing_version",
}

_METADATA_FIELDS = (
    "source_product",
    "product_version",
    "source_band",
    "observation_datetime",
    "temperature_unit",
    "raw_or_scaled",
    "scale_factor",
    "scale_offset",
    "quality_flag",
    "processing_version",
)

_UNIT_ALIASES = {
    "c": "celsius",
    "°c": "celsius",
    "degc": "celsius",
    "degree celsius": "celsius",
    "degrees celsius": "celsius",
    "celsius": "celsius",
    "k": "kelvin",
    "degk": "kelvin",
    "kelvin": "kelvin",
}

_DEFAULT_SUSPICIOUS_RANGES = {
    "celsius": (-100.0, 100.0),
    "kelvin": (150.0, 400.0),
}


def validate_temperature_records(
    records: Iterable[Mapping[str, object]],
    *,
    product_catalog: Mapping[str, ProductSpec] | None = None,
    field_map: Mapping[str, str] | None = None,
    suspicious_ranges: Mapping[str, tuple[float, float]] | None = None,
) -> ValidationReport:
    """Validate records without changing them or converting temperature values.

    A product catalog is an explicit trust boundary: products absent from it
    cannot be independently checked and are reported with UNKNOWN status.
    ``field_map`` maps canonical field names to keys in the supplied records.
    """

    fields = dict(_DEFAULT_FIELD_MAP)
    if field_map:
        unknown_fields = set(field_map) - set(fields)
        if unknown_fields:
            names = ", ".join(sorted(unknown_fields))
            raise ValueError(f"Unsupported canonical field(s): {names}")
        fields.update(field_map)

    ranges = dict(_DEFAULT_SUSPICIOUS_RANGES)
    if suspicious_ranges:
        ranges.update(suspicious_ranges)
    for unit, bounds in ranges.items():
        if (
            len(bounds) != 2
            or not all(isfinite(float(bound)) for bound in bounds)
            or bounds[0] > bounds[1]
        ):
            raise ValueError(f"Invalid suspicious range for {unit!r}")

    catalog = product_catalog
    materialized_records = list(records)
    per_record_issues: list[list[ValidationIssue]] = [
        [] for _ in materialized_records
    ]
    missing_metadata = Counter({name: 0 for name in _METADATA_FIELDS})
    parsed_keys: dict[
        tuple[str, str, str, str, float, float], list[int]
    ] = defaultdict(list)

    def add_issue(
        index: int,
        code: str,
        status: ValidationStatus,
        field_name: str | None,
        message: str,
    ) -> None:
        per_record_issues[index].append(
            ValidationIssue(
                code=code,
                status=status,
                field=field_name,
                message=message,
            )
        )

    for index, record in enumerate(materialized_records):
        if not isinstance(record, Mapping):
            for name in _METADATA_FIELDS:
                missing_metadata[name] += 1
            add_issue(
                index,
                "invalid_record_type",
                ValidationStatus.INVALID,
                None,
                "Record must be a mapping of field names to values.",
            )
            continue

        for name in _METADATA_FIELDS:
            if _is_missing(record.get(fields[name])):
                missing_metadata[name] += 1

        parsed_date_key: str | None = None
        timezone_naive = False
        parsed_latitude: float | None = None
        parsed_longitude: float | None = None
        parsed_temperature: float | None = None

        raw_date = record.get(fields["observation_datetime"])
        if _is_missing(raw_date):
            add_issue(
                index,
                "missing_observation_datetime",
                ValidationStatus.INVALID,
                "observation_datetime",
                "Observation date or datetime is required.",
            )
        else:
            try:
                parsed_date_key, date_only, timezone_naive = _parse_datetime(
                    raw_date
                )
                if date_only:
                    add_issue(
                        index,
                        "date_without_time",
                        ValidationStatus.WARNING,
                        "observation_datetime",
                        "Date is present without an observation time; "
                        "overpass-level matching is not possible.",
                    )
                elif timezone_naive:
                    add_issue(
                        index,
                        "timezone_naive_datetime",
                        ValidationStatus.UNKNOWN,
                        "observation_datetime",
                        "Datetime has no timezone; its instant cannot be "
                        "compared reliably with timezone-aware observations.",
                    )
            except (TypeError, ValueError):
                add_issue(
                    index,
                    "invalid_observation_datetime",
                    ValidationStatus.INVALID,
                    "observation_datetime",
                    "Observation date must be a valid ISO date or datetime.",
                )

        raw_temperature = record.get(fields["temperature_value"])
        if _is_missing(raw_temperature):
            add_issue(
                index,
                "missing_temperature_value",
                ValidationStatus.INVALID,
                "temperature_value",
                "Temperature value is required.",
            )
        else:
            parsed_temperature = _finite_number(raw_temperature)
            if parsed_temperature is None:
                add_issue(
                    index,
                    "invalid_temperature_value",
                    ValidationStatus.INVALID,
                    "temperature_value",
                    "Temperature must be a finite numeric value.",
                )

        for coordinate_name, minimum, maximum in (
            ("latitude", -90.0, 90.0),
            ("longitude", -180.0, 180.0),
        ):
            raw_coordinate = record.get(fields[coordinate_name])
            if _is_missing(raw_coordinate):
                add_issue(
                    index,
                    f"missing_{coordinate_name}",
                    ValidationStatus.INVALID,
                    coordinate_name,
                    f"{coordinate_name.capitalize()} is required.",
                )
                continue

            coordinate = _finite_number(raw_coordinate)
            if coordinate is None:
                add_issue(
                    index,
                    f"invalid_{coordinate_name}",
                    ValidationStatus.INVALID,
                    coordinate_name,
                    f"{coordinate_name.capitalize()} must be a finite number.",
                )
            elif not minimum <= coordinate <= maximum:
                add_issue(
                    index,
                    f"{coordinate_name}_out_of_bounds",
                    ValidationStatus.INVALID,
                    coordinate_name,
                    f"{coordinate_name.capitalize()} must be between "
                    f"{minimum:g} and {maximum:g}.",
                )
            elif coordinate_name == "latitude":
                parsed_latitude = coordinate
            else:
                parsed_longitude = coordinate

        unit_value = record.get(fields["temperature_unit"])
        normalized_unit = _normalize_unit(unit_value)
        if normalized_unit is None:
            add_issue(
                index,
                "unknown_temperature_unit",
                ValidationStatus.UNKNOWN,
                "temperature_unit",
                "Temperature unit is missing or unsupported; values will not "
                "be converted or range-checked.",
            )

        product_value = record.get(fields["source_product"])
        product = _nonempty_string(product_value)
        if product is None:
            add_issue(
                index,
                "missing_source_product",
                ValidationStatus.UNKNOWN,
                "source_product",
                "Source product is required to establish data provenance.",
            )
        elif catalog is None:
            add_issue(
                index,
                "product_catalog_unavailable",
                ValidationStatus.UNKNOWN,
                "source_product",
                "No verified product catalog was supplied; source provenance "
                "cannot be checked.",
            )
        elif product not in catalog:
            add_issue(
                index,
                "unknown_source_product",
                ValidationStatus.UNKNOWN,
                "source_product",
                f"Source product {product!r} is not in the supplied catalog.",
            )

        spec = catalog.get(product) if catalog is not None and product else None
        version = _nonempty_string(record.get(fields["product_version"]))
        if version is None:
            add_issue(
                index,
                "missing_product_version",
                ValidationStatus.UNKNOWN,
                "product_version",
                "Product version is required to verify product semantics.",
            )
        elif spec is not None and version not in spec.versions:
            add_issue(
                index,
                "unsupported_product_version",
                ValidationStatus.UNKNOWN,
                "product_version",
                f"Product version {version!r} is not listed for "
                f"{product!r}.",
            )

        band = _nonempty_string(record.get(fields["source_band"]))
        if band is None:
            add_issue(
                index,
                "missing_source_band",
                ValidationStatus.UNKNOWN,
                "source_band",
                "Source band is required to identify the temperature input.",
            )
        elif spec is not None and spec.bands and band not in spec.bands:
            add_issue(
                index,
                "unsupported_source_band",
                ValidationStatus.UNKNOWN,
                "source_band",
                f"Source band {band!r} is not listed for {product!r}.",
            )

        if (
            spec is not None
            and spec.temperature_units
            and normalized_unit is not None
            and normalized_unit not in {
                _normalize_unit(value) for value in spec.temperature_units
            }
        ):
            add_issue(
                index,
                "unit_mismatch_for_product",
                ValidationStatus.UNKNOWN,
                "temperature_unit",
                f"Unit {unit_value!r} is not listed for product {product!r}.",
            )

        representation = _nonempty_string(
            record.get(fields["raw_or_scaled"])
        )
        if representation is None:
            add_issue(
                index,
                "missing_raw_or_scaled",
                ValidationStatus.UNKNOWN,
                "raw_or_scaled",
                "Declare whether the supplied value is raw or scaled.",
            )
        elif representation.casefold() not in {"raw", "scaled"}:
            add_issue(
                index,
                "unknown_raw_or_scaled",
                ValidationStatus.UNKNOWN,
                "raw_or_scaled",
                "raw_or_scaled must be either 'raw' or 'scaled'.",
            )
        elif representation.casefold() == "raw":
            add_issue(
                index,
                "raw_value_not_interpreted",
                ValidationStatus.UNKNOWN,
                "raw_or_scaled",
                "Raw values are not temperature-interpreted or converted by "
                "this validator.",
            )

        scale_factor = _finite_number(record.get(fields["scale_factor"]))
        scale_offset = _finite_number(record.get(fields["scale_offset"]))
        if scale_factor is None:
            add_issue(
                index,
                "missing_or_invalid_scale_factor",
                ValidationStatus.UNKNOWN,
                "scale_factor",
                "A finite scale factor is required to verify value scaling.",
            )
        if scale_offset is None:
            add_issue(
                index,
                "missing_or_invalid_scale_offset",
                ValidationStatus.UNKNOWN,
                "scale_offset",
                "A finite scale offset is required to verify value scaling.",
            )
        scale_spec = (
            spec.scale_metadata.get((version, band))
            if spec is not None and version is not None and band is not None
            else None
        )
        if scale_spec is None:
            add_issue(
                index,
                "scale_specification_unavailable",
                ValidationStatus.UNKNOWN,
                "scale_factor",
                "No trusted scale factor and offset are specified for this "
                "product, version, and band.",
            )
        elif scale_factor is not None and scale_offset is not None:
            expected_factor, expected_offset = (
                float(value) for value in scale_spec
            )
            if (
                scale_factor != expected_factor
                or scale_offset != expected_offset
            ):
                add_issue(
                    index,
                    "scale_metadata_mismatch",
                    ValidationStatus.UNKNOWN,
                    "scale_factor",
                    "Supplied scale factor or offset does not match the "
                    "trusted product, version, and band specification.",
                )

        if (
            parsed_temperature is not None
            and normalized_unit is not None
            and representation is not None
            and representation.casefold() == "scaled"
            and normalized_unit in ranges
        ):
            lower, upper = ranges[normalized_unit]
            if not lower <= parsed_temperature <= upper:
                add_issue(
                    index,
                    "suspicious_temperature_range",
                    ValidationStatus.WARNING,
                    "temperature_value",
                    f"Value is outside the configured suspicious range "
                    f"[{lower:g}, {upper:g}] {normalized_unit}; it is retained "
                    "and requires source-specific review.",
                )

        raw_quality_flag = record.get(fields["quality_flag"])
        quality_statuses = (
            spec.quality_flag_statuses.get((version, band))
            if spec is not None and version is not None and band is not None
            else None
        )
        if _is_missing(raw_quality_flag):
            add_issue(
                index,
                "quality_flag_unavailable",
                ValidationStatus.UNKNOWN,
                "quality_flag",
                "No quality flag was supplied.",
            )
        elif quality_statuses is None:
            add_issue(
                index,
                "quality_flag_interpretation_unavailable",
                ValidationStatus.UNKNOWN,
                "quality_flag",
                "No trusted QA interpretation is specified for this product, "
                "version, and band.",
            )
        else:
            try:
                quality_status = quality_statuses.get(raw_quality_flag)
            except TypeError:
                quality_status = None
            if quality_status is None:
                add_issue(
                    index,
                    "unsupported_quality_flag",
                    ValidationStatus.UNKNOWN,
                    "quality_flag",
                    "Quality flag value is not defined by the trusted "
                    "product-specific QA interpretation.",
                )
            elif quality_status is not ValidationStatus.VALID:
                add_issue(
                    index,
                    "quality_flag_rejected",
                    quality_status,
                    "quality_flag",
                    "Quality flag is classified by the trusted "
                    "product-specific QA interpretation.",
                )
        if _is_missing(record.get(fields["processing_version"])):
            add_issue(
                index,
                "processing_version_unavailable",
                ValidationStatus.WARNING,
                "processing_version",
                "Processing version was not supplied.",
            )

        if (
            parsed_date_key is not None
            and parsed_latitude is not None
            and parsed_longitude is not None
            and product is not None
            and version is not None
            and band is not None
        ):
            parsed_keys[
                (
                    product,
                    version,
                    band,
                    parsed_date_key,
                    parsed_latitude,
                    parsed_longitude,
                )
            ].append(index)

    duplicate_groups = [
        indices for indices in parsed_keys.values() if len(indices) > 1
    ]
    duplicate_record_count = 0
    for indices in duplicate_groups:
        duplicate_record_count += len(indices)
        for index in indices:
            add_issue(
                index,
                "duplicate_date_coordinate_key",
                ValidationStatus.WARNING,
                "observation_datetime",
                "Another record has the same product, version, band, "
                "normalized observation time, and exact coordinates. Records "
                "are retained unchanged.",
            )

    validations: list[RecordValidation] = []
    for index, record in enumerate(materialized_records):
        issues = per_record_issues[index]
        statuses = {issue.status for issue in issues}
        if ValidationStatus.INVALID in statuses:
            status = ValidationStatus.INVALID
        elif ValidationStatus.UNKNOWN in statuses:
            status = ValidationStatus.UNKNOWN
        elif ValidationStatus.WARNING in statuses:
            status = ValidationStatus.WARNING
        else:
            status = ValidationStatus.VALID

        record_id = (
            record.get(fields["record_id"])
            if isinstance(record, Mapping)
            else None
        )
        validations.append(
            RecordValidation(
                record_index=index,
                record_id=_safe_record_id(record_id),
                status=status,
                issues=tuple(issues),
            )
        )

    status_counts = Counter(record.status for record in validations)
    return ValidationReport(
        total_records=len(validations),
        valid_records=status_counts[ValidationStatus.VALID],
        invalid_records=status_counts[ValidationStatus.INVALID],
        warning_records=status_counts[ValidationStatus.WARNING],
        unknown_records=status_counts[ValidationStatus.UNKNOWN],
        missing_metadata_counts=dict(missing_metadata),
        duplicate_key_count=len(duplicate_groups),
        duplicate_record_count=duplicate_record_count,
        records=tuple(validations),
    )


def _is_missing(value: object) -> bool:
    return value is None or (isinstance(value, str) and not value.strip())


def _finite_number(value: object) -> float | None:
    if isinstance(value, bool) or _is_missing(value):
        return None
    try:
        number = float(value)
    except (TypeError, ValueError, OverflowError):
        return None
    return number if isfinite(number) else None


def _parse_datetime(value: object) -> tuple[str, bool, bool]:
    date_only = False
    if isinstance(value, datetime):
        parsed = value
    elif isinstance(value, date):
        parsed = datetime.combine(value, time.min)
        date_only = True
    elif isinstance(value, str):
        text = value.strip()
        if len(text) == 10:
            parsed_date = date.fromisoformat(text)
            parsed = datetime.combine(parsed_date, time.min)
            date_only = True
        else:
            parsed = datetime.fromisoformat(text.replace("Z", "+00:00"))
    else:
        raise TypeError("Unsupported date value")

    if parsed.tzinfo is not None:
        return parsed.astimezone(timezone.utc).isoformat(), date_only, False
    return parsed.isoformat(), date_only, not date_only


def _normalize_unit(value: object) -> str | None:
    unit = _nonempty_string(value)
    return _UNIT_ALIASES.get(unit.casefold()) if unit else None


def _nonempty_string(value: object) -> str | None:
    if not isinstance(value, str) or not value.strip():
        return None
    return value.strip()


def _safe_record_id(value: object) -> str | int | float | None:
    if isinstance(value, (str, int, float)) and not isinstance(value, bool):
        if not isinstance(value, float) or isfinite(value):
            return value
    return None
