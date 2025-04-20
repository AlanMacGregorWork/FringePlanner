//
//  ErrorContent.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 20/04/2025.
//

/// A structure for standardizing the presentation of errors throughout the application.
/// Used to format error information for display in UI elements.
struct ErrorContent {
    /// Optional title for the error message
    let title: String?
    
    /// Detailed description of the error
    let description: String

    /// Creates error content from an `Error` object
    /// - Parameter error: The error to be formatted
    init(error: Error) {
        self.title = nil
        self.description = error.localizedDescription
    }
}
