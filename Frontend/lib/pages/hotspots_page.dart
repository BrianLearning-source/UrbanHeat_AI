import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../app/theme/app_colors.dart';
import '../app/theme/app_spacing.dart';
import '../app/theme/app_text_styles.dart';
import '../data/repositories/urban_heat_repository.dart';
import '../data/models/urban_heat_models.dart';
import '../shared/widgets/app_top_bar.dart';
import '../shared/widgets/buttons.dart';
import '../shared/widgets/info_card.dart';
import '../shared/widgets/pill_badge.dart';
import '../shared/widgets/placeholder_image.dart';

class HotspotsPage extends StatefulWidget {
  const HotspotsPage({super.key});

  @override
  State<HotspotsPage> createState() => _HotspotsPageState();
}

class _HotspotsPageState extends State<HotspotsPage> {
  // Indeks filter yang dipilih, disimpan sebagai state lokal halaman.
  int _selectedFilterIndex = 0;
  final List<String> _filters = const [
    'All Kota Malang',
    'Lowokwaru',
    'Klojen',
    'Blimbing',
  ];

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
                    _buildHeader(context),
                    const SizedBox(height: AppSpacing.md),
                    _buildFilterChips(),
                    const SizedBox(height: AppSpacing.md),
                    const _HotspotsMapOverview(),
                    const SizedBox(height: AppSpacing.lg),
                    // map mengubah setiap objek hotspot menjadi satu kartu UI.
                    ...urbanHeatRepository.hotspots.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: _HotspotClusterCard(
                            item: item,
                            onInspect: () => context.go('/hotspots/area/${item.gridId}'),
                          ),
                        )),
                    const SizedBox(height: AppSpacing.sm),
                    GradientButton(
                      label: 'Select on Heatmap to View Area Detail',
                      icon: Icons.map_outlined,
                      onPressed: () => context.go('/heatmap'),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'UrbanHeat AI Research Team',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
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

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (context.canPop())
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.xs),
            child: InkWell(
              onTap: () => context.pop(),
              borderRadius: AppSpacing.roundedSm,
              child: const Padding(
                padding: EdgeInsets.all(AppSpacing.xs),
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.primary,
                  size: AppSpacing.lg,
                ),
              ),
            ),
          ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Potential Hotspots',
                style: AppTextStyles.pageTitle,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Identified areas with higher predicted Land Surface Temperature across Kota Malang',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: AppSpacing.xl,
          height: AppSpacing.xl,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppSpacing.roundedSm,
            border: Border.all(
              color: AppColors.border,
              width: 1,
            ),
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
              onTap: () {
                // setState memberi tahu Flutter bahwa pilihan berubah dan UI perlu dibangun ulang.
                setState(() {
                  _selectedFilterIndex = index;
                });
              },
              borderRadius: AppSpacing.roundedSm,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surface,
                  borderRadius: AppSpacing.roundedSm,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected) ...[
                      Container(
                        width: AppSpacing.xs,
                        height: AppSpacing.xs,
                        decoration: const BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                    ],
                    Text(
                      _filters[index],
                      style: AppTextStyles.caption.copyWith(
                        color: isSelected ? AppColors.surface : AppColors.primary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ],
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
      child: Stack(
        children: [
          const PlaceholderImage(
            height: 180,
            icon: Icons.map_outlined,
          ),
          Positioned(
            top: AppSpacing.sm,
            left: AppSpacing.sm,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.85),
                borderRadius: AppSpacing.roundedFull,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '3 HOTSPOT CLUSTERS DETECTED',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.surface,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Hotspot marker 1
          Positioned(
            left: 120,
            top: 60,
            child: _MapClusterMarker(
              number: '1',
              color: AppColors.heatHigh,
              temp: '35.1°C',
            ),
          ),
          // Hotspot marker 2
          Positioned(
            right: 80,
            bottom: 40,
            child: _MapClusterMarker(
              number: '2',
              color: AppColors.accent,
              temp: '34.6°C',
            ),
          ),
          // Hotspot marker 3
          Positioned(
            left: 60,
            bottom: 50,
            child: _MapClusterMarker(
              number: '3',
              color: AppColors.heatMedium,
              temp: '34.2°C',
            ),
          ),
          // Bottom overlay bar
          Positioned(
            bottom: AppSpacing.sm,
            left: AppSpacing.sm,
            right: AppSpacing.sm,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.9),
                borderRadius: AppSpacing.roundedSm,
                border: Border.all(
                  color: AppColors.border,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Kota Malang Spatial Scan Window',
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'High LST Distribution',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.heatHigh,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapClusterMarker extends StatelessWidget {
  final String number;
  final Color color;
  final String temp;

  const _MapClusterMarker({
    required this.number,
    required this.color,
    required this.temp,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: AppSpacing.roundedSm,
          ),
          child: Text(
            temp,
            style: AppTextStyles.tabular(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.surface,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Container(
          width: AppSpacing.lg,
          height: AppSpacing.lg,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.surface,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              number,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.surface,
                fontWeight: FontWeight.w700,
                fontSize: 10,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HotspotClusterCard extends StatelessWidget {
  final HotspotItem item;
  final VoidCallback onInspect;

  const _HotspotClusterCard({
    required this.item,
    required this.onInspect,
  });

  @override
  Widget build(BuildContext context) {
    final rankColor = item.rank == 1
        ? AppColors.heatHigh
        : item.rank == 2
            ? AppColors.accent
            : AppColors.heatMedium;

    final statusColor = item.riskLevel == 'HIGH' ? AppColors.accent : AppColors.heatMedium;

    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: AppSpacing.lg,
                height: AppSpacing.lg,
                decoration: BoxDecoration(
                  color: rankColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${item.rank}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.surface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${item.district} • ${item.tag}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${item.temp}°C',
                    style: AppTextStyles.tabular(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Predicted LST',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: PillBadge(
                  label: item.status,
                  color: statusColor,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              InkWell(
                onTap: onInspect,
                borderRadius: AppSpacing.roundedSm,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: AppSpacing.xs,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Inspect Area',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: AppSpacing.md,
                        color: AppColors.accent,
                      ),
                    ],
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
