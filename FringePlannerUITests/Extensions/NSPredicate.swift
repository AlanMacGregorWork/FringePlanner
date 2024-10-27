//
//  NSPredicate.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 27/10/2024.
//

import Foundation

extension NSPredicate {
    static func label(string: String) -> NSPredicate {
        NSPredicate(format: "label CONTAINS '\(string)'")
    }
}
