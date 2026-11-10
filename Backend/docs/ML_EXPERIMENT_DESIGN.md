# UrbanHeat AI Leakage-Safe Model Experiment Design

**Status:** Proposed protocol; documentation only. The backend inference and Flutter output behavior described here are design requirements, not verified implemented functionality.
**Primary task:** Predict absolute Land Surface Temperature (LST) in °C.
**Secondary output:** Derive an anomaly from predicted LST and a versioned, training-only baseline.
**Evidence note:** This is a design, not an experiment result. No model is trained and no performance is claimed.

## 1. Dataset contract

Do not begin model comparison until one versioned observation table and its source manifest have been approved. The ML1/ML2 audit found dataset/run discrepancies and unresolved source lineage; do not assume files with similar names or the documented point/date counts refer to the same experiment.

### One row per observation support

The analysis table represents one eligible satellite LST observation for a declared target support. Define the support before modeling: source product/pass, spatial pixel or footprint, acquisition period/time convention, and whether multiple satellite observations are kept separate or explicitly combined. Each input record must be traceable to a source observation or an explicitly documented aggregate.

| Field | Requirement |
|---|---|
| `dataset_id`, `dataset_version`, `processing_run_id` | Stable identity for the input snapshot and processing run. Include a file manifest/checksum. |
| `source_observation_id` | Stable source-granule/pixel/acquisition identity; for aggregated observations, use a stable derived ID plus a complete contributing-source map. Do not substitute a database row ID without proof. |
| `observation_datetime` and temporal support | Acquisition/observation time with timezone or documented time interval/precision; distinguish from upload and database creation times. Decide and document the prediction origin and target time. |
| `latitude`, `longitude`, `crs`, `spatial_support_id` | Valid coordinates and CRS plus pixel/footprint or spatial-unit identity. Retain the footprint geometry/resolution or an authoritative reference sufficient for the task. |
| `temperature_value_raw`, `temperature_unit_raw` | Original stored observation and unit before any conversion, with fill/no-data representation and validity range. |
| `observed_lst_celsius` | Primary label after documented, version-specific scale/offset/unit conversion. Preserve the conversion formula and the raw source field. Mark whether it is measured satellite LST, aggregated, imputed, or otherwise derived. |
| `source_product`, `product_version`, `source_band`, `source_granule_id` | Product identity and authoritative metadata references. Filenames/column names alone do not establish provenance. |
| `quality_flag_raw`, `quality_interpretation`, eligibility | Retain original QA values, versioned documented interpretation, and predeclared inclusion/exclusion status. Unknown QA must not silently become good quality. |
| `feature values and source metadata` | Each feature must have a definition, units, source/version, spatial support, source time window, `available_at`/publication time, transformation, and missingness meaning. |
| `observation_state` | Explicitly distinguish directly observed/QA-eligible, aggregated, imputed, predicted, and excluded. Model targets in the primary evaluation must be observed, eligible satellite LST—not imputed or predicted labels. |

Freeze an immutable dataset snapshot before splitting. Record a manifest with row counts, source-file checksums, date/location coverage, exclusions, and all processing versions. Keep rejected/unknown rows with reasons in an audit table rather than silently deleting them. Predeclare scientific QA eligibility from product documentation; do not derive it from model residuals or test-set scores.

## 2. Target definitions

### Primary: absolute LST

`y_abs = observed_lst_celsius`

This is the QA-eligible observed satellite surface-temperature value in °C for the declared product/pass, acquisition support, and footprint. It is not air temperature, an anomaly, a prediction, or an imputed value. If Terra and Aqua are combined, define that as a separate target support and preserve the original pass-specific observations and acquisition-time distinction.

The prediction contract is:

`predicted_lst_celsius = f(features available at prediction origin)`

Every evaluation label must be an eligible observed LST measurement that was not used to fit that fold's model or preprocessing.

### Secondary: training-reference anomaly

For a versioned baseline function `B(training_data, location, time_support)`:

`observed_anomaly_celsius = observed_lst_celsius - B(training_data, location, time_support)`
`predicted_anomaly_celsius = predicted_lst_celsius - B(training_data, location, time_support)`

