# UrbanHeat AI Machine Learning Model Selection Audit

**Scope:** ML1 and ML2 artifacts present in the workspace on `feat/temperature-calibration`.
**Mode:** Artifact/code/report inspection only. No models were trained, retrained, or deserialized; no database was accessed.

## Evidence labels

- **VERIFIED** — directly inspected in a workspace file or deterministic file inventory/profile. Counts and contents refer to the local artifact, not proof of source-data provenance.
- **DOCUMENTED** — stated in notebook text, saved metadata, or a result file, but not independently rerun or externally verified.
- **UNKNOWN** — not established by the available artifacts.

## 1. Executive summary

ML1 and ML2 do not currently answer the same question:

- **ML1** experiments target absolute `lst_celsius` values. Their reported temporal holdout results are weak: R² is negative or close to zero in the checked-in result sets. They do not test generalization to unseen locations.
- **ML2**'s final `Linear Regression` model uses only `ndvi_mean` to predict `lst_anom`, defined as LST minus the median of the city observations for the same date and satellite. Its metadata **DOCUMENTS** spatial-block out-of-fold (OOF) R² 0.5281, RMSE 0.8682 °C, and MAE 0.6494 °C. These results are not independently reproduced and are not an absolute-LST evaluation.

**No model can be called best for the application's two-output requirement from the present evidence.** The targets, datasets, splits, and scoring differ. ML2 has a meaningful spatial-group validation attempt, but its target construction and filtering use all dates/locations before the folds, including held-out observations; this makes the reported spatial-CV estimate potentially optimistic/transductive. It also does not test future dates. ML1 evaluates later dates but retains the same locations on both sides.

**Recommendation:** make absolute LST in Celsius the single primary supervised target, using provenance-verified observed LST and only inference-available predictors. Compare simple training-only climatology and Linear Regression against a tree model (Random Forest and/or the existing scikit-learn Gradient Boosting candidate); add XGBoost only if available and justified. Select by nested spatial/temporal evaluation, not by the current non-comparable scores. Derive the secondary heat anomaly deterministically from the absolute prediction and an explicitly approved, training-only comparable baseline. Do not interpret ML2's anomaly prediction as an absolute temperature.

The local candidate tables include 116 point IDs but 196–198 observed dates, depending on file. The “approximately 116 points and 150 dates” statement is **DOCUMENTED** in an older project report, not a verified description of the current experiment tables or any live Supabase data.

The ML1/ML2 files are local experiment artifacts. No evidence in this audit establishes that they are exports of `malang_climate_pilot` or `urban_heat_data`, or that their rows map to either live table. Backend inference and Flutter display of model predictions are recommendations only; they are not established as implemented functionality by these experiment artifacts.

## 2. ML1 experiment inventory

### Train 1 — location/time absolute-LST baseline

| Item | Finding |
|---|---|
| Dataset | **VERIFIED:** notebook prompts for `malang_lst_ml_candidate.csv`; local file has 15,483 rows, 116 distinct point IDs, and 196 dates from 2025-10-13 through 2026-10-09. This matches the saved Train 1 test-prediction file's 3,840 rows plus the `urbanheat_ai_ml_results (1).csv` training count of 11,643. Source lineage and MODIS metadata are **UNKNOWN**. |
| Target | **VERIFIED:** notebook prefers `lst_target_celsius` if present, otherwise `lst_celsius`. The table contains both. The notebook says values are already in Celsius and performs no satellite scale conversion. Exact source meaning/unit is **UNKNOWN** from these artifacts alone. |
| Inputs | **VERIFIED:** latitude, longitude, year, month, day of year, day of week. Date parts are derived from `observation_date`. No NDVI/NDBI is used. |
| Preprocessing | **VERIFIED:** remove rows missing required date, target, or features; sort by date. Linear Regression pipeline has median imputation and `StandardScaler`; Random Forest has median imputation. Those transformations are fit inside each model fit, on the training partition. No scaling for the forest. |
| Missing/outlier handling | Missing required values are dropped before the split. Very low LSTs are flagged for review, not automatically removed. Notebook text notes six low-LST values needing source-quality review. |
| Split | **VERIFIED:** chronological split at approximately 80% of unique dates; all records for a date remain together. Saved predictions cover 40 dates, 2026-08-26 through 2026-10-09. The train and test date sets do not overlap. The same 116 point IDs occur on both sides. |
| Models / settings | Linear Regression; RandomForestRegressor with `n_estimators=300`, `min_samples_leaf=2`, `random_state=42`, `n_jobs=-1`; and a training-mean constant baseline. |
| Evaluation | One later-date test partition, with MAE, RMSE, and R². No spatial holdout, nested tuning, interval, bias, or per-period/location report is established in the summary metrics. Random Forest feature importance is described as non-causal. |
| Reported metrics | **DOCUMENTED** in `urbanheat_ai_train1_metrics.csv`: RF MAE 1.6205 °C, RMSE 2.1138 °C, R² -0.0131; Linear Regression 2.5879, 3.1416, -1.2379; training-mean baseline 2.4540, 2.9803, -1.0140. A separate results CSV rounds/reports slightly different RF values (MAE 1.6215, RMSE 2.1169, R² -0.0161). No run identifier reconciles the difference. |
| Saved artifacts | Test predictions, metrics, and `urbanheat_ai_train1_baseline_models.joblib` are present. The joblib file was inventoried, not loaded or independently validated. |

