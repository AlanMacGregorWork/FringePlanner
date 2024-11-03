//
//  General.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 03/11/2024.
//

// Denotes general helper functions that do not have their own container

// MARK: Error

/// Maps an error to a new error type
/// - Note: Currently Swift will not be able to identify the `InputError` if a closure is being
/// used (i.e. if you are not using the auto closure), doing so will mean the `Output` will be of the
/// `input` closure rather that the value inside of the closure. To ensure this does not accidentally
/// return the wrong type at compile time, the expectedType must be filled.
func mapError<InputError, OutputError, Output>(
    for input: @autoclosure (() throws(InputError) -> Output),
    expectedType: Output.Type,
    to newError: ((InputError) -> OutputError)
) throws(OutputError) -> Output {
    do {
        return try input()
    } catch {
        throw newError(error)
    }
}
