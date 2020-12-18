//
//  Fraction.swift
//  MoonKit
//
//  Created by Jason Cardwell on 8/4/16.
//  Copyright © 2016 Jason Cardwell. All rights reserved.
//

import Foundation
import struct UIKit.CGFloat

// MARK: - Helper variables and functions

private let powersOfTen = OrderedSet<UInt128>((0...38).map({pow10($0)}))

/// Splits a value interpretted as a fractional numerator over a power of ten denominator into non-repeating 
/// and repeating digits.
///
/// - parameter fractionalNumerator: The value to serve as the numerator.
/// - parameter exponent:  The power of ten to serve as the denominator.
///
/// - returns: A tuple an array of the non-repeating fractional digits
///            and an array of the repeating fractional digits
private func split(fractionalNumerator: UInt128, exponent: Int) -> (nonrepeating: [UInt8], repeating: [UInt8]) {
  let digits = fractionalNumerator.digits()
  let zeroPadding = Array<UInt8>(repeating: 0, count: exponent - digits.count)

  return split(fractionalNumerator: zeroPadding + digits)
}

/// Splits a value interpretted as a fractional numerator over a power of ten denominator into non-repeating 
/// and repeating digits.
///
/// - parameter digits: The digits that make up the numerator.
///
/// - returns: A tuple an array of the non-repeating fractional digits
///            and an array of the repeating fractional digits
private func split(fractionalNumerator digits: [UInt8]) -> (nonrepeating: [UInt8], repeating: [UInt8]) {
  guard !digits.isEmpty  else { return ([], []) }
  for (offset, maxPeriodLength) in [(0, 8),
                                    (1, 7), (2, 7),
                                    (3, 6), (4, 6),
                                    (5, 5), (6, 5),
                                    (7, 4), (8, 4),
                                    (9, 3), (10, 3),
                                    (11, 2), (12, 2),
                                    (13, 1), (14, 1)]
  {
    Period: for periodLength in 1...maxPeriodLength {
      var i = offset, j = offset &+ periodLength

      // Check that there are enough digits for two complete cycles of `periodLength`
      guard digits.endIndex &- j >= periodLength else { continue }

      Slice: while i < digits.endIndex /*&& j < value.endIndex*/ {
        // Compare the two slices for equality
        let iʹ = min(i &+ periodLength, digits.endIndex), jʹ = min(j &+ periodLength, digits.endIndex)
        for (x, y) in zip(digits[i..<iʹ], digits[j..<jʹ]) where x != y { break Slice }
        i = iʹ; j = jʹ
      }

      // Check that the loop exited early otherwise a pattern has been found
      guard i < digits.endIndex /*&& j < value.endIndex*/ else {
        return (Array(digits[0..<offset]), Array(digits[offset..<(offset &+ periodLength)]))
      }
    }

  }

  // No pattern detected, return all the digits as `nonrepeating`
  return (digits, [])
}

/// Splits a value interpretted as a numerator over a power of ten denominator into its integer and fractional parts.
///
/// - parameter numerator: The value to serve as the numerator.
/// - parameter exponent:  The power of ten to serve as the denominator.
///
/// - returns: A tuple with the integer, an array of the non-repeating fractional digits
///            and an array of the repeating fractional digits
private func split(numerator: UInt128, exponent: Int) -> (integer: UInt128, nonrepeating: [UInt8], repeating: [UInt8]) {
  guard numerator > 0 else { return (0, [], []) }
  let denominator = pow10(abs(exponent))
  let integer = numerator / denominator
  let fractional = numerator - integer * denominator
  let (nonrepeating, repeating) = split(fractionalNumerator: fractional, exponent: log10(denominator).value)
  return (integer, nonrepeating, repeating)
}

private struct Partial: Hashable {
  var q: UInt128
  var r: UInt128
  init(_ q: UInt128, _ r: UInt128) {
    self.q = q
    self.r = r
  }
  init(_ tuple: (quotient: UInt128, remainder: UInt128)) {
    q = tuple.quotient
    r = tuple.remainder
  }
}

// MARK: - Initializing with global operators

public func ╱<I:ExpressibleByIntegerLiteral>(lhs: I, rhs: I) -> Fraction {
  switch (lhs, rhs) {
    case let (lhs as UInt128, rhs as UInt128): return Fraction(numerator: lhs,            denominator: rhs)
    case let (lhs as Int64,   rhs as Int64):   return Fraction(numerator: lhs,            denominator: rhs)
    case let (lhs as Int32,   rhs as Int32):   return Fraction(numerator: Int64(lhs),     denominator: Int64(rhs))
    case let (lhs as Int16,   rhs as Int16):   return Fraction(numerator: Int64(lhs),     denominator: Int64(rhs))
    case let (lhs as Int8,    rhs as Int8):    return Fraction(numerator: Int64(lhs),     denominator: Int64(rhs))
    case let (lhs as UInt64,  rhs as UInt64):  return Fraction(numerator: UInt128(lhs),   denominator: UInt128(rhs))
    case let (lhs as UInt32,  rhs as UInt32):  return Fraction(numerator: UInt128(lhs),   denominator: UInt128(rhs))
    case let (lhs as UInt16,  rhs as UInt16):  return Fraction(numerator: UInt128(lhs),   denominator: UInt128(rhs))
    case let (lhs as UInt8,   rhs as UInt8):   return Fraction(numerator: UInt128(lhs),   denominator: UInt128(rhs))
    default:                                   return .zero //Fraction(numerator: lhs.toIntMax(), denominator: rhs.toIntMax())
  }
}
public func ÷<I:ExpressibleByIntegerLiteral>(lhs: I, rhs: I) -> Fraction { return lhs╱rhs }

public func ╱(lhs: Int64, rhs: Int64) -> Fraction { return Fraction(numerator: lhs, denominator: rhs) }
public func ÷(lhs: Int64, rhs: Int64) -> Fraction { return lhs╱rhs }

