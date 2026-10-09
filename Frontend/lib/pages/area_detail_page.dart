import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../app/theme/app_colors.dart';
import '../app/theme/app_spacing.dart';
import '../app/theme/app_text_styles.dart';
import '../shared/widgets/app_top_bar.dart';
import '../shared/widgets/buttons.dart';
import '../shared/widgets/heat_spectrum_bar.dart';
import '../shared/widgets/info_card.dart';
import '../shared/widgets/metric_tile.dart';
import '../shared/widgets/pill_badge.dart';
import '../shared/widgets/section_title.dart';

class AreaDetailPage extends StatelessWidget {
  final String gridId;

  const AreaDetailPage({
    super.key,
    required this.gridId,
  });

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
                    _AreaDetailHeroCard(gridId: gridId),
                    const SizedBox(height: AppSpacing.lg),
                    const _AreaDetailSpectrumSection(),
                    const SizedBox(height: AppSpacing.lg),
                    const _AreaDetailIndicatorsSection(),
                    const SizedBox(height: AppSpacing.lg),
                    _AreaDetailModelInfoCard(
                      onTap: () => context.go('/hotspots/area/$gridId/factors'),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    GradientButton(
                      label: 'View Suggested Mitigation Measures →',
                      onPressed: () => context.go('/hotspots/area/$gridId/mitigation'),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Targeted urban cooling & greening strategies for this cell',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/hotspots');
                }
              },
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
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Area Detail',
          style: AppTextStyles.pageTitle,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Spatio-temporal satellite analysis for selected grid in Kota Malang',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _AreaDetailHeroCard extends StatelessWidget {
  final String gridId;

  const _AreaDetailHeroCard({required this.gridId});

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      backgroundColor: AppColors.primary,
      borderColor: AppColors.primaryLight,
      gradient: const LinearGradient(
        colors: [
          AppColors.primary,
          AppColors.primaryLight,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      color: AppColors.accent,
                      size: AppSpacing.md,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        'GRID #$gridId • CENTRAL',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.surface,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '~34.8 °C',
                style: AppTextStyles.tabular(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: AppColors.surface,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                  '-7.9784° S, 112.6312° E',
                  style: AppTextStyles.tabular(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.surface.withValues(alpha: 0.7),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Target: Predicted Land Surface Temp (LST)',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.surface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.08),
                    borderRadius: AppSpacing.roundedSm,
                    border: Border.all(
                      color: AppColors.surface.withValues(alpha: 0.15),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.satellite_alt_rounded,
                        color: AppColors.accent,
                        size: AppSpacing.lg,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SATELLITE PASS',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.surface.withValues(alpha: 0.7),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Sentinel-2 / Landsat',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.surface,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.08),
                    borderRadius: AppSpacing.roundedSm,
                    border: Border.all(
                      color: AppColors.surface.withValues(alpha: 0.15),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.trending_up_rounded,
                        color: AppColors.mitigation,
                        size: AppSpacing.lg,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'LST ANOMALY',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.surface.withValues(alpha: 0.7),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '+3.8°C vs Baseline',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.surface,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
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

class _AreaDetailSpectrumSection extends StatelessWidget {
  const _AreaDetailSpectrumSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionTitle(
          title: 'Heat Intensity Spectrum',
          action: PillBadge(
            label: 'Continuous Range',
            color: AppColors.primaryLight,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        const InfoCard(
          child: HeatSpectrumBar(
            markerText: 'Predicted: ~34.8°C',
            markerPosition: 0.76,
            customLegend: [
              HeatSpectrumLegendItem(
                label: 'Lower LST\n<28°C',
                color: AppColors.heatLow,
              ),
              HeatSpectrumLegendItem(
                label: 'Moderate\n28–32°C',
                color: AppColors.heatMedium,
              ),
              HeatSpectrumLegendItem(
                label: 'Higher LST\n>36°C',
                color: AppColors.heatHigh,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AreaDetailIndicatorsSection extends StatelessWidget {
  const _AreaDetailIndicatorsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionTitle(
          title: 'Environmental Indicators',
          action: PillBadge(
            label: 'Spectral Features',
            color: AppColors.primaryLight,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        InfoCard(
          padding: AppSpacing.cardPaddingAll,
          child: Column(
            children: [
              MetricTile(
                icon: Icons.eco_rounded,
                label: 'NDVI (Vegetation Index)',
                subtitle: 'Low green canopy coverage',
                value: '0.19',
              ),
              const SizedBox(height: AppSpacing.xs),
              MetricTile(
                icon: Icons.apartment_rounded,
                label: 'NDBI (Built-up Indicator)',
                subtitle: 'Dense impervious structures',
                value: '0.74',
              ),
              const SizedBox(height: AppSpacing.xs),
              MetricTile(
                icon: Icons.layers_rounded,
                label: 'Land Cover',
                subtitle: 'Satellite taxonomy',
                value: 'Urban Commercial',
                valueSubtitle: 'High Density',
              ),
              const SizedBox(height: AppSpacing.xs),
              MetricTile(
                icon: Icons.alt_route_rounded,
                label: 'Road / Impervious',
                subtitle: 'Low permeability profile',
                value: '72%',
                valueColor: AppColors.accent,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AreaDetailModelInfoCard extends StatelessWidget {
  final VoidCallback onTap;

  const _AreaDetailModelInfoCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      onTap: onTap,
      padding: AppSpacing.cardPaddingAll,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: AppSpacing.xl,
                      height: AppSpacing.xl,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: AppSpacing.roundedSm,
                      ),
                      child: const Icon(
                        Icons.memory_rounded,
                        color: AppColors.primary,
                        size: AppSpacing.md,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        'Prediction & Model Info',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              const PillBadge(
                label: 'LST-XGBoost',
                color: AppColors.primaryLight,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _ModelInfoRow(label: 'Target Variable', value: 'Land Surface Temp (LST)'),
          const SizedBox(height: AppSpacing.xs),
          _ModelInfoRow(label: 'Approach', value: 'Supervised Reg (MAE, R²)'),
          const SizedBox(height: AppSpacing.xs),
          _ModelInfoRow(label: 'Observation', value: 'Sentinel-2 / Landsat'),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  'Tap to view feature impact (SHAP) →',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ModelInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _ModelInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Flexible(
          child: Text(
            value,
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
