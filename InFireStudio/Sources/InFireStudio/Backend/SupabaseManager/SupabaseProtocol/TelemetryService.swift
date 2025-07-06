//
//  File.swift
//  InFireStudio
//
//  Created by furkan vural on 17.06.2025.
//

import Foundation
import Supabase

/// Log/Metric gönderimini soyutlayan protokol
public protocol LogService {
    func logError(_ app: InFireStudioApps, appName: String, _ message: ErrorLoggingMessage, metadata: [String: String]?) async
}


@MainActor
public final class SupabaseLogService: LogService {
    
    private let client: SupabaseClient = .init(
        supabaseURL: URL(string: "https://ywptoygwapkvyvesogby.supabase.co")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl3cHRveWd3YXBrdnl2ZXNvZ2J5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTAxMDI4NzcsImV4cCI6MjA2NTY3ODg3N30.dZc8LgDO7ZGj84K35G5vO7cOuZ8xeZ2HBcuBGogfaOM"
    )
    
    private var realtimeSubscription: RealtimeChannel?
    public init() { }
    
    /// Supabase database tüm applerin içinden gönderilen hata mesajı
    /// app: InFireStudioApps içindeki enumdan geliyor. Bu enum tüm applerin ismini içeriyor.
    ///
    public func logError(_ app: InFireStudioApps, appName: String, _ message: ErrorLoggingMessage, metadata: [String: String]? = nil) async {
        
        let row = ErrorLogRow(
            appName: appName,
            message: message.rawValue,
            metadata: metadata ?? [:],
            status: .waiting
        )
        
        do {
            let _ = try await client
                .from(app.rawValue)
                .insert(row)
                .execute()
        } catch {
            print("Supabase insert error:", error)
        }
    }
    
    /// Supabase'den all app config bilgilerini çeker.
    /// Buradaki gelen data feedbackIsAvailable olacak.
    /// Eğer true ise kullanıcı feedback verebileceği bir view ile kullanıcıdan feedback alınabilecek
    /// showNewPaywall değeri userdefaults ile check edildikten sonra bakılacak.
    public func fetchAllAppConfig() async throws -> [Instrument] {
        let instruments: [Instrument] = try await client
            .from("infire_studio_config")
            .select()
            .execute()
            .value
        return instruments
    }
    
    public func sendFeedback(_ feedback: Feedback) async {
        do {
            let _ = try await client
                .from("infire_studio_app_feedback")
                .insert(feedback)
                .execute()
        } catch {
            print("Feedback Insert Error:\(error.localizedDescription)")
        }
    }
    
    /// Yeni uygulamanın olup olmadığını kontrol ettikten sonra gösteriminindeki detayları verir.
    ///
    public func fetchFeedbackPopup() async throws -> [FeedbackConfig] {
        let instruments: [FeedbackConfig] = try await client
            .from("feedback_config")
            .select()
            .execute()
            .value
        return instruments
    }

}

// Move File
public struct ErrorLogRow: Encodable, Sendable {
    let appName: String
    let message: String
    let metadata: [String: String]
    let status: Status
    
    enum CodingKeys: String, CodingKey {
        case appName = "app_name"
        case message
        case metadata
        case status
    }
}

public enum Status: String, Codable, Sendable {
    case waiting
    case done
}

// Move File
@MainActor
public struct Instrument: Codable {
    let id: String
    let feedback_is_available: Bool
    let hard_paywall: Bool
    let show_new_app: String
}


// Move File


/// feedback_config tablosundaki bir satırı temsil eder
public struct FeedbackConfig: Codable, Identifiable, Sendable {
    /// UUID (primary key)
    public let id: UUID

    /// Oluşturulma zamanı (Postgres timestamp with time zone)
    public let createdAt: Date

    /// "rating" veya "chat"
    public let feedbackType: FeedbackType

    /// Formun aktif/pasif durumu
    public let available: Bool

    /// Lokalize başlıklar: ["en": "...", "tr": "...", ...]
    public let title: [String:String]

    /// Lokalize teşekkür mesajları
    public let thankYouMessage: [String:String]

    /// Lokalize buton metinleri
    public let sendButtonText: [String:String]
    
    public let appName: String
    
    public let subtitle: [String:String]
    public let dontShowButtonTitle: [String:String]

    public enum CodingKeys: String, CodingKey {
        case id
        case createdAt        = "created_at"
        case feedbackType     = "feedback_type"
        case available
        case title
        case thankYouMessage  = "thank_you_message"
        case sendButtonText   = "send_button_text"
        case appName          = "app_name"
        case subtitle
        case dontShowButtonTitle = "dont_show_button"
    }

    public enum FeedbackType: String, Codable, Sendable {
        case rating
        case chat
    }
}

