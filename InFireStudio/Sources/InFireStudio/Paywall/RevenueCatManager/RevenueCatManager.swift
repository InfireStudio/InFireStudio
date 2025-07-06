//
//  File.swift
//  InFireStudio
//
//  Created by furkan vural on 6.07.2025.
//

import Foundation
import RevenueCat

// MARK: - RevenueCat Manager Protocol
public protocol RevenueCatManagerProtocol {
    func configure(apiKey: String) async
    func getOfferings() async throws -> Offerings
    func purchase(package: Package) async throws -> CustomerInfo
    func restorePurchases() async throws -> CustomerInfo
    func getCustomerInfo() async throws -> CustomerInfo
    func checkSubscriptionStatus() async -> SubscriptionStatus
    func logout() async
}


@MainActor
public class RevenueCatManager: ObservableObject, RevenueCatManagerProtocol {
    
    // MARK: - Singleton
    public static let shared = RevenueCatManager()
    
    // MARK: - Published Properties
    public var customerInfo: CustomerInfo?
    public var offerings: Offerings?
    public var subscriptionStatus: SubscriptionStatus = .unknown
    public var isConfigured = false
    public var isLoading = false
    public var errorMessage: String?
    
    // MARK: - Private Properties
    private var isInitialized = false
    
    // MARK: - Initialization
    public init() {
        setupPurchaserInfoUpdates()
    }
    
    // MARK: - Configuration
    public func configure(apiKey: String) {
        guard !isInitialized else {
            print("RevenueCat is already configured")
            return
        }
        
        // RevenueCat konfigürasyonu
        Purchases.configure(withAPIKey: apiKey)
        
        // Kullanıcı ID'si varsa ayarla
        let userID = UserDefaultsManager.shared.userID
        if let userID {
            Purchases.shared.logIn(userID) { customerInfo, created, error in
                if let error = error {
                    print("RevenueCat login error: \(error.localizedDescription)")
                } else {
                    print("RevenueCat user logged in successfully")
                }
            }
        }
        
        // Debug modu (sadece geliştirme için)
        #if DEBUG
        Purchases.logLevel = .debug
        #endif
        
        isInitialized = true
        isConfigured = true
        
        // İlk veri yüklemesi
        Task {
            await loadInitialData()
        }
    }
    
