//
//  File.swift
//  InFireStudio
//
//  Created by furkan vural on 19.06.2025.
//


import UIKit

// MARK: - Data Models
public struct SettingsConfig: Codable {
    let settings: Settings
}

public struct Settings: Codable {
    let premiumView: PremiumView
    let sections: [SettingsSection]
    let appearance: Appearance
    let localization: Localization
}

public struct PremiumView: Codable {
    let type: String
    let title: [String: String]
    let image: ImageConfig
    let backgroundColor: String
    let cornerRadius: CGFloat
    let action: String
}

public struct ImageConfig: Codable {
    let name: String?
    let systemName: String?
}

public struct SettingsSection: Codable {
    let id: String
    let type: String
    let title: [String: String]
    let layout: SectionLayout?
    let items: [SettingsItem]
}

public struct SectionLayout: Codable {
    let itemsPerRow: Int
    let spacing: CGFloat
    let height: CGFloat
}

public struct SettingsItem: Codable, Hashable, Equatable {
    let id: String
    let type: String
    let title: [String: String]?
    let name: [String: String]?
    let icon: IconConfig?
    let iconURL: String?
    let fallbackIcon: String?
    let appStoreURL: String?
    let url: String?
    let action: String
    let textColor: String?
    let accessoryType: String
    
    enum CodingKeys: String, CodingKey {
        case id, type, title, name, icon, iconURL, fallbackIcon, appStoreURL, url, action, textColor, accessoryType
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        type = try container.decodeIfPresent(String.self, forKey: .type) ?? "button"
        title = try container.decodeIfPresent([String: String].self, forKey: .title)
        name = try container.decodeIfPresent([String: String].self, forKey: .name)
        icon = try container.decodeIfPresent(IconConfig.self, forKey: .icon)
        iconURL = try container.decodeIfPresent(String.self, forKey: .iconURL)
        fallbackIcon = try container.decodeIfPresent(String.self, forKey: .fallbackIcon)
        appStoreURL = try container.decodeIfPresent(String.self, forKey: .appStoreURL)
        url = try container.decodeIfPresent(String.self, forKey: .url)
        action = try container.decodeIfPresent(String.self, forKey: .action) ?? "default"
        textColor = try container.decodeIfPresent(String.self, forKey: .textColor)
        accessoryType = try container.decodeIfPresent(String.self, forKey: .accessoryType) ?? "none"
    }
    
    public init(id: String, type: String, title: [String: String]?, name: [String: String]?, icon: IconConfig?, iconURL: String?, fallbackIcon: String?, appStoreURL: String?, url: String?, action: String, textColor: String?, accessoryType: String?) {
        self.id = id
        self.type = type
        self.title = title
        self.name = name
        self.icon = icon
        self.iconURL = iconURL
        self.fallbackIcon = fallbackIcon
        self.appStoreURL = appStoreURL
        self.url = url
        self.action = action
        self.textColor = textColor
        self.accessoryType = accessoryType ?? "none"
    }
}

public struct IconConfig: Codable, Hashable {
    let systemName: String
    let color: String
}

public struct Appearance: Codable {
    let backgroundColor: String
    let sectionSpacing: CGFloat
    let sectionHeaderFont: FontConfig
    let cellFont: FontConfig
}

public struct FontConfig: Codable {
    let name: String
    let size: CGFloat
}

public struct Localization: Codable {
    let defaultLanguage: String
    let supportedLanguages: [String]
}
