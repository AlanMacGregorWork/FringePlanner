//
//  FringeImageTests.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 25/04/2025.
//

import Testing
import Foundation
@testable import FringePlanner

@Suite("FringeImage Tests")
struct FringeImageTests {

    let thumbOnlyDict = Self.createThumbOnlyDictionary()
    let imagesDictionary = Self.createTestImagesDictionary()
    let emptyDict: [String: FringeImage] = [:]
    
    @Test("optimalURL should return the most appropriate image URL based on dimensions and type")
    func testOptimalURL() throws {
        // Test case 1: Perfect match for thumb type
        #expect(imagesDictionary.optimalURL(width: 300, height: 200, type: .thumb)?.absoluteString == "https://example.com/image1-small.jpg")
        
        // Test case 2: Perfect match for hero type
        #expect(imagesDictionary.optimalURL(width: 1024, height: 768, type: .hero)?.absoluteString == "https://example.com/image3-large.jpg")
        
        // Test case 3: No exact match - should return smallest image that exceeds requirements
        #expect(imagesDictionary.optimalURL(width: 400, height: 250, type: .thumb)?.absoluteString == "https://example.com/image1-medium.jpg")
        
        // Test case 4: No images meet requirement - should return smallest available of that type
        #expect(imagesDictionary.optimalURL(width: 2000, height: 1500, type: .thumb)?.absoluteString == "https://example.com/image1-small.jpg")
        
        // Test case 5: No images of the specified type exist - should fall back to any available type
        #expect(thumbOnlyDict.optimalURL(width: 100, height: 100, type: .hero)?.absoluteString == "https://example.com/thumb-only.jpg")
        
        // Test case 6: Empty dictionary - should return nil
        #expect(emptyDict.optimalURL(width: 100, height: 100, type: .thumb) == nil)
    }
}

// MARK: - Helpers

extension FringeImageTests {
    // Helper method to create test images dictionary with both thumb and hero types
    private static func createTestImagesDictionary() -> [String: FringeImage] {
        // Create different versions
        let smallVersion = FringeImage.Version(type: "small-320", width: 300, height: 200, mime: "image/jpeg", url: URL(string: "https://example.com/image1-small.jpg")!)
        let mediumVersion = FringeImage.Version(type: "medium-640", width: 600, height: 400, mime: "image/jpeg", url: URL(string: "https://example.com/image1-medium.jpg")!)
        let largeVersion = FringeImage.Version(type: "large-1024", width: 1024, height: 768, mime: "image/jpeg", url: URL(string: "https://example.com/image1-large.jpg")!)
        let originalVersion = FringeImage.Version(type: "original", width: 1200, height: 800, mime: "image/jpeg", url: URL(string: "https://example.com/image1-original.jpg")!)
        let heroLargeVersion = FringeImage.Version(type: "large-1024", width: 1024, height: 768, mime: "image/jpeg", url: URL(string: "https://example.com/image3-large.jpg")!)
        let heroOriginalVersion = FringeImage.Version(type: "original", width: 1920, height: 1080, mime: "image/jpeg", url: URL(string: "https://example.com/image3-original.jpg")!)
        // Create image objects
        let thumbImage = FringeImage(hash: "image1", orientation: .landscape, type: .thumb, versions: ["small-320": smallVersion, "medium-640": mediumVersion, "large-1024": largeVersion, "original": originalVersion])
        let heroImage = FringeImage(hash: "image3", orientation: .landscape, type: .hero, versions: ["large-1024": heroLargeVersion, "original": heroOriginalVersion])
        
        // Return dictionary with test images
        return ["image1": thumbImage, "image3": heroImage]
    }
    
    // Helper method to create dictionary with only thumb type images
    private static func createThumbOnlyDictionary() -> [String: FringeImage] {
        let version = FringeImage.Version(type: "small-320", width: 300, height: 200, mime: "image/jpeg", url: URL(string: "https://example.com/thumb-only.jpg")!)
        let thumbImage = FringeImage(hash: "thumbonly", orientation: .landscape, type: .thumb, versions: ["small-320": version])
        
        return ["thumbonly": thumbImage]
    }
}
