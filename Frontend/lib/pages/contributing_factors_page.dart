import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/theme/app_colors.dart';
import '../app/theme/app_spacing.dart';
import '../app/theme/app_text_styles.dart';
import '../features/urban_heat/domain/entities/shap_dimension.dart';
import '../features/urban_heat/domain/entities/shap_factor.dart';
import '../features/urban_heat/domain/repositories/urban_heat_repository.dart';
import '../shared/widgets/app_top_bar.dart';
import '../shared/widgets/buttons.dart';
import '../shared/widgets/feature_bar_row.dart';
import '../shared/widgets/info_card.dart';
import '../shared/widgets/pill_badge.dart';
import '../shared/widgets/section_title.dart';

class ContributingFactorsPage extends StatefulWidget {
  final String gridId;
  final UrbanHeatRepository repository;

  const ContributingFactorsPage({
    super.key,
    required this.gridId,
    required this.repository,
  });

  @override
  State<ContributingFactorsPage> createState() =>
      _ContributingFactorsPageState();
}

class _ContributingFactorsPageState extends State<ContributingFactorsPage> {
  List<ShapFactor> _factors = const [];
  List<ShapDimension> _dimensions = const [];
  bool _loading = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _loadAnalysis();
  }

  Future<void> _loadAnalysis() async {
    final factors = await widget.repository.getShapFactors(widget.gridId);
    final dimensions = await widget.repository.getShapDimensions(widget.gridId);
    if (!mounted) return;

    setState(() {
      _factors = factors.data ?? const [];
      _dimensions = dimensions.data ?? const [];
      _failed = factors.failure != null || dimensions.failure != null;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final gridId = widget.gridId;
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
                    _ShapTargetSummaryCard(gridId: gridId),
                    const SizedBox(height: AppSpacing.lg),
                    if (_loading)
                      const Center(child: CircularProgressIndicator())
                    else if (_failed)
                      const Text('Unable to load contributing factors.')
                    else ...[
                      _RelativeAssociationSection(factors: _factors),
                      const SizedBox(height: AppSpacing.lg),
                      _DetailedDimensionsSection(dimensions: _dimensions),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    GradientButton(
                      label: 'Explore Mitigation Insights →',
                      onPressed: () =>
                          context.go('/hotspots/area/$gridId/mitigation'),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'AI model inference confidence: 94.2% across Kecamatan Lowokwaru sensor grid',
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
            const Icon(
              Icons.info_outline_rounded,
              color: AppColors.textSecondary,
              size: AppSpacing.lg,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text('Contributing Factors', style: AppTextStyles.pageTitle),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Environmental characteristics associated with the model prediction.',
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _ShapTargetSummaryCard extends StatelessWidget {
  final String gridId;

  const _ShapTargetSummaryCard({required this.gridId});

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      backgroundColor: AppColors.primary,
      borderColor: AppColors.primaryLight,
      gradient: const LinearGradient(
        colors: [AppColors.primary, AppColors.primaryLight],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: AppSpacing.xl,
                  height: AppSpacing.xl,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.15),
                    borderRadius: AppSpacing.roundedSm,
                  ),
                  child: const Icon(
                    Icons.grid_view_rounded,
                    color: AppColors.accent,
                    size: AppSpacing.md,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Spatial Target Grid',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.surface.withValues(alpha: 0.7),
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        'Grid #$gridId • Lowokwaru',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.surface,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Surface LST',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.surface.withValues(alpha: 0.7),
                  fontSize: 10,
                ),
              ),
              Row(
                children: [
                  Text(
                    '34.8°C',
                    style: AppTextStyles.tabular(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.surface,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  const PillBadge(
                    label: 'HIGH',
                    color: AppColors.heatHigh,
                    isDark: true,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RelativeAssociationSection extends StatelessWidget {
  const _RelativeAssociationSection({required this.factors});

  final List<ShapFactor> factors;

  @override
  Widget build(BuildContext context) {
    final colors = [
      AppColors.heatHigh,
      AppColors.heatMedium,
      AppColors.accent,
      AppColors.primaryLight,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionTitle(
          title: 'Relative Feature Association',
          subtitle: 'Marginal SHAP value allocation',
          action: const Icon(
            Icons.poll_rounded,
            color: AppColors.textSecondary,
            size: AppSpacing.lg,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        InfoCard(
          padding: AppSpacing.cardPaddingAll,
          child: Column(
            children: List.generate(factors.length, (index) {
              final factor = factors[index];
              return FeatureBarRow(
                label: factor.title,
                percentage: factor.percentage,
                impactText: factor.impactLabel,
                barColor: colors[index % colors.length],
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _DetailedDimensionsSection extends StatelessWidget {
  const _DetailedDimensionsSection({required this.dimensions});

  final List<ShapDimension> dimensions;

  @override
  Widget build(BuildContext context) {
    final icons = [
      Icons.park_rounded,
      Icons.apartment_rounded,
      Icons.alt_route_rounded,
      Icons.history_rounded,
    ];

    final badgeColors = [
      AppColors.heatHigh,
      AppColors.accent,
      AppColors.accent,
      AppColors.heatLow,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionTitle(
          title: 'Features Contributing to Prediction',
          action: Text(
            '4 key dimensions',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        ...List.generate(dimensions.length, (index) {
          final dim = dimensions[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _DimensionDetailCard(
              icon: icons[index % icons.length],
              title: dim.title,
              subtitle: dim.subtitle,
              badge: dim.badge,
              badgeColor: badgeColors[index % badgeColors.length],
              description: dim.description,
            ),
          );
        }),
      ],
    );
  }
}

class _DimensionDetailCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String badge;
  final Color badgeColor;
  final String description;

  const _DimensionDetailCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.badgeColor,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      padding: AppSpacing.cardPaddingAll,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: AppSpacing.xl,
                height: AppSpacing.xl,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: AppSpacing.roundedSm,
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: AppSpacing.md,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      subtitle,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: PillBadge(
                  label: badge,
                  color: badgeColor,
                  showDot: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: AppSpacing.roundedSm,
            ),
            child: Text(
              description,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
