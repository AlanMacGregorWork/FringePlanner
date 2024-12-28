//
//  FringeEventDownloaderTests.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 16/11/2024.
//

import Testing
import Foundation
@testable import FringePlanner

@Suite("FringeEventDownloader Tests")
struct FringeEventDownloaderTests {

    let validResponseData: Data
    
    init() throws {
        validResponseData = try Cache.shared.validResponseData
    }
    
    @Test("Throws `downloadFailed` if download failed")
    func testDownloadFailsThrows() async throws {
        let dataResult = try DataResult(testOption: .downloadFailed)
        let downloadSupport = MockDownloaderSupport(dataResult: dataResult)
        let downloader = FringeEventDownloader(downloadSupport: downloadSupport)
        await #expect(throws: FringeEventDownloader.DownloadError.downloadFailed, performing: { try await downloader.getEvents(from: .init()) })
    }
    
    @Test("Throws `decodeFailed` if decode failed", arguments: ["", "someData", "{}"])
    func testDecodeFailsThrows(dataString: String) async throws {
        let dataResult = try #require(try DataResult(testOption: .decodeFailed(dataString: dataString)))
        let downloadSupport = MockDownloaderSupport(dataResult: dataResult)
        let downloader = FringeEventDownloader(downloadSupport: downloadSupport)
        await #expect(throws: FringeEventDownloader.DownloadError.decodeFailed, performing: { try await downloader.getEvents(from: .init()) })
    }

    @Test("Throws `httpError` if status code is not 200-299", arguments: [(0...199), (200...299), (300...999)])
    func testHttpErrorThrows(statusCode: ClosedRange<Int>) async throws {
        for statusCode in statusCode {
            let dataResult = try #require(try DataResult(testOption: .httpError(statusCode: statusCode, validData: validResponseData)))
            let downloadSupport = MockDownloaderSupport(dataResult: dataResult)
            let downloader = FringeEventDownloader(downloadSupport: downloadSupport)
            if (200...299).contains(statusCode) {
                await #expect(throws: Never.self, "\(statusCode) should not fail", performing: { try await downloader.getEvents(from: .init()) })
            } else {
                await #expect(throws: FringeEventDownloader.DownloadError.httpError(statusCode: statusCode), "\(statusCode) should fail", performing: { try await downloader.getEvents(from: .init()) })
            }
        }
    }
    
    @Test("Does not throw when response is valid")
    func testValidResponse() async throws {
        let dataResult = try #require(try DataResult(testOption: .validResponse(validData: validResponseData)))
        let downloadSupport = MockDownloaderSupport(dataResult: dataResult)
        let downloader = FringeEventDownloader(downloadSupport: downloadSupport)
        await #expect(throws: Never.self, performing: { try await downloader.getEvents(from: .init()) })
    }
    
    @Test("Does not throw when response is an empty array")
    func testValidResponseFromEmptyArray() async throws {
        let dataResult = try #require(try DataResult(testOption: .validResponse(validData: Data("[]".utf8))))
        let downloadSupport = MockDownloaderSupport(dataResult: dataResult)
        let downloader = FringeEventDownloader(downloadSupport: downloadSupport)
        await #expect(throws: Never.self, performing: { try await downloader.getEvents(from: .init()) })
    }
}

// MARK: - Cache

/// Cache to prevent multiple reads from hard disk
private struct Cache {
    private let internalValidResponseData: Data?
    static let shared = Cache()
    var validResponseData: Data {
        get throws(CacheError) {
            guard let internalValidResponseData else { throw .responseFailed }
            return internalValidResponseData
        }
    }
        
    private init() {
        internalValidResponseData = try? Bundle.testData(name: "eventResponse")
    }
    
    enum CacheError: Error {
        case responseFailed
    }
}

// MARK: - MockDownloaderSupport

/// Mock implementation of `FBEventDownloader.DownloadProtocol`
private struct MockDownloaderSupport: FringeEventDownloader.DownloadProtocol {
    let dataResult: DataResult
    
    func data(from: URL) async throws -> (Data, URLResponse) {
        switch dataResult {
        case .error:
            throw NSError(domain: "", code: 0)
        case .success(let data, let response):
            return (data, response)
        }
    }
}

// MARK: - DataResult

/// Contains the elements that alter the response for `MockDownloaderSupport`
private enum DataResult {
    /// Throws an error
    case error
    /// Returns the data and response
    case success(Data, URLResponse)
    
    init(testOption: DataResultTestOption) throws(InitError) {
        switch testOption {
        case .downloadFailed:
            self = .error
        case .httpError(let statusCode, let validData):
            self = .success(validData, try Self.response(forStatusCode: statusCode))
        case .decodeFailed(let dataString):
            self = .success(Data(dataString.utf8), try Self.response(forStatusCode: 200))
        case .validResponse(let validData):
            self = .success(validData, try Self.response(forStatusCode: 200))
        }
    }
    
    private static func response(forStatusCode statusCode: Int) throws(InitError) -> HTTPURLResponse {
        guard let url = URL(string: "http://site.co") else { throw InitError.failedToCreateURL }
        guard let response = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil) else { throw InitError.failedToCreateResponse }
        return response
    }
    
    // MARK: Errors
    
    enum InitError: Error {
        case failedToCreateURL
        case failedToCreateResponse
    }
    
    enum DataResultTestOption {
        case downloadFailed
        case decodeFailed(dataString: String)
        case httpError(statusCode: Int, validData: Data)
        case validResponse(validData: Data)
    }
}
