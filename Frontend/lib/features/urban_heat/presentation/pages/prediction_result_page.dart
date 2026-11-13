import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/failures.dart';
import '../../domain/entities/prediction.dart';
import '../../domain/repositories/prediction_repository.dart';
import '../../../profile/domain/entities/user_profile.dart';
import '../../../profile/domain/repositories/profile_repository.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../../../shared/widgets/buttons.dart';
import '../../../../shared/widgets/info_card.dart';
import '../../../../shared/widgets/pill_badge.dart';
import '../../../../shared/widgets/section_title.dart';

class PredictionResultPage extends StatefulWidget {
  const PredictionResultPage({
    super.key,
    required this.profileRepository,
    required this.predictionRepository,
  });

  final ProfileRepository profileRepository;
  final PredictionRepository predictionRepository;

  @override
  State<PredictionResultPage> createState() => _PredictionResultPageState();
}

class _PredictionResultPageState extends State<PredictionResultPage> {
  // Temporary development coordinates while map-based selection is paused.
  static const double _testLatitude = -7.9797;
  static const double _testLongitude = 112.6304;

  late final Stream<UserProfile?> _profileStream;

  bool _isLoading = false;
  Prediction? _prediction;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _profileStream = widget.profileRepository.watchProfile();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadPrediction();
      }
    });
  }

  Future<void> _loadPrediction() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _prediction = null;
      _errorMessage = null;
    });

    try {
      final result = await widget.predictionRepository.predict(
        latitude: _testLatitude,
        longitude: _testLongitude,
        date: DateTime.now(),
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _prediction = result.data;

        if (result.failure is NetworkFailure) {
          _errorMessage = 'Tidak dapat terhubung ke Prediction API. Periksa server dan API_BASE_URL.';
        } else if (result.failure != null || result.data == null) {
          _errorMessage = 'Response Prediction API tidak dapat diproses. Periksa format response backend.';
        }
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _prediction = null;
        _errorMessage = 'Terjadi kesalahan saat menjalankan prediksi.';
      });
    }
  }

  Color _riskColor(String riskLevel) {
    switch (riskLevel.toUpperCase()) {
      case 'LOW':
        return AppColors.heatLow;
      case 'MODERATE':
        return AppColors.heatMedium;
      case 'ELEVATED':
        return AppColors.accent;
      case 'HIGH':
        return AppColors.heatHigh;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final prediction = _prediction;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StreamBuilder<UserProfile?>(
                stream: _profileStream,
                builder: (context, snapshot) {
                  return AppTopBar(
                    avatarUrl: snapshot.data?.avatarUrl,
                    onProfileTap: () => context.go('/profile'),
                  );
                },
              ),
              Padding(
                padding: AppSpacing.screenPaddingH,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpacing.xs),
                    _buildHeader(context, prediction),
                    const SizedBox(height: AppSpacing.md),
                    if (_isLoading) ...[
                      const LinearProgressIndicator(),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Mengirim request ke Prediction API...',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    if (_errorMessage != null) ...[
                      _buildErrorCard(_errorMessage!),
                      const SizedBox(height: AppSpacing.md),
                      SoftButton(
                        label: 'Retry Prediction',
                        icon: Icons.refresh_rounded,
                        onPressed: _loadPrediction,
                      ),
                    ],
                    if (prediction != null) ...[
                      _PredictionGaugeCard(
                        prediction: prediction,
                        riskColor: _riskColor(prediction.riskLevel),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _SpatioTemporalContextSection(prediction: prediction),
                      const SizedBox(height: AppSpacing.lg),
                      _ModelDiagnosticsSection(prediction: prediction),
                      const SizedBox(height: AppSpacing.lg),
                      DarkButton(
                        label: 'View Detailed Analysis →',
                        onPressed: () =>
                            context.go('/hotspots/area/LW-A12/factors'),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      SoftButton(
                        label: 'Run Another Prediction',
                        icon: Icons.refresh_rounded,
                        onPressed: _loadPrediction,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Prediction? prediction) {
    final badgeLabel = _isLoading
        ? 'Processing Prediction'
        : _errorMessage != null
        ? 'Prediction Unavailable'
        : prediction?.isDummy == true
        ? 'Dummy Prediction'
        : prediction != null
        ? 'Inference Complete · Spatio-Temporal'
        : 'Prediction API Test';

    final badgeColor = prediction?.isDummy == true || _errorMessage != null
        ? AppColors.heatMedium
        : AppColors.accent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            InkWell(
              onTap: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/home');
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
            PillBadge(label: badgeLabel, showDot: true, color: badgeColor),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text('Prediction Result', style: AppTextStyles.pageTitle),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Lowokwaru Urban Heat Island Micro-climate Simulation',
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildErrorCard(String message) {
    return InfoCard(
      padding: AppSpacing.cardPaddingAll,
      borderColor: AppColors.heatHigh,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.heatHigh),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.body.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _PredictionGaugeCard extends StatelessWidget {
  const _PredictionGaugeCard({
    required this.prediction,
    required this.riskColor,
  });

  final Prediction prediction;
  final Color riskColor;

  @override
  Widget build(BuildContext context) {
    final difference =
        prediction.predictedLstCelsius - prediction.baseValueCelsius;

    final insight = prediction.mitigations.isNotEmpty
        ? prediction.mitigations.first.description
        : prediction.isDummy
        ? 'This is simulated output for integration testing, not a real ML prediction.'
        : 'No mitigation insight was included in this API response.';

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
              PillBadge(
                label: '${prediction.riskLevel.toUpperCase()} RISK',
                showDot: true,
                color: riskColor,
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
                        '${prediction.predictedLstCelsius.toStringAsFixed(1)}°C',
                        style: AppTextStyles.tabular(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${difference >= 0 ? '+' : ''}${difference.toStringAsFixed(1)}°C vs Baseline',
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
  children: [
    Expanded(
      child: _GaugeMetricItem(
        label: 'Base Value',
        value: '${prediction.baseValueCelsius.toStringAsFixed(1)}°C',
      ),
    ),
    Expanded(
      child: _GaugeMetricItem(
        label: 'Difference',
        value: '${difference >= 0 ? '+' : ''}${difference.toStringAsFixed(1)}°C',
      ),
    ),
    Expanded(
      child: _GaugeMetricItem(
        label: 'Factors',
        value: prediction.factors.length.toString(),
      ),
    ),
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
                    insight,
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
  // CustomPainter menggambar gauge original.
  // Arc tetap dekoratif karena API belum menyediakan threshold/range.
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - AppSpacing.lg) / 2;
    const startAngle = 135 * (math.pi / 180);
    const sweepAngle = 270 * (math.pi / 180);

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

    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradient = SweepGradient(
      startAngle: startAngle,
      endAngle: startAngle + sweepAngle,
      colors: const [AppColors.accent, AppColors.heatHigh],
    );

    final activePaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = AppSpacing.sm
      ..strokeCap = StrokeCap.round;

    // Original 78% decorative arc retained to preserve the gauge appearance.
    const progress = 0.78;
    canvas.drawArc(rect, startAngle, sweepAngle * progress, false, activePaint);
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
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
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
  const _SpatioTemporalContextSection({required this.prediction});

  final Prediction prediction;

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
                title:
                    '${prediction.latitude.toStringAsFixed(4)}, ${prediction.longitude.toStringAsFixed(4)}',
                subtitle: 'Coordinates submitted to Prediction API',
              ),
              const Divider(color: AppColors.border, height: AppSpacing.lg),
              _ContextRow(
                icon: Icons.calendar_today_rounded,
                label: 'Prediction Target Window',
                title: prediction.date.toIso8601String().substring(0, 10),
                subtitle: 'Date supplied in the prediction request',
              ),
              const Divider(color: AppColors.border, height: AppSpacing.lg),
              _ContextRow(
                icon: Icons.access_time_rounded,
                label: 'Computation Timestamp',
                title: prediction.generatedAt.toLocal().toString(),
                subtitle: 'Model version: ${prediction.modelVersion}',
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
          child: Icon(icon, color: AppColors.accent, size: AppSpacing.md),
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
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
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
  const _ModelDiagnosticsSection({required this.prediction});

  final Prediction prediction;

  @override
  Widget build(BuildContext context) {
    final statusColor = prediction.isDummy
        ? AppColors.heatMedium
        : AppColors.mitigation;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionTitle(
          title: 'Model Diagnostics',
          action: PillBadge(label: prediction.modelVersion, color: statusColor),
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
                prediction.isDummy ? 'DummyPredictor' : 'Trained model',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Icon(
                    prediction.isDummy
                        ? Icons.info_outline_rounded
                        : Icons.check_circle_rounded,
                    size: AppSpacing.md,
                    color: statusColor,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      prediction.isDummy
                          ? 'Simulated output for integration testing; not a real ML prediction.'
                          : 'Prediction output returned by the configured model.',
                      style: AppTextStyles.caption.copyWith(
                        color: statusColor,
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
                      value: '—',
                      status: 'Not provided',
                      statusColor: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: _DiagnosticMetricBox(
                      label: 'RMSE',
                      value: '—',
                      status: 'Not provided',
                      statusColor: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: _DiagnosticMetricBox(
                      label: 'MAE',
                      value: '—',
                      status: 'Not provided',
                      statusColor: AppColors.textSecondary,
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
        border: Border.all(color: AppColors.border, width: 1),
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
