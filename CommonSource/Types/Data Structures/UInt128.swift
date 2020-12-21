//
//  UInt128.swift
//  MoonKit
//
//  Created by Jason Cardwell on 8/19/16.
//  Copyright © 2016 Jason Cardwell. All rights reserved.
//

import Foundation
import Swift

// MARK: - UInt128

public struct UInt128: FixedWidthInteger {

  public var words: Words { Words(self) }

  public var trailingZeroBitCount: Int {
    low == 0
      ? low.trailingZeroBitCount + high.trailingZeroBitCount
      : low.trailingZeroBitCount
  }

  public var byteSwapped: UInt128 { UInt128(high: low.byteSwapped, low: high.byteSwapped) }

  public var nonzeroBitCount: Int { high.nonzeroBitCount + low.nonzeroBitCount }

  public var leadingZeroBitCount: Int {
    high == 0
      ? high.leadingZeroBitCount + low.leadingZeroBitCount
      : high.leadingZeroBitCount
  }

  public fileprivate(set) var low: UInt64
  public fileprivate(set) var high: UInt64

  public init(high h: UInt64 = 0, low l: UInt64 = 0) { low = l; high = h }

  public init(_ value: UInt64) { self = UInt128(low: value) }
  public init(_ value: UInt32) { self = UInt128(low: UInt64(value)) }
  public init(_ value: UInt16) { self = UInt128(low: UInt64(value)) }
  public init(_ value: UInt8) { self = UInt128(low: UInt64(value)) }
  public init(_ value: UInt) { self = UInt128(low: UInt64(value)) }
  public init(_ value: Int64) { self = UInt128(low: UInt64(value)) }
  public init(_ value: Int32) { self = UInt128(low: UInt64(value)) }
  public init(_ value: Int16) { self = UInt128(low: UInt64(value)) }
  public init(_ value: Int8) { self = UInt128(low: UInt64(value)) }
  public init(_ value: Int) { self = UInt128(low: UInt64(value)) }

  public init(_ value: Decimal) {
    guard value.sign == .plus else { self = UInt128(); return }
    let decimalHandler = NSDecimalNumberHandler(roundingMode: .down,
                                                scale: 0,
                                                raiseOnExactness: false,
                                                raiseOnOverflow: false,
                                                raiseOnUnderflow: false,
                                                raiseOnDivideByZero: false)
    let digits = (value as NSDecimalNumber).rounding(accordingToBehavior: decimalHandler).decimalValue.digits()
    self = UInt128(digits: digits)
  }

  public static var isSigned: Bool { return false }

  public var magnitude: UInt128 { return self }

  public func isEqual(to rhs: UInt128) -> Bool { return high == rhs.high && low == rhs.low }

  public func isLess(than rhs: UInt128) -> Bool { return high < rhs.high || high == rhs.high && low < rhs.low }

//  public func word(at n: Int) -> UInt { return UInt(n == 1 ? high : low) }

  public static var bitWidth: Int { return 128 }
  public var bitWidth: Int { return 128 }

  public var minimumSignedRepresentationBitWidth: Int { return 128 }

//  public mutating func formRemainder(dividingBy rhs: UInt128) { self = quotientAndRemainder(dividingBy: rhs).1 }


  public func signum() -> UInt128 { return UInt128(1) }

  public static var max: UInt128 { return UInt128(high: UInt64.max, low: UInt64.max) }
  public static var min: UInt128 { return UInt128() }

  public init(integerLiteral value: UInt64) { self = UInt128(value) }

  public init<T: BinaryInteger>(_ source: T) {
    switch source.words.count {
      case 1: self = UInt128(low: UInt64(source.words[0]))
      case 2: self = UInt128(high: UInt64(source.words[1]), low: UInt64(source.words[0]))
      default: self = UInt128()
    }
  }

