//
//  Numbers.swift
//  MoonKit
//
//  Created by Jason Cardwell on 5/14/15.
//  Copyright (c) 2015 Jason Cardwell. All rights reserved.
//

import Foundation
import UIKit
import Darwin

/// Multiplies a floating point value by a power of ten to remove the decimal place.
///
/// - Parameter value: The floating point value to convert.
/// - Returns: A tuple holding the new value and the power of ten.
public func integerize<F>(_ value: F) -> (integer: F, exponent: Int)
where F:FloatingPoint, F:LosslessStringConvertible
{

  // Capture the magnitude as a string to trim floating point garbage.
  let string = "\(value.magnitude)"

  // Find the decimal or `value` is already an integer.
  guard let decimal = string.firstIndex(of: ".") else {
    return (value, 0)
  }

  // Calculate the power of ten by which to multiply `value`.
  let powerOfTen = string.distance(from: string.index(after: decimal),
                                   to: string.endIndex)

  // Create a mutable copy of `value`.
  var result = value

  // Multiply away the decimal point.
  for _ in 0..<powerOfTen { result *= 10 }

  // Round to trim floating point garbage.
  result.round()

  return (result, powerOfTen)

}

/// Converts a fixed width integer into an array of its digits.
///
/// - Parameter value: The value to convert to digits.
/// - Returns: The base 10 digits of `value`.
public func decimalDigits<I>(_ value: I) -> [UInt8] where I:FixedWidthInteger {
  var result: [UInt8] = []
  var value = value
  repeat {
    let r = UInt8(value % 10)
    value /= 10
    result.append(r)
  } while value > 0
  result.reverse()
  return result
}

/// Converts a floating point value into decimal digits, separating the integer
/// digits from the fractional digits.
///
/// - Parameter value: The value with a fractional part to convert to digits.
/// - Returns: A tuple of the base 10 digits of `value`.
public func decimalDigits<F>(_ value: F) -> (integer: [UInt8], fractional: [UInt8])
where F:BinaryFloatingPoint//, F:LosslessStringConvertible
{
  guard !(value.isNaN || value.isInfinite) else { return ([], []) }
  guard !value.isZero else { return ([0], []) }

  // Capture the magnitude as a string to trim floating point garbage.
  let strings = "\(value.magnitude)".split(separator: ".")

  var integer: [UInt8] = [], fractional: [UInt8] = []

  for character in strings[0] {
    guard let digit = UInt8(String(character)) else { continue }
    integer.append(digit)
  }

  for character in strings[1] {
    guard let digit = UInt8(String(character)) else { continue }
    fractional.append(digit)
  }

  return (integer, fractional)
}
