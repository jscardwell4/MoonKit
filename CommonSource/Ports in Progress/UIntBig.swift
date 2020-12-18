//
//  UIntBig.swift
//  MoonKit
//
//  Created by Jason Cardwell on 8/19/16.
//  Copyright © 2016 Jason Cardwell. All rights reserved.
//

import Foundation
import Swift

public struct UIntBig: BinaryInteger {

  fileprivate var buffer: [UInt]

  public init(_ value: UInt64) { self = UIntBig(UInt64(value)) }
  public init(_ value: UInt32) { self = UIntBig(UInt64(value)) }
  public init(_ value: UInt16) { self = UIntBig(UInt64(value)) }
  public init(_ value: UInt8)  { self = UIntBig(UInt64(value)) }
  public init(_ value: UInt)   { buffer = [value] }
  public init(_ value: Int64)  { self = UIntBig(UInt64(value)) }
  public init(_ value: Int32)  { self = UIntBig(UInt64(value)) }
  public init(_ value: Int16)  { self = UIntBig(UInt64(value)) }
  public init(_ value: Int8)   { self = UIntBig(UInt64(value)) }
  public init(_ value: Int)    { self = UIntBig(UInt64(value)) }

  public init(_ value: Decimal) {
    guard value.sign == .plus else { self = UIntBig(); return }
    let decimalHandler = NSDecimalNumberHandler(roundingMode: .down,
                                                scale: 0,
                                                raiseOnExactness: false,
                                                raiseOnOverflow: false,
                                                raiseOnUnderflow: false,
                                                raiseOnDivideByZero: false)
    let digits = (value as NSDecimalNumber).rounding(accordingToBehavior: decimalHandler).decimalValue.digits()
    self = UIntBig(digits: digits)
  }

  public static var isSigned: Bool { return false }

  public var magnitude: UIntBig { return self }

  public func isEqual(to rhs: UIntBig) -> Bool { return buffer.elementsEqual(rhs.buffer) }

  public func isLess(than rhs: UIntBig) -> Bool {
    switch (buffer.count, rhs.buffer.count) {
      case let (l, r) where l < r: return true
      case let (l, r) where l > r: return false
      case (0, 0): return false
      default: return buffer[0] < rhs.buffer[0]
    }
  }

  public func word(at n: Int) -> UInt { return buffer[n] }

  public var bitWidth: Int { return buffer.count * 64 }

  public var minimumSignedRepresentationBitWidth: Int { return bitWidth }

  public mutating func formRemainder(dividingBy rhs: UIntBig) { self = quotientAndRemainder(dividingBy: rhs).1 }

  public func quotientAndRemainder(dividingBy rhs: UIntBig) -> (UIntBig, UIntBig) {
    fatalError("\(#function) not yet implemented")
  }

  public func signum() -> UIntBig { return UIntBig(1) }

  public init(integerLiteral value: UInt64) { self = UIntBig(value) }

  public init<T:BinaryInteger>(_ source: T) {
    buffer = (0..<source.countRepresentedWords).map({source.word(at: $0)})
  }

/*  private static func convertFloatingPoint<T:BinaryFloatingPoint>(_ source: T) -> (result: UIntBig, exact: Bool) {
    var source = source
    var value = UIntBig()
    var shift = UInt64()
    let base: T = 65536
    let exact = source - source.truncatingRemainder(dividingBy: 10) == source
    while source > 0  && shift < 128 {
      let r = source.truncatingRemainder(dividingBy: base).rounded(.towardZero)
      let bits: UInt64
      switch MemoryLayout<T>.size {
        case 4:
          bits = UInt64(Float(sign: .plus,
                            exponentBitPattern: UInt(r.exponentBitPattern.toUIntMax()),
                            significandBitPattern: UInt32(UInt(r.significandBitPattern.toUIntMax()))))
        default:
          bits = UInt64(Double(sign: .plus,
                              exponentBitPattern: UInt(r.exponentBitPattern.toUIntMax()),
                              significandBitPattern: UInt64(UInt(UInt(r.significandBitPattern.toUIntMax())))))
      }
      switch shift {
        case 0...63:   value.low |= bits << shift
        case 64...127: value.high |= bits << (shift &- 64)
        default:       unreachable()
      }
      shift = shift &+ 16
      source.divide(by: base)
      source.round(.towardZero)
    }

    return (value, exact)
  }
*/
//  public init<T:BinaryFloatingPoint>(_ source: T) { self = UIntBig.convertFloatingPoint(source).result }

  public init<T:FloatingPoint>(_ source: T) {
    switch source {
      case let float as Float:   self = UIntBig(float)
      case let double as Double: self = UIntBig(double)
      default:                   self = UIntBig()
    }
  }

  public init(_truncatingBits bits: UInt) { self = UIntBig(bits) }

  public init<T:BinaryInteger>(clamping source: T) { self = UIntBig(source) }

//  public init?<T:BinaryFloatingPoint>(exactly source: T) {
//    let (maybeSelf, exact) = UIntBig.convertFloatingPoint(source)
//    guard exact else { return nil }
//    self = maybeSelf
//  }

