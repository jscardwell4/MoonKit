//
//  BCD.swift
//  MoonKit
//
//  Created by Jason Cardwell on 8/15/16.
//  Copyright © 2016 Jason Cardwell. All rights reserved.
//

import Foundation
import Swift

fileprivate protocol _BCDInteger: FixedWidthInteger {
  associatedtype Base: UnsignedInteger, BitShifting, BitwiseOperations, ExpressibleByIntegerLiteral
  var _value: Base { get }
  init(bitPattern: Base)
  init(_ value: Base)
  func toUIntMax() -> UIntMax
  func toBase() -> Base
  static prefix func ~(value: Self) -> Self
}

extension _BCDInteger {

  func _addingWithOverflow(_ rhs: Self, adjustMSB: Bool = false) -> (partialValue: Self, overflow: ArithmeticOverflow) {
    let (partialValue, overflow) = _add(_value, rhs._value, bitWidth: bitWidth, adjustMSB: adjustMSB)
    return (Self(bitPattern: partialValue), overflow)
  }

  func _subtractingWithOverflow(_ rhs: Self) -> (partialValue: Self, overflow: ArithmeticOverflow) {
    let (partialValue, _) = _add(_value, (~rhs)._value, bitWidth: bitWidth, adjustMSB: false)
    return (Self(bitPattern: partialValue), .none)
  }

  func _multipliedWithOverflow(by rhs: Self) -> (partialValue: Self, overflow: ArithmeticOverflow) {
    guard _value != 0 && rhs._value != 0 else { return (0, .none) }
    var a = _value, n = rhs.toBase()
    var overflow: ArithmeticOverflow = .none

    func add(_ x: Base, _ y: Base) -> Base {
      let result = _add(x, y, bitWidth: bitWidth, adjustMSB: true)
      if case .overflow = result.overflow, case .none = overflow { overflow = .overflow }
      return result.partialValue
    }

    while n & 0b1 != 0b1 {
      a = add(a, a)
      n = n >> 1
    }
    guard n != 1 else { return (Self.init(bitPattern: a), overflow) }
    n = (n - 1) >> 1
    var r = a
    a = add(a, a)
    while true {
      if n & 0b1 == 0b1 {
        r = add(r, a)
        guard n != 1 else { return (Self.init(bitPattern: r), overflow) }
      }
      n = n >> 1
      a = add(a, a)
    }
  }

  static func _doubleWidthMultiply(_ lhs: Self, _ rhs: Self) -> (high: Self, low: Self) {
    //TODO: Implement actual double width multiply
    guard lhs._value != 0 && rhs._value != 0 else { return (0, 0) }
    var a = lhs._value, n = rhs.toBase()
    var overflow: ArithmeticOverflow = .none

    func add(_ x: Base, _ y: Base) -> Base {
      let result = _add(x, y, bitWidth: bitWidth, adjustMSB: true)
      if case .overflow = result.overflow, case .none = overflow { overflow = .overflow }
      return result.partialValue
    }

    while n & 0b1 != 0b1 {
      a = add(a, a)
      n = n >> 1
    }
    guard n != 1 else { return (0, Self.init(bitPattern: a)) }
    n = (n - 1) >> 1
    var r = a
    a = add(a, a)
    while true {
      if n & 0b1 == 0b1 {
        r = add(r, a)
        guard n != 1 else { return (0, Self.init(bitPattern: r)) }
      }
      n = n >> 1
      a = add(a, a)
    }
  }

  func _dividedWithOverflow(by rhs: Self) -> (partialValue: Self, overflow: ArithmeticOverflow) {
    let (partialValue, overflow) = Base.divideWithOverflow(Base(toUIntMax()), Base(rhs.toUIntMax()))
    return (Self(partialValue), overflow ? .overflow : .none)
  }

  var _popcount: Int { return Int(_countOnes(self).toUIntMax()) }
  var _leadingZeros: Int { return Int(_countLeadingZeros(self).toUIntMax()) }
  func _maskingShiftLeft(_ amount: Base) -> Self { return Self.init(bitPattern: _value << (amount * 4)) }
  func _maskingShiftRight(_ amount: Base) -> Self { return Self.init(bitPattern: _value >> (amount * 4)) }
  func _bitwiseOr(_ rhs: Self) -> Self { return Self.init(bitPattern: _value | rhs._value) }
  func _bitwiseAnd(_ rhs: Self) -> Self { return Self.init(bitPattern: _value & rhs._value) }
  func _bitwiseXor(_ rhs: Self) -> Self { return Self.init(bitPattern: _value ^ rhs._value) }
}

