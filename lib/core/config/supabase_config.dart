// ──────────────────────────────────────────────
// supabase_config.dart — Configuración de Supabase
// ──────────────────────────────────────────────

import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String url = 'https://jakctjvneuttyyqmzyfu.supabase.co';
  static const String publishableKey = 'sb_publishable_movXD6PSPA-rdHcZINqtUA_5UUy0VWE';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: url,
      publishableKey: publishableKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
