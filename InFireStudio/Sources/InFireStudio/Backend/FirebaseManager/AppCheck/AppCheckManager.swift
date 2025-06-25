//
//  File.swift
//  InFireStudio
//
//  Created by furkan vural on 25.06.2025.
//

import Foundation
import FirebaseCore
@preconcurrency import FirebaseAppCheck

@MainActor
public class AppCheckManager {
    
    // Singleton instance
    public static let shared = AppCheckManager()
    
    private var isConfigured = false
    
    private init() {}
    
    /// App Check'i yapılandır - AppDelegate'de çağır
    /// - Parameter debugToken: Debug için özel token (opsiyonel)
    public func configure(debugToken: String? = nil) {
        guard !isConfigured else {
            print("⚠️ App Check zaten yapılandırılmış")
            return
        }
        
        #if DEBUG
        configureForDebug(debugToken: debugToken)
        #else
        configureForProduction()
        #endif
        
        isConfigured = true
        print("✅ App Check başarıyla yapılandırıldı")
    }
    
    /// App Check token'ı al (test için)
    public func getToken() async -> String? {
        guard isConfigured else {
            print("❌ App Check henüz yapılandırılmamış")
            return nil
        }
        
        do {
            let token = try await AppCheck.appCheck().token(forcingRefresh: false)
            print("✅ App Check token alındı")
            return token.token
        } catch {
            print("❌ App Check token alınamadı: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// App Check durumunu kontrol et
    public func checkStatus() {
        print("📱 App Check Durumu:")
        print("   - Yapılandırıldı: \(isConfigured)")
        
        #if DEBUG
        print("   - Mod: DEBUG")
        print("   - Provider: Debug Provider")
        #else
        print("   - Mod: PRODUCTION")
        print("   - Provider: App Attest Provider")
        #endif
    }
    
    // MARK: - Private Methods
    
    private func configureForDebug(debugToken: String?) {
        print("🔧 App Check DEBUG modunda yapılandırılıyor...")
        
        if let token = debugToken {
            // Özel debug token kullan
            print("🔑 Özel debug token kullanılıyor")
            AppCheck.setAppCheckProviderFactory(CustomDebugAppCheckProviderFactory(token: token))
        } else {
            // Varsayılan debug provider
            print("🔑 Varsayılan debug provider kullanılıyor")
            AppCheck.setAppCheckProviderFactory(AppCheckDebugProviderFactory())
        }
    }
    
    private func configureForProduction() {
        print("🚀 App Check PRODUCTION modunda yapılandırılıyor...")
        
        #if os(iOS)
        // iOS için App Attest Provider
        AppCheck.setAppCheckProviderFactory(AppCheckDebugProviderFactory())
        print("🔒 App Attest Provider kullanılıyor")
        #elseif os(macOS)
        // macOS için DeviceCheck Provider
        AppCheck.setAppCheckProviderFactory(DeviceCheckProviderFactory())
        print("🔒 DeviceCheck Provider kullanılıyor")
        #endif
    }
}

// MARK: - Custom Debug Provider Factory
private class CustomDebugAppCheckProviderFactory: NSObject, AppCheckProviderFactory {
    private let debugToken: String
    
    init(token: String) {
        self.debugToken = token
        super.init()
    }
    
    func createProvider(with app: FirebaseApp) -> AppCheckProvider? {
        return AppCheckDebugProvider(app: app)
    }
}

// MARK: - AppDelegate Extension
public extension AppCheckManager {
    
    /// AppDelegate için kolay yapılandırma
    /// - Parameters:
    ///   - debugToken: Debug için özel token (Firebase Console'dan alınabilir)
    ///   - enableLogging: Detaylı log çıktısı
    static func configureInAppDelegate(debugToken: String? = nil, enableLogging: Bool = true) {
        if enableLogging {
            print("🔥 Firebase App Check başlatılıyor...")
        }
        
        AppCheckManager.shared.configure(debugToken: debugToken)
        
        if enableLogging {
            AppCheckManager.shared.checkStatus()
        }
    }
}
