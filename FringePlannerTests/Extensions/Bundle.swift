//
//  Bundle.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 17/11/2024.
//

import UIKit // Note: Required for NSDataAsset
@testable import FringePlanner

extension Bundle {
    
    // MARK: Get Test Bundle
    
    enum GetTestBundleError: Error {
        /// The bundle was not found 
        case notFound
        /// Multiple bundles were found, which should not happen
        case multipleFound
    }
    
    /// Returns the test bundle (not the application bundle)
    static var testBundle: Bundle {
        get throws(GetTestBundleError) {
            let allTestBundles = Bundle.allBundles.filter({ $0.bundlePath.hasSuffix(".xctest") })
            if allTestBundles.count > 1 {
                throw .multipleFound
            }
            guard let bundle = allTestBundles.first else {
                throw .notFound
            }
            return bundle
        }
    }
    
    // MARK: Get Test Data
    
    enum GetTestDataError: Error {
        /// The test bundle could not be found
        case bundleUnavailable(GetTestBundleError)
        /// The data was not found in the bundle
        case notFound
    }
    
    /// Retrieves data from the test bundle
    static func testData(name: String) throws(GetTestDataError) -> Data {
        let bundle = try mapError(
            for: try Self.testBundle,
            expectedType: Bundle.self,
            to: { (error: GetTestBundleError) in GetTestDataError.bundleUnavailable(error) })
        
        guard let dataAsset = NSDataAsset(name: name, bundle: bundle) else {
            throw .notFound
        }
        return dataAsset.data
    }
}
