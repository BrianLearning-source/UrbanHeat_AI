import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../features/urban_heat/presentation/pages/heatmap_page.dart';
import '../features/urban_heat/presentation/pages/prediction_result_page.dart';
import '../features/urban_heat/presentation/pages/home_page.dart';
import '../features/urban_heat/presentation/pages/area_detail_page.dart';
import '../features/urban_heat/presentation/pages/contributing_factors_page.dart';
import '../features/urban_heat/presentation/pages/hotspots_page.dart';
import '../features/urban_heat/presentation/pages/mitigation_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/auth/domain/entities/app_user.dart';
import '../features/profile/presentation/pages/edit_profile_page.dart';
import '../features/auth/presentation/pages/change_password_page.dart';
import '../features/onboarding/presentation/pages/splash_pages.dart';
import '../features/onboarding/presentation/pages/onboarding_pages.dart';
import '../features/onboarding/data/repositories/shared_preferences_onboarding_repository.dart';
import '../features/onboarding/domain/repositories/onboarding_repository.dart';
import '../features/profile/data/repositories/mock_profile_repository.dart';
import '../features/profile/domain/repositories/profile_repository.dart';
import '../features/urban_heat/data/repositories/mock_urban_heat_repository.dart';
import '../features/urban_heat/domain/repositories/urban_heat_repository.dart';
import '../shared/widgets/app_bottom_nav.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/data/repositories/supabase_auth_repository.dart';

final AuthRepository authRepository = SupabaseAuthRepository(
  Supabase.instance.client,
);

// Feature dependencies are constructed here and passed into pages.
final UrbanHeatRepository urbanHeatFeatureRepository =
    const MockUrbanHeatRepository();
final ProfileRepository profileRepository = const MockProfileRepository();
final OnboardingRepository onboardingRepository =
    const SharedPreferencesOnboardingRepository();

final GoRouter appRouter = createAppRouter(authRepository: authRepository);

GoRouter createAppRouter({required AuthRepository authRepository}) {
  final authRefreshListenable = _AuthStateRefreshListenable(
    authRepository.authStateChanges,
  );

  return GoRouter(
    refreshListenable: authRefreshListenable,
    redirect: (context, state) {
      final location = state.uri.path;
      final isPublicRoute = const {
        '/splash',
        '/onboarding',
        '/login',
        '/register',
      }.contains(location);

      if (!authRepository.isAuthenticated && !isPublicRoute) {
        return Uri(
          path: '/login',
          queryParameters: {'from': state.uri.toString()},
        ).toString();
      }

      if (authRepository.isAuthenticated && isPublicRoute) {
        return '/home';
      }

      return null;
    },
    // Halaman pertama yang ditampilkan ketika aplikasi dibuka.
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) =>
            SplashScreen(repository: onboardingRepository),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) =>
            OnboardingScreen(repository: onboardingRepository),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginScreen(
          authRepository: authRepository,
          redirectLocation: state.uri.queryParameters['from'],
        ),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) =>
            RegisterScreen(authRepository: authRepository),
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) {
          final arguments = state.extra as EditProfileArguments?;
          return EditProfileScreen(
            initialName:
                arguments?.name ??
                profileRepository.getProfile().data?.name ??
                'Nasywa',
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
                builder: (context, state) => HomePage(
                  userName:
                      profileRepository.getProfile().data?.name ?? 'Nasywa',
                ),
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
                builder: (context, state) => ProfilePage(
                  repository: profileRepository,
                  authRepository: authRepository,
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

class _AuthStateRefreshListenable extends ChangeNotifier {
  _AuthStateRefreshListenable(Stream<AppUser?> authStateChanges) {
    _subscription = authStateChanges.listen(
      (_) => notifyListeners(),
      onError: (Object error, StackTrace stackTrace) {
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: error,
            stack: stackTrace,
            library: 'authentication route refresh',
          ),
        );
      },
    );
  }

  late final StreamSubscription<AppUser?> _subscription;

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