// MARK: - Fraction declaration
public struct Fraction {

  // MARK: Nested types
  fileprivate struct Flags: OptionSet, CustomStringConvertible {
    let rawValue: UInt8

    static let isNaN       = Flags(rawValue: 0b00000001)
    static let isSignaling = Flags(rawValue: 0b00000011)
    static let isReduced   = Flags(rawValue: 0b00000100)
    static let isInfinite  = Flags(rawValue: 0b00001000)
    static let isRepeating = Flags(rawValue: 0b00010000)
    static let isNegative  = Flags(rawValue: 0b10000000)

    var sign: FloatingPointSign { return contains(.isNegative) ? .minus : .plus }

    mutating func toggleSign() {
      switch sign {
        case .minus: remove(.isNegative)
        case .plus: insert(.isNegative)
      }
    }

    var description: String {
      var flags: [String] = []
      if self ∋ .isSignaling { flags += ["isNaN", "isSignaling"] }
      else if self ∋ .isNaN { flags.append("isNaN") }
      if self ∋ .isReduced { flags.append("isReduced") }
      if self ∋ .isInfinite { flags.append("isInfinite") }
      if self ∋ .isRepeating { flags.append("isRepeating") }
      if self ∋ .isNegative { flags.append("isNegative") }
      return "[\(flags.joined(separator: ", "))]"
    }
  }

  // MARK: Stored properties
  public fileprivate(set) var numerator: UInt128
  public fileprivate(set) var denominator: UInt128
  fileprivate var flags: Flags

  // MARK: Computed properties

  public static var zero: Fraction { return Fraction() }

  public var isDecimal:      Bool { return powersOfTen.contains(denominator)               }
  public var isImproper:     Bool { return isNormal && numerator > denominator             }
  public var isProper:       Bool { return (isNormal || isZero) && numerator < denominator }
  public var isReduced:      Bool { return flags ∋ .isReduced                              }
  public var isRepeating:    Bool { return flags ∋ .isRepeating                            }

  public var integerPart: UInt128 { return parts.integer }
  public var fractionalPart: Fraction { return parts.fractional }

  public var reciprocal: Fraction {
    guard !isNaN else { return self }
    guard !isInfinite else { return Fraction(signOf: self, magnitudeOf: Fraction.zero) }
    guard !isZero else { return Fraction(signOf: self, magnitudeOf: Fraction.infinity) }
    return Fraction(sign: sign, numerator: denominator, denominator: numerator)
  }

   /// The fraction as a decimal with an integer part and a fractional part
  public var parts: (integer: UInt128, fractional: Fraction) {
    guard isImproper else { return (0, self) }
    let integerPart = numerator / denominator
    let fractionalPart = Fraction(sign: sign, magnitude: (numerator - integerPart * denominator)╱denominator)
    return (integerPart, fractionalPart)
  }

  public var unitFraction: Fraction { return 1╱denominator }

  /// The fraction converted into decimal form. i.e. The denominator is a power of 10.
  public var decimalForm: Fraction {
    guard flags.intersection([.isNaN, .isInfinite]).isEmpty else { return self }
    guard numerator > 0 else { return Fraction(sign: sign, magnitude: Fraction.zero) }
    guard !powersOfTen.contains(denominator) else { return self }

    var partial = Partial(numerator.quotientAndRemainder(dividingBy: denominator))
    guard partial.r > 0 else { return Fraction(sign: sign, numerator: partial.q, denominator: 1) }


    let pad = partial.q == 0 ? 0 : log10(partial.q).value &+ 1
    var partials: OrderedSet<AnyHashable> = []
    var fractional: Queue<UInt128> = []

    let integer = partial.q

    for i in 0..<(38 &- pad) {
      partial.r *= 10
      while partial.r < denominator {
        partial.r *= 10
        fractional.enqueue(0)
        partials.insert(AnyHashable(i)) // Add a spacer to maintain index accuracy
      }
      partial = Partial(partial.r.quotientAndRemainder(dividingBy: denominator))

      guard partial.r > 0 else {
        fractional.enqueue(partial.q)
        return Fraction(sign: sign, integer: integer, nonrepeating: fractional.map({UInt8($0.low)}), repeating: [])
      }

      switch partials.index(of: partial) {
      case let idx?:
        return Fraction(sign: sign,
                        integer: integer,
                        nonrepeating: idx == 0 ? [] : fractional.dequeue(count: idx).map({UInt8($0.low)}),
                        repeating: fractional.map({UInt8($0.low)}))
      default:
        fractional.enqueue(partial.q)
        partials.insert(AnyHashable(partial))
      }

    }

    return Fraction(sign: sign, integer: integer, nonrepeating: fractional.map({UInt8($0.low)}), repeating: [])
  }

  // MARK: Reducing/rebasing fractions

  public func reduced() -> Fraction {
    guard !isReduced else { return self }
    var result = self
    result.reduce()
    return result
  }

  public mutating func reduce() {
    guard isFinite && !isZero && !isReduced else { return }

    if isRepeating {
      let decimalForm = self.decimalForm
      let (integer, nonrepeating, repeating) = split(numerator: decimalForm.numerator, exponent: Swift.abs(Int(decimalForm.exponent)))
      switch (nonrepeating.count, repeating.count) {
        case (_, 0):
          break
        case (0, _):
          denominator = repeating.reduce(0){ $0.0 * 10 + 9 }
          numerator = UInt128(digits: repeating) + integer * denominator
        default:
          let nOnly = UInt128(digits: nonrepeating)
          let nAndR = UInt128(digits: nonrepeating + repeating)
          denominator = repeating.reduce(0){ $0.0 * 10 + 9 } * powersOfTen[nonrepeating.count]
          numerator = nAndR - nOnly + integer * denominator
      }
    }

    let divisor = gcd(numerator, denominator)
    numerator /= divisor
    denominator /= divisor
    flags.insert(.isReduced)
  }

