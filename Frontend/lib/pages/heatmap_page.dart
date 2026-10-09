import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../app/theme/app_colors.dart';
import '../app/theme/app_spacing.dart';
import '../app/theme/app_text_styles.dart';
import '../shared/widgets/app_top_bar.dart';
import '../shared/widgets/buttons.dart';
import '../shared/widgets/info_card.dart';
import '../shared/widgets/placeholder_image.dart';

class HeatmapPage extends StatelessWidget {
  const HeatmapPage({super.key});

  @override
  Widget build(BuildContext context) {
    // StatelessWidget cocok karena halaman ini belum menyimpan data yang berubah.
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
                    Text(
                      'City Heatmap',
                      style: AppTextStyles.pageTitle,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Spatial Land Surface Temperature distribution across Kota Malang',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    InfoCard(
                      padding: AppSpacing.cardPaddingAll,
                      child: Column(
                        children: [
                          // Ini placeholder desain, belum menampilkan peta suhu sungguhan.
                          PlaceholderImage(
                            height: 280,
                            icon: Icons.map_rounded,
                            label: 'Heatmap akan diimplementasikan',
                            borderRadius: AppSpacing.roundedSm,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'Visualisasi raster LST Kota Malang akan dirender pada lapisan interaktif ini.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SoftButton(
                      label: 'Simulasi Prediksi Mikro-klimat',
                      icon: Icons.analytics_outlined,
                      onPressed: () => context.go('/heatmap/prediction'),
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
}
