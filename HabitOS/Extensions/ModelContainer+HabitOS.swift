// ──────────────────────────────────────────────
// ModelContainer+HabitOS.swift — Extensión de ModelContainer Compartido
// ──────────────────────────────────────────────
// Centraliza la configuración de la base de datos de SwiftData para habilitar:
// 1. Sincronización iCloud (CloudKit) automática.
// 2. Almacenamiento local en el App Group para compartir datos con Widgets.

import Foundation
import SwiftData

extension ModelContainer {
    
    /// Instancia única y compartida de ModelContainer configurada para App Groups y CloudKit.
    public static let shared: ModelContainer = {
        let schema = Schema([
            User.self,
            Habit.self,
            HabitLog.self,
            ShieldUsage.self
        ])
        
        let containerURL: URL
        // Intentamos obtener el directorio del App Group para que la app principal y los widgets compartan la misma DB
        if let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.con.habitos.HabitOS") {
            containerURL = groupURL.appendingPathComponent("default.store")
        } else {
            // Fallback para pruebas locales en simulador sin App Groups firmados
            let appSupportURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            containerURL = appSupportURL.appendingPathComponent("default.store")
        }
        
        // Habilita la sincronización iCloud (CloudKit) de forma automática.
        // SwiftData usará el contenedor de CloudKit configurado en el Xcode Project.
        let config = ModelConfiguration(
            url: containerURL,
            allowsSave: true
        )
        
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Error crítico al inicializar el ModelContainer compartido: \(error.localizedDescription)")
        }
    }()
}
