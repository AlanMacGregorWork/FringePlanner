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
        let type: VersionType
        let width: Int
        let height: Int
        let mime: String
        let url: URL
    }
    
    /// Image version types available from the API
    enum VersionType: Codable, Equatable, Hashable {
        /// The original size and format of the image
        case original
        /// Scaled down to fit a transparent 75 pixel square box
        case square75
        /// Scaled down to fit a transparent 150 pixel square box
        case square150
        /// Scaled down in original aspect ratio to 100 pixels on the longest side
        case thumb100
        /// Scaled down in original aspect ratio to 320 pixels on the longest side
        case small320
        /// Scaled down in original aspect ratio to 640 pixels on the longest side
        case medium640
        /// Scaled down in original aspect ratio to 1024 pixels on the longest side
        case large1024
        /// For handling unknown version types that may be added in the future
        case custom(String)
        
        // MARK: - Codable
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawValue = try container.decode(String.self)
            
            switch rawValue {
            case "original": self = .original
            case "square-75": self = .square75
            case "square-150": self = .square150
            case "thumb-100": self = .thumb100
            case "small-320": self = .small320
            case "medium-640": self = .medium640
            case "large-1024": self = .large1024
            default: self = .custom(rawValue)
            }
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            
            let rawValue: String
            switch self {
            case .original: rawValue = "original"
            case .square75: rawValue = "square-75"
            case .square150: rawValue = "square-150"
            case .thumb100: rawValue = "thumb-100"
            case .small320: rawValue = "small-320"
            case .medium640: rawValue = "medium-640"
            case .large1024: rawValue = "large-1024"
            case .custom(let value): rawValue = value
            }
            
            try container.encode(rawValue)
        }
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
