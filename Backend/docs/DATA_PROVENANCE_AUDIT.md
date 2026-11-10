# UrbanHeat AI Data Provenance Audit

**Scope:** Repository evidence available on `feat/temperature-calibration` at audit time.
**Mode:** Read-only inspection; no Supabase connection, remote data access, application changes, calibration, or model fitting.

## 1. Executive summary

**Conclusion — the repository does not establish that the actual UrbanHeat AI observations can enter the calibration-readiness pipeline.** The original provenance inventory found no source MODIS granules, independent reference records, or lineage-complete source exports. A subsequent review of the ML1/ML2 folders found candidate CSV datasets and notebooks, but these do not establish original source-file lineage, independent references, or compatibility with live Supabase rows. The project PDF **DOCUMENTS** MOD11A1/MODIS data; the ML2 notebook additionally documents a Terra/Aqua extraction workflow. Neither proves which source observations produced the local candidate tables.

The checked-in Supabase baseline describes `malang_climate_pilot` and `urban_heat_data`, but it is a schema reconstruction, explicitly not reconciled with remote migration history. No row data was inspected. The Flutter heatmap reads only `id,date,latitude,longitude,lst,ndvi` from `malang_climate_pilot`; this does not provide the source/product/version/band/unit/scale/QA and stable source-observation identity required by the validation and calibration-readiness contracts. Its `date` is date-only, while matching requires an observation timestamp with a timezone. The app does not read `urban_heat_data`; the Python backend contains no query or mapping for either table.

No independent surface-temperature reference observations were found. The current evidence therefore supports **neither a verified source dataset nor an eligible satellite/reference pair**. This is a repository-evidence assessment, not a result from running the readiness pipeline against live data.

## 2. Evidence labels

- **VERIFIED** — directly visible in checked-in code, a local file, or the SQL definition reviewed here. For schema fields, this verifies the migration's declaration, not the live remote schema or contents.
- **DOCUMENTED** — stated in project documentation, but not independently verified against original data or source/provider metadata.
- **INFERRED** — a limited conclusion from visible code/schema behavior; it is not asserted as scientific provenance.
- **UNKNOWN** — no adequate evidence was found. In particular, names and UI labels are not treated as proof of provider, units, product, or lineage.

## 3. Dataset inventory

