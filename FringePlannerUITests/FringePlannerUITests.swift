//
//  FringePlannerUITests.swift
//  FringePlannerUITests
//
//  Created by Alan MacGregor on 16/09/2024.
//

import XCTest

final class FringePlannerUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testNavigationCorrectlyPushes() throws {
        // Verifies that the navigation correctly pushes views
        
        let app = XCUIApplication()
        app.launchArguments = ["ui-test"]
        app.launch()
        
        // == Setup Elements ==
        let navScreen1 = app.staticTexts.containing(.label(string: "Nav: Screen 1")).firstMatch
        let navScreen2 = app.staticTexts.containing(.label(string: "Nav: Screen 2")).firstMatch
        let openSheet1Button = app.buttons.containing(.label(string: "Open Screen 1")).firstMatch
        let openSheet2Button = app.buttons.containing(.label(string: "Open Screen 2")).firstMatch
        let backButton = app.buttons.containing(.label(string: "Back")).firstMatch
        
        
        // Pressing the "Open Screen 1" button should push Screen 1
        try openSheet1Button.throwOnNotExist()
        openSheet1Button.tap()
        try navScreen1.throwOnNotExist()
        
        // Pressing back should show the first screen again
        try backButton.throwOnNotExist()
        backButton.tap()
        
        // Pressing the "Open Screen 1" button should push Screen 1 again
        try openSheet1Button.throwOnNotExist()
        openSheet1Button.tap()
        try navScreen1.throwOnNotExist()
        
        // Pressing back should show the first screen again
        try backButton.throwOnNotExist()
        backButton.tap()
        
        // Pressing the "Open Screen 1" button should push Screen 2
        try openSheet2Button.throwOnNotExist()
        openSheet2Button.tap()
        try navScreen2.throwOnNotExist()
    }
}

extension NSPredicate {
    static func label(string: String) -> NSPredicate {
        NSPredicate(format: "label CONTAINS '\(string)'")
    }
}

extension XCUIElement {
    @discardableResult
    func throwOnNotExist() throws -> Self {
        enum ElementIssue: Error {
            case elementDoesNotExist
        }
        guard self.exists else { throw ElementIssue.elementDoesNotExist }
        return self
    }
}
