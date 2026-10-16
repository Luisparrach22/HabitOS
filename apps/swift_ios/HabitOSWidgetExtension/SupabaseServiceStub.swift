// SupabaseServiceStub.swift — Sustituto ligero para la extensión de widgets
// La extensión no enlaza el SDK de Supabase. Los cambios hechos desde un widget
// se guardan en la base compartida (App Group) y la app los sincroniza al abrirse.

import Foundation

final class SupabaseService {
    static let shared = SupabaseService()
    private init() {}

    func syncHabit(_ habit: Habit) async throws {}
    func syncUser(_ user: User) async throws {}
    func syncHabitLog(_ log: HabitLog) async throws {}
    func syncShieldUsage(_ usage: ShieldUsage) async throws {}
    func deleteHabitLog(id: String) async throws {}
}
