//
//  EmptyData.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 01/12/2024.
//

import SwiftUI

/// A view data type that represents an empty view
struct EmptyData: ViewDataProtocol {
    struct ContentView: View, ViewProtocol {
        let data: EmptyData

        var body: some View {
            EmptyView()
        }
    }
}
