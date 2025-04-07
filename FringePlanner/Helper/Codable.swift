//
//  Codable.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 15/11/2024.
//

import Foundation

/// The default date formatter for the Fringe endpoints
let fringeDateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.timeZone = TimeZone(identifier: "UTC")
    return dateFormatter
}()

/// The main decoder for the Fringe response
var fringeJsonDecoder: JSONDecoder {
    // Note: This decoder must be recreated each time so that the `userInfo` is cleared, allowing
    // the `FringePerformance` to not access previously used information about a different `FringeEvent`
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    decoder.dateDecodingStrategy = .formatted(fringeDateFormatter)

    // The API decoder can use some added functionality to help with decoding
    decoder.userInfo = [
        JSONDecoder.DecoderStorage.eventCodeKey: JSONDecoder.DecoderStorage(),
        JSONDecoder.DecoderStorage.validateMissingValuesKey: JSONDecoder.DecoderStorage(value: true)
    ].reduce(into: [:]) { result, pair in
        // Map all of the optional keys to non-optional keys
        guard let key = pair.key else { return }
        result[key] = pair.value
    }
    
    return decoder
}

// MARK: -

extension JSONDecoder {
    /// A class that allows storing content in the `userInfo` part of the decoder
    class DecoderStorage {
        static let eventCodeKey = CodingUserInfoKey(rawValue: "eventId")
        /// If exists, validation can be performed for missing keys
        static let validateMissingValuesKey = CodingUserInfoKey(rawValue: "validateMissingValues")
        var value: Any?
        
        init(value: Any? = nil) {
            self.value = value
        }
        
        // MARK: Errors
        
        enum DecoderStorageError: Error {
            case keyIsNil
            case valueIsNil
            case userInfoValueNotStorage
        }
    }
}