    // MARK: - Initial Data Loading
    private func loadInitialData() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                await self.loadOfferings()
            }
            
            group.addTask {
                await self.loadCustomerInfo()
            }
        }
    }
    
    // MARK: - Offerings
    public func getOfferings() async throws -> Offerings {
        isLoading = true
        errorMessage = nil
        
        do {
            let offerings = try await Purchases.shared.offerings()
            await MainActor.run {
                self.offerings = offerings
                self.isLoading = false
            }
            return offerings
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
            throw error
        }
    }
    
    private func loadOfferings() async {
        do {
            _ = try await getOfferings()
        } catch {
            print("Failed to load offerings: \(error)")
        }
    }
    
    // MARK: - Purchase
    public func purchase(package: Package) async throws -> CustomerInfo {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await Purchases.shared.purchase(package: package)
            let customerInfo = result.customerInfo
            
            await MainActor.run {
                self.customerInfo = customerInfo
                self.updateSubscriptionStatus()
                self.isLoading = false
            }
            
            return customerInfo
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
            throw error
        }
    }
    
    // MARK: - Restore Purchases
    public func restorePurchases() async throws -> CustomerInfo {
        isLoading = true
        errorMessage = nil
        
        do {
            let customerInfo = try await Purchases.shared.restorePurchases()
            await MainActor.run {
                self.customerInfo = customerInfo
                self.updateSubscriptionStatus()
                self.isLoading = false
            }
            return customerInfo
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
            throw error
        }
    }
    
    // MARK: - Customer Info
    public func getCustomerInfo() async throws -> CustomerInfo {
        isLoading = true
        errorMessage = nil
        
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            await MainActor.run {
                self.customerInfo = customerInfo
                self.updateSubscriptionStatus()
                self.isLoading = false
            }
            return customerInfo
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
            throw error
        }
    }
    
    private func loadCustomerInfo() async {
        do {
            _ = try await getCustomerInfo()
        } catch {
            print("Failed to load customer info: \(error)")
        }
    }
    
    /// MARK: - Subscription Status
    public func checkSubscriptionStatus() async -> SubscriptionStatus {
        do {
            let customerInfo = try await getCustomerInfo()
            return determineSubscriptionStatus(from: customerInfo)
        } catch {
            return .unknown
        }
    }
    
    private func updateSubscriptionStatus() {
        guard let customerInfo = customerInfo else {
            subscriptionStatus = .unknown
            return
        }
        
        subscriptionStatus = determineSubscriptionStatus(from: customerInfo)
    }
    
    private func determineSubscriptionStatus(from customerInfo: CustomerInfo) -> SubscriptionStatus {
        // Aktif abonelikleri kontrol et
        if !customerInfo.activeSubscriptions.isEmpty {
            return .active
        }
        
        // Entitlements kontrolü
        let activeEntitlements = customerInfo.entitlements.active
        if !activeEntitlements.isEmpty {
            // Trial kontrolü
            if activeEntitlements.values.contains(where: { $0.periodType == .trial }) {
                return .trial
            }
            return .active
        }
        
        // Geçmişte abonelik var mı kontrol et
        let allEntitlements = customerInfo.entitlements.all
        if !allEntitlements.isEmpty {
            return .expired
        }
        
        return .none
    }
    
    // MARK: - User Management
    public func logout() {
        Purchases.shared.logOut { customerInfo, error in
            if let error = error {
                print("RevenueCat logout error: \(error.localizedDescription)")
            } else {
                print("RevenueCat user logged out successfully")
            }
        }
        
        // Local state'i temizle
        customerInfo = nil
        offerings = nil
        subscriptionStatus = .unknown
        errorMessage = nil
    }
    
    public func login(userId: String) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            Purchases.shared.logIn(userId) { customerInfo, created, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    Task { @MainActor in
                        self.customerInfo = customerInfo
                        self.updateSubscriptionStatus()
                    }
                    continuation.resume()
                }
            }
        }
    }
    
    // MARK: - Private Methods
    private func setupPurchaserInfoUpdates() {
        // CustomerInfo güncellemelerini dinle
        NotificationCenter.default.addObserver(
            forName: .purchaserInfoUpdated,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                await self?.loadCustomerInfo()
            }
        }
    }
    
    // MARK: - Helper Methods
    public func hasActiveSubscription() -> Bool {
        return subscriptionStatus == .active || subscriptionStatus == .trial
    }
    
    public func getActiveSubscriptionProductId() -> String? {
        return customerInfo?.activeSubscriptions.first
    }
    
    public func getExpirationDate() -> Date? {
        guard let customerInfo = customerInfo else { return nil }
        
        // En son aktif entitlement'ın bitiş tarihini al
        let activeEntitlements = customerInfo.entitlements.active
        let expirationDates = activeEntitlements.values.compactMap { $0.expirationDate }
        
        return expirationDates.max()
    }
    
    public func isInTrialPeriod() -> Bool {
        guard let customerInfo = customerInfo else { return false }
        
        let activeEntitlements = customerInfo.entitlements.active
        return activeEntitlements.values.contains { $0.periodType == .trial }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}



// MARK: - Error Handling Extension
public extension RevenueCatManager {
    
    func handleError(_ error: Error) {
        if let purchasesError = error as? RevenueCat.ErrorCode {
            switch purchasesError {
            case .purchaseCancelledError:
                errorMessage = "Satın alma iptal edildi"
            case .storeProblemError:
                errorMessage = "App Store ile bağlantı sorunu"
            case .purchaseNotAllowedError:
                errorMessage = "Satın alma izni yok"
            case .purchaseInvalidError:
                errorMessage = "Geçersiz satın alma"
            case .productNotAvailableForPurchaseError:
                errorMessage = "Ürün satın alma için uygun değil"
            case .productAlreadyPurchasedError:
                errorMessage = "Ürün zaten satın alındı"
            case .receiptAlreadyInUseError:
                errorMessage = "Fiş zaten kullanımda"
            case .invalidReceiptError:
                errorMessage = "Geçersiz fiş"
            case .missingReceiptFileError:
                errorMessage = "Fiş dosyası bulunamadı"
            case .networkError:
                errorMessage = "Ağ bağlantı hatası"
            case .invalidCredentialsError:
                errorMessage = "Geçersiz kimlik bilgileri"
            case .unexpectedBackendResponseError:
                errorMessage = "Beklenmeyen sunucu yanıtı"
            case .receiptInUseByOtherSubscriberError:
                errorMessage = "Fiş başka kullanıcı tarafından kullanılıyor"
            case .invalidAppUserIdError:
                errorMessage = "Geçersiz kullanıcı ID'si"
            case .unknownBackendError:
                errorMessage = "Bilinmeyen sunucu hatası"
            default:
                errorMessage = "Bilinmeyen hata: \(error.localizedDescription)"
            }
        } else {
            errorMessage = error.localizedDescription
        }
    }
}
