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
    /// - Returns: An attributed string created from the HTML.
    init?(from html: String) {
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