### Train 2 — adding NDVI/NDBI to absolute-LST experiments

| Item | Finding |
|---|---|
| Dataset | **VERIFIED:** notebook loads a supplied CSV; the accompanying `UrbanHeat_AI_dataset_training_candidate.csv` contains 15,385 rows, 116 point IDs, 197 dates from 2025-10-13 through 2026-10-08, and no missing values in the inspected CSV columns. Related `malang_lst_ndbi_ndvi.csv` contains 15,489 rows and 104 missing values in each of NDVI and NDBI. Exact file-to-run lineage is **UNKNOWN**. |
| Target | **VERIFIED:** `lst_celsius`, an absolute-LST-labelled target. Unit/source provenance is **UNKNOWN**. |
| Inputs | **VERIFIED:** baseline set latitude, longitude, year, month, day of year, day of week; enriched set adds `ndvi` and `ndbi`. `point_id`, satellite, observation count, and review flags are not model features in the described comparison. |
| Preprocessing | Drop rows missing required date, coordinates, target, time features, NDVI, or NDBI; recompute time features from the observation date; sort chronologically. An imputer is in each training pipeline and is fit on the training partition. No feature scaling or fitted feature selection is shown. |
| Missing/composite handling | Notebook notes that NDVI/NDBI may recur across LST dates because the indices are 8-day composites; composite start/end dates are absent. It audits repeated value pairs and chooses a time cutoff intended to avoid identical `(point_id, NDVI, NDBI)` tuples across splits where possible. This is a proxy, not verified composite-window lineage. Low LST rows are flagged, not automatically removed. |
| Split | A chronological date split with no date overlap. At the saved revised cutoff (2026-08-21), train/test counts are 11,192/4,193 and the notebook output reports zero exact point+NDVI+NDBI tuples crossing the cutoff. The same 116 locations appear on both sides. Another metrics file uses cutoff 2026-08-25 and 11,533/3,852 rows; a local inventory calculation finds 116 exact point+NDVI+NDBI tuples crossing that cutoff. These are different evaluation configurations, not interchangeable results. |
| Models / settings | Linear Regression; RandomForestRegressor (`n_estimators=300`, `min_samples_leaf=2`, `random_state=42`, `n_jobs=-1`); GradientBoostingRegressor (`n_estimators=150`, `random_state=42`). Each receives median imputation. Gradient Boosting here is scikit-learn's model, not XGBoost. |
| Evaluation | One later-date holdout for each saved run; MAE, RMSE, R² and prediction CSVs. No spatial holdout. A notebook also contains older exploratory cell outputs, making the notebook's execution state/run version important to reconcile. |
| Reported metrics | **DOCUMENTED, cutoff 2026-08-25:** best shown is Gradient Boosting with NDVI/NDBI, MAE 1.4361 °C, RMSE 1.8771 °C, R² 0.1951; Gradient Boosting baseline-only R² 0.1808. RF and Linear Regression scores are weaker. **DOCUMENTED, revised cutoff 2026-08-21:** Gradient Boosting with NDVI/NDBI has MAE 1.6757, RMSE 2.2122, R² -0.1575; baseline-only R² -0.4149. The revised comparison CSV reports a different two-row comparison (MAE/RMSE/R² 1.6423/2.1923/-0.1367 with features vs 1.8412/2.3913/-0.3524 baseline), apparently a separate comparison run. No run manifests reconcile these outputs. |
| Saved artifacts | Candidate model joblib, two metric CSVs, two prediction CSVs, and Train 1/2 comparison CSV are present. The joblib was inventoried, not loaded. |