  public func fractionWithBase(_ base: UInt128) -> Fraction {
    guard base != denominator else { return self }
    let numeratorʹ = base < denominator ? numerator / denominator / base : numerator * base / denominator
    return Fraction(sign: sign, numerator: numeratorʹ, denominator: base)
  }

  // MARK: Private initializers
  fileprivate init(numerator: Int64, denominator: Int64) {
    self = Fraction(sign: (numerator < 0) ^ (denominator < 0) ? .minus : .plus,
                    numerator: UInt128(Swift.abs(numerator)),
                    denominator: UInt128(Swift.abs(denominator)))
  }

  /// Initializer that allows for specifying a value's `flags` property directly.
  ///
  /// - parameter numerator:   The numerator for this value.
  /// - parameter denominator: The denominator for this value.
  /// - parameter flags:       The flags for this value.
  fileprivate init(numerator: UInt128 = 0, denominator: UInt128 = 1, flags: Flags) {
    self.numerator = numerator
    self.denominator = denominator
    self.flags = flags
  }

  // MARK: Public initializers
  /// Creates a value initialized to zero.
  public init(){ numerator = 0; denominator = 1; flags = [] }

  /// Default initializer for creating a `Fraction`.
  ///
  /// - parameter sign:   Denote's whether the fraction is postive or negative.
  /// - parameter n:      The fraction's numerator.
  /// - parameter d:      The fraction's denominator.
  /// - parameter reduce: Indicates whether the fraction should be reduced after initialization.
  public init(sign: FloatingPointSign = .plus, numerator: UInt128, denominator: UInt128) {
    self.numerator = numerator
    self.denominator = denominator
    flags = sign == .minus ? [.isNegative] : []
    if denominator == 0 { flags.insert(.isInfinite) }
  }

  /// Creates a value initialized as a NaN.
  ///
  /// - parameter payload:   Additional information carried by the NaN.
  /// - parameter signaling: Whether the fraction is a 'Signaling NaN' or a 'Quit NaN'.
  public init(nan payload: UInt128, signaling: Bool) {
    numerator = payload
    denominator = 1
    flags = signaling ? [.isSignaling] : [.isNaN]
  }

  /// Creates a value by specifying the sign and magnitude of the fraction.
  ///
  /// - parameter sign:      Whether the value is positive or negative.
  /// - parameter magnitude: The weight of the value without regard for its sign.
  public init(sign: FloatingPointSign, magnitude: Fraction) {
    flags = sign == .minus ? [.isNegative] : []
    if magnitude.isInfinite { flags.insert(.isInfinite) }
    if magnitude.isNaN { flags.insert(.isNaN) }
    numerator = magnitude.numerator
    denominator = magnitude.denominator
  }

  // Initializing from one of the standard library/Foundation floating point types.

  public init(_ value: Float)   { self = Fraction(Double(value)) }
  public init(_ value: CGFloat) { self = Fraction(Double(value)) }

  /// The default initializer for full width conversion from a floating point type to a fraction. For normal values the
  /// resulting fraction will be in decimal form unless `reduce` is `true`, in which case an attempt will be made to
  /// reduce the fraction down from it's decimal form.
  ///
  /// - parameter value:  The value to be converted into a fraction
  /// - parameter reduce: Whether the fraction should be reduced before returning.
  public init(_ value: Double)  {
    guard !value.isSignalingNaN else {
      self = Fraction(nan: UInt128(value.significandBitPattern & ~(UInt64(1) << 50)), signaling: true)
      return
    }
    guard !value.isNaN else { self = Fraction(nan: 0, signaling: false); return }
    guard !value.isInfinite else { self = Fraction(sign: value.sign, magnitude: Fraction.infinity); return }

    let integer: Double = Swift.abs(value).rounded(.towardZero)
    var numerator = UInt128(integer)
    let fractional = Swift.abs(value) - integer
    let digits = Array(fractional.digits().prefix(15))

    let fractionalParts = split(fractionalNumerator: digits)
    if !fractionalParts.repeating.isEmpty {
      // The decimal has a repeating pattern

      let fractionalValue = UInt128(digits: (fractionalParts.nonrepeating + fractionalParts.repeating))
      let nonrepeatingValue = UInt128(digits: fractionalParts.nonrepeating)

      let numeratorʹ = fractionalValue &- nonrepeatingValue
      var denominator: UInt128 = 0
      for _ in 0..<fractionalParts.repeating.count { denominator = denominator * 10 &+ 9 }
      for _ in 0..<fractionalParts.nonrepeating.count { denominator = denominator * 10 }
      numerator *= denominator
      numerator += numeratorʹ
      self = Fraction(sign: value.sign, numerator: numerator, denominator: denominator)
      flags.insert(.isRepeating)

    } else {
      // The decimal terminates or does not have a repeating pattern

      let denominator = pow(UInt128(10), digits.count)
      numerator *= denominator
      numerator += UInt128(digits: digits)
      self = Fraction(sign: value.sign, numerator: numerator, denominator: denominator)

    }

    reduce()

  }

