//
//  AsyncImageView.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 06/10/2024.
//

import SwiftUI

/// A view that asynchronously loads, caches, and displays an image from a URL
struct AsyncImageView: View {
    /// The URL of the image to load
    let url: URL?
    @State private var phase: ImagePhase = .empty
    @Environment(\.downloader) private var downloader: DownloadProtocol
    
    var body: some View {
        switch phase {
        case .empty:
            ProgressView()
                .task {
                    let phase = await loadImage()
                    await MainActor.run {
                        self.phase = phase
                    }
                }
        case .success(let image):
            image
                .resizable()
                .scaledToFit()
        case .failure:
            Image(systemName: "exclamationmark.triangle")
        }
    }
    
    /// Loads the image from the network using URLCache
    private func loadImage() async -> ImagePhase {
        // Retrieve the data
        guard let url else { return .failure }
        guard let data = try? await DownloadHelper.downloadData(from: url, downloadSupport: downloader) else {
            return .failure
        }
        // Convert the data to an image
        guard let uiImage = UIImage(data: data) else { return .failure }
        return .success(Image(uiImage: uiImage))
    }
    
    /// Represents the different states of the image loading process
    private enum ImagePhase {
        /// The image has not started loading yet
        case empty
        /// The image loaded successfully
        case success(Image)
        /// The image failed to load
        case failure
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        // Example with default placeholder and error view
        VStack {
            Text("Valid URL #1")
                .font(.headline)
            AsyncImageView(url: URL(string: "https://some-fake-url.com/fake-image1.png"))
                .frame(width: 50, height: 50)
                .border(.gray)
        }
        
        VStack {
            Text("Valid URL #2")
                .font(.headline)
            AsyncImageView(url: URL(string: "https://some-fake-url.com/fake-image2.png"))
                .frame(width: 50, height: 50)
                .border(.gray)
        }
        
        VStack {
            Text("Loading")
                .font(.headline)
            AsyncImageView(url: URL(string: "https://some-fake-url.com/loading.png"))
                .frame(width: 50, height: 50)
                .border(.gray)
        }
        
        VStack {
            Text("Failure")
                .font(.headline)
            AsyncImageView(url: nil)
                .frame(width: 50, height: 50)
                .border(.gray)
        }
    }
    .environment(\.downloader, PreviewDownloader())
    .padding()
}

/// A downloader specifically for Preview use
private struct PreviewDownloader: DownloadProtocol {
    func data(from url: URL) async throws -> (Data, URLResponse) {
        guard let urlResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil) else {
            throw URLError(.unknown)
        }
        
        if url.absoluteString == "https://some-fake-url.com/fake-image1.png" {
            guard let data = UIImage(named: "image1")?.jpegData(compressionQuality: 1.0) else { throw URLError(.unknown) }
            return (data, urlResponse)
        } else if url.absoluteString == "https://some-fake-url.com/fake-image2.png" {
            guard let data = UIImage(named: "image2")?.jpegData(compressionQuality: 1.0) else { throw URLError(.unknown) }
            return (data, urlResponse)
        } else if url.absoluteString == "https://some-fake-url.com/loading.png" {
            try await Task.sleep(nanoseconds: 3600000000000) // 1 hour
            throw URLError(.unknown)
        } else {
            throw URLError(.unknown)
        }
    }
}
