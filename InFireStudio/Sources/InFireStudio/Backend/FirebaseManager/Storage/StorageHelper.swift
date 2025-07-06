//
//  File.swift
//  InFireStudio
//
//  Created by furkan vural on 25.06.2025.
//

import Foundation


@MainActor
public enum InFireStorageError: @preconcurrency LocalizedError {
    case invalidImageData
    case failedToGetDownloadURL
    case downloadFailed
    case metadataNotFound
    
    public var errorDescription: String? {
        switch self {
        case .invalidImageData:
            return "Invalid image data provided"
        case .failedToGetDownloadURL:
            return "Failed to get download URL"
        case .downloadFailed:
            return "Download operation failed"
        case .metadataNotFound:
            return "File metadata not found"
        }
    }
}