  private static func convertFloatingPoint<T: BinaryFloatingPoint>(_ source: T) -> (result: UInt128, exact: Bool) {
    var source = source
    var value = UInt128()
    var shift = UInt64()
    let base: T = 65536
    let exact = source - source.truncatingRemainder(dividingBy: 10) == source
    while source > 0, shift < 128 {
      let r = source.truncatingRemainder(dividingBy: base).rounded(.towardZero)
      let bits: UInt64
      switch MemoryLayout<T>.size {
        case 4:
          bits = UInt64(Float(sign: .plus,
                              exponentBitPattern: UInt(r.exponentBitPattern),
                              significandBitPattern: UInt32(UInt(r.significandBitPattern))))
        default:
          bits = UInt64(Double(sign: .plus,
                               exponentBitPattern: UInt(r.exponentBitPattern),
                               significandBitPattern: UInt64(UInt(UInt(r.significandBitPattern)))))
      }
      switch shift {
        case 0...63: value.low |= bits << shift
        case 64...127: value.high |= bits << (shift &- 64)
        default: unreachable()
      }
      shift = shift &+ 16
      source /= base
      source.round(.towardZero)
    }

    return (value, exact)
  }

  public init<T: BinaryFloatingPoint>(_ source: T) { self = UInt128.convertFloatingPoint(source).result }

  public init<T: FloatingPoint>(_ source: T) {
    switch source {
      case let float as Float: self = UInt128(float)
      case let double as Double: self = UInt128(double)
      default: self = UInt128()
    }
  }

  public init(_truncatingBits bits: UInt) { self = UInt128(low: UInt64(bits)) }

  public init<T: BinaryInteger>(clamping source: T) { self = UInt128(source) }

  public init?<T: BinaryFloatingPoint>(exactly source: T) {
    let (maybeSelf, exact) = UInt128.convertFloatingPoint(source)
    guard exact else { return nil }
    self = maybeSelf
  }

  public init?<T: FloatingPoint>(exactly source: T) {
    switch source {
      case let float as Float: self.init(exactly: float)
      case let double as Double: self.init(exactly: double)
      default: return nil
    }
  }

  public init<T: BinaryInteger>(extendingOrTruncating source: T) { self = UInt128(source) }

  public var description: String { return String(self, radix: 10) }
  public var debugDescription: String {
    return "\(description) {high: 0x\(String(high, radix: 16)); low: 0x\(String(low, radix: 16))}"
  }

  public func remainderReportingOverflow(dividingBy rhs: UInt128) -> (partialValue: UInt128, overflow: Bool) {
    return (quotientAndRemainder(dividingBy: rhs).1, false)
  }

  public func quotientAndRemainder(dividingBy rhs: UInt128) -> (UInt128, UInt128) {

    func largestDoubling(_ a: UInt128, _ b: UInt128) -> UInt128
    {
      // precondition: b != 0
      var b = b
      while a - b >= b { b = b + b }
      return b
    }

    var a = self, b = rhs

    // precondition: b > 0
    guard a >= b else { return (0, a) }
    var c = largestDoubling(a, b)
    a = a - c
    var n: UInt128 = 1
    while c != b {
      c >>= 1
      n = n + n
      if c <= a {
        a = a - c
        n = n + 1
      }
    }
    return (n, a)
//    return quotientRemainder(self, rhs)
  }

  public func dividingFullWidth(_ dividend: (high: UInt128, low: UInt128)) -> (quotient: UInt128, remainder: UInt128) {
    quotientAndRemainder(dividingBy: UInt128(high: UInt64(high), low: UInt64(low)))
  }

  public func addingReportingOverflow(_ rhs: UInt128) -> (partialValue: UInt128, overflow: Bool) {
    var partialValue = UInt128()

    // Split lows into two 32 bit numbers stored in two 64 bit numbers
    var x = low & 0xFFFFFFFF
    var y = rhs.low & 0xFFFFFFFF
    var sum = x &+ y
    var carry = sum >> 32
    partialValue.low = sum & 0xFFFFFFFF
    x = low >> 32
    y = rhs.low >> 32
    sum = x &+ y &+ carry
    carry = sum >> 32
    partialValue.low |= sum << 32

    x = high & 0xFFFFFFFF
    y = rhs.high & 0xFFFFFFFF
    sum = x &+ y &+ carry
    carry = sum >> 32
    partialValue.high = sum & 0xFFFFFFFF
    x = high >> 32
    y = rhs.high >> 32
    sum = x &+ y &+ carry
    carry = sum >> 32
    partialValue.high |= sum << 32

    return (partialValue, carry > 0)
  }

