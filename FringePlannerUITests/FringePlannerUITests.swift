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
        
        // == Setup ==
        let app = XCUIApplication()
        app.launchArguments = ["ui-test"]
        app.launch()
        
        // == Setup Variables ==
        // Buttons
        let buttonNavigationTests = TestUIElement(elementType: .button, label: "Navigation Tests")
        let buttonOpenSheetBV1 = TestUIElement(elementType: .button, label: "Open Sheet B (V1)")
        let buttonOpenSheetBV2 = TestUIElement(elementType: .button, label: "Open Sheet B (V2)")
        let buttonOpenSheetC = TestUIElement(elementType: .button, label: "Open Sheet C")
        let buttonOpenSheetDV1 = TestUIElement(elementType: .button, label: "Open Sheet D (V1)")
        let buttonChangeParentSelectionToSheetBV2 = TestUIElement(elementType: .button, label: "Change Parent Selection To Sheet B (V2)")
        let buttonBack = TestUIElement(elementType: .button, label: "Back")
        // Sheets
        let sheetA = TestUIElement(elementType: .text, label: "Title: Sheet A")
        let sheetBV1 = TestUIElement(elementType: .text, label: "Title: Sheet B (V1)")
        let sheetBV2 = TestUIElement(elementType: .text, label: "Title: Sheet B (V2)")
        let sheetC = TestUIElement(elementType: .text, label: "Title: Sheet C")
        let sheetDV1 = TestUIElement(elementType: .text, label: "Title: Sheet D (V1)")
        
        // == Open Navigation Sheet ==
        try XCTContext.runActivity(named: "Open Navigation Sheet") { _ in
            try runTask(for: app, tap: buttonNavigationTests, task: "push", expect: sheetA)
        }
        
        // == Tests ==
        try XCTContext.runActivity(named: "Test: General Push & Pop") { _ in
            try runTask(for: app, tap: buttonOpenSheetBV1, task: "push", expect: sheetBV1)
            try runTask(for: app, tap: buttonBack, task: "pop", expect: sheetA)
        }
        try XCTContext.runActivity(named: "Test: Verify the `pushSheet` can have the same selected value (ensures that `pushSheet` became nil on pop)") { _ in
            try runTask(for: app, tap: buttonOpenSheetBV1, task: "push", expect: sheetBV1)
            try runTask(for: app, tap: buttonBack, task: "pop", expect: sheetA)
        }
        try XCTContext.runActivity(named: "Test: Verify requesting another sheet will not show the first sheet again") { _ in
            try runTask(for: app, tap: buttonOpenSheetBV2, task: "push", expect: sheetBV2)
            try runTask(for: app, tap: buttonBack, task: "pop", expect: sheetA)
        }
        try XCTContext.runActivity(named: "Test: Multiple child views can be pushed individually") { _ in
            try runTask(for: app, tap: buttonOpenSheetBV1, task: "push", expect: sheetBV1)
            try runTask(for: app, tap: buttonOpenSheetC, task: "push", expect: sheetC)
            try runTask(for: app, tap: buttonOpenSheetDV1, task: "push", expect: sheetDV1)
        }
        try XCTContext.runActivity(named: "Test: Multiple child views can be popped individually") { _ in
            try runTask(for: app, tap: buttonBack, task: "pop", expect: sheetC)
            try runTask(for: app, tap: buttonBack, task: "pop", expect: sheetBV1)
            try runTask(for: app, tap: buttonBack, task: "pop", expect: sheetA)
        }
        try XCTContext.runActivity(named: "Test: Altering a parent `pushedSheet` value will pop child view and push new view") { _ in
            try runTask(for: app, tap: buttonOpenSheetBV1, task: "push", expect: sheetBV1)
            try runTask(for: app, tap: buttonChangeParentSelectionToSheetBV2, task: "swaps to", expect: sheetBV2)
        }
    }
}
