//
//  BaseTestCase.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 27/10/2024.
//

import XCTest

class BaseUITests: XCTestCase {
    
    // MARK: Properties
    
    private static let session = UISession()
    var app: XCUIApplication { Self.session.app }
    
    // MARK: Overrides
    
    override func setUp() async throws {
        try await super.setUp()
        // No point in continuing after a failure
        self.continueAfterFailure = false
        await Self.session.launchAppIfNeeded()
    }
    
    override func tearDown() async throws {
        try await super.tearDown()
        try await popToMainSheetTearDown()
    }
    
    // MARK: Helpers
    
    /// Continuously pops the navigation stack until the main sheet is present
    @MainActor
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

// MARK: - Actors

/// A singleton that manages the state of the UI session
private actor UISession {
    private var isAppLaunched = false
    @MainActor let app = XCUIApplication()
    
    func launchAppIfNeeded() async {
        // Ensure that the application is only launched once. This reduces the time of having to relaunch
        // the app to run another test
        if !isAppLaunched {
            await MainActor.run {
                app.launchArguments = ["ui-test"]
                app.launch()
            }
            isAppLaunched = true
        }
    }
}