  /// Full width conversion from a `Decimal` to a fraction. The maximum value of both `Double` and `Decimal` are well
  /// above that of `Fraction`; however, there may be some degree of increased precision in converting from a `Decimal`
  /// value versus a `Double` value. The fraction will be in decimal form unless `reduce` is `true`, in which case an 
  /// attempt will be made to reduce the fraction down from it's decimal form.
  ///
  /// - parameter value:  The value to be converted into a fraction
  /// - parameter reduce: Whether the fraction should be reduced before returning.
  public init(_ value: Decimal) {

    guard !value.isSignalingNaN else {
      self = Fraction(nan: UInt128((value as NSDecimalNumber).doubleValue.significandBitPattern & ~(UInt64(1) << 50)),
                      signaling: true)
      return
    }
    guard !value.isNaN else { self = Fraction(nan: 0, signaling: false); return }
    guard !value.isInfinite else { self = Fraction(sign: value.sign, magnitude: Fraction.infinity); return }

    let valueʹ = abs(value)

    let decimalHandler = NSDecimalNumberHandler(roundingMode: .down,
                                                scale: 0,
                                                raiseOnExactness: false,
                                                raiseOnOverflow: false,
                                                raiseOnUnderflow: false,
                                                raiseOnDivideByZero: false)

    let integer = (valueʹ as NSDecimalNumber).rounding(accordingToBehavior: decimalHandler).decimalValue
    let fractional = valueʹ - integer

    var numerator = UInt128(integer)

    let digits = fractional.digits()

    let (nonrepeating, repeating) = split(fractionalNumerator: digits)
    if !repeating.isEmpty {
      // The decimal has a repeating pattern

      let fractionalValue = UInt128(digits: (nonrepeating + repeating))
      let nonrepeatingValue = UInt128(digits: nonrepeating)

      let numeratorʹ = fractionalValue &- nonrepeatingValue
      let denominatorDigits = Array<UInt8>(repeating: 9, count: repeating.count)
                            + Array<UInt8>(repeating: 0, count: nonrepeating.count)
      let denominator: UInt128 = UInt128(digits: denominatorDigits)
      numerator *= denominator
      numerator += numeratorʹ

      self = Fraction(sign: value.sign, numerator: numerator, denominator: denominator)
      flags.insert(.isRepeating)

    } else {
      // The decimal terminates or does not have a repeating pattern

      let denominator = pow(UInt128(10), digits.count)
      numerator *= denominator
      numerator += UInt128(digits: digits)
      self = Fraction(sign: value.sign, numerator: numerator, denominator: denominator)

    }

    reduce()

  }

  /// Creates a fraction where the denominator is a power of 10 and the represented value is equivalent to
  /// `a.bc̅` where `a = integerPart`, `b = nonrepeatingPart`, and  `c = repeatingPart`.
  ///
  /// - parameter sign:             Whether the fraction is positive or negative
  /// - parameter integerPart:      The whole number value for the fraction to create.
  /// - parameter nonrepeatingPart: The non-repeating fractional part for the fraction to create.
  /// - parameter repeatingPart:    The infinitely repeating fraction part for the fraction to create.
  public init<S1, S2>(sign: FloatingPointSign = .plus, integer: UInt128, nonrepeating: S1, repeating: S2)
    where S1:Collection, S2: Collection, S1.Iterator.Element == UInt8, S2.Iterator.Element == UInt8
  {
    let pad = integer == 0 ? 0 : log10(integer).value &+ 1
    var m = 0
    switch (nonrepeating.count, repeating.count) {
      case (0,  0):
        self = Fraction(sign: sign, numerator: integer, denominator: 1)

        case (0,  _):
          var numerator = integer
          for digit in repeating.repeating() {
            guard m &+ pad < 38 else { break }
            numerator = numerator * 10 &+ UInt128(digit)
            m = m &+ 1
          }
          self = Fraction(sign: sign, numerator: numerator, denominator: powersOfTen[m])
          flags.insert(.isRepeating)

        case (_, 0):
          var numerator = integer
          for digit in nonrepeating {
            guard m &+ pad < 38 else { break }
            numerator = numerator * 10 &+ UInt128(digit)
            m = m &+ 1
          }
          self = Fraction(sign: sign, numerator: numerator, denominator: powersOfTen[m])

        default:
          var numerator = integer
          for digit in nonrepeating {
            guard m &+ pad < 38 else { break }
            numerator = numerator * 10 &+ UInt128(digit)
            m = m &+ 1
          }
          for digit in repeating.repeating() {
            guard m &+ pad < 38 else { break }
            numerator = numerator * 10 &+ UInt128(digit)
            m = m &+ 1
          }
          self = Fraction(sign: sign, numerator: numerator, denominator: powersOfTen[m])
          flags.insert(.isRepeating)
    }
  }

  /// Initializer taking a tupled parameter to splay through to `init(sign:integer:nonrepeating:repeating:)`
  public init<S1, S2>(sign: FloatingPointSign = .plus, parts: (integer: UInt128, nonrepeating: S1, repeating: S2))
    where S1:Collection, S2: Collection, S1.Iterator.Element == UInt8, S2.Iterator.Element == UInt8
  {
    self = Fraction(sign: sign, integer: parts.integer, nonrepeating: parts.nonrepeating, repeating: parts.repeating)
  }

}

// MARK: - FloatingPoint conformance
extension Fraction: FloatingPoint {

  public typealias Exponent = Int

  public init<Source>(_ value: Source) where Source:BinaryInteger {

  }

  public init?<Source>(exactly value: Source) where Source:BinaryInteger {

  }

  /// Initialize a value using the formula: `representedValue = -1**sign.rawValue * significand * 10**exponent`
  /// For a normalized fraction in decimal form `exponent` will be a negative value and `significand`'s denominator is `1`.
  ///
  /// - parameter sign:        Whether the value is positive or negative.
  /// - parameter exponent:    Power to which `10` is raised. Must fall within -38...38 to avoid overflow.
  /// - parameter significand: Value by which the power of `10` is multiplied
  public init(sign: FloatingPointSign, exponent: Int, significand: Fraction) {
    guard !significand.isNaN else { self = Fraction(sign: sign, magnitude: Fraction.nan); return }
    guard !significand.isInfinite else { self = Fraction(sign: sign, magnitude: Fraction.infinity); return }
    let parts = exponent < 0
      ? split(numerator: significand.numerator, exponent: Int(Swift.abs(exponent)))
      : split(numerator: powersOfTen[Swift.abs(exponent)] * significand.numerator, exponent: 0)

    self = Fraction(sign: sign, parts: parts)
    reduce()
  }

