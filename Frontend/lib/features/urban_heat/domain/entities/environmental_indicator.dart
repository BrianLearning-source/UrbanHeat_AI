/// An environmental measurement or classification for an area.
class EnvironmentalIndicator {
  const EnvironmentalIndicator({
    required this.title,
    required this.subtitle,
    required this.value,
    this.valueSubtitle,
  });

  final String title;
  final String subtitle;
  final String value;
  final String? valueSubtitle;
}
