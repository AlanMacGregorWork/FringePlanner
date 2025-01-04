//
//  DBFringeModelTestSupport.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 04/01/2025.
//

@testable import FringePlanner

/// Provides default values that can be used for testing DBFringeModels
protocol DBFringeModelTestSupport where Self: DBFringeModel {
    static var keyPaths: [KeyPathCheck<Self, APIModelType>] { get throws }
    static var apiModel: APIModelType { get }
    static var dbModel: Self { get }
}
