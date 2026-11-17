import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../profile/domain/entities/user_profile.dart';
import '../../../profile/domain/repositories/profile_repository.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../../../shared/widgets/buttons.dart';
// import '../../../../shared/widgets/heat_spectrum_bar.dart';
import '../../../../shared/widgets/info_card.dart';
import '../../../../shared/widgets/pill_badge.dart';
import '../../../../shared/widgets/placeholder_image.dart';
import '../../../../shared/widgets/section_title.dart';
import '../../domain/repositories/heat_intensity_repository.dart';
import '../../domain/entities/heat_intensity_summary.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.profileRepository, required this.heatIntensityRepository,});

  final ProfileRepository profileRepository;
  final HeatIntensityRepository heatIntensityRepository;

  @override
  Widget build(BuildContext content) {
    return StreamBuilder<UserProfile?>(
      stream: profileRepository.watchProfile(),
      builder: (context, snapshot) {
        final profile = snapshot.data;
        final userName = profile?.name ?? 'User';
        final avatarUrl = profile?.avatarUrl;
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTopBar(
                    avatarUrl: avatarUrl,
                    onProfileTap: () => context.go('/profile'),
                  ),

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
                        _SurfaceHeatIntensityCard(
                          repository: heatIntensityRepository,
                        ),

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
      },
    );
  }
}
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.only(bottom: AppSpacing.xl),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               const AppTopBar(),
//               Padding(
//                 padding: AppSpacing.screenPaddingH,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     const SizedBox(height: AppSpacing.xs),
//                     _HomeGreetingHeader(userName: userName),
//                     const SizedBox(height: AppSpacing.md),
//                     const _HeroOutlookCard(),
//                     const SizedBox(height: AppSpacing.lg),
//                     const _SurfaceHeatIntensityCard(),
//                     const SizedBox(height: AppSpacing.lg),
//                     const _LatestObservationCard(),
//                     const SizedBox(height: AppSpacing.lg),
//                     const _QuickActionsSection(),
//                     const SizedBox(height: AppSpacing.md),
//                     const _CanopyImpactBanner(),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

class _HomeGreetingHeader extends StatefulWidget {
  const _HomeGreetingHeader({required this.userName});

  final String userName;

  @override
  State<_HomeGreetingHeader> createState() => _HomeGreetingHeaderState();
}

class _HomeGreetingHeaderState extends State<_HomeGreetingHeader> {
  Timer? _greetingTimer;

  @override
  void initState() {
    super.initState();

    // Periksa waktu setiap satu menit.
    _greetingTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _greetingTimer?.cancel();
    super.dispose();
  }

  String get _timeGreeting {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 11) {
      return 'Good morning';
    } else if (hour >= 11 && hour < 15) {
      return 'Good afternoon';
    } else if (hour >= 15 && hour < 18) {
      return 'Good evening';
    } else {
      return 'Good night';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$_timeGreeting, ${widget.userName}',
                style: AppTextStyles.pageTitle,
              ),
              const SizedBox(height: AppSpacing.xs),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => context.push('/notifications'),
            borderRadius: AppSpacing.roundedSm,
            child: SizedBox(
              width: AppSpacing.xl,
              height: AppSpacing.xl,
              child: Stack(
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
            ),
          ),
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

//============= SURFACE HEAT INTENSITY INDEX ===========
// nilai _temporaryHeatIntensityLstCelcius adalah sementara, nanti diganti dengan nilai dari model ML

class _SurfaceHeatIntensityCard extends StatefulWidget {
  const _SurfaceHeatIntensityCard({
    required this.repository,
  });

  final HeatIntensityRepository repository;

  @override
  State<_SurfaceHeatIntensityCard> createState() =>
      _SurfaceHeatIntensityCardState();
}

class _SurfaceHeatIntensityCardState
    extends State<_SurfaceHeatIntensityCard> {
  late Future<HeatIntensityResult> _summaryFuture;

  @override
  void initState() {
    super.initState();
    _summaryFuture = widget.repository.getSummary();
  }

  @override
  void didUpdateWidget(
    covariant _SurfaceHeatIntensityCard oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.repository != widget.repository) {
      _summaryFuture = widget.repository.getSummary();
    }
  }

  void _retry() {
    setState(() {
      _summaryFuture = widget.repository.getSummary();
    });
  }

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

