//
//  File.swift
//  InFireStudio
//
//  Created by furkan vural on 2.07.2025.
//

import Foundation
// MARK: - Custom Errors
public enum InFireAuthError: LocalizedError {
    case noCurrentUser
    case unknownError
    case googleConfigurationError
    case googleSignInFailed
    case appleSignInFailed
    case phoneVerificationFailed
    
    public var errorDescription: String? {
        switch self {
        case .noCurrentUser:
            return "No current user found"
        case .unknownError:
            return "An unknown error occurred"
        case .googleConfigurationError:
            return "Google Sign-In configuration error"
        case .googleSignInFailed:
            return "Google Sign-In failed"
        case .appleSignInFailed:
            return "Apple Sign-In failed"
        case .phoneVerificationFailed:
            return "Phone verification failed"
        }
    }
}
