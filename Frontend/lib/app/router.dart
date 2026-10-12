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
import '../shared/widgets/app_bottom_nav.dart';

// Key ini memberi GoRouter akses ke navigator utama aplikasi.
final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'rootNavigator');

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  // Halaman pertama yang ditampilkan ketika aplikasi dibuka.
  initialLocation: '/home',
  routes: [
    GoRoute(
      path: '/',
      redirect: (_, _) => '/home',
    ),
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
              builder: (context, state) => const HomePage(),
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
              builder: (context, state) => const HotspotsPage(),
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
                        final gridId = state.pathParameters['gridId'] ?? 'MC-204';
                        return ContributingFactorsPage(gridId: gridId);
                      },
                    ),
                    GoRoute(
                      path: 'mitigation',
                      builder: (context, state) {
                        final gridId = state.pathParameters['gridId'] ?? 'MC-204';
                        return MitigationPage(gridId: gridId);
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
