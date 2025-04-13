//
//  FringeEvent.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 15/11/2024.
//

import Foundation

struct FringeEvent: Equatable, Hashable {
    let title: String
    let subTitle: String?
    let artist: String?
    /// Example: `Germany`, `Ireland`, `Scotland`
    let country: String?
    let descriptionTeaser: String?
    let code: String
    /// Example: `5-9 yrs`, `11-15 yrs`
    let ageCategory: String?
    let description: String
    let festival: String
    let festivalId: String
    let genre: String
    /// Example: `Art, Event`
    let genreTags: String?
    let performances: [FringePerformance]
    let performanceSpace: FringePerformanceSpace
    let status: FringeStatus
    let url: URL
    let venue: FringeVenue
    let website: URL
    let disabled: FringeDisabled?
    let images: [String: FringeImage]
    let warnings: String?
    let updated: Date
    let year: Int
}

// MARK: APIFringeModelType

extension FringeEvent: APIFringeModel {
    typealias DBFringeModelType = DBFringeEvent
    var referenceID: String { "Event-\(code)" }
}

// MARK: Codable

extension FringeEvent: Codable {
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: AnyCodingKey.self)
        
        // The performance model does not include the events code that is needed for the database tables to correctly
        // relate. In order for the performance model to access this value it will need to be passed via the decoder.
        self.code = try container.decode(String.self, forKey: "code").trimmed
        // Add event code into the decoder so the performances can retrieve it
        guard let eventCodeKey = JSONDecoder.DecoderStorage.eventCodeKey else {
            throw JSONDecoder.DecoderStorage.DecoderStorageError.keyIsNil }
        // FP-2: The `JSONDecoderStorage` should be a requirement, however we currently have tests that encode this
        // model meaning that a general JSONDecoder may be used instead. This will be removed, and will then throw
        // if the type is incorrect
        if let eventCodeStorage = decoder.userInfo[eventCodeKey] as? JSONDecoder.DecoderStorage {
            eventCodeStorage.value = self.code
        }
        
        // Now decode everything else

        self.title = try container.decode(String.self, forKey: "title").trimmed
        self.ageCategory = try container.decodeIfPresent(String.self, forKey: "ageCategory")?.trimmed.nilOnEmpty
        self.artist = try container.decodeIfPresent(String.self, forKey: "artist")?.trimmed.nilOnEmpty
        self.country = try container.decodeIfPresent(String.self, forKey: "country")?.trimmed.nilOnEmpty
        self.warnings = try container.decodeIfPresent(String.self, forKey: "warnings")?.trimmed.nilOnEmpty
        self.status = try container.decode(FringeStatus.self, forKey: "status")
        self.festival = try container.decode(String.self, forKey: "festival").trimmed
        self.festivalId = try container.decode(String.self, forKey: "festivalId").trimmed
        self.genre = try container.decode(String.self, forKey: "genre").trimmed
        self.website = try container.decode(URL.self, forKey: "website")
        self.url = try container.decode(URL.self, forKey: "url")
        self.description = try container.decode(String.self, forKey: "description").trimmed
        self.genreTags = try container.decodeIfPresent(String.self, forKey: "genreTags")?.trimmed.nilOnEmpty
        self.descriptionTeaser = try container.decodeIfPresent(String.self, forKey: "descriptionTeaser")?.trimmed.nilOnEmpty
        self.updated = try container.decode(Date.self, forKey: "updated")
        self.year = try container.decode(Int.self, forKey: "year")
        self.performances = try container.decode([FringePerformance].self, forKey: "performances")
        self.performanceSpace = try container.decode(FringePerformanceSpace.self, forKey: "performanceSpace")
        self.venue = try container.decode(FringeVenue.self, forKey: "venue")
        self.disabled = try container.decodeIfPresent(FringeDisabled.self, forKey: "disabled")
        self.images = try container.decode([String: FringeImage].self, forKey: "images")
        self.subTitle = try container.decodeIfPresent(String.self, forKey: "subTitle")?.trimmed.nilOnEmpty
        
        // Additional key validation: 

        if decoder.canValidateMissingKeys {
            container.validateAssumedNil(keys: [
                "artistType", "performersNumber", "nonEnglish", "fringeFirst", "relatedContent"])
        }
        
        // Some fields are deprecated but may be included in the response, these should not be used:
        // - `fringe_first`, `sub_venue`, `twitter`, `discounts`, `categories`
        // Some fields are only just not required for us:
        // - `update_times`
        
        // It looks like latitude and longitude will always match with the venues position
        let latitude = try container.decodeIfPresent(Double.self, forKey: "latitude")
        fringeAssert(latitude == self.venue.position.lat, "Base latitude value does not match")
        let longitude = try container.decodeIfPresent(Double.self, forKey: "longitude")
        fringeAssert(longitude == self.venue.position.lon, "Base longitude value does not match")
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: AnyCodingKey.self)
        try container.encodeIfPresent(title, forKey: "title")
        try container.encodeIfPresent(subTitle, forKey: "subTitle")
        try container.encodeIfPresent(ageCategory, forKey: "ageCategory")
        try container.encodeIfPresent(artist, forKey: "artist")
        try container.encodeIfPresent(country, forKey: "country")
        try container.encodeIfPresent(warnings, forKey: "warnings")
        try container.encodeIfPresent(status, forKey: "status")
        try container.encodeIfPresent(code, forKey: "code")
        try container.encodeIfPresent(festival, forKey: "festival")
        try container.encodeIfPresent(festivalId, forKey: "festivalId")
        try container.encodeIfPresent(genre, forKey: "genre")
        try container.encodeIfPresent(website, forKey: "website")
        try container.encodeIfPresent(url, forKey: "url")
        try container.encodeIfPresent(description, forKey: "description")
        try container.encodeIfPresent(genreTags, forKey: "genreTags")
        try container.encodeIfPresent(descriptionTeaser, forKey: "descriptionTeaser")
        try container.encodeIfPresent(fringeDateFormatter.string(from: updated), forKey: "updated")
        try container.encodeIfPresent(year, forKey: "year")
        try container.encodeIfPresent(performances, forKey: "performances")
        try container.encodeIfPresent(performanceSpace, forKey: "performanceSpace")
        try container.encodeIfPresent(venue, forKey: "venue")
        try container.encodeIfPresent(disabled, forKey: "disabled")
        try container.encodeIfPresent(images, forKey: "images")
    }
}
