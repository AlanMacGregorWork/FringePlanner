//
//  ForEachData.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 15/10/2024.
//

import SwiftUI

/// Allows grouping of array data
struct ForEachData<Input: Hashable, Content: ViewDataProtocol>: ViewDataProtocol {
    let data: [Input]
    @MakeEquatableReadOnly var content: ((Input) -> (Content))

    struct ContentView: View, ViewProtocol {
        let data: ForEachData<Input, Content>
        
        var body: some View {
            ForEach(data.data, id: \.hashValue, content: { data.content($0).createView() })
        }
    }
}
