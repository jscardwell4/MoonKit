//
//  Math.swift
//  MoonKit
//
//  Created by Jason Cardwell on 8/25/16.
//  Copyright © 2016 Jason Cardwell. All rights reserved.
//
import Foundation

/// Returns the nearest power of 2 greater than or equal to a specified integer value.
///
/// - Parameter value: The integer value containing the minimum value required.
/// - Returns: A power of 2 guaranteed to be ≥ `value`.
public func round2(_ value: Int) -> Int {
  Int(exp2(ceil(log2(max(0, Double(value))))))
}

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

/// Calculates the quotient and remainder for fixed width unsigned integer division.
///
/// - Parameters:
///   - dividend: The dividend.
///   - divisor: The divisor.
/// - Returns: The quotient and remainder when dividing `a` by `b`.
public func quotientAndRemainder<I>(dividend: I, divisor: I) -> (quotient: I,
                                                                 remainder: I)
  where I: FixedWidthInteger, I: UnsignedInteger
{
  // Determine how many leading zeroes there are in the dividend.
  let dividendBits = I.bitWidth - dividend.leadingZeroBitCount

  // Determine the minimum number of bits required per subtraction.
  let divisorBits = I.bitWidth - divisor.leadingZeroBitCount

  // Determine the total number of shifts that will be performed during the calculation.
  var shiftsRequired = dividendBits - divisorBits + 1

  // Initialize the remainder with the shifted high bits.
  var remainder = dividend

  // Calculate the actual shift required for the next subtraction.
  var currentShift = I.bitWidth - remainder.leadingZeroBitCount - divisorBits

  // Initialize the quotient.
  var quotient: I = 0

  repeat {
    // Get the value from which to subtract this round.
    let minuend = remainder >> currentShift

    // Determine whether the quotient bit will be `1` or `0`.
    let bit = divisor < minuend ? 1 as I : 0

    // Determine the value being subtracted.
    let subtrahend = divisor * bit

    // Subtract `subtrahend` from `minuend`.
    let difference = minuend - subtrahend

    // Slide the quotient over and insert the bit for this round.
    quotient = (quotient << 1) | bit

    // Clear out the corresponding bits of the remainder for this subtraction.
    remainder &= I.max >> (I.bitWidth - currentShift)

    // Insert the bits for `difference`.
    remainder |= difference << currentShift

    // Decrement the shift counters.
    shiftsRequired -= 1
    currentShift -= 1

  } while shiftsRequired > 0

  // Ensure there isn't one left in the chamber.
  if remainder >= divisor {
    // Subtract the `divisor`.
    remainder -= divisor

    // For the final digit we can simply add `1`.
    quotient += 1
  }

  // Return the calculated quotient and remainder.
  return (quotient: quotient, remainder: remainder)
}

/// Returns a tuple containing the quotient and remainder obtained by dividing
/// the given value by this value.
///
/// The resulting quotient must be representable within the bounds of the
/// type. If the quotient is too large to represent in the type, a runtime
/// error may occur.
///
/// The following example divides a value that is too large to be represented
/// using a single `UInt` instance by another `UInt` value. Because the quotient
/// is representable as an `UInt`, the division succeeds.
///
///     // 'dividend' represents the value 0x506f70652053616e74612049494949
///     let dividend = (22640526660490081 as UInt, 7959093232766896457 as UInt)
///     let divisor = 2241543570477705381 as UInt
///
///     let (quotient, remainder) = divisor.dividingFullWidth(dividend)
///     // quotient == 186319822866995413
///     // remainder == 0
///
///
/// - Parameters:
///   - dividend: A tuple containing the high and low parts of a double-width integer.
///   - divisor: The value by which to divide `dividend`.
/// - Returns: A tuple containing the quotient and remainder obtained by
///            dividing `dividend` by this value.
public func quotientAndRemainder<I>(dividend: (high: I, low: I),
                                    divisor: I) -> (quotient: I, remainder: I)
  where I: FixedWidthInteger, I: UnsignedInteger
{
  // Determine how many leading zeroes there are in the dividend.
  let dividendBits = dividend.high == 0
    ? I.bitWidth - dividend.low.leadingZeroBitCount
    : I.bitWidth * 2 - dividend.high.leadingZeroBitCount

  // Determine the minimum number of bits required per subtraction.
  let divisorBits = I.bitWidth - divisor.leadingZeroBitCount

  // Determine the total number of shifts that will be performed during the calculation.
  var shiftsRequired = dividendBits - divisorBits + 1

  // Determine how many bits from the lower register we have room for.
  let movedBitCount = dividend.high.leadingZeroBitCount

  // Initialize the remainder with the shifted high bits.
  var remainder = (dividend.high << movedBitCount)

  // Move over the lower register bits.
  remainder |= (dividend.low >> (I.bitWidth - movedBitCount))

  // Keep track of the remaining bits of the lower register.
  var lowBitsRemaining = I.bitWidth - movedBitCount
  var lowʹ = dividend.low << movedBitCount

  // Calculate the actual shift required for the next subtraction.
  var currentShift = I.bitWidth - remainder.leadingZeroBitCount - divisorBits

  // Initialize the quotient.
  var quotient: I = 0

  repeat {
    // Get the value from which to subtract this round.
    let minuend = remainder >> currentShift

    // Determine whether the quotient bit will be `1` or `0`.
    let bit = divisor < minuend ? 1 as I : 0

    // Determine the value being subtracted.
    let subtrahend = divisor * bit

    // Subtract `subtrahend` from `minuend`.
    let difference = minuend - subtrahend

    // Slide the quotient over and insert the bit for this round.
    quotient = (quotient << 1) | bit

    // Clear out the corresponding bits of the remainder for this subtraction.
    remainder &= I.max >> (I.bitWidth - currentShift)

    // Insert the bits for `difference`.
    remainder |= difference << currentShift

    // Decrement the shift counters.
    shiftsRequired -= 1
    currentShift -= 1

    // Do lower register bits require moving and is there room to move them?
    if lowBitsRemaining > 0, remainder.leadingZeroBitCount > 0 {
      // Move over as many as will currently fit in `remainder`.
      let currentRoom = min(remainder.leadingZeroBitCount, lowBitsRemaining)

      // Shift to make room for the moved bits.
      remainder <<= currentRoom

      // Move the bits over to `remainder`.
      remainder |= lowʹ >> (I.bitWidth - currentRoom)

      // Clear the bits out of the lower register.
      lowʹ <<= currentRoom

      // Decrement the lower register bit count remaining.
      lowBitsRemaining -= currentRoom

      // Increment the current shift to accomodate the moved bits.
      currentShift += currentRoom
    }

  } while shiftsRequired > 0

  // Ensure there isn't one left in the chamber.
  if remainder >= divisor {
    // Subtract the `divisor`.
    remainder -= divisor

    // For the final digit we can simply add `1`.
    quotient += 1
  }

  // Return the calculated quotient and remainder.
  return (quotient: quotient, remainder: remainder)
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

/// Calculates the double-width multiplication of two fixed width, unsigned integers.
/// - Parameters:
///   - lhs: The first multiplicand.
///   - rhs: The second multiplicand.
/// - Returns: The double-width result of multiplying `lhs` by `rhs`.
public func doubleWidthMultiply<I>(_ lhs: I, _ rhs: I) -> (high: I, low: I)
  where I: FixedWidthInteger, I: UnsignedInteger
{
  let bitWidth = I.bitWidth
  let halfBitWidth = bitWidth / 2

  let mask = I.max >> halfBitWidth

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
