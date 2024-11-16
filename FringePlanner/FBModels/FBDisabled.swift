//
//  FBDisabled.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 13/11/2024.
//

struct FBDisabled: Equatable {
    let captioning: Bool?
    let otherServices: Bool?
    let signed: Bool?
    let audio: Bool?
}

extension FBDisabled: Decodable {
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: AnyCodingKey.self)
        self.captioning = try container.decodeIfPresent(Bool.self, forKey: "captioning")
        self.otherServices = try container.decodeIfPresent(Bool.self, forKey: "otherServices")
        self.signed = try container.decodeIfPresent(Bool.self, forKey: "signed")
        self.audio = try container.decodeIfPresent(Bool.self, forKey: "audio")

        container.validateAssumedNil(keys: [
            "audioDates", "captioningDates", "otherServicesDates", "otherServicesInformation", "signedDates"])
    }
}
