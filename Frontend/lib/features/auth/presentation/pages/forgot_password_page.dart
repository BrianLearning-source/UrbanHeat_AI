import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/auth_widgets.dart';
import '../../domain/repositories/auth_repository.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({
    super.key,
    required this.authRepository,
    this.initialEmail,
  });

  final AuthRepository authRepository;
  final String? initialEmail;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late final TextEditingController _emailController;

  bool _isSubmitting = false;
  bool _submitted = false;
  bool _emailSent = false;

  bool get _isValidEmail {
    final email = _emailController.text.trim();
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);
  }

  String? get _emailError {
    if (!_submitted) return null;

    if (_emailController.text.trim().isEmpty) {
      return 'Enter your email address';
    }

    if (!_isValidEmail) {
      return 'Enter a valid email address';
    }

    return null;
  }

  @override
  void initState() {
    super.initState();

    // Mengisi email otomatis jika pengguna datang dari Login Page.
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendRecoveryEmail() async {
    setState(() => _submitted = true);

    if (!_isValidEmail) return;

    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);

    try {
      // Mengarahkan pengguna kembali ke route Reset Password.
      // Proyek saat ini menggunakan Flutter Web dengan hash routing.
      final redirectTo = Uri.base
          .replace(path: '/', query: null, fragment: '/reset-password')
          .toString();

      await widget.authRepository.sendPasswordRecoveryEmail(
        email: _emailController.text.trim(),
        redirectTo: redirectTo,
      );

      if (!mounted) return;

      setState(() => _emailSent = true);
    } catch (error) {
      debugPrint('Password recovery request failed (${error.runtimeType}).');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to send recovery email. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
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
                    AuthBackButton(onPressed: () => context.pop()),
                    const SizedBox(height: AppSpacing.lg),

                    Text('Forgot password?', style: AppTextStyles.pageTitle),
                    const SizedBox(height: AppSpacing.xs),

                    Text(
                      'Enter your registered email address. '
                      'We will send you a link to reset your password.',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    if (!_emailSent) ...[
                      AuthTextField(
                        label: 'Email',
                        hint: 'Enter your email address',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.email],
                        errorText: _emailError,
                        onChanged: (_) => setState(() {}),
                        onSubmitted: (_) => _sendRecoveryEmail(),
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      AuthPrimaryButton(
                        label: 'Send recovery link',
                        onPressed: _isValidEmail ? _sendRecoveryEmail : null,
                        isLoading: _isSubmitting,
                      ),
                    ] else ...[
                      Container(
                        padding: AppSpacing.cardPaddingAll,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: AppSpacing.roundedSm,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.mark_email_read_outlined,
                              size: 48,
                              color: AppColors.primary,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              'Check your email',
                              style: AppTextStyles.body.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'If an account exists for '
                              '${_emailController.text.trim()}, '
                              'a password recovery link has been sent. '
                              'Please check your inbox and spam folder.',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.md),

                      TextButton(
                        onPressed: () {
                          setState(() {
                            _emailSent = false;
                            _submitted = false;
                          });
                        },
                        child: const Text('Use another email'),
                      ),

                      TextButton(
                        onPressed: _isSubmitting ? null : _sendRecoveryEmail,
                        child: const Text('Resend recovery email'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