## 3. ML2 experiment inventory

### Data and target construction

- **VERIFIED:** local ML2 files include a 116-row point grid; a 19,255-row Terra/Aqua LST file with 116 points and 198 dates; a 40,832-row daily precipitation file; and a 15,489-row merged one-year urban-heat dataset with 116 points and 198 dates. These are local file counts, not source/provider verification.
- **DOCUMENTED in the notebook:** MODIS Terra MOD11A1 and Aqua MYD11A1 collection/version `v061`, band `LST_Day_1km`, 1 km extraction; `QC_Day` bit screening; raw LST scaled by 0.02 Kelvin then converted by subtracting 273.15 to Celsius. Terra/Aqua are kept separate initially and averaged at a point/date when both are valid. Source-side collection metadata, original granules, export manifests, and exact final-row lineage are not present in the inspected ML2 package, so actual source provenance remains **UNKNOWN**.
- The notebook also **DOCUMENTS** static/context data from SRTM elevation, Dynamic World land cover/built-up, Sentinel-2 SR Harmonized NDVI, OpenStreetMap road length, and CHIRPS precipitation. NDVI is a study-period median composite summarized in a 500 m buffer; built-up/land cover and other site features are also static per point. **UNKNOWN:** exact lineage/version of each local CSV row and whether the full-study-period Sentinel-2 imagery is available at the time of any historical/future prediction.
- **VERIFIED:** the final ML2 `model_metadata.json` defines the target as `lst_anom = LST - median city LST for the same date and satellite`, in °C. It is not absolute LST. The notebook calculates this from per-satellite observations, then averages satellite anomalies at point/date if both are available.
- The notebook describes filtering date/satellite groups with fewer than 70 valid points, excluding absolute anomalies greater than 6 °C, flagging large robust residuals, and removing groups with at least 20 flagged records. Its saved metadata lists these cleaning thresholds. They are notebook-defined processing choices, not independently validated QA truth.

### Models, validation, and outputs

| Item | Finding |
|---|---|
| Final model inputs | **VERIFIED:** metadata lists one feature, `ndvi_mean`; target is `lst_anom`. Metadata reports 13,188 training rows across 116 locations. |
| Preprocessing | Final artifact source in the notebook uses a scikit-learn Pipeline with median `SimpleImputer` and `LinearRegression`; it fits on all cleaned `panel2` rows after evaluation. Other feature-set pipelines use median imputation and most-frequent categorical imputation. Fold pipelines fit their transformers within each fold. |
| Compared candidates | Mean/Dummy baseline, Linear Regression on NDVI alone, Linear Regression on static features, and Random Forest on all static features. The candidates do not all use identical inputs; the table therefore compares both algorithm and feature set. No XGBoost model is present. |
| Spatial grouping | **DOCUMENTED/VERIFIED in notebook outputs:** 5-fold `GroupKFold` using coordinate-derived spatial blocks; configured block size 0.03 degrees; final output reports 18 blocks and 13,188 rows. Sensitivity outputs test other block sizes. |
| Reported spatial OOF metrics | **DOCUMENTED** in `model_metadata.json`, `model_comparison.csv`, and saved notebook outputs: Linear Regression/NDVI-only R² 0.5281, RMSE 0.8682 °C, MAE 0.6494 °C. Other saved comparison rows: Linear Regression/all features R² 0.5118, RMSE 0.8831, MAE 0.6615; RF/all features R² 0.3330, RMSE 1.0322, MAE 0.7815; mean baseline R² -0.1400, RMSE 1.3494, MAE 1.0722. These are previously reported OOF results, not independently reproduced here. |
| Random-split contrast | Saved comparison reports RF R² 0.7001 on random split versus 0.3330 on spatial OOF, and Linear Regression NDVI-only 0.5565 versus 0.5281. The notebook itself says random KFold is for demonstrating spatial leakage, not for the headline score. |
| Saved artifacts | `urbanheat_linear_ndvi.joblib`, `model_metadata.json`, `model_comparison.csv`, 116-row `heat_predictions.json`, and `hasil_akhir.png`. The JSON contains `pred_anom`, NDVI, coordinates, and Low/Medium/High categories, not absolute LST. Notebook describes these categories as relative rank tertiles, not health-risk thresholds. The saved model is fit on all 13,188 rows; the 116 exported predictions are not a held-out test set. |

