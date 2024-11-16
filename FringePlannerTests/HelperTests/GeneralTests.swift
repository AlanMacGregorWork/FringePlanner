//
//  GeneralTests.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 03/11/2024.
//

import Testing
@testable import FringePlanner

@Suite("General Tests")
struct GeneralTests {
    @Suite("`mapError` Tests")
    struct MapErrorTests { }
}

// MARK: - MapError Tests

extension GeneralTests.MapErrorTests {
    
    @Test("Ignores input error and creates new type")
    func ignoresInputErrorAnCreatesNewType() {
        #expect(throws: FileError.fileNotFound) {
            try mapError(
                for: errorFunction(errorType: ExampleError.example, expectedResponse: ""),
                expectedType: String.self,
                to: { (_: ExampleError) in FileError.fileNotFound })
        }
        
        #expect(throws: FileError.accessFailed(.writingFailed)) {
            try mapError(
                for: errorFunction(errorType: ExampleError.example, expectedResponse: ""),
                expectedType: String.self,
                to: { (_: ExampleError) in FileError.accessFailed(.writingFailed) })
        }
    }
    
    @Test("Uses input type with new type")
    func usesInputTypeWithNewType() {
        #expect(throws: FileError.accessFailed(.loadingFailed)) {
            try mapError(
                for: errorFunction(errorType: DataError.loadingFailed, expectedResponse: ""),
                expectedType: String.self,
                to: { (error: DataError) in FileError.accessFailed(error) })
        }
        
        #expect(throws: FileError.accessFailed(.loadingFailed)) {
            try mapError(
                for: errorFunction(errorType: DataError.loadingFailed, expectedResponse: ""),
                expectedType: String.self,
                to: FileError.accessFailed)
        }
    }
    
    @Test("Can throw with the same type as input")
    func canThrowWithTheSameTypeAsInput() {
        #expect(throws: ExampleError.revision) {
            try mapError(
                for: errorFunction(errorType: ExampleError.example, expectedResponse: ""),
                expectedType: String.self,
                to: { (_: ExampleError) in ExampleError.revision })
        }
    }
    
    @Test("Maps to output type", arguments: typesTest.keys)
    func testMapError_Equatable(key: String) throws {
        let expectedResponse = try #require(Self.typesTest[key])
        try testMapError_EquatableTests(expectedResponse: expectedResponse)
    }
    
    func testMapError_EquatableTests<T: Equatable>(expectedResponse: T) throws {
        #expect(throws: FileError.self, performing: { try mapErrorToDataError(shouldPass: false, expectedResponse: expectedResponse) })
        #expect(throws: Never.self, performing: { try mapErrorToDataError(shouldPass: true, expectedResponse: expectedResponse) })
        #expect(try mapErrorToDataError(shouldPass: true, expectedResponse: expectedResponse) == expectedResponse)
    }
}

// MARK: Helpers

fileprivate extension GeneralTests.MapErrorTests {
    
    enum ExampleError: Error {
        case example
        case revision
    }
    
    enum FileError: Error, Equatable {
        case fileNotFound
        case accessFailed(DataError)
    }
    
    enum DataError: Error, Equatable {
        case loadingFailed
        case writingFailed
    }
    
    static var typesTest: [String: any Equatable] {
        [
            "Int": 123,
            "String": "Passed",
            "Bool": true
        ]
    }
    
    func mapErrorToDataError<Value: Equatable>(shouldPass: Bool, expectedResponse: Value) throws(FileError) -> Value {
        try mapError(
            for: try throwError(shouldPass: shouldPass, expectedResponse: expectedResponse),
            expectedType: Value.self,
            to: { (_: DataError) in FileError.fileNotFound })
    }
    
    func throwError<ExpectedResponse>(shouldPass: Bool, expectedResponse: ExpectedResponse) throws(DataError) -> ExpectedResponse {
        if shouldPass {
            return expectedResponse
        } else {
            throw DataError.loadingFailed
        }
    }
    
    func errorFunction<ErrorType: Error, ExpectedType>(errorType: ErrorType, expectedResponse: ExpectedType) throws(ErrorType) -> ExpectedType {
        throw errorType
    }
}
