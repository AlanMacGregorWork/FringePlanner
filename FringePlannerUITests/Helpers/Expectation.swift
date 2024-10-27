//
//  Expectation.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 27/10/2024.
//

import XCTest

/// The type of check to perform on the UI
enum Expectation {
    case elementExists(TestUIElement)
    case labelsContain([TestUIElement: LabelContains])
    
    func trigger(app: XCUIApplication) throws {
        switch self {
        case .elementExists(let element):
            try element.xcElement(from: app)
        case .labelsContain(let dict):
            for (element, labelContains) in dict {
                let xcElement = try element.xcElement(from: app)
                if !xcElement.label.contains(labelContains.label) {
                    throw ElementIssue.labelDoesNotContainText(referenceName: element.referenceName, label: labelContains.label)
                }
            }
        }
    }
    
    var title: String {
        switch self {
        case .elementExists(let element):
            return "`\(element.referenceName)`"
        case .labelsContain(let dict):
            return "\n" + dict.map({ (element, labelContains) in
                switch labelContains.state {
                case .changes:
                    " - '\(element.referenceName)' changes to contain \"\(labelContains.label)\""
                case .noChanges:
                    " - '\(element.referenceName)' does not change"
                }
            })
            .sorted()
            .joined(separator: "\n")
        }
    }
}

// MARK: - LabelContains

extension Expectation {
    /// Provides additional information into how the label expectation should operate
    struct LabelContains: Hashable {
        enum State {
            case changes
            case noChanges
        }
        
        let label: String
        let state: State
        
        // MARK: Redirects
        
        static func changes(to label: String) -> Self {
            return .init(label: label, state: .changes)
        }
        static func noChanges(of label: String) -> Self {
            return .init(label: label, state: .noChanges)
        }
    }
    
    // MARK: Errors
    
    private enum ElementIssue: Error, CustomStringConvertible {
        case labelDoesNotContainText(referenceName: String, label: String)
        
        var description: String {
            switch self {
            case .labelDoesNotContainText(let referenceName, let label):
                return "'\(referenceName)' does not contain label: \"\(label)\""
            }
        }
    }
}
