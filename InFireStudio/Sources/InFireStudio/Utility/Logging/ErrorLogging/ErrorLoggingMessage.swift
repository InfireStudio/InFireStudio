//
//  File.swift
//  InFireStudio
//
//  Created by furkan vural on 19.06.2025.
//

import Foundation

@MainActor
public enum ErrorLoggingMessage: String {
    case requiredAPIPayment
    case requestFailed
    case invalidResponse
    case timeout
    case authenticationFailed
    case authorizationFailed
    case invalidCredentials
    case invalidToken
    case invalidRequest
    case resourceNotFound
    case internalServerError
    case serviceUnavailable
    case tooManyRequests
    case rateLimitExceeded
    case conflict
    case unknown
}
