//
//  DBFringeVenue+DBFringeModelTestSupport.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 04/01/2025.
//

import Foundation
@testable import FringePlanner

extension DBFringeVenue: DBFringeModelTestSupport {
    static var apiModel: FringeVenue {
        FringeVenue(
            code: "TEST123",
            description: "Test Description",
            name: "Test Venue",
            address: "123 Test Street",
            position: .init(lat: 55.9533, lon: -3.1883),
            postCode: "EH1 1AB",
            webAddress: URL(string: "https://example.com")!,
            phone: "01234567890",
            email: "test@example.com",
            disabledDescription: "Accessible entrance"
        )
    }
    
    static var dbModel: DBFringeVenue {
        DBFringeVenue(
            code: "ORIGINAL",
            name: "Original Name",
            position: .init(lat: 0, lon: 0),
            postCode: "Original"
        )
    }
}