  public func dividedReportingOverflow(by rhs: UInt128) -> (partialValue: UInt128, overflow: Bool) {
    return (quotientAndRemainder(dividingBy: rhs).0, false)
  }

  public func multipliedReportingOverflow(by rhs: UInt128) -> (partialValue: UInt128, overflow: Bool) {
    let (highpᴸᴸ, lowpᴸᴸ) = MoonKit.doubleWidthMultiply(low, rhs.low)
    var overflow: Bool = false
    var didOverflow = false
    let pᴸᴴ: UInt64, pᴴᴸ: UInt64
    (pᴸᴴ, didOverflow) = low.multipliedReportingOverflow(by: rhs.high)
    if didOverflow { overflow = true }
    (pᴴᴸ, didOverflow) = high.multipliedReportingOverflow(by: rhs.low)
    if didOverflow { overflow = true }

    var partialValue = UInt128(low: lowpᴸᴸ)
    let mask: UInt64 = 0xFFFFFFFF
    var s = (highpᴸᴸ & mask) &+ (pᴸᴴ & mask) &+ (pᴴᴸ & mask)
    var c = s >> 32
    partialValue.high |= s & mask
    s = (highpᴸᴸ >> 32) &+ (pᴸᴴ >> 32) &+ (pᴴᴸ >> 32) &+ c
    c = s >> 32
    partialValue.high |= s << 32
    if c > 0 { overflow = true }
    return (partialValue, overflow)
  }

  public func subtractingReportingOverflow(_ rhs: UInt128) -> (partialValue: UInt128, overflow: Bool) {
    var partialValue = UInt128()
    var (result, overflow) = low.subtractingReportingOverflow(rhs.low)
    partialValue.low = result
    (result, overflow) = (overflow && high == 0 ? UInt64.max : (overflow ? high &- 1 : high)).subtractingReportingOverflow(rhs.high)
    partialValue.high = result
    return (partialValue, overflow)
  }

  public func bitwiseOr(_ rhs: UInt128) -> UInt128 {
    return UInt128(high: high | rhs.high, low: low | rhs.low)
  }

  public func bitwiseAnd(_ rhs: UInt128) -> UInt128 {
    return UInt128(high: high & rhs.high, low: low & rhs.low)
  }

  public func bitwiseXor(_ rhs: UInt128) -> UInt128 {
    return UInt128(high: high ^ rhs.high, low: low ^ rhs.low)
  }

  public func maskingShiftLeft(_ rhs: UInt128) -> UInt128 {
    guard rhs.high == 0, rhs.low < 128 else { fatalError("shift amount is greater than or equal to type size in bits") }
    switch rhs.low {
      case 0: return self
      case 64|->: return UInt128(high: low << (rhs.low &- 64), low: 0)
      default:
        let carry = low >> (64 &- rhs.low)
        return UInt128(high: (high << rhs.low) | carry, low: low << rhs.low)
    }
  }

  public func maskingShiftRight(_ rhs: UInt128) -> UInt128 {
    guard rhs.high == 0, rhs.low < 128 else {
      fatalError("shift amount is greater than or equal to type size in bits")
    }

    switch rhs.low {
      case 64..<128: return UInt128(high: 0, low: high >> (rhs.low &- 64))
      default:
        let carry = high << (64 &- rhs.low)
        return UInt128(high: high >> rhs.low, low: (low >> rhs.low) | carry)
    }
  }

