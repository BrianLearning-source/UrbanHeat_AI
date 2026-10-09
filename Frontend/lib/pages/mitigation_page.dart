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
import '../shared/widgets/placeholder_image.dart';

class MitigationPage extends StatelessWidget {
  final String gridId;

  const MitigationPage({
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
                    const _MitigationInfoNotice(),
                    const SizedBox(height: AppSpacing.md),
                    const _MitigationStatsRow(),
                    const SizedBox(height: AppSpacing.lg),
                    ...urbanHeatRepository.mitigations.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: _MitigationItemCard(item: item),
                        )),
                    const SizedBox(height: AppSpacing.md),
                    DarkButton(
                      label: 'Export Planning Summary (PDF)',
                      icon: Icons.picture_as_pdf_outlined,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Coming soon'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SoftButton(
                      label: 'Back to Heatmap',
                      icon: Icons.map_outlined,
                      onPressed: () => context.go('/heatmap'),
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
                  context.go('/hotspots/area/$gridId');
                }
              },
              borderRadius: AppSpacing.roundedSm,
              child: const Padding(
                padding: EdgeInsets.all(AppSpacing.xs),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.arrow_back_rounded,
                      color: AppColors.primary,
                      size: AppSpacing.md,
                    ),
                    SizedBox(width: AppSpacing.xs),
                    Text(
                      'Back',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Suggested Mitigation\nMeasures',
          style: AppTextStyles.pageTitle,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Informational strategies for areas with higher predicted Land Surface Temperature across Kota Malang.',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _MitigationInfoNotice extends StatelessWidget {
  const _MitigationInfoNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.08),
        borderRadius: AppSpacing.roundedSm,
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lightbulb_outline_rounded,
            color: AppColors.accent,
            size: AppSpacing.md,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mitigation Information',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'These points serve as supporting environmental knowledge and planning references based on satellite environmental indicators, not automated administrative decisions.',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MitigationStatsRow extends StatelessWidget {
  const _MitigationStatsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InfoCard(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Monitored City Sectors',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '5',
                      style: AppTextStyles.tabular(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        'Districts (Kota Malang)',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: InfoCard(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Potential Thermal Relief',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '-1.0° to\n-1.8°C',
                      style: AppTextStyles.tabular(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.mitigation,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Relief',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.mitigation,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MitigationItemCard extends StatelessWidget {
  final MitigationItem item;

  const _MitigationItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final isGreening = item.category.contains('Greening');
    final isRoofing = item.category.contains('Roofing');

    return InfoCard(
      padding: AppSpacing.cardPaddingAll,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(
                isGreening
                    ? Icons.park_rounded
                    : isRoofing
                        ? Icons.roofing_rounded
                        : Icons.layers_outlined,
                color: isGreening ? AppColors.mitigation : AppColors.primary,
                size: AppSpacing.lg,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  item.title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              const Icon(
                Icons.navigation_outlined,
                size: AppSpacing.sm,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  'Target: ${item.target}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              const Icon(
                Icons.trending_down_rounded,
                size: AppSpacing.sm,
                color: AppColors.mitigation,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  'Impact: ${item.impact}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.mitigation,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            item.description,
            style: AppTextStyles.body.copyWith(
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (isGreening)
            const PlaceholderImage(
              height: 110,
              icon: Icons.forest_outlined,
              label: 'Simulated tree canopy corridor intervention',
            )
          else if (isRoofing)
            const PlaceholderImage(
              height: 110,
              icon: Icons.roofing_outlined,
              label: 'Albedo increase: 0.15 → 0.65 · Cool Roofs',
            )
          else
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.background,
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Baseline NDBI Index',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '0.34 (High Built-Up)',
                          style: AppTextStyles.tabular(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.heatHigh,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: AppColors.textSecondary,
                    size: AppSpacing.md,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Target Surface Heat Index',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '-1.2°C Moderated',
                          style: AppTextStyles.tabular(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.mitigation,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.sm),
          Theme(
            data: ThemeData(dividerColor: Colors.transparent),
            child: Material(
              color: Colors.transparent,
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.only(top: AppSpacing.xs),
              leading: Icon(
                Icons.check_circle_outline_rounded,
                color: AppColors.mitigation,
                size: AppSpacing.md,
              ),
              title: Text(
                item.badge,
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Details',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textSecondary,
                    size: AppSpacing.md,
                  ),
                ],
              ),
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: AppSpacing.roundedSm,
                  ),
                  child: Text(
                    item.details,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
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
