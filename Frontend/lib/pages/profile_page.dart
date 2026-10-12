import 'package:flutter/material.dart';
import '../app/theme/app_colors.dart';
import '../app/theme/app_spacing.dart';
import '../app/theme/app_text_styles.dart';
import '../data/repositories/urban_heat_repository.dart';
import '../shared/widgets/app_top_bar.dart';
import '../shared/widgets/info_card.dart';
import '../shared/widgets/pill_badge.dart';
import '../shared/widgets/section_title.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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
                    const _UserProfileHeaderCard(),
                    const SizedBox(height: AppSpacing.md),
                    const SizedBox(height: AppSpacing.lg),
                    const _PreferencesSection(),
                    const SizedBox(height: AppSpacing.lg),
                    const _AboutUrbanHeatSection(),
                    const SizedBox(height: AppSpacing.lg),
                    const _CacheAndSignOutSection(),
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

class _UserProfileHeaderCard extends StatelessWidget {
  const _UserProfileHeaderCard();

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: AppSpacing.roundedSm,
                      border: Border.all(
                        color: AppColors.border,
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      size: AppSpacing.xl,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          urbanHeatRepository.userName,
                          style: AppTextStyles.pageTitle.copyWith(
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        const Icon(
                          Icons.verified_rounded,
                          size: AppSpacing.md,
                          color: AppColors.accent,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      urbanHeatRepository.userRole,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: AppSpacing.sm,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            urbanHeatRepository.userLocation,
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
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PreferencesSection extends StatelessWidget {
  const _PreferencesSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionTitle(
          title: 'PREFERENCES',
          action: Text(
            'Customized',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        InfoCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _ProfileSettingsTile(
                icon: Icons.notifications_active_outlined,
                title: 'Notifications & Advisory Alerts',
                subtitle: 'Model simulation notices & heat alerts',
                trailing: const PillBadge(
                  label: 'Active',
                  color: AppColors.accent,
                ),
                showBorder: true,
              ),
              _ProfileSettingsTile(
                icon: Icons.tune_rounded,
                title: 'Prediction & Observation Settings',
                subtitle: 'Satellite Observation cycle, spatial resolution',
                trailing: Text(
                  '30m grid',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                showBorder: true,
              ),
              const _ProfileSettingsTile(
                icon: Icons.layers_outlined,
                title: 'Map Layers & Display',
                subtitle: 'LST Thermal gradient, NDVI overlay, contours',
                showBorder: false,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AboutUrbanHeatSection extends StatelessWidget {
  const _AboutUrbanHeatSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionTitle(
          title: 'About the Project',
          action: Text(
            'PBL ML Study',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        InfoCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: const [
              _ProfileSettingsTile(
                icon: Icons.description_outlined,
                title: 'Project Information',
                subtitle: 'Kota Malang Spatio-Temporal LST Modeling',
                showBorder: true,
              ),
              _ProfileSettingsTile(
                icon: Icons.science_outlined,
                title: 'Data & Methodology',
                subtitle: 'Sentinel-2 / Landsat LST, Linear Reg., Random Forest, XGBoost',
                showBorder: true,
              ),
              _ProfileSettingsTile(
                icon: Icons.public_rounded,
                title: 'Scope & Study Area',
                subtitle: 'City-wide Kota Malang, East Java',
                showBorder: false,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileSettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final bool showBorder;

  const _ProfileSettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: showBorder
            ? const Border(
                bottom: BorderSide(
                  color: AppColors.border,
                  width: 1,
                ),
              )
            : null,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Container(
            width: AppSpacing.xl,
            height: AppSpacing.xl,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: AppSpacing.roundedSm,
            ),
            child: Icon(
              icon,
              size: AppSpacing.md,
              color: AppColors.primary,
            ),
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
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: AppSpacing.xs),
            trailing!,
          ],
          const SizedBox(width: AppSpacing.xs),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textSecondary,
            size: AppSpacing.md,
          ),
        ],
      ),
    );
  }
}

class _CacheAndSignOutSection extends StatelessWidget {
  const _CacheAndSignOutSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InfoCard(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Container(
                width: AppSpacing.xl,
                height: AppSpacing.xl,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: AppSpacing.roundedSm,
                ),
                child: const Icon(
                  Icons.storage_rounded,
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
                      'Offline Inference Cache',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '14.8 MB local model weights stored',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Offline inference cache cleared'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                borderRadius: AppSpacing.roundedSm,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: AppSpacing.roundedSm,
                    border: Border.all(
                      color: AppColors.border,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'Clear Cache',
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Signed out from study session'),
                duration: Duration(seconds: 2),
              ),
            );
          },
          borderRadius: AppSpacing.roundedMd,
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.md,
              horizontal: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.heatHigh.withValues(alpha: 0.08),
              borderRadius: AppSpacing.roundedMd,
              border: Border.all(
                color: AppColors.heatHigh.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.logout_rounded,
                  color: AppColors.heatHigh,
                  size: AppSpacing.md,
                ),
                const SizedBox(width: AppSpacing.xs),
                Flexible(
                  child: Text(
                    'Sign Out from Study Session',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.heatHigh,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'UrbanHeat AI Research Team · 2025',
          textAlign: TextAlign.center,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
