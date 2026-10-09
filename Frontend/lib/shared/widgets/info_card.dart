import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';

class InfoCard extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final Color borderColor;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Gradient? gradient;

  const InfoCard({
    super.key,
    required this.child,
    this.backgroundColor = AppColors.surface,
    this.borderColor = AppColors.border,
    this.padding = AppSpacing.cardPaddingAll,
    this.onTap,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final cardContent = Container(
      decoration: BoxDecoration(
        color: gradient == null ? backgroundColor : null,
        gradient: gradient,
        borderRadius: AppSpacing.roundedMd,
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
      ),
      padding: padding,
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppSpacing.roundedMd,
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}
