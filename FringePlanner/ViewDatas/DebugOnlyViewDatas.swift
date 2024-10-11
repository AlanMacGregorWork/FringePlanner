//
//  DebugOnlyViewDatas.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 10/10/2024.
//

import SwiftUI

// Note: Contains view datas only available in Debug/Testing

#if DEBUG

/// Displays a basic text view
struct TextData: ViewDataProtocol, Equatable {
    let text: String
    
    struct ContentView: View, Equatable, ViewProtocol {
        let data: TextData
        
        var body: some View {
            VStack(alignment: .leading) {
                Text("Text: \(data.text)")
                Text("View Change: \(Date.now.timeIntervalSince1970)")
                    .font(.footnote)
            }
        }
    }
}

/// Displays a basic button
struct ButtonData: ViewDataProtocol, Equatable {
    let title: String
    @MakeEquatableReadOnly var interaction: (() -> ())
    
    struct ContentView: View, Equatable, ViewProtocol {
        let data: ButtonData
        
        var body: some View {
            Button(action: data.interaction) {
                VStack(alignment: .leading) {
                    Text("Title: \(data.title)")
                    Text("View Change: \(Date.now.timeIntervalSince1970)")
                        .font(.footnote)
                }
            }
        }
    }
}

/// Displays a Times
///  - Note: Currently does not disable the time on tap
struct CustomTimeData: ViewDataProtocol, Equatable {
    let timerOn: Bool
    @MakeEquatableReadOnly var interaction: (() -> ())
    
    struct ContentView: View, Equatable, ViewProtocol {
        let data: CustomTimeData
        @State private var value = 0
        @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        
        var body: some View {
            Button(action: data.interaction) {
                VStack(alignment: .leading) {
                    Text("View Change: \(Date.now.timeIntervalSince1970)")
                        .font(.footnote)
                    Text(data.timerOn ? "Turn Timer Off" : "Turn Timer On")
                    Text("Seconds: \(value)")
                }
            }
            .foregroundStyle(.black)
            .onReceive(timer, perform: { _ in value += 1 })
        }
        
        static func == (lhs: CustomTimeData.ContentView, rhs: CustomTimeData.ContentView) -> Bool {
            guard lhs.data == rhs.data else { return false }
            guard lhs.value == rhs.value else { return false }
            return true
        }
    }
}
#endif