fileprivate func _countOnes<I>(of value: I, bitWidth: Int) -> I
  where I:UnsignedInteger, I:BitShifting, I:BitwiseOperations, I:ExpressibleByIntegerLiteral
{
  var result = value
  switch bitWidth {
    case 8:
      result = ((result >>  1) & 0x55) + (result & 0x55)
      result = ((result >>  2) & 0x33) + (result & 0x33)
      result = ((result >>  4)       ) + (result & 0x07)
    case 16:
      result = ((result >>  1) & 0x5555) + (result & 0x5555)
      result = ((result >>  2) & 0x3333) + (result & 0x3333)
      result = ((result >>  4) & 0x0707) + (result & 0x0707)
      result = ((result >>  8)         ) + (result & 0x000F)
    case 32:
      result = ((result >>  1) & 0x55555555) + (result & 0x55555555)
      result = ((result >>  2) & 0x33333333) + (result & 0x33333333)
      result = ((result >>  4) & 0x07070707) + (result & 0x07070707)
      result = ((result >>  8) & 0x000F000F) + (result & 0x000F000F)
      result = ((result >> 16)             ) + (result & 0x0000001F)
    default:
      result = ((result >>  1) & 0x5555555555555555) + (result & 0x5555555555555555)
      result = ((result >>  2) & 0x3333333333333333) + (result & 0x3333333333333333)
      result = ((result >>  4) & 0x0707070707070707) + (result & 0x0707070707070707)
      result = ((result >>  8) & 0x000F000F000F000F) + (result & 0x000F000F000F000F)
      result = ((result >> 16) & 0x0000001F0000001F) + (result & 0x0000001F0000001F)
      result = ((result >> 32)                     ) + (result & 0x00000000000000FF)
    }
    return result
}

fileprivate func _countOnes<I:_BCDInteger>(_ value: I) -> I.Base {
  return _countOnes(of: value._value, bitWidth: I.bitWidth)
}

fileprivate func _countLeadingZeros<I>(of value: I, bitWidth: Int) -> I
  where I:UnsignedInteger, I:BitShifting, I:BitwiseOperations, I:ExpressibleByIntegerLiteral
{
  var result = value
  switch bitWidth {
    case 8:
      result |= (result >> 1)
      result |= (result >> 2)
      result |= (result >> 4)
    case 16:
      result |= (result >> 1)
      result |= (result >> 2)
      result |= (result >> 4)
      result |= (result >> 8)
    case 32:
      result |= (result >> 1)
      result |= (result >> 2)
      result |= (result >> 4)
      result |= (result >> 8)
      result |= (result >> 16)
    default:
      result |= (result >> 1)
      result |= (result >> 2)
      result |= (result >> 4)
      result |= (result >> 8)
      result |= (result >> 16)
      result |= (result >> 32)
  }
  return _countOnes(of: ~result, bitWidth: bitWidth)
}

fileprivate func _countLeadingZeros<I:_BCDInteger>(_ value: I) -> I.Base {
  return _countLeadingZeros(of: value._value, bitWidth: I.bitWidth)
}


fileprivate func _add<U:UnsignedInteger>(
  _ lhs: U,
  _ rhs: U,
  bitWidth: Int,
  adjustMSB: Bool = false) -> (partialValue: U, overflow: ArithmeticOverflow)
  where U:BitShifting, U:BitwiseOperations, U:ExpressibleByIntegerLiteral
{
  let a1: U, a2: U
  switch bitWidth {
    case 8:  a1 = 0x06;               a2 = 0x10
    case 16: a1 = 0x0666;             a2 = 0x1110
    case 32: a1 = 0x06666666;         a2 = 0x11111110
    default: a1 = 0x0666666666666666; a2 = 0x1111111111111110
  }

  let t1 = lhs + a1
  let overflow: Bool
  var t2: U
  (t2, overflow) = U.addWithOverflow(t1, rhs)
  if overflow && adjustMSB {
    let shift = U(UIntMax(bitWidth - 4))
    t2 = ((((t2 >> shift) + 0x10) % 10) << shift) | ((t2 << 4) >> 4)
  }
  let t3 = t1 ^ rhs
  let t4 = t2 ^ t3
  let t5 = ~t4 & a2
  let t6 = (t5 >> 2) | (t5 >> 3)
  let t7 = t2 - t6
  return (t7, overflow ? .overflow : .none)
}

fileprivate func _describe<I:FixedWidthInteger>(_ value: I) -> String {
  var shift = UInt64(value.bitWidth &- 4)
  let value = UInt64(value.word(at: 0))
  while shift > 0 && value & (0xF << shift) == 0 { shift -= 4 }
  var result = ""
  while shift != 0 {
    result += "\((value & (0xF << shift)) >> shift)"
    shift = shift &- 4
  }
  result += "\(value & 0xF)"
  return result
}


public struct BCD8: CustomStringConvertible, FixedWidthInteger, _BCDInteger {

  public typealias Base = UInt8

  fileprivate var _value: Base

  fileprivate func toBase() -> UInt8 { return UInt8(self) }

  fileprivate init(bitPattern: Base) { _value = bitPattern }
  fileprivate func toUIntMax() -> UIntMax { return UIntMax(UInt8(self)) }
  public static var isSigned: Bool { return false }

  public var magnitude: BCD8 { return self }

  public func isEqual(to rhs: BCD8) -> Bool { return _value == rhs._value }
  public func isLess(than rhs: BCD8) -> Bool { return _value < rhs._value }

