//
//  TestUIElement.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 20/10/2024.
//

import XCTest

/// Defines information about the UI element for testing
struct TestUIElement: Hashable {
    
    // MARK: Property
    
    let referenceName: String
    let elementType: ElementType
    let label: String
    
    // MARK: Element Access
    
    /// Retrieves the test element defined for this object
    @discardableResult
    @MainActor
    func xcElement(from app: XCUIApplication) throws -> XCUIElement {
        let element: XCUIElement = switch elementType {
        case .text:
            app.staticTexts.containing(.label(string: self.label)).firstMatch
        case .button:
            app.buttons.containing(.label(string: self.label)).firstMatch
        }
        
        return try throwOnNotExist(for: element)
    }
    
    /// Throws an error if the identified UI element does not exist
    @MainActor
    private func throwOnNotExist(for element: XCUIElement) throws -> XCUIElement {
        enum ElementIssue: Error, CustomStringConvertible {
            case elementDoesNotExist(type: String, label: String)
            
            var description: String {
                switch self {
                case .elementDoesNotExist(let type, let label):
                    return "Cannot find \(type) with label: \"\(label)\""
                }
            }
        }
        
        guard element.exists else {
            throw ElementIssue.elementDoesNotExist(type: "\(elementType)", label: label)
        }
        
        return element
    }
}

// MARK: Enums

extension TestUIElement {
    enum ElementType {
        case text
        case button
    }
}
