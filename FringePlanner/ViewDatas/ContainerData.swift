//
//  ContainerData.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 25/12/2024.
//

import SwiftUI

/// Stores data used in parameter packs
struct ContainerData<each Content: ViewDataProtocol>: ViewDataProtocol {
    let values: (repeat each Content)
    
    init(values: (repeat each Content)) {
        self.values = values
    }
    
    init(@FringeDataResultBuilder values: () -> (repeat each Content)) {
        self.values = values()
    }
    
    struct ContentView: View, ViewProtocol {
        let data: ContainerData<repeat each Content>
        
        var body: some View {
            TupleView((repeat (each data.values).createView()))
        }
    }
}

// MARK: Equatable Support

extension ContainerData: Equatable {
    /// Note: Custom `Equatable` required due to parameter pack
    static func == (lhs: Self, rhs: Self) -> Bool {
        for (left, right) in repeat (each lhs.values, each rhs.values) {
            guard left == right else { return false }
        }
        return true
    }
}
