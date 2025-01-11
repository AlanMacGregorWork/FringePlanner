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
    
    init(title: String? = nil,
         type: FringePerformanceType,
         isAtFixedTime: Bool,
         priceType: FringePriceType,
         price: Double,
         concession: Double? = nil,
         priceString: String,
         start: Date,
         end: Date,
         durationMinutes: Int) {
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
    }
}

extension DBFringePerformance {
    convenience init(apiModel performance: FringePerformance, context: ModelContext) throws(DBError) {
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
            durationMinutes: performance.durationMinutes
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
            EquatableCheck(lhsName: "durationMinutes", rhsName: "durationMinutes", lhsKeyPath: \.durationMinutes, rhsKeyPath: \.durationMinutes)
        ]
    }
}
