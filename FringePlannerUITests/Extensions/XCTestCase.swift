//
//  XCTestCase.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 20/10/2024.
//

import XCTest

extension XCTestCase {
    /// Constructs a basic task to be performed
    func runTask(for app: XCUIApplication, tap: TestUIElement, task: String, expect: Expectation) throws {
        try XCTContext.runActivity(named: "Tap '\(tap.referenceName)' to \(task) \(expect.title)") { _ in
            let tapElement = try tap.xcElement(from: app)
            tapElement.tap()
            try expect.trigger(app: app)
        }
    }
    
    // MARK: Redirects
    
    func runTask(for app: XCUIApplication, tap: TestUIElement, pushToSheet sheet: TestUIElement) throws {
        try runTask(for: app, tap: tap, task: "push to", expect: .elementExists(sheet))
    }
    func runTask(for app: XCUIApplication, tap: TestUIElement, popToSheet sheet: TestUIElement) throws {
        try runTask(for: app, tap: tap, task: "pop to", expect: .elementExists(sheet))
    }
}
