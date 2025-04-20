//
//  AsyncView.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 10/04/2025.
//

import SwiftUI

/// A view that handles asynchronous operations and displays content based on the result
/// - Parameters:
///   - ReturnedType: The type of data returned by the async operation
///   - ContentView: The type of view to display when data is available
struct AsyncView<ReturnedType: Sendable, ContentView: View>: View {
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

extension AsyncView {
    /// Convenience initializer for when the async operation directly returns a view
    /// - Parameter contentView: An async function that returns a view directly
    ///
    /// This initializer simplifies usage when your async operation directly returns
    /// the view you want to display, eliminating the need for a separate content builder closure.
    init(contentView: @escaping () async throws -> ContentView) where ContentView == ReturnedType {
        self.asyncOperation = {
            try await contentView()
        }
        self.contentView = { return $0 }
    }
}

#if DEBUG

#Preview(traits: .sizeThatFitsLayout) {
    VStack(spacing: 30) {
        // Standard initializer example
        Text("Standard Initializer:")
            .font(.headline)
        AsyncView(asyncOperation: {
            try await Task.sleep(nanoseconds: 2_000_000_000)
            return "Example Response"
        }, contentView: { stringValue in
            Text(stringValue)
        })
        
        // Convenience initializer example
        Text("Convenience Initializer:")
            .font(.headline)
        AsyncView(contentView: {
            try await Task.sleep(nanoseconds: 1_500_000_000)
            return Text("This Text view was created directly in the async operation")
        })
    }
    .padding()
}

#endif