  public static func doubleWidthMultiply(_ lhs: UInt128, _ rhs: UInt128) -> (high: UInt128, low: UInt128) {
    let (highpᴸᴸ, lowpᴸᴸ) = MoonKit.doubleWidthMultiply(lhs.low, rhs.low)
    let (highpᴸᴴ, lowpᴸᴴ) = MoonKit.doubleWidthMultiply(lhs.low, rhs.high)
    let (highpᴴᴸ, lowpᴴᴸ) = MoonKit.doubleWidthMultiply(lhs.high, rhs.low)
    let (highpᴴᴴ, lowpᴴᴴ) = MoonKit.doubleWidthMultiply(lhs.high, rhs.high)

    var low = UInt128(low: lowpᴸᴸ)
    var high = UInt128(high: highpᴴᴴ)

    let mask: UInt64 = 0xFFFFFFFF
    var s = (highpᴸᴸ & mask) &+ (lowpᴸᴴ & mask) &+ (lowpᴴᴸ & mask)
    var c = s >> 32
    low.high |= s & mask
    s = (highpᴸᴸ >> 32) &+ (lowpᴸᴴ >> 32) &+ (lowpᴴᴸ >> 32) &+ c
    c = s >> 32
    low.high |= s << 32

    s = (highpᴸᴴ & mask) &+ (highpᴴᴸ & mask) &+ (lowpᴴᴴ & mask) &+ c
    c = s >> 32
    high.low = s & mask
    s = (highpᴸᴴ >> 32) &+ (highpᴴᴸ >> 32) &+ (lowpᴴᴴ >> 32) &+ c
    c = s >> 32
    high.low |= s << 32

    high.high = high.high &+ c

    return (high, low)
  }

  public var leadingZeros: Int {
    var result = countLeadingZeros(high)
    if result == 64 { result += countLeadingZeros(low) }
    return Int(result)
  }

  public var popcount: Int {
    return Int(countOnes(high) + countOnes(low))
  }

  /// Returns the value as an array of digits with leading zeros when the number of digits is less than `minLength`.
  public func digits(minLength: Int = 0) -> [UInt8] {
    var digits: Stack<UInt8> = []
    var value = self
    var exponent = Swift.max(minLength, Int(log10(Double(self))))
    repeat { digits.push(UInt8((value % 10).low)); value /= 10; exponent -= 1 } while value > 0
    while exponent > 0 { digits.push(0); exponent -= 1 }
    return Array(digits)
  }

  /// Initialize from an array of base 10 digits.
  public init(digits: [UInt8]) { self = digits.reduce(UInt128()) { $0 * 10 &+ UInt128($1) } }
}

public extension Double {
  init(_ value: UInt128) { self = Double(value.high) * exp2(64.0) + Double(value.low) }
}

public extension Decimal {
  init(_ value: UInt128) { self = value.digits().reduce(Decimal()) { $0 * 10 + Decimal($1) } }
}

public extension UInt {
  init(_ value: UInt128) {
    precondition(value.high == 0, "value overflows when converted")
    self = UInt(value.low)
  }
}

public extension UInt64 {
  init(_ value: UInt128) {
    precondition(value.high == 0, "value overflows when converted")
    self = value.low
  }
}

public extension UInt32 {
  init(_ value: UInt128) {
    precondition(value.high == 0, "value overflows when converted")
    self = UInt32(value.low)
  }
}

public extension UInt16 {
  init(_ value: UInt128) {
    precondition(value.high == 0, "value overflows when converted")
    self = UInt16(value.low)
  }
}

public extension UInt8 {
  init(_ value: UInt128) {
    precondition(value.high == 0, "value overflows when converted")
    self = UInt8(value.low)
  }
}

public extension Int {
  init(_ value: UInt128) {
    precondition(value.high == 0, "value overflows when converted")
    self = Int(value.low)
  }
}

public extension Int64 {
  init(_ value: UInt128) {
    precondition(value.high == 0, "value overflows when converted")
    self = Int64(value.low)
  }
}

