//
//  FilterRequest.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 02/11/2024.
//

import Foundation

/// Provides items that can be used to filter for events
struct FilterRequest {
    
    // MARK: Properties
    
    // Text
    var title: String?
    var description: String?
    var artist: String?
    // Dates
    var dateFrom: Date?
    var dateTo: Date?
    // Price
    var priceFrom: Int?
    var priceTo: Int?
    // Accessibility Options
    var hasAudioDescription: Bool?
    var hasCaptioning: Bool?
    var hasSigned: Bool?
    var hasOtherAccessibility: Bool?
    // Venue Search
    var venueName: String?
    var venueCode: String?
    var postCode: String?
    // Geographical location
    var latitude: Float?
    var longitude: Float?
    // Paging
    var pageSize: Int?
    var fromPage: Int?
    // Additional
    // Note: Really only needed for debug purposes
    var prettyPrint: Bool?
    // TODO: `modified_from` not been setup
    
    // MARK: Generation
    
    /// Generates an array of all of the query items set for this request.
    var queryItem: [URLQueryItem] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        // General Bool
        // Note: For bool options, a query should only be returned if the value is true
        let hasAudioDescription = self.hasAudioDescription.flatMap({ $0 ? URLQueryItem(name: "has_audio_description", value: "1") : nil })
        let hasCaptioning = self.hasCaptioning.flatMap({ $0 ? URLQueryItem(name: "has_captioning", value: "1") : nil })
        let hasOtherAccessibility = self.hasOtherAccessibility.flatMap({ $0 ? URLQueryItem(name: "has_other_accessibility", value: "1") : nil })
        let hasSigned = self.hasSigned.flatMap({ $0 ? URLQueryItem(name: "has_signed", value: "1") : nil })
        let pretty = self.prettyPrint.flatMap({ $0 ? URLQueryItem(name: "pretty", value: "1") : nil })
        
        // General String
        let title = self.title?.trimmed.nilOnEmpty.map({ URLQueryItem(name: "title", value: $0) })
        let description = self.description?.trimmed.nilOnEmpty.map({ URLQueryItem(name: "description", value: $0) })
        let artist = self.artist?.trimmed.nilOnEmpty.map({ URLQueryItem(name: "artist", value: $0) })
        let venueName = self.venueName?.trimmed.nilOnEmpty.map({ URLQueryItem(name: "venue_name", value: $0) })
        let venueCode = self.venueCode?.trimmed.nilOnEmpty.map({ URLQueryItem(name: "venue_code", value: $0) })
        let postCode = self.postCode?.trimmed.nilOnEmpty.map({ URLQueryItem(name: "post_code", value: $0) })
        
        // Prices
        let priceFrom: URLQueryItem?
        let priceTo: URLQueryItem?
        if self.priceFrom ?? 0 <= self.priceTo ?? Int.max {
            priceFrom = self.priceFrom.flatMap({ $0 > 0 ? $0 : nil }).flatMap({ URLQueryItem(name: "price_from", value: "\($0)") })
            priceTo = self.priceTo.flatMap({ $0 > 0 ? $0 : nil }).flatMap({ URLQueryItem(name: "price_to", value: "\($0)") })
        } else {
            priceFrom = nil
            priceTo = nil
        }
        
        // Date
        let dateFrom: URLQueryItem?
        let dateTo: URLQueryItem?
        if self.dateFrom ?? Date.distantPast <= self.dateTo ?? Date.distantFuture {
            dateFrom = self.dateFrom.map({ URLQueryItem(name: "date_from", value: formatter.string(from: $0)) })
            dateTo = self.dateTo.map({ URLQueryItem(name: "date_to", value: formatter.string(from: $0)) })
        } else {
            dateFrom = nil
            dateTo = nil
        }
        
        // Geography
        let latitude = self.latitude.map({ URLQueryItem(name: "lat", value: "\($0)") })
        let longitude = self.longitude.map({ URLQueryItem(name: "lon", value: "\($0)") })
        
        // Page Size
        let pageSize = self.pageSize.map({ max(25,min(100,$0)) }).map({ URLQueryItem(name: "size", value: "\($0)") })

        // From Page
        let fromPage = self.fromPage.flatMap({ $0 > 0 ? $0 : nil }).flatMap({ URLQueryItem(name: "from", value: "\($0)") })
    
        
        return [
            title,
            description,
            artist,
            dateFrom,
            dateTo,
            priceFrom,
            priceTo,
            hasAudioDescription,
            hasCaptioning,
            hasSigned,
            hasOtherAccessibility,
            venueName,
            venueCode,
            postCode,
            latitude,
            longitude,
            pageSize,
            fromPage,
            pretty
        ].compactMap({ $0 })
    }
}
