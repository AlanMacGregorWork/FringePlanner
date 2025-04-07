//
//  Decoder.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 07/04/2025.
//

import Foundation

extension Decoder {
    /// - Returns: `true` if the decoder can validate missing keys
    var canValidateMissingKeys: Bool {
        guard let key = JSONDecoder.DecoderStorage.validateMissingValuesKey else { return false }
        guard let decoderStorage = self.userInfo[key] as? JSONDecoder.DecoderStorage else { return false }
        return decoderStorage.value as? Bool ?? false
    }
}
