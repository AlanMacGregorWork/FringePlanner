//
//  ApiKey.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 27/10/2024.
//

import Foundation

/// Allows access to supported API keys
enum ApiKey: CaseIterable {
    case fringeSecretSigningKey
    case fringeApiKey
   
    /// The actual API key value
    var value: String {
        guard let dict = Bundle.main.infoDictionary else { preconditionFailure("Dictionary does not exist") }
        let value = dict[name] as? String ?? ""
        guard !value.isEmpty else { preconditionFailure("Value for `\(name)` should not be empty") }
        return value
    }
    
    /// Note: The `name` is used instead of setting `ApiKey.RawValue` as `String` to avoid accidentally
    /// using `rawValue` instead of `value`.
    private var name: String {
        switch self {
        case .fringeSecretSigningKey: "FRINGE_SECRET_SIGNING_KEY"
        case .fringeApiKey: "FRINGE_API_KEY"
        }
    }
}
