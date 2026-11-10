# UrbanHeat AI Dataset Acquisition Requirements

**Audience:** ML/data, backend, database, and project coordination teams  
**Purpose:** Request and organize the evidence needed to determine whether project observations can support calibration-readiness assessment.  
**Scope:** Documentation and data handoff requirements only. This document does not authorize schema changes, data downloads, model fitting, or live database access.

## Evidence status at handoff

- **VERIFIED** — directly present in inspected repository code or checked-in schema declaration. It does not imply that a remote database matches the declaration.
- **DOCUMENTED** — stated in project documentation but not independently verified against original files or authoritative source metadata.
- **UNKNOWN** — not established by the repository evidence available for the provenance audit.
- **NOT VERIFIED** — deliberately not a fourth evidence category: use **UNKNOWN** when a claim lacks confirmation.

The original provenance inventory found no **original source granules/exports or independent reference records**. A subsequent ML1/ML2 artifact review found local candidate CSV datasets and notebooks (**VERIFIED** as workspace artifacts; see `ML_MODEL_SELECTION_AUDIT.md`). The ML2 notebook **DOCUMENTS** a Terra MOD11A1/Aqua MYD11A1 `v061` workflow, `LST_Day_1km`, 1 km extraction, `QC_Day` screening, and a `0.02` scale followed by Kelvin-to-Celsius conversion. These notebook details do not verify that the local candidate rows were produced from those source products or processing steps; original granules, export manifests, and row-level lineage remain **UNKNOWN**. A project report separately **DOCUMENTS** approximately 116 spatial points and 150 dates, weekly aggregation, and cloud-gap imputation. Those counts and processing statements are not verified facts about current Supabase records. The migration is a reconstructed baseline and is not confirmed as the live schema.

## 1. Satellite LST dataset

Please provide the original observations and enough retained metadata to connect each derived value back to its source. Do not fill missing provenance from filenames, UI labels, or assumed product conventions.

### Required files

- Original MODIS/MOD11A1 granules or provider downloads used by the project, in their original format and with original names.
- Companion metadata files and provider-generated manifests, including product/collection metadata, granule identifiers, acquisition metadata, and checksums where available.
- The exact extracted/converted files used by the project, not only a later merged table.
- QA layers or QA values corresponding to every LST observation; do not provide only a cloud-filtered output if the original QA evidence can be retained.
- A file inventory linking source files to each processing stage and identifying missing or unavailable files.

If redistribution is restricted, provide a source URL/catalog reference, product and granule identifiers, access/retrieval date, and checksums or another stable integrity identifier. Do not place credentials or access tokens in the handoff.

### Required metadata and history

| Item to provide | Minimum evidence requested |
|---|---|
| Product identity and version | Provider/source, MODIS instrument/product identifier, exact product name and collection/version (including Terra MOD11A1 and/or Aqua MYD11A1 only where applicable), granule IDs, source URL/catalog reference, and download/retrieval date. The ML2 notebook documents both Terra MOD11A1 and Aqua MYD11A1 `v061`; provide source metadata to verify which, if either, produced each delivered row. Include original metadata, not just a manually typed label. |
| LST band | Exact SDS/band/subdataset name and the field in each derived file that came from it. Identify any alternate day/night band or other selection. |
| Native encoding and scale | Product documentation or metadata reference for stored type, fill/missing values, valid range, native unit, scale factor, and offset. Provide the raw stored values and a separate explanation of any scale/offset applied. |
| QA and cloud filtering | Original QA bit fields/flags; authoritative interpretation reference; selected accepted/rejected values; cloud/snow/quality criteria; masking order; and counts/reasons for removed, retained, or imputed observations. Include code/configuration implementing the rules. |
| Acquisition time | Per-granule acquisition date/time and time convention/zone if available; per-observation acquisition timestamp or documented temporal precision; and mapping to the source granule/pixel. A calendar date or row insertion time alone is insufficient for time collocation. |
| Coordinates and resolution | Coordinate values and coordinate order; CRS/EPSG or source grid definition; any reprojection/resampling method; spatial resolution and its authoritative source; and pixel/footprint or grid identifier. Distinguish point coordinates from pixel footprints. |
| Unit conversion history | Source unit, transformation formula, scale/offset, any Kelvin/Celsius conversion, rounding, and the processing step/version that applied it. Preserve raw and converted values separately where available. |
| Processing history | Scripts/notebooks, parameters, software/library versions, run dates, masking, reprojection, resampling, spatial extraction, temporal aggregation, imputation, and output naming/version conventions. |
| Aggregation and derived values | Definition of daily/weekly windows, timezone/calendar boundary, aggregation statistic, required sample/QA criteria, treatment of partial windows, and lineage from every aggregate back to contributing source observations. Clearly flag predictions, imputations, and derived values. |
| Record identity | Stable dataset ID and stable source observation ID, such as a documented source granule plus pixel/coordinate/time key. Explain identity uniqueness and any changes introduced by aggregation. |

