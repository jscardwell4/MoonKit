//
//  Fraction.swift
//  MoonKit
//
//  Created by Jason Cardwell on 8/4/16.
//  Copyright © 2016 Jason Cardwell. All rights reserved.
//
import Foundation

// MARK: - Fraction

public struct Fraction {
  /// The numerator of the fraction.
  public let numerator: UInt128

  /// The denominator of the fraction.
  public let denominator: UInt128

  /// Structure holding various flag values for the fraction.
  fileprivate var flags: Flags

  /// Initializing with known flag values.
  /// - Parameters:
  ///   - numerator: The fraction's numerator. The default is `0`.
  ///   - denominator: The fraction's denominator. The default is `1`
  ///   - flags: The fraction's flags.
  ///   - reducing: Whether to reduce the fraction while initializing.
  ///               The default is `false`
  fileprivate init(numerator: UInt128 = 0,
                   denominator: UInt128 = 1,
                   flags: Flags,
                   reducing: Bool)
  {
    self.numerator = numerator
    self.denominator = denominator
    self.flags = flags
    if denominator == 0 { self.flags.insert(.isInfinite) }
    if _isDecimalBase(denominator) {
      let (_, repeating) = _split(fractionalNumerator: numerator.digits())
      if !repeating.isEmpty { self.flags.insert(.isRepeating) }
    }
    if reducing { reduce() }
  }

  /// Initializer for fractions that require only specific flags be set.
  /// - Parameter flags: The flags for the new fraction.
  fileprivate init(flags: Flags) {
    numerator = 0
    denominator = 1
    self.flags = flags
  }

  /// Default initializer.
  /// - Parameters:
  ///   - numerator: The fraction's numerator value.
  ///   - denominator: The fraction's denominator value.
  ///   - sign: Whether the fraction is positive or negative. The default is `.plus`
  ///   - reducing: Whether to reduce the fraction while initializing.
  ///               The default is `false`.
  public init(numerator: UInt128,
              denominator: UInt128,
              sign: FloatingPointSign = .plus,
              reducing: Bool = false)
  {
    self.init(numerator: numerator,
              denominator: denominator,
              flags: sign == .minus ? .isNegative : [],
              reducing: reducing)
  }

  /// `true` if `denominator` is a power of 10 and `false` otherwise.
  public var isDecimal: Bool { _isDecimalBase(denominator) }

  /// `true` if the fraction is normal and top heavy and `false` otherwise.
  public var isImproper: Bool { isNormal && numerator > denominator }

  /// `true` if the fraction is normal, non-zero and bottom heavy and `false` otherwise.
  public var isProper: Bool { (isNormal || isZero) && numerator < denominator }

  /// `true` if the fraction is in reduced form and `false` otherwise.
  public var isReduced: Bool { flags ∋ .isReduced }

  /// `true` if the fraction has a repeating part and `false` otherwise.
  public var isRepeating: Bool { flags ∋ .isRepeating }

  /// The integer portion of the fraction's decimal form.
  public var integerPart: UInt128 { isImproper ? numerator / denominator : 0 }

  /// The fractional portion of the fraction's decimal form.
  public var fractionalPart: Fraction {
    Fraction(numerator: numerator - integerPart * denominator,
             denominator: denominator,
             sign: sign)
  }

  /// The nonrepeating and repeating digits of the fraction's decimal form numerator.
  public var parts: (nonrepeating: [UInt8], repeating: [UInt8]) {
    _split(fractionalNumerator: fractionalPart.decimalForm.numerator.digits())
  }

  /// The inverted fraction.
  public var reciprocal: Fraction {
    isNaN
      ? self
      : (isInfinite
        ? Fraction(numerator: 0, denominator: 1, sign: sign)
        : (isZero
          ? Fraction(signOf: self, magnitudeOf: .infinity)
          : Fraction(numerator: denominator, denominator: numerator, sign: sign)))
  }

  /// The fraction as represented with a power of ten denominator.
  public var decimalForm: Fraction {
    // Check that the current form isn't most appropriate.
    guard !isNaN, !isInfinite, _powersOfTen ∌ denominator else { return self }

    // Check that we aren't magnitude zero.
    guard !isZero else { return Fraction(numerator: 0, denominator: 1, sign: sign) }

    // Calculate the quotient and remainder.
    var (quotient, remainder) =
      numerator.quotientAndRemainder(dividingBy: denominator)

    // Check that the denominator does not divide the numerator evenly.
    guard remainder > 0 else {
      // Otherwise we have what we need already.
      return Fraction(numerator: quotient, denominator: 1, sign: sign)
    }

    // Determine how much room the quotient requires.
    let pad = quotient == 0 ? 0 : _log10(quotient) + 1

    // Collect a list of (quotient, remainder) tuples and spacers.
    var partials: OrderedSet<AnyHashable> = []

    // Collect individual digits of the fractional part.
    var fractional: Queue<UInt128> = []

    // Capture the integer part of the fraction's decimal form.
    let integer = quotient

    // Iterate relative to the power of ten.
    for i in 0..<(38 &- pad) {
      remainder *= 10

      while remainder < denominator {
        remainder *= 10
        fractional.enqueue(0)
        partials.insert(AnyHashable(i)) // Add a spacer to maintain index accuracy
      }

      // Carry out another division operation now that `remainder >= denominator`.
      (quotient, remainder) = remainder.quotientAndRemainder(dividingBy: denominator)

      // Check whether there is still a remainder (i.e. there is a repeating part).
      guard remainder > 0 else {
        // Enqueue the most recent value of `quotient`.
        fractional.enqueue(quotient)

        // Form the nonrepeating digits.
        let nonrepeating = fractional.map(\UInt128.low).map(UInt8.init)

        // Return the composed fraction
        return Fraction(sign: sign,
                        integer: integer,
                        nonrepeating: nonrepeating,
                        repeating: [])
      }

      // Check whether this (quotient, remainder) tuple is unique.
      switch partials.index(of: AnyHashable((quotient, remainder))) {
        case let idx?:
          // The tuple is not unique. Compose a repeating fraction.

          // Form the nonrepeating digits.
          let nonrepeating = idx == 0
            ? []
            : fractional.dequeue(count: idx).map(\UInt128.low).map(UInt8.init)

          // Form the repeating digits.
          let repeating = fractional.map(\UInt128.low).map(UInt8.init)

          // Return the composed fracion.
          return Fraction(sign: sign,
                          integer: integer,
                          nonrepeating: nonrepeating,
                          repeating: repeating)

        default:
          // The tuple is unique, enqueue and insert.

          fractional.enqueue(quotient)
          partials.insert(AnyHashable((quotient, remainder)))
      }
    }

    // A repeating fraction will have returned. Form the nonrepeating digits.
    let nonrepeating = fractional.map(\UInt128.low).map(UInt8.init)

    // Return the composed fraction.
    return Fraction(sign: sign,
                    integer: integer,
                    nonrepeating: nonrepeating,
                    repeating: [])
  }

//  /// Creates a fraction where the denominator is a power of 10 and the represented
//  /// value is equivalent to `a.bc̅` where `a = integerPart`, `b = nonrepeatingPart`,
//  /// and  `c = repeatingPart`.
//  ///
//  /// - Parameters:
//  ///   - sign: Whether the fraction is positive or negative
//  ///   - integer: The whole number value.
//  ///   - nonrepeating: The non-repeating fractional part.
//  ///   - repeating: The infinitely repeating fractional part.
//  ///   - reducing: Whether to reduce the fraction while initializing.
//  public init<S1, S2>(sign: FloatingPointSign = .plus,
//                      integer: UInt128,
//                      nonrepeating: S1,
//                      repeating: S2,
//                      reducing: Bool = false)
//    where S1: Collection, S2: Collection, S1.Element == UInt8, S2.Element == UInt8
//  {
//    let pad = integer == 0 ? 0 : Int(log10(Double(integer))) &+ 1
//    var m = 0
//    switch (nonrepeating.count, repeating.count) {
//      case (0, 0):
//        self = Fraction(numerator: integer, denominator: 1, sign: sign)
//
//      case (0, _):
//        var numerator = integer
//        for digit in repeating.repeating() {
//          guard m &+ pad < 38 else { break }
//          numerator = numerator * 10 &+ UInt128(digit)
//          m = m &+ 1
//        }
//        self = Fraction(numerator: numerator, denominator: _powersOfTen[m], sign: sign)
//        flags.insert(.isRepeating)
//
//      case (_, 0):
//        var numerator = integer
//        for digit in nonrepeating {
//          guard m &+ pad < 38 else { break }
//          numerator = numerator * 10 &+ UInt128(digit)
//          m = m &+ 1
//        }
//        self = Fraction(numerator: numerator, denominator: _powersOfTen[m], sign: sign)
//
//      default:
//        var numerator = integer
//        for digit in nonrepeating {
//          guard m &+ pad < 38 else { break }
//          numerator = numerator * 10 &+ UInt128(digit)
//          m = m &+ 1
//        }
//        for digit in repeating.repeating() {
//          guard m &+ pad < 38 else { break }
//          numerator = numerator * 10 &+ UInt128(digit)
//          m = m &+ 1
//        }
//        self = Fraction(numerator: numerator, denominator: _powersOfTen[m], sign: sign)
//        flags.insert(.isRepeating)
//    }
//    if reducing { reduce() }
//  }

  /// Creates a fraction where the denominator is a power of 10 and the represented
  /// value is equivalent to `a.bc̅` where `a = integerPart`, `b = nonrepeatingPart`,
  /// and  `c = repeatingPart`.
  ///
  /// - Parameters:
  ///   - sign: Whether the fraction is positive or negative
  ///   - integer: The whole number value.
  ///   - nonrepeating: The non-repeating fractional part.
  ///   - repeating: The infinitely repeating fractional part.
  ///   - reducing: Whether to reduce the fraction while initializing.
  public init<S1, S2>(sign: FloatingPointSign = .plus,
                      integer: UInt128,
                      nonrepeating: S1,
                      repeating: S2,
                      reducing: Bool = false)
    where S1: Collection, S2: Collection, S1.Element == UInt8, S2.Element == UInt8
  {
    let pad = integer == 0 ? 0 : Int(log10(Double(integer))) &+ 1
    var m = 0
    switch (nonrepeating.count, repeating.count) {
      case (0, 0):
        self = Fraction(numerator: integer, denominator: 1, sign: sign)
        
      case (0, _):
        var numerator = integer
        for digit in repeating.repeating() {
          guard m &+ pad < 38 else { break }
          numerator = numerator * 10 &+ UInt128(digit)
          m = m &+ 1
        }
        self = Fraction(numerator: numerator, denominator: _powersOfTen[m], sign: sign)
        flags.insert(.isRepeating)
        
      case (_, 0):
        var numerator = integer
        for digit in nonrepeating {
          guard m &+ pad < 38 else { break }
          numerator = numerator * 10 &+ UInt128(digit)
          m = m &+ 1
        }
        self = Fraction(numerator: numerator, denominator: _powersOfTen[m], sign: sign)
        
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
        self = Fraction(numerator: numerator, denominator: _powersOfTen[m], sign: sign)
        flags.insert(.isRepeating)
    }
    if reducing { reduce() }
//    if repeating.count > 0 {
//      var denominatorDigits: [UInt8] = []
//      for _ in 0..<repeating.count { denominatorDigits.append(9) }
//      for _ in 0..<nonrepeating.count { denominatorDigits.append(0) }
//      denominator = UInt128(digits: denominatorDigits)
//    } else if nonrepeating.count > 0 {
//      var denominatorDigits: [UInt8] = [1]
//      for _ in 0..<nonrepeating.count { denominatorDigits.append(0) }
//      denominator = UInt128(digits: denominatorDigits)
//    } else {
//      denominator = 1
//    }
//    numerator = integer * denominator
//              + UInt128(digits: Array(nonrepeating))
//              + UInt128(digits: Array(repeating))
//    flags = []
//    if sign == .minus { flags.insert(.isNegative) }
//    if repeating.count > 0 { flags.insert(.isRepeating) }
//    if reducing { reduce() }
  }

