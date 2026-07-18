// ──────────────────────────────────────────────
// HabitOSApp.swift — Entry Point de la aplicación
// ──────────────────────────────────────────────
// Este es el equivalente a tu _layout.tsx raíz en Expo Router.
// Es el PRIMER archivo que se ejecuta al abrir la app.
//
// ¿Qué hace @main?
// Le dice a iOS: "este es el punto de entrada de la app".
// Solo puede haber UN @main en todo el proyecto.
//
// ¿Qué hace .modelContainer()?
// Configura SwiftData (la base de datos local).
// Le dice a SwiftUI qué modelos de datos debe persistir.
// Todos los modelos listados aquí tendrán su tabla creada
// automáticamente en la base de datos SQLite local del dispositivo.

import SwiftUI
import SwiftData

@main
struct HabitOSApp: App {
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        // Registramos TODOS nuestros modelos SwiftData aquí.
        // SwiftData crea las tablas automáticamente.
        .modelContainer(for: [
            User.self,
            Habit.self,
            HabitLog.self,
            ShieldUsage.self
        ])
    }
}
