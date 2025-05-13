//
//  DBFringeEvent.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 04/01/2025.
//

import Foundation
import SwiftData

@Model
final class DBFringeEvent: DBFringeModel {
    private(set) var title: String
    private(set) var subTitle: String?
    private(set) var artist: String?
    private(set) var country: String?
    private(set) var descriptionTeaser: String?
    private(set) var code: String
    private(set) var ageCategory: String?
    private(set) var eventDescription: String
    private(set) var festival: String
    private(set) var festivalId: String
    private(set) var genre: String
    private(set) var genreTags: String?
    @Relationship(inverse: \DBFringePerformance.event) private(set) var performances: [DBFringePerformance]
    // Note: Is optional due to SwiftDatas handling of Codable objects with entirely nil proeprties
    private(set) var performanceSpace: FringePerformanceSpace?
    private(set) var status: FringeStatus
    private(set) var url: URL
    @Relationship private(set) var venue: DBFringeVenue
    private(set) var website: URL
    private(set) var disabled: FringeDisabled?
    private(set) var images: [String: FringeImage]
    private(set) var warnings: String?
    private(set) var updatedValue: Date
    private(set) var year: Int
    
    // Custom properties
    
    var isFavourite: Bool
    
    init(title: String,
         subTitle: String? = nil,
         artist: String? = nil,
         country: String? = nil,
         descriptionTeaser: String? = nil,
         code: String,
         ageCategory: String? = nil,
         eventDescription: String,
         festival: String,
         festivalId: String,
         genre: String,
         genreTags: String? = nil,
         performances: [DBFringePerformance] = [],
         performanceSpace: FringePerformanceSpace?,
         status: FringeStatus,
         url: URL,
         venue: DBFringeVenue,
         website: URL,
         disabled: FringeDisabled? = nil,
         images: [String: FringeImage],
         warnings: String? = nil,
         updatedValue: Date,
         year: Int,
         isFavourite: Bool = false
    ) {
        self.title = title
        self.subTitle = subTitle
        self.artist = artist
        self.country = country
        self.descriptionTeaser = descriptionTeaser
        self.code = code
        self.ageCategory = ageCategory
        self.eventDescription = eventDescription
        self.festival = festival
        self.festivalId = festivalId
        self.genre = genre
        self.genreTags = genreTags
        self.performances = performances
        self.performanceSpace = performanceSpace
        self.status = status
        self.url = url
        self.venue = venue
        self.website = website
        self.disabled = disabled
        self.images = images
        self.warnings = warnings
        self.updatedValue = updatedValue
        self.year = year
        self.isFavourite = isFavourite
    }
}

extension DBFringeEvent {
    
    convenience init(apiModel event: FringeEvent, context: ModelContext) throws(DBError) {
        // The venue should have been created first as multiple events can share the same venue. If the venue
        // cannot be found, then something has gone wrong and the event cannot be created.
        guard let dbVenue = try DBHelper.getDBModel(from: event.venue, context: context) else {
            throw .assumptionFailed(.expectedCreatedVenue)
        }

        self.init(title: event.title,
                  subTitle: event.subTitle,
                  artist: event.artist,
                  country: event.country,
                  descriptionTeaser: event.descriptionTeaser,
                  code: event.code,
                  ageCategory: event.ageCategory,
                  eventDescription: event.description,
                  festival: event.festival,
                  festivalId: event.festivalId,
                  genre: event.genre,
                  genreTags: event.genreTags,
                  performanceSpace: event.performanceSpace,
                  status: event.status,
                  url: event.url,
                  venue: dbVenue,
                  website: event.website,
                  disabled: event.disabled,
                  images: event.images,
                  warnings: event.warnings,
                  updatedValue: event.updated,
                  year: event.year)
        update(from: event)
    }
    
