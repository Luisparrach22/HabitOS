// ──────────────────────────────────────────────
// user_model.dart — Modelo de Usuario en Dart
// ──────────────────────────────────────────────

class UserModel {
  final String id;
  final String email;
  final String? name;
  final String passwordHash;
  final String? avatarUrl;
  final int totalXp;
  final int level;
  final bool isPro;
  final String timezone;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    this.name,
    this.passwordHash = 'managed_by_supabase_auth',
    this.avatarUrl,
    this.totalXp = 0,
    this.level = 1,
    this.isPro = false,
    this.timezone = 'UTC',
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      passwordHash: json['passwordHash'] as String? ?? 'managed_by_supabase_auth',
      avatarUrl: json['avatarUrl'] as String?,
      totalXp: json['totalXp'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      isPro: json['isPro'] as bool? ?? false,
      timezone: json['timezone'] as String? ?? 'UTC',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'passwordHash': passwordHash,
      'avatarUrl': avatarUrl,
      'totalXp': totalXp,
      'level': level,
      'isPro': isPro,
      'timezone': timezone,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
