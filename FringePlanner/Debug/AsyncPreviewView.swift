//
//  AsyncPreviewView.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 10/04/2025.
//

import SwiftUI

#if DEBUG

/// A view that handles asynchronous operations and displays content based on the result
/// - Parameters:
///   - ReturnedType: The type of data returned by the async operation
///   - ContentView: The type of view to display when data is available
struct AsyncPreviewView<ReturnedType: Sendable, ContentView: View>: View {
    /// The result of the async operation
    @State private var content: ReturnedType?
    /// Any error that occurred during the async operation
    @State private var error: Error?
    
    /// The async operation to perform
    let asyncOperation: () async throws -> ReturnedType
    /// The view to display when data is available
    let contentView: (ReturnedType) -> ContentView
    
    var body: some View {
        Group {
            if let error = error {
                Text("Error: \(error.localizedDescription)")
            } else if let content = content {
                contentView(content)
            } else {
                ProgressView()
            }
        }
        .task {
            do {
                content = try await asyncOperation()
            } catch {
                self.error = error
            }
        }
    }
}

#endif
