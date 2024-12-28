//
//  EventDetailsContentContainer+Structure+DescriptionStructure.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 27/12/2024.
//

import SwiftUI

extension EventDetailsContentContainer.Structure {
    /// Structure for the description portion of the event details
    struct DescriptionStructure: BaseStructureProtocol {
        let descriptionTeaser: AttributedString?
        let description: AttributedString
        let warnings: AttributedString?
        
        var structure: some ViewDataProtocol {
            GroupData(type: .section) {
                Self.getTeaserRow(from: descriptionTeaser, description: description)
                Self.getDescriptionRow(from: description)
                Self.getWarningsRow(from: warnings)
            }
        }
        
        @FringeDataResultBuilder
        static func getTeaserRow(from teaser: AttributedString?, description: AttributedString) -> some ViewDataProtocol {
            // The teaser should not be shown if it appears in the description, otherwise it will look duplicated.
            if let teaser, !description.hasTrimmedPrefix(teaser) {
                SectionRowData(text: teaser)
            }
        }
        
        @FringeDataResultBuilder
        static func getDescriptionRow(from description: AttributedString) -> some ViewDataProtocol {
            SectionRowData(text: description)
        }
        
        @FringeDataResultBuilder
        static func getWarningsRow(from warnings: AttributedString?) -> some ViewDataProtocol {
            if let warnings {
                SectionRowData(title: "Warnings", text: warnings)
            }
        }
    }
}

extension EventDetailsContentContainer.Structure.DescriptionStructure {
    init(event: FBEvent) {
        self.descriptionTeaser = event.descriptionTeaser.map(AttributedString.init)
        self.description = AttributedString(event.description)
        self.warnings = event.warnings.map(AttributedString.init)
    }
}