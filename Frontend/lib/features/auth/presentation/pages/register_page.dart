import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/auth_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  bool _nameTouched = false;
  bool _emailTouched = false;
  bool _passwordTouched = false;
  bool _confirmTouched = false;
  bool _submitted = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _isSubmitting = false;

  bool get _validEmail => _isValidEmail(_emailController.text.trim());
  bool get _canSubmit =>
      _nameController.text.trim().isNotEmpty &&
      _validEmail &&
      _passwordController.text.length >= 8 &&
      _confirmController.text == _passwordController.text &&
      !_isSubmitting;

  bool _isValidEmail(String email) =>
      RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  String? get _nameError =>
      (_submitted || _nameTouched) && _nameController.text.trim().isEmpty
      ? 'Enter your full name'
      : null;

  String? get _emailError => (_submitted || _emailTouched) && !_validEmail
      ? 'Enter a valid email address'
      : null;

  String? get _passwordError =>
      (_submitted || _passwordTouched) && _passwordController.text.length < 8
      ? 'Password must be at least 8 characters'
      : null;

  String? get _confirmError =>
      (_submitted || _confirmTouched) &&
          _confirmController.text != _passwordController.text
      ? 'Passwords do not match'
      : null;

  void _touch(void Function() markTouched) {
    setState(markTouched);
  }

  Future<void> _createAccount() async {
    setState(() => _submitted = true);
    if (!_canSubmit) return;

    setState(() => _isSubmitting = true);
    // TODO: connect to backend register endpoint when available.
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Account created (demo)')));
    context.go('/login');
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
                                onTap: () => context.go('/login'),
                                borderRadius: AppSpacing.roundedSm,
                                child: const SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: Icon(Icons.arrow_back_rounded),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            'Create account',
                            style: AppTextStyles.pageTitle,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Join UrbanHeat AI to explore heat maps and mitigation insights for Kota Malang.',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          AuthTextField(
                            label: 'Full name',
                            hint: 'Your full name',
                            controller: _nameController,
                            focusNode: _nameFocus,
                            textInputAction: TextInputAction.next,
                            errorText: _nameError,
                            onChanged: (_) => setState(() {}),
                            onFocusChange: (focused) {
                              if (!focused) _touch(() => _nameTouched = true);
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AuthTextField(
                            label: 'Email',
                            hint: 'Your email',
                            controller: _emailController,
                            focusNode: _emailFocus,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.email],
                            errorText: _emailError,
                            onChanged: (_) => setState(() {}),
                            onFocusChange: (focused) {
                              if (!focused) _touch(() => _emailTouched = true);
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AuthTextField(
                            label: 'Password',
                            hint: 'Create a password',
                            controller: _passwordController,
                            focusNode: _passwordFocus,
                            textInputAction: TextInputAction.next,
                            obscureText: !_showPassword,
                            errorText: _passwordError,
                            onChanged: (_) => setState(() {}),
                            onFocusChange: (focused) {
                              if (!focused) {
                                _touch(() => _passwordTouched = true);
                              }
                            },
                            suffixIcon: IconButton(
                              onPressed: () => setState(
                                () => _showPassword = !_showPassword,
                              ),
                              icon: Icon(
                                _showPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AuthTextField(
                            label: 'Confirm password',
                            hint: 'Repeat your password',
                            controller: _confirmController,
                            focusNode: _confirmFocus,
                            textInputAction: TextInputAction.done,
                            obscureText: !_showConfirmPassword,
                            errorText: _confirmError,
                            onChanged: (_) => setState(() {}),
                            onFocusChange: (focused) {
                              if (!focused) {
                                _touch(() => _confirmTouched = true);
                              }
                            },
                            suffixIcon: IconButton(
                              onPressed: () => setState(
                                () => _showConfirmPassword =
                                    !_showConfirmPassword,
                              ),
                              icon: Icon(
                                _showConfirmPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          SizedBox(
                            height: 54,
                            child: ElevatedButton(
                              onPressed: _canSubmit ? _createAccount : null,
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
                              child: _isSubmitting
                                  ? const SizedBox(
                                      width: AppSpacing.md,
                                      height: AppSpacing.md,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.surface,
                                      ),
                                    )
                                  : const Text('Create account'),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already have an account? ',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              InkWell(
                                onTap: () => context.go('/login'),
                                child: Text(
                                  'Log in',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
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
              child: Text.rich(
                TextSpan(
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  children: [
                    const TextSpan(
                      text: 'By creating an account, you agree to our ',
                    ),
                    TextSpan(
                      text: 'Terms of Use',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy policy',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const TextSpan(text: '.'),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
