import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../data/models/planning_model.dart';
import '../../../../data/repositories/planning_repository.dart';
import '../../../../shared/widgets/animated_interaction.dart';
import '../../../../shared/widgets/info_card.dart';

class PlanningPage extends StatefulWidget {
  const PlanningPage({super.key});

  @override
  State<PlanningPage> createState() => _PlanningPageState();
}

class _PlanningPageState extends State<PlanningPage> {
  late Future<List<PlanningItem>> _planningFuture;
  final Set<String> _removingIds = <String>{};

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    _planningFuture = planningRepository.loadPlannings();
  }

  String _formatDate(DateTime dateTime) {
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$day/$month/${dateTime.year} $hour:$minute';
  }

  Future<void> _openPlannerDialog([PlanningItem? item]) async {
    final result = await showDialog<PlanningItem>(
      context: context,
      animationStyle: const AnimationStyle(
        duration: Duration(milliseconds: 280),
        reverseDuration: Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInOut,
      ),
      builder: (context) => _PlanningEditorDialog(existingItem: item),
    );

    if (result == null || !mounted) {
      return;
    }

    final saveResult = await planningRepository.savePlanning(result);
    if (!mounted) return;
    setState(_refresh);
    if (saveResult == PlanningWriteResult.localOnly) {
      _showLocalOnlyMessage('Plan saved on this device only.');
    }
  }

  Future<void> _toggleComplete(String id) async {
    final result = await planningRepository.markCompleted(id);
    if (!mounted) return;
    setState(_refresh);
    if (result == PlanningWriteResult.localOnly) {
      _showLocalOnlyMessage('Completion status saved on this device only.');
    }
  }

  Future<void> _deletePlanning(PlanningItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      animationStyle: const AnimationStyle(
        duration: Duration(milliseconds: 260),
        reverseDuration: Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInOut,
      ),
      builder: (context) => AlertDialog(
        title: const Text('Delete planning?'),
        content: Text('Delete "${item.title}" from your planning list?'),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => context.pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 260);
    setState(() => _removingIds.add(item.id));
    final deleteFuture = planningRepository.deletePlanning(item.id);
    PlanningWriteResult result;
    var deletionSucceeded = false;
    try {
      result = await deleteFuture;
      if (duration > Duration.zero) {
        await Future<void>.delayed(duration);
      }
      deletionSucceeded = true;
    } finally {
      if (!deletionSucceeded && mounted) {
        setState(() => _removingIds.remove(item.id));
      }
    }

    if (!mounted) return;
    setState(_refresh);
    if (result == PlanningWriteResult.localOnly) {
      _showLocalOnlyMessage('Plan removed on this device only.');
    }
  }

  void _showLocalOnlyMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.primary,
        elevation: 0,
        title: const Text('Planning & reminders'),
        actions: [
          PressScale(
            child: IconButton(
              onPressed: () => _openPlannerDialog(),
              icon: const Icon(Icons.add_rounded),
              tooltip: 'Add plan',
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<PlanningItem>>(
        future: _planningFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _ErrorState(onRetry: () => setState(_refresh));
          }

          final plannings = snapshot.data ?? const <PlanningItem>[];
          if (plannings.isEmpty) {
            return const _EmptyState();
          }

          final upcoming =
              plannings
                  .where((item) => item.status == PlanningStatus.upcoming)
                  .toList()
                ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
          final completed =
              plannings
                  .where((item) => item.status == PlanningStatus.completed)
                  .toList()
                ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              if (upcoming.isNotEmpty) ...[
                _SectionHeader(title: 'Upcoming'),
                const SizedBox(height: AppSpacing.sm),
                ...upcoming.indexed.map((entry) {
                  final (index, planning) = entry;
                  return Padding(
                    key: ValueKey(planning.id),
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _PlanningListItem(
                      item: planning,
                      index: index,
                      removing: _removingIds.contains(planning.id),
                      onEdit: () => _openPlannerDialog(planning),
                      onToggleComplete: () => _toggleComplete(planning.id),
                      onDelete: () => _deletePlanning(planning),
                      formattedDate: _formatDate(planning.scheduledAt),
                    ),
                  );
                }),
              ] else
                const _NoSectionItem(label: 'No upcoming plans'),
              const SizedBox(height: AppSpacing.md),
              if (completed.isNotEmpty) ...[
                _SectionHeader(title: 'Completed'),
                const SizedBox(height: AppSpacing.sm),
                ...completed.indexed.map((entry) {
                  final (index, planning) = entry;
                  final entranceIndex = upcoming.length + index;
                  return Padding(
                    key: ValueKey(planning.id),
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _PlanningListItem(
                      item: planning,
                      index: entranceIndex,
                      removing: _removingIds.contains(planning.id),
                      onEdit: () => _openPlannerDialog(planning),
                      onToggleComplete: () => _toggleComplete(planning.id),
                      onDelete: () => _deletePlanning(planning),
                      formattedDate: _formatDate(planning.scheduledAt),
                    ),
                  );
                }),
              ] else
                const _NoSectionItem(label: 'No completed plans'),
            ],
          );
        },
      ),
    );
  }
}

