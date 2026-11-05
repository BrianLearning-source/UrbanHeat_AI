import unittest

from calibration_pipeline import (
    CalibrationConfig,
    CalibrationReadinessStatus,
    assess_calibration_readiness,
)
from temperature_validation import ProductSpec, ValidationStatus


SATELLITE_CATALOG = {
    "SAT_LST": ProductSpec(
        versions=frozenset({"v1"}),
        bands=frozenset({"lst"}),
        temperature_units=frozenset({"Celsius"}),
        scale_metadata={("v1", "lst"): (1.0, 0.0)},
        quality_flag_statuses={
            ("v1", "lst"): {
                "good": ValidationStatus.VALID,
                "bad": ValidationStatus.INVALID,
            }
        },
    )
}
REFERENCE_CATALOG = {
    "GROUND_LST": ProductSpec(
        versions=frozenset({"v1"}),
        bands=frozenset({"surface_sensor"}),
        temperature_units=frozenset({"Celsius", "Kelvin"}),
        scale_metadata={("v1", "surface_sensor"): (1.0, 0.0)},
        quality_flag_statuses={
            ("v1", "surface_sensor"): {"good": ValidationStatus.VALID}
        },
    )
}


def satellite_record(**overrides):
    record = {
        "id": "sat-1",
        "source_dataset_id": "sat-dataset-1",
        "source_observation_id": "sat-source-1",
        "temperature_value": 31.0,
        "latitude": -7.95,
        "longitude": 112.63,
        "observation_datetime": "2024-06-08T03:00:00Z",
        "temperature_unit": "Celsius",
        "source_product": "SAT_LST",
        "product_version": "v1",
        "source_band": "lst",
        "raw_or_scaled": "scaled",
        "scale_factor": 1.0,
        "scale_offset": 0.0,
        "quality_flag": "good",
        "processing_version": "pipeline-1",
        "measurand": "land_surface_temperature",
        "measurand_definition_reference": "measurement-dictionary-v1",
        "footprint_compatibility_id": "pixel-surface-protocol-v1",
    }
    record.update(overrides)
    return record


def reference_record(**overrides):
    record = {
        "id": "ref-1",
        "source_dataset_id": "reference-dataset-1",
        "source_observation_id": "ref-source-1",
        "temperature_value": 30.5,
        "latitude": -7.951,
        "longitude": 112.631,
        "observation_datetime": "2024-06-08T03:10:00+00:00",
        "temperature_unit": "Celsius",
        "source_product": "GROUND_LST",
        "product_version": "v1",
        "source_band": "surface_sensor",
        "raw_or_scaled": "scaled",
        "scale_factor": 1.0,
        "scale_offset": 0.0,
        "quality_flag": "good",
        "processing_version": "sensor-pipeline-1",
        "measurand": "land_surface_temperature",
        "measurand_definition_reference": "measurement-dictionary-v1",
        "footprint_compatibility_id": "pixel-surface-protocol-v1",
        "reference_independence_basis": "independent-ground-sensor-record",
    }
    record.update(overrides)
    return record


def config(minimum=1):
    return CalibrationConfig(
        max_spatial_distance_meters=500,
        max_temporal_difference_seconds=1800,
        minimum_matched_pairs=minimum,
    )


