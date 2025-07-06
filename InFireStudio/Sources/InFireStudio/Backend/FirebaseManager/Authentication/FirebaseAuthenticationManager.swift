//
//  File.swift
//  InFireStudio
//
//  Created by furkan vural on 25.06.2025.
//

import Foundation
import FirebaseAuth
import AuthenticationServices
import CryptoKit


// MARK: - Firebase Auth Manager
@MainActor
public class FirebaseAuthenticationManager: NSObject, ObservableObject {
    
    // MARK: - Singleton
    public static let shared = FirebaseAuthenticationManager()
    private var appleSignInCompletion: ((Result<InFireStudioUser, Error>) -> Void)?
    private let auth = Auth.auth()
    
    // MARK: - Published Properties
    @Published public var currentUser: InFireStudioUser?
    @Published public var isAuthenticated = false
    @Published public var isLoading = false
    
    // MARK: - Private Properties
    private var authStateListener: AuthStateDidChangeListenerHandle?
    private var currentNonce: String?
    
    private override init() {
        super.init()
        setupAuthListener()
    }
    
    
    
    // MARK: - Auth State Listener
    private func setupAuthListener() {
        authStateListener = auth.addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                if let user = user {
                    self?.currentUser = InFireStudioUser(from: user)
                    self?.isAuthenticated = true
                } else {
                    self?.currentUser = nil
                    self?.isAuthenticated = false
                }
            }
        }
    }
    
#warning("App tamamen kapatılınca bunu çağırmak zorundasın")
    /// Bunu çağırmak gerekebilir app kill olunca.
    /// 
    private func removeAuthListener() {
        if let listener = authStateListener {
            auth.removeStateDidChangeListener(listener)
            authStateListener = nil
        }
    }
}

// MARK: - Email/Password Authentication
extension FirebaseAuthenticationManager {
    
    /// Sign up with email and password
    /// - Parameters:
    ///   - email: User email
    ///   - password: User password
    ///   - completion: Completion callback
    public func signUp(
        email: String,
        password: String,
        completion: @escaping (Result<InFireStudioUser, Error>) -> Void
    ) {
        isLoading = true
        
        auth.createUser(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    completion(.failure(error))
                } else if let user = result?.user {
                    let inFireUser = InFireStudioUser(from: user)
                    completion(.success(inFireUser))
                } else {
                    completion(.failure(InFireAuthError.unknownError))
                }
            }
        }
    }
    
    /// Sign in with email and password
    /// - Parameters:
    ///   - email: User email
    ///   - password: User password
    ///   - completion: Completion callback
    public func signIn(
        email: String,
        password: String,
        completion: @escaping (Result<InFireStudioUser, Error>) -> Void
    ) {
        isLoading = true
        
        auth.signIn(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    completion(.failure(error))
                } else if let user = result?.user {
                    let inFireUser = InFireStudioUser(from: user)
                    completion(.success(inFireUser))
                } else {
                    completion(.failure(InFireAuthError.unknownError))
                }
            }
        }
    }
    
    /// Send password reset email
    /// - Parameters:
    ///   - email: User email
    ///   - completion: Completion callback
    public func resetPassword(
        email: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        auth.sendPasswordReset(withEmail: email) { error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }
    
    /// Send email verification
    /// - Parameter completion: Completion callback
    public func sendEmailVerification(
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let user = auth.currentUser else {
            completion(.failure(InFireAuthError.noCurrentUser))
            return
        }
        
        user.sendEmailVerification { error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }
}

// MARK: - Apple Sign In
extension FirebaseAuthenticationManager {
    
    /// Sign in with Apple
    /// - Parameter completion: Completion callback
    public func signInWithApple(
        completion: @escaping (Result<InFireStudioUser, Error>) -> Void
    ) {
        let nonce = randomNonceString()
        currentNonce = nonce
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
        
        // Store completion for delegate callback
        self.appleSignInCompletion = completion
    }
    
    
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError(
                "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
        }
        
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        let nonce = randomBytes.map { byte in
            charset[Int(byte) % charset.count]
        }
        
        return String(nonce)
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}

// MARK: - Phone Authentication
extension FirebaseAuthenticationManager {
    
    /// Send verification code to phone number
    /// - Parameters:
    ///   - phoneNumber: Phone number with country code
    ///   - completion: Completion callback with verification ID
    public func sendVerificationCode(
        to phoneNumber: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                } else if let verificationID = verificationID {
                    completion(.success(verificationID))
                } else {
                    completion(.failure(InFireAuthError.phoneVerificationFailed))
                }
            }
        }
    }
    
    /// Sign in with phone verification
    /// - Parameters:
    ///   - verificationID: Verification ID from sendVerificationCode
    ///   - verificationCode: SMS code received by user
    ///   - completion: Completion callback
    public func signInWithPhone(
        verificationID: String,
        verificationCode: String,
        completion: @escaping (Result<InFireStudioUser, Error>) -> Void
    ) {
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: verificationCode
        )
        
        signIn(with: credential, completion: completion)
    }
}