## 4. Existing model comparison

| Strategy / result set | Target | Evaluation evidence | Interpretation |
|---|---|---|---|
| ML1 Train 1 Random Forest | Absolute LST (°C) | Later-date holdout; reported R² -0.0131, MAE 1.6205, RMSE 2.1138. | Best among the two trained models on the listed result file, but does not beat a useful generalization standard and is not spatially held out. |
| ML1 Train 2 Gradient Boosting + NDVI/NDBI | Absolute LST (°C) | Cutoff 2026-08-25: R² 0.1951, MAE 1.4361, RMSE 1.8771. Revised cutoff 2026-08-21: R² -0.1575, MAE 1.6757, RMSE 2.2122. | Metrics vary materially with the saved split/run. No best-model conclusion is justified until run lineage is reconciled and evaluation is repeated with controlled splits. |
| ML2 Linear Regression, NDVI-only | Spatial anomaly (°C), not absolute LST | Reported 5-fold spatial-block OOF R² 0.5281, MAE 0.6494, RMSE 0.8682; potentially affected by global target construction/filtering before folds. | Simple and interpretable for relative anomaly, but cannot supply absolute Celsius LST. It is a provisional anomaly candidate only. |
| ML2 Random Forest, all static features | Spatial anomaly (°C) | Reported spatial OOF R² 0.3330, MAE 0.7815, RMSE 1.0322; random-split R² 0.7001. | Lower than NDVI-only Linear Regression in this comparison. Random-split inflation illustrates why spatial grouping matters. |
| XGBoost | No experiment found | No XGBoost model/result/artifact found; `xgboost` and scikit-learn are unavailable in the inspected Python interpreter. | Do not claim a result. The notebook installs scikit-learn, not XGBoost. Consider only as a future controlled candidate if the backend environment can support it. |
| Historical/climatological baseline | ML1 train-mean and ML2 dummy/mean baselines exist; no comparable location-season historical-climatology result found. | ML1's reported train-mean and ML2's reported mean baseline metrics are shown above. | Add a train-only seasonal/location climatology baseline; it must use only information available at prediction time and match the target's spatial/temporal/product support. |

These scores must not be ranked against one another as a single leaderboard: ML1 predicts absolute LST over later dates; ML2 predicts same-date, same-satellite city-relative anomalies under spatial-block CV. Dataset versions and split definitions also differ.

## 5. Data leakage audit

### ML1

1. **Spatial reuse — VERIFIED:** both Train 1 and Train 2 temporal splits contain the same 116 locations in training and testing. This is appropriate only for a stated “future dates at known locations” use case; it does not estimate unseen-location performance and can reward location memorization, especially for coordinate-based tree models.
2. **Date split — VERIFIED:** each saved ML1 split keeps all rows for a date together and has no shared train/test dates. This avoids direct same-date train/test row overlap but only tests the particular later period.
3. **Composite reuse — potential, with split-version conflict:** Train 2 documents repeated 8-day NDVI/NDBI values and missing composite start/end dates. Its 2026-08-21 output reports no exact `(point_id, NDVI, NDBI)` tuple crossing the split. A separate 2026-08-25 metrics configuration has 116 such tuples by direct inspection of the supplied candidate CSV. Neither check identifies true composite IDs/windows; repeated values may indicate the same source composite, but the exact lineage is **UNKNOWN**.
4. **Preprocessing fits — no direct leakage found in the inspected model code:** median imputers and Train 1's scaler are inside pipelines fitted on `X_train`; Train 2 imputers are similarly fit on its training partition. There is no evidence that a fitted scaler or imputer was fit on the test data.
5. **Feature/target separation — no direct leakage found in selected feature lists:** ML1 feature lists exclude `lst_celsius` (Train 1 target alias handled separately; Train 2 target is `lst_celsius`), review flags, satellite labels, and observation count. Date-derived calendar features are available in advance, not future observations. However, the dataset's LST/NDVI/NDBI lineage and composite timestamps are unknown, so upstream leakage cannot be ruled out.
6. **Model selection/test reuse — risk:** notebooks contain exploratory outputs, multiple cutoffs, revised results, and comparison files without run IDs. If a cutoff/model/feature set was chosen after repeatedly inspecting the reported test period, the final score is a selected-on-test estimate. The available package does not establish a separate untouched final test after these choices.

