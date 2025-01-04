//
//  DBFringeModel.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 30/12/2024.
//

import SwiftData

/// Supports linking the database Fringe model to the API
protocol DBFringeModel: PersistentModel {
    associatedtype APIModelType
    func update(from apiModel: APIModelType)
}
