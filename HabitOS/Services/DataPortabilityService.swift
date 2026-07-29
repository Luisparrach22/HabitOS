// ──────────────────────────────────────────────
// DataPortabilityService.swift — Servicio de Copia de Seguridad JSON
// ──────────────────────────────────────────────
// Gestiona la importación y exportación de datos de usuario en formato JSON.
// Utiliza DTOs desacoplados del esquema de persistencia para evitar
// dependencias circulares y asegurar compatibilidad futura.

import Foundation
import SwiftUI
import SwiftData
import UniformTypeIdentifiers

// MARK: - Esquemas de Transferencia de Datos (DTO)

struct HabitLogDTO: Codable {
    let id: String
    let completedAt: Date
    let value: Int
    let notes: String?
}

struct ShieldUsageDTO: Codable {
    let id: String
    let usedAt: Date
    let reason: String?
}

struct HabitDTO: Codable {
    let id: String
    let name: String
    let habitDescription: String?
    let trigger: String?
    let frequency: String
    let color: String?
    let icon: String?
    let currentStreak: Int
    let maxStreak: Int
    let shields: Int
    let createdAt: Date
    let logs: [HabitLogDTO]
    let shieldLogs: [ShieldUsageDTO]
}

struct UserDTO: Codable {
    let id: String
    let email: String
    let name: String?
    let passwordHash: String
    let avatarUrl: String?
    let totalXp: Int
    let level: Int
    let isPro: Bool
    let timezone: String
    let createdAt: Date
    let habits: [HabitDTO]
}

struct BackupDTO: Codable {
    let version: Int
    let app: String
    let exportedAt: Date
    let user: UserDTO
}

// MARK: - Documento para SwiftUI FileExporter

struct JSONDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    
    var jsonData: Data
    
    init(data: Data) {
        self.jsonData = data
    }
    
    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            self.jsonData = data
        } else {
            throw CocoaError(.fileReadCorruptFile)
        }
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: jsonData)
    }
}

// MARK: - Servicio Principal

class DataPortabilityService {
    static let shared = DataPortabilityService()
    
    private init() {}
    