### ML2

1. **Target uses held-out outcomes — high-confidence leakage risk:** the notebook computes the per-date/per-satellite city median from `raw` before spatial folds, then derives each row's anomaly as its LST minus that median. The median includes observations from spatial blocks later held out and includes the row's own LST. Consequently, test labels depend on held-out outcomes and are not independent of the test set. This can be valid only for a deliberately transductive “relative to the observed city on that date” target with all-city observations available; it is not an independent future prediction target.
2. **Full-data filtering/flagging before CV — leakage/selection risk:** coverage thresholds, anomaly outlier removal, robust residual flags, and bad date/satellite group removal are applied to the full panel before GroupKFold. Test-fold values therefore influence which rows/groups are retained and their labels. These rules should be predeclared from product QA or recomputed using training-only statistics; evaluation of an observed target may retain test rows but must not use them to train the predictor or select the test population.
3. **Spatial but not temporal holdout — VERIFIED:** GroupKFold holds coordinate-derived blocks out, but observations from the same dates occur across train/test blocks. It tests transfer to held-out blocks in dates already represented in training, not future dates. This is not a same-row split leak; it is a scope limitation for temporal deployment claims.
4. **Static features may look ahead — potential risk:** notebook describes Sentinel-2 NDVI as a median composite over the study period, and static features are reused across all dates. If any imagery or derived covariate postdates a prediction date, it is future information for that date. The exact composite time window and per-feature source dates must be established before temporal prediction claims.
5. **Feature preprocessing — lower risk in inspected model code:** model pipelines fit imputers within each GroupKFold fit. The final model is then fit on the full cleaned panel after evaluation, as expected for a deployment artifact. No scaler is shown. This does not address the global target/cleaning leakage above.
6. **Selection after repeated CV — optimism risk:** the notebook compares feature sets, model types, block sizes, cleaning sensitivity, and seasonal variants using the same spatial folds, then chooses NDVI-only Linear Regression. The selected model's same-fold score is not a fully independent final estimate. Use nested spatial CV or a locked spatial holdout for final model selection.
7. **Exported predictions are not test metrics:** `heat_predictions.json` contains predictions for 116 locations after fitting the final model to the complete `panel2`. It must not be presented as held-out/OOF prediction evidence. The categories are relative ranks and, with the negative NDVI coefficient, largely reverse NDVI rank; they are not absolute temperature or validated health-risk classes.

### Leakage conclusions

- The ML1 scaler/imputer implementations inspected are train-fit, but location identity crosses its time splits.
- ML2's spatial blocking is a strength, but global anomaly construction, filtering, and model selection before/on those same folds compromise the independence of its reported OOF estimate.
- No confirmed use of future target values as explicit ML1 features was found. ML2 target-derived city medians and potentially study-period NDVI are the major look-ahead risks.
- No evidence in the checked-in package establishes that original acquisition/composite windows or any hidden upstream processing are leakage-free.

## 6. Dataset suitability

### Suitable only for a new controlled experiment, not yet as verified calibration data

