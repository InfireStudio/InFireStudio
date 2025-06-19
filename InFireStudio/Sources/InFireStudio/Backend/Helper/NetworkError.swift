//
//  File.swift
//  InFireStudio
//
//  Created by furkan vural on 17.06.2025.
//

import Foundation

public enum NetworkError: String, Error, CaseIterable {
    
    case networkFailure      = "networkFailure"
    case invalidConfig       = "invalidConfig"
    case authenticationError = "authenticationError"
    case unknown             = "unknownError"
    
    /// Returns the localized description for the current locale.
    public var localizedDescription: String {
        // Look up in "InFireStudio" strings table inside the SDK bundle
        return NSLocalizedString(
            self.rawValue,
            tableName: "InFireStudio",
            bundle: Bundle.module,
            comment: ""
        )
    }
}
