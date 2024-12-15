//
//  FringeDataResultBuilder.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 06/10/2024.
//

/// Simplifies building `ViewDataProtocol`
@resultBuilder
struct FringeDataResultBuilder {
    static func buildBlock() {
    }
    
    static func buildBlock<each Content: ViewDataProtocol>(_ content: repeat each Content) -> (repeat each Content) {
        (repeat each content)
    }
    
    static func buildExpression<each Content: ViewDataProtocol>(_ content: repeat each Content) -> (repeat each Content) {
        (repeat each content)
    }
    
    static func buildIf<FirstContent: ViewDataProtocol>(_ content: FirstContent?) -> ConditionalData<FirstContent, EmptyData> {
        .init(option: content.map({ .first($0) }) ?? .second(EmptyData()))
    }
    
    static func buildEither<FirstContent: ViewDataProtocol, SecondContent: ViewDataProtocol>(first: FirstContent) -> ConditionalData<FirstContent, SecondContent> {
        .init(option: .first(first))
    }
    
    static func buildEither<FirstContent: ViewDataProtocol, SecondContent: ViewDataProtocol>(second: SecondContent) -> ConditionalData<FirstContent, SecondContent> {
        .init(option: .second(second))
    }
}

// MARK: Helpers

extension FringeDataResultBuilder {
    /// Redirects the `structure` as a building block
    @MainActor
    static func buildExpression<Structure: BaseStructureProtocol>(_ structure: Structure) -> Structure.StructureType {
        structure.structure
    }
}
