//
//  ApplicationEnvironment.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 15/11/2024.
//

import Foundation

/// Defines the different environments the app can use
enum ApplicationEnvironment {
    case normal
    case testingUnit
    case testingUI
    
    /// Identifies the current environment being used by the app
    static var current: Self {
        if ProcessInfo.processInfo.arguments.contains("ui-test") {
            return .testingUI
        } else if NSClassFromString("XCTestCase") != nil {
            return .testingUnit
        } else {
            return .normal
        }
    }
}