### Satellite handoff acceptance criteria

- A recipient can identify the exact product/version and source granules without relying on filename inference, and can distinguish source-verified metadata from the ML2 notebook's documented workflow.
- Product references support the band, native units, scale/offset, resolution, CRS, and QA interpretation used.
- Each delivered observation has coordinates, acquisition time at its available precision, a QA disposition, and a traceable source identity—or the specific missing field is marked **UNKNOWN** with an explanation.
- Raw/source measurements are distinguishable from scaled, filtered, aggregated, imputed, or predicted values.
- Processing artifacts and parameters reproduce the delivered derived dataset, or unavailable steps are explicitly listed.

## 2. Existing ML dataset

The project report **DOCUMENTS** an initial dataset of roughly 116 spatial points and 150 observation dates and later describes weekly aggregation and cloud-gap imputation. These are documentary statements only. Do **not** treat the counts as verified characteristics of the current Supabase tables or assume that the current ML target is the same at each workflow stage. The report describes an initial absolute-LST-in-Celsius objective and a later relative-LST-anomaly model; the team must identify the target and dataset version intended for this handoff.

### Required ML team package

1. **Original dataset files:** the exact source inputs used in the relevant ML run, plus the exact final model-ready dataset. Include file formats, row counts, date range, coordinate count, and a checksum/inventory. Keep raw and derived versions separate.
2. **Historical candidate dataset:** if still available, the dataset described as approximately 116 spatial points and 150 observation dates. State whether the supplied file is that exact version, a partial copy, a reconstruction, or unavailable. Include actual measured counts rather than assuming the report's counts apply.
3. **Data dictionary:** every column's definition, type, unit, source, allowed/missing values, derivation, temporal meaning, and whether it is measured, converted, aggregated, imputed, predicted, or a model feature/target. Explain target changes, including absolute LST versus anomaly.
4. **Preprocessing artifacts:** notebooks/scripts, configuration, dependency/environment versions, random seeds where used, run logs, and ordered steps from source files to final training rows.
5. **Missing and cloud-gap handling:** source of missingness, fill values, QA/cloud masks, row/pixel exclusions, imputation method, group/window used to compute imputations, fit scope, and indicators distinguishing original observations from imputed values. State whether any imputation statistics were computed using held-out data.
6. **Weekly aggregation procedure:** aggregation key, week definition and timezone, statistic, inclusion/QA rules, minimum observations per week, partial-week handling, and source row IDs contributing to each weekly output.
7. **Train/test methodology:** exact split strategy, indices or stable row/group IDs per split, chronological/spatial blocking details, fold definitions, leakage controls, preprocessing fit boundaries, and which outputs are from validation versus final evaluation. Do not substitute a general description for the actual split assignments when those assignments are available.
8. **Source-to-row lineage:** for every final row, preserve source dataset ID and source observation ID(s), product/version/band, acquisition time, spatial key, and transformation/aggregation run ID. For aggregates, provide an explicit mapping table or an equivalent reproducible lineage mechanism.
9. **Version/target reconciliation:** identify the dataset version and target variable intended for calibration readiness. Explain differences between the documented initial dataset and later model dataset; provide the relevant report/run references.

### ML handoff acceptance criteria

- Recipient can load both source and final datasets and reconcile their row counts to a manifest.
- Every column and target has a data-dictionary entry and unit/derivation statement.
- A reproducible run produces the same processing stages and split assignments, or discrepancies are documented.
- Cloud filtering, missing-value handling, and imputation are explicit; imputed values cannot be mistaken for independent observations.
- Final rows can be traced to source observations, including many-to-one lineage for aggregates.
- The claimed 116-point/150-date counts are reported as measured counts for the supplied file, not assumed from documentation.

