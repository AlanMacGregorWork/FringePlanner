//
//  DownloadHelper.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 22/04/2025.
//

import Foundation
import SwiftUI

/// Helper struct providing utilities for downloading data from URLs
struct DownloadHelper {
    private init() {}
    
    /// Downloads data from a specified URL using the provided download implementation
    /// - Parameters:
    ///   - url: The URL to download data from
    ///   - downloadSupport: An implementation of `DownloadProtocol` to perform the actual download
    /// - Returns: The downloaded data
    /// - Throws: A `DownloadError` if any errors occur during the download or validation process
    static func downloadData(
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
    
    // MARK: Errors

    /// Errors that can occur during the download process
    enum DownloadError: Error, Equatable {
        case urlGenerationFailed(FringeEventURLBuilder.URLError)
        case downloadFailed
        case decodeFailed
        case invalidResponse
        case httpError(statusCode: Int)
    }
}

// MARK: -

/// Protocol for downloading data from a URL
protocol DownloadProtocol: Sendable {
    /// Retrieves data from a specified URL
    /// - Parameter from: The URL to download data from
    /// - Returns: A tuple containing the downloaded data and the URL response
    /// - Throws: Any error that occurs during the download operation
    func data(from: URL) async throws -> (Data, URLResponse)
}

extension EnvironmentValues {
    @Entry var downloader: DownloadProtocol = URLSession.shared
}