| Candidate | What is present | Evidence status and classification |
|---|---|---|
| ML1 candidate data and workflow | Local ML1 CSVs, notebooks, results, predictions, and model artifact files are present and reviewed in `ML_MODEL_SELECTION_AUDIT.md`. | **VERIFIED** as local experiment artifacts and contents/inventory as described in that audit. They are not verified original source downloads, and their source-to-row lineage is **UNKNOWN**. Do not equate them with Supabase records. |
| ML2 candidate data and workflow | Local ML2 CSVs, notebooks, result/metadata files, and model artifact files are present and reviewed in `ML_MODEL_SELECTION_AUDIT.md`. | **VERIFIED** as local experiment artifacts and contents/inventory as described in that audit. The notebook documents a MODIS Terra/Aqua extraction and processing workflow, but original granules/export manifests and exact final-row lineage are absent; actual row provenance is **UNKNOWN**. Do not equate them with Supabase records. |
| Reported MODIS/MOD11A1 dataset | No original MODIS granules, source exports, metadata sidecars, or manifests were found. | **DOCUMENTED** in `Document/UTS_PBL_Group4_Machine-Learning.pdf` (page 2): the initial dataset is described as raw MOD11A1 MODIS observations over Malang, with daily records at 116 spatial points and approximately 150 observation dates. This is a report statement, not a verified source artifact. |
| Later LST modeling description | Documentary description in the project PDF; local ML workflows are separately inventoried above. | **DOCUMENTED** in the same PDF (pages 4 and 7): it describes 116 locations and data from October 2025 to October 2026, a relative-LST-anomaly model, weekly aggregation, location-wise mean imputation for cloud-covered missing pixels, and cyclical temporal features. The report's initial absolute-LST-in-Celsius objective (page 2) and later relative-anomaly target are different target descriptions; the underlying dataset/version relationship is **UNKNOWN**. |
| `malang_climate_pilot` | Declared in `supabase/migrations/20261027110000_baseline_public_schema.sql`; no table export or rows are checked in. | **VERIFIED** as a table declaration in that migration. **UNKNOWN** whether this definition matches the live project and what any live rows represent. |
| `urban_heat_data` | Declared in the same migration; no table export or rows are checked in. | **VERIFIED** as a table declaration in that migration. **UNKNOWN** whether this definition matches the live project and what any live rows represent. |
| Flutter heatmap observations | A Supabase query and parser are present; no observation rows are stored locally. | **VERIFIED** that the app queries `malang_climate_pilot` and parses the six selected fields listed in section 5. The query behavior does not verify the rows' provenance. |
| Flutter mock/demo values | Hard-coded UI values and an in-memory mock repository are present in `Frontend/lib/features/urban_heat/data/mock_urban_heat_data.dart` and `.../mock_urban_heat_repository.dart`. | **VERIFIED** as prototype constants, not source observations. Values and labels in these files are not calibration data. |
| Unit-test observations | Tests define `TEST_LST`, `SAT_LST`, and `GROUND_LST` product catalogs and hand-authored example records. | **VERIFIED** as test fixtures in `Backend/tests/test_temperature_validation.py` and `Backend/tests/test_calibration_pipeline.py`; they demonstrate code behavior, not actual sensor products or reference measurements. |
| Other local scientific/geospatial data | The ML1/ML2 CSVs and notebooks are the local experiment artifacts noted above. No original satellite granules, GeoTIFF/NetCDF/HDF source products, independent reference observations, or source manifests were identified in the inspected artifacts. | **VERIFIED** for the inspected workspace inventory. JSON files include application/configuration files and ML2 metadata/results; the latter describe experiment outputs, not original satellite source metadata. |

## 4. Verified and documented provenance

### MODIS/MOD11A1 claim

The project PDF documents MOD11A1. Separately, the ML2 notebook documents a MODIS extraction workflow. These are evidence of what the documents/code say, not verification that the local CSV rows came from the stated products.

| Provenance field | Evidence |
|---|---|
| Source/provider | **UNKNOWN.** The PDF names MODIS/MOD11A1 and the ML2 notebook uses Earth Engine collection names, but no source URL/account record, original granule, download/export manifest, or source archive was found to verify data lineage. |
| Product | **DOCUMENTED:** the PDF names MOD11A1. The ML2 notebook documents Terra MOD11A1 and Aqua MYD11A1. No source product metadata or granule was present to verify that these products generated the local rows. |
| Product version/collection | **DOCUMENTED in the ML2 notebook:** collection/version `v061` for the named Terra/Aqua products. **UNKNOWN** for the PDF-described data and for the lineage of any local ML1/ML2 row. |
| Band/subdataset | **DOCUMENTED in the ML2 notebook:** `LST_Day_1km`. **UNKNOWN** whether this band produced the local CSV values; no source export metadata confirms it. |
| Acquisition | **DOCUMENTED:** daily observations and approximately 150 observation dates are claimed on PDF page 2; the ML2 notebook describes daily Terra/Aqua observations. **UNKNOWN:** actual row-level acquisition timestamps, overpass/time convention, exact source granules, and correspondence between notebook dates and local CSV rows. |
| Spatial resolution | **DOCUMENTED in the ML2 notebook:** 1 km extraction. **UNKNOWN** for the PDF-described data and whether the local rows preserve the source grid/footprint or were resampled. |
| Measurand and unit | **DOCUMENTED:** the PDF describes an absolute-LST-in-Celsius objective and later a relative-LST-anomaly target. The ML2 notebook documents LST conversion to Celsius. **UNKNOWN:** source-file measurand and unit for each local row, and whether its recorded value was processed exactly as described. |
| Scale factor/offset | **DOCUMENTED in the ML2 notebook:** raw LST multiplied by `0.02` Kelvin and then converted by subtracting `273.15` to Celsius. **UNKNOWN** whether these steps produced the delivered CSV values; no source values/export lineage verifies application. |
| QA/cloud handling | **DOCUMENTED:** the PDF describes cloud-related gaps, screening, and location-wise mean imputation. The ML2 notebook documents `QC_Day` bit screening. **UNKNOWN:** whether the notebook's exact QA code and interpretation are authoritative and whether its output rows correspond to those rules; the PDF does not identify a QA mask. |
| CRS | **UNKNOWN.** Longitude/latitude features are mentioned, but no coordinate reference system or transformation history is given. |
| Processing and lineage | **DOCUMENTED:** the PDF describes weekly aggregation, imputation, cyclical date encoding, and modeling; the ML2 notebook contains an extraction/preprocessing workflow. **UNKNOWN:** complete reproducible source-to-row lineage, export manifests, aggregation relationship to the PDF workflow, and which run produced any stored or Supabase rows. |
| Data state | **DOCUMENTED:** the report calls the initial input “raw” observations and describes subsequent derived features/modeling. **UNKNOWN:** whether any current Supabase records are raw, scaled, screened, aggregated, imputed, or predicted. |

