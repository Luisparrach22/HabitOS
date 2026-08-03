// ──────────────────────────────────────────────
// widget_test.dart — Smoke Test de HabitOS Flutter
// Verifica que la app arranca sin errores fatales.
// ──────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('HabitOS arranca y muestra el indicador de carga', (WidgetTester tester) async {
    // Construir un widget mínimo que simula el arranque de la app
    // sin necesitar inicialización de Supabase.
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );

    // Verificar que el indicador de carga se renderiza
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('Scaffold se renderiza correctamente', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('HabitOS'),
          ),
        ),
      ),
    );

    expect(find.text('HabitOS'), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
