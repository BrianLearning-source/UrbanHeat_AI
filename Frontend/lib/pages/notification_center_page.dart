import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/theme/app_colors.dart';
import '../app/theme/app_spacing.dart';
import '../app/theme/app_text_styles.dart';
import '../data/models/notification_model.dart';
import '../data/repositories/notification_repository.dart';
import '../shared/widgets/animated_interaction.dart';

class NotificationCenterPage extends StatefulWidget {
  const NotificationCenterPage({super.key});

  @override
  State<NotificationCenterPage> createState() => _NotificationCenterPageState();
}

class _NotificationCenterPageState extends State<NotificationCenterPage> {
  late Future<List<AppNotification>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    _notificationsFuture = notificationRepository.loadNotifications();
  }

  String _formatDate(DateTime dateTime) {
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$day/$month/${dateTime.year} $hour:$minute';
  }

  Future<void> _markAllAsRead() async {
    final result = await notificationRepository.markAllAsRead();
    if (!mounted) return;
    setState(_refresh);
    if (result == NotificationWriteResult.localOnly) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Read status is saved on this device only.'),
        ),
      );
    }
  }

  Future<void> _handleNotificationTap(AppNotification notification) async {
    if (!notification.isRead) {
      final result = await notificationRepository.markAsRead(notification.id);
      if (result == NotificationWriteResult.localOnly && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Read status is saved on this device only.'),
          ),
        );
      }
    }

    if (!mounted) return;

    if (notification.targetRoute != null &&
        notification.targetRoute!.startsWith('/')) {
      context.go(notification.targetRoute!);
      return;
    }

    setState(_refresh);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.primary,
        elevation: 0,
        title: const Text('Notification Center'),
        actions: [
          TextButton(
            onPressed: _markAllAsRead,
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: FutureBuilder<List<AppNotification>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _ErrorState(onRetry: () => setState(_refresh));
          }

          final notifications = snapshot.data ?? const <AppNotification>[];

          if (notifications.isEmpty) {
            return const _EmptyState();
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: notifications.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return StaggeredEntrance(
                key: ValueKey(notification.id),
                delay: Duration(milliseconds: index < 8 ? index * 45 : 360),
                child: _NotificationTile(
                  notification: notification,
                  onTap: () => _handleNotificationTap(notification),
                  formattedDate: _formatDate(notification.createdAt),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.onTap,
    required this.formattedDate,
  });

  final AppNotification notification;
  final VoidCallback onTap;
  final String formattedDate;

  @override
  Widget build(BuildContext context) {
    final cardColor = notification.isRead
        ? AppColors.surface
        : AppColors.primary.withValues(alpha: 0.03);

    final borderColor = notification.isRead
        ? AppColors.border
        : AppColors.accent.withValues(alpha: 0.25);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return PressScale(
      elevation: 1.5,
      shadowColor: AppColors.primary.withValues(alpha: 0.12),
      borderRadius: AppSpacing.roundedMd,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppSpacing.roundedMd,
          child: AnimatedContainer(
            duration: reduceMotion
                ? Duration.zero
                : const Duration(milliseconds: 260),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: AppSpacing.roundedMd,
              border: Border.all(color: borderColor),
            ),
            padding: AppSpacing.cardPaddingAll,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedContainer(
                  duration: reduceMotion
                      ? Duration.zero
                      : const Duration(milliseconds: 260),
                  curve: Curves.easeInOut,
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: BoxDecoration(
                    color: notification.isRead
                        ? AppColors.border
                        : AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: AnimatedDefaultTextStyle(
                              duration: reduceMotion
                                  ? Duration.zero
                                  : const Duration(milliseconds: 260),
                              curve: Curves.easeInOut,
                              style: AppTextStyles.body.copyWith(
                                fontWeight: notification.isRead
                                    ? FontWeight.w500
                                    : FontWeight.w700,
                                color: AppColors.primary,
                              ),
                              child: Text(notification.title),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              notification.type.toUpperCase(),
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      AnimatedDefaultTextStyle(
                        duration: reduceMotion
                            ? Duration.zero
                            : const Duration(milliseconds: 260),
                        curve: Curves.easeInOut,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: notification.isRead
                              ? FontWeight.w400
                              : FontWeight.w500,
                        ),
                        child: Text(notification.message),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            formattedDate,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const Spacer(),
                          AnimatedSwitcher(
                            duration: reduceMotion
                                ? Duration.zero
                                : const Duration(milliseconds: 220),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeInOut,
                            transitionBuilder: (child, animation) =>
                                FadeTransition(
                                  opacity: animation,
                                  child: ScaleTransition(
                                    scale: animation,
                                    child: child,
                                  ),
                                ),
                            child: notification.isRead
                                ? const SizedBox.shrink(
                                    key: ValueKey('read'),
                                  )
                                : Text(
                                    'Unread',
                                    key: const ValueKey('unread'),
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.accent,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final animationDuration = reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 340);

    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: reduceMotion ? 1 : 0.94, end: 1),
        duration: animationDuration,
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
                Icons.notifications_none_rounded,
                size: 48,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: AppSpacing.md),
              Text('No notifications yet', style: AppTextStyles.sectionTitle),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Future alerts and reminders will appear here.',
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
            Text(
              'Unable to load notifications',
              style: AppTextStyles.sectionTitle,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Please retry to refresh the notification center.',
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
