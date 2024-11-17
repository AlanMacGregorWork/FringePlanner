//
//  FBEventURLBuilder.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 16/11/2024.
//

import Foundation

struct FBEventURLBuilder {

    let key: String
    let secretKey: String

    init(key: String = ApiKey.fringeApiKey.value, secretKey: String = ApiKey.fringeSecretSigningKey.value) {
        self.key = key
        self.secretKey = secretKey
    }
    
    func constructURL(for request: FilterRequest) throws(FBEventURLError) -> URL {
        // The URL requires a "signature" which is taken from the later half of the URL, this is then appended
        // onto the URL to authenticate
        var components = URLComponents()
        components.path = "/events"
        components.queryItems = request.queryItem + [.init(name: "key", value: key)]
        // The signature for the URL is built from the query portion of the URL (not the scheme & host)
        let signature = try getSignature(from: components)
        components.queryItems?.append(.init(name: "signature", value: signature))
        // Once the signature is calculated and added to the URL, the final parts of the URL can be included
        components.scheme = "https"
        components.host = "api.edinburghfestivalcity.com"

        // Assemble the URL
        guard let url = components.url else { throw .urlFailed }
        return url
    }

    private func getSignature(from components: URLComponents) throws(FBEventURLError) -> String {
        guard let componentsString = components.string else { throw .componentsFailed }
        
        // Create a signature from the path
        return try mapError(
            for: try HMACGenerator.createHash(for: componentsString, key: secretKey),
            expectedType: String.self,
            to: FBEventURLError.signatureFailed)
    }
    
    // MARK: Error
    
    enum FBEventURLError: Error, Equatable {
        case signatureFailed(HMACGenerator.GeneratorError)
        case componentsFailed
        case urlFailed
    }
}
