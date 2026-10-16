import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';

class AppTopBar extends StatelessWidget {
  const AppTopBar({super.key, this.onProfileTap});

  final VoidCallback? onProfileTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: AppSpacing.xl,
                height: AppSpacing.xl,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  borderRadius: AppSpacing.roundedSm,
                ),
                child: ClipRRect(
                  borderRadius: AppSpacing.roundedSm,
                  child: SvgPicture.asset(
                    'assets/branding/urbanheat_logo.svg',
                    width: AppSpacing.xl,
                    height: AppSpacing.xl,
                    semanticsLabel: 'UrbanHeat AI logo',
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'UrbanHeat AI',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    'Kota Malang',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          InkWell(
            onTap: onProfileTap,
            customBorder: const CircleBorder(),
            child: Container(
              width: AppSpacing.xl,
              height: AppSpacing.xl,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.border,
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.person_rounded,
                color: AppColors.primary,
                size: AppSpacing.lg,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
