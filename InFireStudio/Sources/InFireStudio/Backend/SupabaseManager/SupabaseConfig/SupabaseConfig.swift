//
//  File.swift
//  InFireStudio
//
//  Created by furkan vural on 17.06.2025.
//

import Foundation

/// Supabase’e bağlanmak için gereken parametreleri taşır
public struct SupabaseConfig {
  public let url: URL
  public let anonKey: String

  public init(url: URL, anonKey: String) {
    self.url = url
    self.anonKey = anonKey
  }
}
