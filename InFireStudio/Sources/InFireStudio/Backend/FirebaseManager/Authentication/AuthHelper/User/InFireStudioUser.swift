//
//  File.swift
//  InFireStudio
//
//  Created by furkan vural on 2.07.2025.
//

import Foundation
import FirebaseAuth

// MARK: - Auth User Model
public struct InFireStudioUser: Codable {
    public let uid: String
    public let email: String?
    public let displayName: String?
    public let photoURL: URL?
    public let phoneNumber: String?
    public let isEmailVerified: Bool
    public let creationDate: Date?
    public let lastSignInDate: Date?
    public let providerData: [String]
    public var notificationID: String = .init()
    
    public init(from firebaseUser: User) {
        self.uid = firebaseUser.uid
        self.email = firebaseUser.email
        self.displayName = firebaseUser.displayName
        self.photoURL = firebaseUser.photoURL
        self.phoneNumber = firebaseUser.phoneNumber
        self.isEmailVerified = firebaseUser.isEmailVerified
        self.creationDate = firebaseUser.metadata.creationDate
        self.lastSignInDate = firebaseUser.metadata.lastSignInDate
        self.providerData = firebaseUser.providerData.map { $0.providerID }
    }
}
