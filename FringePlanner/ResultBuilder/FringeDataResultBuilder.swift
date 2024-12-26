//
//  FringeDataResultBuilder.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 06/10/2024.
//

/// Simplifies building `ViewDataProtocol`
@resultBuilder
struct FringeDataResultBuilder {
    
    // MARK: Expressions
    
    /// Builds a general `ViewDataProtocol` (this is the default)
    static func buildExpression<Content: ViewDataProtocol>(_ content: Content) -> Content {
        content
    }
    
    // MARK: Blocks
    
    /// Build block for zero content
    static func buildBlock() -> EmptyData {
        EmptyData()
    }
    
    /// Build block for single content
    static func buildBlock<Content: ViewDataProtocol>(_ content: Content) -> Content {
        content
    }
    
    /// Build block for multiple content
    static func buildBlock<FirstContent: ViewDataProtocol, each OtherContent: ViewDataProtocol>(_ firstContent: FirstContent, _ otherContent: repeat each OtherContent) -> ContainerData<FirstContent, repeat each OtherContent> {
        .init(values: (firstContent, repeat each otherContent))
    }
    
    // MARK: Conditionals
    
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
