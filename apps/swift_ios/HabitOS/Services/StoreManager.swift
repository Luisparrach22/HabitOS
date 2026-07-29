// ──────────────────────────────────────────────
// StoreManager.swift — Servicio de StoreKit 2
// ──────────────────────────────────────────────
// Gestiona el producto de suscripción "Pro", las
// transacciones de compra, la restauración de compras y
// el estado de la suscripción de forma reactiva.

import Foundation
import StoreKit
import SwiftData

@Observable
class StoreManager {
    static let shared = StoreManager()
    
    // El identificador de nuestro producto Pro
    let proProductId = "com.habitos.HabitOS.pro"
    
    var proProduct: Product?
    var hasPro: Bool = false
    var isLoadingProducts = false
    var isPurchasing = false
    
    private var transactionListener: Task<Void, Error>?
    
    private init() {
        // Escuchar transacciones en segundo plano
        transactionListener = Task { [weak self] in
            for await result in Transaction.updates {
                await self?.handleTransactionUpdate(result: result)
            }
        }
    }
    
    deinit {
        transactionListener?.cancel()
    }
    
    // MARK: - Carga inicial y chequeo
    
    /// Carga los productos desde la App Store (o el archivo local .storekit)
    func loadProducts() async {
        guard proProduct == nil else { return }
        await MainActor.run { isLoadingProducts = true }
        
        do {
            let storeProducts = try await Product.products(for: [proProductId])
            await MainActor.run {
                self.proProduct = storeProducts.first(where: { $0.id == proProductId })
                self.isLoadingProducts = false
            }
        } catch {
            print("Error al cargar productos de StoreKit: \(error)")
            await MainActor.run { isLoadingProducts = false }
        }
    }
    
    /// Comprueba si el usuario tiene suscripciones activas en este momento
    func checkActiveSubscriptions(modelContext: ModelContext) async {
        var isProUser = false
        
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            if transaction.productID == proProductId {
                // Verificar que no haya expirado la suscripción
                if transaction.revocationDate == nil {
                    isProUser = true
                }
            }
        }
        
        let active = isProUser
        await MainActor.run {
            self.hasPro = active
        }
        await updateUserDataInSwiftData(isPro: active, context: modelContext)
    }
    
    // MARK: - Flujo de Compra
    
    /// Inicia la compra de la suscripción Pro
    func purchasePro(modelContext: ModelContext) async -> Bool {
        guard let product = proProduct else {
            await loadProducts()
            guard proProduct != nil else { return false }
            return await purchasePro(modelContext: modelContext)
        }
        
        await MainActor.run { isPurchasing = true }
        
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verificationResult):
                await handleTransactionUpdate(result: verificationResult)
                // Esperar a que se actualice
                await checkActiveSubscriptions(modelContext: modelContext)
                await MainActor.run { isPurchasing = false }
                return true
                
            case .pending:
                print("Compra pendiente de aprobación paterna o bancaria.")
                
            case .userCancelled:
                print("Compra cancelada por el usuario.")
                
            @unknown default:
                break
            }
        } catch {
            print("Error al realizar la compra: \(error)")
        }
        
        await MainActor.run { isPurchasing = false }
        return false
    }
    
    /// Fuerza la restauración de compras
    func restorePurchases(modelContext: ModelContext) async {
        do {
            try await AppStore.sync()
            await checkActiveSubscriptions(modelContext: modelContext)
        } catch {
            print("Error al sincronizar/restaurar compras: \(error)")
        }
    }
    
    // MARK: - Helper Lógica Interna
    
    private func handleTransactionUpdate(result: VerificationResult<Transaction>) async {
        switch result {
        case .verified(let transaction):
            // Finaliza la transacción
            await transaction.finish()
            
            // Si es nuestro producto, actualizar el estado
            if transaction.productID == proProductId {
                let isPro = transaction.revocationDate == nil
                await MainActor.run {
                    self.hasPro = isPro
                }
            }
        case .unverified(let transaction, let error):
            print("Transacción sin verificar para \(transaction.productID): \(error)")
        }
    }
    
    /// Actualiza el estado isPro en el modelo User de SwiftData
    @MainActor
    private func updateUserDataInSwiftData(isPro: Bool, context: ModelContext) async {
        let descriptor = FetchDescriptor<User>()
        do {
            if let user = try context.fetch(descriptor).first {
                if user.isPro != isPro {
                    user.isPro = isPro
                    try context.save()
                    print("SwiftData: Estado Pro del usuario actualizado a \(isPro)")
                }
            }
        } catch {
            print("Error al actualizar SwiftData User.isPro: \(error)")
        }
    }
}
