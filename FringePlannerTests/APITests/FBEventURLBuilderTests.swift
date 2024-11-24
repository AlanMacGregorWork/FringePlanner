//
//  FBEventURLBuilderTests.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 17/11/2024.
//

import Testing
import Foundation
@testable import FringePlanner

@Suite("FBEventURLBuilder Tests")
struct FBEventURLBuilderTests {
    
    @Test("Default init uses correct keys")
    func testDefaultInitKeys() throws {
        // Validate state
        let key = try #require(ApiKey.fringeApiKey.value)
        let secretKey = try #require(ApiKey.fringeSecretSigningKey.value)
        try #require(!key.isEmpty)
        try #require(!secretKey.isEmpty)
        
        // Perform test
        let urlBuilder = FBEventURLBuilder()
        #expect(key == urlBuilder.key)
        #expect(secretKey == urlBuilder.secretKey)
    }
    
    @Test("Keys alter URL")
    func testKeysAlterURL() throws {
        // Pass 1
        let urlBuilder1 = FBEventURLBuilder(key: "key1", secretKey: "secretKey1")
        let actualURL1 = try urlBuilder1.constructURL(for: .init())
        let expectedURL1 = try #require(URL(string: "https://api.edinburghfestivalcity.com/events?key=key1&signature=4e451ff1db9e98529af4c781c30d944a98ed21c1"))
        #expect(expectedURL1 == actualURL1)
        // Pass 2
        let urlBuilder2 = FBEventURLBuilder(key: "key2", secretKey: "secretKey2")
        let actualURL2 = try urlBuilder2.constructURL(for: .init())
        let expectedURL2 = try #require(URL(string: "https://api.edinburghfestivalcity.com/events?key=key2&signature=4fa579d29e1f7d427a1c4cc8fa7ae6bb854df6cc"))
        #expect(expectedURL2 == actualURL2)
        
        #expect(actualURL1 != actualURL2, "Keys should affect URL")
    }
    
    @Test("Requests alter URL")
    func testRequestsAlterURL() throws {
        let urlBuilder = FBEventURLBuilder()
        
        let actualURL1 = try urlBuilder.constructURL(for: .init(title: "some Item"))
        let expectedURL1 = try #require(URL(string: "https://api.edinburghfestivalcity.com/events?title=some%20Item&key=j2MuaCgShVgUaMtm&signature=418e8d542d471e45254b5fd736028100b6533fcc"))
        #expect(expectedURL1 == actualURL1)
        // Pass 2
        let actualURL2 = try urlBuilder.constructURL(for: .init(title: "some different item"))
        let expectedURL2 = try #require(URL(string: "https://api.edinburghfestivalcity.com/events?title=some%20different%20item&key=j2MuaCgShVgUaMtm&signature=eeb8f86fd3cf79dd339bf92418fa8d779a87e77e"))
        #expect(expectedURL2 == actualURL2)
        
        // Pass 3
        let actualURL3 = try urlBuilder.constructURL(for: .init(title: "some different item", hasCaptioning: true))
        let expectedURL3 = try #require(URL(string: "https://api.edinburghfestivalcity.com/events?title=some%20different%20item&has_captioning=1&key=j2MuaCgShVgUaMtm&signature=b68fd08d7ad586b82dd89a4ed98fe0853c4907c7"))
        #expect(expectedURL3 == actualURL3)
        
        #expect(actualURL1 != actualURL2, "Requests should affect URL")
        #expect(actualURL1 != actualURL3, "Requests should affect URL")
    }
}