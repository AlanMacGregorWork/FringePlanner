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
    decoder.userInfo = JSONDecoder.DecoderStorage.eventCodeKey.map { [$0: JSONDecoder.DecoderStorage()] } ?? [:]
    return decoder
}

// MARK: -

extension JSONDecoder {
    /// A class that allows storing content in the `userInfo` part of the decoder
    class DecoderStorage {
        static let eventCodeKey = CodingUserInfoKey(rawValue: "eventId")
        var value: Any?
        
        // MARK: Errors
        
        enum DecoderStorageError: Error {
            case keyIsNil
            case valueIsNil
            case userInfoValueNotStorage
        }
    }
}
