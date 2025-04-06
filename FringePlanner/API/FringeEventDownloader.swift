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

    func getEvents(from request: FilterRequest) async throws(DownloadError) -> [FringeEvent] {
        let url = try Self.constructURL(from: request)
        let data = try await Self.downloadData(from: url, downloadSupport: downloadSupport)
        let events = try Self.decodeEvents(from: data)
        return events
    }
}

// MARK: Helpers

extension FringeEventDownloader {

    private static func constructURL(from request: FilterRequest) throws (DownloadError) -> URL {
        try mapError(
            for: try FringeEventURLBuilder().constructURL(for: request),
            expectedType: URL.self,
            to: { DownloadError.urlGenerationFailed($0) })
    }
    
    private static func downloadData(
        from url: URL,
        downloadSupport: any DownloadProtocol
    ) async throws(DownloadError) -> Data {
        // Get Data
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await downloadSupport.data(from: url)
        } catch {
            fringeAssertFailure("Download failed: \(error)")
            throw .downloadFailed
        }
        
        // Validate Response
        guard let httpResponse = response as? HTTPURLResponse else { throw .invalidResponse }
        guard (200...299).contains(httpResponse.statusCode) else { throw .httpError(statusCode: httpResponse.statusCode) }

        return data
    }
    
    private static func decodeEvents(from data: Data) throws(DownloadError) -> [FringeEvent] {
        try mapError(
            for: try fringeJsonDecoder.decode([FringeEvent].self, from: data),
            expectedType: [FringeEvent].self,
            to: { (error: any Error) in
                fringeAssertFailure("Decode failed: \(error)")
                return DownloadError.decodeFailed
            })
    }
    
    // MARK: Errors
    
    enum DownloadError: Error, Equatable {
        case urlGenerationFailed(FringeEventURLBuilder.URLError)
        case downloadFailed
        case decodeFailed
        case invalidResponse
        case httpError(statusCode: Int)
    }
    
    // MARK: Protocols
    
    /// Protocol for downloading data from a URL
    protocol DownloadProtocol: Sendable {
        func data(from: URL) async throws -> (Data, URLResponse)
    }
    
    /// Protocol for the downloading events from the Fringe API 
    protocol GetEventsProtocol {
        func getEvents(from request: FilterRequest) async throws(FringeEventDownloader.DownloadError) -> [FringeEvent]
    }
}

// MARK: Protocol Support

extension URLSession: FringeEventDownloader.DownloadProtocol {}

#if DEBUG
struct MockEventDownloader: FringeEventDownloader.GetEventsProtocol {
    /// The models to return
    let models: [FringeEvent]
    
    /// Initialise a MockEventDownloader with a set of models
    /// - Parameter models: The models to return
    init(models: [FringeEvent] = .exampleModels()) {
        self.models = models
    }
    
    func getEvents(from request: FilterRequest) async throws(FringeEventDownloader.DownloadError) -> [FringeEvent] {
        return self.models
    }
}
#endif
