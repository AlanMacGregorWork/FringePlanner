//
//  FringeDisabled.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 13/11/2024.
//

struct FringeDisabled: Equatable, Hashable {
    let otherServices: Bool?
    let audio: Bool?
    let captioningDates: [String]?
    let signedDates: [String]?
    let audioDates: [String]?
}

// MARK: Codable

private let kOtherServices = "otherServices"
private let kAudio = "audio"
private let kCaptioningDates = "captioningDates"
private let kSignedDates = "signedDates"
private let kAudioDates = "audioDates"

extension FringeDisabled: Codable {
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: AnyCodingKey.self)
        try container.encodeIfPresent(otherServices, forKey: kOtherServices)
        try container.encodeIfPresent(audio, forKey: kAudio)
        try container.encodeIfPresent(captioningDates?.joined(separator: ","), forKey: kCaptioningDates)
        try container.encodeIfPresent(signedDates?.joined(separator: ","), forKey: kSignedDates)
        try container.encodeIfPresent(audioDates?.joined(separator: ","), forKey: kAudioDates)
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: AnyCodingKey.self)
        self.otherServices = try container.decodeIfPresent(Bool.self, forKey: kOtherServices)
        self.audio = try container.decodeIfPresent(Bool.self, forKey: kAudio)
        self.captioningDates = try container.decodeIfPresent(String.self, forKey: kCaptioningDates)?
            .components(separatedBy: ",")
            .compactMap { $0.nilOnEmpty } // None of the elements should be empty
        self.signedDates = try container.decodeIfPresent(String.self, forKey: kSignedDates)?
            .components(separatedBy: ",")
            .compactMap { $0.nilOnEmpty } // None of the elements should be empty
        self.audioDates = try container.decodeIfPresent(String.self, forKey: kAudioDates)?
            .components(separatedBy: ",")
            .compactMap { $0.nilOnEmpty } // None of the elements should be empty
        
        // Additional key validation:
        
        // `captioning` and `signed` keys are not being stored as only the dates are important, this
        // logic below ensures that these values still corresponds to the dates informations
        if let captioningDates, !captioningDates.isEmpty {
            let captioning = try container.decodeIfPresent(Bool.self, forKey: "captioning")
            fringeAssert(captioning != nil, "Captioning Dates exist without Bool flag")
            fringeAssert(captioning ?? false, "Captioning Dates exist with Bool flag not true")
        }
        if let signedDates, !signedDates.isEmpty {
            let signed = try container.decodeIfPresent(Bool.self, forKey: "signed")
            fringeAssert(signed != nil, "Signed Dates exist without Bool flag")
            fringeAssert(signed ?? false, "Signed Dates exist with Bool flag not true")
        }
        
        container.validateAssumedNil(keys: ["otherServicesDates", "otherServicesInformation"])
    }
}
