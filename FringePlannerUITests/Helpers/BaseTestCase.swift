//
//  BaseTestCase.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 27/10/2024.
//

import XCTest

class BaseUITests: XCTestCase {
    
    // MARK: Properties
    
    private static var isAppLaunched = false
    private static let app = XCUIApplication()
    var app: XCUIApplication { Self.app }
    
    // MARK: Overrides

    override class func setUp() {
        super.setUp()
        
        // Ensure that the application is only launched once. This reduces the time of having to relaunch
        // the app to run another test
        if !isAppLaunched {
            app.launchArguments = ["ui-test"]
            app.launch()
            isAppLaunched = true
        }
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        try popToMainSheetTearDown()
    }
    
    // MARK: Helpers
    
    /// Continuously pops the navigation stack until the main sheet is present
    private func popToMainSheetTearDown() throws {
        enum TearDownError: Error, CustomStringConvertible {
            case couldNotPopToMainSheet
            var description: String {
                "Failed to pop to main sheet"
            }
        }
        
        // Keep pressing the back button until the main sheet appears. Limit this to 10 attempts to ensure we
        // we don't get stuck in a loop in the main sheet is not available.
        var attempts = 0
        let buttonBack = TestUIElement(referenceName: "Back button", elementType: .button, label: "Back")
        while !app.staticTexts.containing(.label(string: "Title: Main Sheet")).firstMatch.exists {
            guard attempts < 10 else { throw TearDownError.couldNotPopToMainSheet }
            try buttonBack.xcElement(from: app).tap()
            attempts += 1
        }
    }
}
