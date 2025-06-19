//
//  PerformanceContentContainer.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 06/05/2025.
//

import SwiftUI
import SwiftData

/// Container for displaying a single performance for an event
struct PerformanceContentContainer {
    typealias Router = SimplifiedRouter<BasicNavigationLocation>
}

// MARK: - Content

extension PerformanceContentContainer {
    struct Content: ContentProtocol {
        typealias Structure = PerformanceContentContainer.Structure
        let router: Router
        let interaction: Interaction
        let dataSource: DataSource
    }
}

// MARK: - Structure

extension PerformanceContentContainer {
    struct Structure: StructureProtocol {
        let input: Content
        var performance: DBFringePerformance { input.dataSource.performance }
        
        var structure: some ViewDataProtocol {
            FringePerformanceData(performance: performance)
        }
    }
}

// MARK: - Data Source

extension PerformanceContentContainer {
    @Observable
    class DataSource: DataSourceProtocol {
        let performance: DBFringePerformance
        
        init(performance: DBFringePerformance) {
            self.performance = performance
        }
    }
}

// MARK: - Interaction
    
extension PerformanceContentContainer {
    struct Interaction: InteractionProtocol {
        let dataSource: DataSource
    }
}

// MARK: - Helper

#if DEBUG

extension PerformanceContentContainer {
    @MainActor
    static func createContent(performance: DBFringePerformance, constructionHelper: ConstructionHelper) -> Content {
        let router = Router(constructionHelper: constructionHelper)
        let dataSource = DataSource(performance: performance)
        let interaction = Interaction(dataSource: dataSource)
        return Content(router: router, interaction: interaction, dataSource: dataSource)
    }
}

// MARK: - Preview

@available(iOS 18, *)
#Preview(traits: .modifier(MockDataPreviewModifier(config: [0: .init(code: .override("demo"))]))) {
    @Previewable @Environment(\.modelContext) var modelContext

    PreviewEventFromDatabaseView(eventCode: "demo") { event in
        // Sort by the `referenceID` as the importing into the database does not keep the sort order
        let performance = event.performances.sorted(by: { $0.referenceID < $1.referenceID })[0]
        
        let constructionHelper = ConstructionHelper(modelContainer: modelContext.container)
        return PerformanceContentContainer.createContent(
            performance: performance,
            constructionHelper: constructionHelper
        ).buildView()
    }
}

#endif