  // MARK: Reducing/rebasing fractions

  /// The fraction in its most compact form.
  /// - Returns: The reduced fraction.
  public func reduced() -> Fraction {
    guard !isReduced else { return self }
    var result = self
    result.reduce()
    return result
  }

  /// Reduces the fraction to its most compact form.
  public mutating func reduce() {
    guard isFinite, !isZero, !isReduced else { return }

    var numerator = self.numerator, denominator = self.denominator

//    if isRepeating {
//      let decimal = decimalForm
//      let (integer,
//           nonrepeating,
//           repeating) = _split(numerator: decimal.numerator,
//                               exponent: abs(decimal.exponent))
//      switch (nonrepeating.count, repeating.count) {
//        case (_, 0):
//          break
//        case (0, _):
//          denominator = repeating.reduce(0) { $0 + UInt128($1 * 10 + 9) }
//          numerator = UInt128(digits: repeating) + integer * denominator
//        default:
//          let nOnly = UInt128(digits: nonrepeating)
//          let nAndR = UInt128(digits: nonrepeating + repeating)
//          denominator = repeating.reduce(0) { $0 + UInt128($1 * 10 + 9) }
//          denominator *= _powersOfTen[nonrepeating.count]
//          numerator = nAndR - nOnly + integer * denominator
//      }
//    }

    let divisor = gcd(numerator, denominator)
    numerator /= divisor
    denominator /= divisor
    self = Fraction(numerator: numerator,
                    denominator: denominator,
                    flags: flags,
                    reducing: false)
    flags.insert(.isReduced)
  }

  /// Calculates the fraction's value over the specified denominator.
  /// - Parameter base: The new denominator for the fraction.
  /// - Returns: The equivalent value for the fraction over `base`.
  public func rebased(_ base: UInt128) -> Fraction {
    guard base != denominator else { return self }
    let numeratorʹ = base < denominator
      ? numerator / denominator / base
      : numerator * base / denominator
    return Fraction(numerator: numeratorʹ, denominator: base, sign: sign)
  }
}

// MARK: Full Width Conversions

public extension Fraction {
  /// The default initializer for full width conversion from a floating point type to
  /// a fraction. For normal values the resulting fraction will be in decimal form
  /// unless `reduce` is `true`, in which case an attempt will be made to reduce the
  /// fraction down from it's decimal form.
  ///
  /// - parameter value:  The value to be converted into a fraction
  init(_ value: Double) {
    guard !value.isSignalingNaN else {
      let payload = UInt128(value.significandBitPattern & ~(UInt64(1) << 50))
      self.init(numerator: payload, flags: .isSignaling, reducing: false)
      return
    }
    guard !value.isNaN else {
      self.init(flags: .isNaN)
      return
    }

    guard !value.isInfinite else {
      self.init(flags: value < 0 ? [.isInfinite, .isNegative] : [.isInfinite])
      return
    }

    let integer: Double = Swift.abs(value).rounded(.towardZero)
    var numerator = UInt128(integer)
    let fractional = Swift.abs(value) - integer
    let digits = Array(fractional.digits().prefix(15))

    let (nonrepeating, repeating) = _split(fractionalNumerator: digits)

    if !repeating.isEmpty {
      // The decimal has a repeating pattern

      let fractionalValue = UInt128(digits: nonrepeating + repeating)
      let nonrepeatingValue = UInt128(digits: nonrepeating)

      let numeratorʹ = fractionalValue &- nonrepeatingValue
      var denominator: UInt128 = 0
      for _ in 0..<repeating.count { denominator = denominator * 10 &+ 9 }
      for _ in 0..<nonrepeating.count { denominator = denominator * 10 }
      numerator *= denominator
      numerator += numeratorʹ
      var flags: Flags = .isRepeating
      if value.sign == .minus { flags.insert(.isNegative) }
      self = Fraction(numerator: numerator,
                      denominator: denominator,
                      flags: (value.sign == .minus
                                ? [.isNegative, .isRepeating]
                                : [.isRepeating]),
                      reducing: false)

    } else {
      // The decimal terminates or does not have a repeating pattern

      let denominator: UInt128 = _pow10(digits.count)
      numerator *= denominator
      numerator += UInt128(digits: digits)
      self = Fraction(numerator: numerator, denominator: denominator, sign: value.sign)
    }

    reduce()
  }

  /// Full width conversion from a `Decimal` to a fraction. The maximum value of both
  /// `Double` and `Decimal` are well above that of `Fraction`; however, there may be
  /// some degree of increased precision in converting from a `Decimal` value versus a
  /// `Double` value. The fraction will be in decimal form unless `reduce` is `true`,
  /// in which case an attempt will be made to reduce the fraction down from it's
  /// decimal form.
  ///
  /// - parameter value:  The value to be converted into a fraction
  /// - parameter reduce: Whether the fraction should be reduced before returning.
  init(_ value: Decimal) {
    guard !value.isSignalingNaN else {
      let bitPattern = (value as NSDecimalNumber).doubleValue.significandBitPattern
      let payload = UInt128(bitPattern & ~(UInt64(1) << 50))
      self.init(numerator: payload, flags: .isSignaling, reducing: false)
      return
    }
    guard !value.isNaN else {
      self.init(flags: .isNaN)
      return
    }

    guard !value.isInfinite else {
      self.init(flags: value < 0 ? [.isInfinite, .isNegative] : [.isInfinite])
      return
    }

    let valueʹ = abs(value)

    let decimalHandler = NSDecimalNumberHandler(roundingMode: .down,
                                                scale: 0,
                                                raiseOnExactness: false,
                                                raiseOnOverflow: false,
                                                raiseOnUnderflow: false,
                                                raiseOnDivideByZero: false)

    let integer = (valueʹ as NSDecimalNumber)
      .rounding(accordingToBehavior: decimalHandler).decimalValue
    let fractional = valueʹ - integer

    var numerator = UInt128(integer)

    let digits = fractional.digits()

    let (nonrepeating, repeating) = _split(fractionalNumerator: digits)
    if !repeating.isEmpty {
      // The decimal has a repeating pattern

      let fractionalValue = UInt128(digits: nonrepeating + repeating)
      let nonrepeatingValue = UInt128(digits: nonrepeating)

      let numeratorʹ = fractionalValue &- nonrepeatingValue
      let denominatorDigits = [UInt8](repeating: 9, count: repeating.count)
        + [UInt8](repeating: 0, count: nonrepeating.count)
      let denominator = UInt128(digits: denominatorDigits)
      numerator *= denominator
      numerator += numeratorʹ

      self = Fraction(numerator: numerator, denominator: denominator, sign: value.sign)
      flags.insert(.isRepeating)

    } else {
      // The decimal terminates or does not have a repeating pattern

      let denominator: UInt128 = power(value: 10, exponent: digits.count,
                                       identity: 1, operation: *)
      numerator *= denominator
      numerator += UInt128(digits: digits)
      self = Fraction(numerator: numerator, denominator: denominator, sign: value.sign)
    }

    reduce()
  }

  /// Full width conversion from an `Int`.
  /// - Parameter value: The integer value.
  init(_ value: Int) {
    self.init(numerator: UInt128(abs(value)),
              denominator: 1,
              sign: value < 0 ? .minus : .plus)
  }
}

// MARK: CustomStringConvertible

extension Fraction: CustomStringConvertible {
  /// Textual represenation of the fraction's value.
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
}

// MARK: Hashable

extension Fraction: Hashable {
  /// Hashes the numerator, denominator, and flag values into the specified `hasher`.
  /// - Parameter hasher: The `Hasher` into which we shall be hashing.
  public func hash(into hasher: inout Hasher) {
    numerator.hash(into: &hasher)
    denominator.hash(into: &hasher)
    flags.rawValue.hash(into: &hasher)
  }
}

// MARK: AdditiveArithmetic

extension Fraction: AdditiveArithmetic {
  /// The zero value.
  ///
  /// Zero is the identity element for addition. For any value,
  /// `x + .zero == x` and `.zero + x == x`.
  public static let zero = Fraction(numerator: 0, denominator: 1, sign: .plus)

  /// Adds two values and produces their sum.
  ///
  /// The addition operator (`+`) calculates the sum of its two arguments. For
  /// example:
  ///
  ///     1 + 2                   // 3
  ///     -10 + 15                // 5
  ///     -15 + -5                // -20
  ///     21.5 + 3.25             // 24.75
  ///
  /// You cannot use `+` with arguments of different types. To add values of
  /// different types, convert one of the values to the other value's type.
  ///
  ///     let x: Int8 = 21
  ///     let y: Int = 1000000
  ///     Int(x) + y              // 1000021
  ///
  /// - Parameters:
  ///   - lhs: The first value to add.
  ///   - rhs: The second value to add.
  public static func + (lhs: Self, rhs: Self) -> Self { _add(lhs, rhs) }

  /// Adds two values and stores the result in the left-hand-side variable.
  ///
  /// - Parameters:
  ///   - lhs: The first value to add.
  ///   - rhs: The second value to add.
  public static func += (lhs: inout Self, rhs: Self) { lhs = lhs + rhs }

  /// Subtracts one value from another and produces their difference.
  ///
  /// The subtraction operator (`-`) calculates the difference of its two
  /// arguments. For example:
  ///
  ///     8 - 3                   // 5
  ///     -10 - 5                 // -15
  ///     100 - -5                // 105
  ///     10.5 - 100.0            // -89.5
  ///
  /// You cannot use `-` with arguments of different types. To subtract values
  /// of different types, convert one of the values to the other value's type.
  ///
  ///     let x: UInt8 = 21
  ///     let y: UInt = 1000000
  ///     y - UInt(x)             // 999979
  ///
  /// - Parameters:
  ///   - lhs: A numeric value.
  ///   - rhs: The value to subtract from `lhs`.
  public static func - (lhs: Self, rhs: Self) -> Self { _subtract(lhs, rhs) }

  /// Subtracts the second value from the first and stores the difference in the
  /// left-hand-side variable.
  ///
  /// - Parameters:
  ///   - lhs: A numeric value.
  ///   - rhs: The value to subtract from `lhs`.
  public static func -= (lhs: inout Self, rhs: Self) { lhs = lhs - rhs }
}

// MARK: ExpressibleByIntegerLiteral

extension Fraction: ExpressibleByIntegerLiteral {
  /// Creates an instance initialized to the specified integer value.
  ///
  /// Do not call this initializer directly. Instead, initialize a variable or
  /// constant using an integer literal. For example:
  ///
  ///     let x = 23
  ///
  /// In this example, the assignment to the `x` constant calls this integer
  /// literal initializer behind the scenes.
  ///
  /// - Parameter value: The value to create.
  public init(integerLiteral value: Int) {
    self.init(numerator: UInt128(abs(value)),
              denominator: 1,
              sign: value < 0 ? .minus : .plus)
  }
}

// MARK: Numeric

extension Fraction: Numeric {
  /// Creates a new instance from the given integer, if it can be represented
  /// exactly.
  ///
  /// If the value passed as `source` is not representable exactly, the result
  /// is `nil`. In the following example, the constant `x` is successfully
  /// created from a value of `100`, while the attempt to initialize the
  /// constant `y` from `1_000` fails because the `Int8` type can represent
  /// `127` at maximum:
  ///
  ///     let x = Int8(exactly: 100)
  ///     // x == Optional(100)
  ///     let y = Int8(exactly: 1_000)
  ///     // y == nil
  ///
  /// - Parameter source: A value to convert to this type.
  public init?<T>(exactly source: T) where T: BinaryInteger {
    self.init(source)
  }

  /// A type that can represent the absolute value of any possible value of the
  /// conforming type.
  public typealias Magnitude = Self