These are documentary claims only; they do not prove that the local app's `lst` or `LST_Celsius` values came from MOD11A1.

### Supabase schema declarations

The migration header calls itself a “Baseline reconstruction of the existing public schema” based on a “read-only production metadata audit,” and warns that it has **not** been reconciled with remote migration history and recreates schema objects, not production data. Accordingly, the following are **VERIFIED** declarations in the checked-in file only:

- `malang_climate_pilot`: `id`, `date date`, `latitude`, `longitude`, `lst`, `ndvi`, `ndbi`, and `created_at timestamptz DEFAULT CURRENT_TIMESTAMP`. It declares indexes on `date` and latitude/longitude.
- `urban_heat_data`: `id`, `NDVI`, `NDBI`, `LST_Celsius`, `.geo text`, `geom geometry(Point, 4326)`, and `created_at timestamptz DEFAULT timezone('utc', now())`. The `geom` column's declared CRS/SRID is 4326; this does not verify the values or any `.geo` text convention.
- Neither definition declares source dataset/product/version/band, acquisition time, temperature unit metadata, scale parameters, QA flags, processing version, or a reference-observation identity.
- `created_at` is a database insertion/default timestamp in these declarations; it is not evidence of acquisition time.

The column name `LST_Celsius` and frontend display of `lst` as `°C` are **not** treated as verification of source units or conversion history.

## 5. Supabase schema compatibility

### Existing reads

- **VERIFIED:** `Frontend/lib/features/urban_heat/data/repositories/supabase_heatmap_repository.dart` selects `id,date,latitude,longitude,lst,ndvi` from `malang_climate_pilot`, ordering by `date` and `id`.
- **VERIFIED:** `HeatmapObservation.tryParse` reads those values. It requires `id`, date, coordinates, and `lst`; it accepts optional `ndvi`, checks finite coordinates/value, and reduces the parsed date to UTC midnight. It does not read `created_at`, `ndbi`, or any provenance fields.
- **VERIFIED:** `Backend/db/database.py` creates a Supabase client from environment variables but contains no table query, row loader, or mapping into the calibration pipeline.
- **VERIFIED:** no repository code query to `urban_heat_data` was found.
- The UI describes the heatmap as historical satellite-derived observations and displays LST as Celsius. Those are **INFERRED** UI assertions, not source lineage or unit evidence.

### Calibration contract fit

`Backend/temperature_validation.py` expects canonical observation values, coordinates, an observation date/datetime, unit, product, product version, band, raw/scaled declaration, and product-specific scale/QA metadata when applicable. `Backend/calibration_pipeline.py` additionally requires stable `source_dataset_id` (or `source_dataset`) and `source_observation_id`, a documented `measurand` and definition reference, a shared footprint-compatibility identifier, and (for references) an independence basis. Matching requires timezone-aware observation datetimes, compatible measurements/units/footprints, and caller-supplied spatial, temporal, and minimum-pair thresholds.

