/// A suggested measure for reducing heat exposure in an area.
class Mitigation {
  const Mitigation({
    required this.category,
    required this.title,
    required this.target,
    required this.impact,
    required this.description,
    required this.badge,
    required this.details,
  });

  final String category;
  final String title;
  final String target;
  final String impact;
  final String description;
  final String badge;
  final String details;
}