  /// The magnitude of this value.
  ///
  /// For any numeric value `x`, `x.magnitude` is the absolute value of `x`.
  /// You can use the `magnitude` property in operations that are simpler to
  /// implement in terms of unsigned values, such as printing the value of an
  /// integer, which is just printing a '-' character in front of an absolute
  /// value.
  ///
  ///     let x = -200
  ///     // x.magnitude == 200
  ///
  /// The global `abs(_:)` function provides more familiar syntax when you need
  /// to find an absolute value. In addition, because `abs(_:)` always returns
  /// a value of the same type, even in a generic context, using the function
  /// instead of the `magnitude` property is encouraged.
  public var magnitude: Self.Magnitude {
    Fraction(numerator: numerator, denominator: denominator, sign: .plus)
  }

  /// Multiplies two values and produces their product.
  ///
  /// The multiplication operator (`*`) calculates the product of its two
  /// arguments. For example:
  ///
  ///     2 * 3                   // 6
  ///     100 * 21                // 2100
  ///     -10 * 15                // -150
  ///     3.5 * 2.25              // 7.875
  ///
  /// You cannot use `*` with arguments of different types. To multiply values
  /// of different types, convert one of the values to the other value's type.
  ///
  ///     let x: Int8 = 21
  ///     let y: Int = 1000000
  ///     Int(x) * y              // 21000000
  ///
  /// - Parameters:
  ///   - lhs: The first value to multiply.
  ///   - rhs: The second value to multiply.
  public static func * (lhs: Self, rhs: Self) -> Self { _multiply(lhs, rhs) }

  /// Multiplies two values and stores the result in the left-hand-side
  /// variable.
  ///
  /// - Parameters:
  ///   - lhs: The first value to multiply.
  ///   - rhs: The second value to multiply.
  public static func *= (lhs: inout Self, rhs: Self) { lhs = lhs * rhs }
}

// MARK: SignedNumeric

extension Fraction: SignedNumeric {
  /// Returns the additive inverse of the specified value.
  ///
  /// The negation operator (prefix `-`) returns the additive inverse of its
  /// argument.
  ///
  ///     let x = 21
  ///     let y = -x
  ///     // y == -21
  ///
  /// The resulting value must be representable in the same type as the
  /// argument. In particular, negating a signed, fixed-width integer type's
  /// minimum results in a value that cannot be represented.
  ///
  ///     let z = -Int8.min
  ///     // Overflow error
  ///
  /// - Returns: The additive inverse of this value.
  public static prefix func - (operand: Self) -> Self {
    var result = operand
    result.negate()
    return result
  }

  /// Replaces this value with its additive inverse.
  ///
  /// The following example uses the `negate()` method to negate the value of
  /// an integer `x`:
  ///
  ///     var x = 21
  ///     x.negate()
  ///     // x == -21
  ///
  /// The resulting value must be representable within the value's type. In
  /// particular, negating a signed, fixed-width integer type's minimum
  /// results in a value that cannot be represented.
  ///
  ///     var y = Int8.min
  ///     y.negate()
  ///     // Overflow error
  public mutating func negate() {
    if flags ∋ .isNegative { flags.remove(.isNegative) }
    else { flags.insert(.isNegative) }
  }
}

// MARK: Strideable

extension Fraction: Strideable {
  /// Returns the distance from this value to the given value, expressed as a
  /// stride.
  ///
  /// If this type's `Stride` type conforms to `BinaryInteger`, then for two
  /// values `x` and `y`, and a distance `n = x.distance(to: y)`,
  /// `x.advanced(by: n) == y`. Using this method with types that have a
  /// noninteger `Stride` may result in an approximation.
  ///
  /// - Parameter other: The value to calculate the distance to.
  /// - Returns: The distance from this value to `other`.
  ///
  /// - Complexity: O(1)
  public func distance(to other: Self) -> Self { other - self }

  /// Returns a value that is offset the specified distance from this value.
  ///
  /// Use the `advanced(by:)` method in generic code to offset a value by a
  /// specified distance. If you're working directly with numeric values, use
  /// the addition operator (`+`) instead of this method.
  ///
  ///     func addOne<T: Strideable>(to x: T) -> T
  ///         where T.Stride: ExpressibleByIntegerLiteral
  ///     {
  ///         return x.advanced(by: 1)
  ///     }
  ///
  ///     let x = addOne(to: 5)
  ///     // x == 6
  ///     let y = addOne(to: 3.5)
  ///     // y = 4.5
  ///
  /// If this type's `Stride` type conforms to `BinaryInteger`, then for a
  /// value `x`, a distance `n`, and a value `y = x.advanced(by: n)`,
  /// `x.distance(to: y) == n`. Using this method with types that have a
  /// noninteger `Stride` may result in an approximation.
  ///
  /// - Parameter n: The distance to advance this value.
  /// - Returns: A value that is offset from this value by `n`.
  ///
  /// - Complexity: O(1)
  public func advanced(by n: Self) -> Self { self + n }
}

// MARK: FloatingPoint

extension Fraction: FloatingPoint {
  /// Creates a new value from the given sign, exponent, and significand.
  ///
  /// The following example uses this initializer to create a new `Double`
  /// instance. `Double` is a binary floating-point type that has a radix of
  /// `2`.
  ///
  ///     let x = Double(sign: .plus, exponent: -2, significand: 1.5)
  ///     // x == 0.375
  ///
  /// This initializer is equivalent to the following calculation, where `**`
  /// is exponentiation, computed as if by a single, correctly rounded,
  /// floating-point operation:
  ///
  ///     let sign: FloatingPointSign = .plus
  ///     let exponent = -2
  ///     let significand = 1.5
  ///     let y = (sign == .minus ? -1 : 1) * significand * Double.radix ** exponent
  ///     // y == 0.375
  ///
  /// As with any basic operation, if this value is outside the representable
  /// range of the type, overflow or underflow occurs, and zero, a subnormal
  /// value, or infinity may result. In addition, there are two other edge
  /// cases:
  ///
  /// - If the value you pass to `significand` is zero or infinite, the result
  ///   is zero or infinite, regardless of the value of `exponent`.
  /// - If the value you pass to `significand` is NaN, the result is NaN.
  ///
  /// For any floating-point value `x` of type `F`, the result of the following
  /// is equal to `x`, with the distinction that the result is canonicalized
  /// if `x` is in a noncanonical encoding:
  ///
  ///     let x0 = F(sign: x.sign, exponent: x.exponent, significand: x.significand)
  ///
  /// This initializer implements the `scaleB` operation defined by the [IEEE
  /// 754 specification][spec].
  ///
  /// [spec]: http://ieeexplore.ieee.org/servlet/opac?punumber=4610933
  ///
  /// - Parameters:
  ///   - sign: The sign to use for the new value.
  ///   - exponent: The new value's exponent.
  ///   - significand: The new value's significand.
  public init(sign: FloatingPointSign, exponent: Int, significand: Self) {
    guard !significand.isNaN else {
      self.init(flags: sign == .minus ? [.isNegative, .isNaN] : [.isNaN])
      return
    }

    guard !significand.isInfinite else {
      self.init(flags: sign == .minus ? [.isNegative, .isInfinite] : [.isInfinite])
      return
    }

    let multiplier = _pow10(abs(exponent))
    if exponent > 0 {
      self = significand * multiplier÷1
    } else {
      self = significand * 1÷multiplier
    }

    if sign == .minus { flags.insert(.isNegative) }

//    let (integer, nonrepeating, repeating) = exponent < 0
//      ? _split(numerator: significand.numerator, exponent: Swift.abs(exponent))
//      : _split(numerator: _powersOfTen[Swift.abs(exponent)] * significand.numerator,
//               exponent: 0)
//
//    self.init(sign: sign,
//              integer: integer,
//              nonrepeating: nonrepeating,
//              repeating: repeating,
//              reducing: true)
  }

  /// Creates a new floating-point value using the sign of one value and the
  /// magnitude of another.
  ///
  /// The following example uses this initializer to create a new `Double`
  /// instance with the sign of `a` and the magnitude of `b`:
  ///
  ///     let a = -21.5
  ///     let b = 305.15
  ///     let c = Double(signOf: a, magnitudeOf: b)
  ///     print(c)
  ///     // Prints "-305.15"
  ///
  /// This initializer implements the IEEE 754 `copysign` operation.
  ///
  /// - Parameters:
  ///   - signOf: A value from which to use the sign. The result of the
  ///     initializer has the same sign as `signOf`.
  ///   - magnitudeOf: A value from which to use the magnitude. The result of
  ///     the initializer has the same magnitude as `magnitudeOf`.
  public init(signOf: Self, magnitudeOf: Self) {
    self = magnitudeOf
    if signOf.sign == .minus { flags.insert(.isNegative) }
    else { flags.remove(.isNegative) }
  }

  /// Creates a new value, rounded to the closest possible representation.
  ///
  /// If two representable values are equally close, the result is the value
  /// with more trailing zeros in its significand bit pattern.
  ///
  /// - Parameter value: The integer to convert to a floating-point value.
  public init<Source>(_ value: Source) where Source: BinaryInteger {
    self.init(numerator: UInt128(value.magnitude),
              denominator: 1,
              sign: value < 0 ? .minus : .plus)
  }

  /// The radix, or base of exponentiation, for a fraction.
  ///
  /// The magnitude of a floating-point value `x` of type `F` can be calculated
  /// by using the following formula, where `**` is exponentiation:
  ///
  ///     let magnitude = x.significand * F.radix ** x.exponent
  ///
  /// A conforming type may use any integer radix, but values other than 2 (for
  /// binary floating-point types) or 10 (for decimal floating-point types)
  /// are extraordinarily rare in practice.
  public static let radix = 10

  /// A quiet NaN ("not a number").
  ///
  /// A NaN compares not equal, not greater than, and not less than every
  /// value, including itself. Passing a NaN to an operation generally results
  /// in NaN.
  ///
  ///     let x = 1.21
  ///     // x > Double.nan == false
  ///     // x < Double.nan == false
  ///     // x == Double.nan == false
  ///
  /// Because a NaN always compares not equal to itself, to test whether a
  /// floating-point value is NaN, use its `isNaN` property instead of the
  /// equal-to operator (`==`). In the following example, `y` is NaN.
  ///
  ///     let y = x + Double.nan
  ///     print(y == Double.nan)
  ///     // Prints "false"
  ///     print(y.isNaN)
  ///     // Prints "true"
  public static let nan = Fraction(flags: .isNaN)

  /// A signaling NaN ("not a number").
  ///
  /// The default IEEE 754 behavior of operations involving a signaling NaN is
  /// to raise the Invalid flag in the floating-point environment and return a
  /// quiet NaN.
  ///
  /// Operations on types conforming to the `FloatingPoint` protocol should
  /// support this behavior, but they might also support other options. For
  /// example, it would be reasonable to implement alternative operations in
  /// which operating on a signaling NaN triggers a runtime error or results
  /// in a diagnostic for debugging purposes. Types that implement alternative
  /// behaviors for a signaling NaN must document the departure.
  ///
  /// Other than these signaling operations, a signaling NaN behaves in the
  /// same manner as a quiet NaN.
  public static let signalingNaN = Fraction(flags: .isSignaling)

  /// Positive infinity.
  ///
  /// Infinity compares greater than all finite numbers and equal to other
  /// infinite values.
  ///
  ///     let x = Double.greatestFiniteMagnitude
  ///     let y = x * 2
  ///     // y == Double.infinity
  ///     // y > x
  public static let infinity = Fraction(flags: .isInfinite)

  /// The greatest finite number representable by this type.
  ///
  /// This value compares greater than or equal to all finite numbers, but less
  /// than `infinity`.
  ///
  /// This value corresponds to type-specific C macros such as `FLT_MAX` and
  /// `DBL_MAX`. The naming of those macros is slightly misleading, because
  /// `infinity` is greater than this value.
  public static let greatestFiniteMagnitude = Fraction(numerator: .max, denominator: 1)

