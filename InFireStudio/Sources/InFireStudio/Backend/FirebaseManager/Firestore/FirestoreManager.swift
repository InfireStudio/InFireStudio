//
//  File.swift
//  InFireStudio
//
//  Created by furkan vural on 25.06.2025.
//

import Foundation
import Foundation
import FirebaseFirestore

// MARK: - Firestore Document Protocol
public protocol FirestoreDocument: Codable {
    var id: String? { get set }
    var createdAt: Date? { get set }
    var updatedAt: Date? { get set }
}

@MainActor
public class FirestoreManager {
    
    // MARK: - Singleton
    public static let shared = FirestoreManager()
    
    private let db = Firestore.firestore()
    
    private init() {
        let settings = FirestoreSettings()
        settings.cacheSettings = MemoryCacheSettings() // Sadece RAM'de cache. uygulama kapanınca siliyor
        
        // Diğer opsiyonlar
        // 100MB persistent cache
        // settings.cacheSettings = PersistentCacheSettings(sizeBytes: 100 * 1024 * 1024)

        // Unlimited cache size
        // settings.cacheSettings = PersistentCacheSettings()
        db.settings = settings
    }
    
    // MARK: - Common Collections
    public enum Collection: String {
        case users = "users"
        case posts = "posts"
        case comments = "comments"
        case notifications = "notifications"
        case chats = "chats"
        case messages = "messages"
        case categories = "categories"
        case products = "products"
        case orders = "orders"
        case result = "result"
        case history = "history"
        case friends = "friends"
        
        public func path(documentID: String? = nil) -> String {
            if let documentID = documentID {
                return "\(self.rawValue)/\(documentID)"
            }
            return self.rawValue
        }
        
        public func subCollection(_ subCollection: Collection, parentID: String, documentID: String? = nil) -> String {
            let basePath = "\(self.rawValue)/\(parentID)/\(subCollection.rawValue)"
            if let documentID = documentID {
                return "\(basePath)/\(documentID)"
            }
            return basePath
        }
    }
}

// MARK: - Save/Create Operations
extension FirestoreManager {
    
    /// Save document to Firestore (Create or Update)
    /// - Parameters:
    ///   - document: Document conforming to FirestoreDocument
    ///   - path: Firestore path (e.g., "users" or "users/123")
    ///   - completion: Completion callback with document ID or error
    public func save<T: FirestoreDocument>(
        _ document: T,
        to path: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        var doc = document
        let now = Date()
        
        // Auto-generate ID if not provided
        let documentID = doc.id ?? UUID().uuidString
        doc.id = documentID
        
        // Set timestamps
        if doc.createdAt == nil {
            doc.createdAt = now
        }
        doc.updatedAt = now
        
        let fullPath = path.hasSuffix("/") ? "\(path)\(documentID)" : "\(path)/\(documentID)"
        let docRef = db.document(fullPath)
        
        do {
            try docRef.setData(from: doc) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(documentID))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    /// Save document with custom document ID
    /// - Parameters:
    ///   - document: Document to save
    ///   - documentID: Custom document ID
    ///   - collection: Collection path
    ///   - completion: Completion callback
    public func save<T: FirestoreDocument>(
        _ document: T,
        with documentID: String,
        to collection: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        var doc = document
        doc.id = documentID
        
        let now = Date()
        if doc.createdAt == nil {
            doc.createdAt = now
        }
        doc.updatedAt = now
        
        let docRef = db.collection(collection).document(documentID)
        
        do {
            try docRef.setData(from: doc) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(documentID))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    /// Save document using Collection enum
    /// - Parameters:
    ///   - document: Document to save
    ///   - collection: Collection enum
    ///   - documentID: Optional document ID
    ///   - completion: Completion callback
    public func save<T: FirestoreDocument>(
        _ document: T,
        to collection: Collection,
        documentID: String? = nil,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        let path = collection.path(documentID: documentID)
        save(document, to: path, completion: completion)
    }
    
    /// Batch save multiple documents
    /// - Parameters:
    ///   - documents: Array of documents to save
    ///   - collection: Collection path
    ///   - completion: Completion callback with success count
    public func batchSave<T: FirestoreDocument>(
        _ documents: [T],
        to collection: String,
        completion: @escaping (Result<Int, Error>) -> Void
    ) {
        let batch = db.batch()
        var processedDocuments = 0
        
        for var document in documents {
            let documentID = document.id ?? UUID().uuidString
            document.id = documentID
            
            let now = Date()
            if document.createdAt == nil {
                document.createdAt = now
            }
            document.updatedAt = now
            
            let docRef = db.collection(collection).document(documentID)
            
            do {
                try batch.setData(from: document, forDocument: docRef)
                processedDocuments += 1
            } catch {
                completion(.failure(error))
                return
            }
        }
        
        batch.commit { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(processedDocuments))
            }
        }
    }
}

