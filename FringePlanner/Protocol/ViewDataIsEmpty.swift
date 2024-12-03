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

extension ConditionalData: ViewDataIsEmpty {
    var isEmpty: Bool {
        switch self.option {
        case .first(let type):
            return isEmpty(type: type)
        case .second(let type):
            return isEmpty(type: type)
        }
    }

    private func isEmpty<T: ViewDataProtocol>(type: T) -> Bool {
        if let isEmptyType = type as? ViewDataIsEmpty {
            return isEmptyType.isEmpty
        }
        return false
    }
}

/// Empty view data is always empty
extension EmptyData: ViewDataIsEmpty {
    var isEmpty: Bool { true }
}
