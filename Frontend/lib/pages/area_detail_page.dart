import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/theme/app_colors.dart';
import '../app/theme/app_spacing.dart';
import '../app/theme/app_text_styles.dart';
import '../shared/widgets/info_card.dart';
import '../shared/widgets/section_title.dart';
import 'auth_widgets.dart';

class AreaDetailPage extends StatelessWidget {
  const AreaDetailPage({super.key, required this.gridId});

  final String gridId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: AppSpacing.xl),
          child: Padding(
            padding: AppSpacing.screenPaddingH,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.md),
                _buildHeader(context),
                const SizedBox(height: AppSpacing.lg),
                _AreaDetailHeroCard(gridId: gridId),
                const SizedBox(height: AppSpacing.lg),
                const _AreaDetailSpectrumSection(),
                const SizedBox(height: AppSpacing.lg),
                const _AreaDetailIndicatorsSection(),
                const SizedBox(height: AppSpacing.lg),
                _AreaDetailModelInfoSection(
                  onTap: () => context.go('/hotspots/area/$gridId/factors'),
                ),
                const SizedBox(height: AppSpacing.lg),
                AuthPrimaryButton(
                  label: 'View Suggested Mitigation Measures',
                  onPressed: () =>
                      context.go('/hotspots/area/$gridId/mitigation'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Material(
            color: AppColors.surface,
            borderRadius: AppSpacing.roundedSm,
            child: InkWell(
              onTap: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/hotspots');
                }
              },
              borderRadius: AppSpacing.roundedSm,
              child: const SizedBox(
                width: AppSpacing.xl + AppSpacing.xs,
                height: AppSpacing.xl + AppSpacing.xs,
                child: Icon(Icons.arrow_back_rounded, color: AppColors.primary),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text('Area Detail', style: AppTextStyles.pageTitle),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Satellite analysis for the selected grid.',
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          maxLines: 1,
        ),
      ],
    );
  }
}

class _AreaDetailHeroCard extends StatelessWidget {
  const _AreaDetailHeroCard({required this.gridId});

  final String gridId;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      backgroundColor: AppColors.primary,
      borderColor: AppColors.primaryLight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.location_on_rounded,
                color: AppColors.accent,
                size: AppSpacing.md,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  'Grid #$gridId · Central',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.surface,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '~34.8°C',
            style: AppTextStyles.display.copyWith(color: AppColors.surface),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Predicted Land Surface Temp (LST)',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.surface.withValues(alpha: 0.72),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              const Expanded(
                child: _HeroMetric(
                  icon: Icons.satellite_alt_rounded,
                  caption: 'Satellite pass',
                  value: 'Sentinel-2',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Expanded(
                child: _HeroMetric(
                  icon: Icons.trending_up_rounded,
                  caption: 'vs baseline',
                  value: '+3.8°C',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({
    required this.icon,
    required this.caption,
    required this.value,
  });

  final IconData icon;
  final String caption;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPaddingAll,
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.08),
        borderRadius: AppSpacing.roundedSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.surface, size: AppSpacing.md),
          const SizedBox(height: AppSpacing.xs),
          Text(
            caption,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.surface.withValues(alpha: 0.72),
            ),
            maxLines: 1,
          ),
          Text(
            value,
            style: AppTextStyles.body.copyWith(
              color: AppColors.surface,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
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
        const SectionTitle(title: 'Heat Intensity Spectrum'),
        const SizedBox(height: AppSpacing.xs),
        const InfoCard(child: _SpectrumContent()),
      ],
    );
  }
}

class _SpectrumContent extends StatelessWidget {
  const _SpectrumContent();

  static const double _markerPosition = 0.77;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: const Alignment(-1 + _markerPosition * 2, 0),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: AppSpacing.roundedFull,
            ),
            child: Text(
              'Predicted: ~34.8°C',
              style: AppTextStyles.caption.copyWith(color: AppColors.surface),
              maxLines: 1,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          height: AppSpacing.xs,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.heatLow,
                AppColors.heatMedium,
                AppColors.accent,
                AppColors.heatHigh,
              ],
            ),
            borderRadius: AppSpacing.roundedFull,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const Row(
          children: [
            Expanded(
              child: _SpectrumLegend(label: 'Lower', range: '<28°C'),
            ),
            Expanded(
              child: _SpectrumLegend(label: 'Moderate', range: '28-32°C'),
            ),
            Expanded(
              child: _SpectrumLegend(label: 'Higher', range: '>36°C'),
            ),
          ],
        ),
      ],
    );
  }
}

class _SpectrumLegend extends StatelessWidget {
  const _SpectrumLegend({required this.label, required this.range});

  final String label;
  final String range;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
          maxLines: 1,
        ),
        Text(
          range,
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
          maxLines: 1,
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
        const SectionTitle(title: 'Environmental Indicators'),
        const SizedBox(height: AppSpacing.xs),
        const InfoCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _IndicatorRow(
                icon: Icons.eco_rounded,
                title: 'NDVI',
                subtitle: 'Vegetation index',
                value: '0.19',
              ),
              _InsetDivider(),
              _IndicatorRow(
                icon: Icons.apartment_rounded,
                title: 'NDBI',
                subtitle: 'Built-up index',
                value: '0.74',
              ),
              _InsetDivider(),
              _IndicatorRow(
                icon: Icons.layers_rounded,
                title: 'Land cover',
                subtitle: 'High density area',
                value: 'Urban',
              ),
              _InsetDivider(),
              _IndicatorRow(
                icon: Icons.alt_route_rounded,
                title: 'Impervious',
                subtitle: 'Road surface',
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

class _IndicatorRow extends StatelessWidget {
  const _IndicatorRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    this.valueColor = AppColors.primary,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: AppSpacing.xl + AppSpacing.xs,
            height: AppSpacing.xl + AppSpacing.xs,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: AppSpacing.roundedSm,
            ),
            child: Icon(icon, color: AppColors.primary, size: AppSpacing.md),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(
            width: AppSpacing.xl * 2,
            child: Text(
              value,
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w600,
                color: valueColor,
              ),
              textAlign: TextAlign.end,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _InsetDivider extends StatelessWidget {
  const _InsetDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.md + AppSpacing.xl + AppSpacing.xs + AppSpacing.sm,
        right: AppSpacing.md,
      ),
      child: Divider(height: 1, thickness: 1, color: AppColors.border),
    );
  }
}

class _AreaDetailModelInfoSection extends StatelessWidget {
  const _AreaDetailModelInfoSection({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionTitle(title: 'Model info'),
        const SizedBox(height: AppSpacing.xs),
        InfoCard(
          child: Column(
            children: [
              const _ModelInfoRow(label: 'Target', value: 'LST'),
              const SizedBox(height: AppSpacing.sm),
              const _ModelInfoRow(
                label: 'Approach',
                value: 'Supervised regression',
              ),
              const SizedBox(height: AppSpacing.sm),
              const _ModelInfoRow(label: 'Data', value: 'Sentinel-2 / Landsat'),
              const SizedBox(height: AppSpacing.md),
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: onTap,
                  child: Text(
                    'Tap to view feature impact (SHAP) →',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.accent,
                    ),
                    maxLines: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ModelInfoRow extends StatelessWidget {
  const _ModelInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          flex: 2,
          child: Text(
            value,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.end,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}