  /// The mathematical constant pi.
  ///
  /// This value should be rounded toward zero to keep user computations with
  /// angles from inadvertently ending up in the wrong quadrant. A type that
  /// conforms to the `FloatingPoint` protocol provides the value for `pi` at
  /// its best possible precision.
  ///
  ///     print(Double.pi)
  ///     // Prints "3.14159265358979"
  public static let pi = Fraction(numerator: UInt128(low: 0xaae7b57d8c88bd6a,
                                                     high: 0x17a27cc3ed6cf7ee),
                                  denominator: _pow10(37))

  /// The unit in the last place of this value.
  ///
  /// This is the unit of the least significant digit in this value's
  /// significand. For most numbers `x`, this is the difference between `x`
  /// and the next greater (in magnitude) representable number. There are some
  /// edge cases to be aware of:
  ///
  /// - If `x` is not a finite number, then `x.ulp` is NaN.
  /// - If `x` is very small in magnitude, then `x.ulp` may be a subnormal
  ///   number. If a type does not support subnormals, `x.ulp` may be rounded
  ///   to zero.
  /// - `greatestFiniteMagnitude.ulp` is a finite number, even though the next
  ///   greater representable value is `infinity`.
  ///
  /// See also the `ulpOfOne` static property.
  public var ulp: Self { isFinite ? .leastNonzeroMagnitude : .nan }

  /// The unit in the last place of 1.0.
  ///
  /// The positive difference between 1.0 and the next greater representable
  /// number. `ulpOfOne` corresponds to the value represented by the C macros
  /// `FLT_EPSILON`, `DBL_EPSILON`, etc, and is sometimes called *epsilon* or
  /// *machine epsilon*. Swift deliberately avoids using the term "epsilon"
  /// because:
  ///
  /// - Historically "epsilon" has been used to refer to several different
  ///   concepts in different languages, leading to confusion and bugs.
  ///
  /// - The name "epsilon" suggests that this quantity is a good tolerance to
  ///   choose for approximate comparisons, but it is almost always unsuitable
  ///   for that purpose.
  ///
  /// See also the `ulp` member property.
  public static var ulpOfOne: Self { .leastNonzeroMagnitude }

  /// The least positive normal number.
  ///
  /// This value compares less than or equal to all positive normal numbers.
  /// There may be smaller positive numbers, but they are *subnormal*, meaning
  /// that they are represented with less precision than normal numbers.
  ///
  /// This value corresponds to type-specific C macros such as `FLT_MIN` and
  /// `DBL_MIN`. The naming of those macros is slightly misleading, because
  /// subnormals, zeros, and negative numbers are smaller than this value.
  public static var leastNormalMagnitude: Self { .leastNonzeroMagnitude }

  /// The least positive number.
  ///
  /// This value compares less than or equal to all positive numbers, but
  /// greater than zero. If the type supports subnormal values,
  /// `leastNonzeroMagnitude` is smaller than `leastNormalMagnitude`;
  /// otherwise they are equal.
  public static let leastNonzeroMagnitude = Fraction(numerator: 1, denominator: .max)

  /// The sign of the floating-point value.
  ///
  /// The `sign` property is `.minus` if the value's signbit is set, and
  /// `.plus` otherwise. For example:
  ///
  ///     let x = -33.375
  ///     // x.sign == .minus
  ///
  /// Do not use this property to check whether a floating point value is
  /// negative. For a value `x`, the comparison `x.sign == .minus` is not
  /// necessarily the same as `x < 0`. In particular, `x.sign == .minus` if
  /// `x` is -0, and while `x < 0` is always `false` if `x` is NaN, `x.sign`
  /// could be either `.plus` or `.minus`.
  public var sign: FloatingPointSign { flags ∋ .isNegative ? .minus : .plus }

  /// The exponent of the floating-point value.
  ///
  /// The *exponent* of a floating-point value is the integer part of the
  /// logarithm of the value's magnitude. For a value `x` of a floating-point
  /// type `F`, the magnitude can be calculated as the following, where `**`
  /// is exponentiation:
  ///
  ///     let magnitude = x.significand * F.radix ** x.exponent
  ///
  /// In the next example, `y` has a value of `21.5`, which is encoded as
  /// `1.34375 * 2 ** 4`. The significand of `y` is therefore 1.34375.
  ///
  ///     let y: Double = 21.5
  ///     // y.significand == 1.34375
  ///     // y.exponent == 4
  ///     // Double.radix == 2
  ///
  /// The `exponent` property has the following edge cases:
  ///
  /// - If `x` is zero, then `x.exponent` is `Int.min`.
  /// - If `x` is +/-infinity or NaN, then `x.exponent` is `Int.max`
  ///
  /// This property implements the `logB` operation defined by the [IEEE 754
  /// specification][spec].
  ///
  /// [spec]: http://ieeexplore.ieee.org/servlet/opac?punumber=4610933
  public var exponent: Int {
    isNaN || isInfinite ? .max : (isZero ? 0 : -_log10(decimalForm.denominator))
  }

  /// The significand of the floating-point value.
  ///
  /// The magnitude of a floating-point value `x` of type `F` can be calculated
  /// by using the following formula, where `**` is exponentiation:
  ///
  ///     let magnitude = x.significand * F.radix ** x.exponent
  ///
  /// In the next example, `y` has a value of `21.5`, which is encoded as
  /// `1.34375 * 2 ** 4`. The significand of `y` is therefore 1.34375.
  ///
  ///     let y: Double = 21.5
  ///     // y.significand == 1.34375
  ///     // y.exponent == 4
  ///     // Double.radix == 2
  ///
  /// If a type's radix is 2, then for finite nonzero numbers, the significand
  /// is in the range `1.0 ..< 2.0`. For other values of `x`, `x.significand`
  /// is defined as follows:
  ///
  /// - If `x` is zero, then `x.significand` is 0.0.
  /// - If `x` is infinite, then `x.significand` is infinity.
  /// - If `x` is NaN, then `x.significand` is NaN.
  /// - Note: The significand is frequently also called the *mantissa*, but
  ///   significand is the preferred terminology in the [IEEE 754
  ///   specification][spec], to allay confusion with the use of mantissa for
  ///   the fractional part of a logarithm.
  ///
  /// [spec]: http://ieeexplore.ieee.org/servlet/opac?punumber=4610933
  public var significand: Self {
    isNaN
      ? .nan
      : (isInfinite
        ? .infinity
        : (isZero
          ? .zero
          : Fraction(numerator: decimalForm.numerator, denominator: 1, sign: sign)))
  }

  /// Returns the quotient of dividing the first value by the second, rounded
  /// to a representable value.
  ///
  /// The division operator (`/`) calculates the quotient of the division if
  /// `rhs` is nonzero. If `rhs` is zero, the result of the division is
  /// infinity, with the sign of the result matching the sign of `lhs`.
  ///
  ///     let x = 16.875
  ///     let y = x / 2.25
  ///     // y == 7.5
  ///
  ///     let z = x / 0
  ///     // z.isInfinite == true
  ///
  /// The `/` operator implements the division operation defined by the [IEEE
  /// 754 specification][spec].
  ///
  /// [spec]: http://ieeexplore.ieee.org/servlet/opac?punumber=4610933
  ///
  /// - Parameters:
  ///   - lhs: The value to divide.
  ///   - rhs: The value to divide `lhs` by.
  public static func / (lhs: Self, rhs: Self) -> Self { _divide(lhs, rhs) }

  /// Divides the first value by the second and stores the quotient in the
  /// left-hand-side variable, rounding to a representable value.
  ///
  /// - Parameters:
  ///   - lhs: The value to divide.
  ///   - rhs: The value to divide `lhs` by.
  public static func /= (lhs: inout Self, rhs: Self) { lhs = lhs / rhs }

  /// Returns the remainder of this value divided by the given value.
  ///
  /// For two finite values `x` and `y`, the remainder `r` of dividing `x` by
  /// `y` satisfies `x == y * q + r`, where `q` is the integer nearest to
  /// `x / y`. If `x / y` is exactly halfway between two integers, `q` is
  /// chosen to be even. Note that `q` is *not* `x / y` computed in
  /// floating-point arithmetic, and that `q` may not be representable in any
  /// available integer type.
  ///
  /// The following example calculates the remainder of dividing 8.625 by 0.75:
  ///
  ///     let x = 8.625
  ///     print(x / 0.75)
  ///     // Prints "11.5"
  ///
  ///     let q = (x / 0.75).rounded(.toNearestOrEven)
  ///     // q == 12.0
  ///     let r = x.remainder(dividingBy: 0.75)
  ///     // r == -0.375
  ///
  ///     let x1 = 0.75 * q + r
  ///     // x1 == 8.625
  ///
  /// If this value and `other` are finite numbers, the remainder is in the
  /// closed range `-abs(other / 2)...abs(other / 2)`. The
  /// `remainder(dividingBy:)` method is always exact. This method implements
  /// the remainder operation defined by the [IEEE 754 specification][spec].
  ///
  /// [spec]: http://ieeexplore.ieee.org/servlet/opac?punumber=4610933
  ///
  /// - Parameter other: The value to use when dividing this value.
  /// - Returns: The remainder of this value divided by `other`.
  public func remainder(dividingBy other: Self) -> Self { _remainder(self, other) }

  /// Replaces this value with the remainder of itself divided by the given
  /// value.
  ///
  /// For two finite values `x` and `y`, the remainder `r` of dividing `x` by
  /// `y` satisfies `x == y * q + r`, where `q` is the integer nearest to
  /// `x / y`. If `x / y` is exactly halfway between two integers, `q` is
  /// chosen to be even. Note that `q` is *not* `x / y` computed in
  /// floating-point arithmetic, and that `q` may not be representable in any
  /// available integer type.
  ///
  /// The following example calculates the remainder of dividing 8.625 by 0.75:
  ///
  ///     var x = 8.625
  ///     print(x / 0.75)
  ///     // Prints "11.5"
  ///
  ///     let q = (x / 0.75).rounded(.toNearestOrEven)
  ///     // q == 12.0
  ///     x.formRemainder(dividingBy: 0.75)
  ///     // x == -0.375
  ///
  ///     let x1 = 0.75 * q + x
  ///     // x1 == 8.625
  ///
  /// If this value and `other` are finite numbers, the remainder is in the
  /// closed range `-abs(other / 2)...abs(other / 2)`. The
  /// `formRemainder(dividingBy:)` method is always exact.
  ///
  /// - Parameter other: The value to use when dividing this value.
  public mutating func formRemainder(dividingBy other: Self) {
    self = _remainder(self, other)
  }

  /// Returns the remainder of this value divided by the given value using
  /// truncating division.
  ///
  /// Performing truncating division with floating-point values results in a
  /// truncated integer quotient and a remainder. For values `x` and `y` and
  /// their truncated integer quotient `q`, the remainder `r` satisfies
  /// `x == y * q + r`.
  ///
  /// The following example calculates the truncating remainder of dividing
  /// 8.625 by 0.75:
  ///
  ///     let x = 8.625
  ///     print(x / 0.75)
  ///     // Prints "11.5"
  ///
  ///     let q = (x / 0.75).rounded(.towardZero)
  ///     // q == 11.0
  ///     let r = x.truncatingRemainder(dividingBy: 0.75)
  ///     // r == 0.375
  ///
  ///     let x1 = 0.75 * q + r
  ///     // x1 == 8.625
  ///
  /// If this value and `other` are both finite numbers, the truncating
  /// remainder has the same sign as this value and is strictly smaller in
  /// magnitude than `other`. The `truncatingRemainder(dividingBy:)` method
  /// is always exact.
  ///
  /// - Parameter other: The value to use when dividing this value.
  /// - Returns: The remainder of this value divided by `other` using
  ///   truncating division.
  public func truncatingRemainder(dividingBy other: Self) -> Self {
    _truncatingRemainder(self, other)
  }