// MARK: - Anonymous Authentication
extension FirebaseAuthenticationManager {
    
    /// Sign in anonymously
    /// - Parameter completion: Completion callback
    public func signInAnonymously(
        completion: @escaping (Result<InFireStudioUser, Error>) -> Void
    ) {
        isLoading = true
        
        auth.signInAnonymously { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    completion(.failure(error))
                } else if let user = result?.user {
                    let inFireUser = InFireStudioUser(from: user)
                    UserDefaultsManager.shared.saveUserData(inFireUser)
                    completion(.success(inFireUser))
                } else {
                    completion(.failure(InFireAuthError.unknownError))
                }
            }
        }
    }
}

// MARK: - Generic Sign In with Credential
extension FirebaseAuthenticationManager {
    
    private func signIn(
        with credential: AuthCredential,
        completion: @escaping (Result<InFireStudioUser, Error>) -> Void
    ) {
        auth.signIn(with: credential) { [weak self] result, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                } else if let user = result?.user {
                    let inFireUser = InFireStudioUser(from: user)
                    completion(.success(inFireUser))
                } else {
                    completion(.failure(InFireAuthError.unknownError))
                }
            }
        }
    }
}

// MARK: - User Management
extension FirebaseAuthenticationManager {
    
    /// Sign out current user
    /// - Parameter completion: Completion callback
    public func signOut(completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try auth.signOut()
            DispatchQueue.main.async {
                completion(.success(()))
            }
        } catch {
            DispatchQueue.main.async {
                completion(.failure(error))
            }
        }
    }
    
    /// Delete current user account
    /// - Parameter completion: Completion callback
    public func deleteAccount(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = auth.currentUser else {
            completion(.failure(InFireAuthError.noCurrentUser))
            return
        }
        
        user.delete { error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }
    
    /// Update user profile
    /// - Parameters:
    ///   - displayName: New display name
    ///   - photoURL: New photo URL
    ///   - completion: Completion callback
    public func updateProfile(
        displayName: String? = nil,
        photoURL: URL? = nil,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let user = auth.currentUser else {
            completion(.failure(InFireAuthError.noCurrentUser))
            return
        }
        
        let changeRequest = user.createProfileChangeRequest()
        
        if let displayName = displayName {
            changeRequest.displayName = displayName
        }
        
        if let photoURL = photoURL {
            changeRequest.photoURL = photoURL
        }
        
        changeRequest.commitChanges { error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }
    
    /// Update user email
    /// - Parameters:
    ///   - newEmail: New email address
    ///   - completion: Completion callback
    public func updateEmail(
        to newEmail: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let user = auth.currentUser else {
            completion(.failure(InFireAuthError.noCurrentUser))
            return
        }
        
        user.updateEmail(to: newEmail) { error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }
    
    /// Update user password
    /// - Parameters:
    ///   - newPassword: New password
    ///   - completion: Completion callback
    public func updatePassword(
        to newPassword: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let user = auth.currentUser else {
            completion(.failure(InFireAuthError.noCurrentUser))
            return
        }
        
        user.updatePassword(to: newPassword) { error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }
}

// MARK: - Apple Sign In Delegates
extension FirebaseAuthenticationManager: ASAuthorizationControllerDelegate {
    
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                appleSignInCompletion?(.failure(InFireAuthError.appleSignInFailed))
                return
            }
            
            guard let appleIDToken = appleIDCredential.identityToken else {
                appleSignInCompletion?(.failure(InFireAuthError.appleSignInFailed))
                return
            }
            
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                appleSignInCompletion?(.failure(InFireAuthError.appleSignInFailed))
                return
            }
            
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                    idToken: idTokenString,
                                                    rawNonce: nonce)
            
            signIn(with: credential) { [weak self] result in
                self?.appleSignInCompletion?(result)
                self?.appleSignInCompletion = nil
            }
        }
    }
    
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        appleSignInCompletion?(.failure(error))
        appleSignInCompletion = nil
    }
}

extension FirebaseAuthenticationManager: ASAuthorizationControllerPresentationContextProviding {
    
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return ASPresentationAnchor()
        }
        return window
    }
}

// MARK: - Convenience Extensions
public extension FirebaseAuthenticationManager {
    
    /// Check if user is signed in
    var isSignedIn: Bool {
        return auth.currentUser != nil
    }
    
    /// Get current user UID
    var currentUserUID: String? {
        return auth.currentUser?.uid
    }
    
    /// Check if current user email is verified
    var isEmailVerified: Bool {
        return auth.currentUser?.isEmailVerified ?? false
    }
    
    /// Get current user providers
    var currentUserProviders: [String] {
        return auth.currentUser?.providerData.map { $0.providerID } ?? []
    }
}
