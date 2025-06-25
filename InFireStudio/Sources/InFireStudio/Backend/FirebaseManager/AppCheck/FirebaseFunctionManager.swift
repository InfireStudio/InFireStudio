//
//  File.swift
//  InFireStudio
//
//  Created by furkan vural on 25.06.2025.
//

import Foundation
import FirebaseFunctions
@preconcurrency import FirebaseAppCheck
import FirebaseAppCheckInterop



// MARK: - Firebase Function Manager
@MainActor
public class FirebaseFunctionManager: ObservableObject {
    private let functions: Functions
    private let appCheck: AppCheck?
    private var apiKeyCache: [String: APIKey] = [:]
    
    // MARK: - Initialization
    public init(region: String = "us-central1") {
        self.functions = Functions.functions(region: region)
        self.appCheck = AppCheck.appCheck()
        
    }
    
    // MARK: - Public Methods
    
    /// Belirli bir servis için API anahtarını getirir
    /// - Parameters:
    ///   - service: API servis adı (örn: "openai", "stripe")
    ///   - forceRefresh: Cache'i yoksay ve yeniden getir
    /// - Returns: API anahtarı
    public func getAPIKey(for service: String, forceRefresh: Bool = false) async throws -> APIKey {
        // Cache kontrolü
        if !forceRefresh, let cachedKey = apiKeyCache[service], !isExpired(cachedKey) {
            return cachedKey
        }
        
        try await validateAppCheckToken()
                
        let callable = functions.httpsCallable("getAPIKey")
        let data = ["service": service]
        
        do {
            let result = try await callable.call(data)
            
            guard let resultData = result.data as? [String: Any] else {
                throw FirebaseFunctionError.noData
            }
            
            let jsonData = try JSONSerialization.data(withJSONObject: resultData)
            let response = try JSONDecoder().decode(APIKeyResponse.self, from: jsonData)
            let apiKey = response.toAPIKey()
            
            
            apiKeyCache[service] = apiKey
            
            return apiKey
        } catch let error as NSError {
            if error.domain == FunctionsErrorDomain {
                let message = error.userInfo[FunctionsErrorDetailsKey] as? String ?? "Bilinmeyen hata"
                throw FirebaseFunctionError.functionError(message)
            }
            throw FirebaseFunctionError.networkError(error)
        }
    }
    
    /// Tüm mevcut API anahtarlarını listeler
    /// - Returns: API anahtarları dizisi
    public func getAllAPIKeys() async throws -> [APIKey] {
        try await validateAppCheckToken()
        
        let callable = functions.httpsCallable("getAllAPIKeys")
        
        do {
            let result = try await callable.call()
            
            guard let resultData = result.data as? [String: Any],
                  let keysArray = resultData["keys"] as? [[String: Any]] else {
                throw FirebaseFunctionError.noData
            }
            
            var apiKeys: [APIKey] = []
            
            for keyData in keysArray {
                let jsonData = try JSONSerialization.data(withJSONObject: keyData)
                let response = try JSONDecoder().decode(APIKeyResponse.self, from: jsonData)
                apiKeys.append(response.toAPIKey())
            }
            
            // Cache'i güncelle
            for key in apiKeys {
                apiKeyCache[key.service] = key
            }
            
            return apiKeys
        } catch let error as NSError {
            if error.domain == FunctionsErrorDomain {
                let message = error.userInfo[FunctionsErrorDetailsKey] as? String ?? "Bilinmeyen hata"
                throw FirebaseFunctionError.functionError(message)
            }
            throw FirebaseFunctionError.networkError(error)
        }
    }
    
    /// Cache'i temizler
    public func clearCache() {
        apiKeyCache.removeAll()
    }
    
    /// Belirli bir servisin cache'ini temizler
    /// - Parameter service: Temizlenecek servis adı
    public func clearCache(for service: String) {
        apiKeyCache.removeValue(forKey: service)
    }
    
    // MARK: - Private Methods
    
    private func validateAppCheckToken() async throws {
        guard let appCheck = appCheck else {
            throw FirebaseFunctionError.appCheckError("App Check başlatılamadı")
        }
        
        do {
            _ = try await appCheck.token(forcingRefresh: false)
        } catch {
            throw FirebaseFunctionError.appCheckError("App Check token alınamadı: \(error.localizedDescription)")
        }
    }
    
    private func isExpired(_ apiKey: APIKey) -> Bool {
        guard let expiryDate = apiKey.expiresAt else {
            return false
        }
        return Date() > expiryDate
    }
}

// MARK: - Convenience Extensions
public extension FirebaseFunctionManager {
    
    /// OpenAI API anahtarını getirir
    func getOpenAIKey(forceRefresh: Bool = false) async throws -> String {
        let apiKey = try await getAPIKey(for: "openai", forceRefresh: forceRefresh)
        return apiKey.key
    }
    
    /// Stripe API anahtarını getirir
    func getStripeKey(forceRefresh: Bool = false) async throws -> String {
        let apiKey = try await getAPIKey(for: "stripe", forceRefresh: forceRefresh)
        return apiKey.key
    }
    
    /// Google API anahtarını getirir
    func getGoogleAPIKey(forceRefresh: Bool = false) async throws -> String {
        let apiKey = try await getAPIKey(for: "google", forceRefresh: forceRefresh)
        return apiKey.key
    }
}

// MARK: - Usage Example
/*
 
 // Kullanım örneği:
 
 let functionManager = FirebaseFunctionManager()
 
 // Tek bir API anahtarı al
 do {
     let openAIKey = try await functionManager.getOpenAIKey()
     print("OpenAI Key: \(openAIKey)")
 } catch {
     print("Hata: \(error.localizedDescription)")
 }
 
 // Tüm API anahtarlarını al
 do {
     let allKeys = try await functionManager.getAllAPIKeys()
     for key in allKeys {
         print("Service: \(key.service), Key: \(key.key)")
     }
 } catch {
     print("Hata: \(error.localizedDescription)")
 }
 
 // Cache'i temizle
 functionManager.clearCache()
 
 */
