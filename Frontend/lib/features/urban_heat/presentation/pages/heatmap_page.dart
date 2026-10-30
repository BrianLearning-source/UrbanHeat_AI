import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../../../shared/widgets/buttons.dart';
import '../../../../shared/widgets/info_card.dart';
import '../../data/models/heatmap_observation.dart';
import '../../data/repositories/supabase_heatmap_repository.dart';

class HeatmapPage extends StatefulWidget {
  const HeatmapPage({super.key});

  @override
  State<HeatmapPage> createState() => _HeatmapPageState();
}

class _HeatmapPageState extends State<HeatmapPage> {
  late Future<List<HeatmapObservation>> _observationsFuture;
  String? _selectedDate;
  int? _selectedObservationId;

  @override
  void initState() {
    super.initState();
    _observationsFuture = _loadObservations();
  }

  void _retry() {
    setState(() {
      _observationsFuture = _loadObservations();
    });
  }

  Future<List<HeatmapObservation>> _loadObservations() async {
    final repository = SupabaseHeatmapRepository(Supabase.instance.client);
    return repository.getObservations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppTopBar(),
              Padding(
                padding: AppSpacing.screenPaddingH,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpacing.xs),
                    Text('City Heatmap', style: AppTextStyles.pageTitle),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Observed satellite-derived Land Surface Temperature '
                      'at available locations in Kota Malang.',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    FutureBuilder<List<HeatmapObservation>>(
                      future: _observationsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return _buildLoadingState();
                        }
                        if (snapshot.hasError) {
                          return _buildErrorState(snapshot.error!);
                        }

                        final observations = snapshot.data ?? const [];
                        if (observations.isEmpty) {
                          return _buildEmptyState();
                        }
                        return _buildHeatmap(observations);
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SoftButton(
                      label: 'Simulasi Prediksi Mikro-klimat',
                      icon: Icons.analytics_outlined,
                      onPressed: () => context.go('/heatmap/prediction'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return InfoCard(
      child: SizedBox(
        height: 280,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.accent),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Loading satellite observations...',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return InfoCard(
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            size: 36,
            color: AppColors.heatHigh,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Unable to load heatmap data',
            style: AppTextStyles.sectionTitle,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            error.toString(),
            textAlign: TextAlign.center,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: _retry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return InfoCard(
      child: Column(
        children: [
          const Icon(
            Icons.location_searching_rounded,
            size: 36,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text('No mappable observations', style: AppTextStyles.sectionTitle),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'No rows with a valid date, coordinate, and LST value are '
            'available from malang_climate_pilot.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildHeatmap(List<HeatmapObservation> observations) {
    final dates =
        observations.map((observation) => observation.dateKey).toSet().toList()
          ..sort((first, second) => second.compareTo(first));
    final selectedDate = dates.contains(_selectedDate)
        ? _selectedDate!
        : dates.first;
    final dateObservations = observations
        .where((observation) => observation.dateKey == selectedDate)
        .toList();
    final selectedObservation = dateObservations.firstWhere(
      (observation) => observation.id == _selectedObservationId,
      orElse: () => dateObservations.first,
    );
    final minimumLst = observations
        .map((observation) => observation.lst)
        .reduce(math.min);
    final maximumLst = observations
        .map((observation) => observation.lst)
        .reduce(math.max);
    final earliestDate = dates.last;
    final latestDate = dates.first;
    final mapHeight = (MediaQuery.sizeOf(context).height * 0.48).clamp(
      280.0,
      420.0,
    );

    return InfoCard(
      padding: AppSpacing.cardPaddingAll,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.satellite_alt_outlined,
                color: AppColors.accent,
                size: 21,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  'Observed LST points',
                  style: AppTextStyles.sectionTitle,
                ),
              ),
              Text(
                '${dateObservations.length} points',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Choose an observation date',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          DropdownButton<String>(
            isExpanded: true,
            value: selectedDate,
            items: [
              for (final date in dates)
                DropdownMenuItem(
                  value: date,
                  child: Text(_formatDate(date), style: AppTextStyles.body),
                ),
            ],
            onChanged: (date) {
              if (date == null) return;
              setState(() {
                _selectedDate = date;
                _selectedObservationId = null;
              });
            },
          ),
          const SizedBox(height: AppSpacing.xs),
          ClipRRect(
            borderRadius: AppSpacing.roundedSm,
            child: SizedBox(
              height: mapHeight,
              child: FlutterMap(
                key: ValueKey(selectedDate),
                options: MapOptions(
                  initialCameraFit: CameraFit.bounds(
                    bounds: _boundsFor(dateObservations),
                    padding: const EdgeInsets.all(36),
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.urbanheat_ai',
                  ),
                  MarkerLayer(
                    markers: [
                      for (final observation in dateObservations)
                        _buildMarker(
                          observation,
                          minimumLst,
                          maximumLst,
                          selectedObservation.id,
                        ),
                    ],
                  ),
                  RichAttributionWidget(
                    attributions: [
                      TextSourceAttribution('© OpenStreetMap contributors'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildLegend(minimumLst, maximumLst),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: AppSpacing.cardPaddingAll,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: AppSpacing.roundedSm,
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected observation',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                _observationDetail(
                  'Date',
                  _formatDate(selectedObservation.dateKey),
                ),
                _observationDetail(
                  'LST',
                  '${selectedObservation.lst.toStringAsFixed(2)} °C',
                ),
                _observationDetail(
                  'NDVI',
                  selectedObservation.ndvi?.toStringAsFixed(3) ??
                      'Not available',
                ),
                _observationDetail(
                  'Coordinates',
                  '${selectedObservation.latitude.toStringAsFixed(5)}, '
                      '${selectedObservation.longitude.toStringAsFixed(5)}',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Data source: malang_climate_pilot. Available observations: '
            '${_formatDate(earliestDate)} – ${_formatDate(latestDate)}. '
            'This is a point-based display of historical satellite-derived '
            'observations, not a continuous raster or live feed.',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Marker _buildMarker(
    HeatmapObservation observation,
    double minimumLst,
    double maximumLst,
    int selectedObservationId,
  ) {
    final isSelected = observation.id == selectedObservationId;
    return Marker(
      point: LatLng(observation.latitude, observation.longitude),
      width: 36,
      height: 36,
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () {
              setState(() {
                _selectedObservationId = observation.id;
              });
            },
            child: Container(
              width: isSelected ? 30 : 23,
              height: isSelected ? 30 : 23,
              decoration: BoxDecoration(
                color: _lstColor(observation.lst, minimumLst, maximumLst),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: isSelected ? 3 : 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegend(double minimumLst, double maximumLst) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('LST intensity (°C)', style: AppTextStyles.caption),
        const SizedBox(height: AppSpacing.xs),
        Container(
          height: 10,
          decoration: BoxDecoration(
            borderRadius: AppSpacing.roundedFull,
            gradient: const LinearGradient(
              colors: [
                AppColors.heatLow,
                AppColors.heatMedium,
                AppColors.heatHigh,
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${minimumLst.toStringAsFixed(1)} °C · Cooler',
              style: AppTextStyles.caption,
            ),
            Text(
              '${maximumLst.toStringAsFixed(1)} °C · Warmer',
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ],
    );
  }

  Widget _observationDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 94,
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(child: Text(value, style: AppTextStyles.body)),
        ],
      ),
    );
  }

  LatLngBounds _boundsFor(List<HeatmapObservation> observations) {
    var south = observations
        .map((observation) => observation.latitude)
        .reduce(math.min);
    var north = observations
        .map((observation) => observation.latitude)
        .reduce(math.max);
    var west = observations
        .map((observation) => observation.longitude)
        .reduce(math.min);
    var east = observations
        .map((observation) => observation.longitude)
        .reduce(math.max);

    if (north - south < 0.005) {
      south = (south - 0.005).clamp(-90.0, 90.0);
      north = (north + 0.005).clamp(-90.0, 90.0);
    }
    if (east - west < 0.005) {
      west = (west - 0.005).clamp(-180.0, 180.0);
      east = (east + 0.005).clamp(-180.0, 180.0);
    }

    return LatLngBounds.fromPoints([LatLng(south, west), LatLng(north, east)]);
  }

  Color _lstColor(double value, double minimum, double maximum) {
    final fraction = maximum == minimum
        ? 0.5
        : ((value - minimum) / (maximum - minimum)).clamp(0.0, 1.0);
    if (fraction <= 0.5) {
      return Color.lerp(AppColors.heatLow, AppColors.heatMedium, fraction * 2)!;
    }
    return Color.lerp(
      AppColors.heatMedium,
      AppColors.heatHigh,
      (fraction - 0.5) * 2,
    )!;
  }

  String _formatDate(String value) {
    final date = DateTime.parse(value);
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day.toString().padLeft(2, '0')} '
        '${months[date.month - 1]} ${date.year}';
  }
}
