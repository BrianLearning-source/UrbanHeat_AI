# Temperature data validation

This module validates temperature observations before provenance-aware
processing. It is read-only: it does not connect to Supabase, convert units,
filter rows, remove duplicates, or train a model.

## Validation rules

- Requires a finite temperature value, latitude in `[-90, 90]`, longitude in
  `[-180, 180]`, and a parseable ISO observation date or datetime.
- Accepts only explicitly recognized Celsius and Kelvin unit labels. It never
  converts between units.
- Requires source product, product version, source band, and a `raw` or
  `scaled` declaration to establish interpretability. A caller-supplied
  `ProductSpec` catalog is needed to verify product, version, band, and unit
  constraints.
- Scaled measurements require finite supplied scale metadata and an exact
  trusted scale-factor/offset specification keyed by product version and band.
  If either is unavailable or mismatched, the result is `UNKNOWN`. The module
  never applies a scale or offset. Provide `scale_metadata` as
  `{(version, band): (factor, offset)}`. Raw values remain `UNKNOWN`.
- QA is interpreted only through explicit per-version/per-band mappings in a
  caller-supplied `ProductSpec`, using
  `{(version, band): {raw_flag: ValidationStatus}}`. A missing, unsupported,
  or unspecified QA value is `UNKNOWN`; mapped statuses can flag a value as
  `INVALID`, `WARNING`, or `UNKNOWN`. The original input value is not changed.
  No QA rules are bundled, and no cloud filtering is performed.
- Flags duplicate observations only when product, version, band, normalized
  observation timestamp, and exact coordinates all match. Timezone-aware
  timestamps are normalized to UTC; naive datetimes are `UNKNOWN`. Records
  lacking any duplicate identity component are not grouped. All records are
  preserved.
- Broad suspicious temperature ranges are warnings, not scientific validity
  limits; callers can override them.
- Missing processing-version metadata is reported as a warning.
- Accepts `field_map` to map legacy column names such as `lst` and `date`.
  Missing metadata is not inferred from existing table names or UI labels.

## Status definitions

- `VALID`: required values are parseable and finite; units and product
  provenance are supported by the supplied catalog; no warnings were raised.
- `WARNING`: data is parseable but has a suspicious range, date-only time,
  duplicate key, or missing processing-version metadata.
- `INVALID`: required observation fields are missing or malformed, or
  coordinates are out of range, or a supported QA mapping classifies the
  observation as invalid.
- `UNKNOWN`: unit, timezone, scale specification, QA interpretation,
  scaling state, or product provenance cannot be verified.

Each record receives one overall status, with precedence `INVALID`, `UNKNOWN`,
`WARNING`, then `VALID`. Individual issues retain their own status. Duplicate
records are all preserved and reported.

## Current limitations

The live Supabase tables do not currently provide enough verified provenance
to validate their values as MODIS or any other product. No scale or QA
specifications are bundled because the source and processing history of those
rows are unknown. Callers must provide product/version/band-specific scale
metadata and QA interpretations from trusted sources; the validator does not
establish that those caller-supplied specifications are scientifically
authoritative. Suspicious ranges are deliberately broad and configurable. A
successful validation report is not calibration, ground truth, or an accuracy
claim.

## Calibration readiness pipeline

`calibration_pipeline.py` provides a read-only readiness assessment. It accepts
satellite LST observations and independent reference observations, runs both
sets through `validate_temperature_records`, and matches only records whose
validation status is `VALID`. It does not modify inputs, connect to Supabase,
convert units, or fit a model.

Each input record must use the validator's canonical fields and also provide:

- `source_dataset_id` (or `source_dataset`) and `source_observation_id`: a
  stable source identity. Repeated identities scoped by input side, dataset,
  product, version, and band are all retained but excluded from matching. If
  either identifier is missing or invalid, the pipeline reports the metadata
  gap and does not infer a duplicate key from a database row ID.
- `measurand`: a documented measurement concept; satellite and reference
  values must have the same normalized label.
- `measurand_definition_reference`: a non-empty reference to the documentation
  defining that measurement concept. The reference must match on both sides.
- `footprint_compatibility_id`: a shared identifier for a documented,
  caller-verified footprint comparison method. Coordinate proximity alone
  does not establish compatible footprints.
- Reference records additionally need `reference_independence_basis`, a
  non-empty provenance/documentation reference. Their `source_product` must
  differ from the satellite product. These references and declarations are
  not independently authenticated by the pipeline.

Use `assess_calibration_readiness` with both product catalogs and an explicit
`CalibrationConfig`. The configuration requires a maximum spatial distance in
meters, maximum time difference in seconds, and minimum matched-pair count.
Only timezone-aware `observation_datetime` values are matchable. A `created_at`
field is never used. Spatial distance is calculated between the supplied
coordinates using the haversine formula; the pipeline does not infer a
measurement footprint or spatially aggregate data.

Pairing requires equal measurand labels, equivalent recognized units (without
conversion), equal footprint compatibility identifiers, distinct source
products, and both configured distance/time thresholds. Matching is one-to-one
and deterministic; observations that cannot be paired are retained in the
report with exclusion reasons. Any `WARNING`, `UNKNOWN`, or `INVALID`
validation status excludes that record from matching.

Readiness is `READY` only when the number of valid matched pairs meets the
configured minimum. A positive but insufficient count is
`PARTIALLY_READY`; zero valid pairs is `NOT_READY`. Readiness is an input
eligibility gate, not evidence that a calibration model is scientifically
appropriate or accurate. No reference data, footprint method, thresholds,
scale specifications, QA rules, or minimum sample size are bundled.
The report's valid, invalid, warning, and unknown observation counts reflect
the validator statuses; exclusion reasons separately describe matching
eligibility and duplicate source identities.

## Run tests

From `Backend`:

```powershell
python -m unittest discover -s tests -v
```
