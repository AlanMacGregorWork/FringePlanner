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

// MARK: Codable

extension FringeImage: Codable {
    enum Orientation: String, Codable {
        case landscape
        case portrait
        case square
    }
    
    enum ImageType: String, Codable {
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

// MARK: - Helper

extension Dictionary where Key == String, Value == FringeImage {
    /// Finds the optimal image URL that meets or exceeds the requested dimensions
    /// - Returns: URL of the smallest image that meets or exceeds the requested dimensions,
    ///   or the URL of the first available image if none meet the criteria, or nil if no images exist
    func optimalURL(width: Int, height: Int, type: FringeImage.ImageType) -> URL? {
        var images = values.filter { $0.type == type }
        // We ideally want to receive at least one image, so if there is nothing available for the type, all types
        // should be allowed
        if images.isEmpty {
            images = values.map({ $0 })
        }
        let versions = images.flatMap { $0.versions.values }
        let sortedVersions = versions.sorted { $0.width * $0.height < $1.width * $1.height }
        return sortedVersions.first { $0.width >= width && $0.height >= height }?.url ?? sortedVersions.first?.url
    }
}
