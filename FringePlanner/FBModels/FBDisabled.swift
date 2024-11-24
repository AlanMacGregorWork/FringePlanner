//
//  FBDisabled.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 13/11/2024.
//

struct FBDisabled: Equatable, Hashable {
    let otherServices: Bool?
    let audio: Bool?
    let captioningDates: [String]?
    let signedDates: [String]?
}

extension FBDisabled: Decodable {
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: AnyCodingKey.self)
        self.otherServices = try container.decodeIfPresent(Bool.self, forKey: "otherServices")
        self.audio = try container.decodeIfPresent(Bool.self, forKey: "audio")
        self.captioningDates = try container.decodeIfPresent(String.self, forKey: "captioningDates")?
            .components(separatedBy: ",")
        self.signedDates = try container.decodeIfPresent(String.self, forKey: "signedDates")?
            .components(separatedBy: ",")
        
        // Additional key validation:
        
        // `captioning` and `signed` keys are not being stored as only the dates are important, this
        // logic below ensures that these values still corresponds to the dates informations
        if let captioningDates, !captioningDates.isEmpty {
            let captioning = try container.decodeIfPresent(Bool.self, forKey: "captioning")
            fbAssert(captioning != nil, "Captioning Dates exist without Bool flag")
            fbAssert(captioning ?? false, "Captioning Dates exist with Bool flag not true")
        }
        if let signedDates, !signedDates.isEmpty {
            let signed = try container.decodeIfPresent(Bool.self, forKey: "signed")
            fbAssert(signed != nil, "Signed Dates exist without Bool flag")
            fbAssert(signed ?? false, "Signed Dates exist with Bool flag not true")
        }
        
        container.validateAssumedNil(keys: ["audioDates", "otherServicesDates", "otherServicesInformation"])
    }
}