class _PlanningListItem extends StatelessWidget {
  const _PlanningListItem({
    required this.item,
    required this.index,
    required this.removing,
    required this.onEdit,
    required this.onToggleComplete,
    required this.onDelete,
    required this.formattedDate,
  });

  final PlanningItem item;
  final int index;
  final bool removing;
  final VoidCallback onEdit;
  final VoidCallback onToggleComplete;
  final VoidCallback onDelete;
  final String formattedDate;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return AnimatedSwitcher(
      duration: reduceMotion
          ? Duration.zero
          : const Duration(milliseconds: 260),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInOut,
      transitionBuilder: (child, animation) => SizeTransition(
        sizeFactor: animation,
        alignment: Alignment.topCenter,
        child: FadeTransition(opacity: animation, child: child),
      ),
      child: removing
          ? const SizedBox.shrink(key: ValueKey('removing'))
          : StaggeredEntrance(
              key: ValueKey(item.id),
              delay: Duration(milliseconds: index < 8 ? index * 45 : 360),
              child: _PlanningTile(
                item: item,
                onEdit: onEdit,
                onToggleComplete: onToggleComplete,
                onDelete: onDelete,
                formattedDate: formattedDate,
              ),
            ),
    );
  }
}

class _PlanningTile extends StatelessWidget {
  const _PlanningTile({
    required this.item,
    required this.onEdit,
    required this.onToggleComplete,
    required this.onDelete,
    required this.formattedDate,
  });

