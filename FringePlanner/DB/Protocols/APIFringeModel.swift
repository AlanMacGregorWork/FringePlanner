//
//  APIFringeModel.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 05/01/2025.
//

/// The model received from the Fringe API
protocol APIFringeModel: CustomEquatableSupport, Sendable where OtherEquatableType == DBFringeModelType {
    associatedtype DBFringeModelType: DBFringeModel where DBFringeModelType.APIFringeModelType == Self
    /// An ID that can be used to uniquely reference this model
    var referenceID: String { get }
}

// MARK: CustomEquatableSupport

extension APIFringeModel {
    static func == (lhs: Self, rhs: DBFringeModelType) -> Bool {
        rhs == lhs
    }
}
