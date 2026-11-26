
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/auth_widgets.dart';
import '../../domain/repositories/auth_repository.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({
    super.key,
    required this.authRepository,
  });

  final AuthRepository authRepository;

  @override
  State<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState
    extends State<ResetPasswordScreen> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _showNewPassword = false;
  bool _showConfirmPassword = false;
  bool _submitted = false;
  bool _isSubmitting = false;
  bool _isUpdated = false;

  bool get _hasRecoverySession =>
      widget.authRepository.isAuthenticated;

  bool get _isValid =>
      _newPasswordController.text.length >= 8 &&
      _newPasswordController.text ==
          _confirmPasswordController.text;

  String? get _newPasswordError {
    if (!_submitted) return null;

    if (_newPasswordController.text.length < 8) {
      return 'Password must be at least 8 characters';
    }

    return null;
  }

  String? get _confirmPasswordError {
    if (!_submitted) return null;

    if (_confirmPasswordController.text !=
        _newPasswordController.text) {
      return 'Passwords do not match';
    }

    return null;
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    setState(() => _submitted = true);

    if (!_hasRecoverySession || !_isValid) return;

    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);

    try {
      await widget.authRepository.updatePasswordAfterRecovery(
        newPassword: _newPasswordController.text,
      );

      if (!mounted) return;

      setState(() => _isUpdated = true);
    } catch (error) {
      debugPrint(
        'Password reset failed (${error.runtimeType}).',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to reset password. '
            'Your recovery link may have expired. '
            'Please request a new one.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Widget _visibilityButton({
    required bool visible,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        visible
            ? Icons.visibility_off_outlined
            : Icons.visibility_outlined,
        color: AppColors.textSecondary,
      ),
    );
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
                    AuthBackButton(
                      onPressed: () => context.go('/login'),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    if (!_hasRecoverySession) ...[
                      Text(
                        'Recovery link unavailable',
                        style: AppTextStyles.pageTitle,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'This password recovery link is invalid, '
                        'expired, or has already been used. '
                        'Please request a new recovery email.',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      AuthPrimaryButton(
                        label: 'Request new recovery link',
                        onPressed: () =>
                            context.go('/forgot-password'),
                      ),
                    ] else if (_isUpdated) ...[
                      const Icon(
                        Icons.check_circle_outline_rounded,
                        size: 64,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'Password updated!',
                        style: AppTextStyles.pageTitle,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Your password has been reset successfully. '
                        'You can now continue using UrbanHeat AI.',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      AuthPrimaryButton(
                        label: 'Continue to UrbanHeat AI',
                        onPressed: () => context.go('/home'),
                      ),
                    ] else ...[
                      Text(
                        'Create new password',
                        style: AppTextStyles.pageTitle,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Use at least 8 characters.',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      AuthTextField(
                        label: 'New password',
                        hint: 'Create a new password',
                        controller: _newPasswordController,
                        obscureText: !_showNewPassword,
                        textInputAction: TextInputAction.next,
                        errorText: _newPasswordError,
                        onChanged: (_) => setState(() {}),
                        suffixIcon: _visibilityButton(
                          visible: _showNewPassword,
                          onPressed: () => setState(
                            () => _showNewPassword =
                                !_showNewPassword,
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.md),

                      AuthTextField(
                        label: 'Confirm new password',
                        hint: 'Repeat your new password',
                        controller: _confirmPasswordController,
                        obscureText: !_showConfirmPassword,
                        textInputAction: TextInputAction.done,
                        errorText: _confirmPasswordError,
                        onChanged: (_) => setState(() {}),
                        onSubmitted: (_) => _resetPassword(),
                        suffixIcon: _visibilityButton(
                          visible: _showConfirmPassword,
                          onPressed: () => setState(
                            () => _showConfirmPassword =
                                !_showConfirmPassword,
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      AuthPrimaryButton(
                        label: 'Reset password',
                        onPressed: _isValid ? _resetPassword : null,
                        isLoading: _isSubmitting,
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