  public func word(at n: Int) -> UInt { return UInt(_value) }

  public static var bitWidth: Int { return 8 }
  public var bitWidth: Int { return 8 }

  public var minimumSignedRepresentationBitWidth: Int { return 8 }

  public mutating func formRemainder(dividingBy rhs: BCD8) {
    self = BCD8(Base(self) % Base(rhs))
  }

  public func quotientAndRemainder(dividingBy rhs: BCD8) -> (BCD8, BCD8) {
    let quotient = Base(self) / Base(rhs)
    let remainder = Base(self) % Base(rhs)
    return (BCD8(quotient), BCD8(remainder))
  }

  public func signum() -> BCD8 { return BCD8(bitPattern: 1) }
  public static var max: BCD8 { return BCD8(bitPattern: 0b11111001) }
  public static var min: BCD8 { return BCD8(bitPattern: 0b00000000) }

  
  public init<T:BinaryInteger>(_ source: T) { self = BCD8(Base(truncatingBitPattern: source.word(at: 0))) }
  public init<T:FloatingPoint>(_ source: T) {
    switch source {
      case let f as Float: self = BCD8(Base(f))
      case let d as Double: self = BCD8(Base(d))
      default: self = 0
    }
  }
  public init(_truncatingBits bits: UInt) { self = BCD8(Base(truncatingBitPattern: bits)) }
  public init<T:BinaryInteger>(clamping source: T) { self = BCD8(source) }
  public init?<T:FloatingPoint>(exactly source: T) {
    switch source {
      case let f as Float:
        let value = Base(f)
        guard Float(value) == f else { return nil }
        self = BCD8(value)
      case let d as Double:
        let value = Base(d)
        guard Double(value) == d else { return nil }
        self = BCD8(value)
      default: return nil
    }
  }
  public init<T:BinaryInteger>(extendingOrTruncating source: T) { self = BCD8(source) }


  init(_ value: Base) {
    precondition(value < 0xF9, "BCD8 supports up to 2 decimal digits")
    var d: Base, q: Base

    d = 6 * ((value >> 4) & 0xF) &+ (value & 0xF)
    q = d / 10
    d = d % 10
    _value = d

    d = q &+ ((value >> 4) & 0xF)

    _value |= d << 4
  }

  public var description: String { return _describe(self) }

  public func addingWithOverflow(_ rhs: BCD8) -> (partialValue: BCD8, overflow: ArithmeticOverflow) {
    return _addingWithOverflow(rhs, adjustMSB: true)
  }

  public func dividedWithOverflow(by rhs: BCD8) -> (partialValue: BCD8, overflow: ArithmeticOverflow) {
    return _dividedWithOverflow(by: rhs)
  }

  public func multipliedWithOverflow(by rhs: BCD8) -> (partialValue: BCD8, overflow: ArithmeticOverflow) {
    return _multipliedWithOverflow(by: rhs)
  }

  public func subtractingWithOverflow(_ rhs: BCD8) -> (partialValue: BCD8, overflow: ArithmeticOverflow) {
    return _subtractingWithOverflow(rhs)
  }

  public func bitwiseOr(_ rhs: BCD8) -> BCD8 { return _bitwiseOr(rhs) }
  public func bitwiseAnd(_ rhs: BCD8) -> BCD8 { return _bitwiseAnd(rhs) }
  public func bitwiseXor(_ rhs: BCD8) -> BCD8 { return _bitwiseXor(rhs) }

  public func maskingShiftLeft(_ rhs: BCD8) -> BCD8 { return _maskingShiftLeft(Base(rhs)) }
  public func maskingShiftRight(_ rhs: BCD8) -> BCD8 { return _maskingShiftRight(Base(rhs)) }


  public static func doubleWidthMultiply(_ lhs: BCD8, _ rhs: BCD8) -> (high: BCD8, low: BCD8) {
    return _doubleWidthMultiply(lhs, rhs)
  }

  public var leadingZeros: Int { return _leadingZeros }
  public var popcount: Int { return _popcount }

}

extension BCD8: ExpressibleByIntegerLiteral { public init(integerLiteral value: Base) { self = BCD8(value) } }

extension BCD8 {
  public static prefix func ~ (value: BCD8) -> BCD8 {
    let t1 = 0xF9 - value._value
    let t2 = t1 + 0x06
    let t3 = Base.addWithOverflow(t2, 0x01).0
    let t4 = t2 ^ 0x01
    let t5 = t3 ^ t4
    let t6 = ~t5 & 0x10
    let t7 = (t6 >> 2) | (t6 >> 3)
    let bitPattern = t3 - t7
    return BCD8(bitPattern: bitPattern)
  }
}

extension UInt8 {
  public init(_ value: BCD8) {
    self = ((value._value >> 4) * 10) + (value._value & 0xF)
  }
}

public struct BCD16: CustomStringConvertible, FixedWidthInteger, _BCDInteger {

  public typealias Base = UInt16

  fileprivate var _value: Base
  fileprivate func toBase() -> UInt16 { return UInt16(self) }