    func update(from event: FringeEvent) {
        self.title = event.title
        self.subTitle = event.subTitle
        self.artist = event.artist
        self.country = event.country
        self.descriptionTeaser = event.descriptionTeaser
        self.code = event.code
        self.ageCategory = event.ageCategory
        self.eventDescription = event.description
        self.festival = event.festival
        self.festivalId = event.festivalId
        self.genre = event.genre
        self.genreTags = event.genreTags
        self.performanceSpace = event.performanceSpace
        self.status = event.status
        self.url = event.url
        self.website = event.website
        self.disabled = event.disabled
        self.images = event.images
        self.warnings = event.warnings
        self.updatedValue = event.updated
        self.year = event.year
    }
    
    static var equatableChecksForDBAndAPI: [EquatableCheck<DBFringeEvent, FringeEvent>] {
        [
            // Note: `venue` & `performances` not included as changes to that entity should not effect this one.
            EquatableCheck(lhsName: "title", rhsName: "title", lhsKeyPath: \.title, rhsKeyPath: \.title),
            EquatableCheck(lhsName: "subTitle", rhsName: "subTitle", lhsKeyPath: \.subTitle, rhsKeyPath: \.subTitle),
            EquatableCheck(lhsName: "artist", rhsName: "artist", lhsKeyPath: \.artist, rhsKeyPath: \.artist),
            EquatableCheck(lhsName: "country", rhsName: "country", lhsKeyPath: \.country, rhsKeyPath: \.country),
            EquatableCheck(lhsName: "descriptionTeaser", rhsName: "descriptionTeaser", lhsKeyPath: \.descriptionTeaser, rhsKeyPath: \.descriptionTeaser),
            EquatableCheck(lhsName: "code", rhsName: "code", lhsKeyPath: \.code, rhsKeyPath: \.code),
            EquatableCheck(lhsName: "ageCategory", rhsName: "ageCategory", lhsKeyPath: \.ageCategory, rhsKeyPath: \.ageCategory),
            EquatableCheck(lhsName: "eventDescription", rhsName: "description", lhsKeyPath: \.eventDescription, rhsKeyPath: \.description),
            EquatableCheck(lhsName: "festival", rhsName: "festival", lhsKeyPath: \.festival, rhsKeyPath: \.festival),
            EquatableCheck(lhsName: "festivalId", rhsName: "festivalId", lhsKeyPath: \.festivalId, rhsKeyPath: \.festivalId),
            EquatableCheck(lhsName: "genre", rhsName: "genre", lhsKeyPath: \.genre, rhsKeyPath: \.genre),
            EquatableCheck(lhsName: "genreTags", rhsName: "genreTags", lhsKeyPath: \.genreTags, rhsKeyPath: \.genreTags),
            EquatableCheck(lhsName: "performanceSpace", rhsName: "performanceSpace", lhsKeyPath: \.performanceSpace, rhsKeyPath: \.performanceSpace),
            EquatableCheck(lhsName: "status", rhsName: "status", lhsKeyPath: \.status, rhsKeyPath: \.status),
            EquatableCheck(lhsName: "url", rhsName: "url", lhsKeyPath: \.url, rhsKeyPath: \.url),
            EquatableCheck(lhsName: "website", rhsName: "website", lhsKeyPath: \.website, rhsKeyPath: \.website),
            EquatableCheck(lhsName: "disabled", rhsName: "disabled", lhsKeyPath: \.disabled, rhsKeyPath: \.disabled),
            EquatableCheck(lhsName: "images", rhsName: "images", lhsKeyPath: \.images, rhsKeyPath: \.images),
            EquatableCheck(lhsName: "warnings", rhsName: "warnings", lhsKeyPath: \.warnings, rhsKeyPath: \.warnings),
            EquatableCheck(lhsName: "updatedValue", rhsName: "updated", lhsKeyPath: \.updatedValue, rhsKeyPath: \.updated),
            EquatableCheck(lhsName: "year", rhsName: "year", lhsKeyPath: \.year, rhsKeyPath: \.year)
        ]
    }
    
    static func predicate(forMatchingAPIModel apiModel: FringeEvent) -> Predicate<DBFringeEvent> {
        let code = apiModel.code
        return #Predicate { $0.code == code }
    }
}
