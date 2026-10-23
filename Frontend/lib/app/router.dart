import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../pages/heatmap_page.dart';
import '../pages/prediction_result_page.dart';
import '../pages/home_page.dart';
import '../pages/area_detail_page.dart';
import '../pages/contributing_factors_page.dart';
import '../pages/hotspots_page.dart';
import '../pages/mitigation_page.dart';
import '../pages/profile_page.dart';
import '../pages/login_page.dart';
import '../pages/register_page.dart';
import '../pages/edit_profile_page.dart';
import '../pages/change_password_page.dart';
import '../pages/splash_pages.dart';
import '../pages/onboarding_pages.dart';
import '../data/repositories/urban_heat_repository.dart' as legacy_data;
import '../features/urban_heat/data/repositories/mock_urban_heat_repository.dart';
import '../features/urban_heat/domain/repositories/urban_heat_repository.dart';
import '../shared/widgets/app_bottom_nav.dart';

// Key ini memberi GoRouter akses ke navigator utama aplikasi.
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'rootNavigator',
);

// Feature dependencies are constructed here and passed into pages.
final UrbanHeatRepository urbanHeatFeatureRepository =
    const MockUrbanHeatRepository();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  // Halaman pertama yang ditampilkan ketika aplikasi dibuka.
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/edit-profile',
      builder: (context, state) {
        final arguments = state.extra as EditProfileArguments?;
        return EditProfileScreen(
          initialName:
              arguments?.name ?? legacy_data.urbanHeatRepository.userName,
          initialPhotoPath: arguments?.photoPath,
        );
      },
    ),
    GoRoute(
      path: '/change-password',
      builder: (context, state) => const ChangePasswordScreen(),
    ),
    GoRoute(path: '/', redirect: (_, _) => '/splash'),
    // Tiap tab punya riwayat sendiri; indexedStack menjaga tab lain tetap tersimpan.
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return Scaffold(
          body: navigationShell,
          bottomNavigationBar: AppBottomNav(
            currentIndex: navigationShell.currentIndex,
            onTap: (index) {
              navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              );
            },
          ),
        );
      },
      branches: [
        // Tab 0: Home
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) =>
                  HomePage(userName: legacy_data.urbanHeatRepository.userName),
            ),
          ],
        ),
        // Tab 1: Heatmap
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/heatmap',
              builder: (context, state) => const HeatmapPage(),
              routes: [
                GoRoute(
                  path: 'prediction',
                  builder: (context, state) => const PredictionResultPage(),
                ),
              ],
            ),
          ],
        ),
        // Tab 2: Hotspots
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/hotspots',
              builder: (context, state) =>
                  HotspotsPage(repository: urbanHeatFeatureRepository),
              routes: [
                GoRoute(
                  path: 'area/:gridId',
                  builder: (context, state) {
                    final gridId = state.pathParameters['gridId'] ?? 'MC-204';
                    // gridId dari URL diteruskan sebagai data ke halaman detail.
                    return AreaDetailPage(gridId: gridId);
                  },
                  routes: [
                    GoRoute(
                      path: 'factors',
                      builder: (context, state) {
                        final gridId =
                            state.pathParameters['gridId'] ?? 'MC-204';
                        return ContributingFactorsPage(
                          gridId: gridId,
                          repository: urbanHeatFeatureRepository,
                        );
                      },
                    ),
                    GoRoute(
                      path: 'mitigation',
                      builder: (context, state) {
                        final gridId =
                            state.pathParameters['gridId'] ?? 'MC-204';
                        return MitigationPage(
                          gridId: gridId,
                          repository: urbanHeatFeatureRepository,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        // Tab 3: Profile
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfilePage(),
            ),
          ],
        ),
      ],
    ),
  ],
);
