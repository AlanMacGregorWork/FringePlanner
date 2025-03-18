//
//  DBFringeEvent+DBFringeModelTestSupport.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 11/01/2025.
//

import Foundation
@testable import FringePlanner

extension DBFringeEvent: DBFringeModelTestSupport {
    static var apiModel: FringeEvent {
        FringeEvent(
            title: "Test Event",
            artist: "Test Artist",
            country: "Test Country",
            descriptionTeaser: "Test Teaser",
            code: "TEST123",
            ageCategory: "12+",
            description: "Test Description",
            festival: "Test Festival",
            festivalId: "FEST123",
            genre: "Test Genre",
            genreTags: "Tag1, Tag2",
            performances: [
                FringePerformance(
                    title: "Morning Show",
                    type: .inPerson,
                    isAtFixedTime: true,
                    priceType: .paid,
                    price: 10.0,
                    concession: 8.0,
                    priceString: "£10.00 (£8.00)",
                    start: Date(timeIntervalSince1970: 1704366000), // 10:00 AM
                    end: Date(timeIntervalSince1970: 1704369600),   // 11:00 AM
                    durationMinutes: 60,
                    eventCode: "TEST123"
                ),
                FringePerformance(
                    title: "Evening Show",
                    type: .onlineLive,
                    isAtFixedTime: true,
                    priceType: .payWhatYouCan,
                    price: 12.0,
                    concession: 9.0,
                    priceString: "Pay What You Can",
                    start: Date(timeIntervalSince1970: 1704394800), // 18:00 PM
                    end: Date(timeIntervalSince1970: 1704398400),   // 19:00 PM
                    durationMinutes: 60,
                    eventCode: "TEST123"
                )
            ],
            performanceSpace: FringePerformanceSpace(name: "Test Space", ageLimited: false, wheelchairAccess: true),
            status: .active,
            url: URL(string: "https://example.com/event")!,
            venue: DBFringeVenue.apiModel,
            website: URL(string: "https://example.com")!,
            disabled: FringeDisabled(
                otherServices: true,
                audio: false,
                captioningDates: ["2025-01-04", "2025-01-05"],
                signedDates: ["2025-01-06"],
                audioDates: ["2025-01-07"]
            ),
            images: [
                "main": FringeImage(
                    hash: "abc123",
                    orientation: .landscape,
                    type: .hero,
                    versions: [
                        "original": FringeImage.Version(
                            type: "original",
                            width: 1920,
                            height: 1080,
                            mime: "image/jpeg",
                            url: URL(string: "https://example.com/images/original.jpg")!
                        ),
                        "thumb": FringeImage.Version(
                            type: "thumb",
                            width: 300,
                            height: 169,
                            mime: "image/jpeg",
                            url: URL(string: "https://example.com/images/thumb.jpg")!
                        )
                    ]
                )
            ],
            warnings: nil,
            updated: Date(timeIntervalSince1970: 1704380400),
            year: 2025
        )
    }
    
    static var dbModel: DBFringeEvent {
        DBFringeEvent(
            title: "Original Event",
            artist: "Original Artist",
            country: "Original Country",
            descriptionTeaser: "Original Teaser",
            code: "ORIGINAL",
            ageCategory: "18+",
            eventDescription: "Original Description",
            festival: "Original Festival",
            festivalId: "ORIG123",
            genre: "Original Genre",
            genreTags: "OriginalTag1, OriginalTag2",
            performances: [],
            performanceSpace: FringePerformanceSpace(name: "Original Space", ageLimited: true, wheelchairAccess: false),
            status: .cancelled,
            url: URL(string: "https://original.com/event")!,
            venue: DBFringeVenue.dbModel,
            website: URL(string: "https://original.com")!,
            disabled: FringeDisabled(
                otherServices: false,
                audio: true,
                captioningDates: ["2024-01-04"],
                signedDates: nil,
                audioDates: nil
            ),
            images: [
                "main": FringeImage(
                    hash: "xyz789",
                    orientation: .portrait,
                    type: .thumb,
                    versions: [
                        "original": FringeImage.Version(
                            type: "original",
                            width: 1080,
                            height: 1920,
                            mime: "image/jpeg",
                            url: URL(string: "https://original.com/images/original.jpg")!
                        ),
                        "small": FringeImage.Version(
                            type: "small",
                            width: 169,
                            height: 300,
                            mime: "image/jpeg",
                            url: URL(string: "https://original.com/images/small.jpg")!
                        )
                    ]
                )
            ],
            warnings: "Original Warning",
            updatedValue: Date(timeIntervalSince1970: 1704294000),
            year: 2024
        )
    }

    static var omittedDBAndAPIFields: (dbFields: [String], apiFields: [String]) {
        (dbFields: ["venue", "performances"], apiFields: ["venue", "performances"])
    }
}
