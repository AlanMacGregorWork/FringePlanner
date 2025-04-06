//
//  FringeEventData.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 06/04/2025.
//

import SwiftUI

/// Displays the Event content
struct FringeEventData: ViewDataProtocol, Equatable {
    let event: DBFringeEvent
    @MakeEquatableReadOnly var onSelected: (() -> Void)
}

// MARK: - ContentView

extension FringeEventData {
    struct ContentView: View, ViewProtocol {
        let data: FringeEventData
        
        /// Displays basic info wrapped in a button
        var body: some View {
            Button(action: { data.onSelected() }, label: {
                VStack(alignment: .leading) {
                    Text(data.event.title)
                    if let descriptionTeaser = data.event.descriptionTeaser {
                        Text(descriptionTeaser)
                            .font(.footnote)
                            .lineLimit(1)
                    }
                }
            })
        }
    }
}
