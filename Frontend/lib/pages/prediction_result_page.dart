import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../app/theme/app_colors.dart';
import '../app/theme/app_spacing.dart';
import '../app/theme/app_text_styles.dart';
import '../shared/widgets/app_top_bar.dart';
import '../shared/widgets/buttons.dart';
import '../shared/widgets/info_card.dart';
import '../shared/widgets/pill_badge.dart';
import '../shared/widgets/section_title.dart';

class PredictionResultPage extends StatelessWidget {
  const PredictionResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Angka hasil pada halaman ini masih contoh yang ditulis langsung di UI.
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
                    const _PredictionGaugeCard(),
                    const SizedBox(height: AppSpacing.lg),
                    const _SpatioTemporalContextSection(),
                    const SizedBox(height: AppSpacing.lg),
                    const _ModelDiagnosticsSection(),
                    const SizedBox(height: AppSpacing.lg),
                    DarkButton(
                      label: 'View Detailed Analysis →',
                      onPressed: () => context.go('/hotspots/area/LW-A12/factors'),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SoftButton(
                      label: 'Run Another Prediction',
                      icon: Icons.refresh_rounded,
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
                  context.go('/heatmap');
                }
              },
              borderRadius: AppSpacing.roundedSm,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: AppSpacing.xs,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.arrow_back_rounded,
                      size: AppSpacing.md,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Back',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const PillBadge(
              label: 'Inference Complete · Spatio-Temporal',
              showDot: true,
              color: AppColors.accent,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Prediction Result',
          style: AppTextStyles.pageTitle,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Lowokwaru Urban Heat Island Micro-climate Simulation',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _PredictionGaugeCard extends StatelessWidget {
  const _PredictionGaugeCard();

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'PREDICTED HEAT INTENSITY',
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              const PillBadge(
                label: 'HIGH RISK',
                showDot: true,
                color: AppColors.heatHigh,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: SizedBox(
              width: 192,
              height: 192,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(192, 192),
                    painter: _GaugePainter(),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '34.8°C',
                        style: AppTextStyles.tabular(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '+4.2°C vs Baseline',
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _GaugeMetricItem(label: 'Min Grid', value: '24.0°C'),
              _GaugeMetricItem(label: 'Threshold', value: '32.5°C'),
              _GaugeMetricItem(label: 'Peak Sim', value: '38.0°C'),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
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
                  Icons.warning_amber_rounded,
                  color: AppColors.accent,
                  size: AppSpacing.md,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Elevated thermal comfort index. Dense canopy mitigation strongly advised for commercial corridors.',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                    ),
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

class _GaugePainter extends CustomPainter {
  // CustomPainter menggambar gauge langsung pada Canvas Flutter.
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - AppSpacing.lg) / 2;
    const startAngle = 135 * (math.pi / 180);
    const sweepAngle = 270 * (math.pi / 180);

    // Background Arc
    final bgPaint = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = AppSpacing.sm
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      bgPaint,
    );

    // Active Gradient Arc
    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradient = SweepGradient(
      startAngle: startAngle,
      endAngle: startAngle + sweepAngle,
      colors: const [
        AppColors.accent,
        AppColors.heatHigh,
      ],
    );

    final activePaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = AppSpacing.sm
      ..strokeCap = StrokeCap.round;

    // 78% progress along 270 degree arc
    const progress = 0.78;
    canvas.drawArc(
      rect,
      startAngle,
      sweepAngle * progress,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GaugeMetricItem extends StatelessWidget {
  final String label;
  final String value;

  const _GaugeMetricItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTextStyles.tabular(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _SpatioTemporalContextSection extends StatelessWidget {
  const _SpatioTemporalContextSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionTitle(title: 'Spatio-Temporal Context'),
        const SizedBox(height: AppSpacing.xs),
        InfoCard(
          padding: AppSpacing.cardPaddingAll,
          child: Column(
            children: [
              _ContextRow(
                icon: Icons.location_city_rounded,
                label: 'Location Zone',
                title: 'Lowokwaru, Malang City',
                subtitle: 'Grid #LW-A12 Dinoyo Corridor',
              ),
              const Divider(color: AppColors.border, height: AppSpacing.lg),
              _ContextRow(
                icon: Icons.calendar_today_rounded,
                label: 'Prediction Target Window',
                title: '23 Sep 2026 · 10:00 – 12:00 WIB',
                subtitle: 'Peak Solar Irradiance Window',
              ),
              const Divider(color: AppColors.border, height: AppSpacing.lg),
              _ContextRow(
                icon: Icons.access_time_rounded,
                label: 'Computation Timestamp',
                title: 'Generated today at 10:14 WIB',
                subtitle: 'Execution runtime: 218ms via Edge TPU',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ContextRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String title;
  final String subtitle;

  const _ContextRow({
    required this.icon,
    required this.label,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: AppSpacing.xl,
          height: AppSpacing.xl,
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.1),
            borderRadius: AppSpacing.roundedSm,
          ),
          child: Icon(
            icon,
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
                label,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
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
      ],
    );
  }
}

class _ModelDiagnosticsSection extends StatelessWidget {
  const _ModelDiagnosticsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionTitle(
          title: 'Model Diagnostics',
          action: PillBadge(
            label: 'v3.4 Production',
            color: AppColors.mitigation,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        InfoCard(
          padding: AppSpacing.cardPaddingAll,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Model Architecture',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'XGBoost Spatio-Temporal Regressor',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    size: AppSpacing.md,
                    color: AppColors.mitigation,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      'High Confidence (Environmental telemetry verified)',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.mitigation,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _DiagnosticMetricBox(
                      label: 'R² Score',
                      value: '0.88',
                      status: 'Excellent',
                      statusColor: AppColors.mitigation,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: _DiagnosticMetricBox(
                      label: 'RMSE',
                      value: '0.52°C',
                      status: 'Low Drift',
                      statusColor: AppColors.heatLow,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: _DiagnosticMetricBox(
                      label: 'MAE',
                      value: '0.41°C',
                      status: 'Optimal',
                      statusColor: AppColors.mitigation,
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

class _DiagnosticMetricBox extends StatelessWidget {
  final String label;
  final String value;
  final String status;
  final Color statusColor;

  const _DiagnosticMetricBox({
    required this.label,
    required this.value,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppSpacing.roundedSm,
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTextStyles.tabular(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            status,
            style: AppTextStyles.caption.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
