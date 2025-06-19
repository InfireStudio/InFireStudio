//
//  LocalizationManager.swift
//  InFireStudio
//
//  Created by furkan vural on 15.06.2025.
//

import Foundation

open class LocalizationManager {
    
    @MainActor static let shared = LocalizationManager()

    // Kullanıcının cihaz dilini burada tutuyoruz, eğer desteklemeyen bir dilse İngilizce olarak belirledik
    private var language: String {
        let preferred = Locale.preferredLanguages.first ?? "en"
        if preferred.contains("tr") { return "tr" }
        if preferred.contains("de") { return "de" }
        return "en"
    }

    private var localizedStrings: [String: String] = [:]

    private init() {
        loadLocalization()
    }

    private func loadLocalization() {
        
//        if let path = Bundle.module.path(forResource: "Localizable_\(language)", ofType: "json"),
//           let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
//           let json = try? JSONDecoder().decode([String: String].self, from: data) {
//            localizedStrings = json
//        }
    }

    func localized(_ key: String) -> String {
        return localizedStrings[key] ?? key
    }
}
