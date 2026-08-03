// ──────────────────────────────────────────────
// main.dart — Punto de Entrada de HabitOS Flutter
// ──────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'app/theme/app_theme.dart';
import 'app/navigation/main_tab_screen.dart';
import 'core/config/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
  runApp(const HabitOSApp());
}

class HabitOSApp extends StatelessWidget {
  const HabitOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HabitOS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainTabScreen(),
    );
  }
}
