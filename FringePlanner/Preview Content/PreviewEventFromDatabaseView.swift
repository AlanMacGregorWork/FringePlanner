//
//  PreviewEventFromDatabaseView.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 12/05/2025.
//

import SwiftUI

/// Simplifies previewing database objects by automatically retrieving the event for the view
struct PreviewEventFromDatabaseView<ContentView: View>: View {
    @Environment(\.modelContext) private var modelContext
    let eventCode: String
    let contentView: ((DBFringeEvent) -> ContentView)
    
    var body: some View {
        let eventContent = PredicateHelper.event(eventCode: eventCode).getWrappedContent(context: modelContext)
        switch eventContent {
        case .failure(let dBError):
            Text("Database Error: \(dBError.localizedDescription)")
        case .success(let dBFringeEvent):
            contentView(dBFringeEvent)
        }
    }
}
