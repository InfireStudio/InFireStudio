//
//  File.swift
//  InFireStudio
//
//  Created by furkan vural on 19.06.2025.
//

import Foundation
import UIKit

@MainActor
public enum ErrorLoggingMessage: String {
    case firebase
    case requiredAPIPayment
    case paywallError
    case unknown
}

public class InFireAssets {
    public static func neutralFace() -> UIImage? {
        return UIImage(named: "neutral_face", in: Bundle.module, compatibleWith: nil)
    }
    
    public static func smilingFace() -> UIImage? {
        return UIImage(named: "smiling_face", in: Bundle.module, compatibleWith: nil)
    }
    
    public static func slightlyFace() -> UIImage? {
        return UIImage(named: "slightly_frowning_face", in: Bundle.module, compatibleWith: nil)
    }
    
    public static func smilingHeartsFace() -> UIImage? {
        return UIImage(named: "smiling_face_with_hearts", in: Bundle.module, compatibleWith: nil)
    }
    
    public static func getInFireStudioLogo() -> UIImage? {
        return UIImage(named: "in_fire_studio_logo", in: Bundle.module, compatibleWith: nil)
    }
    
}
