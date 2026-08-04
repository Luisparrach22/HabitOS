// ──────────────────────────────────────────────
// NotificationService.swift — Servicio de Notificaciones Locales
// ──────────────────────────────────────────────
// Se encarga de solicitar permisos al usuario y programar recordatorios
// locales diarios mediante UNUserNotificationCenter para sus hábitos.

import Foundation
import UserNotifications

class NotificationService {
    
    static let shared = NotificationService()
    
    private init() {}
    
    // MARK: - Solicitar Permisos
    
    /// Solicita permiso para mostrar alertas, sonidos y globos en el icono.
    func requestAuthorization(completion: ((Bool) -> Void)? = nil) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                #if DEBUG
                if let error = error {
                    print("❌ Error al solicitar permisos de notificación: \(error.localizedDescription)")
                }
                #endif
                completion?(granted)
            }
        }
    }
    
    // MARK: - Programar Recordatorio
    
    /// Programar una notificación diaria repetitiva a la hora indicada.
    func scheduleReminder(for habit: Habit, at reminderDate: Date) {
        // Primero eliminamos notificaciones anteriores de este hábito
        cancelReminder(for: habit)
        
        let content = UNMutableNotificationContent()
        content.title = "⚡ HabitOS — ¡Hora de actuar!"
        content.body = "Mantén tu racha viva completando: '\(habit.name)'"
        content.sound = .default
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: reminderDate)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "habit_\(habit.id)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            #if DEBUG
            if let error = error {
                print("❌ Error al programar notificación para '\(habit.name)': \(error.localizedDescription)")
            } else {
                print("🔔 Notificación programada correctamente para '\(habit.name)' a las \(components.hour ?? 0):\(components.minute ?? 0)")
            }
            #endif
        }
    }
    
    // MARK: - Cancelar Recordatorio
    
    /// Cancela la notificación de un hábito.
    func cancelReminder(for habit: Habit) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["habit_\(habit.id)"])
    }
}
