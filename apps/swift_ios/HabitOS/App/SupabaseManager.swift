import Foundation
import Supabase

// ──────────────────────────────────────────────
// SupabaseManager.swift — Cliente Global de Supabase
// ──────────────────────────────────────────────
// Nota de seguridad: supabaseKey es la clave PÚBLICA (anon/publishable).
// Es segura para incluir en el bundle de la app.
// La clave secreta (service_role) NUNCA debe estar en código cliente.

struct Config {
    static let supabaseURL = URL(string: "https://jakctjvneuttyyqmzyfu.supabase.co")!
    static let supabaseKey = "sb_publishable_movXD6PSPA-rdHcZINqtUA_5UUy0VWE"
}

/// Cliente compartido de Supabase — usar esta instancia en toda la app.
let supabase = SupabaseClient(
    supabaseURL: Config.supabaseURL,
    supabaseKey: Config.supabaseKey
)