public extension Int32 {
  init(_ value: UInt128) {
    precondition(value.high == 0, "value overflows when converted")
    self = Int32(value.low)
  }
}

public extension Int16 {
  init(_ value: UInt128) {
    precondition(value.high == 0, "value overflows when converted")
    self = Int16(value.low)
  }
}

public extension Int8 {
  init(_ value: UInt128) {
    precondition(value.high == 0, "value overflows when converted")
    self = Int8(value.low)
  }
}

// MARK: - UInt128 + UnsignedInteger

extension UInt128: UnsignedInteger {
//  public init(_builtinIntegerLiteral value: _MaxBuiltinIntegerType) { self = UInt128(UInt64(_builtinIntegerLiteral: value)) }

//  public func advanced(by n: Double) -> UInt128 { return n < 0 ? self - UInt128(n) : self + UInt128(n) }
//  public func distance(to other: UInt128) -> Double {
//    return other < self
//      ? Double(self - other).negate()
//      : Double(other - self)
//  }

  public func hash(into hasher: inout Hasher) {
    high.hash(into: &hasher)
    low.hash(into: &hasher)
  }

  public static func <<(lhs: UInt128, rhs: UInt128) -> UInt128 { lhs.maskingShiftLeft(rhs) }
  public static func <<=(lhs: inout UInt128, rhs: UInt128) { lhs = lhs.maskingShiftLeft(rhs) }
  public static func >>(lhs: UInt128, rhs: UInt128) -> UInt128 { lhs.maskingShiftRight(rhs) }
  public static func >>=(lhs: inout UInt128, rhs: UInt128) { lhs = lhs.maskingShiftRight(rhs) }

  public static func |(lhs: UInt128, rhs: UInt128) -> UInt128 { lhs.bitwiseOr(rhs) }
  public static func |=(lhs: inout UInt128, rhs: UInt128) { lhs = lhs.bitwiseOr(rhs) }
  public static func &(lhs: UInt128, rhs: UInt128) -> UInt128 { lhs.bitwiseAnd(rhs) }
  public static func &=(lhs: inout UInt128, rhs: UInt128) { lhs = lhs.bitwiseAnd(rhs) }
  public static func ^(lhs: UInt128, rhs: UInt128) -> UInt128 { lhs.bitwiseXor(rhs) }
  public static func ^=(lhs: inout UInt128, rhs: UInt128) { lhs = lhs.bitwiseXor(rhs) }

  public static func <(lhs: UInt128, rhs: UInt128) -> Bool { lhs.isLess(than: rhs) }
  public static func <=(lhs: UInt128, rhs: UInt128) -> Bool { lhs.isLess(than: rhs) || lhs.isEqual(to: rhs) }
  public static func ==(lhs: UInt128, rhs: UInt128) -> Bool { lhs.isEqual(to: rhs) }

  public static func +(lhs: UInt128, rhs: UInt128) -> UInt128 { lhs.addingReportingOverflow(rhs).partialValue }
  public static func +=(lhs: inout UInt128, rhs: UInt128) { lhs = lhs + rhs }
  public static func -(lhs: UInt128, rhs: UInt128) -> UInt128 { lhs.subtractingReportingOverflow(rhs).partialValue }
  public static func -=(lhs: inout UInt128, rhs: UInt128) { lhs = lhs - rhs }
  public static func *(lhs: UInt128, rhs: UInt128) -> UInt128 { lhs.multipliedReportingOverflow(by: rhs).partialValue }
  public static func *=(lhs: inout UInt128, rhs: UInt128) { lhs = lhs * rhs }
  public static func /(lhs: UInt128, rhs: UInt128) -> UInt128 { lhs.dividedReportingOverflow(by: rhs).partialValue }
  public static func /=(lhs: inout UInt128, rhs: UInt128) { lhs = lhs / rhs }

  public static func &+(lhs: UInt128, rhs: UInt128) -> UInt128 { lhs.addingReportingOverflow(rhs).partialValue }
  public static func &-(lhs: UInt128, rhs: UInt128) -> UInt128 { lhs.subtractingReportingOverflow(rhs).partialValue }