  fileprivate init(bitPattern: Base) { _value = bitPattern }
  fileprivate func toUIntMax() -> UIntMax { return UIntMax(UInt16(self)) }

  public static var isSigned: Bool { return false }

  public var magnitude: BCD16 { return self }

  public func isEqual(to rhs: BCD16) -> Bool { return _value == rhs._value }
  public func isLess(than rhs: BCD16) -> Bool { return _value < rhs._value }

  public func word(at n: Int) -> UInt { return UInt(_value) }

  public static var bitWidth: Int { return 16 }
  public var bitWidth: Int { return 16 }

  public var minimumSignedRepresentationBitWidth: Int { return 8 }

  mutating public func formRemainder(dividingBy rhs: BCD16) {
    self = BCD16(Base(self) % Base(rhs))
  }

  public func quotientAndRemainder(dividingBy rhs: BCD16) -> (BCD16, BCD16) {
    let quotient = Base(self) / Base(rhs)
    let remainder = Base(self) % Base(rhs)
    return (BCD16(quotient), BCD16(remainder))
  }

  public func signum() -> BCD16 { return BCD16(bitPattern: 1) }
  public static var max: BCD16 { return BCD16(bitPattern: 0b1111100110011001) }
  public static var min: BCD16 { return BCD16(bitPattern: 0b0000000000000000) }

  
  public init<T:BinaryInteger>(_ source: T) { self = BCD16(Base(truncatingBitPattern: source.word(at: 0))) }
  public init<T:FloatingPoint>(_ source: T) {
    switch source {
      case let f as Float: self = BCD16(Base(f))
      case let d as Double: self = BCD16(Base(d))
      default: self = 0
    }
  }
  public init(_truncatingBits bits: UInt) { self = BCD16(Base(truncatingBitPattern: bits)) }
  public init<T:BinaryInteger>(clamping source: T) { self = BCD16(source) }
  public init?<T:FloatingPoint>(exactly source: T) {
    switch source {
      case let f as Float:
        let value = Base(f)
        guard Float(value) == f else { return nil }
        self = BCD16(value)
      case let d as Double:
        let value = Base(d)
        guard Double(value) == d else { return nil }
        self = BCD16(value)
      default: return nil
    }
  }
  public init<T:BinaryInteger>(extendingOrTruncating source: T) { self = BCD16(source) }


  init(_ value: Base) {
    precondition(value < 16000, "BCD16 supports up to 4 decimal digits")
    var d: Base, q: Base

    let a = (value & 0xF, (value >> 4)  & 0xF, (value >> 8)  & 0xF, (value >> 12) & 0xF)

    d = 6 * (a.3 + a.2 + a.1)
    d = d &+ a.0
    q = d / 10
    d = d % 10
    _value = d

    d = q
    d = d &+ 9 * a.3
    d = d &+ 5 * a.2
    d = d &+ a.1
    q = d / 10
    d = d % 10
    _value |= d << 4

    d = q
    d = d &+ 2 * a.2
    q = d / 10
    d = d % 10
    _value |= d << 8

    d = q
    d = d &+ 4 * a.3

    _value |= d << 12
  }

  public var description: String { return _describe(self) }

  public func addingWithOverflow(_ rhs: BCD16) -> (partialValue: BCD16, overflow: ArithmeticOverflow) {
    return _addingWithOverflow(rhs, adjustMSB: true)
  }

  public func dividedWithOverflow(by rhs: BCD16) -> (partialValue: BCD16, overflow: ArithmeticOverflow) {
    return _dividedWithOverflow(by: rhs)
  }

  public func multipliedWithOverflow(by rhs: BCD16) -> (partialValue: BCD16, overflow: ArithmeticOverflow) {
    return _multipliedWithOverflow(by: rhs)
  }

  public func subtractingWithOverflow(_ rhs: BCD16) -> (partialValue: BCD16, overflow: ArithmeticOverflow) {
    return _subtractingWithOverflow(rhs)
  }

  public func bitwiseOr(_ rhs: BCD16) -> BCD16 { return _bitwiseOr(rhs) }

  public func bitwiseAnd(_ rhs: BCD16) -> BCD16 { return _bitwiseAnd(rhs) }

  public func bitwiseXor(_ rhs: BCD16) -> BCD16 { return _bitwiseXor(rhs) }

  public func maskingShiftLeft(_ rhs: BCD16) -> BCD16 { return _maskingShiftLeft(Base(rhs)) }
  public func maskingShiftRight(_ rhs: BCD16) -> BCD16 { return _maskingShiftRight(Base(rhs)) }


  public static func doubleWidthMultiply(_ lhs: BCD16, _ rhs: BCD16) -> (high: BCD16, low: BCD16) {
    return _doubleWidthMultiply(lhs, rhs)
  }

  public var leadingZeros: Int { return _leadingZeros }
  public var popcount: Int { return _popcount }

}

extension BCD16: ExpressibleByIntegerLiteral { public init(integerLiteral value: Base) { self = BCD16(value) } }

