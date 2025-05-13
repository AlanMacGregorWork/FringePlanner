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
        
        var structure: some ViewDataProtocol {
            switch input.dataSource.content {
            case .success(let performance):
                performanceStructure(performance: performance)
            case .failure(let error):
                TextData("Database error\n\(error.description)")
            }
        }

        func performanceStructure(performance: DBFringePerformance) -> some ViewDataProtocol {
            // TODO: Implement proper error handling for the UI
            FringePerformanceData(performance: performance) 
        }
    }
}

// MARK: - Data Source

extension PerformanceContentContainer {
    @Observable
    class DataSource: DataSourceProtocol {
        let content: Result<DBFringePerformance, DBError>
        var errorContent: ErrorContent?
        
        init(content: Result<DBFringePerformance, DBError>) {
            self.content = content
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
    static func createContent(referenceID: String, constructionHelper: ConstructionHelper) -> Content {
        let context = ModelContext(constructionHelper.modelContainer)
        let dataSourceContent = PredicateHelper.performance(referenceID: referenceID).getWrappedContent(context: context)
        let router = Router(constructionHelper: constructionHelper)
        let dataSource = DataSource(content: dataSourceContent)
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
            referenceID: performance.referenceID,
            constructionHelper: constructionHelper
        ).buildView()
    }
}

#endif