  /// Creates a value by copying the sign and magnitude of the specified fractions.
  ///
  /// - parameter otherSign:      Fraction whose sign value shall be used to initialize this value.
  /// - parameter otherMagnitude: Fraction whose numerator and denominator shall be used to initialize this value.
  public init(signOf otherSign: Fraction, magnitudeOf otherMagnitude: Fraction) {
    self = Fraction(sign: otherSign.sign, magnitude: otherMagnitude)
  }

  // Initializing from one of the standard library integer types.
  // 'reduce' parameters are absent because these are always whole numbers.

  public init(_ value: UInt8)  { self = Fraction(numerator: UInt128(value), flags: []) }
  public init(_ value: Int8)   { self = Fraction(numerator: UInt128(Fraction.abs(Fraction(value))), flags: value < 0 ? [.isNegative] : []) }
  public init(_ value: UInt16) { self = Fraction(numerator: UInt128(value), flags: []) }
  public init(_ value: Int16)  { self = Fraction(numerator: UInt128(Fraction.abs(Fraction(value))), flags: value < 0 ? [.isNegative] : []) }
  public init(_ value: UInt32) { self = Fraction(numerator: UInt128(value), flags: []) }
  public init(_ value: Int32)  { self = Fraction(numerator: UInt128(Fraction.abs(Fraction(value))), flags: value < 0 ? [.isNegative] : []) }
  public init(_ value: UInt64) { self = Fraction(numerator: UInt128(value), flags: []) }
  public init(_ value: Int64)  { self = Fraction(numerator: UInt128(Fraction.abs(Fraction(value))), flags: value < 0 ? [.isNegative] : []) }
  public init(_ value: UInt)   { self = Fraction(numerator: UInt128(value), flags: []) }
  public init(_ value: Int)    { self = Fraction(numerator: UInt128(Fraction.abs(Fraction(value))), flags: value < 0 ? [.isNegative] : []) }

  public static var radix: Int { return 10 }
  public static var nan: Fraction          { return Fraction(nan: 0, signaling: false) }
  public static var signalingNaN: Fraction { return Fraction(nan: 0, signaling: true) }
  public static var infinity: Fraction     { return Fraction(flags: [.isInfinite]) }
  public static var greatestFiniteMagnitude: Fraction { return Fraction(numerator: UInt128.max, denominator: 1) }
  public static var pi: Fraction           { return Fraction(numerator: UInt128(high: 0x17a27cc3ed6cf7ee,
                                                                                low: 0xaae7b57d8c88bd6a),
                                                             denominator: pow10(37)) }


  public var ulp: Fraction { return isFinite ? Fraction.leastNonzeroMagnitude : Fraction.nan }

  public static var leastNormalMagnitude: Fraction { return leastNonzeroMagnitude }

  public static var leastNonzeroMagnitude: Fraction { return Fraction(numerator: 1, denominator: UInt128.max) }

  public private(set) var sign: FloatingPointSign {
    get { return flags.sign }
    set { guard flags.sign != newValue else { return }; flags.toggleSign() }
  }

  /// The exponent in `Fraction.representedValue =  -1**sign.rawValue * significand * 10**exponent`
  public var exponent: Int {
    guard flags.intersection([.isInfinite, .isNaN]) == [] else { return Int.max }
    guard denominator > 1 else { return 0 }
    return -log10(decimalForm.denominator).value
  }

  /// /// The significand in `Fraction.representedValue =  -1**sign.rawValue * significand * 10**exponent`
  public var significand: Fraction {
    guard !isNaN else { return Fraction.nan }
    guard !isInfinite else { return Fraction.infinity }
    guard numerator > 0 else { return Fraction.zero }
    return decimalForm.numerator╱1
  }


  public mutating func add(_ other: Fraction) {

    // Check NaNs
    guard !isNaN else { return }
    guard !other.isNaN else { flags.insert(.isNaN); return }

    // Check infinities
    switch (isInfinite, other.isInfinite) {
      case (false, false): break
      case (true, false),
           (true, true) where sign == other.sign: return
      case (false, true): self = other; return
      case (true, true): flags.insert(.isNaN); return
    }

    // Calculate numerators over common base
    let denominatorʹ = lcm(denominator, other.denominator)
    let numeratorʹ = (denominatorʹ/denominator) * numerator
    let otherNumerator = (denominatorʹ / other.denominator) * other.numerator

    denominator = denominatorʹ  // Update to common base used in calculations

    // Check signs
    switch (sign, other.sign) {
      case (.plus, .plus),
           (.minus, .minus):
        numerator = numeratorʹ &+ otherNumerator
      case (.plus, .minus) where numeratorʹ >= otherNumerator:
        numerator = numeratorʹ &- otherNumerator
      case (.plus, .minus) /* where numeratorʹ < otherNumerator*/:
        numerator = otherNumerator &- numeratorʹ
        flags.insert(.isNegative)
      case (.minus, .plus) where numeratorʹ >= otherNumerator:
        numerator = numeratorʹ &- otherNumerator
      case (.minus, .plus) /* where numeratorʹ < otherNumerator*/:
        numerator = otherNumerator &- numeratorʹ
        flags.remove(.isNegative)
    }

    flags.remove([.isReduced, .isRepeating])
    reduce()
  }

  public mutating func negate() { flags.toggleSign() }

  public mutating func subtract(_ other: Fraction) { add(other.negate()) }

