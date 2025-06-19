//
//  File.swift
//  InFireStudio
//
//  Created by furkan vural on 19.06.2025.
//

import Foundation


protocol InFireStudioProtocol {
    func trackEvent(name: String, parameters: [String: Any]?)
}


@MainActor
public final class MixpanelManager {
    
    static let shared: MixpanelManager = .init()
    
    private init() { }
    
}
