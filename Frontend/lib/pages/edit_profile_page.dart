import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../app/theme/app_colors.dart';
import '../app/theme/app_spacing.dart';
import '../app/theme/app_text_styles.dart';
import '../data/repositories/urban_heat_repository.dart';
import 'auth_widgets.dart';

class EditProfileArguments {
  const EditProfileArguments({required this.name, this.photoPath});

  final String name;
  final String? photoPath;
}

class EditProfileResult {
  const EditProfileResult({required this.name, this.photoPath});

  final String name;
  final String? photoPath;
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, this.initialName, this.initialPhotoPath});

  final String? initialName;
  final String? initialPhotoPath;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController;
  final FocusNode _nameFocus = FocusNode();
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _pickedPhoto;
  bool _photoRemoved = false;
  bool _nameTouched = false;
  bool _submitted = false;
  bool _isSaving = false;

  String get _initialName => widget.initialName ?? urbanHeatRepository.userName;
  String? get _photoPath =>
      _photoRemoved ? null : (_pickedPhoto?.path ?? widget.initialPhotoPath);
  bool get _photoChanged => _photoRemoved || _pickedPhoto != null;
  bool get _nameValid {
    final name = _nameController.text.trim();
    return name.length >= 2 && name.length <= 50;
  }

  bool get _hasChanges =>
      _nameController.text.trim() != _initialName.trim() || _photoChanged;
  String? get _nameError => (_nameTouched || _submitted) && !_nameValid
      ? 'Enter a name between 2 and 50 characters'
      : null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _initialName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _showPhotoOptions() async {
    final action = await showModalBottomSheet<_PhotoAction>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.md),
        ),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from gallery'),
                onTap: () => Navigator.pop(context, _PhotoAction.choose),
              ),
              if (_photoPath != null)
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.heatHigh,
                  ),
                  title: Text(
                    'Remove photo',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.heatHigh,
                    ),
                  ),
                  onTap: () => Navigator.pop(context, _PhotoAction.remove),
                ),
              ListTile(
                leading: const Icon(Icons.close_rounded),
                title: const Text('Cancel'),
                onTap: () => Navigator.pop(context, _PhotoAction.cancel),
              ),
            ],
          ),
        ),
      ),
    );

    if (!mounted || action == null || action == _PhotoAction.cancel) return;
    if (action == _PhotoAction.remove) {
      setState(() {
        _photoRemoved = true;
        _pickedPhoto = null;
      });
      return;
    }

    try {
      final photo = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (!mounted) return;
      if (photo == null) {
        _showMessage('No photo selected.');
        return;
      }
      setState(() {
        _pickedPhoto = photo;
        _photoRemoved = false;
      });
    } on PlatformException {
      if (mounted) {
        _showMessage(
          'Photo access is unavailable. Check your photo permissions.',
        );
      }
    } catch (_) {
      if (mounted) _showMessage('Could not open the photo gallery.');
    }
  }

  Future<void> _saveChanges() async {
    setState(() => _submitted = true);
    if (!_hasChanges || !_nameValid) return;

    setState(() => _isSaving = true);
    // TODO: connect to backend update-profile endpoint when available.
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    final result = EditProfileResult(
      name: _nameController.text.trim(),
      photoPath: _photoPath,
    );
    setState(() => _isSaving = false);
    _showMessage('Profile updated (demo)');
    context.pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final avatar = _photoPath;
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
                    Text('Edit profile', style: AppTextStyles.pageTitle),
                    const SizedBox(height: AppSpacing.lg),
                    Center(
                      child: GestureDetector(
                        onTap: _showPhotoOptions,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.lg,
                              ),
                              child: Container(
                                width: AppSpacing.xl * 3,
                                height: AppSpacing.xl * 3,
                                color: AppColors.primary.withValues(
                                  alpha: 0.08,
                                ),
                                child: avatar == null
                                    ? const Icon(
                                        Icons.person_rounded,
                                        size: AppSpacing.xl * 2,
                                        color: AppColors.primary,
                                      )
                                    : Image.file(
                                        File(avatar),
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) => const Icon(
                                          Icons.person_rounded,
                                          size: AppSpacing.xl * 2,
                                          color: AppColors.primary,
                                        ),
                                      ),
                              ),
                            ),
                            Positioned(
                              right: -AppSpacing.xs,
                              bottom: -AppSpacing.xs,
                              child: Material(
                                color: AppColors.accent,
                                shape: const CircleBorder(),
                                child: InkWell(
                                  onTap: _showPhotoOptions,
                                  customBorder: const CircleBorder(),
                                  child: const SizedBox(
                                    width: AppSpacing.xl,
                                    height: AppSpacing.xl,
                                    child: Icon(
                                      Icons.camera_alt_outlined,
                                      color: AppColors.surface,
                                      size: AppSpacing.md,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AuthTextField(
                      label: 'Full name',
                      hint: 'Your full name',
                      controller: _nameController,
                      focusNode: _nameFocus,
                      textInputAction: TextInputAction.done,
                      errorText: _nameError,
                      onChanged: (_) => setState(() {}),
                      onFocusChange: (focused) {
                        if (!focused) setState(() => _nameTouched = true);
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AuthPrimaryButton(
                      label: 'Save changes',
                      isLoading: _isSaving,
                      onPressed: _hasChanges && _nameValid
                          ? _saveChanges
                          : null,
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

enum _PhotoAction { choose, remove, cancel }
