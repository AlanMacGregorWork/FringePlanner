//
//  ContainerData.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 26/12/2024.
//

@testable import FringePlanner

extension ContainerData {
    /// Allows directly calling a ContainerData
    /// - Note: Only required during testing as ContainerData is otherwise created in `FringeDataResultBuilder`
    init(@FringeDataResultBuilder values: () -> ContainerData<repeat each Content>) {
        self = values()
    }
}
