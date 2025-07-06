//
//  File.swift
//  InFireStudio
//
//  Created by furkan vural on 2.07.2025.
//

import Foundation

@MainActor
public final class UserDefaultsManager {
    
    public static let shared = UserDefaultsManager()
    
    private let userDefaults = UserDefaults.standard
    private let userDataKey = "UserData"
    private let isUserLoggedInKey = "IsUserLeggedInKey"
    private let chatFeedback = "chatFeedback"
    private let ratingFeedback = "ratingFeedback"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private init() {}
    
    /// Kullanıcının Login Statüsünü verir
    public var isUserLoggedIn: Bool {
        get {
            return userDefaults.bool(forKey: isUserLoggedInKey)
        }
        set {
            userDefaults.set(newValue, forKey: isUserLoggedInKey)
        }
    }
    
    
    public var isChatFeedbackProcessCompleted: Bool {
        get {
            return userDefaults.bool(forKey: chatFeedback)
        }
        
        set {
            userDefaults.set(newValue, forKey: chatFeedback)
        }
    }
    
    public var isRatingFeedbackProcessCompleted: Bool {
        get {
            return userDefaults.bool(forKey: ratingFeedback)
        }
        
        set {
            userDefaults.set(newValue, forKey: ratingFeedback)
        }
    }
    
    
    /// Kullanıcı firebase kaydedilten sonra çağırılması gerekmektedir. App içinde başka yerde çağırılmamalıdır!
    public func saveUserData(_ userData: InFireStudioUser) {
        do {
            let encodedData = try encoder.encode(userData)
            userDefaults.set(encodedData, forKey: userDataKey)
            isUserLoggedIn = true
            print("✅ User data saved successfully")
        } catch {
            print("❌ Failed to save user data: \(error.localizedDescription)")
        }
    }
    
    
    /// Kullanıcı ile ilgili bilgileri geri döner.
    public func getUserData() -> InFireStudioUser? {
        guard let data = userDefaults.data(forKey: userDataKey) else {
            return nil
        }
        
        do {
            let userData = try decoder.decode(InFireStudioUser.self, from: data)
            return userData
        } catch {
            print("❌ Failed to decode user data: \(error.localizedDescription)")
            return nil
        }
    }
    
    
    public func updateUserData(completion: (inout InFireStudioUser) -> Void) {
        guard var userData = getUserData() else {
            print("❌ No user data to update")
            return
        }
        
        completion(&userData)
        saveUserData(userData)
    }
    
    
}


extension UserDefaultsManager {
    
    /// Özel olarak firebase'deki userID veriri
    public var userID: String? {
        return getUserData()?.uid
    }
    
    public var accountCreationDate: Date? {
        return getUserData()?.creationDate
    }
    
    public var notificationID: String? {
        get {
            return getUserData()?.notificationID
        }
        set {
            updateUserData { userData in
                userData.notificationID = newValue!
            }
        }
    }
    
}


extension UserDefaultsManager {
    
    public func printUserInfo() {
        guard let userData = getUserData() else {
            print("❌ No user data available")
            return
        }
        
        print("👤 User Information:")
        print("   User ID: \(userData.uid)")
        print("   Registration Date: \(String(describing: userData.creationDate))")
        print("   Email: \(userData.email ?? "Not set")")
        print("   Name: \(userData.displayName ?? "Not set")")
        print("   Notification ID: \(userData.notificationID)")
        print("   Notifications Enabled: \(String(describing: userData.phoneNumber))")
    }
}
