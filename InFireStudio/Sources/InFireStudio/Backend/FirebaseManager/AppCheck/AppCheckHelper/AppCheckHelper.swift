//
//  File.swift
//  InFireStudio
//
//  Created by furkan vural on 25.06.2025.
//

import Foundation
// MARK: - Models
public struct APIKey {
    public let key: String
    public let service: String
    public let expiresAt: Date?
    
    public init(key: String, service: String, expiresAt: Date? = nil) {
        self.key = key
        self.service = service
        self.expiresAt = expiresAt
    }
}

public struct APIKeyResponse: Codable {
    let key: String
    let service: String
    let expiresAt: String?
    
    public func toAPIKey() -> APIKey {
        let dateFormatter = ISO8601DateFormatter()
        let expiry = expiresAt != nil ? dateFormatter.date(from: expiresAt!) : nil
        return APIKey(key: key, service: service, expiresAt: expiry)
    }
}

// MARK: - Error Types
public enum FirebaseFunctionError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case functionError(String)
    case appCheckError(String)
    case networkError(Error)
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Geçersiz URL"
        case .noData:
            return "Veri bulunamadı"
        case .decodingError(let error):
            return "Veri çözme hatası: \(error.localizedDescription)"
        case .functionError(let message):
            return "Function hatası: \(message)"
        case .appCheckError(let message):
            return "App Check hatası: \(message)"
        case .networkError(let error):
            return "Ağ hatası: \(error.localizedDescription)"
        }
    }
}
