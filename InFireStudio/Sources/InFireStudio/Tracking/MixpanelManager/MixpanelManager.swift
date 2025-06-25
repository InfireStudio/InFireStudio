//
//  File.swift
//  InFireStudio
//
//  Created by furkan vural on 19.06.2025.
//

import Foundation
import Mixpanel


@MainActor
public final class MixpanelManager {

    public static let shared = MixpanelManager()
    
    private var isInitialized: Bool = false

    private init() { }

    /// Mixpanel'i initialize eder.
    /// Kullanıcının firebase ID'si de gönderilsin.
    public func configure(with token: String, isDebugMode: Bool = false, userID: String) {
        Mixpanel.initialize(token: token, trackAutomaticEvents: true)
        isInitialized = true

        if isDebugMode {
            Mixpanel.mainInstance().loggingEnabled = true
        }
        
        identify(userId: userID)
    }

    /// Event gönderir.
    /// Her event için userID, sayfanın ismi, yapılan işlem, kullanıcının credit sayısı gönderilmez zorundadır.    
    public func track(event: String, properties: [TrackKey.RawValue: String]? = nil) {
        guard isInitialized else {
            fatalError("MixpanelManager: Not initialized. Call configure() first.")
            return
        }
        
        Mixpanel.mainInstance().track(event: event, properties: properties)
    }

    /// User ID ataması yapar
    public func identify(userId: String) {
        guard isInitialized else {
            fatalError("MixpanelManager: Not initialized. Call configure() first.")
            return
        }

        Mixpanel.mainInstance().identify(distinctId: userId)
    }

    /// User profile property set
    public func setUserProperties(_ properties: [String: String]) {
        guard isInitialized else {
            fatalError("MixpanelManager: Not initialized. Call configure() first.")
            return
        }

        Mixpanel.mainInstance().people.set(properties: properties)
    }
    
    /// Tüm mixpanel durumlarını resetler.
    public func reset() {
        guard isInitialized else {
            fatalError("MixpanelManager: Not initialized. Call configure() first.")
            return
        }

        Mixpanel.mainInstance().reset()
    }
}


public enum TrackKey: String {
    case pageName
    case eventName
    case userID
    case userCreditCount
}

