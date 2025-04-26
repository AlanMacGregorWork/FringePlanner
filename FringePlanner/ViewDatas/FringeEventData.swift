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
                HStack {
                    VStack(alignment: .leading) {
                        Text(data.event.title)
                        if let descriptionTeaser = data.event.descriptionTeaser {
                            Text(descriptionTeaser)
                                .font(.footnote)
                                .lineLimit(1)
                        }
                    }
                    // Display the favourite UI
                    if data.event.isFavourite {
                        Spacer()
                        Image.favourite(isFavourite: data.event.isFavourite)
                    }
                }
            })
        }
    }
}

// MARK: - Preview

@available(iOS 18, *)
#Preview(traits: .modifier(MockDataPreviewModifier(config: [0: .init(code: .override("demo"))]))) {
    @Previewable @Environment(\.modelContext) var modelContext
    
    let eventContent = EventContent(eventCode: "demo", modelContainer: modelContext.container)
    switch eventContent {
    case .noEventFound:
        Text("No Event Found")
    case .databaseError(let dBError):
        Text("Database Error: \(dBError.localizedDescription)")
    case .eventFound(let dBFringeEvent):
        FringeEventData.ContentView(data: .init(event: dBFringeEvent, onSelected: {}))
            .border(Color.gray)
    }
}
