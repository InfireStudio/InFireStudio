//
//  File.swift
//  InFireStudio
//
//  Created by furkan vural on 19.06.2025.
//

import Foundation
import UIKit

// MARK: - Settings Manager Protocol
public protocol SettingsManagerDelegate: AnyObject {
    func settingsManager(_ manager: SettingsManager, didTapPremium action: String)
    func settingsManager(_ manager: SettingsManager, didTapAction action: String, withItem item: SettingsItem)
    func settingsManager(_ manager: SettingsManager, didTapApp item: SettingsItem)
}

// MARK: - Settings Manager
@MainActor
public class SettingsManager: NSObject {
    
    public weak var delegate: SettingsManagerDelegate?
    
    public var config: SettingsConfig?
    private var currentLanguage: String = "en"
    
    public override init() {
        super.init()
        setupLanguage()
    }
    
    // MARK: - Public Methods
    public func createSettingsViewController(with jsonData: Data) -> UIViewController? {
        guard let config = parseJSON(jsonData) else { return nil }
        self.config = config
        
        let viewController = SettingsViewController()
        viewController.settingsManager = self
        return viewController
    }
    
    public func createSettingsViewController(with jsonString: String) -> UIViewController? {
        guard let data = jsonString.data(using: .utf8) else { return nil }
        return createSettingsViewController(with: data)
    }
    
    public func createSettingsViewController(fromBundle fileName: String) -> UIViewController? {
            print("SettingsManager: Looking for file: \(fileName).json")
            
            guard let path = Bundle.main.path(forResource: fileName, ofType: "json") else {
                print("SettingsManager: JSON file not found in bundle: \(fileName).json")
                return nil
            }
            
            print("SettingsManager: Found JSON file at path: \(path)")
            
            guard let data = NSData(contentsOfFile: path) as Data? else {
                print("SettingsManager: Could not read data from file")
                return nil
            }
            
            print("SettingsManager: Successfully read \(data.count) bytes from JSON file")
            return createSettingsViewController(with: data)
        }
        
        // MARK: - Private Methods
        private func parseJSON(_ data: Data) -> SettingsConfig? {
            do {
                let decoder = JSONDecoder()
                let config = try decoder.decode(SettingsConfig.self, from: data)
                print("SettingsManager: Successfully parsed JSON config")
                return config
            } catch let DecodingError.keyNotFound(key, context) {
                print("SettingsManager: JSON key not found: \(key.stringValue)")
                print("SettingsManager: Context: \(context.debugDescription)")
                return nil
            } catch let DecodingError.typeMismatch(type, context) {
                print("SettingsManager: JSON type mismatch for type: \(type)")
                print("SettingsManager: Context: \(context.debugDescription)")
                return nil
            } catch let DecodingError.valueNotFound(type, context) {
                print("SettingsManager: JSON value not found for type: \(type)")
                print("SettingsManager: Context: \(context.debugDescription)")
                return nil
            } catch let DecodingError.dataCorrupted(context) {
                print("SettingsManager: JSON data corrupted")
                print("SettingsManager: Context: \(context.debugDescription)")
                return nil
            } catch {
                print("SettingsManager: JSON parsing error - \(error)")
                
                // JSON içeriğini string olarak yazdır
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("SettingsManager: JSON content:")
                    print(jsonString)
                }
                return nil
            }
        }
    
    private func setupLanguage() {
        if let preferredLanguage = Locale.current.languageCode {
            currentLanguage = preferredLanguage
        }
    }
    
    internal func getLocalizedString(_ dictionary: [String: String]?) -> String {
        guard let dictionary = dictionary else { return "" }
        return dictionary[currentLanguage] ?? dictionary["en"] ?? ""
    }
    
    internal func hexToUIColor(_ hex: String) -> UIColor {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexString = hexString.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgb)
        
        return UIColor(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: 1.0
        )
    }
}