  /// Replaces this value with the remainder of itself divided by the given
  /// value using truncating division.
  ///
  /// Performing truncating division with floating-point values results in a
  /// truncated integer quotient and a remainder. For values `x` and `y` and
  /// their truncated integer quotient `q`, the remainder `r` satisfies
  /// `x == y * q + r`.
  ///
  /// The following example calculates the truncating remainder of dividing
  /// 8.625 by 0.75:
  ///
  ///     var x = 8.625
  ///     print(x / 0.75)
  ///     // Prints "11.5"
  ///
  ///     let q = (x / 0.75).rounded(.towardZero)
  ///     // q == 11.0
  ///     x.formTruncatingRemainder(dividingBy: 0.75)
  ///     // x == 0.375
  ///
  ///     let x1 = 0.75 * q + x
  ///     // x1 == 8.625
  ///
  /// If this value and `other` are both finite numbers, the truncating
  /// remainder has the same sign as this value and is strictly smaller in
  /// magnitude than `other`. The `formTruncatingRemainder(dividingBy:)`
  /// method is always exact.
  ///
  /// - Parameter other: The value to use when dividing this value.
  public mutating func formTruncatingRemainder(dividingBy other: Self) {
    self = _truncatingRemainder(self, other)
  }

  /// Returns the square root of the value, rounded to a representable value.
  ///
  /// The following example declares a function that calculates the length of
  /// the hypotenuse of a right triangle given its two perpendicular sides.
  ///
  ///     func hypotenuse(_ a: Double, _ b: Double) -> Double {
  ///         return (a * a + b * b).squareRoot()
  ///     }
  ///
  ///     let (dx, dy) = (3.0, 4.0)
  ///     let distance = hypotenuse(dx, dy)
  ///     // distance == 5.0
  ///
  /// - Returns: The square root of the value.
  public func squareRoot() -> Self { _squareRoot(self) }

  /// Replaces this value with its square root, rounded to a representable
  /// value.
  public mutating func formSquareRoot() { self = _squareRoot(self) }

  /// Returns the result of adding the product of the two given values to this
  /// value, computed without intermediate rounding.
  ///
  /// This method is equivalent to the C `fma` function and implements the
  /// `fusedMultiplyAdd` operation defined by the [IEEE 754
  /// specification][spec].
  ///
  /// [spec]: http://ieeexplore.ieee.org/servlet/opac?punumber=4610933
  ///
  /// - Parameters:
  ///   - lhs: One of the values to multiply before adding to this value.
  ///   - rhs: The other value to multiply.
  /// - Returns: The product of `lhs` and `rhs`, added to this value.
  public func addingProduct(_ lhs: Self, _ rhs: Self) -> Self {
    _addProduct(self, lhs, rhs)
  }

  /// Adds the product of the two given values to this value in place, computed
  /// without intermediate rounding.
  ///
  /// - Parameters:
  ///   - lhs: One of the values to multiply before adding to this value.
  ///   - rhs: The other value to multiply.
  public mutating func addProduct(_ lhs: Self, _ rhs: Self) {
    self = _addProduct(self, lhs, rhs)
  }

  /// Returns the lesser of the two given values.
  ///
  /// This method returns the minimum of two values, preserving order and
  /// eliminating NaN when possible. For two values `x` and `y`, the result of
  /// `minimum(x, y)` is `x` if `x <= y`, `y` if `y < x`, or whichever of `x`
  /// or `y` is a number if the other is a quiet NaN. If both `x` and `y` are
  /// NaN, or either `x` or `y` is a signaling NaN, the result is NaN.
  ///
  ///     Double.minimum(10.0, -25.0)
  ///     // -25.0
  ///     Double.minimum(10.0, .nan)
  ///     // 10.0
  ///     Double.minimum(.nan, -25.0)
  ///     // -25.0
  ///     Double.minimum(.nan, .nan)
  ///     // nan
  ///
  /// The `minimum` method implements the `minNum` operation defined by the
  /// [IEEE 754 specification][spec].
  ///
  /// [spec]: http://ieeexplore.ieee.org/servlet/opac?punumber=4610933
  ///
  /// - Parameters:
  ///   - x: A floating-point value.
  ///   - y: Another floating-point value.
  /// - Returns: The minimum of `x` and `y`, or whichever is a number if the
  ///   other is NaN.
  public static func minimum(_ x: Self, _ y: Self) -> Self {
    guard !x.isSignalingNaN,
          !y.isSignalingNaN,
          !x.isNaN || !y.isNaN else { return .nan }

    return x.isNaN ? y : (y.isNaN ? x : (_isLessThanOrEqual(x, y) ? x : y))
  }

  /// Returns the greater of the two given values.
  ///
  /// This method returns the maximum of two values, preserving order and
  /// eliminating NaN when possible. For two values `x` and `y`, the result of
  /// `maximum(x, y)` is `x` if `x > y`, `y` if `x <= y`, or whichever of `x`
  /// or `y` is a number if the other is a quiet NaN. If both `x` and `y` are
  /// NaN, or either `x` or `y` is a signaling NaN, the result is NaN.
  ///
  ///     Double.maximum(10.0, -25.0)
  ///     // 10.0
  ///     Double.maximum(10.0, .nan)
  ///     // 10.0
  ///     Double.maximum(.nan, -25.0)
  ///     // -25.0
  ///     Double.maximum(.nan, .nan)
  ///     // nan
  ///
  /// The `maximum` method implements the `maxNum` operation defined by the
  /// [IEEE 754 specification][spec].
  ///
  /// [spec]: http://ieeexplore.ieee.org/servlet/opac?punumber=4610933
  ///
  /// - Parameters:
  ///   - x: A floating-point value.
  ///   - y: Another floating-point value.
  /// - Returns: The greater of `x` and `y`, or whichever is a number if the
  ///   other is NaN.
  public static func maximum(_ x: Self, _ y: Self) -> Self {
    guard !x.isSignalingNaN,
          !y.isSignalingNaN,
          !x.isNaN || !y.isNaN else { return .nan }

    return x.isNaN ? y : (y.isNaN ? x : (_isLessThanOrEqual(x, y) ? y : x))
  }

  /// Returns the value with lesser magnitude.
  ///
  /// This method returns the value with lesser magnitude of the two given
  /// values, preserving order and eliminating NaN when possible. For two
  /// values `x` and `y`, the result of `minimumMagnitude(x, y)` is `x` if
  /// `x.magnitude <= y.magnitude`, `y` if `y.magnitude < x.magnitude`, or
  /// whichever of `x` or `y` is a number if the other is a quiet NaN. If both
  /// `x` and `y` are NaN, or either `x` or `y` is a signaling NaN, the result
  /// is NaN.
  ///
  ///     Double.minimumMagnitude(10.0, -25.0)
  ///     // 10.0
  ///     Double.minimumMagnitude(10.0, .nan)
  ///     // 10.0
  ///     Double.minimumMagnitude(.nan, -25.0)
  ///     // -25.0
  ///     Double.minimumMagnitude(.nan, .nan)
  ///     // nan
  ///
  /// The `minimumMagnitude` method implements the `minNumMag` operation
  /// defined by the [IEEE 754 specification][spec].
  ///
  /// [spec]: http://ieeexplore.ieee.org/servlet/opac?punumber=4610933
  ///
  /// - Parameters:
  ///   - x: A floating-point value.
  ///   - y: Another floating-point value.
  /// - Returns: Whichever of `x` or `y` has lesser magnitude, or whichever is
  ///   a number if the other is NaN.
  public static func minimumMagnitude(_ x: Self, _ y: Self) -> Self {
    minimum(x.magnitude, y.magnitude)
  }

  /// Returns the value with greater magnitude.
  ///
  /// This method returns the value with greater magnitude of the two given
  /// values, preserving order and eliminating NaN when possible. For two
  /// values `x` and `y`, the result of `maximumMagnitude(x, y)` is `x` if
  /// `x.magnitude > y.magnitude`, `y` if `x.magnitude <= y.magnitude`, or
  /// whichever of `x` or `y` is a number if the other is a quiet NaN. If both
  /// `x` and `y` are NaN, or either `x` or `y` is a signaling NaN, the result
  /// is NaN.
  ///
  ///     Double.maximumMagnitude(10.0, -25.0)
  ///     // -25.0
  ///     Double.maximumMagnitude(10.0, .nan)
  ///     // 10.0
  ///     Double.maximumMagnitude(.nan, -25.0)
  ///     // -25.0
  ///     Double.maximumMagnitude(.nan, .nan)
  ///     // nan
  ///
  /// The `maximumMagnitude` method implements the `maxNumMag` operation
  /// defined by the [IEEE 754 specification][spec].
  ///
  /// [spec]: http://ieeexplore.ieee.org/servlet/opac?punumber=4610933
  ///
  /// - Parameters:
  ///   - x: A floating-point value.
  ///   - y: Another floating-point value.
  /// - Returns: Whichever of `x` or `y` has greater magnitude, or whichever is
  ///   a number if the other is NaN.
  public static func maximumMagnitude(_ x: Self, _ y: Self) -> Self {
    maximum(x.magnitude, y.magnitude)
  }

  /// Returns this value rounded to an integral value using the specified
  /// rounding rule.
  ///
  /// The following example rounds a value using four different rounding rules:
  ///
  ///     let x = 6.5
  ///
  ///     // Equivalent to the C 'round' function:
  ///     print(x.rounded(.toNearestOrAwayFromZero))
  ///     // Prints "7.0"
  ///
  ///     // Equivalent to the C 'trunc' function:
  ///     print(x.rounded(.towardZero))
  ///     // Prints "6.0"
  ///
  ///     // Equivalent to the C 'ceil' function:
  ///     print(x.rounded(.up))
  ///     // Prints "7.0"
  ///
  ///     // Equivalent to the C 'floor' function:
  ///     print(x.rounded(.down))
  ///     // Prints "6.0"
  ///
  /// For more information about the available rounding rules, see the
  /// `FloatingPointRoundingRule` enumeration. To round a value using the
  /// default "schoolbook rounding", you can use the shorter `rounded()`
  /// method instead.
  ///
  ///     print(x.rounded())
  ///     // Prints "7.0"
  ///
  /// - Parameter rule: The rounding rule to use.
  /// - Returns: The integral value found by rounding using `rule`.
  public func rounded(_ rule: FloatingPointRoundingRule) -> Self { _round(self, rule) }

  /// Rounds the value to an integral value using the specified rounding rule.
  ///
  /// The following example rounds a value using four different rounding rules:
  ///
  ///     // Equivalent to the C 'round' function:
  ///     var w = 6.5
  ///     w.round(.toNearestOrAwayFromZero)
  ///     // w == 7.0
  ///
  ///     // Equivalent to the C 'trunc' function:
  ///     var x = 6.5
  ///     x.round(.towardZero)
  ///     // x == 6.0
  ///
  ///     // Equivalent to the C 'ceil' function:
  ///     var y = 6.5
  ///     y.round(.up)
  ///     // y == 7.0
  ///
  ///     // Equivalent to the C 'floor' function:
  ///     var z = 6.5
  ///     z.round(.down)
  ///     // z == 6.0
  ///
  /// For more information about the available rounding rules, see the
  /// `FloatingPointRoundingRule` enumeration. To round a value using the
  /// default "schoolbook rounding", you can use the shorter `round()` method
  /// instead.
  ///
  ///     var w1 = 6.5
  ///     w1.round()
  ///     // w1 == 7.0
  ///
  /// - Parameter rule: The rounding rule to use.
  public mutating func round(_ rule: FloatingPointRoundingRule) {
    self = _round(self, rule)
  }

  /// The least representable value that compares greater than this value.
  ///
  /// For any finite value `x`, `x.nextUp` is greater than `x`. For `nan` or
  /// `infinity`, `x.nextUp` is `x` itself. The following special cases also
  /// apply:
  ///
  /// - If `x` is `-infinity`, then `x.nextUp` is `-greatestFiniteMagnitude`.
  /// - If `x` is `-leastNonzeroMagnitude`, then `x.nextUp` is `-0.0`.
  /// - If `x` is zero, then `x.nextUp` is `leastNonzeroMagnitude`.
  /// - If `x` is `greatestFiniteMagnitude`, then `x.nextUp` is `infinity`.
  public var nextUp: Self {
    guard !isNaN, !(isInfinite && flags ∌ .isNegative) else { return self }

    guard !isInfinite else { return -.greatestFiniteMagnitude }

    guard !_isEqual(self, -.leastNonzeroMagnitude) else { return .zero }

    guard !isZero else { return .leastNonzeroMagnitude }

    guard !_isEqual(self, .greatestFiniteMagnitude) else { return .infinity }

    return _add(self, .leastNonzeroMagnitude)
  }

