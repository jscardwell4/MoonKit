//
//  Math.swift
//  MoonKit
//
//  Created by Jason Cardwell on 8/25/16.
//  Copyright © 2016 Jason Cardwell. All rights reserved.
//
import Foundation

/// Xor operation support for `Bool` values.
///
/// - Parameters:
///   - lhs: The left hand side.
///   - rhs: The right hand side.
/// - Returns: The xor result between `lhs` and `rhs`.
public func ^(_ lhs: Bool, _ rhs: Bool) -> Bool {
  ((lhs && !rhs) || (rhs && !lhs))
}

/// Calculates the greatest common denominator for two integers.
///
/// - Parameters:
///   - a: The first integer.
///   - b: The second integer.
/// - Returns: The least common denominator for `a` and `b`.
public func gcd<T>(_ a: T, _ b: T) -> T where T: FixedWidthInteger {
  var a = a, b = b
  while b != 0 {
    a = a % b
    swap(&a, &b)
  }
  return a
}

/// Calculates the least common multiply between two integers.
///
/// - Parameters:
///   - a: The first integer.
///   - b: The second integer.
/// - Returns: The least common multiple shared by `a` and `b`.
public func lcm<T>(_ a: T, _ b: T) -> T where T: FixedWidthInteger {
  a / gcd(a, b) * b
}

/// Whether the integer is odd.
///
/// - Parameter n: The integer to test.
/// - Returns: `true` if `n` is odd and `false` otherwise.
public func odd<I: FixedWidthInteger>(_ n: I) -> Bool { n & I(1) == I(1) }

/// Whether the integer is even.
///
/// - Parameter n: The integer to test.
/// - Returns: `true` if `n` is even and `false` otherwise.
public func even<I: FixedWidthInteger>(_ n: I) -> Bool { !odd(n) }

/// Shift-based halving
///
/// - Parameter n: The value to half.
/// - Returns: half of `n`.
public func half<T>(_ n: T) -> T where T: FixedWidthInteger { n &>> 1 }

/// Calculates the quotient and remainder for fixed width integer division.
///
/// - Parameters:
///   - a: The dividend.
///   - b: The divisor.
/// - Returns: The quotient and remainder when dividing `a` by `b`.
public func quotientRemainder<T>(_ a: T, _ b: T) -> (quotient: T, remainder: T)
  where T: FixedWidthInteger
{
  precondition(b > 0)

  guard a >= b else { return (0, a) }

  var c = b
  while a - c >= c { c = c &+ c }

  var r = a - c
  var q: T = 1

  while c != b {
    c >>= 1
    q = q + q
    if c <= r {
      r = r - c
      q = q + 1
    }
  }
  return (q, r)
}

/// Raises a value to the specified exponent using the provided closure.
///
/// - Parameters:
///   - value: The value to raise.
///   - exponent: The exponent to which `value` shall be raised. Must not be `< 1`.
///   - operation: The closure serving as the operation.
/// - Returns: The result of raising `value` to `exponent` using `operation`.
public func power<T>(value: T, exponent: Int, operation: (T, T) -> T) -> T {
  precondition(exponent > 0)
  guard exponent != 0 else { return value }

  var value = value, exponent = exponent

  while exponent & 0b1 != 0b1 {
    value = operation(value, value)
    exponent = exponent >> 1
  }

  guard exponent != 1 else { return value }

  var result = value
  value = operation(value, value)
  exponent = (exponent - 1) >> 1

  while true {
    if exponent & 0b1 == 0b1 {
      result = operation(result, value)
      guard exponent != 1 else { break }
    }
    exponent = exponent >> 1
    value = operation(value, value)
  }

  return result
}

/// Raises a value to the specified exponent using the provided closure.
///
/// - Parameters:
///   - value: The value to raise.
///   - exponent: The exponent to which `value` shall be raised. Must not be `< 0`.
///   - identity: The value for all `T` values when raised to exponent `0`.
///   - operation: The closure serving as the operation.
/// - Returns: The result of raising `value` to `exponent` using `operation`.
public func power<T>(value: T, exponent: Int, identity: T, operation: (T, T) -> T) -> T {
  precondition(exponent >= 0)

  guard exponent != 0 else { return identity }

  var value = value, exponent = abs(exponent)

  while exponent & 0b1 != 0b1 {
    value = operation(value, value)
    exponent = exponent >> 1
  }

  guard exponent != 1 else { return value }

  var result = value
  value = operation(value, value)
  exponent = (exponent - 1) >> 1

  while true {
    if exponent & 0b1 == 0b1 {
      result = operation(result, value)
      guard exponent != 1 else { break }
    }
    exponent = exponent >> 1
    value = operation(value, value)
  }

  return result
}