The same fold-specific, training-only baseline is used for both observed and predicted anomaly. A held-out target value must never be used to calculate, select, or update its baseline.

An anomaly is a relative quantity; it cannot replace the absolute LST prediction. Do not use the ML2 same-date/same-satellite city median target for future-time inference unless that task explicitly receives the complete same-date observed city dataset. If the product instead wants city-relative ranking, specify and label that as a different, potentially transductive output—not as a temporal climatological anomaly or health-risk category.

## 3. Feature availability rules

For each prediction row with prediction origin `t0`, a feature is eligible only when its input data and derived value would have been available by `t0`, and its spatial/temporal support is compatible with the target.

### Candidate feature families

- **Location:** latitude/longitude, projected coordinates, or a spatially meaningful site descriptor. Coordinates can be used for known-area interpolation but may encode location identity; assess them under held-out spatial blocks.
- **Season/time:** cyclic day-of-year terms (`sin`, `cos`) or a prespecified seasonal window computed from the observation calendar. Avoid raw point IDs and arbitrary integer encodings when they create an unintended lookup or discontinuity.
- **Environmental covariates:** NDVI, NDBI/built-up, land cover, elevation, rainfall, and other justified predictors only with documented source, units, scale, spatial support, coverage, and time window. A full-study-period median composite is not available for a historical prediction before the composite end date.
- **Product/pass:** if pass is required, define a stratified task or include a product/pass indicator only when it is available at inference and the output target remains well-defined. Do not average incompatible pass observations without declaring the new support.

### Prohibited or conditional features

- Never include the target, target conversions, target-derived city medians/anomalies, target residuals, QA decisions created from model errors, or future observations as predictors.
- Exclude `source_observation_id`, database `id`, point IDs used as lookup keys, `observation_count`, `satellites` when derived from target availability, predictions, and post-target review labels from the predictor set unless a distinct, justified inference-time use is approved.
- Exclude any feature whose source/composite window extends beyond the prediction origin in a temporal prediction evaluation. Do not infer compositing windows from repeated values.
- Do not use precipitation from the target day if the product is supposed to forecast before the rainfall is observed; define a lagged window and its publication latency.
- Static labels derived using future imagery or full-study-period summaries are ineligible for a historical temporal backtest unless recomputed using only imagery available by each prediction origin.
- Scaling, feature selection, imputation, category encoding, winsorization, learned outlier thresholds, climatology and other data-dependent transforms are fitted within the training partition only.

The feature manifest should include, per field, definition, type, unit, source and version, footprint, observation/composite start/end, publication/availability time, transformation, and allowed missing-value policy.

## 4. Validation protocols

Run spatial and temporal protocols as separate deployment questions. Report their results separately; neither substitutes for the other. Fix splits before fitting or model selection and publish the fold assignment file, split code/version, random seed where applicable, and dataset checksum.

### A. Spatial generalization (new locations)

1. Construct spatial groups from coordinates using a declared projection/CRS and block geometry/size appropriate to the target footprint and spatial autocorrelation scale. Do not assume 0.03 degrees is a distance-independent or statistically independent block.
2. Keep every date and all observations for a held-out location/spatial block in the same outer test fold. All observations from that block remain outside training and all data-dependent fitting for that fold.
3. Use contiguous held-out regions with a documented buffer/guard band between train and test where sample size permits. Exclude buffer observations from training for that fold; report the number of groups/locations, excluded buffer area/rows, and coverage.
4. If model/feature/hyperparameter selection is needed, use inner spatial GroupKFold within the outer training blocks. Never tune against outer-fold scores.
5. To avoid a target baseline requiring held-out locations, use a training-derived regional/seasonal baseline for spatial folds. Do not use the held-out location's full time series to construct its baseline.
6. Report pooled outer-fold predictions and fold-level results. Do not compute a single randomly split score as a proxy for geographic transfer.

This protocol answers: “How well does the model transfer to unseen areas within the represented study domain and period?”

### B. Chronological temporal generalization (future dates at known locations)