  public mutating func multiply(by other: Fraction) {
    // check NaNs
    guard !isNaN else { return }
    guard !other.isNaN else { flags.insert(.isNaN); return }

    // check infinities
    switch (isInfinite, other.isInfinite) {
      case (true, false) where other.numerator == 0,
           (false, true) where numerator == 0:
        flags.insert(.isNaN)
        return
      case (false, true):
        flags.insert(.isInfinite)
      case (true, false),
           (true, true):
        break
      case (false, false):
        numerator *= other.numerator
        denominator *= other.denominator
        flags.remove([.isReduced, .isRepeating])
        reduce()
    }

    // check signs
    switch (sign, other.sign) {
      case (.plus, .plus),
           (.minus, .plus):
        break
      case (.minus, .minus):
        flags.remove(.isNegative)
      case (.plus, .minus):
        flags.insert(.isNegative)
    }
  }

  public mutating func divide(by other: Fraction) { multiply(by: other.reciprocal) }

  public mutating func formRemainder(dividingBy other: Fraction) {

    // check NaNs
    guard !isNaN else { return }
    guard !other.isNaN else { flags.insert(.isNaN); return }

    // check infinities
    switch (isInfinite, other.isInfinite) {
      case (true, _),
           (false, false) where other.numerator == 0:
        flags.insert(.isNaN)
        return
      case (false, true),
           (false, false) where numerator == 0:
        return
      case (false, false):
        /*
         n = numerator, d = denominator, nʹ = other.numerator, dʹ = other.denominator
         a = ndʹ, b = dnʹ, c = a mod b
             ⎧ (a - c)/b , if c < b/2 or c == b/2 and ((a - c)/b) mod 2 == 0
         q = ⎨
             ⎩ (a + b - c)/b , if c > b/2 or c == b/2 and ((a + b - c)/b) mod 2 == 0
         r = (n/d) - q(nʹ/dʹ)
         */
        let n = numerator, d = denominator, nʹ = other.numerator, dʹ = other.denominator
        let a = n * dʹ, b = d * nʹ, c = a % b
        let q: UInt128

        switch b / 2 {
          case c-->:
            // c < b/2
            q = (a - c) / b

          case <--c:
            // c > b/2
            q = (a + b - c) / b

          default:
            // c == b/2
            let qʹ = (a - c) / b
            q = qʹ % 2 == 0 ? qʹ : (a + b - c) / b
        }

        self = n╱d - (q * nʹ)╱dʹ
    }
  }

  public mutating func formTruncatingRemainder(dividingBy other: Fraction) {
    // check NaNs
    guard !isNaN else { return }
    guard !other.isNaN else { flags.insert(.isNaN); return }

    // check infinities
    switch (isInfinite, other.isInfinite) {
      case (true, _),
           (false, false) where other.numerator == 0:
        flags.insert(.isNaN)
        return
      case (false, true),
           (false, false) where numerator == 0:
        return
      case (false, false):
        /*
         n = numerator, d = denominator, nʹ = other.numerator, dʹ = other.denominator
         n/d mod nʹ/dʹ == nʺ/dʺ mod n‴/d″ where n/d == n″/d″ and n′/d′ == n‴/d″
         */
        let denominatorʹ = lcm(denominator, other.denominator)
        let numeratorʹ = (denominatorʹ / denominator) * numerator
        let otherNumerator = (denominatorʹ / other.denominator) * other.numerator

        numerator = numeratorʹ % otherNumerator
        denominator = denominatorʹ
        flags.remove([.isReduced, .isRepeating])
        reduce()
    }

  }

  public mutating func formSquareRoot() {
    guard !(isZero || isNaN || isInfinite && sign == .plus) else { return }
    guard !(isInfinite && sign == .minus) else { flags.insert(.isNaN); return }

    reduce()

    // √(n/d) == √n/√d == (√n * √d)/d == (√(n * d))/d
    let (numeratorʹ, overflow) = numerator.multipliedWithOverflow(by: denominator)
    guard overflow != .overflow else {
      self = Fraction(Double(self).squareRoot())
      return
    }

    let pairs: AnyIterator<UInt128> = {
      var value = numeratorʹ
      let totalPairs = (log10(value).value &+ 1) / 2
      var currentPair = totalPairs
      return AnyIterator {
        guard currentPair > -1 else { return nil }
        let powerOf10 = pow10(currentPair * 2)
        let result = value / powerOf10
        currentPair = currentPair &- 1
        value -= result * powerOf10
        return result
      }
    }()

    var p: (integer: (value: UInt128, exponent: Int), fractional: (value: UInt128, exponent: Int)) = ((0, 0), (0, 0))
    var x: UInt128 = 0
    var y: UInt128 = 0
    var currentPair = pairs.next()
    guard currentPair != nil else { flags.insert(.isNaN); return }
    var c = currentPair!

    repeat {
      x = 0
      let pʹ = p.integer.value
      while (x &+ 1) * (20 * pʹ &+ (x &+ 1)) <= c { x = x &+ 1 }
      p.integer.value *= 10
      p.integer.value += x
      p.integer.exponent += 1
      y = x * (20 * pʹ &+ x)
      c -= y
      currentPair = pairs.next()
      if currentPair != nil {
        c *= 100
        c += currentPair!
      }
    } while currentPair != nil

    while c != 0 && (p.fractional.exponent &+ p.integer.exponent) < 38 {
      c *= 100
      x = 0
      let pʹ = p.integer.value * pow10(p.fractional.exponent) + p.fractional.value
      while (x &+ 1) * (20 * pʹ &+ (x &+ 1)) <= c { x = x &+ 1 }
      let (fractionalʹ, overflow) = p.fractional.value.multipliedWithOverflow(by: 10)
      guard overflow == .none else { break }
      p.fractional.value = fractionalʹ &+ x
      p.fractional.exponent += 1
      y = x * (20 * pʹ &+ x)
      c -= y
    }

    let denominatorʹ = pow10(p.fractional.exponent)
    numerator = denominatorʹ * p.integer.value + p.fractional.value
    denominator *= denominatorʹ
    flags.remove(.isReduced)
    if c == 0 { flags.remove(.isRepeating) }
  }

