import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';

class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final IconData? trailingIcon;
  final bool isFullWidth;

  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.trailingIcon,
    this.isFullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Material(
      color: Colors.transparent,
      borderRadius: AppSpacing.roundedMd,
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.accent,
              Color.lerp(AppColors.accent, AppColors.primary, 0.15)!,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: AppSpacing.roundedMd,
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: AppSpacing.roundedMd,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: AppColors.surface, size: AppSpacing.md),
                  const SizedBox(width: AppSpacing.xs),
                ],
                Flexible(
                  child: Text(
                    label,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.surface,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (trailingIcon != null) ...[
                  const SizedBox(width: AppSpacing.xs),
                  Icon(trailingIcon, color: AppColors.surface, size: AppSpacing.md),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    if (isFullWidth) {
      return SizedBox(width: double.infinity, child: content);
    }
    return content;
  }
}

class DarkButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final IconData? trailingIcon;
  final bool isFullWidth;

  const DarkButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.trailingIcon,
    this.isFullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Material(
      color: Colors.transparent,
      borderRadius: AppSpacing.roundedMd,
      child: Ink(
        decoration: const BoxDecoration(
          color: AppColors.primary,
          borderRadius: AppSpacing.roundedMd,
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: AppSpacing.roundedMd,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: AppColors.surface, size: AppSpacing.md),
                  const SizedBox(width: AppSpacing.xs),
                ],
                Flexible(
                  child: Text(
                    label,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.surface,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (trailingIcon != null) ...[
                  const SizedBox(width: AppSpacing.xs),
                  Icon(trailingIcon, color: AppColors.surface, size: AppSpacing.md),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    if (isFullWidth) {
      return SizedBox(width: double.infinity, child: content);
    }
    return content;
  }
}

class SoftButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final IconData? trailingIcon;
  final bool isFullWidth;
  final Color textColor;
  final Color? backgroundColor;
  final Color? borderColor;

  const SoftButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.trailingIcon,
    this.isFullWidth = true,
    this.textColor = AppColors.primary,
    this.backgroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? AppColors.primary.withValues(alpha: 0.05);
    final border = borderColor ?? AppColors.border;

    Widget content = Material(
      color: Colors.transparent,
      borderRadius: AppSpacing.roundedMd,
      child: Ink(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: AppSpacing.roundedMd,
          border: Border.all(
            color: border,
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: AppSpacing.roundedMd,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: textColor, size: AppSpacing.md),
                  const SizedBox(width: AppSpacing.xs),
                ],
                Flexible(
                  child: Text(
                    label,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (trailingIcon != null) ...[
                  const SizedBox(width: AppSpacing.xs),
                  Icon(trailingIcon, color: textColor, size: AppSpacing.md),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    if (isFullWidth) {
      return SizedBox(width: double.infinity, child: content);
    }
    return content;
  }
}
