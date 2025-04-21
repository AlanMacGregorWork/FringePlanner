//
//  Image.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 20/04/2025.
//

import SwiftUI

extension Image { 
    /// Returns an image of a star with a fill if the `isFavourite` parameter is true
    /// - Parameter isFavourite: Whether the star should be filled
    /// - Returns: An image of a star
    static func favourite(isFavourite: Bool) -> some View {
        Image(systemName: isFavourite ? "star.fill" : "star")
            .foregroundColor(isFavourite ? .blue : .primary)
    }
}
