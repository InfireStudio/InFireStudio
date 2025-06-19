//
//  File.swift
//  InFireStudio
//
//  Created by furkan vural on 19.06.2025.
//

import Foundation
import AVFoundation
import Photos
import UserNotifications
import AppTrackingTransparency
import UIKit

@MainActor
public final class PermissionManager {
    
    public static let shared = PermissionManager()
    private init() {}
    
    // MARK: - Request Permission Methods
    
    /// Request camera permission
    public func requestCameraPermission(completion: @escaping (PermissionStatus) -> Void) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .authorized:
            completion(.authorized)
        case .denied, .restricted:
            showPermissionAlert(for: .camera)
            completion(status == .denied ? .denied : .restricted)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    completion(granted ? .authorized : .denied)
                }
            }
        @unknown default:
            completion(.notDetermined)
        }
    }
    
    /// Request photo library permission
    public func requestPhotoLibraryPermission(completion: @escaping (PermissionStatus) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus()
        
        switch status {
        case .authorized:
            completion(.authorized)
        case .limited:
            completion(.limited)
        case .denied, .restricted:
            showPermissionAlert(for: .photoLibrary)
            completion(status == .denied ? .denied : .restricted)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { newStatus in
                DispatchQueue.main.async {
                    switch newStatus {
                    case .authorized:
                        completion(.authorized)
                    case .limited:
                        completion(.limited)
                    case .denied:
                        completion(.denied)
                    case .restricted:
                        completion(.restricted)
                    default:
                        completion(.notDetermined)
                    }
                }
            }
        @unknown default:
            completion(.notDetermined)
        }
    }
    
    /// Request notification permission
    public func requestNotificationPermission(completion: @escaping (PermissionStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .authorized, .provisional:
                    completion(.authorized)
                case .denied:
                    self.showPermissionAlert(for: .notification)
                    completion(.denied)
                case .notDetermined:
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
                        DispatchQueue.main.async {
                            completion(granted ? .authorized : .denied)
                        }
                    }
                case .ephemeral:
                    completion(.notDetermined)
                @unknown default:
                    completion(.notDetermined)
                }
            }
        }
    }
    
    /// Request tracking permission (iOS 14+)
    public func requestTrackingPermission(completion: @escaping (PermissionStatus) -> Void) {
        if #available(iOS 14, *) {
            let status = ATTrackingManager.trackingAuthorizationStatus
            
            switch status {
            case .authorized:
                completion(.authorized)
            case .denied, .restricted:
                showPermissionAlert(for: .tracking)
                completion(status == .denied ? .denied : .restricted)
            case .notDetermined:
                ATTrackingManager.requestTrackingAuthorization { newStatus in
                    DispatchQueue.main.async {
                        switch newStatus {
                        case .authorized:
                            completion(.authorized)
                        case .denied:
                            completion(.denied)
                        case .restricted:
                            completion(.restricted)
                        default:
                            completion(.notDetermined)
                        }
                    }
                }
            @unknown default:
                completion(.notDetermined)
            }
        } else {
            // iOS 14 öncesi için tracking her zaman authorized kabul edilir
            completion(.authorized)
        }
    }
    
    // MARK: - Check Permission Status Methods
    
    public func getCameraPermissionStatus() -> PermissionStatus {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized: return .authorized
        case .denied: return .denied
        case .restricted: return .restricted
        case .notDetermined: return .notDetermined
        @unknown default: return .notDetermined
        }
    }
    
    public func getPhotoLibraryPermissionStatus() -> PermissionStatus {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized: return .authorized
        case .limited: return .limited
        case .denied: return .denied
        case .restricted: return .restricted
        case .notDetermined: return .notDetermined
        @unknown default: return .notDetermined
        }
    }
    
    public func getNotificationPermissionStatus(completion: @escaping (PermissionStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .authorized, .provisional: completion(.authorized)
                case .denied: completion(.denied)
                case .notDetermined: completion(.notDetermined)
                case .ephemeral: completion(.notDetermined)
                @unknown default: completion(.notDetermined)
                }
            }
        }
    }
    
    public func getTrackingPermissionStatus() -> PermissionStatus {
        if #available(iOS 14, *) {
            let status = ATTrackingManager.trackingAuthorizationStatus
            switch status {
            case .authorized: return .authorized
            case .denied: return .denied
            case .restricted: return .restricted
            case .notDetermined: return .notDetermined
            @unknown default: return .notDetermined
            }
        } else {
            return .authorized
        }
    }
    
    // MARK: - Alert Methods
    
    private func showPermissionAlert(for permissionType: PermissionType) {
        guard let topViewController = getTopViewController() else { return }
        
        let alert = UIAlertController(
            title: getLocalizedString(for: "\(permissionType)_permission_title"),
            message: getLocalizedString(for: "\(permissionType)_permission_message"),
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(
            title: getLocalizedString(for: "cancel"),
            style: .cancel
        ))
        
        alert.addAction(UIAlertAction(
            title: getLocalizedString(for: "settings"),
            style: .default
        ) { _ in
            self.openAppSettings()
        })
        
        topViewController.present(alert, animated: true)
    }
    
    private func openAppSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(settingsUrl) else { return }
        UIApplication.shared.open(settingsUrl)
    }
    
    private func getTopViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            return nil
        }
        
        var topController = window.rootViewController
        while let presentedController = topController?.presentedViewController {
            topController = presentedController
        }
        return topController
    }
    
    // MARK: - Localization
    
    private func getLocalizedString(for key: String) -> String {
        let bundle = Bundle(for: type(of: self))
        return NSLocalizedString(key, bundle: bundle, comment: "")
    }
}