## 3. Independent reference dataset

Calibration requires an independent observation of a comparable measurand. Prefer synchronized, ground-based surface radiometry for direct surface-temperature reference, with documented footprint and measurement protocol.

**Land Surface Temperature (LST)** is the temperature of the observed surface/radiating target under a defined measurement method and footprint. **Air temperature** is the temperature of the atmosphere measured by an air-temperature sensor at its exposure/height and is a different measurand. BMKG or ERA5 air-temperature observations, if supplied, may be useful contextual covariates or separate validation targets, but must not be relabeled as direct LST ground truth.

### Required reference fields and supporting evidence

| Field | Request |
|---|---|
| Measurement type and measurand | Explicitly label the record as surface radiometry/LST, satellite LST, air temperature, or another measurement. Define the measurand and provide a stable reference to the measurement definition. Do not use a generic “temperature” label. |
| Sensor and method | Manufacturer/model or dataset/product identity; instrument type; measurement principle; sensor installation/measurement height or viewing geometry; emissivity/target assumptions where applicable; sampling/averaging procedure; and operating protocol. For a satellite reference, provide sensor, product, band, version, and processing documentation. |
| Accuracy and calibration | Calibration certificate, traceability, calibration date/status, stated accuracy/uncertainty, resolution, and known limitations if available. If absent, say **UNKNOWN** and provide any available manufacturer or dataset documentation; do not invent an uncertainty. |
| Timestamp and timezone | Observation start/end or instant, timestamp precision, timezone/UTC offset, clock convention, and synchronization method. Provide ISO-8601 timestamps with offset when available; distinguish observation time from file creation/upload time. |
| Coordinates and footprint | Latitude/longitude or native coordinates, CRS, coordinate uncertainty if known, sensor height/view angle, surface target/footprint dimensions or footprint geometry, and footprint method/version. For an area/pixel reference, provide the polygon/grid and spatial support. |
| Temperature value and original unit | Original unmodified value, original unit, any conversion formula, converted value/unit if applicable, and data type/scale/offset where applicable. |
| Quality flags | Original sensor/dataset QA flags and authoritative definitions; screening/exclusion criteria; weather/obstruction flags if recorded; and treatment of missing or suspect observations. Retain the original flag alongside any interpreted status. |
| Provenance and independence | Source organization/provider, collection method, dataset/version, source record ID, acquisition/export date, file or API documentation, custodial contact/permission as needed, and a written basis for independence from the satellite product and its processing. |
| Collocation protocol | Documented comparison between reference support and satellite support: distance/overlap rule, temporal tolerance, surface/land-cover context, footprint compatibility identifier, and any aggregation method. Coordinate proximity alone does not establish equivalent footprints. |

### Reference handoff acceptance criteria

- Each reference record's measurement type clearly distinguishes surface temperature from air temperature.
- A recipient can identify the sensor/product, source record, timestamp with timezone, coordinates/CRS, footprint, original unit, and QA interpretation—or see each missing item explicitly marked **UNKNOWN**.
- Independence from the satellite data source and processing is justified and documented.
- Any unit conversion and comparison/collocation method are reproducible; the reference is not converted or relabeled merely to force a match.

## 4. Supabase data requirements

Before mapping existing records, the database/project team must establish what exists without treating the checked-in reconstruction as the live schema. **VERIFIED:** the Flutter heatmap reads `id,date,latitude,longitude,lst,ndvi` from `malang_climate_pilot`; the migration declares additional columns including `ndbi` and `created_at`. **UNKNOWN:** whether the remote tables match the migration and what any live values mean. No remote inspection is authorized or performed by this document.

Request a safe, reviewed schema/metadata export and a representative, access-approved data dictionary/sample that excludes credentials and unrelated personal data. Do not change schemas as part of this discovery.

### Verify for both `malang_climate_pilot` and `urban_heat_data`

