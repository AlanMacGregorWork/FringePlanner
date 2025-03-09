//
//  DBFringeVenue.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 28/12/2024.
//

import Foundation
import SwiftData

/// Contains details of the venue for the performance
@Model
final class DBFringeVenue: DBFringeModel {
    private(set) var code: String
    private(set) var venueDescription: String?
    private(set) var name: String
    private(set) var address: String?
    private(set) var position: FringeVenue.Position
    private(set) var postCode: String
    private(set) var webAddress: URL?
    private(set) var phone: String?
    private(set) var email: String?
    private(set) var disabledDescription: String?
    
    init(code: String,
         venueDescription: String? = nil,
         name: String,
         address: String? = nil,
         position: FringeVenue.Position,
         postCode: String,
         webAddress: URL? = nil,
         phone: String? = nil,
         email: String? = nil,
         disabledDescription: String? = nil) {
        self.code = code
        self.venueDescription = venueDescription
        self.name = name
        self.address = address
        self.position = position
        self.postCode = postCode
        self.webAddress = webAddress
        self.phone = phone
        self.email = email
        self.disabledDescription = disabledDescription
    }
}

extension DBFringeVenue {
    
    convenience init(apiModel venue: FringeVenue, context: ModelContext) throws(DBError) {
        // Create a new venue including the required fields
        self.init(code: venue.code, name: venue.name, position: venue.position, postCode: venue.postCode)
        // Update the venue with the optional fields
        update(from: venue)
    }
    
    func update(from venue: FringeVenue) {
        self.code = venue.code
        self.venueDescription = venue.description
        self.name = venue.name
        self.address = venue.address
        self.position = venue.position
        self.postCode = venue.postCode
        self.webAddress = venue.webAddress
        self.phone = venue.phone
        self.email = venue.email
        self.disabledDescription = venue.disabledDescription
    }

    static var equatableChecksForDBAndAPI: [EquatableCheck<DBFringeVenue, FringeVenue>] {
        [
            EquatableCheck(lhsName: "code", rhsName: "code", lhsKeyPath: \.code, rhsKeyPath: \.code),
            EquatableCheck(lhsName: "venueDescription", rhsName: "description", lhsKeyPath: \.venueDescription, rhsKeyPath: \.description),
            EquatableCheck(lhsName: "name", rhsName: "name", lhsKeyPath: \.name, rhsKeyPath: \.name),
            EquatableCheck(lhsName: "address", rhsName: "address", lhsKeyPath: \.address, rhsKeyPath: \.address),
            EquatableCheck(lhsName: "position", rhsName: "position", lhsKeyPath: \.position, rhsKeyPath: \.position),
            EquatableCheck(lhsName: "postCode", rhsName: "postCode", lhsKeyPath: \.postCode, rhsKeyPath: \.postCode),
            EquatableCheck(lhsName: "webAddress", rhsName: "webAddress", lhsKeyPath: \.webAddress, rhsKeyPath: \.webAddress),
            EquatableCheck(lhsName: "phone", rhsName: "phone", lhsKeyPath: \.phone, rhsKeyPath: \.phone),
            EquatableCheck(lhsName: "email", rhsName: "email", lhsKeyPath: \.email, rhsKeyPath: \.email),
            EquatableCheck(lhsName: "disabledDescription", rhsName: "disabledDescription", lhsKeyPath: \.disabledDescription, rhsKeyPath: \.disabledDescription)
        ]
    }   
    
    static func predicate(forMatchingAPIModel apiModel: FringeVenue) -> Predicate<DBFringeVenue> {
        let code = apiModel.code
        return #Predicate { $0.code == code }
    }
}