1. Order by actual acquisition/target support time; define a prediction origin, forecast horizon, and consecutive future test window(s). Keep all observations sharing the same target date/interval or overlapping source composite window on one side of each cutoff.
2. Use forward-chaining outer folds: each training window contains only observations before its cutoff; each test window is later. Do not shuffle dates. Reserve the latest predeclared block of time as a final untouched holdout if data coverage permits.
3. Apply an embargo around split boundaries at least as wide as any overlapping target support or feature composite window. If exact feature dates are missing, the feature cannot support a defensible temporal backtest until its availability is established.
4. Require the exact held-out feature values to be available at the historical prediction origin. Rebuild period-dependent composites and any feature aggregation from data available by that origin; otherwise drop that feature from the temporal experiment.
5. Keep point IDs across train/test only if the stated use case is future prediction at known locations. Add a separate spatially held-out evaluation for new-location transfer.
6. Fit all preprocessing, feature selection, hyperparameter selection, and historical baseline statistics using only the training period for that fold.

This protocol answers: “How well does the model predict a later period at locations whose history may be known?”

### C. Optional joint transfer test

If sufficient data exist, add a locked test containing both later dates and held-out spatial blocks. Use a spatial buffer and temporal embargo, and perform all tuning on the remaining training data. Treat this as a separate, stricter deployment scenario; do not merge it into the spatial-only or temporal-only headline.

## 5. Leakage prevention checklist

Before accepting any run, verify and retain evidence for each item:

- [ ] One frozen dataset snapshot, row IDs, checksum, source manifest, and predeclared target eligibility rules.
- [ ] Split assignment generated before data-dependent transforms or model selection; all same-date observations are grouped for temporal boundaries, and all observations from a site/block are grouped for spatial boundaries.
- [ ] Spatial block coordinates use an explicit CRS, appropriate spatial scale and buffer; no held-out block rows enter training.
- [ ] Temporal folds are forward-only; test rows are later than training rows; all overlapping target/composite windows respect the split/embargo.
- [ ] Every feature has source-time and availability metadata; feature was available at prediction origin for every fold.
- [ ] No target, target-derived group statistic, held-out residual, target-based row filter, target imputation, or post-observation value enters the feature set.
- [ ] The city/date baseline is never computed from held-out labels. For a fixed climatology, fit it from the training reference period only.
- [ ] Product QA eligibility is predeclared from authoritative documentation, not chosen to improve test metrics.
- [ ] Any learned missing-value imputer, scaler, encoder, feature selector, outlier rule, or hyperparameter is fit/selected inside the training fold. Fold-specific validation data do not fit preprocessing.
- [ ] Full-panel anomaly statistics, all-data composites, and all-data filtering are not carried into spatial or temporal CV.
- [ ] Inner folds are used for model selection; outer folds/locked holdout are used for final estimates. Do not repeatedly select against the final test period.
- [ ] Predictions in evaluation are out-of-fold for every reported record; fitted-on-all-data deployment predictions are not labeled OOF or test predictions.
- [ ] Duplicate source observations and derived aggregates are grouped/identified so that copies or overlapping source granules cannot cross a split as independent samples.
- [ ] Report any remaining transductive assumptions explicitly and evaluate them only for the corresponding deployment scenario.

## 6. Comparable model comparison protocol

All candidates use the same frozen rows, eligible targets, feature contract, outer folds, target units, missingness policy, and metric definitions. Compare only within the same target and deployment scenario. Use nested inner validation for model/feature/hyperparameter selection and one shared outer evaluation.

### Candidates

1. **Historical baseline:** fold-local climatology described in section 7. Also report a training-fold global mean as a simple reference comparator; it is not guaranteed to be a performance floor. Baselines are genuine candidate predictors and must receive the same test rows and metrics.
2. **Linear Regression:** standardized numeric inputs and encoded categorical inputs as appropriate. Fit scaler/encoder and any regularization choice inside each training fold. Report coefficients and collinearity/conditioning diagnostics. A Ridge variant may be added as a separately named candidate.
3. **Random Forest Regressor:** all imputation/encoding and estimator selection inside the pipeline. Choose tree count, leaf size, feature sampling and depth only in inner training folds. Preserve a deterministic seed and thread/runtime configuration.
4. **XGBoost Regressor, conditional:** include only if the intended backend environment has a supported, pinned XGBoost version and the same folds/features can be run. Tune only in inner folds; record package/build/device settings. If unavailable, record “not evaluated”—do not substitute scikit-learn Gradient Boosting under the XGBoost label.

