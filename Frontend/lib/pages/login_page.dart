import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/theme/app_colors.dart';
import '../app/theme/app_spacing.dart';
import '../app/theme/app_text_styles.dart';
import '../features/auth/domain/repository/auth_repository.dart';
import 'auth_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.authRepository,
  });

  final AuthRepository authRepository;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late final AnimationController _passwordAnimation;
  bool _showPassword = false;
  bool _obscurePassword = true;
  bool _isSubmiting = false;
  bool get _validEmail => _isValidEmail(_emailController.text.trim());
  bool get _canLogIn =>
      _validEmail && (!_showPassword || _passwordController.text.length >= 8) && !_isSubmiting;

  @override
  void initState() {
    super.initState();
    _passwordAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _passwordAnimation.addStatusListener(_onPasswordAnimationStatus);
  }

  void _onPasswordAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.dismissed && mounted) setState(() {});
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordAnimation.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) =>
      RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);

  void _onEmailChanged(String value) {
    final isValid = _isValidEmail(value.trim());
    if (isValid != _showPassword) {
      setState(() => _showPassword = isValid);
      if (isValid) {
        _passwordAnimation.forward();
      } else {
        _passwordAnimation.reverse();
      }
    } else {
      setState(() {});
    }
  }

  Future<void> _logIn() async {
    if (!_canLogIn) return;

    // Sembunyikan keyboard. Aktifkan indikator loading
    FocusScope.of(context).unfocus();
    setState(() => _isSubmiting = true);

    try {
      // Meneruskan email dan kata sandi ke domain layer lalu repo akan panggil Supabase Auth
      await widget.authRepository.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // memastikan widget masih aktif sebelum melakukan navigasi
      if(!mounted) return;

      context.go('/home');
    } catch (e) {
      // Handle login error
    } finally {
      setState(() => _isSubmiting = false);
    }
  }

  void _signInWithGoogle() {
    // TODO: Connect this action to the authentication provider's Google sign-in flow.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: SingleChildScrollView(
                  padding: AppSpacing.screenPaddingAll,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Material(
                              color: AppColors.surface,
                              borderRadius: AppSpacing.roundedSm,
                              child: InkWell(
                                onTap: () => context.canPop()
                                    ? context.pop()
                                    : context.go('/home'),
                                borderRadius: AppSpacing.roundedSm,
                                child: const SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: Icon(Icons.arrow_back_rounded),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          Text('Log in', style: AppTextStyles.pageTitle),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Access UrbanHeat AI to explore city heat insights.',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          AuthTextField(
                            label: 'Email',
                            hint: 'Your email',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.email],
                            onChanged: _onEmailChanged,
                          ),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            alignment: Alignment.topCenter,
                            child:
                                _showPassword || _passwordAnimation.isAnimating
                                ? SizeTransition(
                                    sizeFactor: _passwordAnimation,
                                    alignment : Alignment.topCenter,
                                    child: FadeTransition(
                                      opacity: _passwordAnimation,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          top: AppSpacing.md,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            AuthTextField(
                                              label: 'Password',
                                              hint: 'Your password',
                                              controller: _passwordController,
                                              textInputAction:
                                                  TextInputAction.done,
                                              obscureText: _obscurePassword,
                                              onChanged: (_) => setState(() {}),
                                              onSubmitted: (_) => _logIn(),
                                              suffixIcon: IconButton(
                                                onPressed: () => setState(
                                                  () => _obscurePassword =
                                                      !_obscurePassword,
                                                ),
                                                icon: Icon(
                                                  _obscurePassword
                                                      ? Icons
                                                            .visibility_outlined
                                                      : Icons
                                                            .visibility_off_outlined,
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: AppSpacing.xs,
                                            ),
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: TextButton(
                                                onPressed: () {
                                                  // TODO: Add the password recovery flow.
                                                },
                                                style: TextButton.styleFrom(
                                                  padding: EdgeInsets.zero,
                                                  minimumSize: Size.zero,
                                                  tapTargetSize:
                                                      MaterialTapTargetSize
                                                          .shrinkWrap,
                                                ),
                                                child: Text(
                                                  'Forgot password?',
                                                  style: AppTextStyles.caption
                                                      .copyWith(
                                                        color:
                                                            AppColors.primary,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          SizedBox(
                            height: 54,
                            child: ElevatedButton(
                              onPressed: _canLogIn ? _logIn : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accent,
                                disabledBackgroundColor: AppColors.accent
                                    .withValues(alpha: 0.4),
                                foregroundColor: AppColors.surface,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: AppSpacing.roundedSm,
                                ),
                                textStyle: AppTextStyles.body.copyWith(
                                  color: AppColors.surface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              // child: const Text('Log in'),
                              child: _isSubmiting
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.surface,
                                      ),
                                    )
                                  : const Text('Log in'),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Row(
                            children: [
                              const Expanded(child: Divider()),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                ),
                                child: Text('Or', style: AppTextStyles.caption),
                              ),
                              const Expanded(child: Divider()),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          AuthOutlinedButton(
                            label: 'Sign in with Google',
                            leading: const Text(
                              'G',
                              style: TextStyle(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            onPressed: _signInWithGoogle,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AuthOutlinedButton(
                            label: 'Register with email',
                            icon: Icons.mail_outline_rounded,
                            onPressed: () => context.push('/register'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.sm,
                AppSpacing.screenPadding,
                AppSpacing.md,
              ),
              child: Text(
                'By logging in, you agree to our Terms of Use and Privacy Policy.',
                textAlign: TextAlign.center,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
