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
            start: Date(),
            end: Date().addingTimeInterval(3600),
            durationMinutes: 60
        )
    }
    
    static var dbModel: DBFringePerformance {
        DBFringePerformance(
            type: .onlineLive,
            isAtFixedTime: false,
            priceType: .free,
            price: 0.0,
            priceString: "Free",
            start: Date(),
            end: Date().addingTimeInterval(1800),
            durationMinutes: 30
        )
    }
}