  public init?<T:FloatingPoint>(exactly source: T) {
    switch source {
      case let float as Float:   self.init(exactly: float)
      case let double as Double: self.init(exactly: double)
      default:                   return nil
    }
  }

  public init<T:BinaryInteger>(extendingOrTruncating source: T) { self = UIntBig(source) }

  public var description: String { return String(self, radix: 10) }
//  public var debugDescription: String {
//    return "\(description) {high: 0x\(String(high, radix: 16)); low: 0x\(String(low, radix: 16))}"
//  }

  public func add(_ rhs: UIntBig) {
    fatalError("\(#function) not yet implemented")
  }
/*  public func addingWithOverflow(_ rhs: UIntBig) -> (partialValue: UIntBig, overflow: ArithmeticOverflow) {
    var partialValue = UIntBig()

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

    return (partialValue, carry > 0 ? .overflow : .none)
  }
*/
  public func divide(by rhs: UIntBig) {
    fatalError("\(#function) not yet implemented")
  }
/*  public func dividedWithOverflow(by rhs: UIntBig) -> (partialValue: UIntBig, overflow: ArithmeticOverflow) {
    return (quotientAndRemainder(dividingBy: rhs).0, .none)
  }
*/
  public func multiply(by rhs: UIntBig) {
    fatalError("\(#function) not yet implemented")
  }
/*  public func multipliedWithOverflow(by rhs: UIntBig) -> (partialValue: UIntBig, overflow: ArithmeticOverflow) {
    let (highpᴸᴸ, lowpᴸᴸ) = MoonKit.doubleWidthMultiply(low, rhs.low)
    var overflow: ArithmeticOverflow = .none
    var didOverflow = false
    let pᴸᴴ: UInt64, pᴴᴸ: UInt64
    (pᴸᴴ, didOverflow) = UInt64.multiplyWithOverflow(low, rhs.high)
    if didOverflow { overflow = .overflow }
    (pᴴᴸ, didOverflow) = UInt64.multiplyWithOverflow(high, rhs.low)
    if didOverflow { overflow = .overflow }

    var partialValue = UIntBig(low: lowpᴸᴸ)
    let mask: UInt64 = 0xFFFFFFFF
    var s = (highpᴸᴸ & mask) &+ (pᴸᴴ & mask) &+ (pᴴᴸ & mask)
    var c = s >> 32
    partialValue.high |= s & mask
    s = (highpᴸᴸ >> 32) &+ (pᴸᴴ >> 32) &+ (pᴴᴸ >> 32) &+ c
    c = s >> 32
    partialValue.high |= s << 32
    if c > 0 { overflow = .overflow }
    return (partialValue, overflow)
  }
*/
  public func subtract(_ rhs: UIntBig) {
    fatalError("\(#function) not yet implemented")
  }
/*  public func subtractingWithOverflow(_ rhs: UIntBig) -> (partialValue: UIntBig, overflow: ArithmeticOverflow) {
    var partialValue = UIntBig()
    var (result, overflow)  = UInt64.subtractWithOverflow(low, rhs.low)
    partialValue.low = result
    (result, overflow) = UInt64.subtractWithOverflow(overflow && high == 0 ? UInt64.max : overflow ? high &- 1 : high, rhs.high)
    partialValue.high = result
    return (partialValue, overflow ? .overflow : .none)
  }
*/

/*  public static func doubleWidthMultiply(_ lhs: UIntBig, _ rhs: UIntBig) -> (high: UIntBig, low: UIntBig) {
    let (highpᴸᴸ, lowpᴸᴸ) = MoonKit.doubleWidthMultiply(lhs.low, rhs.low)
    let (highpᴸᴴ, lowpᴸᴴ) = MoonKit.doubleWidthMultiply(lhs.low, rhs.high)
    let (highpᴴᴸ, lowpᴴᴸ) = MoonKit.doubleWidthMultiply(lhs.high, rhs.low)
    let (highpᴴᴴ, lowpᴴᴴ) = MoonKit.doubleWidthMultiply(lhs.high, rhs.high)

    var low = UIntBig(low: lowpᴸᴸ)
    var high = UIntBig(high: highpᴴᴴ)

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

    high.high = high.high &+  c

    return (high, low)
  }
*/

  /// Returns the value as an array of digits with leading zeros when the number of digits is less than `minLength`.
  public func digits(minLength: Int = 0) -> [UInt8] {
    fatalError("\(#function) not yet implemented")
//    var digits: Stack<UInt8> = []
//    var value = self
//    var exponent = Swift.max(minLength, log10(value).value)
//    repeat { digits.push(UInt8((value % 10).low)); value /= 10; exponent -= 1 } while value > 0
//    while exponent > 0 { digits.push(0); exponent -= 1 }
//    return Array(digits)
  }

  /// Initialize from an array of base 10 digits.
  public init(digits: [UInt8]) { self = digits.reduce(UIntBig()) { $0 * 10 &+ UIntBig($1) } }
}

