//
//  DBFringeModel.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 30/12/2024.
//

import SwiftData
import Foundation

/// Supports linking the database Fringe model to the API
protocol DBFringeModel: PersistentModel, CustomEquatableSupport where OtherEquatableType == APIFringeModelType {
    associatedtype APIFringeModelType: APIFringeModel where APIFringeModelType.DBFringeModelType == Self
    func update(from apiModel: APIFringeModelType)
    static var equatableChecksForDBAndAPI: [EquatableCheck<Self, APIFringeModelType>] { get }
    init(apiModel: APIFringeModelType, context: ModelContext) throws(DBError)
    static func predicate(forMatchingAPIModel apiModel: APIFringeModelType) -> Predicate<Self>
}

// MARK: CustomEquatableSupport

extension DBFringeModel {
    static func == (lhs: Self, rhs: APIFringeModelType) -> Bool {
        !Self.equatableChecksForDBAndAPI.contains(where: { !$0.isEqual(lhs: lhs, rhs: rhs) })
    }
}
