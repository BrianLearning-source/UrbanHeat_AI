import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/theme/app_colors.dart';
import '../app/theme/app_spacing.dart';
import '../app/theme/app_text_styles.dart';
import '../data/repositories/urban_heat_repository.dart';
import '../shared/widgets/app_top_bar.dart';
import '../shared/widgets/info_card.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late String _profileName;
  File? _profilePhoto;

  @override
  void initState() {
    super.initState();
    _profileName = urbanHeatRepository.userName;
  }

  Future<void> _openEditProfile() async {
    final result = await context.push<EditProfileResult>(
      '/edit-profile',
      extra: EditProfileArguments(
        name: _profileName,
        photoPath: _profilePhoto?.path,
      ),
    );
    if (!mounted || result == null) return;
    setState(() {
      _profileName = result.name;
      _profilePhoto = result.photoPath == null ? null : File(result.photoPath!);
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
              const AppTopBar(),
              Padding(
                padding: AppSpacing.screenPaddingH,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpacing.xs),
                    _UserProfileHeaderCard(
                      name: _profileName,
                      photo: _profilePhoto,
                      onTap: _openEditProfile,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const _ProfileSettingsCard(),
                    const SizedBox(height: AppSpacing.lg),
                    _SignOutButton(onPressed: () => context.go('/login')),
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
  const _UserProfileHeaderCard({
    required this.name,
    required this.photo,
    required this.onTap,
  });

  final String name;
  final File? photo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: AppSpacing.roundedSm,
              border: Border.all(color: AppColors.border, width: 1.5),
            ),
            child: ClipRRect(
              borderRadius: AppSpacing.roundedSm,
              child: photo == null
                  ? const Icon(
                      Icons.person_rounded,
                      size: AppSpacing.xl,
                      color: AppColors.primary,
                    )
                  : Image.file(
                      photo!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.person_rounded,
                        size: AppSpacing.xl,
                        color: AppColors.primary,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              name,
              style: AppTextStyles.sectionTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
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

class _ProfileSettingsCard extends StatefulWidget {
  const _ProfileSettingsCard();

  @override
  State<_ProfileSettingsCard> createState() => _ProfileSettingsCardState();
}

class _ProfileSettingsCardState extends State<_ProfileSettingsCard> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _SettingsRow(
            icon: Icons.notifications_active_outlined,
            title: 'Notifications',
            subtitle: 'Heat & model alerts',
            trailing: Transform.scale(
              scale: 0.85,
              child: Switch(
                value: _notificationsEnabled,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                activeTrackColor: AppColors.accent,
                activeThumbColor: AppColors.surface,
                inactiveTrackColor: AppColors.border,
                trackOutlineColor: const WidgetStatePropertyAll(
                  Colors.transparent,
                ),
                trackOutlineWidth: const WidgetStatePropertyAll(0),
                onChanged: (enabled) {
                  setState(() => _notificationsEnabled = enabled);
                  // TODO: Persist the notification preference with the backend.
                },
              ),
            ),
          ),
          const _SettingsDivider(),
          _SettingsRow(
            icon: Icons.lock_outline_rounded,
            title: 'Change Password',
            subtitle: 'Update your account password',
            trailing: const _SettingsChevron(),
            onTap: () => context.push('/change-password'),
          ),
          const _SettingsDivider(),
          const _SettingsRow(
            icon: Icons.description_outlined,
            title: 'Project Information',
            subtitle: 'Detail information about UrbanHeat AI',
            trailing: _SettingsChevron(),
          ),
          const _SettingsDivider(),
          _SettingsRow(
            icon: Icons.shield_outlined,
            title: 'Privacy Policy',
            subtitle: 'How your data is handled',
            trailing: const _SettingsChevron(),
            onTap: () {
              // TODO: Connect this row to the privacy policy destination.
            },
          ),
          const _SettingsDivider(),
          const _SettingsRow(
            icon: Icons.info_outline_rounded,
            title: 'App version',
            subtitle: 'UrbanHeat AI',
            trailing: _AppVersionLabel(),
          ),
        ],
      ),
    );
  }
}

class _ProfileIcon extends StatelessWidget {
  const _ProfileIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppSpacing.roundedSm,
      ),
      child: Icon(icon, size: AppSpacing.md, color: AppColors.primary),
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.md + 40 + AppSpacing.sm,
        right: AppSpacing.md,
      ),
      child: Divider(height: 1, thickness: 1, color: AppColors.border),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              _ProfileIcon(icon: icon),
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
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      subtitle,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsChevron extends StatelessWidget {
  const _SettingsChevron();

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.chevron_right_rounded,
      color: AppColors.textSecondary,
      size: AppSpacing.md,
    );
  }
}

class _AppVersionLabel extends StatelessWidget {
  const _AppVersionLabel();

  @override
  Widget build(BuildContext context) {
    // TODO: Read the app version from pubspec metadata.
    return Text(
      '1.0.0',
      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
    );
  }
}

class _SignOutButton extends StatelessWidget {
  const _SignOutButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: AppSpacing.roundedSm,
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppSpacing.roundedSm,
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            borderRadius: AppSpacing.roundedSm,
            border: Border.all(color: AppColors.border),
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
              Text(
                'Sign Out',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.heatHigh,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
