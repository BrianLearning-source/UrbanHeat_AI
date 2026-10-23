import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../../../shared/widgets/buttons.dart';
import '../../../../shared/widgets/heat_spectrum_bar.dart';
import '../../../../shared/widgets/info_card.dart';
import '../../../../shared/widgets/pill_badge.dart';
import '../../../../shared/widgets/placeholder_image.dart';
import '../../../../shared/widgets/section_title.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.userName});

  final String userName;

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
                    _HomeGreetingHeader(userName: userName),
                    const SizedBox(height: AppSpacing.md),
                    const _HeroOutlookCard(),
                    const SizedBox(height: AppSpacing.lg),
                    const _SurfaceHeatIntensityCard(),
                    const SizedBox(height: AppSpacing.lg),
                    const _LatestObservationCard(),
                    const SizedBox(height: AppSpacing.lg),
                    const _QuickActionsSection(),
                    const SizedBox(height: AppSpacing.md),
                    const _CanopyImpactBanner(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeGreetingHeader extends StatelessWidget {
  const _HomeGreetingHeader({required this.userName});

  final String userName;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Good morning, $userName', style: AppTextStyles.pageTitle),
              const SizedBox(height: AppSpacing.xs),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Stack(
          children: [
            Container(
              width: AppSpacing.xl,
              height: AppSpacing.xl,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppSpacing.roundedSm,
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: const Icon(
                Icons.notifications_outlined,
                color: AppColors.primary,
                size: AppSpacing.md,
              ),
            ),
            Positioned(
              right: AppSpacing.xs,
              top: AppSpacing.xs,
              child: Container(
                width: AppSpacing.xs,
                height: AppSpacing.xs,
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeroOutlookCard extends StatelessWidget {
  const _HeroOutlookCard();

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.md),
          Text(
            'City-wide Heat\nOutlook (Kota\nMalang)',
            style: AppTextStyles.pageTitle.copyWith(color: AppColors.surface),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Satellite-based spatial ML predicting surface thermal distribution across Kota Malang.',
            style: AppTextStyles.body.copyWith(
              color: AppColors.surface.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Illustration placeholder representing spatial nodes
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                '~33.4°C',
                style: AppTextStyles.tabular(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: AppColors.surface,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const PillBadge(
                label: 'ESTIMATED',
                showDot: true,
                color: AppColors.accent,
                isDark: true,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Predicted LST',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.surface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          GradientButton(
            label: 'Explore City Heatmap →',
            onPressed: () => context.go('/heatmap'),
          ),
        ],
      ),
    );
  }
}

class _SurfaceHeatIntensityCard extends StatelessWidget {
  const _SurfaceHeatIntensityCard();

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'SURFACE HEAT INTENSITY INDEX',
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.md),
          const HeatSpectrumBar(),
        ],
      ),
    );
  }
}

class _LatestObservationCard extends StatelessWidget {
  const _LatestObservationCard();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionTitle(
          title: 'Latest Satellite Observation',
          action: InkWell(
            onTap: () => context.go('/heatmap/prediction'),
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
                    'View Details',
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
        ),
        const SizedBox(height: AppSpacing.xs),
        InfoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: AppSpacing.xl,
                          height: AppSpacing.xl,
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.12),
                            borderRadius: AppSpacing.roundedSm,
                          ),
                          child: const Icon(
                            Icons.satellite_alt_rounded,
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
                                'Satellite LST Prediction',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Confidence:\n94%',
                    textAlign: TextAlign.end,
                    style: AppTextStyles.tabular(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              PlaceholderImage(
                height: 140,
                icon: Icons.map_outlined,
                overlay: Stack(
                  children: [
                    Positioned(
                      top: AppSpacing.sm,
                      left: AppSpacing.sm,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.8),
                          borderRadius: AppSpacing.roundedFull,
                        ),
                        child: Text(
                          'Kota Malang Study Area',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.surface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: AppSpacing.sm,
                      right: AppSpacing.sm,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.8),
                          borderRadius: AppSpacing.roundedSm,
                        ),
                        child: Text(
                          "Malang S 7°56'38\" E 112°37'12\"",
                          style: AppTextStyles.tabular(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: AppColors.surface,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: AppSpacing.md,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            'Kota Malang Study Area',
                            style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'City-wide Grid',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickActionsSection extends StatelessWidget {
  const _QuickActionsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionTitle(title: 'Quick Actions'),
        const SizedBox(height: AppSpacing.xs),
        _QuickActionTile(
          icon: Icons.map_outlined,
          title: 'City Heatmap',
          subtitle: 'Explore predicted LST across Kota Malang.',
          onTap: () => context.go('/heatmap'),
        ),
        const SizedBox(height: AppSpacing.xs),
        _QuickActionTile(
          icon: Icons.local_fire_department_outlined,
          title: 'Potential Hotspots',
          subtitle: 'View high heat intensity areas.',
          onTap: () => context.go('/hotspots'),
        ),
        const SizedBox(height: AppSpacing.xs),
        _QuickActionTile(
          icon: Icons.grid_view_rounded,
          title: 'Area Detail',
          subtitle: 'Inspect selected grid & indicators.',
          onTap: () => context.go('/hotspots/area/MC-204'),
        ),
      ],
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: AppSpacing.xl,
            height: AppSpacing.xl,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.12),
              borderRadius: AppSpacing.roundedSm,
            ),
            child: Icon(icon, color: AppColors.accent, size: AppSpacing.md),
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
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textSecondary,
            size: AppSpacing.lg,
          ),
        ],
      ),
    );
  }
}

class _CanopyImpactBanner extends StatelessWidget {
  const _CanopyImpactBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.mitigation.withValues(alpha: 0.1),
        borderRadius: AppSpacing.roundedMd,
        border: Border.all(
          color: AppColors.mitigation.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: AppSpacing.xl,
            height: AppSpacing.xl,
            decoration: BoxDecoration(
              color: AppColors.mitigation.withValues(alpha: 0.2),
              borderRadius: AppSpacing.roundedSm,
            ),
            child: const Icon(
              Icons.park_rounded,
              color: AppColors.mitigation,
              size: AppSpacing.md,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Urban Canopy & High Albedo Impact',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  'Building albedo & sparse canopy density',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.textSecondary,
            size: AppSpacing.md,
          ),
        ],
      ),
    );
  }
}
