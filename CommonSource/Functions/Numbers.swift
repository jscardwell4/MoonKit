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

/// Returns the nearest power of 2 greater than or equal to a specified integer value.
/// 
/// - Parameter value: The integer value containing the minimum value required.
/// - Returns: A power of 2 guaranteed to be ≥ `value`.
public func round2(_ value: Int) -> Int {
  Int(exp2(ceil(log2(max(0, Double(value))))))
}

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

/// Converts the fractional portion of a floating point number into an array of
/// its digits.
///
/// - Parameter value: The value with a fractional part to convert to digits.
/// - Returns: The base 10 digits of the fractional part of `value`.
public func fractionalDigits<F>(_ value: F) -> [UInt8]
where F:BinaryFloatingPoint, F:LosslessStringConvertible
{
  guard !(value.isNaN || value.isInfinite) else { return [] }
  guard !value.isZero else { return [0] }

  // Trim away the integer part.
//  let fractional = value - value.rounded(.towardZero)

  // Find the decimal or `value` is already an integer.
  // Capture the magnitude as a string to trim floating point garbage.
  let string = "\(value.magnitude)".split(separator: ".")[1]

  var digits: [UInt8] = []

  for character in string {
    guard let digit = UInt8(String(character)) else { continue }
    digits.append(digit)
  }

  return digits
}
