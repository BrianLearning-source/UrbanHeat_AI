import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:urbanheat_ai/features/auth/domain/entities/app_user.dart';
import 'package:urbanheat_ai/features/auth/domain/repositories/auth_repository.dart';
import 'package:urbanheat_ai/app/app.dart';
import 'package:urbanheat_ai/app/router.dart';
import 'package:urbanheat_ai/features/auth/presentation/pages/login_page.dart';
import 'package:urbanheat_ai/features/auth/presentation/pages/register_page.dart';

void main() {
  testWidgets('UrbanHeat AI initial smoke and navigation test', (
    WidgetTester tester,
  ) async {
    final authRepository = _TestAuthRepository(authenticated: true);
    final router = createAppRouter(authRepository: authRepository);
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      router.dispose();
      unawaited(authRepository.dispose());
    });

    router.go('/home');
    await tester.pumpWidget(UrbanHeatApp(router: router));
    await tester.pumpAndSettle();

    // 1. Start the smoke flow at Home, where the navigation test begins.
    expect(find.text('Good morning, Nasywa'), findsOneWidget);
    expect(find.text('City-wide Heat\nOutlook (Kota\nMalang)'), findsOneWidget);

    // Scroll to and tap "Explore City Heatmap →" -> /heatmap
    final exploreHeatmapFinder = find.text('Explore City Heatmap →');
    await tester.ensureVisible(exploreHeatmapFinder);
    await tester.pumpAndSettle();
    await tester.tap(exploreHeatmapFinder);
    await tester.pumpAndSettle();
    expect(find.text('City Heatmap'), findsOneWidget);
    expect(find.text('Unable to load heatmap data'), findsOneWidget);

    // 2. Navigate to Prediction Result (/heatmap/prediction)
    router.go('/heatmap/prediction');
    await tester.pumpAndSettle();
    expect(find.text('Prediction Result'), findsOneWidget);
    expect(find.text('XGBoost Spatio-Temporal Regressor'), findsOneWidget);

    // Scroll to and tap "View Detailed Analysis →" -> /hotspots/area/LW-A12/factors
    final viewDetailedFinder = find.text('View Detailed Analysis →');
    await tester.ensureVisible(viewDetailedFinder);
    await tester.pumpAndSettle();
    await tester.tap(viewDetailedFinder);
    await tester.pumpAndSettle();
    expect(find.text('Contributing Factors'), findsOneWidget);
    expect(find.text('Built-up Surface Area'), findsOneWidget);

    // Scroll to and tap "Explore Mitigation Insights →" -> /hotspots/area/LW-A12/mitigation
    final exploreMitigationFinder = find.text('Explore Mitigation Insights →');
    await tester.ensureVisible(exploreMitigationFinder);
    await tester.pumpAndSettle();
    await tester.tap(exploreMitigationFinder);
    await tester.pumpAndSettle();
    expect(find.text('Suggested Mitigation\nMeasures'), findsOneWidget);

    // Scroll to and tap "Export Planning Summary (PDF)" -> SnackBar "Coming soon"
    final exportPdfFinder = find.text('Export Planning Summary (PDF)');
    await tester.ensureVisible(exportPdfFinder);
    await tester.pumpAndSettle();
    await tester.tap(exportPdfFinder);
    await tester.pump();
    expect(find.text('Coming soon'), findsOneWidget);

    // Tap "Back to Heatmap" -> /heatmap
    final backToHeatmapFinder = find.text('Back to Heatmap');
    await tester.ensureVisible(backToHeatmapFinder);
    await tester.pumpAndSettle();
    await tester.tap(backToHeatmapFinder);
    await tester.pumpAndSettle();
    expect(find.text('City Heatmap'), findsOneWidget);

    // 3. Navigate to Hotspots tab (/hotspots)
    router.go('/hotspots');
    await tester.pumpAndSettle();
    expect(find.text('Potential Hotspots'), findsOneWidget);

    // Tap the available "View on Heatmap" action -> /heatmap
    final viewOnHeatmapFinder = find.text('View on Heatmap');
    await tester.ensureVisible(viewOnHeatmapFinder);
    await tester.pumpAndSettle();
    await tester.tap(viewOnHeatmapFinder);
    await tester.pumpAndSettle();
    expect(find.text('City Heatmap'), findsOneWidget);

    // 4. Navigate to Area Detail (/hotspots/area/MC-204)
    router.go('/hotspots/area/MC-204');
    await tester.pumpAndSettle();
    expect(find.text('Area Detail'), findsOneWidget);
    expect(find.text('Grid #MC-204 · Central'), findsOneWidget);

    // Scroll to and tap the SHAP link -> factors
    final modelInfoFinder = find.text('Tap to view feature impact (SHAP) →');
    await tester.ensureVisible(modelInfoFinder);
    await tester.pumpAndSettle();
    await tester.tap(modelInfoFinder);
    await tester.pumpAndSettle();
    expect(find.text('Contributing Factors'), findsOneWidget);

    // 5. Navigate to Profile tab (/profile)
    router.go('/profile');
    await tester.pumpAndSettle();
    expect(find.text('Nasywa'), findsOneWidget);
    expect(find.text('Project Information'), findsOneWidget);

    await tester.tap(find.text('Sign Out'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('unauthenticated users cannot access private routes', (
    WidgetTester tester,
  ) async {
    final authRepository = _TestAuthRepository(authenticated: false);
    final router = createAppRouter(authRepository: authRepository);
    addTearDown(() {
      router.dispose();
      unawaited(authRepository.dispose());
    });

    router.go('/profile');
    await tester.pumpWidget(UrbanHeatApp(router: router));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Nasywa'), findsNothing);
  });

  testWidgets('registration with an active session opens Home', (
    WidgetTester tester,
  ) async {
    final authRepository = _TestAuthRepository(authenticated: false);
    final router = createAppRouter(authRepository: authRepository);
    addTearDown(() {
      router.dispose();
      unawaited(authRepository.dispose());
    });

    router.go('/register');
    await tester.pumpWidget(UrbanHeatApp(router: router));
    await tester.pumpAndSettle();
    await _submitRegistration(tester);

    expect(authRepository.signUpName, 'Test User');
    expect(authRepository.signUpEmail, 'test@example.com');
    expect(authRepository.signUpPassword, 'password123');
    expect(find.text('Good morning, Nasywa'), findsOneWidget);
  });

  testWidgets('registration without a session remains unauthenticated', (
    WidgetTester tester,
  ) async {
    final authRepository = _TestAuthRepository(
      authenticated: false,
      signUpCreatesSession: false,
    );
    final router = createAppRouter(authRepository: authRepository);
    addTearDown(() {
      router.dispose();
      unawaited(authRepository.dispose());
    });

    router.go('/register');
    await tester.pumpWidget(UrbanHeatApp(router: router));
    await tester.pumpAndSettle();
    await _submitRegistration(tester);

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Nasywa'), findsNothing);
  });

  testWidgets('login restores the originally requested protected route', (
    WidgetTester tester,
  ) async {
    final authRepository = _TestAuthRepository(authenticated: false);
    final router = createAppRouter(authRepository: authRepository);
    addTearDown(() {
      router.dispose();
      unawaited(authRepository.dispose());
    });

    router.go('/heatmap/prediction');
    await tester.pumpWidget(UrbanHeatApp(router: router));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);

    await _submitLogin(tester);

    expect(find.text('Prediction Result'), findsOneWidget);
  });

  testWidgets(
    'authenticated users are redirected away from splash/onboarding',
    (WidgetTester tester) async {
      final authRepository = _TestAuthRepository(authenticated: true);
      final router = createAppRouter(authRepository: authRepository);
      addTearDown(() {
        router.dispose();
        unawaited(authRepository.dispose());
      });

      router.go('/splash');
      await tester.pumpWidget(UrbanHeatApp(router: router));
      await tester.pumpAndSettle();

      expect(find.text('Good morning, Nasywa'), findsOneWidget);

      router.go('/onboarding');
      await tester.pumpAndSettle();
      expect(find.text('Good morning, Nasywa'), findsOneWidget);
    },
  );

  testWidgets('login failure shows a friendly message and stays on login', (
    WidgetTester tester,
  ) async {
    final authRepository = _TestAuthRepository(
      authenticated: false,
      signInError: StateError('sensitive test detail'),
    );
    final router = createAppRouter(authRepository: authRepository);
    addTearDown(() {
      router.dispose();
      unawaited(authRepository.dispose());
    });

    router.go('/login');
    await tester.pumpWidget(UrbanHeatApp(router: router));
    await tester.pumpAndSettle();
    await _submitLogin(tester);

    expect(find.textContaining('Login gagal.'), findsOneWidget);
    expect(find.textContaining('sensitive test detail'), findsNothing);
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('registration failure shows a friendly message', (
    WidgetTester tester,
  ) async {
    final authRepository = _TestAuthRepository(
      authenticated: false,
      signUpError: StateError('sensitive test detail'),
    );
    final router = createAppRouter(authRepository: authRepository);
    addTearDown(() {
      router.dispose();
      unawaited(authRepository.dispose());
    });

    router.go('/register');
    await tester.pumpWidget(UrbanHeatApp(router: router));
    await tester.pumpAndSettle();
    await _submitRegistration(tester);

    expect(find.byType(RegisterScreen), findsOneWidget);
    expect(find.textContaining('Registration failed.'), findsOneWidget);
    expect(find.textContaining('sensitive test detail'), findsNothing);
  });
}

Future<void> _submitLogin(WidgetTester tester) async {
  final email = find.byType(TextField).first;
  await tester.enterText(email, 'test@example.com');
  await tester.pumpAndSettle();
  final password = find.byType(TextField).last;
  await tester.enterText(password, 'password123');
  await tester.pumpAndSettle();

  final loginButton = find.widgetWithText(ElevatedButton, 'Log in');
  await tester.ensureVisible(loginButton);
  await tester.tap(loginButton);
  await tester.pumpAndSettle();
}

Future<void> _submitRegistration(WidgetTester tester) async {
  final fields = find.byType(TextField);
  await tester.enterText(fields.at(0), 'Test User');
  await tester.enterText(fields.at(1), 'test@example.com');
  await tester.enterText(fields.at(2), 'password123');
  await tester.enterText(fields.at(3), 'password123');
  await tester.pumpAndSettle();

  final submitButton = find.widgetWithText(ElevatedButton, 'Create account');
  await tester.ensureVisible(submitButton);
  await tester.tap(submitButton);
  await tester.pumpAndSettle();
}

class _TestAuthRepository implements AuthRepository {
  _TestAuthRepository({
    required bool authenticated,
    this.signUpCreatesSession = true,
    this.signInError,
    this.signUpError,
  }) : _isAuthenticated = authenticated;

  final StreamController<AppUser?> _authChanges =
      StreamController<AppUser?>.broadcast();
  final bool signUpCreatesSession;
  final Object? signInError;
  final Object? signUpError;
  bool _isAuthenticated;
  String? signUpName;
  String? signUpEmail;
  String? signUpPassword;

  static const _testUser = AppUser(id: 'test-user', email: 'test@example.com');

  @override
  bool get isAuthenticated => _isAuthenticated;

  @override
  Stream<AppUser?> get authStateChanges => _authChanges.stream;

  @override
  Future<AppUser?> getCurrentUser() async =>
      _isAuthenticated ? _testUser : null;

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    if (signInError != null) throw signInError!;
    _isAuthenticated = true;
    _authChanges.add(_testUser);
    return _testUser;
  }

  @override
  Future<void> signOut() async {
    _isAuthenticated = false;
    _authChanges.add(null);
  }

  @override
  Future<AppUser?> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    if (signUpError != null) throw signUpError!;
    signUpName = fullName;
    signUpEmail = email;
    signUpPassword = password;
    if (!signUpCreatesSession) return null;

    _isAuthenticated = true;
    _authChanges.add(_testUser);
    return _testUser;
  }

  Future<void> dispose() => _authChanges.close();
}
