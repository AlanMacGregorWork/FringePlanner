//
//  FringePlannerUITests.swift
//  FringePlannerUITests
//
//  Created by Alan MacGregor on 16/09/2024.
//

import XCTest

final class FringePlannerUITests: BaseUITests {
    @MainActor
    func testChangesToDataModelRender() throws {
        // Verifies that the changes to the data model correctly render the content
        
        // == Setup Variables ==
        // Elements
        let buttonRenderingTests = TestUIElement(referenceName: "Reference Tests button", elementType: .button, label: "Rendering Tests")
        let buttonAddDirectly = TestUIElement(referenceName: "Add directly button", elementType: .button, label: "Add 1 to data model directly")
        let buttonAddFromInteraction = TestUIElement(referenceName: "Add from interaction button", elementType: .button, label: "Add 1 to data model from interaction")
        let textValueStored = TestUIElement(referenceName: "Testing Label", elementType: .text, label: "Value stored in data model")
        let sheetRendering = TestUIElement(referenceName: "Rendering Tests sheet", elementType: .text, label: "Title: Rendering Tests")
        // State
        var originalButtonDirectlyViewChange = ""
        var originalButtonInteractionViewChange = ""
        
        // == Open Rendering Sheet ==
        try XCTContext.runActivity(named: "Open Rendering Sheet") { _ in
            try runTask(for: app, tap: buttonRenderingTests, pushToSheet: sheetRendering)
            
            try XCTContext.runActivity(named: "Getting original state for further tests") { _ in
                originalButtonDirectlyViewChange = try buttonAddDirectly.xcElement(from: app).label.components(separatedBy: "View Change: ")[1]
                originalButtonInteractionViewChange = try buttonAddFromInteraction.xcElement(from: app).label.components(separatedBy: "View Change: ")[1]
                XCTAssertEqual(try textValueStored.xcElement(from: app).label, "Text: Value stored in data model: 0")
            }
        }
        guard !originalButtonDirectlyViewChange.isEmpty && !originalButtonInteractionViewChange.isEmpty else {
            return XCTFail("Failed to get original values")
        }
        
        // == Tests ==
        try XCTContext.runActivity(named: "Test: Modifying Data Model directly") { _ in
            try XCTContext.runActivity(named: "Test: Updates UI using data model") { _ in
                try runTask(for: app, tap: buttonAddDirectly, task: "update fields:", expect: .labelsContain([
                    textValueStored: .changes(to: "Value stored in data model: 1"),
                    buttonAddDirectly: .noChanges(of: originalButtonDirectlyViewChange),
                    buttonAddFromInteraction: .noChanges(of: originalButtonInteractionViewChange)]))
                
                try runTask(for: app, tap: buttonAddDirectly, task: "update fields:", expect: .labelsContain([
                    textValueStored: .changes(to: "Value stored in data model: 2"),
                    buttonAddDirectly: .noChanges(of: originalButtonDirectlyViewChange),
                    buttonAddFromInteraction: .noChanges(of: originalButtonInteractionViewChange)]))
            }
        }
        try XCTContext.runActivity(named: "Test: Modifying Data Model via the interaction model") { _ in
            try XCTContext.runActivity(named: "Test: Updates UI using data model") { _ in
                try runTask(for: app, tap: buttonAddDirectly, task: "update fields:", expect: .labelsContain([
                    textValueStored: .changes(to: "Value stored in data model: 3"),
                    buttonAddDirectly: .noChanges(of: originalButtonDirectlyViewChange),
                    buttonAddFromInteraction: .noChanges(of: originalButtonInteractionViewChange)]))
                
                try runTask(for: app, tap: buttonAddDirectly, task: "update fields:", expect: .labelsContain([
                    textValueStored: .changes(to: "Value stored in data model: 4"),
                    buttonAddDirectly: .noChanges(of: originalButtonDirectlyViewChange),
                    buttonAddFromInteraction: .noChanges(of: originalButtonInteractionViewChange)]))
            }
        }
    }

