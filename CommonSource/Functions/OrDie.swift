//
//  Helpers.swift
//  MoonKit
//
//  Created by Jason Cardwell on 1/19/18.
//  Copyright © 2018 Moondeer Studios. All rights reserved.
//
import Foundation

/// When you absolutely, positively must succeed.
///
/// - Warning: This function is designed to halt execution should `block`
///            throw an error.
///
/// - Parameters:
///   - fileID: Static string capturing `#fileID`.
///   - function: Static string capturing `#function`.
///   - message: An optional message to include in log statements.
///   - block: The closure that must be performed.
/// - Returns: The result of invoking `block`.
public func tryOrDie<T>(fileID: StaticString = #fileID,
                       function: StaticString = #function,
                       message: String? = nil,
                       block: () throws -> T) -> T
{
  do {
    return try block()
  } catch {
    let message = """
      \(fileID) \(function) \
      \(message ?? "Fatal error encountered"): \(error)
      """
    loge(message)
    fatalError(message)
  }
}


/// When you absolutely, positively must produce an unwrapped optional.
///
/// - Warning: This function is designed to halt execution should `block`
///            produce a `nil` value.
///
/// - Parameters:
///   - fileID: Static string capturing `#fileID`.
///   - function: Static string capturing `#function`.
///   - message: An optional message to include in log statements.
///   - block: The closure that must produce a non-nil value.
/// - Returns: The unwrapped result produced by invoking `block`.
public func unwrapOrDie<T>(fileID: StaticString = #fileID,
                           function: StaticString = #function,
                           message: String? = nil,
                           block: () -> T?) -> T
{
  guard let value = block() else {
    let message = """
      \(fileID) \(function) \
      \(message ?? "Unexpected `nil` value."))
      """
    loge(message)
    fatalError(message)
  }
  return value
}

/// When you absolutely, positively must produce an unwrapped optional.
///
/// - Warning: This function is designed to halt execution should `block`
///            produce a `nil` value.
///
/// - Parameters:
///   - fileID: Static string capturing `#fileID`.
///   - function: Static string capturing `#function`.
///   - message: An optional message to include in log statements.
///   - value: The value that must be unwrapped.
/// - Returns: The unwrapped optional value.
public func unwrapOrDie<T>(fileID: StaticString = #fileID,
                           function: StaticString = #function,
                           message: String? = nil,
                           _ value: T?) -> T
{
  unwrapOrDie(fileID: fileID, function: function, message: message, block: {value})
}


