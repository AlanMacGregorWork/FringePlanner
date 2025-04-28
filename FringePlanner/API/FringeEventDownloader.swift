//
//  FringeEventDownloader.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 16/11/2024.
//

import Foundation

/// Downloads Fringe events from the Fringe API
struct FringeEventDownloader: FringeEventDownloader.GetEventsProtocol {
    
    private let downloadSupport: any DownloadProtocol
    
    init(downloadSupport: any DownloadProtocol = URLSession.shared) {
        self.downloadSupport = downloadSupport
    }

    func getEvents(from request: FilterRequest) async throws(DownloadHelper.DownloadError) -> [FringeEvent] {
        let url = try Self.constructURL(from: request)
        let data = try await DownloadHelper.downloadData(from: url, downloadSupport: downloadSupport)
        let events = try Self.decodeEvents(from: data)
        return events
    }
}

// MARK: Helpers

extension FringeEventDownloader {

    private static func constructURL(from request: FilterRequest) throws (DownloadHelper.DownloadError) -> URL {
        try mapError(
            for: try FringeEventURLBuilder().constructURL(for: request),
            expectedType: URL.self,
            to: { DownloadHelper.DownloadError.urlGenerationFailed($0) })
    }

    private static func decodeEvents(from data: Data) throws(DownloadHelper.DownloadError) -> [FringeEvent] {
        try mapError(
            for: try fringeJsonDecoder.decode([FringeEvent].self, from: data),
            expectedType: [FringeEvent].self,
            to: { (error: any Error) in
                fringeAssertFailure("Decode failed: \(error)")
                return DownloadHelper.DownloadError.decodeFailed
            })
    }

    // MARK: Protocols

    /// Protocol for the downloading events from the Fringe API 
    protocol GetEventsProtocol {
        func getEvents(from request: FilterRequest) async throws(DownloadHelper.DownloadError) -> [FringeEvent]
    }
}

// MARK: Protocol Support

extension URLSession: DownloadProtocol {}

#if DEBUG
struct MockEventDownloader: FringeEventDownloader.GetEventsProtocol {
    /// The models to return
    let models: [FringeEvent]
    
    /// Initialise a MockEventDownloader with a set of models
    /// - Parameter models: The models to return
    init(models: [FringeEvent] = .exampleModels()) {
        self.models = models
    }
    
    func getEvents(from request: FilterRequest) async throws(DownloadHelper.DownloadError) -> [FringeEvent] {
        return self.models
    }
}
#endif
