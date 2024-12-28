//
//  FBEventDownloader.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 16/11/2024.
//

import Foundation

/// Downloads Fringe events from the Fringe API
struct FBEventDownloader: FBEventDownloader.GetEventsProtocol {
    
    private let downloadSupport: any DownloadProtocol
    
    init(downloadSupport: any DownloadProtocol = URLSession.shared) {
        self.downloadSupport = downloadSupport
    }

    func getFBEvents(from request: FilterRequest) async throws(FBEventDownloadError) -> [FringeEvent] {
        let url = try Self.constructURL(from: request)
        let data = try await Self.downloadData(from: url, downloadSupport: downloadSupport)
        let events = try Self.decodeEvents(from: data)
        return events
    }
}

// MARK: Helpers

extension FBEventDownloader {

    private static func constructURL(from request: FilterRequest) throws (FBEventDownloadError) -> URL {
        try mapError(
            for: try FBEventURLBuilder().constructURL(for: request),
            expectedType: URL.self,
            to: { FBEventDownloadError.urlGenerationFailed($0) })
    }
    
    private static func downloadData(
        from url: URL,
        downloadSupport: any DownloadProtocol
    ) async throws(FBEventDownloadError) -> Data {
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
    
    private static func decodeEvents(from data: Data) throws(FBEventDownloadError) -> [FringeEvent] {
        try mapError(
            for: try fringeJsonDecoder.decode([FringeEvent].self, from: data),
            expectedType: [FringeEvent].self,
            to: { (error: any Error) in
                fringeAssertFailure("Decode failed: \(error)")
                return FBEventDownloadError.decodeFailed
            })
    }
    
    // MARK: Errors
    
    enum FBEventDownloadError: Error, Equatable {
        case urlGenerationFailed(FBEventURLBuilder.FBEventURLError)
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
        func getFBEvents(from request: FilterRequest) async throws(FBEventDownloader.FBEventDownloadError) -> [FringeEvent]
    }
}

// MARK: Protocol Support

extension URLSession: FBEventDownloader.DownloadProtocol {}

#if DEBUG
struct MockEventDownloader: FBEventDownloader.GetEventsProtocol {
    func getFBEvents(from request: FilterRequest) async throws(FBEventDownloader.FBEventDownloadError) -> [FringeEvent] {
        return .exampleModels()
    }
}
#endif
