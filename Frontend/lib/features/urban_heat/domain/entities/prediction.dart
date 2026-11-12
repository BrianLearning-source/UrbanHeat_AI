
class Prediction {
  const Prediction({
    required this.latitude,
    required this.longitude,
    required this.date,
    required this.predictedLstCelsius,
    required this.baseValueCelsius,
    required this.riskLevel,
    required this.factors,
    required this.dimensions,
    required this.mitigations,
    required this.modelVersion,
    required this.isDummy,
    required this.generatedAt,
  });

  final double latitude;
  final double longitude;
  final DateTime date;
  final double predictedLstCelsius;
  final double baseValueCelsius;
  final String riskLevel;
  final List<PredictionFactor> factors;
  final List<PredictionDimension> dimensions;
  final List<PredictionMitigation> mitigations;
  final String modelVersion;
  final bool isDummy;
  final DateTime generatedAt;
}

class PredictionFactor {
  const PredictionFactor({
    required this.feature,
    required this.title,
    required this.value,
    required this.contributionCelsius,
    required this.percentage,
    required this.direction,
    required this.impactLabel,
  });

  final String feature;
  final String title;
  final double value;
  final double contributionCelsius;
  final int percentage;
  final String direction;
  final String impactLabel;
}

class PredictionDimension {
  const PredictionDimension({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.description,
  });

  final String title;
  final String subtitle;
  final String badge;
  final String description;
}

class PredictionMitigation {
  const PredictionMitigation({
    required this.category,
    required this.title,
    required this.target,
    required this.impact,
    required this.description,
    required this.badge,
    required this.details,
    required this.categoryCode,
    required this.relatedFeature,
  });

  final String category;
  final String title;
  final String target;
  final String impact;
  final String description;
  final String badge;
  final String details;
  final String categoryCode;
  final String relatedFeature;
}
