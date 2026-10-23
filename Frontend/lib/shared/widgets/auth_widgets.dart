import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.obscureText = false,
    this.suffixIcon,
    this.errorText,
    this.focusNode,
    this.onChanged,
    this.onFocusChange,
    this.onSubmitted,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? errorText;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<bool>? onFocusChange;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final borderColor = errorText == null
        ? AppColors.border
        : AppColors.heatHigh;
    final border = OutlineInputBorder(
      borderRadius: AppSpacing.roundedSm,
      borderSide: BorderSide(color: borderColor),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: AppSpacing.xs),
        Focus(
          onFocusChange: onFocusChange,
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            autofillHints: autofillHints,
            obscureText: obscureText,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: AppSpacing.cardPaddingAll,
              suffixIcon: suffixIcon,
              errorText: errorText,
              border: border,
              enabledBorder: border,
              focusedBorder: OutlineInputBorder(
                borderRadius: AppSpacing.roundedSm,
                borderSide: const BorderSide(color: AppColors.accent),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: AppSpacing.roundedSm,
                borderSide: const BorderSide(color: AppColors.heatHigh),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: AppSpacing.roundedSm,
                borderSide: const BorderSide(color: AppColors.heatHigh),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AuthOutlinedButton extends StatelessWidget {
  const AuthOutlinedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.leading,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: AppSpacing.roundedSm,
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppSpacing.roundedSm,
        child: Container(
          constraints: const BoxConstraints(minHeight: 54),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: AppSpacing.roundedSm,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (leading != null)
                leading!
              else if (icon != null)
                Icon(icon, color: AppColors.primary),
              if (leading != null || icon != null)
                const SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(AppSpacing.xl + AppSpacing.lg),
          backgroundColor: AppColors.accent,
          disabledBackgroundColor: AppColors.accent.withValues(alpha: 0.4),
          foregroundColor: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: AppSpacing.roundedSm),
          textStyle: AppTextStyles.body.copyWith(
            color: AppColors.surface,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: AppSpacing.md,
                height: AppSpacing.md,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.surface,
                ),
              )
            : Text(label),
      ),
    );
  }
}

class AuthBackButton extends StatelessWidget {
  const AuthBackButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
        color: AppColors.surface,
        borderRadius: AppSpacing.roundedSm,
        child: InkWell(
          onTap: onPressed,
          borderRadius: AppSpacing.roundedSm,
          child: const SizedBox(
            width: AppSpacing.xl + AppSpacing.xs,
            height: AppSpacing.xl + AppSpacing.xs,
            child: Icon(Icons.arrow_back_rounded),
          ),
        ),
      ),
    );
  }
}