- Actual table/view identity, schema, column names/types/nullability, primary key, relevant indexes, and whether the object is current/authoritative or legacy.
- Whether live schema matches `supabase/migrations/20261027110000_baseline_public_schema.sql`; identify any later changes and migration-history discrepancy.
- Actual row counts and date/coordinate ranges from an approved snapshot or query result. Record the snapshot date and method. Do not infer the contents from the schema.
- Meaning, units, source, and provenance of `lst`, `LST_Celsius`, `NDVI`, `NDBI`, latitude/longitude, `.geo`, `geom`, `date`, and `created_at`.
- Whether `date` represents acquisition date, aggregation date, or another date; whether a separate acquisition timestamp and timezone exist outside the declared fields.
- CRS/coordinate order and whether `geom` and `.geo` represent the same observations; source and transformation history for coordinates.
- Whether values are measured or derived; product/provider, exact product version, band, original unit, scale/offset, QA, cloud filtering, preprocessing and aggregation/imputation/model version.
- Stable source dataset and source observation identifiers; how table `id` is assigned; whether rows are aggregated or duplicated; and how each row maps to source data.
- Whether the two tables contain overlapping or distinct data and which one the heatmap or ML pipeline is intended to consume.
- Any observation columns not currently selected by the Flutter query, and any transformations made by the application before display.

### Mapping readiness gate

Map records to the calibration pipeline only after the team can populate and evidence the canonical fields:

- `temperature_value`, `latitude`, `longitude`, and `observation_datetime` (timezone-aware for matching).
- `temperature_unit`, `source_product`, `product_version`, `source_band`, and `raw_or_scaled`.
- Scale factor/offset where applicable, plus product-version/band-specific QA flag and an authoritative product specification.
- `source_dataset_id` (or `source_dataset`) and `source_observation_id`; do not use database `id` as source identity without documented proof that it is stable and represents the source observation.
- `measurand`, `measurand_definition_reference`, and a documented shared `footprint_compatibility_id`.
- For reference records: a distinct source product and `reference_independence_basis`.
- Processing version and lineage for all transformations; retain a distinction between observed and imputed/aggregated/predicted values.

`created_at` is an insertion timestamp in the checked-in declaration, not observation time. `date` declared as SQL `date` is date-only; it cannot on its own establish a time-of-day match. If timestamps or other provenance fields are unavailable, mark them **UNKNOWN** and report the resulting mapping limitation. This document does not recommend destructive schema edits or authorize schema changes.

## 5. Team handoff checklists

For each item, mark **Received / Partial / Not available**, provide a filename or secure internal reference, name an owner, and record gaps as **UNKNOWN**. Use approved project storage and access controls; do not email credentials, service-role keys, or unrestricted personal data.

### ML/data team

| Done | Required deliverable | Why it is needed | Acceptance criteria | Blocks calibration? |
|---|---|---|---|---|
| [ ] | Original source inputs and exact final model-ready dataset, with inventory, checksums, and actual row/date/location counts. Include the approximately 116-point/150-date file if still available; state clearly if it is unavailable or not the current dataset. | Establishes which observations and dataset version are being discussed; prevents undocumented counts from being attributed to live tables. | Source and final files are distinct; counts are computed from supplied files; each file/version is identified; discrepancies against the documented counts are explained. | **Yes** for calibration on those data; no dataset means no observations to assess. |
| [ ] | Data dictionary, target definition, and dataset-version reconciliation (absolute LST versus anomaly, observed versus derived/predicted). | Resolves what the label and values mean and which target the team intends to calibrate. | Every field has type, unit, source, temporal meaning, derivation, and missing-value meaning; selected target and version are explicit. | **Yes** if the temperature measurand/target is unknown. |
| [ ] | MODIS/MOD11A1 granules/source references and product metadata (version, band, native unit, scale/offset, QA, acquisition, CRS, resolution). | Establishes satellite source identity and scientific interpretation of each value. | Source metadata supports product/version/band/scale/QA/spatial interpretation; files map to outputs; unknown fields are listed, not guessed. | **Yes** for validating satellite observations as a known product. |
| [ ] | Preprocessing notebooks/scripts/configuration and execution environment, including unit conversion and QA/cloud-screening rules. | Makes conversion, filtering, and derived values reproducible. | Ordered steps and parameters can produce the supplied output, or unavailable steps and their impacts are documented; raw values remain distinguishable. | **Yes** where processing could alter temperature or select records. |
| [ ] | Missing/cloud-gap and imputation report; weekly aggregation specification and contributing-source-row mapping. | Prevents imputed/aggregated values from being mistaken for independent measurements and clarifies temporal support. | Missingness and QA dispositions are quantified; imputed values are flagged; aggregation windows/statistics are defined; aggregate rows map to contributing observations. | **Yes** for matching an affected row as an observation; imputed or untraceable rows must not be treated as independent measurements. |
| [ ] | Actual train/validation/test split assignments and methodology, including spatial/temporal grouping and preprocessing fit boundaries. | Supports reproducibility and leakage review; identifies whether the supplied values are training, validation, or holdout outputs. | Split IDs/groups and rules are available; no held-out data are used to fit preprocessing/imputation; any limitations are stated. | **No** for basic provenance inventory; **Yes** before using model evaluation or calibration-performance claims. |
| [ ] | Source-to-row lineage table and stable dataset/source observation IDs. | Allows duplicate detection and traceability through transformation and aggregation. | Each observation maps to source record(s), product/version/band, acquisition time, and processing run; aggregate lineage is explicit. | **Yes** for calibration pipeline eligibility. |

