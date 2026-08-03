// ──────────────────────────────────────────────
// supabase_config.dart — Configuración de Supabase
// Las credenciales se inyectan en tiempo de compilación con --dart-define.
// Ejemplo:
//   flutter run \
//     --dart-define=SUPABASE_URL=https://xxx.supabase.co \
//     --dart-define=SUPABASE_ANON_KEY=eyJ...
// ──────────────────────────────────────────────

import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  /// URL del proyecto Supabase (inyectada con --dart-define o por defecto).
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://jakctjvneuttyyqmzyfu.supabase.co',
  );

  /// Clave pública de Supabase (inyectada con --dart-define o por defecto).
  static const String publishableKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_movXD6PSPA-rdHcZINqtUA_5UUy0VWE',
  );

  /// Inicializa la conexión con Supabase.
  /// Lanza una excepción si las credenciales no están configuradas.
  static Future<void> initialize() async {
    if (url.isEmpty || publishableKey.isEmpty) {
      throw StateError(
        'Supabase no configurado. Ejecuta con:\n'
        'flutter run '
        '--dart-define=SUPABASE_URL=<tu_url> '
        '--dart-define=SUPABASE_ANON_KEY=<tu_clave>',
      );
    }
    await Supabase.initialize(url: url, publishableKey: publishableKey);
  }

  /// Cliente de Supabase inicializado.
  static SupabaseClient get client => Supabase.instance.client;
}