class CalibrationPipelineTests(unittest.TestCase):
    def assess(self, satellites, references, *, settings=None):
        return assess_calibration_readiness(
            satellites,
            references,
            satellite_product_catalog=SATELLITE_CATALOG,
            reference_product_catalog=REFERENCE_CATALOG,
            config=settings or config(),
        )

    def test_valid_compatible_observations_are_matched_and_ready(self):
        report = self.assess(
            [satellite_record()],
            [reference_record()],
        )

        self.assertEqual(report.readiness_status, CalibrationReadinessStatus.READY)
        self.assertEqual(len(report.matched_pairs), 1)
        self.assertEqual(report.unmatched_satellite_observations, ())
        self.assertEqual(report.unmatched_reference_observations, ())
        self.assertLessEqual(report.matched_pairs[0].distance_meters, 500)

    def test_duplicate_satellite_source_ids_with_different_times_are_excluded(self):
        report = self.assess(
            [
                satellite_record(
                    id="sat-row-1",
                    source_observation_id="same-source-id",
                    observation_datetime="2024-06-08T03:00:00Z",
                ),
                satellite_record(
                    id="sat-row-2",
                    source_observation_id="same-source-id",
                    latitude=-7.949,
                    observation_datetime="2024-06-08T03:20:00Z",
                ),
                satellite_record(
                    id="sat-row-3",
                    source_observation_id="distinct-source-id",
                    latitude=-7.948,
                    observation_datetime="2024-06-08T03:40:00Z",
                ),
            ],
            [
                reference_record(
                    id="ref-row-1",
                    source_observation_id="ref-source-1",
                    observation_datetime="2024-06-08T03:00:00Z",
                ),
                reference_record(
                    id="ref-row-2",
                    source_observation_id="ref-source-2",
                    latitude=-7.949,
                    observation_datetime="2024-06-08T03:20:00Z",
                ),
                reference_record(
                    id="ref-row-3",
                    source_observation_id="ref-source-3",
                    latitude=-7.948,
                    observation_datetime="2024-06-08T03:40:00Z",
                ),
            ],
            settings=config(minimum=2),
        )

        self.assertEqual(len(report.matched_pairs), 1)
        self.assertEqual(
            report.readiness_status,
            CalibrationReadinessStatus.PARTIALLY_READY,
        )
        duplicate_exclusions = [
            item
            for item in report.unmatched_satellite_observations
            if "duplicate_source_observation_id" in item.reasons
        ]
        self.assertEqual(len(duplicate_exclusions), 2)

    def test_same_observation_id_in_different_product_contexts_is_not_duplicate(self):
        second_product = ProductSpec(
            versions=frozenset({"v1"}),
            bands=frozenset({"lst"}),
            temperature_units=frozenset({"Celsius"}),
            scale_metadata={("v1", "lst"): (1.0, 0.0)},
            quality_flag_statuses={
                ("v1", "lst"): {"good": ValidationStatus.VALID}
            },
        )
        catalog = {
            **SATELLITE_CATALOG,
            "SAT_LST_OTHER": second_product,
        }
        report = assess_calibration_readiness(
            [
                satellite_record(source_observation_id="shared-id"),
                satellite_record(
                    id="sat-other",
                    source_product="SAT_LST_OTHER",
                    source_observation_id="shared-id",
                    observation_datetime="2024-06-08T04:00:00Z",
                ),
                satellite_record(
                    id="sat-other-dataset",
                    source_dataset_id="sat-dataset-2",
                    source_observation_id="shared-id",
                    observation_datetime="2024-06-08T05:00:00Z",
                ),
            ],
            [],
            satellite_product_catalog=catalog,
            reference_product_catalog=REFERENCE_CATALOG,
            config=config(),
        )

        self.assertEqual(report.exclusion_reasons.get(
            "duplicate_source_observation_id", 0
        ), 0)

    def test_duplicate_reference_source_ids_are_preserved_and_excluded(self):
        report = self.assess(
            [satellite_record()],
            [
                reference_record(
                    id="ref-row-1",
                    source_observation_id="same-reference-id",
                ),
                reference_record(
                    id="ref-row-2",
                    source_observation_id="same-reference-id",
                    latitude=-7.949,
                    observation_datetime="2024-06-08T03:20:00Z",
                ),
            ],
        )

        self.assertEqual(report.matched_pairs, ())
        duplicate_exclusions = [
            item
            for item in report.unmatched_reference_observations
            if "duplicate_source_observation_id" in item.reasons
        ]
        self.assertEqual(len(duplicate_exclusions), 2)
        self.assertEqual(report.total_reference_observations, 2)

    def test_minimum_pair_count_uses_distinct_source_observations(self):
        report = self.assess(
            [
                satellite_record(
                    id="sat-row-1",
                    source_observation_id="same-source-id",
                    observation_datetime="2024-06-08T03:00:00Z",
                ),
                satellite_record(
                    id="sat-row-2",
                    source_observation_id="same-source-id",
                    latitude=-7.949,
                    observation_datetime="2024-06-08T03:20:00Z",
                ),
            ],
            [
                reference_record(
                    source_observation_id="ref-source-1",
                    observation_datetime="2024-06-08T03:00:00Z",
                ),
                reference_record(
                    id="ref-row-2",
                    source_observation_id="ref-source-2",
                    latitude=-7.949,
                    observation_datetime="2024-06-08T03:20:00Z",
                ),
            ],
            settings=config(minimum=2),
        )

        self.assertEqual(len(report.matched_pairs), 0)
        self.assertEqual(
            report.readiness_status,
            CalibrationReadinessStatus.NOT_READY,
        )

    def test_missing_source_observation_id_is_reported_as_limitation(self):
        report = self.assess(
            [satellite_record(source_observation_id=None)],
            [reference_record()],
        )

        self.assertEqual(report.matched_pairs, ())
        self.assertEqual(
            report.missing_metadata_counts["satellite.source_observation_id"],
            1,
        )
        self.assertIn(
            "source_observation_identity_unavailable",
            report.unmatched_satellite_observations[0].reasons,
        )

    def test_missing_source_dataset_id_is_reported_as_limitation(self):
        report = self.assess(
            [satellite_record(source_dataset_id=None)],
            [reference_record()],
        )

        self.assertEqual(report.matched_pairs, ())
        self.assertEqual(
            report.missing_metadata_counts["satellite.source_dataset_id"],
            1,
        )
        self.assertIn(
            "source_observation_identity_unavailable",
            report.unmatched_satellite_observations[0].reasons,
        )

    def test_malformed_records_are_excluded_without_crashing(self):
        for malformed in (None, "not-a-record", 42, ["not", "a", "mapping"]):
            with self.subTest(malformed=malformed):
                report = self.assess([malformed], [reference_record()])

                self.assertEqual(report.total_satellite_observations, 1)
                self.assertEqual(report.invalid_observations, 1)
                self.assertEqual(report.matched_pairs, ())
                self.assertIn(
                    "malformed_record",
                    report.unmatched_satellite_observations[0].reasons,
                )
                self.assertIn(
                    "validation_invalid",
                    report.unmatched_satellite_observations[0].reasons,
                )

    def test_valid_mapping_is_reported_alongside_malformed_records(self):
        report = self.assess(
            [satellite_record(), None, "invalid"],
            [reference_record()],
        )

        self.assertEqual(report.total_satellite_observations, 3)
        self.assertEqual(report.invalid_observations, 2)
        self.assertEqual(len(report.matched_pairs), 1)
        self.assertEqual(len(report.unmatched_satellite_observations), 2)

    def test_validation_status_counts_separate_invalid_warning_and_unknown(self):
        report = self.assess(
            [
                satellite_record(observation_datetime="2024-06-08"),
                satellite_record(
                    id="sat-naive",
                    source_observation_id="sat-naive",
                    observation_datetime="2024-06-08T03:00:00",
                ),
                satellite_record(
                    id="sat-missing-time",
                    source_observation_id="sat-missing-time",
                    observation_datetime=None,
                ),
                satellite_record(
                    id="sat-invalid-time",
                    source_observation_id="sat-invalid-time",
                    observation_datetime="not-a-timestamp",
                ),
            ],
            [],
        )

        self.assertEqual(report.invalid_observations, 2)
        self.assertEqual(report.warning_observations, 1)
        self.assertEqual(report.unknown_observations, 1)
        self.assertEqual(report.valid_observations, 0)
        self.assertEqual(
            report.invalid_observations
            + report.warning_observations
            + report.unknown_observations
            + report.valid_observations,
            report.total_satellite_observations
            + report.total_reference_observations,
        )

    def test_timezone_offsets_are_compared_as_the_same_instant(self):
        report = self.assess(
            [satellite_record(observation_datetime="2024-06-08T03:00:00Z")],
            [
                reference_record(
                    observation_datetime="2024-06-08T05:00:00+02:00"
                )
            ],
        )

        self.assertEqual(len(report.matched_pairs), 1)
        self.assertEqual(
            report.matched_pairs[0].time_difference_seconds,
            0,
        )

    def test_different_measurands_are_not_matched(self):
        report = self.assess(
            [satellite_record(measurand="land_surface_temperature")],
            [reference_record(measurand="air_temperature")],
        )

        self.assertEqual(report.matched_pairs, ())
        self.assertEqual(report.readiness_status, CalibrationReadinessStatus.NOT_READY)
        self.assertIn(
            "measurand_mismatch",
            report.exclusion_reasons,
        )

    def test_incompatible_candidate_does_not_hide_a_later_compatible_pair(self):
        report = self.assess(
            [satellite_record()],
            [
                reference_record(
                    id="wrong-measurand",
                    source_observation_id="wrong-measurand-source",
                    measurand="air_temperature",
                    latitude=-7.949,
                ),
                reference_record(
                    id="compatible",
                    source_observation_id="compatible-source",
                    latitude=-7.951,
                ),
            ],
        )

        self.assertEqual(len(report.matched_pairs), 1)
        self.assertEqual(
            report.matched_pairs[0].reference_record_id,
            "compatible",
        )

    def test_different_units_are_not_converted_or_matched(self):
        report = self.assess(
            [satellite_record()],
            [reference_record(temperature_unit="Kelvin", temperature_value=303.65)],
        )

        self.assertEqual(report.matched_pairs, ())
        self.assertIn("unit_mismatch", report.exclusion_reasons)

    def test_different_measurand_definitions_are_not_matched(self):
        report = self.assess(
            [satellite_record()],
            [
                reference_record(
                    measurand_definition_reference="air-temperature-definition"
                )
            ],
        )

        self.assertEqual(report.matched_pairs, ())
        self.assertIn(
            "measurand_definition_mismatch",
            report.exclusion_reasons,
        )

    def test_missing_timestamps_are_excluded(self):
        report = self.assess(
            [
                satellite_record(
                    observation_datetime=None,
                    created_at="2024-06-08T03:00:00Z",
                )
            ],
            [reference_record()],
        )

        self.assertEqual(report.matched_pairs, ())
        self.assertEqual(report.invalid_observations, 1)
        self.assertIn(
            "validation_invalid",
            report.unmatched_satellite_observations[0].reasons,
        )

    def test_naive_timestamp_is_not_assumed_to_be_utc(self):
        report = self.assess(
            [satellite_record(observation_datetime="2024-06-08T03:00:00")],
            [reference_record()],
        )

        self.assertEqual(report.matched_pairs, ())
        self.assertIn("validation_unknown", report.exclusion_reasons)

    def test_spatial_mismatch_is_excluded(self):
        report = self.assess(
            [satellite_record()],
            [reference_record(latitude=-7.97, longitude=112.66)],
        )

        self.assertEqual(report.matched_pairs, ())
        self.assertIn("spatial_tolerance_exceeded", report.exclusion_reasons)

    def test_temporal_mismatch_is_excluded(self):
        report = self.assess(
            [satellite_record()],
            [reference_record(observation_datetime="2024-06-08T06:00:00Z")],
        )

        self.assertEqual(report.matched_pairs, ())
        self.assertIn("temporal_tolerance_exceeded", report.exclusion_reasons)

    def test_invalid_qa_status_is_excluded(self):
        report = self.assess(
            [satellite_record(quality_flag="bad")],
            [reference_record()],
        )

        self.assertEqual(report.matched_pairs, ())
        self.assertEqual(report.invalid_observations, 1)
        self.assertIn("validation_invalid", report.exclusion_reasons)

    def test_missing_provenance_is_counted_and_excluded(self):
        report = self.assess(
            [satellite_record(source_product=None)],
            [reference_record()],
        )

        self.assertEqual(report.matched_pairs, ())
        self.assertGreater(
            report.missing_metadata_counts.get(
                "satellite.source_product", 0
            ),
            0,
        )
        self.assertIn("validation_unknown", report.exclusion_reasons)

    def test_missing_footprint_compatibility_is_not_inferred_from_coordinates(self):
        report = self.assess(
            [satellite_record(footprint_compatibility_id=None)],
            [reference_record()],
        )

        self.assertEqual(report.matched_pairs, ())
        self.assertIn(
            "missing_footprint_compatibility_id",
            report.exclusion_reasons,
        )

    def test_missing_measurand_documentation_blocks_matching(self):
        report = self.assess(
            [
                satellite_record(
                    measurand_definition_reference=None,
                )
            ],
            [reference_record()],
        )

        self.assertEqual(report.matched_pairs, ())
        self.assertIn(
            "missing_measurand_definition_reference",
            report.exclusion_reasons,
        )

    def test_empty_datasets_are_not_ready(self):
        report = self.assess([], [])

        self.assertEqual(report.total_satellite_observations, 0)
        self.assertEqual(report.total_reference_observations, 0)
        self.assertEqual(report.readiness_status, CalibrationReadinessStatus.NOT_READY)

    def test_nonempty_but_insufficient_pairs_are_partially_ready(self):
        report = self.assess(
            [satellite_record()],
            [reference_record()],
            settings=config(minimum=2),
        )

        self.assertEqual(report.readiness_status,
                         CalibrationReadinessStatus.PARTIALLY_READY)
        self.assertEqual(len(report.matched_pairs), 1)

    def test_readiness_requires_documented_reference_independence(self):
        report = self.assess(
            [satellite_record()],
            [reference_record(reference_independence_basis=None)],
        )

        self.assertEqual(report.readiness_status, CalibrationReadinessStatus.NOT_READY)
        self.assertIn(
            "missing_reference_independence_basis",
            report.exclusion_reasons,
        )

    def test_counts_and_unmatched_reasons_are_consistent(self):
        report = self.assess(
            [
                satellite_record(),
                satellite_record(
                    id="sat-2",
                    source_observation_id="sat-source-2",
                    observation_datetime="2024-06-08T06:00:00Z",
                ),
            ],
            [reference_record()],
        )

        self.assertEqual(report.total_satellite_observations, 2)
        self.assertEqual(report.total_reference_observations, 1)
        self.assertEqual(len(report.matched_pairs), 1)
        self.assertEqual(len(report.unmatched_satellite_observations), 1)
        self.assertEqual(
            len(report.matched_pairs)
            + len(report.unmatched_satellite_observations),
            report.total_satellite_observations,
        )
        self.assertEqual(
            len(report.matched_pairs)
            + len(report.unmatched_reference_observations),
            report.total_reference_observations,
        )

    def test_one_to_one_matching_maximizes_pair_count(self):
        settings = CalibrationConfig(
            max_spatial_distance_meters=500,
            max_temporal_difference_seconds=1200,
            minimum_matched_pairs=2,
        )
        report = self.assess(
            [
                satellite_record(
                    id="sat-early",
                    source_observation_id="sat-source-early",
                ),
                satellite_record(
                    id="sat-late",
                    source_observation_id="sat-source-late",
                    latitude=-7.9495,
                    observation_datetime="2024-06-08T03:20:00Z",
                ),
            ],
            [
                reference_record(
                    id="ref-late",
                    source_observation_id="ref-source-late",
                    observation_datetime="2024-06-08T03:20:00Z",
                ),
                reference_record(
                    id="ref-early",
                    source_observation_id="ref-source-early",
                    latitude=-7.951,
                    observation_datetime="2024-06-08T02:50:00Z",
                ),
            ],
            settings=settings,
        )

        self.assertEqual(len(report.matched_pairs), 2)
        self.assertEqual(report.readiness_status, CalibrationReadinessStatus.READY)


if __name__ == "__main__":
    unittest.main()
