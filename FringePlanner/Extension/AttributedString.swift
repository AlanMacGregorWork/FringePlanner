//
//  AttributedString.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 08/12/2024.
//

import SwiftUI

extension AttributedString {
    /// Create an attributed string from HTML.
    /// - Parameters:
    ///   - html: The HTML string to convert (may also be a standard string)
    ///   - colorScheme: The color scheme to use for the attributed string.
    /// - Returns: An attributed string created from the HTML.
    init?(from html: String, colorScheme: ColorScheme) {
        let styledHTML = Self.createHTML(fromString: html, colorScheme: colorScheme)
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
    
    private static func createHTML(fromString string: String, colorScheme: ColorScheme) -> String {
        """
        <style>
            body {
                font-family: -apple-system; /* Due the default Apple font */
                font-size: \(UIFont.preferredFont(forTextStyle: .body).pointSize)px; /* Use the system font size */
                color: \(colorScheme == .dark ? "white" : "black"); /* Add support for dark mode */
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
}