extension BCD16 {
  public static prefix func ~ (value: BCD16) -> BCD16 {
    let t1 = 0xF999 - value._value
    let t2 = t1 + 0x0666
    let t3 = Base.addWithOverflow(t2, 0x01).0
    let t4 = t2 ^ 0x0001
    let t5 = t3 ^ t4
    let t6 = ~t5 & 0x1110
    let t7 = (t6 >> 2) | (t6 >> 3)
    let bitPattern = t3 - t7
    return BCD16(bitPattern: bitPattern)
  }
}

extension UInt16 {
  public init(_ value: BCD16) {
    var result: UInt16 = 0
    var multiplier = UInt16(1)
    var shift = UInt16(0)
    repeat {
      result = result &+ ((value._value >> shift) & 0xF) * multiplier
      shift = shift &+ 4
      multiplier *= 10
    } while shift < 16
    self = result
  }
}

public struct BCD32: CustomStringConvertible, FixedWidthInteger, _BCDInteger {

  public typealias Base = UInt32

  fileprivate var _value: Base
  fileprivate func toBase() -> UInt32 { return UInt32(self) }

  fileprivate init(bitPattern: Base) { _value = bitPattern }
  fileprivate func toUIntMax() -> UIntMax { return UIntMax(UInt32(self)) }

  public static var isSigned: Bool { return false }

  public var magnitude: BCD32 { return self }

  public func isEqual(to rhs: BCD32) -> Bool { return _value == rhs._value }
  public func isLess(than rhs: BCD32) -> Bool { return _value < rhs._value }

  public func word(at n: Int) -> UInt { return UInt(_value) }

  public static var bitWidth: Int { return 32 }
  public var bitWidth: Int { return 32 }

  public var minimumSignedRepresentationBitWidth: Int { return 8 }

  mutating public func formRemainder(dividingBy rhs: BCD32) {
    self = BCD32(Base(self) % Base(rhs))
  }

  public func quotientAndRemainder(dividingBy rhs: BCD32) -> (BCD32, BCD32) {
    let quotient = Base(self) / Base(rhs)
    let remainder = Base(self) % Base(rhs)
    return (BCD32(quotient), BCD32(remainder))
  }

  public func signum() -> BCD32 { return BCD32(bitPattern: 1) }
  public static var max: BCD32 { return BCD32(bitPattern: 0b11111001100110011001100110011001) }
  public static var min: BCD32 { return BCD32(bitPattern: 0b00000000000000000000000000000000) }

  
  public init<T:BinaryInteger>(_ source: T) { self = BCD32(Base(truncatingBitPattern: source.word(at: 0))) }
  public init<T:FloatingPoint>(_ source: T) {
    switch source {
      case let f as Float: self = BCD32(Base(f))
      case let d as Double: self = BCD32(Base(d))
      default: self = 0
    }
  }
  public init(_truncatingBits bits: UInt) { self = BCD32(Base(truncatingBitPattern: bits)) }
  public init<T:BinaryInteger>(clamping source: T) { self = BCD32(source) }
  public init?<T:FloatingPoint>(exactly source: T) {
    switch source {
      case let f as Float:
        let value = Base(f)
        guard Float(value) == f else { return nil }
        self = BCD32(value)
      case let d as Double:
        let value = Base(d)
        guard Double(value) == d else { return nil }
        self = BCD32(value)
      default: return nil
    }
  }
  public init<T:BinaryInteger>(extendingOrTruncating source: T) { self = BCD32(source) }


  init(_ value: Base) {
    precondition(value < 160000000, "BCD32 supports up to 8 decimal digits")
    var d: Base, q: Base

    let a: (Base, Base, Base, Base, Base, Base, Base, Base) = (
      value         & 0xF,
      (value >> 4)  & 0xF,
      (value >> 8)  & 0xF,
      (value >> 12) & 0xF,
      (value >> 16) & 0xF,
      (value >> 20) & 0xF,
      (value >> 24) & 0xF,
      (value >> 28) & 0xF
    )

    d = 6 * (a.7 &+ a.6 &+ a.5 &+ a.4 &+ a.3 &+ a.2 &+ a.1)
    d = d &+ a.0
    q = d / 10
    d = d % 10
    _value = d

    d = q
    d = d &+ 5 * (a.7 &+ a.2)
    d = d &+ a.6
    d = d &+ 7 * a.5
    d = d &+ 3 * a.4
    d = d &+ 9 * a.3
    d = d &+ a.1
    q = d / 10
    d = d % 10
    _value |= d << 4

    d = q
    d = d &+ 4 * a.7
    d = d &+ 2 * a.6
    d = d &+ 2 * a.2
    d = d &+ 5 * (a.5 &+ a.4)
    q = d / 10
    d = d % 10
    _value |= d << 8

    d = q
    d = d &+ 5 * (a.7 &+ a.4)
    d = d &+ 7 * a.6
    d = d &+ 8 * a.5
    d = d &+ 4 * a.3
    q = d / 10
    d = d % 10
    _value |= d << 12

    d = q
    d = d &+ 3 * a.7
    d = d &+ 7 * a.6
    d = d &+ 4 * a.5
    d = d &+ 6 * a.4
    q = d / 10
    d = d % 10
    _value |= d << 16

    d = q
    d = d &+ 4 * a.7
    d = d &+ 7 * a.6
    q = d / 10
    d = d % 10
    _value |= d << 20

    d = q
    d = d &+ 8 * a.7
    d = d &+ 6 * a.6
    d = d &+ a.5
    q = d / 10
    d = d % 10
    _value |= d << 24

    d = q
    d = d &+ 6 * a.7
    d = d &+ a.6

    _value |= d << 28

  }

