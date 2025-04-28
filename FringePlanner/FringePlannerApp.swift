//
//  FringePlannerApp.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 16/09/2024.
//

import SwiftUI

@main
struct FringePlannerApp: App {
    init() {
        // Setup application-wide settings
        Self.setupURLCache()
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
    
    /// Configure URLCache for the application
    private static func setupURLCache() {
        // 50MB memory cache, 100MB disk cache
        let cacheSizeMemory = 50 * 1024 * 1024
        let cacheSizeDisk = 100 * 1024 * 1024
        let cache = URLCache(memoryCapacity: cacheSizeMemory, diskCapacity: cacheSizeDisk, diskPath: "FringeCache")
        URLCache.shared = cache
    }
}

#Preview {
    MainView()
}
