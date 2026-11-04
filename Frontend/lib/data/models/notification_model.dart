class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime createdAt;
  final String? targetRoute;

  const AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.targetRoute,
  });

  AppNotification copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    String? type,
    bool? isRead,
    DateTime? createdAt,
    String? targetRoute,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      targetRoute: targetRoute ?? this.targetRoute,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'message': message,
      'type': type,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
      'target_route': targetRoute,
    };
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Notification',
      message: json['message']?.toString() ?? '',
      type: json['type']?.toString() ?? 'general',
      isRead: json['is_read'] == true || json['is_read'] == 1,
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      targetRoute: json['target_route']?.toString(),
    );
  }
}
