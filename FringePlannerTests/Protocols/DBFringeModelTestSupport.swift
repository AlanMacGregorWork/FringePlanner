//
//  DBFringeModelTestSupport.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 04/01/2025.
//

@testable import FringePlanner

/// Provides default values that can be used for testing DBFringeModels
protocol DBFringeModelTestSupport where Self: DBFringeModel {
    static var apiModel: APIFringeModelType { get }
    static var dbModel: Self { get }
    /// Some fields are explicitly omitted from the equatable checks, this may be due to the field
    /// being a for a separate entity where it's content being altered should not affect this entity.
    static var omittedDBAndAPIFields: (dbFields: [String], apiFields: [String]) { get }
}

extension DBFringeModelTestSupport {
    static var omittedDBAndAPIFields: (dbFields: [String], apiFields: [String]) {
        // By default all fields should be equatable.
        (dbFields: [], apiFields: [])
    }
}
