//
//  DBFringePerformance+DBFringeModelTestSupport.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 04/01/2025.
//

import Foundation
@testable import FringePlanner

extension DBFringePerformance: DBFringeModelTestSupport {
    static var apiModel: FringePerformance {
        FringePerformance(
            title: "Test Performance",
            type: .inPerson,
            isAtFixedTime: true,
            priceType: .paid,
            price: 15.0,
            concession: 12.0,
            priceString: "£15.00 (£12.00)",
            start: DateComponents(calendar: Calendar.current, year: 2024, month: 4, day: 5, hour: 17, minute: 45, second: 43).date!,
            end: DateComponents(calendar: Calendar.current, year: 2024, month: 4, day: 5, hour: 18, minute: 45, second: 43).date!,
            durationMinutes: 60,
            eventCode: "DiffValue"
        )
    }
    
    static var dbModel: DBFringePerformance {
        DBFringePerformance(
            type: .onlineLive,
            isAtFixedTime: false,
            priceType: .free,
            price: 0.0,
            priceString: "Free",
            start: DateComponents(calendar: Calendar.current, year: 2025, month: 4, day: 5, hour: 17, minute: 45, second: 43).date!,
            end: DateComponents(calendar: Calendar.current, year: 2025, month: 4, day: 5, hour: 18, minute: 45, second: 43).date!,
            durationMinutes: 30,
            eventCode: "otherVal"
        )
    }
}
