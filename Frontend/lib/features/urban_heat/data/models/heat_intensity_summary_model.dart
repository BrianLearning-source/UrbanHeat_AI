import '../../domain/entities/heat_intensity_summary.dart';

class HeatIntensitySummaryModel {
  const HeatIntensitySummaryModel({
    required this.scope,
    required this.areaName,
    required this.lstCelsius,
    required this.intensityLevel,
    required this.lowerThresholdCelsius,
    required this.higherThresholdCelsius,
    required this.scaleMinCelsius,
    required this.scaleMaxCelsius,
    required this.modelVersion,
    required this.source,
    required this.isDummy,
    required this.generatedAt,
  });

  final String scope;
  final String areaName;

  final double lstCelsius;
  final HeatIntensityLevel intensityLevel;

  final double lowerThresholdCelsius;
  final double higherThresholdCelsius;

  final double scaleMinCelsius;
  final double scaleMaxCelsius;

  final String modelVersion;
  final String source;
  final bool isDummy;

  final DateTime generatedAt;

  factory HeatIntensitySummaryModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final level = json['intensity_level'] as String;

    final HeatIntensityLevel intensityLevel;

    switch (level) {
      case 'LOWER':
        intensityLevel = HeatIntensityLevel.lower;
        break;

      case 'MODERATE':
        intensityLevel = HeatIntensityLevel.moderate;
        break;

      case 'HIGHER':
        intensityLevel = HeatIntensityLevel.higher;
        break;

      default:
        throw FormatException(
          'Unknown heat intensity level: $level',
        );
    }

    return HeatIntensitySummaryModel(
      scope: json['scope'] as String,
      areaName: json['area_name'] as String,

      lstCelsius: (json['lst_celsius'] as num).toDouble(),
      intensityLevel: intensityLevel,

      lowerThresholdCelsius:
          (json['lower_threshold_celsius'] as num).toDouble(),

      higherThresholdCelsius:
          (json['higher_threshold_celsius'] as num).toDouble(),

      scaleMinCelsius:
          (json['scale_min_celsius'] as num).toDouble(),

      scaleMaxCelsius:
          (json['scale_max_celsius'] as num).toDouble(),

      modelVersion: json['model_version'] as String,
      source: json['source'] as String,
      isDummy: json['is_dummy'] as bool,

      generatedAt: DateTime.parse(
        json['generated_at'] as String,
      ),
    );
  }

  HeatIntensitySummary toEntity() {
    return HeatIntensitySummary(
      scope: scope,
      areaName: areaName,
      lstCelsius: lstCelsius,
      intensityLevel: intensityLevel,
      lowerThresholdCelsius: lowerThresholdCelsius,
      higherThresholdCelsius: higherThresholdCelsius,
      scaleMinCelsius: scaleMinCelsius,
      scaleMaxCelsius: scaleMaxCelsius,
      modelVersion: modelVersion,
      source: source,
      isDummy: isDummy,
      generatedAt: generatedAt,
    );
  }
}
