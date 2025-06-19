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
    func logError(_ app: InFireStudioApps, _ message: String, metadata: [String: String]?) async
}


@MainActor
public final class SupabaseLogService: LogService {
    
    private let client: SupabaseClient = .init(
        supabaseURL: URL(string: "https://ywptoygwapkvyvesogby.supabase.co")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl3cHRveWd3YXBrdnl2ZXNvZ2J5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTAxMDI4NzcsImV4cCI6MjA2NTY3ODg3N30.dZc8LgDO7ZGj84K35G5vO7cOuZ8xeZ2HBcuBGogfaOM"
    )
    
    public init() { }
    
    /// Supabase database tüm applerin içinden gönderilen hata mesajı
    ///  app: InFireStudioApps içindeki enumdan geliyor. Bu enum tüm applerin ismini içeriyor
    public func logError(_ app: InFireStudioApps, _ message: String, metadata: [String: String]? = nil) async {
        let row = ErrorLogRow(
            message: message,
            metadata: metadata ?? [:]
        )
        
        do {
            let _ = try await client.database
                .from(app.rawValue)
                .insert(row)
                .execute()
        } catch {
            print("Supabase insert error:", error)
        }
    }
}

public struct ErrorLogRow: Encodable, Sendable {
    let message: String
    let metadata: [String: String]
}
