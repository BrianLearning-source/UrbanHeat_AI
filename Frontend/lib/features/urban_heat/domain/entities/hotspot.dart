/// A business representation of a heat hotspot.
class Hotspot {
  const Hotspot({
    required this.rank,
    required this.gridId,
    required this.title,
    required this.district,
    required this.tag,
    required this.temp,
    required this.status,
    required this.riskLevel,
  });

  final int rank;
  final String gridId;
  final String title;
  final String district;
  final String tag;
  final double temp;
  final String status;
  final String riskLevel;
}
