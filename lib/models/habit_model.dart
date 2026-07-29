// ──────────────────────────────────────────────
// habit_model.dart — Modelo de Hábito en Dart
// ──────────────────────────────────────────────

class HabitModel {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final String? trigger;
  final String frequency;
  final String? color;
  final String? icon;
  final int currentStreak;
  final int maxStreak;
  final int shields;
  final DateTime createdAt;

  HabitModel({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    this.trigger,
    this.frequency = 'DAILY',
    this.color = '#018ABE',
    this.icon = 'heart',
    this.currentStreak = 0,
    this.maxStreak = 0,
    this.shields = 0,
    required this.createdAt,
  });

  factory HabitModel.fromJson(Map<String, dynamic> json) {
    return HabitModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      trigger: json['trigger'] as String?,
      frequency: json['frequency'] as String? ?? 'DAILY',
      color: json['color'] as String? ?? '#018ABE',
      icon: json['icon'] as String? ?? 'heart',
      currentStreak: json['currentStreak'] as int? ?? 0,
      maxStreak: json['maxStreak'] as int? ?? 0,
      shields: json['shields'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'description': description,
      'trigger': trigger,
      'frequency': frequency,
      'color': color,
      'icon': icon,
      'currentStreak': currentStreak,
      'maxStreak': maxStreak,
      'shields': shields,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