  /// The greatest representable value that compares less than this value.
  ///
  /// For any finite value `x`, `x.nextDown` is less than `x`. For `nan` or
  /// `-infinity`, `x.nextDown` is `x` itself. The following special cases
  /// also apply:
  ///
  /// - If `x` is `infinity`, then `x.nextDown` is `greatestFiniteMagnitude`.
  /// - If `x` is `leastNonzeroMagnitude`, then `x.nextDown` is `0.0`.
  /// - If `x` is zero, then `x.nextDown` is `-leastNonzeroMagnitude`.
  /// - If `x` is `-greatestFiniteMagnitude`, then `x.nextDown` is `-infinity`.
  public var nextDown: Self {
    guard !isNaN, !(isInfinite && flags ∋ .isNegative) else { return .nan }

    guard !isInfinite else { return .greatestFiniteMagnitude }

    guard !_isEqual(self, .leastNonzeroMagnitude) else { return .zero }

    guard !isZero else { return -.leastNonzeroMagnitude }

    guard !_isEqual(self, -.greatestFiniteMagnitude) else { return -.infinity }

    return _subtract(self, .leastNonzeroMagnitude)
  }

  /// Returns a Boolean value indicating whether this instance is equal to the
  /// given value.
  ///
  /// This method serves as the basis for the equal-to operator (`==`) for
  /// floating-point values. When comparing two values with this method, `-0`
  /// is equal to `+0`. NaN is not equal to any value, including itself. For
  /// example:
  ///
  ///     let x = 15.0
  ///     x.isEqual(to: 15.0)
  ///     // true
  ///     x.isEqual(to: .nan)
  ///     // false
  ///     Double.nan.isEqual(to: .nan)
  ///     // false
  ///
  /// The `isEqual(to:)` method implements the equality predicate defined by
  /// the [IEEE 754 specification][spec].
  ///
  /// [spec]: http://ieeexplore.ieee.org/servlet/opac?punumber=4610933
  ///
  /// - Parameter other: The value to compare with this value.
  /// - Returns: `true` if `other` has the same value as this instance;
  ///   otherwise, `false`. If either this value or `other` is NaN, the result
  ///   of this method is `false`.
  public func isEqual(to other: Self) -> Bool { _isEqual(self, other) }

  /// Returns a Boolean value indicating whether this instance is less than the
  /// given value.
  ///
  /// This method serves as the basis for the less-than operator (`<`) for
  /// floating-point values. Some special cases apply:
  ///
  /// - Because NaN compares not less than nor greater than any value, this
  ///   method returns `false` when called on NaN or when NaN is passed as
  ///   `other`.
  /// - `-infinity` compares less than all values except for itself and NaN.
  /// - Every value except for NaN and `+infinity` compares less than
  ///   `+infinity`.
  ///
  ///     let x = 15.0
  ///     x.isLess(than: 20.0)
  ///     // true
  ///     x.isLess(than: .nan)
  ///     // false
  ///     Double.nan.isLess(than: x)
  ///     // false
  ///
  /// The `isLess(than:)` method implements the less-than predicate defined by
  /// the [IEEE 754 specification][spec].
  ///
  /// [spec]: http://ieeexplore.ieee.org/servlet/opac?punumber=4610933
  ///
  /// - Parameter other: The value to compare with this value.
  /// - Returns: `true` if this value is less than `other`; otherwise, `false`.
  ///   If either this value or `other` is NaN, the result of this method is
  ///   `false`.
  public func isLess(than other: Self) -> Bool { _isLess(self, other) }

  /// Returns a Boolean value indicating whether this instance is less than or
  /// equal to the given value.
  ///
  /// This method serves as the basis for the less-than-or-equal-to operator
  /// (`<=`) for floating-point values. Some special cases apply:
  ///
  /// - Because NaN is incomparable with any value, this method returns `false`
  ///   when called on NaN or when NaN is passed as `other`.
  /// - `-infinity` compares less than or equal to all values except NaN.
  /// - Every value except NaN compares less than or equal to `+infinity`.
  ///
  ///     let x = 15.0
  ///     x.isLessThanOrEqualTo(20.0)
  ///     // true
  ///     x.isLessThanOrEqualTo(.nan)
  ///     // false
  ///     Double.nan.isLessThanOrEqualTo(x)
  ///     // false
  ///
  /// The `isLessThanOrEqualTo(_:)` method implements the less-than-or-equal
  /// predicate defined by the [IEEE 754 specification][spec].
  ///
  /// [spec]: http://ieeexplore.ieee.org/servlet/opac?punumber=4610933
  ///
  /// - Parameter other: The value to compare with this value.
  /// - Returns: `true` if `other` is greater than this value; otherwise,
  ///   `false`. If either this value or `other` is NaN, the result of this
  ///   method is `false`.
  public func isLessThanOrEqualTo(_ other: Self) -> Bool {
    _isLessThanOrEqual(self, other)
  }

  /// Returns a Boolean value indicating whether this instance should precede
  /// or tie positions with the given value in an ascending sort.
  ///
  /// This relation is a refinement of the less-than-or-equal-to operator
  /// (`<=`) that provides a total order on all values of the type, including
  /// signed zeros and NaNs.
  ///
  /// The following example uses `isTotallyOrdered(belowOrEqualTo:)` to sort an
  /// array of floating-point values, including some that are NaN:
  ///
  ///     var numbers = [2.5, 21.25, 3.0, .nan, -9.5]
  ///     numbers.sort { !$1.isTotallyOrdered(belowOrEqualTo: $0) }
  ///     // numbers == [-9.5, 2.5, 3.0, 21.25, NaN]
  ///
  /// The `isTotallyOrdered(belowOrEqualTo:)` method implements the total order
  /// relation as defined by the [IEEE 754 specification][spec].
  ///
  /// [spec]: http://ieeexplore.ieee.org/servlet/opac?punumber=4610933
  ///
  /// - Parameter other: A floating-point value to compare to this value.
  /// - Returns: `true` if this value is ordered below or the same as `other`
  ///   in a total ordering of the floating-point type; otherwise, `false`.
  public func isTotallyOrdered(belowOrEqualTo other: Self) -> Bool {
    _isTotallyOrdered(self, other)
  }

  /// A Boolean value indicating whether this instance is normal.
  ///
  /// A *normal* value is a finite number that uses the full precision
  /// available to values of a type. Zero is neither a normal nor a subnormal
  /// number.
  public var isNormal: Bool { !(isNaN || isInfinite || isZero) }

  /// A Boolean value indicating whether this instance is finite.
  ///
  /// All values other than NaN and infinity are considered finite, whether
  /// normal or subnormal.
  public var isFinite: Bool { !(isNaN || isInfinite) }

  /// A Boolean value indicating whether the instance is equal to zero.
  ///
  /// The `isZero` property of a value `x` is `true` when `x` represents either
  /// `-0.0` or `+0.0`. `x.isZero` is equivalent to the following comparison:
  /// `x == 0.0`.
  ///
  ///     let x = -0.0
  ///     x.isZero        // true
  ///     x == 0.0        // true
  public var isZero: Bool { isFinite && numerator == 0 }

  /// A Boolean value indicating whether the instance is subnormal.
  ///
  /// A *subnormal* value is a nonzero number that has a lesser magnitude than
  /// the smallest normal number. Subnormal values do not use the full
  /// precision available to values of a type.
  ///
  /// Zero is neither a normal nor a subnormal number. Subnormal numbers are
  /// often called *denormal* or *denormalized*---these are different names
  /// for the same concept.
  public var isSubnormal: Bool { false }

  /// A Boolean value indicating whether the instance is infinite.
  ///
  /// Note that `isFinite` and `isInfinite` do not form a dichotomy, because
  /// they are not total: If `x` is `NaN`, then both properties are `false`.
  public var isInfinite: Bool { flags ∋ .isInfinite && !isNaN }

  /// A Boolean value indicating whether the instance is NaN ("not a number").
  ///
  /// Because NaN is not equal to any value, including NaN, use this property
  /// instead of the equal-to operator (`==`) or not-equal-to operator (`!=`)
  /// to test whether a value is or is not NaN. For example:
  ///
  ///     let x = 0.0
  ///     let y = x * .infinity
  ///     // y is a NaN
  ///
  ///     // Comparing with the equal-to operator never returns 'true'
  ///     print(x == Double.nan)
  ///     // Prints "false"
  ///     print(y == Double.nan)
  ///     // Prints "false"
  ///
  ///     // Test with the 'isNaN' property instead
  ///     print(x.isNaN)
  ///     // Prints "false"
  ///     print(y.isNaN)
  ///     // Prints "true"
  ///
  /// This property is `true` for both quiet and signaling NaNs.
  public var isNaN: Bool { flags ∋ .isNaN }

  /// A Boolean value indicating whether the instance is a signaling NaN.
  ///
  /// Signaling NaNs typically raise the Invalid flag when used in general
  /// computing operations.
  public var isSignalingNaN: Bool { flags ∋ .isSignaling }

  /// The classification of this value.
  ///
  /// A value's `floatingPointClass` property describes its "class" as
  /// described by the [IEEE 754 specification][spec].
  ///
  /// [spec]: http://ieeexplore.ieee.org/servlet/opac?punumber=4610933
  public var floatingPointClass: FloatingPointClassification {
    isSignalingNaN
      ? .signalingNaN
      : (isNaN
        ? .quietNaN
        : (isZero
          ? sign == .minus ? .negativeZero : .positiveZero
          : (isSubnormal
            ? (sign == .minus ? .negativeSubnormal : .positiveSubnormal)
            : (isInfinite
              ? (sign == .minus ? .negativeInfinity : .positiveInfinity)
              : (sign == .minus ? .negativeNormal : .positiveNormal)
            )
          )
        )
      )
  }

  /// A Boolean value indicating whether the instance's representation is in
  /// its canonical form.
  ///
  /// The [IEEE 754 specification][spec] defines a *canonical*, or preferred,
  /// encoding of a floating-point value. On platforms that fully support
  /// IEEE 754, every `Float` or `Double` value is canonical, but
  /// non-canonical values can exist on other platforms or for other types.
  /// Some examples:
  ///
  /// - On platforms that flush subnormal numbers to zero (such as armv7
  ///   with the default floating-point environment), Swift interprets
  ///   subnormal `Float` and `Double` values as non-canonical zeros.
  ///   (In Swift 5.1 and earlier, `isCanonical` is `true` for these
  ///   values, which is the incorrect value.)
  ///
  /// - On i386 and x86_64, `Float80` has a number of non-canonical
  ///   encodings. "Pseudo-NaNs", "pseudo-infinities", and "unnormals" are
  ///   interpreted as non-canonical NaN encodings. "Pseudo-denormals" are
  ///   interpreted as non-canonical encodings of subnormal values.
  ///
  /// - Decimal floating-point types admit a large number of non-canonical
  ///   encodings. Consult the IEEE 754 standard for additional details.
  ///
  /// [spec]: http://ieeexplore.ieee.org/servlet/opac?punumber=4610933
  public var isCanonical: Bool { true }
}

