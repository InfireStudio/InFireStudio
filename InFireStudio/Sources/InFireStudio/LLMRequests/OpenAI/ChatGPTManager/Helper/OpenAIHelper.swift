//
//  File.swift
//  InFireStudio
//
//  Created by furkan vural on 2.07.2025.
//

import Foundation
// MARK: - Error Types
@MainActor
public enum ChatGPTError: Error, @preconcurrency LocalizedError {
    case invalidURL
    case noData
    case invalidResponse
    case apiError(String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Geçersiz URL"
        case .noData:
            return "Veri alınamadı"
        case .invalidResponse:
            return "Geçersiz API yanıtı"
        case .apiError(let message):
            return "API Hatası: \(message)"
        }
    }
}


public enum ChatGPTPrompt: String {
    case analyzeFeedbackPrompt = """
        Aşağıdaki mesajı analiz et ve bu mesajın bir mobil uygulama hakkında gerçek bir kullanıcı feedback'i olup olmadığını değerlendir.
        
        Gerçek feedback sayılacak durumlar:
        - Uygulamanın özelliklerine dair yorumlar
        - Kullanıcı deneyimi hakkında görüşler
        - Hata/bug raporları
        - Geliştirme önerileri
        - Performans değerlendirmeleri
        - Arayüz/tasarım yorumları
        
        Gerçek feedback SAYILMAYACAK durumlar:
        - Genel konuşma/sohbet
        - İlgisiz sorular
        - Spam/anlamsız mesajlar
        - Reklam/tanıtım mesajları
        - Kişisel bilgi paylaşımları
        
        Sadece "true" veya "false" cevabı ver. Başka açıklama yapma.
        
        Mesaj:
    """
}



public enum ChatGPTModel: String {
    case gpt3dot5 = "gpt-3.5-turbo"
}

public enum ChatGPTMaxToken: Int {
    case tenToken = 10
}