- Local CSVs are large enough for row-level experiments, and the ML2 package includes raw-labelled Terra/Aqua rows plus joined static/daily covariates. **VERIFIED:** ML1/ML2 local files include 116 distinct grid/point IDs and roughly 15k daily merged rows; ML2 reports 13,188 cleaned anomaly-panel rows. These counts describe the checked-in copies only.
- **UNKNOWN:** original source granule lineage, actual product collection and QA for the supplied CSV values, observation time-of-day, provenance of the existing `lst_celsius`, and reproducibility of the extraction/merge. ML2's notebook documents a source pipeline, but states that an earlier merge script was not saved and that the merge was reconstructed.
- The time span and local date counts do not match the older “about 150 observation dates” report statement exactly. The report is not evidence that these exact ML1/ML2 CSVs are the same dataset.
- The available ML2 final model is suitable only as an experimental relative anomaly estimator after resolving leakage and target semantics. It cannot provide absolute LST.
- ML1 absolute-LST results are insufficient to establish reliable accuracy or deployment suitability. Their temporal holdout is useful evidence of difficulty but not a spatially independent evaluation.
- Neither experiment establishes accuracy against independent ground-based surface radiometry. This audit does not treat air temperature or one satellite-derived product as direct LST ground truth.

## 7. Recommended model evaluation plan

Do not train as part of this audit. After source-data and target definitions are approved, run a controlled experiment with a locked protocol:

1. **Freeze the prediction task and data version.** Primary target is absolute LST in Celsius for a defined pixel/footprint, product/pass, spatial resolution, and time support. Retain raw observation, QA, units, scale, and lineage. Separate observed values from imputed/aggregated values and predictions.
2. **Predeclare admissible features and availability times.** Include coordinates/grid, calendar/daypart, and vegetation/built-form/weather features only when their source date/composite is available at the prediction time. Do not use any target-derived LST statistic, same-day observed city median, future imagery, future rainfall, `point_id` lookup, or post-observation value as a predictor unless the product explicitly defines an interpolation/nowcast task and evaluates that setting separately.
3. **Use baselines first.** For absolute LST: training-fold global mean, a location/season climatology computed only from training observations, and a simple persistence/seasonal baseline only where valid prior observations would actually be available. For anomaly: a zero-anomaly baseline when anomaly is defined against a fixed climatology. Report each baseline on exactly the same observations and folds as candidate models.
4. **Compare model candidates fairly.** Linear Regression (and optionally Ridge for collinear features), Random Forest, and the existing scikit-learn Gradient Boosting Regressor, all with identical features and folds. Add XGBoost only if installed/deployable and under the same protocol; it has no current result. Keep model selection inside inner folds, with a locked outer evaluation.
5. **Spatial generalization:** group all observations from a point and nearby correlated points into spatial blocks; use block buffers/holdout areas to reduce spatial autocorrelation across the boundary. All dates from a held-out block stay out of training. Report number of points/blocks and coverage per fold.
6. **Temporal generalization:** a forward-chaining chronological split with a locked future date window; every point's records at dates after the cutoff stay in test. Fit imputers, scalers, feature selection, climatologies, anomaly baselines, and thresholds using training data only. Keep all rows for a date/window together where shared observations or composites could otherwise bridge the split.
7. **Joint deployment check:** additionally evaluate a strict test set that is both a future time window and spatially held-out blocks, when sample coverage permits. Report spatial-transfer and future-time results separately; do not imply either from the other.
8. **Prevent leakage in targets and cleaning:** define any anomaly reference baseline before splitting and calculate it only from an approved reference/training period. Do not compute test labels from a median that includes held-out LST or use full-panel residuals to decide test-row inclusion. Use authoritative QA flags as predeclared observation eligibility; if a statistical outlier detector is necessary, fit its parameters in the training fold.
9. **Report the same metrics for every model/fold:** MAE, RMSE, R², and signed prediction bias (`mean(predicted - observed)`) in °C. Add per-location, per-period/season, and per-fold errors; report sample counts, uncertainty intervals across spatial/time groups, and failure coverage. Investigate negative R² and systematic bias rather than selecting on one aggregate score.
10. **Assess stability and interpretability:** compare feature sets and hyperparameters within nested validation; report variation across folds/seeds and seasonal periods. Use coefficients for linear models and held-out permutation importance or carefully scoped SHAP for nonlinear models. Interpret associations as predictive, not causal.

## 8. Proposed final architecture

### Prediction and derived output

