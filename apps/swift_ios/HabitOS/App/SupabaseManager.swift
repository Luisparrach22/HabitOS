import Foundation
import Supabase

// Reemplaza los valores con los tuyos
struct Config {
    static let supabaseURL = URL(string: "https://jakctjvneuttyyqmzyfu.supabase.co")!
    // Usamos la clave pública. ¡NUNCA la secreta aquí!
    static let supabaseKey = "sb_publishable_movXD6PSPA-rdHcZINqtUA_5UUy0VWE"
}

// Creamos una instancia global compartida para usarla en cualquier parte de la app
let supabase = SupabaseClient(
    supabaseURL: Config.supabaseURL,
    supabaseKey: Config.supabaseKey
)
