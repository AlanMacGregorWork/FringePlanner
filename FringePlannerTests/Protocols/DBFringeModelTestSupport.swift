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
}
