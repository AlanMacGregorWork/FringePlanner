//
//  FringeDataResultBuilder.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 06/10/2024.
//

/// Simplifies building `ViewDataProtocol`
@resultBuilder
struct FringeDataResultBuilder {
    static func buildBlock() -> () {
        ()
    }
    
    static func buildBlock<each Content: ViewDataProtocol>(_ content: repeat each Content) -> (repeat each Content) {
        (repeat each content)
    }
}
