//
//  DBFringePerformance.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 30/12/2024.
//

import SwiftData
import Foundation

@Model
final class DBFringePerformance: DBFringeModel {
    private(set) var title: String?
    private(set) var type: FringePerformanceType
    private(set) var isAtFixedTime: Bool
    private(set) var priceType: FringePriceType
    private(set) var price: Double
    private(set) var concession: Double?
    private(set) var priceString: String
    private(set) var start: Date
    private(set) var end: Date
    private(set) var durationMinutes: Int
    private(set) var eventCode: String
    @Relationship private(set) var event: DBFringeEvent
    
    init(title: String? = nil,
         type: FringePerformanceType,
         isAtFixedTime: Bool,
         priceType: FringePriceType,
         price: Double,
         concession: Double? = nil,
         priceString: String,
         start: Date,
         end: Date,
         durationMinutes: Int,
         eventCode: String,
         event: DBFringeEvent
    ) {
        self.title = title
        self.type = type
        self.isAtFixedTime = isAtFixedTime
        self.priceType = priceType
        self.price = price
        self.concession = concession
        self.priceString = priceString
        self.start = start
        self.end = end
        self.durationMinutes = durationMinutes
        self.eventCode = eventCode
        self.event = event
    }
}

extension DBFringePerformance {
    convenience init(apiModel performance: FringePerformance, context: ModelContext) throws(DBError) {
        // The event should have been created first as multiple performances can share the same event. If the event
        // cannot be found, then something has gone wrong and the performance cannot be created.
        let predicate: Predicate<DBFringeEvent> = #Predicate { $0.code == performance.eventCode }
        guard let dbEvent = try ImportAPIActor.getDBModel(from: predicate, context: context) else {
            throw .assumptionFailed(.expectedCreatedVenue)
        }
        
        self.init(
            title: performance.title,
            type: performance.type,
            isAtFixedTime: performance.isAtFixedTime,
            priceType: performance.priceType,
            price: performance.price,
            concession: performance.concession,
            priceString: performance.priceString,
            start: performance.start,
            end: performance.end,
            durationMinutes: performance.durationMinutes,
            eventCode: performance.eventCode,
            event: dbEvent
        )
    }
    
    func update(from performance: FringePerformance) {
        self.title = performance.title
        self.type = performance.type
        self.isAtFixedTime = performance.isAtFixedTime
        self.priceType = performance.priceType
        self.price = performance.price
        self.concession = performance.concession
        self.priceString = performance.priceString
        self.start = performance.start
        self.end = performance.end
        self.durationMinutes = performance.durationMinutes
        self.eventCode = performance.eventCode
    }
    
    static var equatableChecksForDBAndAPI: [EquatableCheck<DBFringePerformance, FringePerformance>] {
        [
            EquatableCheck(lhsName: "title", rhsName: "title", lhsKeyPath: \.title, rhsKeyPath: \.title),
            EquatableCheck(lhsName: "type", rhsName: "type", lhsKeyPath: \.type, rhsKeyPath: \.type),
            EquatableCheck(lhsName: "isAtFixedTime", rhsName: "isAtFixedTime", lhsKeyPath: \.isAtFixedTime, rhsKeyPath: \.isAtFixedTime),
            EquatableCheck(lhsName: "priceType", rhsName: "priceType", lhsKeyPath: \.priceType, rhsKeyPath: \.priceType),
            EquatableCheck(lhsName: "price", rhsName: "price", lhsKeyPath: \.price, rhsKeyPath: \.price),
            EquatableCheck(lhsName: "concession", rhsName: "concession", lhsKeyPath: \.concession, rhsKeyPath: \.concession),
            EquatableCheck(lhsName: "priceString", rhsName: "priceString", lhsKeyPath: \.priceString, rhsKeyPath: \.priceString),
            EquatableCheck(lhsName: "start", rhsName: "start", lhsKeyPath: \.start, rhsKeyPath: \.start),
            EquatableCheck(lhsName: "end", rhsName: "end", lhsKeyPath: \.end, rhsKeyPath: \.end),
            EquatableCheck(lhsName: "durationMinutes", rhsName: "durationMinutes", lhsKeyPath: \.durationMinutes, rhsKeyPath: \.durationMinutes),
            EquatableCheck(lhsName: "eventCode", rhsName: "eventCode", lhsKeyPath: \.eventCode, rhsKeyPath: \.eventCode)
        ]
    }
    
    static func predicate(forMatchingAPIModel apiModel: FringePerformance) -> Predicate<DBFringePerformance> {
        // `FringePerformance` does not include a traditional `id`, instead the start time should be used as the
        // performance id as each performance is allocated a set time and should not move our of it. This information
        // was gathered from an enquiry to the API owner
        let start = apiModel.start
        let eventCode = apiModel.eventCode
        return #Predicate { $0.start == start && $0.eventCode == eventCode }
    }
}