The table declaration and selected Flutter fields do not provide this contract. A database `id` is not a verified source observation ID, and the pipeline explicitly does not infer a duplicate/source identity from a database row ID. `malang_climate_pilot.date` is declared as `date`, not a timestamp, and the frontend discards any time component; a date-only value cannot satisfy the pipeline's timestamp matching rule. `created_at` is neither selected by the Flutter query nor accepted as a substitute observation time by the pipeline.

**Assessment:** direct mapping of the currently read `malang_climate_pilot` columns cannot establish provenance or produce eligible calibration pairs. Mapping column names alone would not resolve the missing source identity, product specification, unit/scale/QA, observation time, measurand documentation, or footprint compatibility. `urban_heat_data` has no consumer and is missing source/time provenance in its declared schema as well. No real rows were fetched or submitted to the pipeline.

## 6. Reference dataset availability

No independent surface-temperature reference file, sensor log, station export, or cross-sensor observation set was identified in the repository. No inspected project document named BMKG or ERA5 as an available reference source.

| Reference category | Finding |
|---|---|
| Ground-based surface radiometry (direct LST reference) | **UNKNOWN / not found in repository.** No radiometer observations, instrument metadata, calibration/traceability records, footprint details, or synchronized field measurements were present. |
| Air temperature (for example BMKG or ERA5) | **Not found as data or a documented source in the inspected repository.** In any event, air temperature is not direct LST ground truth and cannot be relabeled as such for this audit. |
| Satellite-derived LST | MOD11A1 is **DOCUMENTED** in the PDF, and the ML2 notebook documents MOD11A1/MYD11A1 as candidate inputs. Original granules and source product metadata/export manifests were not found to verify the local rows. Satellite-derived LST is not a ground-based surface-radiometry reference. |
| Cross-sensor satellite comparison | **UNKNOWN / not evidenced.** No second-sensor observations, product metadata, temporal/spatial collocation records, or independent comparison results were found. The `Sentinel-2` label in an area-detail UI is not evidence of such a dataset or a verified temperature product. |

The calibration test's `GROUND_LST` records are hand-authored fixtures, not a real independent reference dataset.

## 7. Calibration-readiness assessment

**Current outcome: NOT DEMONSTRATED; the available repository data cannot be certified as calibration-ready.**

This conclusion follows from evidence availability and contract mismatch—not from a model run:

1. No provenance-verified source observations or live Supabase records were available for validation. Local ML1/ML2 candidate tables exist, but their row-level source lineage and relationship to Supabase are **UNKNOWN**.
2. No original source files, export manifests, or row-level lineage connect the documented MODIS products to local candidate rows or any live records.
3. The known Flutter query omits most validator fields and all stable source identifiers; the table's date is date-only.
4. No verified unit/scale catalog, product version/band mapping, or QA interpretation is supplied for actual data.
5. No independent direct LST reference observations or shared footprint protocol are available.
6. The test suite's product catalogs and records are examples, not evidence about the project datasets.

The existing readiness code provides an eligibility gate and does not fit a calibration model. No readiness assessment was run against real data, and no scientific accuracy or calibration claim can be made from these findings.

## 8. Recommended next actions

1. **Obtain source artifacts and lineage:** original MODIS files/exports, authoritative download/source URL, collection/product version, granule IDs, extraction date, AOI, and stable source pixel/observation identifiers. Preserve original metadata and QA layers.
2. **Obtain authoritative product interpretation:** product guide references for band/subdataset, native units, scale/offset, QA/cloud flags and their interpretation, spatial resolution, CRS, and acquisition-time convention. Record which specification applies to each stored row.
3. **Obtain the reproducible processing history:** scripts/notebooks, parameters, software versions, filtering and cloud-screening logic, weekly aggregation definition, imputation policy, unit conversion, and processing version. Keep imputed/predicted values distinguishable from measured observations and make source-to-output lineage traceable.
4. **Establish actual Supabase state without sharing secrets:** project team should provide a reviewed schema/export or safe read-only evidence for the two tables, including representative row metadata and row counts. Reconcile this with the baseline migration and identify the intended authoritative table. Do not send credentials or use service-role secrets in this audit.
5. **Obtain a genuine independent LST reference:** preferably time-synchronized, ground-based surface radiometry with instrument identity, calibration/uncertainty, measurement protocol, footprint, coordinates, timestamp/time zone, and source observation IDs. If a satellite cross-sensor reference is proposed, document its independent product lineage and compatibility; do not treat air temperature as direct LST.
6. **Define comparison semantics:** authoritative measurand definitions, unit handling, spatial footprint compatibility, temporal/spatial tolerances, and justified minimum matched-pair count. Provide product catalogs and QA mappings tied to authoritative documentation.
7. **Only then** map source records to the canonical pipeline contract, validate metadata and exclusions, and review the resulting pair set before considering any calibration model.

