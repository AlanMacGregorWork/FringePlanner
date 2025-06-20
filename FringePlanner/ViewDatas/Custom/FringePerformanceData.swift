//
//  FringePerformanceData.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 07/05/2025.
//

import SwiftUI

/// Displays basic information about the performance
struct FringePerformanceData: ViewDataProtocol {
    let performance: DBFringePerformance

    struct ContentView: View, ViewProtocol {
        let data: FringePerformanceData
        
        var body: some View {
            let timeRange = Date.formattedTimeRange(start: data.performance.start, end: data.performance.end)
            EventPerformanceCell(time: timeRange, status: "Not In Calendar", color: .gray)
        }
    }
}

// MARK: - Previews

@available(iOS 18, *)
#Preview(traits: .modifier(MockDataPreviewModifier(config: [0: .init(code: .override("demo"))]))) {
    PreviewEventFromDatabaseView(eventCode: "demo") { event in
        // Sort by the `referenceID` as the importing into the database does not keep the sort order
        let performance = event.performances.sorted(by: { $0.referenceID < $1.referenceID })[0]
        return FringePerformanceData(performance: performance).createView()
    }
}
