//
//  fringeAssert.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 15/11/2024.
//

/// Custom assertion for the application
func fringeAssertFailure(
    _ message: @autoclosure () -> String,
    file: StaticString = #file,
    line: UInt = #line
) {
    fringeAssert(false, message(), file: file, line: line)
}

/// Custom assertion for the application
func fringeAssert(
    _ condition: @autoclosure () -> Bool,
    _ message: @autoclosure () -> String,
    file: StaticString = #file,
    line: UInt = #line
) {
    // Only assert if not testing
    // Note: Several tests verify the outcome of invalid states which would normally assert
    switch ApplicationEnvironment.current {
    case .testingUI, .testingUnit, .preview: return
    case .normal: break
    }
    
    // Trigger the assert as normal
    assert(condition(), message(), file: file, line: line)
}