extension Fraction {
  /// Structure for storing a `Fraction` instance's various flag values.
  fileprivate struct Flags: OptionSet, Hashable, CustomStringConvertible {
    /// The underlying raw value.
    let rawValue: UInt8

    /// Initializing by raw value.
    /// - Parameter value: The raw value for this instance of `Flags`.
    init(rawValue value: UInt8) { rawValue = value }

    /// Set when the fraction does not represent a valid number.
    static let isNaN = Flags(rawValue: 0b0000_0001)

    /// Set when the fraction is not a number and is signaling.
    static let isSignaling = Flags(rawValue: 0b0000_0011)

    /// Set to indicate that the fraction is in its reduced form.
    static let isReduced = Flags(rawValue: 0b0000_0100)

    /// Set to when the fraction represents an infinite value.
    static let isInfinite = Flags(rawValue: 0b0000_1000)

    /// Set when the fraction has a repeating value.
    static let isRepeating = Flags(rawValue: 0b0001_0000)

    /// Set when the fraction is less than zero.
    static let isNegative = Flags(rawValue: 0b1000_0000)

    /// A friendly printout of set options.
    public var description: String {
      var flags: [String] = []
      if self ∋ .isNaN { flags.append("isNaN") }
      if self ∋ .isSignaling { flags += ["isSignaling"] }
      if self ∋ .isReduced { flags.append("isReduced") }
      if self ∋ .isInfinite { flags.append("isInfinite") }
      if self ∋ .isRepeating { flags.append("isRepeating") }
      if self ∋ .isNegative { flags.append("isNegative") }
      return "[\(flags.joined(separator: ", "))]"
    }
  }
}

// MARK: - Converting from a Fraction

public extension Double {
  /// Converts a `Fraction` into a `Double` by converting the numerator and denominator
  /// values and then dividing the numerator by the denominator, negating the result
  /// when `value.isNegative`.
  /// - Parameter value: The fraction to convert into a `Double`.
  init(_ value: Fraction) {
    switch value.floatingPointClass {
      case .quietNaN:
        self = .nan
      case .signalingNaN:
        self = .signalingNaN
      case .positiveInfinity:
        self = .infinity
      case .negativeInfinity:
        self = -.infinity
      case .positiveZero:
        self = .zero
      case .negativeZero:
        self = -.zero
      case .positiveNormal,
           .positiveSubnormal:
        self = Double(value.numerator) / Double(value.denominator)
      case .negativeNormal,
           .negativeSubnormal:
        self = -(Double(value.numerator) / Double(value.denominator))
    }
  }
}

// MARK: - Operations

/// Adds two fractions together.
/// - Parameters:
///   - lhs: The first summand.
///   - rhs: The second summand.
/// - Returns: The result of adding `rhs` to `lhs`.
private func _add(_ lhs: Fraction, _ rhs: Fraction) -> Fraction {
  // Check NaNs
  guard !lhs.isNaN else { return .nan }
  guard !rhs.isNaN else { return .nan }

  // Check infinities
  guard !lhs.isInfinite else {
    return rhs.isInfinite && lhs.sign != rhs.sign ? .nan : lhs
  }

  guard !rhs.isInfinite else { return rhs }

  // Rebase the fracions so that they share a common denominator.
  let denominator = lcm(lhs.denominator, rhs.denominator)

  let lhsʹ = lhs.rebased(denominator)
  let rhsʹ = rhs.rebased(denominator)

  let numerator: UInt128
  let sign: FloatingPointSign

  // Check signs
  switch (lhs.sign, rhs.sign) {
    case (.plus, .plus):
      numerator = lhsʹ.numerator &+ rhsʹ.numerator
      sign = .plus

    case (.minus, .minus):
      numerator = lhsʹ.numerator &+ rhsʹ.numerator
      sign = .minus

    case (.plus, .minus) where lhsʹ.numerator >= rhsʹ.numerator:
      numerator = lhsʹ.numerator &- rhsʹ.numerator
      sign = .plus

    case (.plus, .minus):
      numerator = rhsʹ.numerator &- lhsʹ.numerator
      sign = .minus

    case (.minus, .plus) where lhsʹ.numerator >= rhsʹ.numerator:
      numerator = lhsʹ.numerator &- rhsʹ.numerator
      sign = .minus

    case (.minus, .plus):
      numerator = rhsʹ.numerator &- rhsʹ.numerator
      sign = .plus
  }

  return Fraction(numerator: numerator,
                  denominator: denominator,
                  sign: sign,
                  reducing: true)
}

/// Subtracting one fraction from another.
/// - Parameters:
///   - lhs: The quantity from which to subtract.
///   - rhs: The quantity being subtracted.
/// - Returns: The result of subtracting `rhs` from `lhs`.
private func _subtract(_ lhs: Fraction, _ rhs: Fraction) -> Fraction { _add(lhs, -rhs) }

/// Multiply two fractions.
/// - Parameters:
///   - lhs: The first multiplicand.
///   - rhs: The second multiplicand.
/// - Returns: The result of multiplying `lhs` by `rhs`.
private func _multiply(_ lhs: Fraction, _ rhs: Fraction) -> Fraction {
  // check NaNs
  guard !(lhs.isNaN || rhs.isNaN) else { return .nan }

  let numerator: UInt128, denominator: UInt128
  var flags: Fraction.Flags = []

  // check infinities
  switch (lhs.isInfinite, rhs.isInfinite) {
    case (true, false) where rhs.numerator == 0,
         (false, true) where lhs.numerator == 0:
      return .nan
    case (false, true),
         (true, false),
         (true, true):
      flags.insert(.isInfinite)
      numerator = 0
      denominator = 0

    case (false, false):
      numerator = lhs.numerator * rhs.numerator
      denominator = lhs.denominator * rhs.denominator
  }

  // check signs
  if lhs.sign != rhs.sign { flags.insert(.isNegative) }

  return Fraction(numerator: numerator,
                  denominator: denominator,
                  flags: flags,
                  reducing: true)
}

/// Dividing one fraction by another.
/// - Parameters:
///   - lhs: The dividend
///   - rhs: The devisor
/// - Returns: The result of dividing `lhs` by `rhs`.
private func _divide(_ lhs: Fraction, _ rhs: Fraction) -> Fraction {
  _multiply(lhs, rhs.reciprocal)
}

/// Calculates the remainder when dividing one fraction by another.
///
///        n = lhs.numerator, d = lhs.denominator
///        nʹ = rhs.numerator, dʹ = rhs.denominator
///
///        a = ndʹ, b = dnʹ, c = a mod b
///
///            ⎧(a - c)/b , if c < b/2 or c == b/2 and ((a - c)/b) mod 2 == 0
///        q = ⎨
///            ⎩(a + b - c)/b , if c > b/2 or c == b/2 and ((a + b - c)/b) mod 2 == 0
///
///        r = (n/d) - q(nʹ/dʹ)
///
/// - Parameters:
///   - lhs: The dividend.
///   - rhs: The divisor.
/// - Returns: The remainder when dividing `lhs` by `rhs`.
private func _remainder(_ lhs: Fraction, _ rhs: Fraction) -> Fraction {
  guard !lhs.isNaN, !rhs.isNaN, lhs.isFinite, !rhs.isZero else { return .nan }

  guard !lhs.isZero, !rhs.isInfinite else { return lhs }

  let n = lhs.numerator
  let d = lhs.denominator

  let nʹ = rhs.numerator
  let dʹ = rhs.denominator

  let a = n * dʹ
  let b = d * nʹ
  let c = a % b

  let q: UInt128

  switch b / 2 {
    case c...:
      // c < b/2
      q = (a - c) / b

    case ..<c:
      // c > b/2
      q = (a + b - c) / b

    default:
      // c == b/2
      let qʹ = (a - c) / b
      q = qʹ % 2 == 0 ? qʹ : (a + b - c) / b
  }

  let f1 = Fraction(numerator: n, denominator: d)
  let f2 = Fraction(numerator: q * nʹ, denominator: dʹ)

  return f1 - f2
}

/// Calculates the remainder when dividing one fraction by another.
///
/// Not sure the following says anything particularly helpful.
///
///        n = lhs.numerator, d = lhs.denominator
///        nʹ = rhs.numerator, dʹ = rhs.denominator
///
///         n       nʹ       nʺ     n‴
///        ─── mod ───  ≡  ─── mod ───
///         d       dʹ       dʺ     d″
///
///         where
///
///          n       nʺ        nʹ       n‴
///         ───  ≡  ───  and  ───  ≡  ───
///          d       d″        d′      d″
///
/// - Parameters:
///   - lhs: The dividend.
///   - rhs: The divisor.
/// - Returns: The remainder when dividing `lhs` by `rhs`.
private func _truncatingRemainder(_ lhs: Fraction, _ rhs: Fraction) -> Fraction {
  // check NaNs
  guard !lhs.isNaN, !rhs.isNaN, lhs.isFinite, !rhs.isZero else { return .nan }

  guard !lhs.isZero, !rhs.isInfinite else { return lhs }

  let denominator = lcm(lhs.denominator, rhs.denominator)
  let numeratorʹ = (denominator / lhs.denominator) * lhs.numerator
  let numeratorʺ = (denominator / rhs.denominator) * rhs.numerator
  let numerator = numeratorʹ % numeratorʺ

  return Fraction(numerator: numerator, denominator: denominator, reducing: true)
}

/// Calculating the square root of a fraction.
/// - Parameter value: The fraction for which to calculate the square root.
/// - Returns: The square root of `value`.
private func _squareRoot(_ value: Fraction) -> Fraction {
  guard !(value.isZero || value.isNaN || value.isInfinite && value.sign == .plus) else {
    return value
  }

  guard !(value.isInfinite && value.sign == .minus) else {
    return .nan
  }

  let value = value.reduced()

  // √(n/d) == √n/√d == (√n * √d)/d == (√(n * d))/d
  let (numeratorʹ,
       overflow) = value.numerator.multipliedReportingOverflow(by: value.denominator)

  guard !overflow else {
    return Fraction(Double(value).squareRoot())
  }

  let pairs: AnyIterator<UInt128> = {
    var result = numeratorʹ
    let exponent = _log10(result)
    let totalPairs = (exponent &+ 1) / 2
    var currentPair = totalPairs
    return AnyIterator {
      guard currentPair > -1 else { return nil }
      let powerOf10 = _pow10(currentPair * 2)
      let resultʹ = result / powerOf10
      currentPair = currentPair &- 1
      result -= resultʹ * powerOf10
      return resultʹ
    }
  }()

  var p: (integer: (value: UInt128, exponent: Int),
          fractional: (value: UInt128, exponent: Int)) = ((0, 0),
                                                          (0, 0))
  var x: UInt128 = 0
  var y: UInt128 = 0
  var currentPair = pairs.next()

  guard var c = currentPair else { return .nan }

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

  while c != 0, (p.fractional.exponent &+ p.integer.exponent) < 38 {
    c *= 100
    x = 0

    let pʹ = p.integer.value * _pow10(p.fractional.exponent) + p.fractional.value

    while (x &+ 1) * (20 * pʹ &+ (x &+ 1)) <= c { x = x &+ 1 }

    let (fractionalʹ, overflow) = p.fractional.value.multipliedReportingOverflow(by: 10)

    guard !overflow else { break }

    p.fractional.value = fractionalʹ &+ x
    p.fractional.exponent += 1

    y = x * (20 * pʹ &+ x)
    c -= y
  }

  let numerator = _pow10(p.fractional.exponent) * p.integer.value + p.fractional.value
  let denominator = value.denominator * _pow10(p.fractional.exponent)

  return Fraction(numerator: numerator, denominator: denominator, sign: value.sign)
}

/// Calculates the addition of a fraction to the product of two other fractions.
/// - Parameters:
///   - value: The summand.
///   - m1: The first multiplicand.
///   - m2: The second multiplicand.
/// - Returns: The result of adding `value` to the product of `m1` and `m2`.
private func _addProduct(_ value: Fraction, _ m1: Fraction, _ m2: Fraction) -> Fraction {
  _add(value, _multiply(m1, m2))
}

