// ──────────────────────────────────────────────
// supabase_service.dart — Capa de Red y Servicios Supabase
// ──────────────────────────────────────────────

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../../features/auth/data/user_model.dart';
import '../../features/habits/data/habit_model.dart';
import '../../features/habits/data/habit_log_model.dart';

class SupabaseService {
  static final SupabaseService instance = SupabaseService._internal();
  SupabaseService._internal();

  SupabaseClient get _client => SupabaseConfig.client;

  // ────────────────────────────────
  // MARK: - Autenticación
  // ────────────────────────────────

  /// Registra un nuevo usuario en Supabase Auth y crea su perfil en la tabla User.
  Future<UserModel> signUp({
    required String email,
    required String password,
    String? name,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Fallo al registrar usuario en Supabase Auth');
    }

    final String userId = response.user!.id.toLowerCase();

    final newUser = UserModel(
      id: userId,
      email: email,
      name: name,
      isPro: false, // El estado Pro se gestiona desde la base de datos
      createdAt: DateTime.now(),
    );

    await _client.from('User').upsert(newUser.toJson());
    return newUser;
  }

  /// Inicia sesión y devuelve el perfil del usuario desde la base de datos.
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Correo o contraseña incorrectos');
    }

    final String userId = response.user!.id.toLowerCase();
    final userMap =
        await _client.from('User').select().eq('id', userId).maybeSingle();

    if (userMap != null) {
      return UserModel.fromJson(userMap);
    } else {
      // Primera vez que el usuario inicia sesión (migración de Auth existente)
      final newUser = UserModel(
        id: userId,
        email: email,
        isPro: false,
        createdAt: DateTime.now(),
      );
      await _client.from('User').upsert(newUser.toJson());
      return newUser;
    }
  }

  /// Cierra la sesión del usuario actual.
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // ────────────────────────────────
  // MARK: - Hábitos (CRUD)
  // ────────────────────────────────

  /// Obtiene todos los hábitos de un usuario.
  Future<List<HabitModel>> fetchHabits(String userId) async {
    final List<dynamic> response =
        await _client.from('Habit').select().eq('userId', userId);
    return response
        .map((map) => HabitModel.fromJson(map as Map<String, dynamic>))
        .toList();
  }

  /// Crea o actualiza un hábito.
  Future<void> saveHabit(HabitModel habit) async {
    await _client.from('Habit').upsert(habit.toJson());
  }

  /// Elimina un hábito por su ID.
  Future<void> deleteHabit(String habitId) async {
    await _client.from('Habit').delete().eq('id', habitId);
  }

  // ────────────────────────────────
  // MARK: - Registros de Hábitos (HabitLog)
  // ────────────────────────────────

  /// Obtiene los registros de completación de un hábito.
  Future<List<HabitLogModel>> fetchHabitLogs(String habitId) async {
    final List<dynamic> response = await _client
        .from('HabitLog')
        .select()
        .eq('habitId', habitId)
        .order('completedAt', ascending: false);
    return response
        .map((map) => HabitLogModel.fromJson(map as Map<String, dynamic>))
        .toList();
  }

  /// Obtiene todos los registros del día actual para los hábitos de un usuario.
  Future<Set<String>> fetchTodayCompletedHabitIds(String userId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day).toIso8601String();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();

    try {
      final List<dynamic> response = await _client
          .from('HabitLog')
          .select('habitId, Habit!inner(userId)')
          .eq('Habit.userId', userId)
          .gte('completedAt', startOfDay)
          .lte('completedAt', endOfDay);

      return response
          .map((map) => map['habitId'] as String)
          .toSet();
    } catch (e) {
      debugPrint('Error fetching today completions: $e');
      return {};
    }
  }

  /// Registra (o elimina) la completación de un hábito para hoy.
  /// Retorna `true` si se marcó como completado, `false` si se desmarcó.
  Future<bool> toggleHabitCompletion(String habitId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day).toIso8601String();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();

    // Buscar si ya hay un registro hoy
    final existing = await _client
        .from('HabitLog')
        .select()
        .eq('habitId', habitId)
        .gte('completedAt', startOfDay)
        .lte('completedAt', endOfDay)
        .maybeSingle();

    if (existing != null) {
      // Ya estaba completado → desmarcar
      await _client.from('HabitLog').delete().eq('id', existing['id']);
      return false;
    } else {
      // Marcar como completado
      final log = HabitLogModel(
        id: _generateUuid(),
        habitId: habitId,
        completedAt: DateTime.now(),
      );
      await _client.from('HabitLog').insert(log.toJson());
      return true;
    }
  }

  /// Genera un UUID v4 simple sin dependencias externas.
  String _generateUuid() {
    final now = DateTime.now().microsecondsSinceEpoch;
    return '${now.toRadixString(16)}-${(now * 31).toRadixString(16).substring(0, 4)}-${(now * 37).toRadixString(16).substring(0, 4)}-${(now * 41).toRadixString(16).substring(0, 12)}';
  }
}
