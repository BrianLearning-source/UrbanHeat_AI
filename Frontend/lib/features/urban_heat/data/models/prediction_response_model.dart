import '../../domain/entities/prediction.dart';

class PredictionResponseModel {
  const PredictionResponseModel({
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
  final List<PredictionFactorModel> factors;
  final List<PredictionDimensionModel> dimensions;
  final List<PredictionMitigationModel> mitigations;
  final String modelVersion;
  final bool isDummy;
  final DateTime generatedAt;

  factory PredictionResponseModel.fromJson(Map<String, dynamic> json) {
    final location = json['location'] as Map<String, dynamic>;

    return PredictionResponseModel(
      latitude: (location['latitude'] as num).toDouble(),
      longitude: (location['longitude'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      predictedLstCelsius: (json['predicted_lst_celsius'] as num).toDouble(),
      baseValueCelsius: (json['base_value_celsius'] as num).toDouble(),
      riskLevel: json['risk_level'] as String,
      factors: (json['factors'] as List)
          .map(
            (item) =>
                PredictionFactorModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      dimensions: (json['dimensions'] as List)
          .map(
            (item) =>
                PredictionDimensionModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      mitigations: (json['mitigations'] as List)
          .map(
            (item) => PredictionMitigationModel.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
      modelVersion: json['model_version'] as String,
      isDummy: json['is_dummy'] as bool,
      generatedAt: DateTime.parse(json['generated_at'] as String),
    );
  }

  Prediction toEntity() {
    return Prediction(
      latitude: latitude,
      longitude: longitude,
      date: date,
      predictedLstCelsius: predictedLstCelsius,
      baseValueCelsius: baseValueCelsius,
      riskLevel: riskLevel,
      factors: factors
          .map(
            (item) => PredictionFactor(
              feature: item.feature,
              title: item.title,
              value: item.value,
              contributionCelsius: item.contributionCelsius,
              percentage: item.percentage,
              direction: item.direction,
              impactLabel: item.impactLabel,
            ),
          )
          .toList(),
      dimensions: dimensions
          .map(
            (item) => PredictionDimension(
              title: item.title,
              subtitle: item.subtitle,
              badge: item.badge,
              description: item.description,
            ),
          )
          .toList(),
      mitigations: mitigations
          .map(
            (item) => PredictionMitigation(
              category: item.category,
              title: item.title,
              target: item.target,
              impact: item.impact,
              description: item.description,
              badge: item.badge,
              details: item.details,
              categoryCode: item.categoryCode,
              relatedFeature: item.relatedFeature,
            ),
          )
          .toList(),
      modelVersion: modelVersion,
      isDummy: isDummy,
      generatedAt: generatedAt,
    );
  }
}

class PredictionFactorModel {
  const PredictionFactorModel({
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

  factory PredictionFactorModel.fromJson(Map<String, dynamic> json) {
    return PredictionFactorModel(
      feature: json['feature'] as String,
      title: json['title'] as String,
      value: (json['value'] as num).toDouble(),
      contributionCelsius: (json['contribution_celsius'] as num).toDouble(),
      percentage: (json['percentage'] as num).toInt(),
      direction: json['direction'] as String,
      impactLabel: json['impact_label'] as String,
    );
  }
}

class PredictionDimensionModel {
  const PredictionDimensionModel({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.description,
  });

  final String title;
  final String subtitle;
  final String badge;
  final String description;

  factory PredictionDimensionModel.fromJson(Map<String, dynamic> json) {
    return PredictionDimensionModel(
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      badge: json['badge'] as String,
      description: json['description'] as String,
    );
  }
}

class PredictionMitigationModel {
  const PredictionMitigationModel({
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

  factory PredictionMitigationModel.fromJson(Map<String, dynamic> json) {
    return PredictionMitigationModel(
      category: json['category'] as String,
      title: json['title'] as String,
      target: json['target'] as String,
      impact: json['impact'] as String,
      description: json['description'] as String,
      badge: json['badge'] as String,
      details: json['details'] as String,
      categoryCode: json['category_code'] as String,
      relatedFeature: json['related_feature'] as String,
    );
  }
}
