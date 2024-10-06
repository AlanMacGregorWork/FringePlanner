//
//  EventPerformanceCell.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 17/09/2024.
//

import SwiftUI

/// Displays the status of an events performance
struct EventPerformanceCell: View {
    
    // MARK: Properties
    
    let time: String
    let status: String
    let color: Color
    
    // MARK: Body
    
    var body: some View {
        HStack(spacing: 16) {
            statusIcon
            VStack(alignment: .leading) {
                Text(time)
                    .fringeStyle(.cellBody)
                Text(status)
                    .fringeStyle(.caption)
            }
        }
    }
    
    private var statusIcon: some View {
        Circle()
            .foregroundColor(color)
            .frame(width: 20)
    }
}

// MARK: - Preview

#Preview(traits: .sizeThatFitsLayout) {
    Group {
        EventPerformanceCell(time: "18/08/2024 12:00-13:00", status: "Booked", color: .green)
        EventPerformanceCell(time: "18/08/2024 12:00-13:00", status: "Conflicts with another show", color: .orange)
    }
}