    @MainActor
    func testNavigationCorrectlyPushes() throws {
        // Verifies that the navigation correctly pushes views
        
        // == Setup Variables ==
        // Buttons
        let buttonNavigationTests = TestUIElement(referenceName: "Navigation Tests", elementType: .button, label: "Navigation Tests")
        let buttonOpenSheetBV1 = TestUIElement(referenceName: "Sheet B (V1) button", elementType: .button, label: "Open Sheet B (V1)")
        let buttonOpenSheetBV2 = TestUIElement(referenceName: "Sheet B (V2) button", elementType: .button, label: "Open Sheet B (V2)")
        let buttonOpenSheetC = TestUIElement(referenceName: "Sheet C button",elementType: .button, label: "Open Sheet C")
        let buttonOpenSheetDV1 = TestUIElement(referenceName: "Sheet D (V1) button", elementType: .button, label: "Open Sheet D (V1)")
        let buttonChangeParentSelectionToSheetBV2 = TestUIElement(referenceName: "Switch Sheet button", elementType: .button, label: "Change Parent Selection To Sheet B (V2)")
        let buttonBack = TestUIElement(referenceName: "Back button", elementType: .button, label: "Back")
        // Sheets
        let sheetA = TestUIElement(referenceName: "Sheet A", elementType: .text, label: "Title: Sheet A")
        let sheetBV1 = TestUIElement(referenceName: "Sheet B (V1)", elementType: .text, label: "Title: Sheet B (V1)")
        let sheetBV2 = TestUIElement(referenceName: "Sheet B (V2)", elementType: .text, label: "Title: Sheet B (V2)")
        let sheetC = TestUIElement(referenceName: "Sheet C", elementType: .text, label: "Title: Sheet C")
        let sheetDV1 = TestUIElement(referenceName: "Sheet D (V1)", elementType: .text, label: "Title: Sheet D (V1)")
        
        // == Open Navigation Sheet ==
        try XCTContext.runActivity(named: "Open Navigation Sheet") { _ in
            try runTask(for: app, tap: buttonNavigationTests, pushToSheet: sheetA)
        }
        
        // == Tests ==
        try XCTContext.runActivity(named: "Test: General Push & Pop") { _ in
            try runTask(for: app, tap: buttonOpenSheetBV1, pushToSheet: sheetBV1)
            try runTask(for: app, tap: buttonBack, popToSheet: sheetA)
        }
        try XCTContext.runActivity(named: "Test: Verify the `pushSheet` can have the same selected value (ensures that `pushSheet` became nil on pop)") { _ in
            try runTask(for: app, tap: buttonOpenSheetBV1, pushToSheet: sheetBV1)
            try runTask(for: app, tap: buttonBack, popToSheet: sheetA)
        }
        try XCTContext.runActivity(named: "Test: Verify requesting another sheet will not show the first sheet again") { _ in
            try runTask(for: app, tap: buttonOpenSheetBV2, pushToSheet: sheetBV2)
            try runTask(for: app, tap: buttonBack, popToSheet: sheetA)
        }
        try XCTContext.runActivity(named: "Test: Multiple child views can be pushed individually") { _ in
            try runTask(for: app, tap: buttonOpenSheetBV1, pushToSheet: sheetBV1)
            try runTask(for: app, tap: buttonOpenSheetC, pushToSheet: sheetC)
            try runTask(for: app, tap: buttonOpenSheetDV1, pushToSheet: sheetDV1)
        }
        try XCTContext.runActivity(named: "Test: Multiple child views can be popped individually") { _ in
            try runTask(for: app, tap: buttonBack, popToSheet: sheetC)
            try runTask(for: app, tap: buttonBack, popToSheet: sheetBV1)
            try runTask(for: app, tap: buttonBack, popToSheet: sheetA)
        }
        try XCTContext.runActivity(named: "Test: Altering a parent `pushedSheet` value will pop child view and push new view") { _ in
            try runTask(for: app, tap: buttonOpenSheetBV1, pushToSheet: sheetBV1)
            try runTask(for: app, tap: buttonChangeParentSelectionToSheetBV2, task: "swaps to", expect: .elementExists(sheetBV2))
        }
    }
}