  public static func %(lhs: UInt128, rhs: UInt128) -> UInt128 { lhs.remainderReportingOverflow(dividingBy: rhs).partialValue }
  public static func %=(lhs: inout UInt128, rhs: UInt128) { lhs = lhs % rhs }

  public static func addingWithOverflow(_ lhs: UInt128, _ rhs: UInt128) -> (UInt128, overflow: Bool) {
    let (partialValue, overflow) = lhs.addingReportingOverflow(rhs)
    return (partialValue, overflow)
  }

  public static func subtractWithOverflow(_ lhs: UInt128, _ rhs: UInt128) -> (UInt128, overflow: Bool) {
    let (partialValue, overflow) = lhs.subtractingReportingOverflow(rhs)
    return (partialValue, overflow)
  }

  public static func divideWithOverflow(_ lhs: UInt128, _ rhs: UInt128) -> (UInt128, overflow: Bool) {
    let (partialValue, overflow) = lhs.dividedReportingOverflow(by: rhs)
    return (partialValue, overflow)
  }

  public static func multiplyWithOverflow(_ lhs: UInt128, _ rhs: UInt128) -> (UInt128, overflow: Bool) {
    let (partialValue, overflow) = lhs.multipliedReportingOverflow(by: rhs)
    return (partialValue, overflow)
  }

  public static func remainderWithOverflow(_ lhs: UInt128, _ rhs: UInt128) -> (UInt128, overflow: Bool) {
    return (lhs.quotientAndRemainder(dividingBy: rhs).1, false)
  }

  public static var allZeros: UInt128 { return UInt128() }

//  public func toIntMax() -> IntMax { return IntMax(low) }
}

