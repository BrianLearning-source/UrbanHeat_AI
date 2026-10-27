import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urbanheat_ai/features/auth/data/repositories/supabase_auth_repository.dart';

void main() {
  late _FakeSupabaseAuth auth;
  late _FakeSupabaseClient client;
  late SupabaseAuthRepository repository;

  setUp(() {
    auth = _FakeSupabaseAuth();
    client = _FakeSupabaseClient(auth);
    repository = SupabaseAuthRepository(client);
  });

  tearDown(() {
    auth.dispose();
    return client.dispose();
  });

  test(
    'signUp forwards credentials and returns a user only with a session',
    () async {
      auth.signUpResponse = AuthResponse(session: _session);

      final user = await repository.signUp(
        fullName: 'Test User',
        email: ' test@example.com ',
        password: 'password123',
      );

      expect(auth.signUpEmail, 'test@example.com');
      expect(auth.signUpPassword, 'password123');
      expect(auth.signUpMetadata, {'full_name': 'Test User'});
      expect(user?.id, 'user-1');
      expect(repository.isAuthenticated, isTrue);
    },
  );

  test('signUp without a session does not authenticate the user', () async {
    auth.signUpResponse = AuthResponse(user: _user);

    final user = await repository.signUp(
      fullName: 'Test User',
      email: 'test@example.com',
      password: 'password123',
    );

    expect(user, isNull);
    expect(repository.isAuthenticated, isFalse);
    expect(await repository.getCurrentUser(), isNull);
  });

  test('signIn requires and maps an active session', () async {
    auth.signInResponse = AuthResponse(session: _session);
    final authStateFuture = repository.authStateChanges.first;

    final user = await repository.signIn(
      email: ' test@example.com ',
      password: 'password123',
    );

    expect(auth.signInEmail, 'test@example.com');
    expect(auth.signInPassword, 'password123');
    expect(user.id, 'user-1');
    expect(repository.isAuthenticated, isTrue);
    expect((await repository.getCurrentUser())?.id, 'user-1');
    expect((await authStateFuture)?.id, 'user-1');
  });

  test('signIn rejects a response that has a user but no session', () async {
    auth.signInResponse = AuthResponse(user: _user);

    await expectLater(
      repository.signIn(email: 'test@example.com', password: 'password123'),
      throwsA(isA<AuthException>()),
    );
    expect(repository.isAuthenticated, isFalse);
  });

  test('signOut clears session and emits unauthenticated state', () async {
    auth.session = _session;
    final states = repository.authStateChanges;

    final stateFuture = states.first;
    await repository.signOut();

    expect(await stateFuture, isNull);
    expect(repository.isAuthenticated, isFalse);
    expect(await repository.getCurrentUser(), isNull);
  });
}

final _user = User(
  id: 'user-1',
  appMetadata: const {},
  userMetadata: const {'full_name': 'Test User'},
  aud: 'authenticated',
  email: 'test@example.com',
  createdAt: '2026-01-01T00:00:00Z',
);

final _session = Session(
  accessToken: 'test-access-token',
  refreshToken: 'test-refresh-token',
  tokenType: 'bearer',
  user: _user,
);

class _FakeSupabaseClient extends SupabaseClient {
  _FakeSupabaseClient(this.fakeAuth)
    : super(
        'https://example.supabase.co',
        'test-publishable-key',
        authOptions: const AuthClientOptions(autoRefreshToken: false),
      );

  final _FakeSupabaseAuth fakeAuth;

  @override
  GoTrueClient get auth => fakeAuth;
}

class _FakeSupabaseAuth extends GoTrueClient {
  _FakeSupabaseAuth()
    : super(
        url: 'https://example.supabase.co/auth/v1',
        autoRefreshToken: false,
      );

  final _events = StreamController<AuthState>.broadcast();
  Session? session;
  AuthResponse signUpResponse = AuthResponse(user: _user);
  AuthResponse signInResponse = AuthResponse(user: _user);
  String? signUpEmail;
  String? signUpPassword;
  Map<String, dynamic>? signUpMetadata;
  String? signInEmail;
  String? signInPassword;

  @override
  Session? get currentSession => session;

  @override
  User? get currentUser => session?.user;

  @override
  Stream<AuthState> get onAuthStateChange => _events.stream;

  @override
  Future<AuthResponse> signUp({
    String? email,
    String? phone,
    required String password,
    String? emailRedirectTo,
    Map<String, dynamic>? data,
    String? captchaToken,
    OtpChannel channel = OtpChannel.sms,
  }) async {
    signUpEmail = email;
    signUpPassword = password;
    signUpMetadata = data;
    session = signUpResponse.session;
    if (session != null) {
      _events.add(AuthState(AuthChangeEvent.signedIn, session));
    }
    return signUpResponse;
  }

  @override
  Future<AuthResponse> signInWithPassword({
    String? email,
    String? phone,
    required String password,
    String? captchaToken,
  }) async {
    signInEmail = email;
    signInPassword = password;
    session = signInResponse.session;
    if (session != null) {
      _events.add(AuthState(AuthChangeEvent.signedIn, session));
    }
    return signInResponse;
  }

  @override
  Future<void> signOut({SignOutScope scope = SignOutScope.local}) async {
    session = null;
    _events.add(const AuthState(AuthChangeEvent.signedOut, null));
  }

  @override
  void dispose() {
    unawaited(_events.close());
    super.dispose();
  }
}