          FutureBuilder<HeatIntensityResult>(
            future: _summaryFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState ==
                      ConnectionState.waiting &&
                  !snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                );
              }

              if (snapshot.hasError ||
                  snapshot.data == null ||
                  snapshot.data!.failure != null ||
                  snapshot.data!.data == null) {
                return _buildErrorState();
              }

              final summary = snapshot.data!.data!;

              return _buildHeatIntensityContent(summary);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Unable to load heat intensity data.',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextButton.icon(
          onPressed: _retry,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Retry'),
        ),
      ],
    );
  }

  Widget _buildHeatIntensityContent(
    HeatIntensitySummary summary,
  ) {
    final levelColor = _getLevelColor(summary.intensityLevel);
    final levelLabel = _getLevelLabel(summary.intensityLevel);

    final scaleRange =
        summary.scaleMaxCelsius - summary.scaleMinCelsius;

    final indicatorPosition = scaleRange <= 0
        ? 0.0
        : ((summary.lstCelsius - summary.scaleMinCelsius) /
                scaleRange)
            .clamp(0.0, 1.0)
            .toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Category badge. Numeric LST is not displayed here
        // because it is already shown in the observation section.
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: levelColor.withValues(alpha: 0.12),
              borderRadius: AppSpacing.roundedFull,
            ),
            child: Text(
              levelLabel,
              style: AppTextStyles.caption.copyWith(
                color: levelColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // Gradient bar and dynamic indicator position.
        LayoutBuilder(
          builder: (context, constraints) {
            const markerSize = 18.0;

            final availableWidth =
                (constraints.maxWidth - markerSize)
                    .clamp(0.0, double.infinity);

            final markerLeft =
                availableWidth * indicatorPosition;

            return SizedBox(
              height: 22,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 6,
                    child: Container(
                      height: 10,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(100),
                        ),
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF20C5D0),
                            Color(0xFF8BAF83),
                            Color(0xFFFFB21B),
                            Color(0xFFFF7A1A),
                            Color(0xFFF5424A),
                          ],
                          stops: [
                            0.0,
                            0.30,
                            0.55,
                            0.78,
                            1.0,
                          ],
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    left: markerLeft,
                    top: 2,
                    child: Container(
                      width: markerSize,
                      height: markerSize,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: levelColor,
                          width: 3,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x26000000),
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: AppSpacing.sm),

        // Classification legend using threshold values
        // returned by FastAPI.
        Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: _HeatIntensityLegendItem(
                  label:
                      'Lower LST (<${_formatThreshold(summary.lowerThresholdCelsius)}°C)',
                  color: const Color(0xFF20C5D0),
                  isActive:
                      summary.intensityLevel ==
                      HeatIntensityLevel.lower,
                ),
              ),
            ),

            Expanded(
              child: Center(
                child: _HeatIntensityLegendItem(
                  label:
                      'Moderate (${_formatThreshold(summary.lowerThresholdCelsius)}–${_formatThreshold(summary.higherThresholdCelsius)}°C)',
                  color: const Color(0xFFFFA000),
                  isActive:
                      summary.intensityLevel ==
                      HeatIntensityLevel.moderate,
                ),
              ),
            ),

            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: _HeatIntensityLegendItem(
                  label:
                      'Higher LST (>${_formatThreshold(summary.higherThresholdCelsius)}°C)',
                  color: const Color(0xFFF5424A),
                  isActive:
                      summary.intensityLevel ==
                      HeatIntensityLevel.higher,
                ),
              ),
            ),
          ],
        ),

        // Explicitly disclose temporary backend data.
        if (summary.isDummy) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Simulated backend data • ${summary.modelVersion}',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  Color _getLevelColor(HeatIntensityLevel level) {
    switch (level) {
      case HeatIntensityLevel.lower:
        return const Color(0xFF20C5D0);

      case HeatIntensityLevel.moderate:
        return const Color(0xFFFFA000);

      case HeatIntensityLevel.higher:
        return const Color(0xFFF5424A);
    }
  }

  String _getLevelLabel(HeatIntensityLevel level) {
    switch (level) {
      case HeatIntensityLevel.lower:
        return 'LOWER';

      case HeatIntensityLevel.moderate:
        return 'MODERATE';

      case HeatIntensityLevel.higher:
        return 'HIGHER';
    }
  }

  String _formatThreshold(double value) {
    return value % 1 == 0
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(1);
  }
}


class _HeatIntensityLegendItem extends StatelessWidget {
  const _HeatIntensityLegendItem({
    required this.label,
    required this.color,
    required this.isActive,
  });

  final String label;
  final Color color;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: AppSpacing.xs,
          height: AppSpacing.xs,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),

        const SizedBox(width: AppSpacing.xs),

        Flexible(
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption.copyWith(
              color: isActive
                  ? color
                  : AppColors.textSecondary,
              fontWeight: isActive
                  ? FontWeight.w700
                  : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}


// class _SurfaceHeatIntensityCard extends StatelessWidget {
//   const _SurfaceHeatIntensityCard();

//   @override
//   Widget build(BuildContext context) {
//     return InfoCard(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           Text(
//             'SURFACE HEAT INTENSITY INDEX',
//             style: AppTextStyles.caption.copyWith(
//               fontWeight: FontWeight.w700,
//               color: AppColors.primary,
//             ),
//             maxLines: 2,
//             overflow: TextOverflow.ellipsis,
//           ),
//           const SizedBox(height: AppSpacing.md),
//           const HeatSpectrumBar(),
//         ],
//       ),
//     );
//   }
// }

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

        const SizedBox(height: AppSpacing.xs),
        _QuickActionTile(
          icon: Icons.event_note_rounded,
          title: 'Planning',
          subtitle: 'Manage your heat mitigation plans and activities.',
          onTap: () => context.push('/planning'),
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