/// Rounds the specified fraction according the specified rounding rule.
/// - Parameters:
///   - value: The fraction to round.
///   - rule: The rule used to round the fraction.
/// - Returns: `value` rounded according to `rule`.
private func _round(_ value: Fraction, _ rule: FloatingPointRoundingRule) -> Fraction {
  guard !value.isNaN, !value.isInfinite, !value.isZero else { return value }

  var numerator = value.numerator / value.denominator

  switch ((value.numerator - numerator)÷1, value.denominator÷2) {
    case let (x, y) where x < y:
      switch rule {
        case .down where value.sign == .minus,
             .up where value.sign == .plus,
             .awayFromZero:
          numerator += 1
        default:
          break
      }
    case let (x, y) where x > y:
      switch rule {
        case .awayFromZero,
             .toNearestOrEven,
             .toNearestOrAwayFromZero,
             .down where value.sign == .minus,
             .up where value.sign == .plus:
          numerator += 1
        default:
          break
      }
    default:
      switch rule {
        case .awayFromZero,
             .toNearestOrAwayFromZero,
             .down where value.sign == .minus,
             .up where value.sign == .plus,
             .toNearestOrEven where numerator % 2 == 1:
          numerator += 1
        default:
          break
      }
  }

  return Fraction(numerator: numerator, denominator: 1, sign: value.sign)
}

// MARK: - Comparisons

/// Whether two fractions are equal.
///
/// - Parameters:
///   - lhs: The first fraction.
///   - rhs: The second fraction.
/// - Returns: `true` if `lhs == rhs` and `false` otherwise.
private func _isEqual(_ lhs: Fraction, _ rhs: Fraction) -> Bool {
  lhs.isNaN || rhs.isNaN
    ? false
    : (lhs.isZero && rhs.isZero
      ? true
      : (lhs.sign != rhs.sign
        ? false
        : (lhs.isInfinite != rhs.isInfinite
          ? false
          : lhs.numerator * rhs.denominator == rhs.numerator * lhs.denominator)))
}

/// Whether one fraction is less than another fraction.
///
/// - Parameters:
///   - lhs: The first fraction.
///   - rhs: The second fraction.
/// - Returns: `true` if `lhs < rhs` and `false` otherwise.
private func _isLess(_ lhs: Fraction, _ rhs: Fraction) -> Bool {
  guard !(lhs.isNaN || rhs.isNaN) else { return false }
  switch (lhs.isInfinite, rhs.isInfinite) {
    case (true, true): return lhs.sign == .minus && rhs.sign == .plus
    case (true, false): return lhs.sign == .minus
    case (false, true): return rhs.sign == .plus
    case (false, false): break
  }

  switch (lhs.numerator == 0, rhs.numerator == 0) {
    case (true, true): return false
    case (true, false): return rhs.sign == .plus
    case (false, true): return lhs.sign == .minus
    case (false, false): break
  }

  switch (lhs.sign, rhs.sign) {
    case (.plus, .plus):
      return lhs.numerator * rhs.denominator < rhs.numerator * lhs.denominator
    case (.plus, .minus):
      return false
    case (.minus, .plus):
      return true
    case (.minus, .minus):
      return lhs.numerator * rhs.denominator > rhs.numerator * lhs.denominator
  }
}

/// Whether one fraction is less than or equal to another fraction.
///
/// - Parameters:
///   - lhs: The first fraction.
///   - rhs: The second fraction.
/// - Returns: `true` if `lhs <= rhs` and `false` otherwise.
private func _isLessThanOrEqual(_ lhs: Fraction, _ rhs: Fraction) -> Bool {
  guard !(lhs.isNaN || rhs.isNaN) else { return false }
  switch (lhs.isInfinite, rhs.isInfinite) {
    case (true, true): return lhs.sign == .minus || rhs.sign == .plus
    case (true, false): return lhs.sign == .minus
    case (false, true): return rhs.sign == .plus
    case (false, false): break
  }

  guard lhs.numerator > 0, rhs.numerator > 0 else { return true }

  switch (lhs.sign, rhs.sign) {
    case (.plus, .plus):
      return lhs.numerator * rhs.denominator <= rhs.numerator * lhs.denominator
    case (.plus, .minus):
      return false
    case (.minus, .plus):
      return true
    case (.minus, .minus):
      return lhs.numerator * rhs.denominator >= rhs.numerator * lhs.denominator
  }
}

/// Whether one fraction precedes or ties positions with another fraction.
/// - Parameters:
///   - lhs: The first fraction.
///   - rhs: The second fraction.
/// - Returns: `true` if `lhs` is ordered below or alongside `rhs` and `false` otherwise.
private func _isTotallyOrdered(_ lhs: Fraction, _ rhs: Fraction) -> Bool {
  guard lhs.sign == rhs.sign else { return lhs.sign == .minus }
  switch (lhs.isNaN, rhs.isNaN) {
    case (true, true):
      switch (lhs.isSignalingNaN, rhs.isSignalingNaN) {
        case (true, true): return lhs.numerator <= rhs.numerator
        case (true, false): return lhs.sign == .plus
        case (false, true): return lhs.sign == .minus
        case (false, false): return true
      }
    case (true, false): return lhs.sign == .minus
    case (false, true): return rhs.sign == .plus
    case (false, false): return _isLessThanOrEqual(lhs, rhs)
  }
}

// MARK: - Helper variables and functions

/// Calculates `10` raised to the specified exponent.
/// - Parameter exponent: The power of ten to produce.
/// - Returns: The corresponding power of ten.
private func _pow10(_ exponent: Int) -> UInt128 {
  power(value: 10, exponent: exponent, identity: 1, operation: *)
}

/// Calculates the base 10 logarithm for the specified value, rounding towards zero.
///
/// - Parameter value: The value for which to calculate the logarithm.
/// - Returns: The base 10 logarithm for `value`.
private func _log10(_ value: UInt128) -> Int { Int(log10(Double(value))) }

/// The first 39 powers of ten.
private let _powersOfTen = OrderedSet<UInt128>((0...38).map(_pow10))

/// Whether the specified value is a power of the fraction base.
/// - Parameter value: The value being considered.
/// - Returns: `true` if `value` is a power of ten and `false` otherwise.
private func _isDecimalBase(_ value: UInt128) -> Bool { _powersOfTen.contains(value) }

/// Splits a value interpretted as a fractional numerator over a power of ten
/// denominator into non-repeating and repeating digits.
///
/// - Parameter digits: The digits that make up the numerator.
/// - Returns: A tuple an array of the non-repeating fractional digits
///            and an array of the repeating fractional digits
private func _split(fractionalNumerator digits: [UInt8]) -> (nonrepeating: [UInt8],
                                                             repeating: [UInt8])
{
  guard !digits.isEmpty else { return ([], []) }
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

      Slice: while i < digits.endIndex /* && j < value.endIndex */ {
        // Compare the two slices for equality
        let iʹ = min(i &+ periodLength, digits.endIndex),
            jʹ = min(j &+ periodLength, digits.endIndex)
        for (x, y) in zip(digits[i..<iʹ], digits[j..<jʹ]) where x != y { break Slice }
        i = iʹ; j = jʹ
      }

      // Check that the loop exited early otherwise a pattern has been found
      guard i < digits.endIndex /* && j < value.endIndex */ else {
        return (Array(digits[0..<offset]),
                Array(digits[offset..<(offset &+ periodLength)]))
      }
    }
  }

  // No pattern detected, return all the digits as `nonrepeating`
  return (digits, [])
}

/// Splits a value interpretted as a numerator over a power of ten denominator
/// into its integer and fractional parts.
///
/// - Parameters:
///   - numerator: The value to serve as the numerator.
///   - exponent:  The power of ten to serve as the denominator.
/// - Returns: A tuple with the integer, an array of the non-repeating fractional digits
///            and an array of the repeating fractional digits
private func _split(numerator: UInt128, exponent: Int) -> (integer: UInt128,
                                                           nonrepeating: [UInt8],
                                                           repeating: [UInt8])
{
  guard numerator > 0 else { return (0, [], []) }
  let denominator: UInt128 = power(value: 10, exponent: abs(exponent),
                                   identity: 1, operation: *)
  let integer = numerator / denominator
  let fractional = numerator - integer * denominator

  let digits = fractional.digits()
  let exponent = _log10(denominator)
  let zeroPadding = [UInt8](repeating: 0, count: abs(exponent - digits.count))

  let (nonrepeating, repeating) = _split(fractionalNumerator: zeroPadding + digits)

  return (integer, nonrepeating, repeating)
}

// MARK: - Initializing with global operators

/// Operator support for creating `Fraction` instances.
/// - Parameters:
///   - lhs: The numerator
///   - rhs: The denominator
/// - Returns: `lhs` / `rhs`
public func ÷ <I1, I2>(lhs: I1, rhs: I2) -> Fraction
  where I1: ExpressibleByIntegerLiteral, I2: ExpressibleByIntegerLiteral
{
  // Funnel known quantities into the integer type being stored
  let lhsMax: UInt128
  let rhsMax: UInt128

  // Track any ascertainable signage.
  let leftIsNegative: Bool
  let rightIsNegative: Bool

  // Get the value and sign from `lhs`.
  switch lhs {
    case let lhs as UInt128:
      lhsMax = UInt128(lhs)
      leftIsNegative = false
    case let lhs as UInt64:
      lhsMax = UInt128(lhs)
      leftIsNegative = false
    case let lhs as UInt32:
      lhsMax = UInt128(lhs)
      leftIsNegative = false
    case let lhs as UInt16:
      lhsMax = UInt128(lhs)
      leftIsNegative = false
    case let lhs as UInt8:
      lhsMax = UInt128(lhs)
      leftIsNegative = false
    case let lhs as UInt:
      lhsMax = UInt128(lhs)
      leftIsNegative = false
    case let lhs as Int64:
      lhsMax = UInt128(abs(lhs))
      leftIsNegative = lhs < 0
    case let lhs as Int32:
      lhsMax = UInt128(abs(lhs))
      leftIsNegative = lhs < 0
    case let lhs as Int16:
      lhsMax = UInt128(abs(lhs))
      leftIsNegative = lhs < 0
    case let lhs as Int8:
      lhsMax = UInt128(abs(lhs))
      leftIsNegative = lhs < 0
    case let lhs as Int:
      lhsMax = UInt128(abs(lhs))
      leftIsNegative = lhs < 0
    default: return .zero
  }

  // Get the value and sign of `rhs`.
  switch rhs {
    case let rhs as UInt128:
      rhsMax = UInt128(rhs)
      rightIsNegative = false
    case let rhs as UInt64:
      rhsMax = UInt128(rhs)
      rightIsNegative = false
    case let rhs as UInt32:
      rhsMax = UInt128(rhs)
      rightIsNegative = false
    case let rhs as UInt16:
      rhsMax = UInt128(rhs)
      rightIsNegative = false
    case let rhs as UInt8:
      rhsMax = UInt128(rhs)
      rightIsNegative = false
    case let rhs as UInt:
      rhsMax = UInt128(rhs)
      rightIsNegative = false
    case let rhs as Int64:
      rhsMax = UInt128(abs(rhs))
      rightIsNegative = rhs < 0
    case let rhs as Int32:
      rhsMax = UInt128(abs(rhs))
      rightIsNegative = rhs < 0
    case let rhs as Int16:
      rhsMax = UInt128(abs(rhs))
      rightIsNegative = rhs < 0
    case let rhs as Int8:
      rhsMax = UInt128(abs(rhs))
      rightIsNegative = rhs < 0
    case let rhs as Int:
      rhsMax = UInt128(abs(rhs))
      rightIsNegative = rhs < 0
    default: return .zero
  }

  // Return the initialized fraction.
  return Fraction(numerator: lhsMax,
                  denominator: rhsMax,
                  sign: leftIsNegative ^ rightIsNegative ? .minus : .plus)
}

/// Operator support for creating `Fraction` instances.
/// - Parameters:
///   - lhs: The numerator
///   - rhs: The denominator
/// - Returns: `lhs` / `rhs`
public func ╱ <I1, I2>(lhs: I1, rhs: I2) -> Fraction
  where I1: ExpressibleByIntegerLiteral, I2: ExpressibleByIntegerLiteral
{
  lhs ÷ rhs
}
