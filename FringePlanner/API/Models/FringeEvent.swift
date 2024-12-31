//
//  FringeEvent.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 15/11/2024.
//

import Foundation

struct FringeEvent: Equatable, Hashable {
    var title: String
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

extension FringeEvent: Identifiable {
    var id: String { code }
}

extension FringeEvent: Decodable {
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: AnyCodingKey.self)
        self.title = try container.decode(String.self, forKey: "title").trimmed
        self.ageCategory = try container.decodeIfPresent(String.self, forKey: "ageCategory")?.trimmed.nilOnEmpty
        self.artist = try container.decodeIfPresent(String.self, forKey: "artist")?.trimmed.nilOnEmpty
        self.country = try container.decodeIfPresent(String.self, forKey: "country")?.trimmed.nilOnEmpty
        self.warnings = try container.decodeIfPresent(String.self, forKey: "warnings")?.trimmed.nilOnEmpty
        self.status = try container.decode(FringeStatus.self, forKey: "status")
        self.code = try container.decode(String.self, forKey: "code").trimmed
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
        
        // Additional key validation: 

        container.validateAssumedNil(keys: [
            "subTitle", "artistType", "performersNumber", "nonEnglish", "fringeFirst", "relatedContent"])
        
        // Some fields are deprecated but may be included in the response, these should not be used:
        // - `fringe_first`, `sub_venue`, `twitter`, `discounts`, `categories`
        // Some fields are only just not required for us:
        // - `update_times`
        
        // It looks like latitude and longitude will always match with the venues position
        let latitude = try container.decode(Double.self, forKey: "latitude")
        fringeAssert(latitude == self.venue.position.lat, "Base latitude value does not match")
        let longitude = try container.decode(Double.self, forKey: "longitude")
        fringeAssert(longitude == self.venue.position.lon, "Base longitude value does not match")
    }
}