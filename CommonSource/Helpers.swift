//
//  Helpers.swift
//  MoonKit
//
//  Created by Jason Cardwell on 1/19/18.
//  Copyright © 2018 Moondeer Studios. All rights reserved.
//
import Foundation

public func tryOrDie<T>(_ block: () throws -> T, message: String? = nil) -> T {

  do {
    return try block()
  } catch {
    let messageʹ = "\(message ?? "Fatal error.") Error: \(error.localizedDescription)"
    loge(messageʹ)
    fatalError(messageʹ)
  }

}

public func nonNilOrDie<T>(_ block: () -> T?, message: String? = nil) -> T {
  guard let value = block() else {
    let messageʹ = "\(message ?? "Fatal error.") Error: unexpected `nil` value."
    loge(messageʹ)
    fatalError(messageʹ)
  }
  return value
}

public func nonNilOrDie<T>(_ value: T?, message: String? = nil) -> T {
  guard let value = value else {
    let messageʹ = "\(message ?? "Fatal error.") Error: unexpected `nil` value."
    loge(messageʹ)
    fatalError(messageʹ)
  }
  return value
}

postfix operator ‽

public postfix func ‽<T>(block: () throws -> T) -> T { return tryOrDie(block) }

public postfix func ‽<T>(block: () -> T?) -> T { return nonNilOrDie(block) }

public postfix func ‽<T>(_ value: T?) -> T { return nonNilOrDie(value) }

/*

 The following lead to segmentation faults in the compiler.

public postfix func ‽<T>(block: (() throws -> T, String)) -> T {
  return tryOrDie(block.0, message: block.1)
}

public postfix func ‽<T>(block: (() -> T?, String)) -> T {
  return nonNilOrDie(block.0, message: block.1)
}

public postfix func ‽<T>(_ value: (T?, String)) -> T {
  return nonNilOrDie(value.0, message: value.1)
}

 */
