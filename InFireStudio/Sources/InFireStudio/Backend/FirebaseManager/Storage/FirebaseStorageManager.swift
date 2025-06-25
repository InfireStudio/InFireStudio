//
//  File.swift
//  InFireStudio
//
//  Created by furkan vural on 25.06.2025.
//

import Foundation
import FirebaseStorage
import UIKit

// MARK: - Firebase Storage Manager
@MainActor
public class InFireStorageManager {
    
    
    public static let shared = InFireStorageManager()
    
    private let storage = Storage.storage()
    private let storageRef: StorageReference
    
    private init() {
        self.storageRef = storage.reference()
    }
    
    // MARK: - Storage Paths
    public enum StoragePath: String {
        case images = "images"
        case videos = "videos"
        case documents = "documents"
        case audio = "audio"
        case profiles = "profiles"
        case thumbnails = "thumbnails"
        
        public func path(with filename: String) -> String {
            return "\(self.rawValue)/\(filename)"
        }
    }
}

// MARK: - Upload Methods
extension InFireStorageManager {
    
    /// Firebase image yükler. Yüklenen resmin URL'ini döndürür. Progress ile yüzdesini de kullanbilirsin.
    /// - Parameters:
    ///   - image: UIImage to upload
    ///   - path: Storage path
    ///   - filename: Optional filename (auto-generated if nil)
    ///   - compression: Image compression quality (0.0 - 1.0)
    ///   - progress: Upload progress callback
    ///   - completion: Completion callback with download URL or error
    public func uploadImage(
        _ image: UIImage,
        to path: StoragePath,
        filename: String? = nil,
        compression: CGFloat = 0.8,
        progress: ((Double) -> Void)? = nil,
        completion: @escaping (Result<URL, Error>) -> Void
    ) {
        guard let imageData = image.jpegData(compressionQuality: compression) else {
            completion(.failure(InFireStorageError.invalidImageData))
            return
        }
        
        let fileName = filename ?? generateUniqueFilename(extension: "jpg")
        let fullPath = path.path(with: fileName)
        
        uploadData(imageData, to: fullPath, contentType: "image/jpeg", progress: progress, completion: completion)
    }
    
    /// Upload data to Firebase Storage. Video or image data can accepted
    /// - Parameters:
    ///   - data: Data to upload
    ///   - path: Full storage path
    ///   - contentType: MIME type
    ///   - progress: Upload progress callback
    ///   - completion: Completion callback with download URL or error
    public func uploadData(
        _ data: Data,
        to path: String,
        contentType: String,
        progress: ((Double) -> Void)? = nil,
        completion: @escaping (Result<URL, Error>) -> Void
    ) {
        let fileRef = storageRef.child(path)
        let metadata = StorageMetadata()
        metadata.contentType = contentType
        
        let uploadTask = fileRef.putData(data, metadata: metadata) { [weak self] metadata, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Get download URL
            fileRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                } else if let url = url {
                    completion(.success(url))
                } else {
                    completion(.failure(InFireStorageError.failedToGetDownloadURL))
                }
            }
        }
        
        // Progress tracking
        uploadTask.observe(.progress) { snapshot in
            let percentComplete = Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
            progress?(percentComplete)
        }
    }
    
    /// Upload file from URL
    /// - Parameters:
    ///   - fileURL: Local file URL
    ///   - storagePath: Storage path
    ///   - progress: Upload progress callback
    ///   - completion: Completion callback with download URL or error
    public func uploadFile(
        from fileURL: URL,
        to storagePath: String,
        progress: ((Double) -> Void)? = nil,
        completion: @escaping (Result<URL, Error>) -> Void
    ) {
        let fileRef = storageRef.child(storagePath)
        
        let uploadTask = fileRef.putFile(from: fileURL) { metadata, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            fileRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                } else if let url = url {
                    completion(.success(url))
                } else {
                    completion(.failure(InFireStorageError.failedToGetDownloadURL))
                }
            }
        }
        
        uploadTask.observe(.progress) { snapshot in
            let percentComplete = Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
            progress?(percentComplete)
        }
    }
}


// MARK: - Convenience Extensions
public extension InFireStorageManager {
    
    /// Upload profile image with automatic path
    /// - Parameters:
    ///   - image: Profile image
    ///   - userID: User identifier
    ///   - completion: Completion callback
    func uploadProfileImage(
        _ image: UIImage,
        for userID: String,
        completion: @escaping (Result<URL, Error>) -> Void
    ) {
        let filename = "profile_\(userID).jpg"
        uploadImage(image, to: .profiles, filename: filename, compression: 0.7, completion: completion)
    }
    
    /// Upload thumbnail with automatic compression
    /// - Parameters:
    ///   - image: Original image
    ///   - filename: Thumbnail filename
    ///   - completion: Completion callback
    func uploadThumbnail(
        _ image: UIImage,
        filename: String,
        completion: @escaping (Result<URL, Error>) -> Void
    ) {
        uploadImage(image, to: .thumbnails, filename: filename, compression: 0.5, completion: completion)
    }
}


// MARK: - Utility Methods
extension InFireStorageManager {
    
    /// Generate unique filename with timestamp
    /// - Parameter extension: File extension
    /// - Returns: Unique filename
    private func generateUniqueFilename(extension: String) -> String {
        let timestamp = Int(Date().timeIntervalSince1970)
        let uuid = UUID().uuidString.prefix(8)
        return "\(timestamp)_\(uuid).\(`extension`)"
    }
    
    /// Get file metadata
    /// - Parameters:
    ///   - path: Storage path
    ///   - completion: Completion callback with metadata or error
    public func getMetadata(
        for path: String,
        completion: @escaping (Result<StorageMetadata, Error>) -> Void
    ) {
        let fileRef = storageRef.child(path)
        
        fileRef.getMetadata { metadata, error in
            if let error = error {
                completion(.failure(error))
            } else if let metadata = metadata {
                completion(.success(metadata))
            } else {
                completion(.failure(InFireStorageError.metadataNotFound))
            }
        }
    }
}
