import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/heatmap_observation.dart';

class SupabaseHeatmapRepository {
  const SupabaseHeatmapRepository(this._client);

  final SupabaseClient _client;

  Future<List<HeatmapObservation>> getObservations() async {
    final rows = await _client
        .from('malang_climate_pilot')
        .select('id,date,latitude,longitude,lst,ndvi')
        .order('date', ascending: false)
        .order('id', ascending: false);

    final observations = <HeatmapObservation>[];
    var omittedRows = 0;
    for (final row in rows) {
      final observation = HeatmapObservation.tryParse(row);
      if (observation == null) {
        omittedRows++;
      } else {
        observations.add(observation);
      }
    }

    if (omittedRows > 0) {
      debugPrint(
        'Heatmap omitted $omittedRows rows with invalid required values.',
      );
    }

    return observations;
  }
}
