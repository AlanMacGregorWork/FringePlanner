//
//  ViewDataIsEmpty.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 03/12/2024.
//

/// Protocol to check if a view data is empty
protocol ViewDataIsEmpty {
    /// The content is empty
    var isEmpty: Bool { get }
}

// MARK: Default Handling

extension ViewDataProtocol {
    /// By default the content should not be empty
    var isEmpty: Bool { false }
}

// MARK: Custom Handling

extension ConditionalData {
    /// ConditionalData will return the value of whatever option is chosen
    var isEmpty: Bool {
        switch self.option {
        case .first(let type): return type.isEmpty
        case .second(let type): return type.isEmpty
        }
    }
}

extension EmptyData {
    /// Empty view data is always empty
    var isEmpty: Bool { true }
}

extension ContainerData: ViewDataIsEmpty {
    /// Will return false if any content is not empty
    var isEmpty: Bool {
        for item in repeat (each values) {
            guard item.isEmpty else { return false }
        }
        return true
    }
}