### Backend team

| Done | Required deliverable | Why it is needed | Acceptance criteria | Blocks calibration? |
|---|---|---|---|---|
| [ ] | Written mapping from each supplied satellite/reference dataset to the calibration pipeline canonical fields; include a sample mapping using approved non-sensitive records. | Shows whether real records meet validation and matching inputs without inferring metadata from column names. | Each field has a documented source and transformation; unavailable fields are explicitly **UNKNOWN**; no database ID or `created_at` is silently substituted for source ID/time. | **Yes** until canonical observation fields and provenance are evidenced. |
| [ ] | Product specification/catalog evidence for each product/version/band: accepted units, scale/offset, QA mapping, and authoritative source references. | The validator requires an explicit, product-specific catalog and does not bundle scientific product rules. | Catalog values are traceable to authoritative product documentation; raw flags and unit/scale mappings are reviewable; unspecified rules remain unknown. | **Yes** for validation eligibility. |
| [ ] | Mapping of `measurand`, definition reference, footprint compatibility method/ID, and reference independence basis. | The readiness pipeline requires documented semantic, footprint, and independence compatibility. | Definitions and references are supplied for both sides; a reviewer can justify shared footprint comparison and source independence. | **Yes** for matching satellite/reference records. |
| [ ] | Readiness-run configuration proposal: spatial/time limits and minimum pair count, plus explanation of scientific/operational basis. | These are required explicit parameters, not defaults to invent. | Units and rationale are recorded; values are approved by the project/science owner; no readiness claim is made from unapproved thresholds. | **Yes** for running a readiness assessment; does not block collecting provenance. |
| [ ] | Exclusion/missing-metadata report plan and evidence that output will distinguish VALID/WARNING/INVALID/UNKNOWN and unmatched reasons. | Makes gaps visible and avoids presenting an eligibility gate as accuracy or calibration. | Reports preserve row-level identities/reasons and summarize missing metadata; no input is silently altered or dropped. | **No** for acquisition; required before readiness results are accepted. |

### Database team

