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
struct TextFieldData: ViewDataProtocol, Equatable {
    var text: Binding<String>
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        guard lhs.text.wrappedValue == rhs.text.wrappedValue else { return false }
        return true
    }

    struct ContentView: View, ViewProtocol {
        let data: TextFieldData

        var body: some View {
            VStack(alignment: .leading) {
                TextField("Text", text: data.text)
                Text("View Change: \(Date.now.timeIntervalSince1970)")
                    .font(.footnote)
            }
        }
    }
}

/// Displays a basic text view
struct DebugTextData: ViewDataProtocol, Equatable {
    let text: String
    
    struct ContentView: View, ViewProtocol {
        let data: DebugTextData
        
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
struct DebugButtonData: ViewDataProtocol, Equatable {
    let title: String
    @MakeEquatableReadOnly var interaction: (() -> Void)
    
    struct ContentView: View, ViewProtocol {
        let data: DebugButtonData
        
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
    @MakeEquatableReadOnly var interaction: (() -> Void)
    
    struct ContentView: View, ViewProtocol {
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
    }
}
#endif