  public var description: String { return _describe(self) }

  public func addingWithOverflow(_ rhs: BCD32) -> (partialValue: BCD32, overflow: ArithmeticOverflow) {
    return _addingWithOverflow(rhs, adjustMSB: true)
  }

  public func dividedWithOverflow(by rhs: BCD32) -> (partialValue: BCD32, overflow: ArithmeticOverflow) {
    return _dividedWithOverflow(by: rhs)
  }

  public func multipliedWithOverflow(by rhs: BCD32) -> (partialValue: BCD32, overflow: ArithmeticOverflow) {
    return _multipliedWithOverflow(by: rhs)
  }

  public func subtractingWithOverflow(_ rhs: BCD32) -> (partialValue: BCD32, overflow: ArithmeticOverflow) {
    return _subtractingWithOverflow(rhs)
  }

  public func bitwiseOr(_ rhs: BCD32) -> BCD32 { return _bitwiseOr(rhs) }

  public func bitwiseAnd(_ rhs: BCD32) -> BCD32 { return _bitwiseAnd(rhs) }

  public func bitwiseXor(_ rhs: BCD32) -> BCD32 { return _bitwiseXor(rhs) }

  public func maskingShiftLeft(_ rhs: BCD32) -> BCD32 { return _maskingShiftLeft(Base(rhs)) }
  public func maskingShiftRight(_ rhs: BCD32) -> BCD32 { return _maskingShiftRight(Base(rhs)) }


  public static func doubleWidthMultiply(_ lhs: BCD32, _ rhs: BCD32) -> (high: BCD32, low: BCD32) {
    return _doubleWidthMultiply(lhs, rhs)
  }

  public var leadingZeros: Int { return _leadingZeros }
  public var popcount: Int { return _popcount }

}

extension BCD32: ExpressibleByIntegerLiteral { public init(integerLiteral value: Base) { self = BCD32(value) } }

extension BCD32 {
  public static prefix func ~ (value: BCD32) -> BCD32 {
    let t1 = 0xF9999999 - value._value
    let t2 = t1 + 0x06666666
    let t3 = Base.addWithOverflow(t2, 0x01).0
    let t4 = t2 ^ 0x00000001
    let t5 = t3 ^ t4
    let t6 = ~t5 & 0x11111110
    let t7 = (t6 >> 2) | (t6 >> 3)
    let bitPattern = t3 - t7
    return BCD32(bitPattern: bitPattern)
  }
}

extension UInt32 {
  public init(_ value: BCD32) {
    var result: UInt32 = 0
    var multiplier = UInt32(1)
    var shift = UInt32(0)
    repeat {
      result = result &+ ((value._value >> shift) & 0xF) * multiplier
      shift = shift &+ 4
      multiplier *= 10
    } while shift < 32
    self = result
  }
}

public struct BCD64: CustomStringConvertible, FixedWidthInteger, _BCDInteger {

  public typealias Base = UInt64

  fileprivate var _value: Base
  fileprivate func toBase() -> UInt64 { return UInt64(self) }

  fileprivate init(bitPattern: Base) { _value = bitPattern }
  fileprivate func toUIntMax() -> UIntMax { return UIntMax(UInt64(self)) }

  public static var isSigned: Bool { return false }

  public var magnitude: BCD64 { return self }

  public func isEqual(to rhs: BCD64) -> Bool { return _value == rhs._value }
  public func isLess(than rhs: BCD64) -> Bool { return _value < rhs._value }

  public func word(at n: Int) -> UInt {
    return UInt(MemoryLayout<UInt>.size == MemoryLayout<Base>.size ? _value : n == 0 ? _value & 0xFFFFFFFF : _value >> 32)
  }

  public static var bitWidth: Int { return 64 }
  public var bitWidth: Int { return 64 }

  public var minimumSignedRepresentationBitWidth: Int { return 8 }

  mutating public func formRemainder(dividingBy rhs: BCD64) {
    self = BCD64(Base(self) % Base(rhs))
  }

  public func quotientAndRemainder(dividingBy rhs: BCD64) -> (BCD64, BCD64) {
    let quotient = Base(self) / Base(rhs)
    let remainder = Base(self) % Base(rhs)
    return (BCD64(quotient), BCD64(remainder))
  }

