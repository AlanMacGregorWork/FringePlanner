//
//  ConditionalData.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 01/12/2024.
//

import SwiftUI

/// A view data type that represents a conditional view
struct ConditionalData<FirstContent: ViewDataProtocol, SecondContent: ViewDataProtocol>: ViewDataProtocol {
    let option: Options
    
    struct ContentView: View, ViewProtocol {
        let data: ConditionalData
        
        var body: some View {
            switch data.option {
            case .first(let content): content.createView()
            case .second(let content): content.createView()
            }
        }
    }
}

extension ConditionalData {
    enum Options {
        case first(FirstContent)
        case second(SecondContent)
    }
}
