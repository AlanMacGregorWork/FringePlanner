//
//  PlannerContentContainer.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 21/04/2025.
//

import SwiftUI
import SwiftData

/// Container for searching planing parts of the fringe trip
struct PlannerContentContainer {
    typealias Router = SimplifiedRouter<NavigationLocation>

    struct Content: ContentProtocol {
        typealias Structure = PlannerContentContainer.Structure
        let router: Router
        let interaction: Interaction
        let dataSource: DataSource
    }
    
    struct Interaction: InteractionProtocol { }
    
    class DataSource: DataSourceProtocol { }
    
    enum NavigationLocation: NavigationLocationProtocol {
        @ViewBuilder
        func toView(constructionHelper: ConstructionHelper) -> some View {
            EmptyView()
        }
    }
    
    struct Structure: StructureProtocol {
        let input: Content
        
        var structure: some ViewDataProtocol {
            TextData(text: "Temp")
        }
    }
}

// MARK: - Helper

extension PlannerContentContainer {
    static func createContent(constructionHelper: ConstructionHelper) -> Content {
        let router = Router(constructionHelper: constructionHelper)
        let interaction = Interaction()
        let dataSource = DataSource()
        return Content(router: router, interaction: interaction, dataSource: dataSource)
    }
}

// MARK: - Preview

#Preview {
    if let modelContainer = try? ModelContainer.create() {
        PlannerContentContainer.createContent(constructionHelper: .init(modelContainer: modelContainer)).buildView()
            .modelContainer(modelContainer)
    } else {
        Text("Failed to generated Container")
    }
}