## 9. Limitations and unresolved questions

- No connection was made to Supabase, and no credentials, remote schema, policies, or row values were inspected. Live table contents, actual permissions, and current production schema remain **UNKNOWN**.
- The baseline migration itself warns that it is not reconciled to remote migration history. Its declared schemas are not proof of production state.
- Original MODIS source/provider artifacts, source manifests, and record-level lineage remain unresolved. The ML2 notebook documents product/processing details, but those details have not been verified against source exports or linked to local rows.
- It is unresolved whether `malang_climate_pilot` and `urban_heat_data` contain the same observations, different products, processed outputs, or predictions.
- It is unresolved what `lst` and `LST_Celsius` represent in actual rows, which units/scales were applied, and whether missing/cloudy values were filtered, imputed, aggregated, or predicted.
- It is unresolved whether any real surface-radiometry reference observations exist outside the repository and whether their measurements can be footprint/time matched to the satellite data.
- The UTS report's absolute-LST objective and later relative-anomaly description indicate potentially different workflow stages/targets; the team must identify which dataset and target are intended for calibration.
- This audit establishes repository evidence only. It does not validate scientific product specifications against external provider documentation, inspect live records, execute a data export, or measure model performance.

## Exact files and resources inspected

### Repository files reviewed

- `README.md`
- `Backend/README.md`
- `Backend/calibration_pipeline.py`
- `Backend/temperature_validation.py`
- `Backend/db/database.py`
- `Backend/tests/test_calibration_pipeline.py`
- `Backend/tests/test_temperature_validation.py`
- `Backend/.env.example` (placeholder names only)
- `Frontend/README.md`
- `Frontend/.env.example` (placeholder configuration only)
- `Frontend/lib/features/urban_heat/data/repositories/supabase_heatmap_repository.dart`
- `Frontend/lib/features/urban_heat/data/models/heatmap_observation.dart`
- `Frontend/lib/features/urban_heat/data/mock_urban_heat_data.dart`
- `Frontend/lib/features/urban_heat/data/repositories/mock_urban_heat_repository.dart`
- `Frontend/lib/features/urban_heat/presentation/pages/heatmap_page.dart`
- `Frontend/lib/features/urban_heat/presentation/pages/area_detail_page.dart`
- `Frontend/lib/app/router.dart`
- `supabase/migrations/20261027110000_baseline_public_schema.sql`
- `supabase/config.toml`
- `Document/README.md`

### Project PDFs text-searched/reviewed

- `Document/01_QA_Audit_and_Inspection_Report_QA.pdf`
- `Document/02_Audit_Defense_and_CAP_QA.pdf`
- `Document/Proposal PBL.pdf`
- `Document/UTS_PBL_Group4_Machine-Learning.pdf` (dataset/model statements on pages 2, 4, and 6–8)

The initial workspace inventory was searched for data/scientific file extensions and MODIS/product, reference-source, download, preprocessing, and Supabase table/query terms. The subsequent ML1/ML2 artifact review is documented separately in `ML_MODEL_SELECTION_AUDIT.md`; it found candidate CSVs and notebooks, not verified original source granules, independent references, or a confirmed connection to Supabase. Accordingly, the original inventory statements above are scoped to source-provenance evidence, not a claim that no local experiment datasets exist.