/// Raises a value to the specified exponent using the provided closure.
///
/// - Parameters:
///   - value: The value to raise.
///   - exponent: The exponent to which `value` shall be raised.
///   - identity: The value for all `T` values when raised to exponent `0`.
///   - inverse: Closure for inverting `value` if `exponent < 0`
///   - operation: The closure serving as the operation.
/// - Returns: The result of raising `value` (or `inverse(value)` if `exponent < 0`)
///            to `abs(exponent)` using `operation`.
public func power<T>(value: T,
                     exponent: Int,
                     identity: T,
                     inverse: (T) -> T, operation: (T, T) -> T) -> T
{
  guard exponent != 0 else { return identity }

  var value = exponent < 0 ? inverse(value) : value

  var exponent = abs(exponent)

  while exponent & 0b1 != 0b1 {
    value = operation(value, value)
    exponent = exponent >> 1
  }

  guard exponent != 1 else { return value }

  var result = value
  value = operation(value, value)
  exponent = (exponent - 1) >> 1

  while true {
    if exponent & 0b1 == 0b1 {
      result = operation(result, value)
      guard exponent != 1 else { break }
    }
    exponent = exponent >> 1
    value = operation(value, value)
  }

  return result
}

//public func log<T>(_ x: T, _ y: T, op: (T, T) -> T, stop: (T) -> Bool) -> (Int, T) {
//  var x = x, n = 0
//  while !stop(x) {
//    x = op(x, y)
//    n = n &+ 1
//  }
//  return (n, x)
//}

//public func log<T>(_ x: T, _ n: Int, identity: T, op: (T, T) -> T) -> T {
//  guard n != 0 else { return identity }
//  var x = x, n = abs(n)
//  while n & 0b1 != 0b1 { x = op(x, x); n = n >> 1 }
//  guard n != 1 else { return x }
//  var r = x
//  x = op(x, x)
//  n = (n - 1) >> 1
//  while true {
//    if n & 0b1 == 0b1 {
//      r = op(r, x)
//      guard n != 1 else { return r }
//    }
//    n = n >> 1
//    x = op(x, x)
//  }
//}

//public func log<T>(_ x: T, _ n: Int, identity: T, inverse: (T) -> T, op: (T, T) -> T) -> T {
//  guard n != 0 else { return identity }
//  var x = n < 0 ? inverse(x) : x, n = abs(n)
//  while n & 0b1 != 0b1 { x = op(x, x); n = n >> 1 }
//  guard n != 1 else { return x }
//  var r = x
//  x = op(x, x)
//  n = (n - 1) >> 1
//  while true {
//    if n & 0b1 == 0b1 {
//      r = op(r, x)
//      guard n != 1 else { return r }
//    }
//    n = n >> 1
//    x = op(x, x)
//  }
//}

/// Calculates the double-width multiplication of two fixed width, unsigned integers.
/// - Parameters:
///   - lhs: The first multiplicand.
///   - rhs: The second multiplicand.
/// - Returns: The double-width result of multiplying `lhs` by `rhs`.
public func doubleWidthMultiply<T>(_ lhs: T, _ rhs: T) -> (high: T, low: T)
  where T: FixedWidthInteger, T: UnsignedInteger
{
  let bitWidth = T.bitWidth
  let halfBitWidth = bitWidth / 2

  let mask = T.max >> halfBitWidth

  let pLL = (lhs & mask) * (rhs & mask)
  let pLH = (lhs & mask) * (rhs >> halfBitWidth)

  let pHL = (lhs >> halfBitWidth) * (rhs & mask)
  let pHH = (lhs >> halfBitWidth) * (rhs >> halfBitWidth)

  var low = pLL & mask
  var carry = (pLL >> halfBitWidth) &+ (pLH & mask)
  var high = carry >> halfBitWidth

  carry = (carry & mask) &+ (pHL & mask)
  high = high &+ (carry >> halfBitWidth)
  low |= carry << halfBitWidth

  high = high &+ (pLH >> halfBitWidth)
  carry = high >> halfBitWidth

  high &= mask
  high = high &+ (pHL >> halfBitWidth) &+ pHH &+ carry

  return (high, low)
}
