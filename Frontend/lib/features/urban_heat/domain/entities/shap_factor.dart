/// A factor and its relative contribution shown in the analysis.
class ShapFactor {
  const ShapFactor({
    required this.title,
    required this.percentage,
    required this.impactLabel,
  });

  final String title;
  final int percentage;
  final String impactLabel;
}