    /// Serializa los datos del usuario y sus hábitos a un binario JSON codificado en UTF-8
    func exportBackup(user: User, habits: [Habit]) throws -> Data {
        let habitDTOs = habits.map { habit in
            let logsDTO = (habit.logs ?? []).map { log in
                HabitLogDTO(
                    id: log.id,
                    completedAt: log.completedAt,
                    value: log.value,
                    notes: log.notes
                )
            }
            
            let shieldLogsDTO = (habit.shieldLogs ?? []).map { shield in
                ShieldUsageDTO(
                    id: shield.id,
                    usedAt: shield.usedAt,
                    reason: shield.reason
                )
            }
            
            return HabitDTO(
                id: habit.id,
                name: habit.name,
                habitDescription: habit.habitDescription,
                trigger: habit.trigger,
                frequency: habit.frequency.rawValue,
                color: habit.color,
                icon: habit.icon,
                currentStreak: habit.currentStreak,
                maxStreak: habit.maxStreak,
                shields: habit.shields,
                createdAt: habit.createdAt,
                logs: logsDTO,
                shieldLogs: shieldLogsDTO
            )
        }
        
        let userDTO = UserDTO(
            id: user.id,
            email: user.email,
            name: user.name,
            passwordHash: user.passwordHash,
            avatarUrl: user.avatarUrl,
            totalXp: user.totalXp,
            level: user.level,
            isPro: user.isPro,
            timezone: user.timezone,
            createdAt: user.createdAt,
            habits: habitDTOs
        )
        
        let backup = BackupDTO(
            version: 1,
            app: "HabitOS",
            exportedAt: Date(),
            user: userDTO
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        return try encoder.encode(backup)
    }
    
    /// Borra toda la información actual y restaura los datos a partir de una copia JSON decodificada
    func importBackup(data: Data, modelContext: ModelContext) throws {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let backup = try decoder.decode(BackupDTO.self, from: data)
        
        // 1. Eliminar datos existentes de forma segura e independiente para evitar conflictos de cascada
        let logsFetch = FetchDescriptor<HabitLog>()
        let existingLogs = try modelContext.fetch(logsFetch)
        for log in existingLogs {
            modelContext.delete(log)
        }
        
        let shieldFetch = FetchDescriptor<ShieldUsage>()
        let existingShields = try modelContext.fetch(shieldFetch)
        for shield in existingShields {
            modelContext.delete(shield)
        }
        
        let habitsFetch = FetchDescriptor<Habit>()
        let existingHabits = try modelContext.fetch(habitsFetch)
        for habit in existingHabits {
            modelContext.delete(habit)
        }
        
        let usersFetch = FetchDescriptor<User>()
        let existingUsers = try modelContext.fetch(usersFetch)
        for user in existingUsers {
            modelContext.delete(user)
        }
        
        try modelContext.save()
        
        // 2. Insertar los nuevos datos decodificados
        let userDTO = backup.user
        let newUser = User(
            id: userDTO.id,
            email: userDTO.email,
            name: userDTO.name,
            passwordHash: userDTO.passwordHash,
            avatarUrl: userDTO.avatarUrl,
            totalXp: userDTO.totalXp,
            level: userDTO.level,
            isPro: userDTO.isPro,
            timezone: userDTO.timezone,
            createdAt: userDTO.createdAt
        )
        
        modelContext.insert(newUser)
        
        for habitDTO in userDTO.habits {
            let frequency = Frequency(rawValue: habitDTO.frequency) ?? .daily
            let newHabit = Habit(
                id: habitDTO.id,
                userId: newUser.id,
                name: habitDTO.name,
                habitDescription: habitDTO.habitDescription,
                trigger: habitDTO.trigger,
                frequency: frequency,
                color: habitDTO.color,
                icon: habitDTO.icon,
                currentStreak: habitDTO.currentStreak,
                maxStreak: habitDTO.maxStreak,
                shields: habitDTO.shields,
                createdAt: habitDTO.createdAt
            )
            newHabit.user = newUser
            modelContext.insert(newHabit)
            
            // Reconstruir logs de completado
            for logDTO in habitDTO.logs {
                let newLog = HabitLog(
                    id: logDTO.id,
                    habitId: newHabit.id,
                    completedAt: logDTO.completedAt,
                    value: logDTO.value,
                    notes: logDTO.notes
                )
                newLog.habit = newHabit
                modelContext.insert(newLog)
            }
            
            // Reconstruir logs de uso de escudos
            for shieldDTO in habitDTO.shieldLogs {
                let newShield = ShieldUsage(
                    id: shieldDTO.id,
                    habitId: newHabit.id,
                    usedAt: shieldDTO.usedAt,
                    reason: shieldDTO.reason
                )
                newShield.habit = newHabit
                modelContext.insert(newShield)
            }
        }
        
        try modelContext.save()
    }
    
    /// Exporta la lista de hábitos y su estado actual en formato CSV para hojas de cálculo
    func exportCSV(user: User, habits: [Habit]) -> String {
        var csvString = "Hábito,Descripción,Frecuencia,Racha Actual,Racha Máxima,Escudos,Fecha Creación,Registros Completados\n"
        
        let dateFormatter = ISO8601DateFormatter()
        for habit in habits {
            let logsCount = habit.logs?.count ?? 0
            let nameClean = "\"\(habit.name.replacingOccurrences(of: "\"", with: "\"\""))\""
            let descClean = "\"\( (habit.habitDescription ?? "").replacingOccurrences(of: "\"", with: "\"\"") )\""
            let freq = habit.frequency.rawValue
            let created = dateFormatter.string(from: habit.createdAt)
            
            let row = "\(nameClean),\(descClean),\(freq),\(habit.currentStreak),\(habit.maxStreak),\(habit.shields),\(created),\(logsCount)\n"
            csvString.append(row)
        }
        
        return csvString
    }
}
