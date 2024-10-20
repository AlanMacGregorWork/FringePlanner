//
//  XCTestCase.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 20/10/2024.
//

import XCTest

extension XCTestCase {
    /// Constructs a basic task to be performed
    func runTask(for app: XCUIApplication, tap: TestUIElement, task: String, expect: TestUIElement) throws {
        try XCTContext.runActivity(named: "Tap '\(tap.label)' to \(task) to '\(expect.label)'") { _ in
            let tapElement = try tap.xcElement(from: app)
            tapElement.tap()
            try expect.xcElement(from: app)
        }
    }
}

