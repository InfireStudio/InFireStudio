//
//  File.swift
//  InFireStudio
//
//  Created by furkan vural on 27.06.2025.
//

import Foundation

@MainActor
public final class ChatGPTManager {
    
    private let apiKey: String
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    
    public init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    
    /// Verilen mesajın app hakkında gerçek bir feedback olup olmadığını değerlendirir
    /// - Parameter message: Değerlendirilecek mesaj
    /// - Parameter completion: true/false sonucu dönen completion handler
    ///
    func evaluateFeedback(_ message: String, completion: @escaping @Sendable (Result<Bool, Error>) -> Void) {
        
        let basePrompt = ChatGPTPrompt.analyzeFeedbackPrompt.rawValue
        let prompt = "\(basePrompt) \(message)"
        
        
        let requestBody: [String: Any] = [
            "model": ChatGPTModel.gpt3dot5.rawValue,
            "messages": [
                [
                    "role": "user",
                    "content": prompt
                ]
            ],
            "max_tokens": ChatGPTMaxToken.tenToken.rawValue,
        ]
        
        guard let url = URL(string: baseURL) else {
            completion(.failure(ChatGPTError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(ChatGPTError.noData))
                return
            }
            
            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                
                if let choices = jsonResponse?["choices"] as? [[String: Any]],
                   let firstChoice = choices.first,
                   let message = firstChoice["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    
                    let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                    let isFeedback = trimmedContent == "true"
                    
                    DispatchQueue.main.async {
                        completion(.success(isFeedback))
                    }
                } else {
                    completion(.failure(ChatGPTError.invalidResponse))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

