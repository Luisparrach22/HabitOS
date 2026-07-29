// ──────────────────────────────────────────────
// supabase_service.dart — Capa de Red y Servicios Supabase
// ──────────────────────────────────────────────

import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../../features/auth/data/user_model.dart';
import '../../features/habits/data/habit_model.dart';

class SupabaseService {
  static final SupabaseService instance = SupabaseService._internal();
  SupabaseService._internal();

  SupabaseClient get _client => SupabaseConfig.client;

  // MARK: - Autenticación

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
    final bool isPro = email.trim().toLowerCase() == 'parra.chaconluis006@gmail.com';

    final newUser = UserModel(
      id: userId,
      email: email,
      name: name,
      isPro: isPro,
      createdAt: DateTime.now(),
    );

    await _client.from('User').upsert(newUser.toJson());
    return newUser;
  }

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
    final userMap = await _client.from('User').select().eq('id', userId).maybeSingle();

    if (userMap != null) {
      return UserModel.fromJson(userMap);
    } else {
      final bool isPro = email.trim().toLowerCase() == 'parra.chaconluis006@gmail.com';
      final newUser = UserModel(
        id: userId,
        email: email,
        isPro: isPro,
        createdAt: DateTime.now(),
      );
      await _client.from('User').upsert(newUser.toJson());
      return newUser;
    }
  }

  // MARK: - Hábitos

  Future<List<HabitModel>> fetchHabits(String userId) async {
    final List<dynamic> response = await _client.from('Habit').select().eq('userId', userId);
    return response.map((map) => HabitModel.fromJson(map as Map<String, dynamic>)).toList();
  }

  Future<void> saveHabit(HabitModel habit) async {
    await _client.from('Habit').upsert(habit.toJson());
  }

  Future<void> deleteHabit(String habitId) async {
    await _client.from('Habit').delete().eq('id', habitId);
  }
}
