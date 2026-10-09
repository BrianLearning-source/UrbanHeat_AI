// Model: bentuk data satu hotspot, bukan widget/tampilan.
class HotspotItem {
  final int rank;
  final String gridId;
  final String title;
  final String district;
  final String tag;
  final double temp;
  final String status;
  final String riskLevel;

  const HotspotItem({
    required this.rank,
    required this.gridId,
    required this.title,
    required this.district,
    required this.tag,
    required this.temp,
    required this.status,
    required this.riskLevel,
  });
}

// Model untuk indikator lingkungan yang ditampilkan di detail area.
class EnvIndicatorItem {
  final String title;
  final String subtitle;
  final String value;
  final String? valueSubtitle;

  const EnvIndicatorItem({
    required this.title,
    required this.subtitle,
    required this.value,
    this.valueSubtitle,
  });
}

// Model faktor kontribusi; persentase dipakai untuk mengisi progress bar.
class ShapFactorItem {
  final String title;
  final int percentage;
  final String impactLabel;

  const ShapFactorItem({
    required this.title,
    required this.percentage,
    required this.impactLabel,
  });
}

class ShapDimensionItem {
  final String title;
  final String subtitle;
  final String badge;
  final String description;

  const ShapDimensionItem({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.description,
  });
}

// Model satu rekomendasi mitigasi beserta sasaran dan penjelasannya.
class MitigationItem {
  final String category;
  final String title;
  final String target;
  final String impact;
  final String description;
  final String badge;
  final String details;

  const MitigationItem({
    required this.category,
    required this.title,
    required this.target,
    required this.impact,
    required this.description,
    required this.badge,
    required this.details,
  });
}

// Data statis untuk prototipe; belum diambil dari API atau database.
