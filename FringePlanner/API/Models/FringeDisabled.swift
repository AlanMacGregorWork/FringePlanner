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
}

extension FringeDisabled: Decodable {
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
            fringeAssert(captioning != nil, "Captioning Dates exist without Bool flag")
            fringeAssert(captioning ?? false, "Captioning Dates exist with Bool flag not true")
        }
        if let signedDates, !signedDates.isEmpty {
            let signed = try container.decodeIfPresent(Bool.self, forKey: "signed")
            fringeAssert(signed != nil, "Signed Dates exist without Bool flag")
            fringeAssert(signed ?? false, "Signed Dates exist with Bool flag not true")
        }
        
        container.validateAssumedNil(keys: ["audioDates", "otherServicesDates", "otherServicesInformation"])
    }
}