Do not compare ML1 absolute-LST temporal scores with ML2 anomaly spatial-CV scores. Re-run candidates under this shared protocol after data provenance and target definitions are approved.

## 7. Anomaly baseline definition

### Proposed default: fold-local location-season climatology

For each training fold, build a versioned lookup from **training observations only**, grouped by:

- product/pass and spatial support or a declared compatible class;
- location/grid ID when that location exists in training;
- a prespecified seasonal/calendar window appropriate to available training duration.

Use the median eligible observed LST in the reference period for each group as `B`. The statistic, reference years, calendar window, minimum training observation count, and any smoothing must be fixed in the protocol before evaluating outer folds. Do not choose them based on test errors.

Fallbacks must also be learned within that fold:

1. location + season baseline if it meets the predeclared training-count minimum;
2. otherwise region + season baseline computed only from training locations;
3. otherwise a training-fold global/product-compatible baseline.

If no valid training baseline exists, output anomaly as unavailable with an explicit reason; never use test observations to fill the gap. Record the baseline level used for each row so fallback use is measurable.

### Apply without test-label leakage

Freeze the fold's baseline before predicting its test rows. For each eligible test row:

```text
predicted_anomaly = predicted_lst_celsius - B(training_fold, location, season)
observed_anomaly  = observed_lst_celsius  - B(training_fold, location, season)
```

The test target may be used only to score `observed_anomaly` after predictions are fixed; it must not change `B`. Use the same `B` for observed and predicted anomaly. Also report absolute-LST metrics. Since subtracting the same baseline from both sides leaves the signed residual unchanged, anomaly errors alone do not establish independent model skill; they communicate deviation relative to the stated reference.

For spatial folds, the held-out location has no location-specific training history; use the fold's regional/seasonal fallback and expose it. For temporal folds at known locations, use only that location's pre-cutoff eligible history. A same-date observed city median is not a forecast-time baseline unless all same-date city observations are explicitly available at inference; if used, label it a transductive city-relative product and evaluate separately.

## 8. Evaluation and model selection criteria

### Metrics

For every outer fold and pooled out-of-fold prediction set, report:

- **MAE (°C):** mean absolute error.
- **RMSE (°C):** square root of mean squared error.
- **R²:** coefficient of determination against the same fold's observed target; report negative values without truncation.
- **Mean prediction bias (°C):** `mean(predicted - observed)`; negative means underprediction.
- **Per-location performance:** row count, MAE, RMSE, bias and, when defined/sample size permits, R² for each location; summarize the distribution across locations. Do not average location R² without showing undefined/small-sample cases.
- **Per-period performance:** equivalent counts and errors by month/season or prespecified period. Include each fold and forecast horizon; do not hide low-coverage periods.

Include fold assignments, coverage, missing/unavailable prediction counts, baseline fallback levels, and uncertainty intervals calculated by resampling independent spatial groups or time blocks—not individual autocorrelated rows. State how aggregate metrics weight locations/dates (row-weighted and macro-averaged summaries should be distinguishable).

### Selection policy

Before examining outer results, project/science owners must approve:

- minimum acceptable absolute-LST MAE/RMSE and maximum acceptable absolute bias, in °C;
- required coverage and minimum sample/group counts;
- acceptable fold-to-fold, location, and period stability;
- how scientific QA and reference-data evidence affect the permitted claim.

Choose the simplest candidate meeting those criteria across the required deployment scenarios. Use inner-fold scores to choose features/hyperparameters; use outer-fold estimates only for final assessment. If no model beats the training-only baseline by the predeclared practical margin or shows unacceptable instability/bias, retain the baseline or report no deployable model. Do not declare a winner from a single R² or from incomparable tasks.

## 9. Artifact and backend integration contract

### Saved artifacts

Persist one versioned deployable pipeline that contains the estimator and all fitted preprocessing. A Python backend may use a version-pinned scikit-learn/joblib artifact; never load untrusted serialized model files. Keep the approved baseline table/function as a separately versioned artifact or include its immutable parameters and lookup in the package.

