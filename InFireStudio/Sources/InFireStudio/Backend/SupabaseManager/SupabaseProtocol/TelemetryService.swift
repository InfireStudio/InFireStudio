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
    func logError(_ app: InFireStudioApps, _ message: ErrorLoggingMessage, metadata: [String: String]?) async
}


@MainActor
public final class SupabaseLogService: LogService {
    
    private let client: SupabaseClient = .init(
        supabaseURL: URL(string: "https://ywptoygwapkvyvesogby.supabase.co")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl3cHRveWd3YXBrdnl2ZXNvZ2J5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTAxMDI4NzcsImV4cCI6MjA2NTY3ODg3N30.dZc8LgDO7ZGj84K35G5vO7cOuZ8xeZ2HBcuBGogfaOM"
    )
    
    public init() { }
    
    /// Supabase database tüm applerin içinden gönderilen hata mesajı
    /// app: InFireStudioApps içindeki enumdan geliyor. Bu enum tüm applerin ismini içeriyor.
    ///
    public func logError(_ app: InFireStudioApps, _ message: ErrorLoggingMessage, metadata: [String: String]? = nil) async {
        
        let row = ErrorLogRow(
            message: message.rawValue,
            metadata: metadata ?? [:]
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
}

// Move File
public struct ErrorLogRow: Encodable, Sendable {
    let message: String
    let metadata: [String: String]
}

// Move File
@MainActor
public struct Instrument: Codable {
    let id: String
    let feedback_is_available: Bool
    let hard_paywall: Bool
    let show_new_app: String
}
