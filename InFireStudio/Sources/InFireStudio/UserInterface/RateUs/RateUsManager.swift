//
//  File.swift
//  InFireStudio
//
//  Created by furkan vural on 20.06.2025.
//

import Foundation
import StoreKit

@MainActor
public final class RateUsManager {
    
    public static let shared = RateUsManager()
    
    public init() {}
    
    public func rateUs() {
        SKStoreReviewController.requestReview()
    }
}
