enum HeatIntensityLevel {
  lower,
  moderate,
  higher,
}

class HeatIntensitySummary {
  const HeatIntensitySummary ({
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

}