import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';

class PlaceholderImage extends StatelessWidget {
  final double height;
  final IconData icon;
  final String? label;
  final Widget? overlay;
  final Color? backgroundColor;
  final BorderRadius borderRadius;

  const PlaceholderImage({
    super.key,
    required this.height,
    this.icon = Icons.image_outlined,
    this.label,
    this.overlay,
    this.backgroundColor,
    this.borderRadius = AppSpacing.roundedSm,
  });

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? AppColors.primaryLight.withValues(alpha: 0.12);

    return ClipRRect(
      borderRadius: borderRadius,
      child: Container(
        height: height,
        width: double.infinity,
        color: bg,
        child: Stack(
          children: [
            // Subtle grid / background pattern
            Positioned.fill(
              child: CustomPaint(
                painter: _GridPatternPainter(
                  gridColor: AppColors.primaryLight.withValues(alpha: 0.05),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: AppSpacing.xl,
                    color: AppColors.primaryLight.withValues(alpha: 0.45),
                  ),
                  if (label != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      child: Text(
                        label!,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primaryLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (overlay != null) Positioned.fill(child: overlay!),
          ],
        ),
      ),
    );
  }
}

class _GridPatternPainter extends CustomPainter {
  final Color gridColor;

  _GridPatternPainter({required this.gridColor});

  @override
  void paint(Canvas canvas, Size size) {
    // Menggambar garis berulang sebagai pola dekoratif placeholder.
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 1.0;

    const step = AppSpacing.xl;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