  final PlanningItem item;
  final VoidCallback onEdit;
  final VoidCallback onToggleComplete;
  final VoidCallback onDelete;
  final String formattedDate;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final animationDuration = reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 260);

    return PressScale(
      elevation: 1.5,
      shadowColor: AppColors.primary.withValues(alpha: 0.12),
      borderRadius: AppSpacing.roundedMd,
      child: InfoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.title,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                AnimatedContainer(
                  duration: animationDuration,
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: item.status == PlanningStatus.completed
                        ? AppColors.mitigation.withValues(alpha: 0.12)
                        : AppColors.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: AnimatedSwitcher(
                    duration: animationDuration,
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInOut,
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(scale: animation, child: child),
                    ),
                    child: Text(
                      item.status.label,
                      key: ValueKey(item.status),
                      style: AppTextStyles.caption.copyWith(
                        color: item.status == PlanningStatus.completed
                            ? AppColors.mitigation
                            : AppColors.accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (item.description.trim().isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                item.description,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    formattedDate,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                if (item.status == PlanningStatus.upcoming)
                  Expanded(
                    child: TextButton.icon(
                      onPressed: onToggleComplete,
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Complete'),
                    ),
                  ),
                Expanded(
                  child: TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_rounded),
                    label: const Text('Edit'),
                  ),
                ),
                Expanded(
                  child: TextButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_rounded),
                    label: const Text('Delete'),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanningEditorDialog extends StatefulWidget {
  const _PlanningEditorDialog({this.existingItem});

  final PlanningItem? existingItem;

  @override
  State<_PlanningEditorDialog> createState() => _PlanningEditorDialogState();
}

class _PlanningEditorDialogState extends State<_PlanningEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  DateTime? _selectedDateTime;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.existingItem?.title ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.existingItem?.description ?? '',
    );
    _selectedDateTime = widget.existingItem?.scheduledAt ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (!mounted) return;
    if (pickedDate == null) {
      return;
    }

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime ?? DateTime.now()),
    );

    if (!mounted) return;
    if (pickedTime == null) {
      return;
    }

    final nextDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    setState(() {
      _selectedDateTime = nextDateTime;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.existingItem == null ? 'Add planning' : 'Edit planning',
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Heat mitigation planning',
                ),
                validator: (value) {
                  final trimmed = value?.trim() ?? '';
                  if (trimmed.isEmpty) return 'Please enter a title.';
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _descriptionController,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Add context for this planning item',
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              InkWell(
                onTap: _pickDateTime,
                borderRadius: AppSpacing.roundedSm,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: AppSpacing.roundedSm,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.event_rounded, color: AppColors.primary),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          _selectedDateTime == null
                              ? 'Select date and time'
                              : 'Scheduled: ${_selectedDateTime!.day}/${_selectedDateTime!.month}/${_selectedDateTime!.year} ${_selectedDateTime!.hour.toString().padLeft(2, '0')}:${_selectedDateTime!.minute.toString().padLeft(2, '0')}',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => context.pop(), child: const Text('Cancel')),
        TextButton(
          onPressed: () {
            if (_selectedDateTime == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please choose a valid date and time.'),
                ),
              );
              return;
            }

            if (!_formKey.currentState!.validate()) {
              return;
            }

            final title = _titleController.text.trim();
            final description = _descriptionController.text.trim();
            final scheduledAt = _selectedDateTime!;
            if (scheduledAt.isBefore(DateTime.now())) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Date and time must be in the future.'),
                ),
              );
              return;
            }

            final now = DateTime.now();
            final item = PlanningItem(
              id: widget.existingItem?.id ?? 'p-${now.millisecondsSinceEpoch}',
              userId: widget.existingItem?.userId ?? 'guest-user',
              title: title,
              description: description,
              scheduledAt: scheduledAt,
              status: widget.existingItem?.status ?? PlanningStatus.upcoming,
              createdAt: widget.existingItem?.createdAt ?? now,
              updatedAt: now,
            );

            Navigator.of(context).pop(item);
          },
          child: Text(widget.existingItem == null ? 'Save' : 'Update'),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.sectionTitle.copyWith(color: AppColors.primary),
    );
  }
}

class _NoSectionItem extends StatelessWidget {
  const _NoSectionItem({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: AppSpacing.roundedSm,
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: reduceMotion ? 1 : 0.94, end: 1),
        duration: reduceMotion
            ? Duration.zero
            : const Duration(milliseconds: 340),
        curve: Curves.easeOutCubic,
        builder: (context, scale, child) => Opacity(
          opacity: reduceMotion ? 1 : scale.clamp(0, 1),
          child: Transform.scale(scale: reduceMotion ? 1 : scale, child: child),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.event_busy_rounded,
                size: 48,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: AppSpacing.md),
              Text('No planning items yet', style: AppTextStyles.sectionTitle),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Use the add button to create your first reminder.',
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppColors.accent,
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Unable to load planning', style: AppTextStyles.sectionTitle),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Please retry to refresh your schedule.',
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
