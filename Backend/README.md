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

## Run tests

From `Backend`:

```powershell
python -m unittest discover -s tests -v
```
