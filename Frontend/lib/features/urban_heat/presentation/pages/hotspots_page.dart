import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/entities/hotspot.dart';
import '../../domain/repositories/urban_heat_repository.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../../../shared/widgets/info_card.dart';

class HotspotsPage extends StatefulWidget {
  const HotspotsPage({super.key, required this.repository});

  final UrbanHeatRepository repository;

  @override
  State<HotspotsPage> createState() => _HotspotsPageState();
}

class _HotspotsPageState extends State<HotspotsPage> {
  List<Hotspot> _hotspots = const [];
  bool _loading = true;
  bool _failed = false;

  int _selectedFilterIndex = 0;
  final List<String> _filters = const [
    'All',
    'Lowokwaru',
    'Klojen',
    'Blimbing',
  ];

  @override
  void initState() {
    super.initState();
    _loadHotspots();
  }

  Future<void> _loadHotspots() async {
    final result = await widget.repository.getHotspots();
    if (!mounted) return;

    setState(() {
      _hotspots = result.data ?? const [];
      _failed = result.failure != null;
      _loading = false;
    });
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
              AppTopBar(onProfileTap: () => context.go('/profile')),
              const SizedBox(height: AppSpacing.md),
              Padding(
                padding: AppSpacing.screenPaddingH,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: AppSpacing.md),
                    _buildFilterChips(),
                    const SizedBox(height: AppSpacing.md),
                    const _HotspotsMapOverview(),
                    const SizedBox(height: AppSpacing.lg),
                    if (_loading)
                      const Center(child: CircularProgressIndicator())
                    else if (_failed)
                      const Text('Unable to load hotspots.')
                    else
                      ..._hotspots.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: _HotspotClusterCard(
                            item: item,
                            onInspect: () =>
                                context.go('/hotspots/area/${item.gridId}'),
                          ),
                        ),
                      ),
                    const SizedBox(height: AppSpacing.sm),
                    SizedBox(
                      height: AppSpacing.xl + AppSpacing.lg,
                      child: ElevatedButton.icon(
                        onPressed: () => context.go('/heatmap'),
                        icon: const Icon(Icons.map_outlined),
                        label: Text(
                          'View on Heatmap',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.surface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: AppColors.surface,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: AppSpacing.roundedSm,
                          ),
                        ),
                      ),
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

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Potential Hotspots', style: AppTextStyles.pageTitle),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Areas with the highest predicted LST.',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Container(
          width: AppSpacing.xl + AppSpacing.xs,
          height: AppSpacing.xl + AppSpacing.xs,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppSpacing.roundedSm,
            border: Border.all(color: AppColors.border),
          ),
          child: const Icon(
            Icons.tune_rounded,
            color: AppColors.primary,
            size: AppSpacing.md,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_filters.length, (index) {
          final isSelected = _selectedFilterIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.xs),
            child: InkWell(
              onTap: () => setState(() => _selectedFilterIndex = index),
              borderRadius: AppSpacing.roundedSm,
              child: Container(
                height: AppSpacing.xl + AppSpacing.xs / 2,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surface,
                  borderRadius: AppSpacing.roundedSm,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Text(
                  _filters[index],
                  style: AppTextStyles.body.copyWith(
                    color: isSelected ? AppColors.surface : AppColors.primary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                  maxLines: 1,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _HotspotsMapOverview extends StatelessWidget {
  const _HotspotsMapOverview();

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: AppSpacing.roundedMd,
        child: SizedBox(
          height: AppSpacing.xl * 4 + AppSpacing.md,
          width: double.infinity,
          child: ColoredBox(
            color: AppColors.background,
            child: Stack(
              children: [
                Positioned(
                  top: AppSpacing.md,
                  left: AppSpacing.md,
                  child: Text(
                    '3 hotspot clusters',
                    style: AppTextStyles.caption,
                  ),
                ),
                const Align(
                  alignment: Alignment(-0.2, 0.05),
                  child: _MapClusterMarker(
                    number: '1',
                    color: AppColors.heatHigh,
                    temp: '35.1°C',
                  ),
                ),
                const Align(
                  alignment: Alignment(0.65, 0.15),
                  child: _MapClusterMarker(
                    number: '2',
                    color: AppColors.accent,
                    temp: '34.6°C',
                  ),
                ),
                const Align(
                  alignment: Alignment(-0.65, 0.58),
                  child: _MapClusterMarker(
                    number: '3',
                    color: AppColors.heatMedium,
                    temp: '34.2°C',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MapClusterMarker extends StatelessWidget {
  const _MapClusterMarker({
    required this.number,
    required this.color,
    required this.temp,
  });

  final String number;
  final Color color;
  final String temp;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          temp,
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
          maxLines: 1,
        ),
        Container(
          width: AppSpacing.lg + AppSpacing.xs / 2,
          height: AppSpacing.lg + AppSpacing.xs / 2,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Center(
            child: Text(
              number,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.surface,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
            ),
          ),
        ),
      ],
    );
  }
}

class _HotspotClusterCard extends StatelessWidget {
  const _HotspotClusterCard({required this.item, required this.onInspect});

  final Hotspot item;
  final VoidCallback onInspect;

  String get _title => switch (item.rank) {
    1 => 'Arterial Commercial Axis',
    2 => 'Industrial & Transit Corridor',
    3 => 'Dense Residential Sector',
    _ => item.title.replaceAll('\n', ' '),
  };

  String get _subtitle => switch (item.rank) {
    1 => 'Klojen · High NDBI, low NDVI',
    2 => 'Blimbing · High impervious',
    3 => 'Lowokwaru · Moderate-high',
    _ => '${item.district} · ${item.tag}',
  };

  String get _status =>
      item.riskLevel == 'HIGH' ? 'Potential hotspot' : 'Elevated risk';

  Color get _rankColor => switch (item.rank) {
    1 => AppColors.heatHigh,
    2 => AppColors.accent,
    _ => AppColors.heatMedium,
  };

  Color get _statusColor =>
      item.riskLevel == 'HIGH' ? AppColors.heatHigh : AppColors.heatMedium;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: AppSpacing.lg + AppSpacing.xs / 2,
                height: AppSpacing.lg + AppSpacing.xs / 2,
                decoration: BoxDecoration(
                  color: _rankColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${item.rank}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.surface,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _title,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _subtitle,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              SizedBox(
                width: AppSpacing.xl * 2 + AppSpacing.sm,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${item.temp.toStringAsFixed(1)}°C',
                      style: AppTextStyles.tabular(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                    ),
                    Text(
                      'Predicted LST',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: AppSpacing.xs,
                      height: AppSpacing.xs,
                      decoration: BoxDecoration(
                        color: _statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        _status,
                        style: AppTextStyles.caption.copyWith(
                          color: _statusColor,
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              InkWell(
                onTap: onInspect,
                borderRadius: AppSpacing.roundedSm,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  child: Text(
                    'Inspect area →',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