1. **Primary model target:** `observed_land_surface_temperature` in °C for a declared satellite/product/pass, date/time convention, and spatial support. Use measured/quality-screened observations as training labels; do not train on imputed or predicted labels as if observed.
2. **Primary output:** `predicted_lst_celsius`. A future ML2 anomaly-only model cannot fill this field, and adding an anomaly to an arbitrary constant does not produce a valid absolute temperature.
3. **Secondary derived output:** `heat_anomaly_celsius = predicted_lst_celsius - baseline_lst_celsius`. Define and version the baseline before deployment. Recommended temporal-anomaly baseline: a training-only, fixed reference-period climatology for the same grid/footprint, season/calendar window, and satellite/daypart/product support. For unseen locations, use a separately declared regional fallback and expose that fallback. If the intended product is instead city-relative hotspot ranking, define a distinct city-reference method using only comparable model predictions for the same inference run and label it as relative spatial deviation, not temporal climatology or health-risk temperature.
4. **Do not silently substitute ML2's target definition.** Its same-date observed city median is transductive and unavailable for a true future prediction unless the complete same-date observed city dataset is provided. If retained as a research target, name it explicitly and evaluate it as a different task.

### Model and validation

- Benchmark location/season climatology and Linear Regression as transparent references, then Random Forest and scikit-learn Gradient Boosting on the same features and leakage-safe splits. XGBoost remains optional; no experiment was found, and it is not present in the inspected Python interpreter.
- Select the simplest model that meets project-approved absolute-error, bias, coverage, stability, and interpretability criteria on locked spatial and chronological tests. Current artifacts do not justify selecting a winner.
- Keep anomaly derivation deterministic and separately test baseline coverage, baseline version, and fallback behavior.

### Artifact and backend inference

- Save a versioned scikit-learn `Pipeline` (for the current Python backend, e.g. pinned-version `joblib`) containing all fitted preprocessing and estimator. Include a machine-readable manifest: model ID/version, input schema/types/units/ranges, target/measurand, feature provenance and timing requirements, training dataset/run IDs, preprocessing/QA version, dependency versions, baseline definition/reference period, validation protocol/metrics, artifact checksum, and limitations.
- Backend should validate required features, their units, timestamp/composite availability, and model/manifest compatibility; return explicit missing-input or out-of-domain status rather than silently substituting defaults. Expose both prediction and baseline components and preserve observed vs predicted state. Log model/baseline versions and inference time, not credentials or sensitive inputs.
- If an artifact is exported outside Python, use a separately validated portable format such as ONNX only after confirming equivalent preprocessing and numeric outputs. The Flutter client should consume a backend response, not deserialize a Python joblib.

### Flutter output contract

Return/display separate fields such as:

```json
{
  "observation_type": "predicted",
  "predicted_lst_celsius": 31.4,
  "baseline_lst_celsius": 30.2,
  "heat_anomaly_celsius": 1.2,
  "baseline_definition_id": "approved-version",
  "prediction_period": "declared-date-or-window",
  "model_version": "approved-model-version",
  "quality_or_coverage_status": "validated-status"
}
```

The values are illustrative placeholders, not actual predictions. UI labels must distinguish **Observed satellite LST**, **Predicted LST**, and **Derived anomaly**; show the baseline definition/period and unavailable/low-coverage state. Do not label relative tertiles as absolute heat or health-risk categories without a separate validated threshold policy.

## 9. Risks and unresolved questions

