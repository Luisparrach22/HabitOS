// ──────────────────────────────────────────────
// user_model.dart — Modelo de Dominio de Usuario
// ──────────────────────────────────────────────

class UserModel {
  final String id;
  final String email;
  final String? name;
  final String? avatarUrl;
  final int totalXp;
  final int level;
  final bool isPro;
  final String timezone;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.email,
    this.name,
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
      'avatarUrl': avatarUrl,
      'totalXp': totalXp,
      'level': level,
      'isPro': isPro,
      'timezone': timezone,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Crea una copia del usuario con campos modificados.
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? avatarUrl,
    int? totalXp,
    int? level,
    bool? isPro,
    String? timezone,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      totalXp: totalXp ?? this.totalXp,
      level: level ?? this.level,
      isPro: isPro ?? this.isPro,
      timezone: timezone ?? this.timezone,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
