class HeatmapObservation {
  const HeatmapObservation({
    required this.id,
    required this.date,
    required this.latitude,
    required this.longitude,
    required this.lst,
    this.ndvi,
  });

  final int id;
  final DateTime date;
  final double latitude;
  final double longitude;
  final double lst;
  final double? ndvi;

  String get dateKey =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  static HeatmapObservation? tryParse(Map<String, dynamic> row) {
    final id = int.tryParse(row['id']?.toString() ?? '');
    final date = DateTime.tryParse(row['date']?.toString() ?? '');
    final latitude = _finiteDouble(row['latitude']);
    final longitude = _finiteDouble(row['longitude']);
    final lst = _finiteDouble(row['lst']);

    if (id == null ||
        date == null ||
        latitude == null ||
        longitude == null ||
        lst == null ||
        latitude < -90 ||
        latitude > 90 ||
        longitude < -180 ||
        longitude > 180) {
      return null;
    }

    return HeatmapObservation(
      id: id,
      date: DateTime.utc(date.year, date.month, date.day),
      latitude: latitude,
      longitude: longitude,
      lst: lst,
      ndvi: _finiteDouble(row['ndvi']),
    );
  }

  static double? _finiteDouble(Object? value) {
    final parsed = value is num ? value.toDouble() : double.tryParse('$value');
    return parsed != null && parsed.isFinite ? parsed : null;
  }
}
