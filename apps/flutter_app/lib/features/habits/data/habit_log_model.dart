// ──────────────────────────────────────────────
// habit_log_model.dart — Modelo de Registro de Completación
// Corresponde a la tabla HabitLog del schema SQL.
// ──────────────────────────────────────────────

class HabitLogModel {
  final String id;
  final String habitId;
  final DateTime completedAt;
  final int value;
  final String? notes;

  const HabitLogModel({
    required this.id,
    required this.habitId,
    required this.completedAt,
    this.value = 1,
    this.notes,
  });

  factory HabitLogModel.fromJson(Map<String, dynamic> json) {
    return HabitLogModel(
      id: json['id'] as String,
      habitId: json['habitId'] as String,
      completedAt: DateTime.parse(json['completedAt'] as String),
      value: json['value'] as int? ?? 1,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'habitId': habitId,
      'completedAt': completedAt.toIso8601String(),
      'value': value,
      'notes': notes,
    };
  }
}
