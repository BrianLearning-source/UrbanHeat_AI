import '../mock_data.dart';
import '../models/urban_heat_models.dart';

/// Menjadi satu pintu akses data untuk halaman aplikasi.
/// Saat API tersedia, sumber data dapat diganti di repository ini.
class UrbanHeatRepository {
  const UrbanHeatRepository();

  String get userName => MockData.userName;
  String get userRole => MockData.userRole;
  String get userLocation => MockData.userLocation;
  List<HotspotItem> get hotspots => MockData.hotspots;
  List<EnvIndicatorItem> get indicatorsMC204 => MockData.indicatorsMC204;
  List<ShapFactorItem> get shapFactors => MockData.shapFactors;
  List<ShapDimensionItem> get shapDimensions => MockData.shapDimensions;
  List<MitigationItem> get mitigations => MockData.mitigations;
}

/// Satu instance repository untuk dipakai halaman saat ini.
const urbanHeatRepository = UrbanHeatRepository();