| Done | Required deliverable | Why it is needed | Acceptance criteria | Blocks calibration? |
|---|---|---|---|---|
| [ ] | Reviewed current schema metadata for `malang_climate_pilot` and `urban_heat_data`, including migration-history comparison and snapshot date. | The checked-in migration is only a reconstruction and is not verified against the remote schema. | Actual object/column/type/key metadata is provided through approved read-only means; divergences from the migration are enumerated. | **Yes** for reliable mapping from the live tables; no remote connection is requested from the audit recipient. |
| [ ] | Approved, minimal data profile/sample or export, including row counts/ranges and representative records with sensitive/unrelated fields excluded. | Establishes what data actually exist and whether observations can be mapped, without assuming schema equals content. | Snapshot source/date and filtering are documented; temperature, dates, coordinates, nulls, and relevant metadata are represented; access follows policy. | **Yes** to assess actual table records; not needed to request source artifacts from ML team. |
| [ ] | Data dictionary and owner confirmation for table purpose, each temperature/index/geometry/date field, units, CRS, source, and processing lineage. | Names such as `LST_Celsius` do not independently verify measurand, units, or conversion history. | Definitions are backed by source/processing evidence or explicitly marked **UNKNOWN**; `created_at` is distinguished from acquisition time. | **Yes** for interpreting table values. |
| [ ] | Identity and time provenance explanation: semantics of database `id`, source dataset/observation IDs, acquisition timestamp/timezone, and relationship to `date`. | Pipeline requires stable source identities and timezone-aware observation times for matching. | Stable source IDs and acquisition times are mapped or declared unavailable; insertion timestamps are not used as substitutes. | **Yes** for source identity and temporal matching. |
| [ ] | Relationship statement for both tables, including overlaps, source, transformations, and intended authoritative source. | Prevents silently combining duplicate or incompatible rows from separate tables. | Owners identify whether data overlap and state which table/version should be considered; evidence or uncertainty is recorded. | **Yes** if candidate sources cannot be distinguished. |

### Project coordinator

| Done | Required deliverable | Why it is needed | Acceptance criteria | Blocks calibration? |
|---|---|---|---|---|
| [ ] | Named owners, secure handoff location, due dates, and a received/partial/unavailable tracker for every request in this document. | Coordinates the cross-team evidence package and makes gaps actionable. | Every item has an owner/status/reference; missing items are recorded as **UNKNOWN**, with a follow-up owner/date. | **No** for collecting data; unresolved blocking items prevent a go decision. |
| [ ] | Decision on intended target and dataset stage: initial absolute LST or later relative LST anomaly, and the intended temporal/spatial support. | Project documentation describes multiple workflow targets/stages. | ML/data owner and project lead document one intended target/version and rationale; alternatives remain clearly separated. | **Yes** if the target/measurand is ambiguous. |
| [ ] | Confirmation of reference strategy: ground-based surface radiometry, an explicitly justified independent satellite comparison, or no reference currently available. | A calibration readiness assessment needs an independent compatible reference; air temperature is not direct LST ground truth. | Reference type, owner, measurement definition, independence basis, and availability are recorded; air temperature is not mislabeled as surface LST. | **Yes** to matched-pair calibration readiness if no eligible reference exists. |
| [ ] | Approval of comparison protocol and thresholds by the responsible scientific/project owner. | Distance/time limits, footprint compatibility, and minimum sample size affect which pairs count. | Protocol states measurand, units, footprint, temporal/spatial limits, and minimum pairs with rationale and approver. | **Yes** for a readiness determination. |
| [ ] | Evidence review/sign-off that separates VERIFIED, DOCUMENTED, and UNKNOWN claims. | Prevents report language, schema names, or prototype labels from becoming unsupported dataset provenance. | Claims link to source files, authoritative metadata, or responsible owner; unresolved claims remain **UNKNOWN**; no calibration/model claim is made from documentation alone. | **Yes** for final calibration-readiness sign-off. |

## 6. Handoff response template

Copy this block for each deliverable:

```text
Team / owner:
Checklist item:
Status: Received / Partial / Not available
Deliverable filename or approved internal reference:
Dataset/version and date range:
Evidence status: VERIFIED / DOCUMENTED / UNKNOWN
Acceptance criteria met:
Known gaps or limitations:
Follow-up owner and date:
Blocks calibration: Yes / No (reason):
```

## 7. Calibration gate

Do not declare calibration-ready solely because rows exist, a field is named `lst`/`LST_Celsius`, values appear plausible, or the project report describes a dataset. Before readiness assessment, the team must be able to establish:

1. Which actual satellite observations and product specification produced the candidate values.
2. The observation time, coordinates/footprint, unit, scale/conversion history, QA disposition, and stable source identity for each candidate record.
3. Which values are raw measurements versus scaled, filtered, aggregated, imputed, or predicted outputs.
4. A genuinely independent reference measuring the same defined surface-temperature measurand, with compatible time and spatial support.
5. Traceable mapping of both datasets to the pipeline contract and approved matching thresholds.

If a required item is absent, mark it **UNKNOWN**, preserve the affected records for evidence review, and report the limitation. This checklist does not authorize modifying Supabase schemas or applying calibration.
