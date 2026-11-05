import unittest
from datetime import datetime, timezone

from temperature_validation import (
    ProductSpec,
    ValidationStatus,
    validate_temperature_records,
)


PRODUCT_CATALOG = {
    "TEST_LST": ProductSpec(
        versions=frozenset({"v1"}),
        bands=frozenset({"surface_temperature"}),
        temperature_units=frozenset({"Celsius"}),
        scale_metadata={
            ("v1", "surface_temperature"): (1.0, 0.0),
        },
        quality_flag_statuses={
            ("v1", "surface_temperature"): {
                "good": ValidationStatus.VALID,
                "bad": ValidationStatus.INVALID,
            },
        },
    )
}


def valid_record(**overrides):
    record = {
        "id": 7,
        "temperature_value": 31.5,
        "latitude": -7.95,
        "longitude": 112.63,
        "observation_datetime": "2024-06-08T03:00:00Z",
        "temperature_unit": "Celsius",
        "source_product": "TEST_LST",
        "product_version": "v1",
        "source_band": "surface_temperature",
        "raw_or_scaled": "scaled",
        "scale_factor": 1.0,
        "scale_offset": 0.0,
        "quality_flag": "good",
        "processing_version": "pipeline-1",
    }
    record.update(overrides)
    return record


class TemperatureValidationTests(unittest.TestCase):
    def validate(self, records):
        return validate_temperature_records(
            records,
            product_catalog=PRODUCT_CATALOG,
        )

    def test_valid_record(self):
        report = self.validate([valid_record()])

        self.assertEqual(report.total_records, 1)
        self.assertEqual(report.valid_records, 1)
        self.assertEqual(report.records[0].status, ValidationStatus.VALID)
        self.assertEqual(report.records[0].issues, ())

    def test_missing_unit_is_unknown_and_counted(self):
        report = self.validate([valid_record(temperature_unit=None)])

        self.assertEqual(report.unknown_records, 1)
        self.assertEqual(report.missing_metadata_counts["temperature_unit"], 1)
        self.assertIn(
            "unknown_temperature_unit",
            {issue.code for issue in report.records[0].issues},
        )

    def test_scale_metadata_must_match_trusted_specification(self):
        wrong_factor = self.validate([valid_record(scale_factor=0.5)])
        wrong_offset = self.validate([valid_record(scale_offset=273.15)])

        self.assertEqual(wrong_factor.unknown_records, 1)
        self.assertEqual(wrong_offset.unknown_records, 1)
        for report in (wrong_factor, wrong_offset):
            self.assertIn(
                "scale_metadata_mismatch",
                {issue.code for issue in report.records[0].issues},
            )

    def test_missing_scale_metadata_is_unknown(self):
        report = self.validate([valid_record(scale_factor=None)])

        self.assertEqual(report.unknown_records, 1)
        self.assertIn(
            "missing_or_invalid_scale_factor",
            {issue.code for issue in report.records[0].issues},
        )

    def test_product_without_scale_specification_is_unknown(self):
        catalog_without_scale = {
            "TEST_LST": ProductSpec(
                versions=frozenset({"v1"}),
                bands=frozenset({"surface_temperature"}),
                temperature_units=frozenset({"Celsius"}),
                quality_flag_statuses=PRODUCT_CATALOG[
                    "TEST_LST"
                ].quality_flag_statuses,
            )
        }
        report = validate_temperature_records(
            [valid_record()],
            product_catalog=catalog_without_scale,
        )

        self.assertEqual(report.unknown_records, 1)
        self.assertIn(
            "scale_specification_unavailable",
            {issue.code for issue in report.records[0].issues},
        )

    def test_valid_supported_scale_metadata_is_accepted(self):
        report = self.validate([valid_record(scale_factor=1, scale_offset=0)])

        self.assertEqual(report.valid_records, 1)

    def test_quality_flag_is_interpreted_by_product_specification(self):
        valid = self.validate([valid_record(quality_flag="good")])
        invalid = self.validate([valid_record(quality_flag="bad")])
        missing = self.validate([valid_record(quality_flag=None)])
        unsupported = self.validate(
            [valid_record(quality_flag="not-in-the-spec")]
        )

        self.assertEqual(valid.valid_records, 1)
        self.assertEqual(invalid.invalid_records, 1)
        self.assertIn(
            "quality_flag_rejected",
            {issue.code for issue in invalid.records[0].issues},
        )
        self.assertEqual(missing.unknown_records, 1)
        self.assertEqual(
            missing.missing_metadata_counts["quality_flag"], 1
        )
        self.assertEqual(unsupported.unknown_records, 1)
        self.assertIn(
            "unsupported_quality_flag",
            {issue.code for issue in unsupported.records[0].issues},
        )

    def test_qa_without_product_specific_interpretation_is_unknown(self):
        catalog_without_qa = {
            "TEST_LST": ProductSpec(
                versions=frozenset({"v1"}),
                bands=frozenset({"surface_temperature"}),
                temperature_units=frozenset({"Celsius"}),
                scale_metadata=PRODUCT_CATALOG[
                    "TEST_LST"
                ].scale_metadata,
            )
        }
        report = validate_temperature_records(
            [valid_record()],
            product_catalog=catalog_without_qa,
        )

        self.assertEqual(report.unknown_records, 1)
        self.assertIn(
            "quality_flag_interpretation_unavailable",
            {issue.code for issue in report.records[0].issues},
        )

    def test_quality_flag_input_value_is_preserved(self):
        record = valid_record(quality_flag="good")

        self.validate([record])

        self.assertEqual(record["quality_flag"], "good")

    def test_missing_observation_date_is_invalid(self):
        report = self.validate([valid_record(observation_datetime=None)])

        self.assertEqual(report.invalid_records, 1)
        self.assertEqual(
            report.missing_metadata_counts["observation_datetime"], 1
        )
        self.assertIn(
            "missing_observation_datetime",
            {issue.code for issue in report.records[0].issues},
        )

    def test_missing_temperature_value_is_invalid(self):
        report = self.validate([valid_record(temperature_value=None)])

        self.assertEqual(report.invalid_records, 1)
        self.assertIn(
            "missing_temperature_value",
            {issue.code for issue in report.records[0].issues},
        )

    def test_invalid_coordinates_are_rejected(self):
        report = self.validate(
            [valid_record(latitude=91, longitude=float("nan"))]
        )

        self.assertEqual(report.invalid_records, 1)
        self.assertTrue(
            {"latitude_out_of_bounds", "invalid_longitude"}.issubset(
                {issue.code for issue in report.records[0].issues}
            )
        )

    def test_non_finite_temperature_is_rejected(self):
        report = self.validate([valid_record(temperature_value=float("inf"))])

        self.assertEqual(report.invalid_records, 1)
        self.assertIn(
            "invalid_temperature_value",
            {issue.code for issue in report.records[0].issues},
        )

    def test_duplicate_observations_are_flagged_without_dropping_rows(self):
        first = valid_record(id=1)
        second = valid_record(
            id=2,
            observation_datetime=datetime(
                2024, 6, 8, 3, 0, tzinfo=timezone.utc
            ),
            temperature_value=32.0,
        )
        report = self.validate([first, second])

        self.assertEqual(report.total_records, 2)
        self.assertEqual(report.duplicate_key_count, 1)
        self.assertEqual(report.duplicate_record_count, 2)
        self.assertEqual(report.warning_records, 2)
        for record in report.records:
            self.assertEqual(record.status, ValidationStatus.WARNING)
            self.assertIn(
                "duplicate_date_coordinate_key",
                {issue.code for issue in record.issues},
            )

    def test_equivalent_utc_instants_are_duplicate_observations(self):
        report = self.validate(
            [
                valid_record(observation_datetime="2024-06-08T03:00:00Z"),
                valid_record(
                    observation_datetime="2024-06-08T05:00:00+02:00"
                ),
            ]
        )

        self.assertEqual(report.duplicate_key_count, 1)
        self.assertEqual(report.duplicate_record_count, 2)

    def test_negative_utc_offset_is_normalized_to_utc(self):
        report = self.validate(
            [
                valid_record(observation_datetime="2024-06-08T03:00:00Z"),
                valid_record(
                    observation_datetime="2024-06-07T22:00:00-05:00"
                ),
            ]
        )

        self.assertEqual(report.duplicate_key_count, 1)

    def test_naive_datetime_is_unknown_not_assumed_utc(self):
        report = self.validate(
            [valid_record(observation_datetime="2024-06-08T03:00:00")]
        )

        self.assertEqual(report.unknown_records, 1)
        self.assertIn(
            "timezone_naive_datetime",
            {issue.code for issue in report.records[0].issues},
        )

    def test_same_coordinates_at_different_times_are_not_duplicates(self):
        report = self.validate(
            [
                valid_record(observation_datetime="2024-06-08T03:00:00Z"),
                valid_record(observation_datetime="2024-06-08T04:00:00Z"),
            ]
        )

        self.assertEqual(report.duplicate_key_count, 0)
        self.assertEqual(report.total_records, 2)

    def test_same_time_from_different_products_are_not_duplicates(self):
        report = self.validate(
            [
                valid_record(),
                valid_record(source_product="OTHER_PRODUCT"),
            ]
        )

        self.assertEqual(report.duplicate_key_count, 0)

    def test_same_time_from_different_bands_are_not_duplicates(self):
        report = self.validate(
            [
                valid_record(),
                valid_record(source_band="other_band"),
            ]
        )

        self.assertEqual(report.duplicate_key_count, 0)

    def test_same_time_from_different_versions_are_not_duplicates(self):
        report = self.validate(
            [
                valid_record(),
                valid_record(product_version="v2"),
            ]
        )

        self.assertEqual(report.duplicate_key_count, 0)

    def test_missing_product_or_band_is_not_grouped_as_duplicate(self):
        for field in ("source_product", "source_band"):
            with self.subTest(field=field):
                report = self.validate(
                    [valid_record(**{field: None}), valid_record(**{field: None})]
                )

                self.assertEqual(report.duplicate_key_count, 0)
                self.assertEqual(report.total_records, 2)

    def test_timezone_aware_utc_value_remains_valid(self):
        report = self.validate(
            [valid_record(observation_datetime="2024-06-08T03:00:00Z")]
        )

        self.assertEqual(report.valid_records, 1)

    def test_multiple_issues_follow_status_precedence_and_counts(self):
        report = self.validate(
            [
                valid_record(
                    temperature_value=float("inf"),
                    temperature_unit=None,
                ),
                valid_record(temperature_unit=None, quality_flag="good"),
                valid_record(temperature_value=101.0),
            ]
        )

        self.assertEqual(report.invalid_records, 1)
        self.assertEqual(report.unknown_records, 1)
        self.assertEqual(report.warning_records, 1)
        self.assertEqual(
            report.valid_records
            + report.invalid_records
            + report.warning_records
            + report.unknown_records,
            report.total_records,
        )
        self.assertEqual(
            [record.status for record in report.records],
            [
                ValidationStatus.INVALID,
                ValidationStatus.UNKNOWN,
                ValidationStatus.WARNING,
            ],
        )

    def test_duplicate_group_counts_exclude_distinct_semantics(self):
        report = self.validate(
            [
                valid_record(id=1),
                valid_record(id=2),
                valid_record(id=3, observation_datetime="2024-06-08T04:00:00Z"),
                valid_record(id=4, source_band="other_band"),
            ]
        )

        self.assertEqual(report.duplicate_key_count, 1)
        self.assertEqual(report.duplicate_record_count, 2)
        self.assertEqual(report.total_records, 4)

    def test_unknown_product_provenance_is_not_marked_valid(self):
        report = self.validate(
            [valid_record(source_product="UNVERIFIED_PRODUCT")]
        )

        self.assertEqual(report.unknown_records, 1)
        self.assertIn(
            "unknown_source_product",
            {issue.code for issue in report.records[0].issues},
        )

    def test_missing_product_catalog_keeps_provenance_unknown(self):
        report = validate_temperature_records([valid_record()])

        self.assertEqual(report.unknown_records, 1)
        self.assertIn(
            "product_catalog_unavailable",
            {issue.code for issue in report.records[0].issues},
        )

    def test_raw_values_are_not_converted(self):
        raw = valid_record(
            raw_or_scaled="raw",
            temperature_unit="DN",
            temperature_value=15000,
        )
        report = self.validate([raw])

        self.assertEqual(report.unknown_records, 1)
        self.assertEqual(report.records[0].status, ValidationStatus.UNKNOWN)
        self.assertIn(
            "raw_value_not_interpreted",
            {issue.code for issue in report.records[0].issues},
        )
        self.assertEqual(report.to_dict()["total_records"], 1)

    def test_suspicious_range_is_warning_and_does_not_change_value(self):
        report = self.validate([valid_record(temperature_value=101.0)])

        self.assertEqual(report.warning_records, 1)
        self.assertIn(
            "suspicious_temperature_range",
            {issue.code for issue in report.records[0].issues},
        )

    def test_existing_table_fields_can_be_mapped_without_assuming_metadata(self):
        record = {
            "id": 1,
            "lst": 25.0,
            "latitude": -7.95,
            "longitude": 112.63,
            "date": "2024-06-08",
        }
        report = validate_temperature_records(
            [record],
            field_map={
                "temperature_value": "lst",
                "observation_datetime": "date",
            },
            product_catalog=PRODUCT_CATALOG,
        )

        self.assertEqual(report.total_records, 1)
        self.assertEqual(report.invalid_records, 0)
        self.assertEqual(report.unknown_records, 1)
        self.assertEqual(report.missing_metadata_counts["source_product"], 1)
        self.assertEqual(report.missing_metadata_counts["temperature_unit"], 1)


if __name__ == "__main__":
    unittest.main()
