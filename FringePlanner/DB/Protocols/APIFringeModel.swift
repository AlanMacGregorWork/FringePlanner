//
//  APIFringeModel.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 05/01/2025.
//

/// The model received from the Fringe API
protocol APIFringeModel {
    associatedtype DBFringeModelType: DBFringeModel where DBFringeModelType.APIFringeModelType == Self
}