  public func signum() -> BCD64 { return BCD64(bitPattern: 1) }
  public static var max: BCD64 { return BCD64(bitPattern: 0b1111100110011001100110011001100110011001100110011001100110011001) }
  public static var min: BCD64 { return BCD64(bitPattern: 0b0000000000000000000000000000000000000000000000000000000000000000) }

  
  public init<T:BinaryInteger>(_ source: T) { self = BCD64(Base(source.word(at: 0))) }
  public init<T:FloatingPoint>(_ source: T) {
    switch source {
      case let f as Float: self = BCD64(Base(f))
      case let d as Double: self = BCD64(Base(d))
      default: self = 0
    }
  }
  public init(_truncatingBits bits: UInt) { self = BCD64(Base(bits)) }
  public init<T:BinaryInteger>(clamping source: T) { self = BCD64(source) }
  public init?<T:FloatingPoint>(exactly source: T) {
    switch source {
      case let f as Float:
        let value = Base(f)
        guard Float(value) == f else { return nil }
        self = BCD64(value)
      case let d as Double:
        let value = Base(d)
        guard Double(value) == d else { return nil }
        self = BCD64(value)
      default: return nil
    }
  }
  public init<T:BinaryInteger>(extendingOrTruncating source: T) { self = BCD64(source) }


  init(_ value: Base) {
    precondition(value < 16000000000000000, "BCD64 supports up to 16 decimal digits")
    let a: (Base, Base, Base, Base, Base, Base, Base, Base,
      Base, Base, Base, Base, Base, Base, Base, Base) = (
        value         & 0xF,
        (value >>  4) & 0xF,
        (value >>  8) & 0xF,
        (value >> 12) & 0xF,
        (value >> 16) & 0xF,
        (value >> 20) & 0xF,
        (value >> 24) & 0xF,
        (value >> 28) & 0xF,
        (value >> 32) & 0xF,
        (value >> 36) & 0xF,
        (value >> 40) & 0xF,
        (value >> 44) & 0xF,
        (value >> 48) & 0xF,
        (value >> 52) & 0xF,
        (value >> 56) & 0xF,
        (value >> 60) & 0xF
    )

    var q: Base, d: Base

    d = (6 * (a.15 &+ a.14 &+ a.13 &+ a.12 &+ a.11 &+ a.10 &+ a.9 &+ a.8))
    d = d &+ (6 * (a.7 &+ a.6 &+ a.5 &+ a.4 &+ a.3 &+ a.2 &+ a.1))
    d = d  &+ a.0
    q = d / 10
    _value = d % 10

    d = q
    d = d &+ (7 * (a.15 &+ a.10 &+ a.5))
    d = d &+ (3 * (a.14 &+ a.9 &+ a.4))
    d = d &+ (9 * (a.13 &+ a.8 &+ a.3))
    d = d &+ (5 * (a.12 &+ a.7 &+ a.2))
    d = d &+ a.11
    d = d &+ a.6
    d = d &+ a.1
    q = d / 10
    d = d % 10
    _value |= d << 4

    d = q
    d = d &+ (9 * (a.15 &+ a.14))
    d = d &+ (4 * (a.13 &+ a.11 &+ a.7))
    d = d &+ (6 * a.12)
    d = d &+ (7 * (a.10 &+ a.9))
    d = d &+ (2 * (a.8 &+ a.6 &+ a.2))
    d = d &+ (5 * (a.5 &+ a.4))
    q = d / 10
    d = d % 10
    _value |= d << 8

    d = q
    d = d &+ (6 * (a.15 &+ a.9))
    d = d &+ (7 * (a.14 &+ a.10 &+ a.8 &+ a.6))
    d = d &+ (4 * (a.11 &+ a.3))
    d = d &+ (5 * (a.7 &+ a.4))
    d = d &+ (8 * a.5)
    q = d / 10
    d = d % 10
    _value |= d << 12

    d = q
    d = d &+ (4 * (a.15 &+ a.11 &+ a.5))
    d = d &+ (2 * (a.14 &+ a.10))
    d = d &+ (7 * (a.13 &+ a.9 &+ a.6))
    d = d &+ a.12
    d = d &+ (6 * (a.8 &+ a.4))
    d = d &+ (3 * a.7)
    q = d / 10
    d = d % 10
    _value |= d << 16

    d = q
    d = d &+ (8 * a.15)
    d = d &+ (9 * (a.14 &+ a.8))
    d = d &+ (3 * a.13)
    d = d &+ (7 * (a.12 &+ a.6))
    d = d &+ (6 * a.10)
    d = d &+ (4 * (a.9 &+ a.7))
    q = d / 10
    d = d % 10
    _value |= d << 20

    d = q
    d = d &+ (6 * (a.15 &+ a.12 &+ a.11 &+ a.6))
    d = d &+ (7 * (a.14 &+ a.13))
    d = d &+ a.10
    d = d &+ (9 * a.9)
    d = d &+ (4 * a.8)
    d = d &+ (8 * a.7)
    d = d &+ a.5
    q = d / 10
    d = d % 10
    _value |= d << 24

    d = q
    d = d &+ (3 * a.14)
    d = d &+ (2 * a.13)
    d = d &+ (7 * a.12)
    d = d &+ (8 * a.11)
    d = d &+ a.10
    d = d &+ a.9
    d = d &+ (9 * a.8)
    d = d &+ (6 * a.7)
    d = d &+ a.6
    q = d / 10
    d = d % 10
    _value |= d << 28

    d = q
    d = d &+ (6 * (a.15 &+ a.13))
    d = d &+ (9 * a.12)
    d = d &+ a.11
    d = d &+ (5 * a.10)
    d = d &+ (7 * a.9)
    d = d &+ (2 * (a.8 &+ a.7))
    q = d / 10
    d = d % 10
    _value |= d << 32

    d = q
    d = d &+ (4 * (a.15 &+ a.14 &+ a.12 &+ a.8))
    d = d &+ (9 * (a.13 &+ a.10))
    d = d &+ (2 * a.11)
    d = d &+ (8 * a.9)
    q = d / 10
    d = d % 10
    _value |= d << 36

    d = q
    d = d &+ (9 * (a.14 &+ a.13 &+ a.11 &+ a.10))
    d = d &+ (7 * a.12)
    d = d &+ (6 * a.9)
    q = d / 10
    d = d % 10
    _value |= d << 40

    d = q
    d = d &+ (5 * (a.15 &+ a.14 &+ a.13 &+ a.11))
    d = d &+ (4 * a.12)
    q = d / 10
    d = d % 10
    _value |= d << 44

    d = q
    d = d &+ a.15
    d = d &+ (7 * (a.14 &+ a.11))
    d = d &+ (3 * a.13)
    d = d &+ a.12
    d = d &+ a.10
    q = d / 10
    d = d % 10
    _value |= d << 48

    d = q
    d = d &+ (2 * a.15)
    d = d &+ (5 * a.14)
    d = d &+ (8 * a.12)
    d = d &+ a.11
    q = d / 10
    d = d % 10
    _value |= d << 52

    d = q
    d = d &+ (9 * a.15)
    d = d &+ (5 * a.13)
    d = d &+ (2 * a.12)
    q = d / 10
    d = d % 10
    _value |= d << 56

    d = q
    d = d &+ (2 * (a.15 &+ a.14))
    d = d &+ (4 * a.13)

    _value |= d << 60
  }