public extension String {
  init(_ value: UInt128, radix: Int, uppercase: Bool = false) {
    guard value.high > 0 else {
      self = String(value.low, radix: radix, uppercase: uppercase)
      return
    }
    switch radix {
      case 32:
        let high = String(value.high, radix: radix, uppercase: uppercase)
        let leadingZeros = String(repeating: "0", count: countLeadingZeros(value.low) / 16)
        let low = String(value.low, radix: radix, uppercase: uppercase)
        self = "\(high)\(leadingZeros)\(low)"

      case 16:
        let high = String(value.high, radix: radix, uppercase: uppercase)
        let leadingZeros = String(repeating: "0", count: countLeadingZeros(value.low) / 8)
        let low = String(value.low, radix: radix, uppercase: uppercase)
        self = "\(high)\(leadingZeros)\(low)"

      case 8:
        let high = String(value.high, radix: radix, uppercase: uppercase)
        let leadingZeros = String(repeating: "0", count: countLeadingZeros(value.low) / 4)
        let low = String(value.low, radix: radix, uppercase: uppercase)
        self = "\(high)\(leadingZeros)\(low)"

      case 4:
        let high = String(value.high, radix: radix, uppercase: uppercase)
        let leadingZeros = String(repeating: "0", count: countLeadingZeros(value.low) / 2)
        let low = String(value.low, radix: radix, uppercase: uppercase)
        self = "\(high)\(leadingZeros)\(low)"

      case 2:
        let high = String(value.high, radix: radix, uppercase: uppercase)
        let leadingZeros = String(repeating: "0", count: countLeadingZeros(value.low))
        let low = String(value.low, radix: radix, uppercase: uppercase)
        self = "\(high)\(leadingZeros)\(low)"

      case 10:
        let n7 = value.high >> 48
        let n6 = (value.high >> 32) & 0xFFFF
        let n5 = (value.high >> 16) & 0xFFFF
        let n4 = value.high & 0xFFFF
        let n3 = value.low >> 48
        let n2 = (value.low >> 32) & 0xFFFF
        let n1 = (value.low >> 16) & 0xFFFF
        let n0 = value.low & 0xFFFF

        var d8 = n7 * 51
        var d7 = n7 * 9229
        d7 = d7 &+ n6 * 7
        var d6 = n7 * 6858
        d6 = d6 &+ n6 * 9228
        d6 = d6 &+ n5
        var d5 = n7 * 5348
        d5 = d5 &+ n6 * 1625
        d5 = d5 &+ n5 * 2089
        var d4 = n7 * 2762
        d4 = d4 &+ n6 * 1426
        d4 = d4 &+ n5 * 2581
        d4 = d4 &+ n4 * 1844
        var d3 = n7 * 8530
        d3 = d3 &+ n6 * 4337
        d3 = d3 &+ n5 * 9614
        d3 = d3 &+ n4 * 6744
        d3 = d3 &+ n3 * 281
        var d2 = n7 * 4963
        d2 = d2 &+ n6 * 5935
        d2 = d2 &+ n5 * 6291
        d2 = d2 &+ n4 * 737
        d2 = d2 &+ n3 * 4749
        d2 = d2 &+ n2 * 42
        var d1 = n7 * 2922
        d1 = d1 &+ n6 * 4395
        d1 = d1 &+ n5 * 7470
        d1 = d1 &+ n4 * 955
        d1 = d1 &+ n3 * 7671
        d1 = d1 &+ n2 * 9496
        d1 = d1 &+ n1 * 6
        var d0 = n7 * 96
        d0 = d0 &+ n6 * 336
        d0 = d0 &+ n5 * 6176
        d0 = d0 &+ n4 * 1616
        d0 = d0 &+ n3 * 656
        d0 = d0 &+ n2 * 7296
        d0 = d0 &+ n1 * 5536
        d0 = d0 &+ n0

        var carry = d0 / 10000
        d0 %= 10000

        d1 = d1 &+ carry
        carry = d1 / 10000
        d1 %= 10000

        d2 = d2 &+ carry
        carry = d2 / 10000
        d2 %= 10000

        d3 = d3 &+ carry
        carry = d3 / 10000
        d3 %= 10000

        d4 = d4 &+ carry
        carry = d4 / 10000
        d4 %= 10000

        d5 = d5 &+ carry
        carry = d5 / 10000
        d5 %= 10000

        d6 = d6 &+ carry
        carry = d6 / 10000
        d6 %= 10000

        d7 = d7 &+ carry
        carry = d7 / 10000
        d7 %= 10000

        d8 = d8 &+ carry

        var foundFirstNonZero = false
        var strings: [String] = []

        for digit in [d8, d7, d6, d5, d4, d3, d2, d1, d0] {
          switch digit {
            case 0:
              strings.append(foundFirstNonZero ? "0000" : "")
            default:
              switch foundFirstNonZero {
                case true:
                  strings.append(String(format: "%04u", digit))
                case false:
                  foundFirstNonZero = true
                  strings.append(digit.description)
              }
          }
        }

        guard strings.last?.isEmpty != true else { self = "0"; return }
        self = strings.joined(separator: "")

      default:
        // TODO: Fill in the gaps for bases 3 through 32
        fatalError("\(#function) not yet implemented for bases other than 2, 8, 4, 10, and 16")
    }
  }
}

public extension UInt128 {
  @frozen
  struct Words: RandomAccessCollection {
    public typealias Indices = Range<Int>
    public typealias SubSequence = Slice<UInt128.Words>

    @usableFromInline
    internal var _value: UInt128

    @inlinable
    public init(_ value: UInt128) {
      _value = value
    }

    public let count = 2

    public let startIndex = 0

    public let endIndex = 2

    @inlinable
    public var indices: Indices { return startIndex ..< endIndex }

    @_transparent
    public func index(after i: Int) -> Int { return i + 1 }

    @_transparent
    public func index(before i: Int) -> Int { return i - 1 }

    @inlinable
    public subscript(position: Int) -> UInt {
      precondition(position >= 0, "Negative word index")
      precondition(position < endIndex, "Word index out of range")
      return position == 0 ? _value.low.words[0] : _value.high.words[0]
    }
  }
}
