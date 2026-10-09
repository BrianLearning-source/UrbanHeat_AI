import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';

class HeatSpectrumBar extends StatelessWidget {
  final String? markerText;
  final double? markerPosition; // 0.0 to 1.0
  final List<HeatSpectrumLegendItem>? customLegend;

  const HeatSpectrumBar({
    super.key,
    this.markerText,
    this.markerPosition,
    this.customLegend,
  });

  @override
  Widget build(BuildContext context) {
    final legends = customLegend ??
        const [
          HeatSpectrumLegendItem(
            label: 'Lower LST (<28°C)',
            color: AppColors.heatLow,
          ),
          HeatSpectrumLegendItem(
            label: 'Moderate (~31°C)',
            color: AppColors.heatMedium,
          ),
          HeatSpectrumLegendItem(
            label: 'Higher LST (>34°C)',
            color: AppColors.heatHigh,
          ),
        ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (markerText != null && markerPosition != null) ...[
          LayoutBuilder(
            builder: (context, constraints) {
              final double clampedPos = markerPosition!.clamp(0.1, 0.9);
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Align(
                  alignment: Alignment(-1.0 + (clampedPos * 2.0), 0.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: AppSpacing.roundedFull,
                      border: Border.all(
                        color: AppColors.border,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      markerText!,
                      style: AppTextStyles.tabular(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.surface,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
        Container(
          height: AppSpacing.xs,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.heatLow,
                AppColors.heatMedium,
                AppColors.accent,
                AppColors.heatHigh,
              ],
            ),
            borderRadius: AppSpacing.roundedFull,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: legends.map((item) {
            return Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: AppSpacing.xs,
                    height: AppSpacing.xs,
                    decoration: BoxDecoration(
                      color: item.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Flexible(
                    child: Text(
                      item.label,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class HeatSpectrumLegendItem {
  final String label;
  final Color color;

  const HeatSpectrumLegendItem({
    required this.label,
    required this.color,
  });
}
