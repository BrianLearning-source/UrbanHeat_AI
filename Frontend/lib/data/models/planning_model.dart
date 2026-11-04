enum PlanningStatus { upcoming, completed }

extension PlanningStatusX on PlanningStatus {
  String get value {
    switch (this) {
      case PlanningStatus.upcoming:
        return 'upcoming';
      case PlanningStatus.completed:
        return 'completed';
    }
  }

  String get label {
    switch (this) {
      case PlanningStatus.upcoming:
        return 'Upcoming';
      case PlanningStatus.completed:
        return 'Completed';
    }
  }

  static PlanningStatus fromValue(String? value) {
    switch (value) {
      case 'completed':
        return PlanningStatus.completed;
      case 'upcoming':
      default:
        return PlanningStatus.upcoming;
    }
  }
}

class PlanningItem {
  final String id;
  final String userId;
  final String title;
  final String description;
  final DateTime scheduledAt;
  final PlanningStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PlanningItem({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.scheduledAt,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  PlanningItem copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    DateTime? scheduledAt,
    PlanningStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PlanningItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'scheduled_at': scheduledAt.toIso8601String(),
      'status': status.value,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory PlanningItem.fromJson(Map<String, dynamic> json) {
    return PlanningItem(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Plan',
      description: json['description']?.toString() ?? '',
      scheduledAt:
          DateTime.tryParse(json['scheduled_at']?.toString() ?? '') ??
          DateTime.now(),
      status: PlanningStatusX.fromValue(json['status']?.toString()),
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updated_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}
