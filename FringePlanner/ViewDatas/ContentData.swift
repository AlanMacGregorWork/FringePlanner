//
//  ContentData.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 21/04/2025.
//

import SwiftUI

/// Wraps a `ContentProtocol` into a `ViewDataProtocol`
struct ContentData<Content: ContentProtocol>: ViewDataProtocol {
    let content: Content
    
    struct ContentView: View, ViewProtocol {
        let data: ContentData<Content>
        
        var body: some View {
            data.content.buildView()
        }
    }
}
