//
//  WithContentViewModifier.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 21/04/2025.
//

import SwiftUI

/// A view modifier that conditionally transforms a view based on the presence of an optional value.
///
/// - Parameters:
///   - value: An optional value of type `T` that determines whether to apply the transformation.
///   - transform: A closure that takes the current content and unwrapped value to produce a modified view.
private struct WithContentViewModifier<T, Modified: View>: ViewModifier {
    let value: T?
    let transform: (Content, T) -> Modified
    
    func body(content: Content) -> some View {
        if let unwrappedValue = value {
            transform(content, unwrappedValue)
        } else {
            content
        }
    }
}

extension View {
    /// Conditionally transforms a view based on the presence of an optional value.
    /// - Parameters:
    ///   - value: An optional value that determines whether to apply the transformation.
    ///   - transform: A closure that takes the current view and unwrapped value to produce a modified view.
    /// - Returns: Either the original view if value is nil, or the transformed view if value exists.
    func withContent<T, R: View>(_ value: T?, @ViewBuilder transform: @escaping (Self, T) -> R) -> some View {
        return modifier(WithContentViewModifier(value: value) { _, unwrappedValue in
            transform(self, unwrappedValue)
        })
    }
}