- **UNKNOWN:** Are ML1/ML2 CSVs all derived from the same authoritative source and pipeline? Which dataset version is intended for deployment?
- **UNKNOWN:** Is the target absolute satellite LST, an anomaly from a fixed historical climatology, or a same-day city-relative anomaly? Which spatial/temporal support is required by the app?
- **UNKNOWN:** Are ML2's source band/version/scale/QA claims backed by original Earth Engine export metadata, granules, and reproducible export manifests?
- The ML2 notebook says a previous merge script was not retained and reconstructs the merge. Therefore exact provenance of the supplied merged CSV is not fully reproducible from the original run.
- **UNKNOWN:** Does Sentinel-2 NDVI `median()` span the entire study year? What imagery dates are available for each inference date? This determines look-ahead risk for temporal forecasting.
- **UNKNOWN:** What are the exact spatial block assignment algorithm, coordinate projection/units, geographic gaps, and station/pixel independence? The notebook's 0.03-degree block size does not alone establish statistical independence.
- ML2's 5-fold CV is used across model/feature/block/cleaning/season choices; score selection may be optimistic without an outer test.
- ML1 result files and notebook runs have conflicting row counts, cutoffs, and metrics without run IDs; ML team reconciliation is required before using a number externally.
- Existing joblib files were not loaded because model deserialization can execute code and the inspected Python environment lacks joblib/scikit-learn. Artifact compatibility, contents, dependency versions, and model reproducibility are **UNKNOWN**.
- No XGBoost code, result, artifact, or installed package was found in the inspected interpreter; its future suitability remains untested.
- No independent ground-based surface-radiometry reference data or calibration/uncertainty records were found in these ML folders. Prediction accuracy as a measure of physical LST is therefore not established by this audit.
- **UNKNOWN:** Are random seeds, exact training environments, split assignments, source data snapshots, and final artifact run IDs preserved in other approved project storage?

## 10. Exact files inspected

### ML1

- `ML1/UrbanHeatAI_Train1_Baseline.ipynb`
- `ML1/UrbanHeatAI_Train2(2)_LST_NDVI_NDBI.ipynb`
- `ML1/UrbanHeat_AI_dataset_training_candidate.csv`
- `ML1/malang_lst_ml_candidate.csv`
- `ML1/malang_lst_ndbi_ndvi.csv`
- `ML1/malang_lst_review_with_flags.csv`
- `ML1/urbanheat_ai_ml_results (1).csv`
- `ML1/urbanheat_ai_train1_metrics.csv`
- `ML1/urbanheat_ai_train1_test_predictions.csv`
- `ML1/urbanheat_ai_train1_train2_comparison (1).csv`
- `ML1/urbanheat_ai_train2_metrics.csv`
- `ML1/urbanheat_ai_train2_predictions.csv`
- `ML1/urbanheat_ai_train2_revised_metrics.csv`
- `ML1/urbanheat_ai_train2_revised_predictions.csv`
- `ML1/urbanheat_ai_train1_baseline_models.joblib` — inventoried and fingerprinted; not deserialized.
- `ML1/urbanheat_ai_train2_candidate.joblib` — inventoried and fingerprinted; not deserialized.

### ML2

- `ML2/UrbanHeatAI_Pipeline-2.ipynb`
- `ML2/kota_malang_grid_1km.csv`
- `ML2/malang_lst_terra_aqua_1year.csv`
- `ML2/malang_precipitation_daily.csv`
- `ML2/malang_urbanheat_dataset_with_road_density_1year.csv`
- `ML2/model_final/model_comparison.csv`
- `ML2/model_final/model_metadata.json`
- `ML2/model_final/heat_predictions.json`
- `ML2/model_final/urbanheat_linear_ndvi.joblib` — inventoried and fingerprinted; not deserialized.
- `ML2/model_final/hasil_akhir.png` — inventoried; numerical claims were taken from notebook outputs and CSV/JSON artifacts, not inferred from the image.

macOS `__MACOSX/._*` resource-fork entries were excluded from the dataset inventory as duplicate operating-system metadata, not treated as experiment artifacts.

### Information still needed from the ML team

1. Confirm the authoritative ML1/ML2 dataset versions, intended output target(s), and the relationship between the 116-point/~150-date documented dataset and the checked-in 196–198-date CSVs.
2. Provide source lineage, original exports/granules, exact collection/composite dates, row mappings, and acquisition-time semantics for LST and each predictor.
3. Reconcile all ML1 metric files/notebook outputs with run IDs, exact split cutoffs, model configurations, input file checksums, and the artifact that produced each score.
4. Provide ML2 anomaly construction, filtering, and fold manifests; confirm whether target medians and flags were computed before CV from all locations, and whether full-study-period NDVI was used.
5. Approve the anomaly definition and inference-time baseline: fixed local/season climatology versus city-relative spatial deviation.
6. Provide the data evidence needed to evaluate against independent surface LST reference observations; clarify that any air-temperature source is a distinct measurand.
