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
    
    struct ContentView: View, ViewProtocol {
        let data: ContainerData<repeat each Content>
        
        var body: some View {
            TupleView((repeat (each data.values).createView()))
        }
    }
}