  public mutating func addProduct(_ lhs: Fraction, _ rhs: Fraction) {
    guard !isNaN else { return }

    // calculate the product
    var product: Fraction

    switch (lhs.isInfinite, rhs.isInfinite) {
      case (true, false) where rhs.numerator == 0,
           (false, true) where lhs.numerator == 0,
           (false, _) where lhs.isNaN,
           (_, false) where rhs.isNaN:
        flags.insert(.isNaN); return
      case (false, true):
        product = rhs
      case (true, false),
           (true, true):
        product = lhs
      case (false, false):
        product = (lhs.numerator * rhs.numerator)╱(lhs.denominator * rhs.denominator)
    }

    // Make sure product is appropriately signed
    if lhs.sign != rhs.sign { product.negate() }

    // Check infinities
    switch (isInfinite, product.isInfinite) {
      case (false, false): break
      case (true, false),
           (true, true) where sign == product.sign: return
      case (false, true): self = product; return
      case (true, true): flags.insert(.isNaN); return
    }

    // Calculate numerators over common base
    let denominatorʹ = lcm(denominator, product.denominator)
    let numeratorʹ = (denominatorʹ/denominator) * numerator
    let otherNumerator = (denominatorʹ / product.denominator) * product.numerator

    denominator = denominatorʹ  // Update to common base used in calculations

    // Check signs
    switch (sign, product.sign) {
    case (.plus, .plus),
         (.minus, .minus):
      numerator = numeratorʹ &+ otherNumerator
    case (.plus, .minus) where numeratorʹ >= otherNumerator:
      numerator = numeratorʹ &- otherNumerator
    case (.plus, .minus) /* where numeratorʹ < otherNumerator*/:
      numerator = otherNumerator &- numeratorʹ
      flags.insert(.isNegative)
    case (.minus, .plus) where numeratorʹ >= otherNumerator:
      numerator = numeratorʹ &- otherNumerator
    case (.minus, .plus) /* where numeratorʹ < otherNumerator*/:
      numerator = otherNumerator &- numeratorʹ
      flags.remove(.isNegative)
    }

    flags.remove([.isReduced, .isRepeating])
    reduce()
  }

  public mutating func round(_ rule: FloatingPointRoundingRule) {

    guard flags.intersection([.isNaN, .isInfinite]) == [] && numerator > 0 else { return }
    var numeratorʹ = numerator / denominator

    switch ((numerator - numeratorʹ)╱1, denominator╱2) {
    case let (x, y) where x < y:
      switch rule {
        case .down where sign == .minus,
             .up where sign == .plus,
             .awayFromZero:
          numeratorʹ += 1
        default:
          break
      }
    case let (x, y) where x > y:
      switch rule {
        case .awayFromZero,
             .toNearestOrEven,
             .toNearestOrAwayFromZero,
             .down where sign == .minus,
             .up where sign == .plus:
          numeratorʹ += 1
        default:
          break
      }
    default:
      switch rule {
        case .awayFromZero,
             .toNearestOrAwayFromZero,
             .down where sign == .minus,
             .up where sign == .plus,
             .toNearestOrEven where numeratorʹ % 2 == 1:
          numeratorʹ += 1
        default:
          break
      }
    }

    numerator = numeratorʹ
    denominator = 1
    flags.remove(.isRepeating)
    flags.insert(.isReduced)
  }

  public var nextUp: Fraction {
    guard !isNaN else { return self }
    switch (numerator, denominator, sign) {
      case (_, 0, .minus):
        // If `self` is `-infinity` return `-greatestMagnitude`.
        return Fraction(sign: .minus, numerator: UInt128.max, denominator: 1)
      case (_, 0, .plus):
        // If `self` is `infinity` return `x`.
        return self
      case (1, UInt128.max, .minus):
        // If `self` is `-leastNonzeroMagnitude` return `-0.0`.
        return Fraction(sign: .minus, numerator: 0, denominator: UInt128.max)
      case (UInt128.max, 1, .plus):
        // If `self` is `greatestMagnitude` return `infinity`.
        return Fraction(sign: .plus, numerator: UInt128.max, denominator: 0)
      default:
        // Otherwise increment by `leastNonzeroMagnitude`
        return adding(Fraction.leastNonzeroMagnitude)
    }
  }

  public func isEqual(to other: Fraction) -> Bool {
    guard !(isNaN || other.isNaN) else { return false }
    guard numerator > 0 && other.numerator > 0 else { return true }
    guard sign == other.sign else { return false }
    guard isInfinite == other.isInfinite else { return false }
    return numerator * other.denominator == other.numerator * denominator
  }

  public func isLess(than other: Fraction) -> Bool {
    guard !(isNaN || other.isNaN) else { return false }
    switch (isInfinite, other.isInfinite) {
      case (true, true): return sign == .minus && other.sign == .plus
      case (true, false): return sign == .minus
      case (false, true): return other.sign == .plus
      case (false, false): break
    }

    switch (numerator == 0, other.numerator == 0) {
      case (true, true): return false
      case (true, false): return other.sign == .plus
      case (false, true): return sign == .minus
      case (false, false): break
    }

    switch (sign, other.sign) {
      case (.plus, .plus): return numerator * other.denominator < other.numerator * denominator
      case (.plus, .minus): return false
      case (.minus, .plus): return true
      case (.minus, .minus): return numerator * other.denominator > other.numerator * denominator
    }
  }

  public func isLessThanOrEqualTo(_ other: Fraction) -> Bool {
    guard !(isNaN || other.isNaN) else { return false }
    switch (isInfinite, other.isInfinite) {
      case (true, true): return sign == .minus || other.sign == .plus
      case (true, false): return sign == .minus
      case (false, true): return other.sign == .plus
      case (false, false): break
    }

    guard numerator > 0 && other.numerator > 0 else { return true }

    switch (sign, other.sign) {
      case (.plus, .plus): return numerator * other.denominator <= other.numerator * denominator
      case (.plus, .minus): return false
      case (.minus, .plus): return true
      case (.minus, .minus): return numerator * other.denominator >= other.numerator * denominator
    }
  }

