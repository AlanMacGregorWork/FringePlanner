//
//  FringeImage.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 13/11/2024.
//

import Foundation

/// Contains a group of images
struct FringeImage: Equatable, Hashable {
    let hash: String
    let orientation: Orientation
    let type: ImageType
    let versions: [String: Version]
}

extension FringeImage: Decodable {
    enum Orientation: String, Decodable {
        case landscape
        case portrait
        case square
    }
    
    enum ImageType: String, Decodable {
        case thumb
        case hero
    }
    
    /// Contains a particular image (square, small, original, etc)
    struct Version: Codable, Equatable, Hashable {
        let type: String
        let width: Int
        let height: Int
        let mime: String
        let url: URL
    }
}