Required manifest:

- model ID, semantic version, build/run ID, creation time, owner and artifact checksum;
- exact training dataset snapshot ID/checksum, source manifest, processing/QA version, target definition and unit;
- ordered feature schema: names, types, units, ranges, missing-value behavior, source/version, spatial support, temporal window and inference availability rule;
- fitted preprocessing steps and package/runtime versions;
- spatial/temporal split definitions and fold assignment references;
- outer and inner evaluation metrics, per-fold/per-location/per-period summaries, bias, coverage, limitations and approval status;
- anomaly baseline ID, reference period, grouping keys, minimum-count/fallback rules, units, product/pass support, and checksum;
- explicit out-of-domain, unknown-QA, missing-baseline, and unsupported-feature behavior.

Do not report training metrics or predictions made by the final all-data refit as held-out performance. Retain the immutable outer-fold predictions used for evaluation separately from deployment artifacts.

### Backend request/response behavior

Backend inference should:

1. Validate model/manifest compatibility and require every mandatory feature to satisfy its unit, temporal availability, spatial support, and accepted-value rules.
2. Reject or return an explicit unavailable/unsupported status for missing, unknown, out-of-domain, or post-origin features; do not silently substitute zero, a test-set statistic, or a stale baseline.
3. Emit `predicted_lst_celsius`, `heat_anomaly_celsius`, `baseline_lst_celsius`, baseline fallback level/definition ID, model version, target support/prediction time, and a quality/coverage status.
4. Preserve distinctions among directly observed satellite LST, model-predicted LST, and derived anomaly. Never overwrite an observation with a prediction or label an anomaly as temperature.
5. Log model/baseline versions and structured inference status; avoid logging credentials or unrelated sensitive values.

Flutter consumes the backend's typed response and labels the outputs distinctly. It should show baseline definition/period and unavailable/low-coverage state. Relative ranks are not health-risk categories without a separate validated threshold policy.

## 10. Outstanding questions for the ML team

### Data and target

- Which exact dataset snapshot is authoritative for the experiment? What is its manifest/checksum, and how do ML1/ML2 files relate to the documented approximate 116-location/150-date dataset?
- Are source MODIS granules/export manifests, product collection/version, QA values, conversion history, and row-level source identities available?
- What exact support does one target row represent: Terra or Aqua, a combined daily value, a pixel/footprint, or an aggregate? What acquisition time precision and timezone are available?
- Which LST values are measured/QA eligible versus screened, averaged, imputed, aggregated, or model-derived?
- Are independent ground-based surface-radiometry observations available for scientific validation? Provide sensor, measurand, calibration/uncertainty, time, footprint, units, and provenance. Air temperature is not direct LST ground truth.

### Features and availability

- For NDVI/NDBI, what are the exact sensor/product, composite IDs and start/end dates, spatial supports, and publication/availability times? Does any composite use imagery later than its prediction date?
- Are elevation, land cover, built-up, roads, and rainfall source versions and processing windows documented? Which will be available at the intended inference time?
- Are there duplicate/overlapping granules, point IDs reused between tables, or target-derived feature/quality fields in candidate datasets?

### Protocol and output

- Is the intended use new locations, future dates at known locations, or both? What operational forecast horizon and spatial resolution are required?
- Which spatial block CRS/size/buffer and temporal cutoff/embargo are scientifically appropriate given pixel footprints, autocorrelation, and data coverage?
- Should anomaly mean deviation from a location's historical seasonal baseline, regional climatology, or a transductive same-date city reference? Who approves reference period, window, minimum counts, and fallback?
- What practical performance, bias, coverage, stability, and uncertainty criteria define deployment acceptance? Who approves scientific claims?
- Which Python/backend runtime and artifact format are supported, and is XGBoost available under the production dependency policy?
- Can the ML team provide exact split manifests and reconcile conflicting ML1 metrics/cutoffs and saved artifact run IDs before any score is cited?

Until these questions are answered and provenance/reference requirements are satisfied, this design supports a controlled predictive experiment only. A predictive LST model or derived anomaly is not, by itself, physical sensor calibration or bias correction, and this design does not support a scientifically defensible calibration or accuracy claim.
