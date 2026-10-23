import '../features/urban_heat/domain/entities/environmental_indicator.dart';
import '../features/urban_heat/domain/entities/hotspot.dart';
import '../features/urban_heat/domain/entities/mitigation.dart';
import '../features/urban_heat/domain/entities/shap_dimension.dart';
import '../features/urban_heat/domain/entities/shap_factor.dart';

class MockData {
  const MockData._();

  // User Profile
  static const String userName = 'Nasywa';
  static const String userRole =
      'Urban Researcher & Environmental Planner • Kota Malang Spatial Analysis Group';
  static const String userLocation = 'Kota Malang, East Java';

  // Hotspots list
  static const List<Hotspot> hotspots = [
    Hotspot(
      rank: 1,
      gridId: 'MC-204',
      title: 'Arterial Commercial Axis\n(Central Malang)',
      district: 'Kecamatan Klojen',
      tag: 'High NDBI / Low NDVI',
      temp: 35.1,
      status: 'POTENTIAL HOTSPOT',
      riskLevel: 'HIGH',
    ),
    Hotspot(
      rank: 2,
      gridId: 'BL-102',
      title: 'Industrial & Transit Corridor',
      district: 'Kecamatan Blimbing',
      tag: 'High Impervious Surface',
      temp: 34.6,
      status: 'POTENTIAL HOTSPOT',
      riskLevel: 'HIGH',
    ),
    Hotspot(
      rank: 3,
      gridId: 'LW-A12',
      title: 'Dense Built-up Residential\nSector',
      district: 'Kecamatan Lowokwaru',
      tag: 'Moderate-High Heat',
      temp: 34.2,
      status: 'ELEVATED RISK',
      riskLevel: 'ELEVATED',
    ),
  ];

  // Environmental Indicators for Area Detail
  static const List<EnvironmentalIndicator> indicatorsMC204 = [
    EnvironmentalIndicator(
      title: 'NDVI (Vegetation Index)',
      subtitle: 'Low green canopy coverage',
      value: '0.19',
    ),
    EnvironmentalIndicator(
      title: 'NDBI (Built-up Indicator)',
      subtitle: 'Dense impervious structures',
      value: '0.74',
    ),
    EnvironmentalIndicator(
      title: 'Land Cover',
      subtitle: 'Satellite taxonomy',
      value: 'Urban Commercial',
      valueSubtitle: 'High Density',
    ),
    EnvironmentalIndicator(
      title: 'Road / Impervious',
      subtitle: 'Low permeability profile',
      value: '72%',
    ),
  ];

  // SHAP relative associations
  static const List<ShapFactor> shapFactors = [
    ShapFactor(
      title: 'Built-up Surface Area',
      percentage: 40,
      impactLabel: '+40% impact',
    ),
    ShapFactor(
      title: 'Low Canopy Deficit (NDVI)',
      percentage: 32,
      impactLabel: '+32% impact',
    ),
    ShapFactor(
      title: 'Paved Transportation Grid',
      percentage: 18,
      impactLabel: '+18% impact',
    ),
    ShapFactor(
      title: 'Historical Temperature Baseline',
      percentage: 10,
      impactLabel: '+10% impact',
    ),
  ];

  // SHAP 4 Key Dimensions
  static const List<ShapDimension> shapDimensions = [
    ShapDimension(
      title: 'Vegetation Density',
      subtitle: 'NDVI Index: 0.21',
      badge: 'Low Coverage',
      description: 'Sparse street trees and limited canopy cover across public rights-of-way reduce evaporative cooling efficiency.',
    ),
    ShapDimension(
      title: 'Built-up Surface',
      subtitle: 'Coverage: 78.4%',
      badge: 'High Density',
      description: 'High density of impervious commercial and residential structures retaining heat during solar noon peaks.',
    ),
    ShapDimension(
      title: 'Paved Road Network',
      subtitle: 'Coverage: 68.2%',
      badge: 'High Albedo Deficit',
      description: 'Extensive low-albedo asphalt roadway grid absorbing solar radiation with prolonged nocturnal release.',
    ),
    ShapDimension(
      title: 'Historical Temp Baseline',
      subtitle: 'Baseline LST: 31.0°C',
      badge: 'Mod-High',
      description: 'Consistent multi-year warming trend recorded in seasonal dry months, accelerating microclimate sensitivity.',
    ),
  ];

  // Mitigation Measures
  static const List<Mitigation> mitigations = [
    Mitigation(
      category: 'Urban Greening',
      title: 'Urban Greening & Tree Canopy',
      target: 'Dense commercial & arterial corridors',
      impact: 'Estimated surface cooling potential: -1.0°C to -1.8°C',
      description: 'Prioritize vegetative buffers along dense corridors with low NDVI. Increasing vegetation and shaded pedestrian areas may help reduce heat exposure.',
      badge: 'Recommended for low-NDVI corridors',
      details: 'Focus planting shade trees with leaf area index > 3.5 along east-west street orientations to maximize solar interception and reduce street canyons heat buildup.',
    ),
    Mitigation(
      category: 'Permeable Infrastructure',
      title: 'Permeable Pavements & Cool Surfaces',
      target: 'High-NDBI built-up commercial zones',
      impact: 'Moderate heat retention & stormwater absorption',
      description: 'Mitigation measures for high-NDBI built-up commercial zones to moderate heat retention and facilitate natural ground moisture exchange.',
      badge: 'Permeability factor: +45%',
      details: 'Retrofit interlocking porous concrete pavers in parking bays and pedestrian walkways to enhance sub-base evaporative cooling and groundwater recharge.',
    ),
    Mitigation(
      category: 'High-Albedo Roofing',
      title: 'High-Albedo Roofing Materials',
      target: 'Dense industrial/commercial rooftop clusters',
      impact: 'Mitigates solar irradiance retention',
      description: 'Supporting measures for dense industrial/commercial rooftop clusters through reflective coatings and high-albedo membrane applications.',
      badge: 'Reflectivity boost up to 70%',
      details: 'Apply elastomeric white roof coatings with solar reflectance index (SRI) >= 82 on flat commercial rooftops to reduce thermal absorption into building envelopes.',
    ),
  ];
}
