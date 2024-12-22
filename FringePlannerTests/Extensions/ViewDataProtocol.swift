//
//  ViewDataProtocol.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 22/12/2024.
//

@testable import FringePlanner

extension ViewDataProtocol {
    /// Creates a `ConditionalData` as if the current data was the first case without any other data
    func conditionalFirst() -> ConditionalData<Self, EmptyData> {
        // Note: If an `if` without `else` is used, the second content will always
        conditionalFirst(secondType: EmptyData.self)
    }
    
    /// Creates a `ConditionalData` as if the current data was the first case
    func conditionalFirst<SecondContent: ViewDataProtocol>(secondType: SecondContent.Type) -> ConditionalData<Self, SecondContent> {
        .init(option: .first(self))
    }
    
    /// Creates a `ConditionalData` as if the current data was the second content
    func conditionalSecond<FirstContent: ViewDataProtocol>(firstType: FirstContent.Type) -> ConditionalData<FirstContent, Self> {
        return .init(option: .second(self))
    }
}