  public func isTotallyOrdered(belowOrEqualTo other: Fraction) -> Bool {
    guard sign == other.sign else { return sign == .minus }
    switch (isNaN, other.isNaN) {
      case (true, true):
        switch (isSignalingNaN, other.isSignalingNaN) {
          case (true, true): return numerator <= other.numerator
          case (true, false): return sign == .plus
          case (false, true): return sign == .minus
          case (false, false): return true
        }
        case (true, false): return sign == .minus
        case (false, true): return other.sign == .plus
        case (false, false): return isLessThanOrEqualTo(other)
    }
  }

  public var isNormal:       Bool { return !(isNaN || isInfinite || isZero)      }
  public var isFinite:       Bool { return !(isNaN || isInfinite)                }
  public var isZero:         Bool { return isFinite && numerator == 0            }
  public var isSubnormal:    Bool { return false                                 }
  public var isInfinite:     Bool { return flags ∋ .isInfinite && flags ∌ .isNaN }
  public var isNaN:          Bool { return flags ∋ .isNaN                        }
  public var isSignalingNaN: Bool { return flags ∋ .isSignaling                  }
  public var isCanonical:    Bool { return true                                  }

}

// MARK: - AbsoluteValuable conformance
extension Fraction: AbsoluteValuable {
  /// Returns the absolute value of `x`.
  public static func abs(_ x: Fraction) -> Fraction { return x.sign == .plus ? x : x.negated() }
}

// MARK: - SignedNumber conformance
extension Fraction: SignedNumber {
  // Break ambiguity for `SignedNumber` conformance operators.
  public static func -(lhs: Fraction, rhs: Fraction) -> Fraction { return lhs.subtracting(rhs) }
  public static func +(lhs: Fraction, rhs: Fraction) -> Fraction { return lhs.adding(rhs) }
}

// MARK: - ExpressibleByIntegerLiteral conformance
extension Fraction: ExpressibleByIntegerLiteral {
  public init(integerLiteral value: Int) { self = Fraction(value) }
}

// MARK: - Strideable conformance
extension Fraction: Strideable {
  public func advanced(by n: Fraction) -> Fraction { return self.adding(n) }
  public func distance(to other: Fraction) -> Fraction { return other.subtracting(self) }
}

// MARK: - Hashable conformance
extension Fraction: Hashable {
  public var hashValue: Int {
    guard !isZero else { return 0 };
    return numerator.hashValue ^ denominator.hashValue ^ flags.rawValue.hashValue
  }
}

// MARK: - CustomStringConvertible/CustomDebugStringConvertible conformance
extension Fraction: CustomStringConvertible, CustomDebugStringConvertible {
  public var description: String {
    switch floatingPointClass {
      case .negativeZero: return "-0"
      case .positiveZero: return "0"
      case .negativeInfinity: return "-inf"
      case .positiveInfinity: return "inf"
      case .quietNaN: return "nan"
      case .signalingNaN where numerator == 0: return "snan"
      case .signalingNaN: return "snan(0x\(String(numerator, radix: 16)))"
      case .positiveNormal, .positiveSubnormal: return "\(numerator)/\(denominator)"
      case .negativeNormal, .negativeSubnormal: return "-\(numerator)/\(denominator)"
    }
  }
  public var debugDescription: String { return description + " {flags: \(flags)}" }
}

// MARK: - CustomPlaygroundQuickLookable
extension Fraction: CustomPlaygroundQuickLookable {
  public var customPlaygroundQuickLook: PlaygroundQuickLook { return .text(description) }
}

// MARK: - Extension of other types with intializers that take a fraction
extension Double {
  public init(_ value: Fraction) {
    switch value.floatingPointClass {
      case .quietNaN: self = Double.nan
      case .signalingNaN: self = Double.signalingNaN
      case .positiveInfinity: self = Double.infinity
      case .negativeInfinity: self = Double.infinity.negated()
      case .positiveZero: self = Double()
      case .negativeZero: self = Double().negated()
      case .positiveNormal, .positiveSubnormal: self = Double(value.numerator) / Double(value.denominator)
      case .negativeNormal, .negativeSubnormal: self = (Double(value.numerator) / Double(value.denominator)).negated()
    }
  }
}

extension CGFloat {
  public init(_ value: Fraction) { self = CGFloat(Double(value)) }
}

extension Float {
  public init(_ value: Fraction) { self = Float(Double(value)) }
}

extension UInt {
  public init(_ value: Fraction) { self = UInt(value.integerPart) }
}

extension UInt8 {
  public init(_ value: Fraction) { self = UInt8(value.integerPart) }
}

extension UInt16 {
  public init(_ value: Fraction) { self = UInt16(value.integerPart) }
}

extension UInt32 {
  public init(_ value: Fraction) { self = UInt32(value.integerPart) }
}

extension UInt64 {
  public init(_ value: Fraction) { self = UInt64(value.integerPart) }
}

extension UInt128 {
  public init(_ value: Fraction) { self = value.integerPart }
}

extension Int {
  public init(_ value: Fraction) { self = Int(value.integerPart); if value.sign == .minus { self = -self } }
}

extension Int8 {
  public init(_ value: Fraction) { self = Int8(value.integerPart); if value.sign == .minus { self = -self } }
}

extension Int16 {
  public init(_ value: Fraction) { self = Int16(value.integerPart); if value.sign == .minus { self = -self } }
}

extension Int32 {
  public init(_ value: Fraction) { self = Int32(value.integerPart); if value.sign == .minus { self = -self } }
}

extension Int64 {
  public init(_ value: Fraction) { self = Int64(value.integerPart); if value.sign == .minus { self = -self } }
}
