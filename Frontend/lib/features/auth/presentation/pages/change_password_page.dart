import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/auth_widgets.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  final _currentFocus = FocusNode();
  final _newFocus = FocusNode();
  final _confirmFocus = FocusNode();
  bool _currentTouched = false;
  bool _newTouched = false;
  bool _confirmTouched = false;
  bool _submitted = false;
  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;
  bool _isSubmitting = false;

  bool get _valid =>
      _currentController.text.isNotEmpty &&
      _newController.text.length >= 8 &&
      _newController.text != _currentController.text &&
      _confirmController.text == _newController.text;

  String? get _currentError =>
      (_submitted || _currentTouched) && _currentController.text.isEmpty
      ? 'Enter your current password'
      : null;

  String? get _newError {
    if (!_submitted && !_newTouched) return null;
    if (_newController.text.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (_newController.text == _currentController.text) {
      return 'Choose a password different from your current one';
    }
    return null;
  }

  String? get _confirmError =>
      (_submitted || _confirmTouched) &&
          _confirmController.text != _newController.text
      ? 'Passwords do not match'
      : null;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    _currentFocus.dispose();
    _newFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    setState(() => _submitted = true);
    if (!_valid) return;

    setState(() => _isSubmitting = true);
    // TODO: connect to backend change-password endpoint when available.
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Password updated (demo)')));
    context.pop();
  }

  Widget _visibilityButton({
    required bool visible,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
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
                    AuthBackButton(onPressed: () => context.pop()),
                    const SizedBox(height: AppSpacing.lg),
                    Text('Change password', style: AppTextStyles.pageTitle),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Use at least 8 characters.',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AuthTextField(
                      label: 'Current password',
                      hint: 'Your current password',
                      controller: _currentController,
                      focusNode: _currentFocus,
                      obscureText: !_showCurrent,
                      textInputAction: TextInputAction.next,
                      errorText: _currentError,
                      suffixIcon: _visibilityButton(
                        visible: _showCurrent,
                        onPressed: () =>
                            setState(() => _showCurrent = !_showCurrent),
                      ),
                      onChanged: (_) => setState(() {}),
                      onFocusChange: (focused) {
                        if (!focused) {
                          setState(() => _currentTouched = true);
                        }
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AuthTextField(
                      label: 'New password',
                      hint: 'Create a new password',
                      controller: _newController,
                      focusNode: _newFocus,
                      obscureText: !_showNew,
                      textInputAction: TextInputAction.next,
                      errorText: _newError,
                      suffixIcon: _visibilityButton(
                        visible: _showNew,
                        onPressed: () => setState(() => _showNew = !_showNew),
                      ),
                      onChanged: (_) => setState(() {}),
                      onFocusChange: (focused) {
                        if (!focused) setState(() => _newTouched = true);
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AuthTextField(
                      label: 'Confirm new password',
                      hint: 'Repeat your new password',
                      controller: _confirmController,
                      focusNode: _confirmFocus,
                      obscureText: !_showConfirm,
                      textInputAction: TextInputAction.done,
                      errorText: _confirmError,
                      suffixIcon: _visibilityButton(
                        visible: _showConfirm,
                        onPressed: () =>
                            setState(() => _showConfirm = !_showConfirm),
                      ),
                      onChanged: (_) => setState(() {}),
                      onFocusChange: (focused) {
                        if (!focused) setState(() => _confirmTouched = true);
                      },
                      onSubmitted: (_) => _updatePassword(),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AuthPrimaryButton(
                      label: 'Update password',
                      onPressed: _valid ? _updatePassword : null,
                      isLoading: _isSubmitting,
                    ),
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
