//
//  AttributedString.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 08/12/2024.
//

import SwiftUI

// MARK: - Generation from HTML

extension AttributedString {
    /// Create an attributed string from HTML.
    /// - Note: This must be called from the MainActor otherwise it will attempt to access the main thread and fail
    /// causing the generation to hang
    /// - Parameters:
    ///   - html: The HTML string to convert (may also be a standard string)
    /// - Returns: An attributed string created from the HTML.
    @MainActor
    init?(fromHTML html: String) {
        let styledHTML = Self.createHTML(fromString: html)
        let data = Data(styledHTML.utf8)
        do {
            let nsAttributedString = try NSAttributedString(
                data: data,
                options: [
                    .documentType: NSAttributedString.DocumentType.html, // Inform that the string is HTML
                    .characterEncoding: String.Encoding.utf8.rawValue // Some formatting is lost if this is not included
                ],
                documentAttributes: nil)
            self = AttributedString(nsAttributedString)
        } catch {
            fringeAssertFailure("HTML failed to generate")
            return nil
        }
    }
    
    private static func createHTML(fromString string: String) -> String {
        """
        <style>
            body {
                font-family: -apple-system; /* Due the default Apple font */
                font-size: \(UIFont.preferredFont(forTextStyle: .body).pointSize)px; /* Use the system font size */
                color: \(hexString(from: .gray)); /* Use the system color (which appears to be gray for both modes) */
            }
            p:last-child {
                display: inline; /* Ensure that the last paragraph does not add a blank new line at the end */
            }
        </style>
        <body>
            \(string)
        </body>
        """
    }
    
    // Convert UIColor to hex string
    private static func hexString(from color: Color) -> String {
        let uiColor = UIColor(color)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return String(format: "#%02X%02X%02X", Int(red * 255), Int(green * 255), Int(blue * 255))
    }
}

// MARK: - StringProvider

extension AttributedString {
    /// An enum that provides attributed text content with deferred processing for HTML strings.
    enum StringProvider: Equatable {
        /// Content that is already in AttributedString format
        case attributedString(AttributedString)
        /// HTML string content that will be converted later to AttributedString
        case htmlString(String)

        /// Creates a provider by automatically detecting if the string contains HTML
        /// - Parameter string: The input string to analyze
        /// If string contains HTML markers, it's stored as htmlString for later conversion
        /// Otherwise, it's immediately converted to AttributedString
        init(_ string: String) {
            if string.mayContainHTML {
                self = .htmlString(string)
            } else {
                self = .attributedString(AttributedString(string))
            }
        }
        
        /// Returns true if the string includes the prefix after both strings are processed.
        /// Processing includes:
        /// - Removing HTML tags
        /// - Normalizing typographic characters (converting curly quotes to straight quotes)
        /// - Trimming whitespace
        /// This ensures consistent comparison regardless of formatting differences.
        func hasTrimmedPrefix(_ stringProvider: AttributedString.StringProvider?) -> Bool {
            // Prefix must exist to be a prefix for the title
            guard let stringProvider else { return false }
            // Values must be trimmed of whitespace before comparison as the attributed string generated from HTML
            // may have whitespace which is not part of the default decoding
            let string1 = self.rawString.withoutHTMLTags.withoutNewLines.typographicallyEnhanced.trimmed
            let string2 = stringProvider.rawString.withoutHTMLTags.withoutNewLines.typographicallyEnhanced.trimmed
            return string1.hasPrefix(string2)
        }
        
        /// Returns the raw string content regardless of the provider type
        /// - For attributed string: converts characters to a standard string
        /// - For HTML string: returns the original HTML content
        private var rawString: String {
            switch self {
            case .attributedString(let attributedString):
                return String(attributedString.characters)
            case .htmlString(let htmlString):
                return htmlString
            }
        }
    }
}
