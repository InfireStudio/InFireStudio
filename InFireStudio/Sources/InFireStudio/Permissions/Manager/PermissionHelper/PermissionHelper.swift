//
//  File.swift
//  InFireStudio
//
//  Created by furkan vural on 19.06.2025.
//

import Foundation

// MARK: - Permission Types
public enum PermissionType {
    case camera
    case photoLibrary
    case notification
    case tracking
}

// MARK: - Permission Status
public enum PermissionStatus {
    case authorized
    case denied
    case notDetermined
    case restricted
    case limited // For photo library
}
