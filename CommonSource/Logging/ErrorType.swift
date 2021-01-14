//
//  ErrorType.swift
//  MoonKit
//
//  Created by Jason Cardwell on 1/21/16.
//  Copyright © 2016 Jason Cardwell. All rights reserved.
//

import Foundation

public extension Error where Self:RawRepresentable, Self.RawValue == String {
  var description: String { return rawValue }
}

public protocol ErrorWrapper: Error {
  var underlyingError: Error? { get }
}

public protocol SourcedError: LocalizedError, CustomStringConvertible {

  var line: UInt { get }
  var function: String { get }
  var file: String { get }
  var errorDescription: String { get }
  
}

public extension SourcedError {

  var errorDescription: String {
    return "\(errorDescription ?? "error") <\(file.lastPathComponent):\(line)> \(function)"
  }

}

public struct ErrorMessage: LocalizedError {


  /// A localized message describing what error occurred.
  public var errorDescription: String

  /// A localized message describing the reason for the failure.
  public var failureReason: String

  /// A localized message describing how one might recover from the failure.
  public var recoverySuggestion: String?

  /// A localized message providing "help" text if the user requests help.
  public var helpAnchor: String?

  public init(errorDescription: String, failureReason: String) {
    self.errorDescription = errorDescription
    self.failureReason = failureReason
  }

}