  public var description: String { return _describe(self) }

  public func addingWithOverflow(_ rhs: BCD64) -> (partialValue: BCD64, overflow: ArithmeticOverflow) {
    return _addingWithOverflow(rhs, adjustMSB: true)
  }

  public func dividedWithOverflow(by rhs: BCD64) -> (partialValue: BCD64, overflow: ArithmeticOverflow) {
    return _dividedWithOverflow(by: rhs)
  }

  public func multipliedWithOverflow(by rhs: BCD64) -> (partialValue: BCD64, overflow: ArithmeticOverflow) {
    return _multipliedWithOverflow(by: rhs)
  }

  public func subtractingWithOverflow(_ rhs: BCD64) -> (partialValue: BCD64, overflow: ArithmeticOverflow) {
    return _subtractingWithOverflow(rhs)
  }

  public func bitwiseOr(_ rhs: BCD64) -> BCD64 { return _bitwiseOr(rhs) }

  public func bitwiseAnd(_ rhs: BCD64) -> BCD64 { return _bitwiseAnd(rhs) }

  public func bitwiseXor(_ rhs: BCD64) -> BCD64 { return _bitwiseXor(rhs) }

  public func maskingShiftLeft(_ rhs: BCD64) -> BCD64 { return _maskingShiftLeft(Base(rhs)) }
  public func maskingShiftRight(_ rhs: BCD64) -> BCD64 { return _maskingShiftRight(Base(rhs)) }

  public static func doubleWidthMultiply(_ lhs: BCD64, _ rhs: BCD64) -> (high: BCD64, low: BCD64) {
    return _doubleWidthMultiply(lhs, rhs)
  }

  public var leadingZeros: Int { return _leadingZeros }
  public var popcount: Int { return _popcount }

}

extension BCD64: ExpressibleByIntegerLiteral { public init(integerLiteral value: Base) { self = BCD64(value) } }

extension BCD64 {
  public static prefix func ~ (value: BCD64) -> BCD64 {
    let t1 = 0xF999999999999999 - value._value
    let t2 = t1 + 0x0666666666666666
    let t3 = Base.addWithOverflow(t2, 0x01).0
    let t4 = t2 ^ 0x0000000000000001
    let t5 = t3 ^ t4
    let t6 = ~t5 & 0x1111111111111110
    let t7 = (t6 >> 2) | (t6 >> 3)
    let bitPattern = t3 - t7
    return BCD64(bitPattern: bitPattern)
  }
}

extension UInt64 {
  public init(_ value: BCD64) {
    var result: UInt64 = 0
    var multiplier = UInt64(1)
    var shift = UInt64(0)
    repeat {
      result = result &+ ((value._value >> shift) & 0xF) * multiplier
      shift = shift &+ 4
      multiplier *= 10
    } while shift < 64
    self = result
  }
}

