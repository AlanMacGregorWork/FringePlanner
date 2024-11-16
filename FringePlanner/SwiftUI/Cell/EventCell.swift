//
//  EventCell.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 17/09/2024.
//

import SwiftUI

/// Displays brief overview information about an event
struct EventCell: View {
    
    // MARK: Properties
    
    private let title: String
    private let caption: String
    private let subCaption: String?
    
    // MARK: Init
    
    init(title: String, caption: String, subCaption: String? = nil) {
        self.title = title
        self.caption = caption
        self.subCaption = subCaption
    }
    
    // MARK: Body
    
    var body: some View {
        HStack {
            image
            details
        }
    }
    
    private var image: some View {
        Rectangle()
            .aspectRatio(1, contentMode: .fit)
            .frame(width: 60)
            .foregroundColor(Color.green)
    }
    
    private var details: some View {
        VStack(alignment: .leading) {
            Text(title)
                .fringeStyle(.cellBody)
            Text(caption)
                .fringeStyle(.caption)
                .lineLimit(1)
            if let subCaption {
                Text(subCaption)
                    .fringeStyle(.subCaption)
                    .lineLimit(1)
            }
        }
    }
}

// MARK: - Previews

@available(iOS 18.0, *)
#Preview("With time, event, & venue", traits: .sizeThatFitsLayout) {
    EventCell(
        title: "18:00 - 19:00",
        caption: "Performer Name: Event Name",
        subCaption: "Venue Number: Venue Name")
}

@available(iOS 18.0, *)
#Preview("With event & venue", traits: .sizeThatFitsLayout) {
    EventCell(
        title: "Performer Name: Event Name",
        caption: "Venue Number: Venue Name")
}
