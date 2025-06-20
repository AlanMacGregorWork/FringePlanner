//
//  TextData.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 07/05/2025.
//

import SwiftUI

/// Displays a basic text label
struct TextData: ViewDataProtocol {
    let text: String
    
    struct ContentView: View, ViewProtocol {
        let data: TextData
        
        var body: some View {
            Text(data.text)
        }
    }
}

// MARK: - Helper Inits

extension TextData {
    init(_ text: String) {
        self = .init(text: text)
    }
}
