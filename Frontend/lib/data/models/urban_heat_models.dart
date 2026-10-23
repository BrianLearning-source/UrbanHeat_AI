import '../../features/urban_heat/domain/entities/environmental_indicator.dart';
import '../../features/urban_heat/domain/entities/hotspot.dart';
import '../../features/urban_heat/domain/entities/mitigation.dart';
import '../../features/urban_heat/domain/entities/shap_dimension.dart';
import '../../features/urban_heat/domain/entities/shap_factor.dart';

// Transitional aliases keep the existing presentation compiling while the
// feature is migrated. These are domain entities, not data models.
typedef HotspotItem = Hotspot;
typedef EnvIndicatorItem = EnvironmentalIndicator;
typedef ShapFactorItem = ShapFactor;
typedef ShapDimensionItem = ShapDimension;
typedef MitigationItem = Mitigation;