extension Double {
  public init(_ value: UIntBig) {
    fatalError("\(#function) not yet implemented")
  }
}

extension Decimal {
  public init(_ value: UIntBig) {
    fatalError("\(#function) not yet implemented")
  }
}

extension UIntBig: Integer {
  public init(_builtinIntegerLiteral value: _MaxBuiltinIntegerType) {
    self = UIntBig(UInt64(_builtinIntegerLiteral: value))
  }

  public func advanced(by n: Double) -> UIntBig {
    return n < 0 ? subtracting(UIntBig(n)) : adding(UIntBig(n))
  }

  public func distance(to other: UIntBig) -> Double {
    return other.isLess(than: self)
      ? Double(subtracting(other)).negated()
      : Double(other.subtracting(self))
  }

  public var hashValue: Int { return buffer.reduce(0) {$0 ^ $1.hashValue} }

  public static func <(lhs: UIntBig, rhs: UIntBig) -> Bool { return lhs.isLess(than: rhs) }
  public static func <=(lhs: UIntBig, rhs: UIntBig) -> Bool {
    return lhs.isLess(than:rhs) || lhs.isEqual(to: rhs)
  }
  public static func ==(lhs: UIntBig, rhs: UIntBig) -> Bool { return lhs.isEqual(to: rhs) }

  public static func &(lhs: UIntBig, rhs: UIntBig) -> UIntBig {
    fatalError("\(#function) not yet implemented")
  }

  public static func |(lhs: UIntBig, rhs: UIntBig) -> UIntBig {
    fatalError("\(#function) not yet implemented")
  }

  public static func ^(lhs: UIntBig, rhs: UIntBig) -> UIntBig {
    fatalError("\(#function) not yet implemented")
  }

  public static prefix func ~(x: UIntBig) -> UIntBig {
    fatalError("\(#function) not yet implemented")
  }

  public static func +(lhs: UIntBig, rhs: UIntBig) -> UIntBig { return lhs.adding(rhs) }
  public static func +=(lhs: inout UIntBig, rhs: UIntBig) { lhs.add(rhs) }
  public static func -(lhs: UIntBig, rhs: UIntBig) -> UIntBig { return lhs.subtracting(rhs) }
  public static func -=(lhs: inout UIntBig, rhs: UIntBig) { lhs.subtract(rhs) }
  public static func *(lhs: UIntBig, rhs: UIntBig) -> UIntBig { return lhs.multiplied(by: rhs) }
  public static func *=(lhs: inout UIntBig, rhs: UIntBig) { lhs.multiply(by: rhs) }
  public static func /(lhs: UIntBig, rhs: UIntBig) -> UIntBig { return lhs.divided(by: rhs) }
  public static func /=(lhs: inout UIntBig, rhs: UIntBig) { lhs.divide(by: rhs) }


  public static func %(lhs: UIntBig, rhs: UIntBig) -> UIntBig { return lhs.remainder(dividingBy: rhs) }
  public static func %=(lhs: inout UIntBig, rhs: UIntBig) { lhs.formRemainder(dividingBy: rhs) }

  public static func addWithOverflow(_ lhs: UIntBig, _ rhs: UIntBig) -> (UIntBig, overflow: Bool) {
    return (lhs + rhs, false)
  }
  public static func subtractWithOverflow(_ lhs: UIntBig, _ rhs: UIntBig) -> (UIntBig, overflow: Bool) {
    return (lhs - rhs, false)
  }
  public static func divideWithOverflow(_ lhs: UIntBig, _ rhs: UIntBig) -> (UIntBig, overflow: Bool) {
    return (lhs / rhs, false)
  }
  public static func multiplyWithOverflow(_ lhs: UIntBig, _ rhs: UIntBig) -> (UIntBig, overflow: Bool) {
    return (lhs * rhs, false)
  }
  public static func remainderWithOverflow(_ lhs: UIntBig, _ rhs: UIntBig) -> (UIntBig, overflow: Bool) {
    return (lhs.quotientAndRemainder(dividingBy: rhs).1, false)
  }

  public static var allZeros: UIntBig { return UIntBig() }

  public func toIntMax() -> IntMax {
    fatalError("\(#function) not yet implemented")
  }

}

extension UIntBig: CustomPlaygroundQuickLookable {
  public var customPlaygroundQuickLook: PlaygroundQuickLook { return .text(description) }
}

extension String {
  public init(_ value: UIntBig, radix: Int, uppercase: Bool = false) {
    fatalError("\(#function) not yet implemented")
/*    guard value.high > 0 else {
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
        let n6 = (value.high >> 32) & 0xffff
        let n5 = (value.high >> 16) & 0xffff
        let n4 = value.high & 0xffff
        let n3 = value.low >> 48
        let n2 = (value.low >> 32) & 0xffff
        let n1 = (value.low >> 16) & 0xffff
        let n0 = value.low & 0xffff

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
        //TODO: Fill in the gaps for bases 3 through 32
        fatalError("\(#function) not yet implemented for bases other than 2, 8, 4, 10, and 16")
    }
*/
  }
}
