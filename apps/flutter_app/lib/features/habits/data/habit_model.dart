// ──────────────────────────────────────────────
// habit_model.dart — Modelo de Dominio de Hábito
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

  const HabitModel({
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

  /// Crea una copia del hábito con campos modificados.
  HabitModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    String? trigger,
    String? frequency,
    String? color,
    String? icon,
    int? currentStreak,
    int? maxStreak,
    int? shields,
    DateTime? createdAt,
  }) {
    return HabitModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      trigger: trigger ?? this.trigger,
      frequency: frequency ?? this.frequency,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      currentStreak: currentStreak ?? this.currentStreak,
      maxStreak: maxStreak ?? this.maxStreak,
      shields: shields ?? this.shields,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
