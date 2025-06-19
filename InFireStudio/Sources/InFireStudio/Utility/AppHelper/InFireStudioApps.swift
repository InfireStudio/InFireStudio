//
//  File.swift
//  InFireStudio
//
//  Created by furkan vural on 18.06.2025.
//

import Foundation

/// InFireStudioApps adı altında geliştirilen tüm app isimleri burada olsun.
/// Supabase table oluşturularak, buradaki raw value ile eşleşmesi sağlanacak
/// App içindeki hata mesajlarının sorunsuz gidebilmesi için eşleşmesi mecburidir
///
@MainActor
public enum InFireStudioApps: String {
    case aiVideoGenerator = "pex_note_taker"
    case aiImageGenerator = "normal_ai_image_generator"
}

