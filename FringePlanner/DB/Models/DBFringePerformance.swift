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
    /// SwiftData does not currently support using predicates so instead the `statusString` will allow saving the
    /// `rawValue` into the database. It uses `originalName` as `status` so if enum predicate support is eventually
    /// added this can be replaced with the `Status`.
    @Attribute(originalName: "status") private var statusString: String
    private(set) var status: Status {
        get { Status(rawValue: statusString) ?? .defaultValue }
        set { statusString = newValue.rawValue }
    }
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
         event: DBFringeEvent,
         status: Status = .defaultValue
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
        self.statusString = status.rawValue
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
        // If the performance exists from the API it must mean that the performance is still `active`
        self.status = Status.active
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
    
    /// Denotes whether the performance is still active for the event, or whether it's been cancelled.
    ///  - Note: The API currently does not offer any information as to whether the performance is still going ahead,
    /// but if the performance is cancelled it will not be included in the events performances array. We can can
    /// therefore identify if a performance has been cancelled if it previously existed in the database and with it now
    /// not included in the array from the API.
    enum Status: String, Codable {
        case active
        case cancelled
        
        static let defaultValue = Status.active
    }
}
