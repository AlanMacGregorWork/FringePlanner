//
//  HMACGenerator.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 30/10/2024.
//

import CommonCrypto
import Foundation

struct HMACGenerator {
    
    // MARK: Properties
    
    private static let digestLength = Int(CC_SHA1_DIGEST_LENGTH) // SHA-1 should be 20
    private static let algorithm = CCHmacAlgorithm(kCCHmacAlgSHA1)
    private init() {}
    
    // MARK: Creation
    
    /// Creates a SHA-1 HMAC hash of the input using the provided key
    /// - Returns: A 40-character hexadecimal string
    static func createHash(for input: String, key: String) throws(GeneratorError) -> String {
        // Verify parameters
        guard !key.isEmpty else { throw .keyIsEmpty }
        guard !input.isEmpty else { throw .inputIsEmpty }
        
        // Convert Swift Strings to cString
        guard let inputAsCString = input.cString(using: .utf8) else { throw .failedToCreateInput }
        guard let keyAsCString = key.cString(using: .utf8) else { throw .failedToCreateKey }
        
        // Get Lengths
        let inputLength = Int(input.lengthOfBytes(using: .utf8))
        let keyLength = Int(key.lengthOfBytes(using: .utf8))
        
        // Create the HMAC
        var result = [UInt8](repeating: 0, count: digestLength)
        CCHmac(algorithm, keyAsCString, keyLength, inputAsCString, inputLength, &result)
        
        // Convert the HMAC hex into a String
        let digest = result.map { String(format: "%02x", $0) }.joined()
        return digest
    }
}

// MARK: Enums

extension HMACGenerator {
    enum GeneratorError: Error {
        case failedToCreateInput
        case failedToCreateKey
        case keyIsEmpty
        case inputIsEmpty
    }
}
