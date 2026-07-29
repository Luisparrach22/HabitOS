// ──────────────────────────────────────────────
// SupabaseConfig.dart — Configuración de Supabase en Flutter
// ──────────────────────────────────────────────

import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String url = 'https://jakctjvneuttyyqmzyfu.supabase.co';
  static const String anonKey = 'sb_publishable_movXD6PSPA-rdHcZINqtUA_5UUy0VWE';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