// MARK: - Read Operations
extension FirestoreManager {
    
    /// Fetch document by ID
    /// - Parameters:
    ///   - type: Document type
    ///   - documentID: Document ID
    ///   - collection: Collection path
    ///   - completion: Completion callback
    public func fetch<T: FirestoreDocument>(
        _ type: T.Type,
        documentID: String,
        from collection: String,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        let docRef = db.collection(collection).document(documentID)
        
        docRef.getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let snapshot = snapshot, snapshot.exists else {
                completion(.failure(InFireFirestoreError.documentNotFound))
                return
            }
            
            do {
                let document = try snapshot.data(as: type)
                completion(.success(document))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    /// Fetch all documents from collection
    /// - Parameters:
    ///   - type: Document type
    ///   - collection: Collection path
    ///   - limit: Optional limit
    ///   - completion: Completion callback
    public func fetchAll<T: FirestoreDocument>(
        _ type: T.Type,
        from collection: String,
        limit: Int? = nil,
        completion: @escaping (Result<[T], Error>) -> Void
    ) {
        var query: Query = db.collection(collection)
        
        if let limit = limit {
            query = query.limit(to: limit)
        }
        
        query.getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let documents = snapshot?.documents else {
                completion(.success([]))
                return
            }
            
            do {
                let results = try documents.compactMap { try $0.data(as: type) }
                completion(.success(results))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    /// Fetch documents with query
    /// - Parameters:
    ///   - type: Document type
    ///   - collection: Collection path
    ///   - queryBuilder: Query builder closure
    ///   - completion: Completion callback
    public func fetchWithQuery<T: FirestoreDocument>(
        _ type: T.Type,
        from collection: String,
        queryBuilder: (Query) -> Query,
        completion: @escaping (Result<[T], Error>) -> Void
    ) {
        let baseQuery = db.collection(collection)
        let query = queryBuilder(baseQuery)
        
        query.getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let documents = snapshot?.documents else {
                completion(.success([]))
                return
            }
            
            do {
                let results = try documents.compactMap { try $0.data(as: type) }
                completion(.success(results))
            } catch {
                completion(.failure(error))
            }
        }
    }
}

// MARK: - Update Operations
extension FirestoreManager {
    
    /// Update specific fields of a document
    /// - Parameters:
    ///   - documentID: Document ID
    ///   - collection: Collection path
    ///   - fields: Fields to update
    ///   - completion: Completion callback
    public func updateFields(
        documentID: String,
        in collection: String,
        fields: [String: Any],
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        var updatedFields = fields
        updatedFields["updatedAt"] = Date()
        
        let docRef = db.collection(collection).document(documentID)
        
        docRef.updateData(updatedFields) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}

// MARK: - Delete Operations
extension FirestoreManager {
    
    /// Delete document by ID
    /// - Parameters:
    ///   - documentID: Document ID
    ///   - collection: Collection path
    ///   - completion: Completion callback
    public func delete(
        documentID: String,
        from collection: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let docRef = db.collection(collection).document(documentID)
        
        docRef.delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    /// Batch delete multiple documents
    /// - Parameters:
    ///   - documentIDs: Array of document IDs
    ///   - collection: Collection path
    ///   - completion: Completion callback
    public func batchDelete(
        documentIDs: [String],
        from collection: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let batch = db.batch()
        
        for documentID in documentIDs {
            let docRef = db.collection(collection).document(documentID)
            batch.deleteDocument(docRef)
        }
        
        batch.commit { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}

// MARK: - Real-time Listeners
extension FirestoreManager {
    
    /// Listen to document changes
    /// - Parameters:
    ///   - type: Document type
    ///   - documentID: Document ID
    ///   - collection: Collection path
    ///   - listener: Change listener callback
    /// - Returns: Listener registration for cleanup
    @discardableResult
    public func listen<T: FirestoreDocument>(
        to type: T.Type,
        documentID: String,
        in collection: String,
        listener: @escaping (Result<T, Error>) -> Void
    ) -> ListenerRegistration {
        let docRef = db.collection(collection).document(documentID)
        
        return docRef.addSnapshotListener { snapshot, error in
            if let error = error {
                listener(.failure(error))
                return
            }
            
            guard let snapshot = snapshot, snapshot.exists else {
                listener(.failure(InFireFirestoreError.documentNotFound))
                return
            }
            
            do {
                let document = try snapshot.data(as: type)
                listener(.success(document))
            } catch {
                listener(.failure(error))
            }
        }
    }
    
    /// Listen to collection changes
    /// - Parameters:
    ///   - type: Document type
    ///   - collection: Collection path
    ///   - queryBuilder: Optional query builder
    ///   - listener: Change listener callback
    /// - Returns: Listener registration for cleanup
    @discardableResult
    public func listenToCollection<T: FirestoreDocument>(
        _ type: T.Type,
        in collection: String,
        queryBuilder: ((Query) -> Query)? = nil,
        listener: @escaping (Result<[T], Error>) -> Void
    ) -> ListenerRegistration {
        var query: Query = db.collection(collection)
        
        if let queryBuilder = queryBuilder {
            query = queryBuilder(query)
        }
        
        return query.addSnapshotListener { snapshot, error in
            if let error = error {
                listener(.failure(error))
                return
            }
            
            guard let documents = snapshot?.documents else {
                listener(.success([]))
                return
            }
            
            do {
                let results = try documents.compactMap { try $0.data(as: type) }
                listener(.success(results))
            } catch {
                listener(.failure(error))
            }
        }
    }
}

// MARK: - Custom Errors
public enum InFireFirestoreError: LocalizedError {
    case documentNotFound
    case invalidData
    case encodingFailed
    case decodingFailed
    
    public var errorDescription: String? {
        switch self {
        case .documentNotFound:
            return "Document not found"
        case .invalidData:
            return "Invalid data provided"
        case .encodingFailed:
            return "Failed to encode document"
        case .decodingFailed:
            return "Failed to decode document"
        }
    }
}

// MARK: - Convenience Extensions
public extension FirestoreManager {
    
    /// Save user document
    func saveUser<T: FirestoreDocument>(_ user: T, completion: @escaping (Result<String, Error>) -> Void) {
        save(user, to: .users, completion: completion)
    }
    
    /// Save post document
    func savePost<T: FirestoreDocument>(_ post: T, completion: @escaping (Result<String, Error>) -> Void) {
        save(post, to: .posts, completion: completion)
    }
    
    /// Fetch user by ID
    func fetchUser<T: FirestoreDocument>(_ type: T.Type, userID: String, completion: @escaping (Result<T, Error>) -> Void) {
        fetch(type, documentID: userID, from: Collection.users.rawValue, completion: completion)
    }
}
