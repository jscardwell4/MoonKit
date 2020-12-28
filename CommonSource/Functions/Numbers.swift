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

public func encodeDeclet(_ x: UInt8, _ y: UInt8, _ z: UInt8) -> UInt16 {

  let a = UInt16((x & 0b1000) >> 3)
  let b = UInt16((x & 0b100) >> 2)
  let c = UInt16((x & 0b10) >> 1)
  let d = UInt16(x & 0b1)

  let e = UInt16((y & 0b1000) >> 3)
  let f = UInt16((y & 0b100) >> 2)
  let g = UInt16((y & 0b10) >> 1)
  let h = UInt16(y & 0b1)

  let i = UInt16((z & 0b1000) >> 3)
  let j = UInt16((z & 0b100) >> 2)
  let k = UInt16((z & 0b10) >> 1)
  let m = UInt16(z & 0b1)

  switch (a, e, i) {

  case (0, 0, 0):
    let first = b << 9 | c << 8 | d << 7 | f << 6
    let second = g << 5 | h << 4 | j << 2
    let third =  k << 1 | m
    return first | second | third

  case (0, 0, 1):
    let first = b << 9 | c << 8
    let second = d << 7 | f << 6 | g << 5
    let third = h << 4 | 0b1000 | m
    return first | second | third

  case (0, 1, 0):
    let first = b << 9 | c << 8 | d << 7
    let second = j << 6 | k << 5
    let third = h << 4 | 0b1010 | m
    return first | second | third

  case (1, 0, 0):
    let first = j << 9 | k << 8 | d << 7
    let second = f << 6 | g << 5
    let third = h << 4 | 0b1100 | m
    return first | second | third

  case (1, 1, 0):
    let first = j << 9 | k << 8
    let second = d << 7 | h << 4
    let third = 0b1110 | m
    return first | second | third

  case (1, 0, 1):
    let first = f << 9 | g << 8
    let second = d << 7 | 0b10_1110
    let third = h << 4 | m
    return first | second | third

  case (0, 1, 1):
    let first = b << 9 | c << 8
    let second = d << 7 | 0b100_1110
    let third = h << 4 | m
    return first | second | third

  case (1, 1, 1):
    let first = d << 7 | 0b110_1110
    let second = h << 4 | m
    return first | second

  default: fatalError("The impossible happened")

  }

}

public func decodeDeclet(_ bitPattern: UInt16) -> (UInt8, UInt8, UInt8) {

  let p = UInt8((bitPattern & 0b1000000000) >> 9)
  let q = UInt8((bitPattern & 0b100000000) >> 8)
  let r = UInt8((bitPattern & 0b10000000) >> 7)
  let s = UInt8((bitPattern & 0b1000000) >> 6)
  let t = UInt8((bitPattern & 0b100000) >> 5)
  let u = UInt8((bitPattern & 0b10000) >> 4)
  let v = UInt8((bitPattern & 0b1000) >> 3)
  let w = UInt8((bitPattern & 0b100) >> 2)
  let x = UInt8((bitPattern & 0b10) >> 1)
  let y = UInt8((bitPattern & 0b1) >> 0)

  switch (v, w, x, s, t) {

  case (0, _, _, _, _):
    return (UInt8(p << 2 | q << 1 | r), UInt8(s << 2 | t << 1 | u), UInt8(w << 2 | x << 1 | y))

  case (1, 0, 0, _, _):
    return (UInt8(p << 2 | q << 1 | r), UInt8(s << 2 | t << 1 | u), UInt8(0b1000 | y))

  case (1, 0, 1, _, _):
    return (UInt8(p << 2 | q << 1 | r), UInt8(0b1000 | u), UInt8(s << 2 | t << 1 | y))

  case (1, 1, 0, _, _):
    return (UInt8(0b1000 | r), UInt8(s << 2 | t << 1 | u), UInt8(p << 2 | q << 1 | y))

  case (1, 1, 1, 0, 0):
    return (UInt8(0b1000 | r), UInt8(0b1000 | u), UInt8(p << 2 | q << 1 | y))

  case (1, 1, 1, 0, 1):
    return (UInt8(0b1000 | r), UInt8(p << 2 | q << 1 | u), UInt8(0b1000 | y))

  case (1, 1, 1, 1, 0):
    return (UInt8(p << 2 | q << 1 | r), UInt8(0b1000 | u), UInt8(0b1000 | y))

  case (1, 1, 1, 1, 1):
    return (UInt8(0b1000 | r), UInt8(0b1000 | u), UInt8(0b1000 | y))
    
  default:
    fatalError("The impossible happened")
    
  }
  
}

public func countOnes(_ value: UInt8) -> Int {
  var result = value
  result = ((result >>  1) & 0x55) + (result & 0x55)
  result = ((result >>  2) & 0x33) + (result & 0x33)
  result = ((result >>  4)       ) + (result & 0x07)
  return Int(result)
}

public func countOnes(_ value: UInt16) -> Int {
  var result = value
  result = ((result >>  1) & 0x5555) + (result & 0x5555)
  result = ((result >>  2) & 0x3333) + (result & 0x3333)
  result = ((result >>  4) & 0x0707) + (result & 0x0707)
  result = ((result >>  8)         ) + (result & 0x000F)
  return Int(result)
}

public func countOnes(_ value: UInt32) -> Int {
  var result = value
  result = ((result >>  1) & 0x55555555) + (result & 0x55555555)
  result = ((result >>  2) & 0x33333333) + (result & 0x33333333)
  result = ((result >>  4) & 0x07070707) + (result & 0x07070707)
  result = ((result >>  8) & 0x000F000F) + (result & 0x000F000F)
  result = ((result >> 16)             ) + (result & 0x0000001F)
  return Int(result)
}

public func countOnes(_ value: UInt64) -> Int {
  var result = value
  result = ((result >>  1) & 0x5555555555555555) + (result & 0x5555555555555555)
  result = ((result >>  2) & 0x3333333333333333) + (result & 0x3333333333333333)
  result = ((result >>  4) & 0x0707070707070707) + (result & 0x0707070707070707)
  result = ((result >>  8) & 0x000F000F000F000F) + (result & 0x000F000F000F000F)
  result = ((result >> 16) & 0x0000001F0000001F) + (result & 0x0000001F0000001F)
  result = ((result >> 32)                     ) + (result & 0x00000000000000FF)
  return Int(result)
}

public func countLeadingZeros(_ value: UInt8) -> Int {
  var result = value
    result |= (result >> 1)
    result |= (result >> 2)
    result |= (result >> 4)
  return countOnes(~result)
}

public func countLeadingZeros(_ value: UInt16) -> Int {
  var result = value
    result |= (result >> 1)
    result |= (result >> 2)
    result |= (result >> 4)
    result |= (result >> 8)
  return countOnes(~result)
}

public func countLeadingZeros(_ value: UInt32) -> Int {
  var result = value
  result |= (result >> 1)
  result |= (result >> 2)
  result |= (result >> 4)
  result |= (result >> 8)
  result |= (result >> 16)
  return countOnes(~result)
}

public func countLeadingZeros(_ value: UInt64) -> Int {
  var result = value
  result |= (result >> 1)
  result |= (result >> 2)
  result |= (result >> 4)
  result |= (result >> 8)
  result |= (result >> 16)
  result |= (result >> 32)
  return countOnes(~result)
}

public func countLeadingZeros(_ value: UInt) -> Int {
  return MemoryLayout<UInt>.size == MemoryLayout<UInt32>.size
           ? countLeadingZeros(UInt32(value))
           : countLeadingZeros(UInt64(value))
}

public func countLeadingZeros(_ value: Int) -> Int {
  return countLeadingZeros(UInt(bitPattern: value))
}
public func countLeadingZeros(_ value: Int8) -> Int {
  return countLeadingZeros(UInt8(bitPattern: value))
}
public func countLeadingZeros(_ value: Int16) -> Int {
  return countLeadingZeros(UInt16(bitPattern: value))
}
public func countLeadingZeros(_ value: Int32) -> Int {
  return countLeadingZeros(UInt32(bitPattern: value))
}
public func countLeadingZeros(_ value: Int64) -> Int {
  return countLeadingZeros(UInt64(bitPattern: value))
}

/// Returns the next power of 2 that is equal to or greater than `x`
public func round2(_ x: Int) -> Int {
  return Int(_exp2(ceil(_log2(Double(max(0, x))))))
}

public func integerize(_ value: Double) -> (Double, Int) {
  var valueʹ = value, i = 0
  while i < 16 && valueʹ - valueʹ.rounded() != 0 {
    valueʹ *= 10.0
    i += 1
  }
  return (valueʹ, i)
}

public func digits(_ value: Double) -> (digits: [UInt8], radical: Int) {
  let (valueʹ, radical) = integerize(value)
  let result = digits(UInt64(valueʹ))
  return (result, result.count &- radical)
}

public func reversedDigits(_ value: Double) -> (digits: [UInt8], radical: Int) {
  let (valueʹ, radical) = integerize(value)
  let result = reversedDigits(UInt64(valueʹ))
  return (result, result.count &- radical)
}

public func digits(_ value: UInt64) -> [UInt8] {
  var result = reversedDigits(value)
  var l = 0, r = result.count &- 1
  while l < r {
    result.swapAt(l, r)
    l += 1
    r -= 1
  }
  return result
}

public func reversedDigits(_ value: UInt64) -> [UInt8] {
  var result: [UInt8] = []
  var x = value
  repeat {
    let r = UInt8(x % 10)
    x /= 10
    result.append(r)
  } while x > 0
  return result
}

extension FixedWidthInteger {

  public func digits(base: Self) -> [Self] {

    var stack = Stack<Self>(minimumCapacity: 4)

    var remainingValue = self

    repeat {

      stack.push(remainingValue.remainderReportingOverflow(dividingBy: base).partialValue)
      remainingValue = remainingValue.dividedReportingOverflow(by: base).partialValue

    } while remainingValue > 0

    return Array(stack)

  }

}

//extension SignedInteger {
//
//  public func digits(base: Self) -> [Self] {
//
//    let base = abs(base)
//
//    var stack = Stack<Self>(minimumCapacity: 4)
//
//    var remainingValue = abs(self)
//
//    repeat {
//
//      stack.push(remainingValue.remainderReportingOverflow(dividingBy: base).partialValue)
//      remainingValue = remainingValue.dividedReportingOverflow(by: base).partialValue
//
//    } while remainingValue > 0
//
//    return Array(stack)
//
//  }
//
//}

extension UInt {

  public var digits: [UInt] {

    var stack = Stack<UInt>(minimumCapacity: 4)

    var remainingValue = self

    repeat {

      stack.push(remainingValue % 10)
      remainingValue /= 10

    } while remainingValue > 0


    return Array(stack)

  }

}

extension UInt8 {

  public var digits: [UInt8] {

    var stack = Stack<UInt8>(minimumCapacity: 4)

    var remainingValue = self

    repeat {

      stack.push(remainingValue % 10)
      remainingValue /= 10

    } while remainingValue > 0


    return Array(stack)

  }

}

extension UInt16 {

  public var digits: [UInt16] {

    var stack = Stack<UInt16>(minimumCapacity: 4)

    var remainingValue = self

    repeat {

      stack.push(remainingValue % 10)
      remainingValue /= 10

    } while remainingValue > 0


    return Array(stack)

  }

}

extension UInt32 {

  public var digits: [UInt32] {

    var stack = Stack<UInt32>(minimumCapacity: 4)

    var remainingValue = self

    repeat {

      stack.push(remainingValue % 10)
      remainingValue /= 10

    } while remainingValue > 0


    return Array(stack)

  }

}

extension UInt64 {

  public var digits: [UInt64] {

    var stack = Stack<UInt64>(minimumCapacity: 4)

    var remainingValue = self

    repeat {
      
      stack.push(remainingValue % 10)
      remainingValue /= 10
      
    } while remainingValue > 0
    
    
    return Array(stack)
    
  }
  
}

extension Int {

  public var digits: [Int] {

    var stack = Stack<Int>(minimumCapacity: 4)

    var remainingValue = abs(self)

    repeat {

      stack.push(remainingValue % 10)
      remainingValue /= 10

    } while remainingValue > 0


    return Array(stack)

  }

}

extension Int8 {

  public var digits: [Int8] {

    var stack = Stack<Int8>(minimumCapacity: 4)

    var remainingValue = abs(self)

    repeat {

      stack.push(remainingValue % 10)
      remainingValue /= 10

    } while remainingValue > 0


    return Array(stack)
    
  }
  
}

extension Int16 {

  public var digits: [Int16] {

    var stack = Stack<Int16>(minimumCapacity: 4)

    var remainingValue = abs(self)

    repeat {

      stack.push(remainingValue % 10)
      remainingValue /= 10

    } while remainingValue > 0


    return Array(stack)
    
  }
  
}

extension Int32 {

  public var digits: [Int32] {

    var stack = Stack<Int32>(minimumCapacity: 4)

    var remainingValue = abs(self)

    repeat {

      stack.push(remainingValue % 10)
      remainingValue /= 10

    } while remainingValue > 0


    return Array(stack)
    
  }
  
}

extension Int64 {

  public var digits: [Int64] {

    var stack = Stack<Int64>(minimumCapacity: 4)

    var remainingValue = abs(self)

    repeat {

      stack.push(remainingValue % 10)
      remainingValue /= 10

    } while remainingValue > 0


    return Array(stack)
    
  }
  
}

extension Double {
  public func digits() -> [UInt8] {
    guard !(isNaN || isInfinite) else { return [] }

    let value = abs(self)

    var integer = value.rounded(.towardZero)
    var fractional = value - integer

    var integerDigits: Stack<UInt8> = []

    while integer > 0 {
      integerDigits.push(UInt8(integer.remainder(dividingBy: 10)))
      integer /= 10
    }

    var fractionalDigits: [UInt8] = []

    while fractional > 0 {
      fractional *= 10
      let digit = fractional.truncatingRemainder(dividingBy: 10).rounded(.towardZero)
      fractionalDigits.append(UInt8(digit))
      fractional -= digit
    }

    return Array(integerDigits) + fractionalDigits
  }
}

extension Decimal {

  public func digits() -> [UInt8] {
    guard !(isNaN || isInfinite) else { return [] }
    let value = abs(self)
    let decimalHandler = NSDecimalNumberHandler(roundingMode: .down,
                                                scale: 0,
                                                raiseOnExactness: false,
                                                raiseOnOverflow: false,
                                                raiseOnUnderflow: false,
                                                raiseOnDivideByZero: false)
    var integer = (value as NSDecimalNumber).rounding(accordingToBehavior: decimalHandler).decimalValue
    var fractional = value - integer

    var integerDigits: Stack<UInt8> = []
    while integer >= 1 {
      let integerʹ = ((integer / 10) as NSDecimalNumber).rounding(accordingToBehavior: decimalHandler).decimalValue
      let digit = integer - integerʹ
      integerDigits.push(UInt8((digit as NSDecimalNumber).doubleValue))
      integer = integerʹ
    }

    var fractionalDigits: [UInt8] = []
    while fractional > 0 {
      let fractionalʹ = fractional * 10
      let digit = (fractionalʹ as NSDecimalNumber).rounding(accordingToBehavior: decimalHandler).decimalValue
      fractionalDigits.append(UInt8((digit as NSDecimalNumber).doubleValue))
      fractional = fractionalʹ - digit
    }

    return Array(integerDigits) + fractionalDigits
  }
}

extension FloatingPoint {

  public var parts: (whole: Self, fractional: Self) {
    let whole = rounded(.towardZero)
    let fractional = self - whole
    return (whole: whole, fractional: fractional)
  }

}

extension Float: Additive, Subtractive, Multiplicative, Divisive {}
extension Double: Additive, Subtractive, Multiplicative, Divisive {}
extension CGFloat: Additive, Subtractive, Multiplicative, Divisive {}
extension Int: Additive, Subtractive, Multiplicative, Divisive, BitShifting {}
extension Int8: Additive, Subtractive, Multiplicative, Divisive, BitShifting {}
extension Int16: Additive, Subtractive, Multiplicative, Divisive, BitShifting {}
extension Int32: Additive, Subtractive, Multiplicative, Divisive, BitShifting {}
extension Int64: Additive, Subtractive, Multiplicative, Divisive, BitShifting {}
extension UInt: Additive, Subtractive, Multiplicative, Divisive, BitShifting {}
extension UInt8: Additive, Subtractive, Multiplicative, Divisive, BitShifting {}
extension UInt16: Additive, Subtractive, Multiplicative, Divisive, BitShifting {}
extension UInt32: Additive, Subtractive, Multiplicative, Divisive, BitShifting {}
extension UInt64: Additive, Subtractive, Multiplicative, Divisive, BitShifting {}


extension UInt8: PrettyPrint { public var prettyDescription: String { return description } }
extension Int8: PrettyPrint { public var prettyDescription: String { return description } }
extension UInt16: PrettyPrint { public var prettyDescription: String { return description } }
extension Int16: PrettyPrint { public var prettyDescription: String { return description } }
extension UInt32: PrettyPrint { public var prettyDescription: String { return description } }
extension Int32: PrettyPrint { public var prettyDescription: String { return description } }
extension UInt64: PrettyPrint { public var prettyDescription: String { return description } }
extension Int64: PrettyPrint { public var prettyDescription: String { return description } }
extension UInt: PrettyPrint { public var prettyDescription: String { return description } }
extension Int: PrettyPrint { public var prettyDescription: String { return description } }
extension Float: PrettyPrint { public var prettyDescription: String { return description } }
extension Double: PrettyPrint { public var prettyDescription: String { return description } }
extension CGFloat: PrettyPrint { public var prettyDescription: String { return description } }


public extension SignedInteger {
  var isNegative: Bool { return self < 0 }
}

public protocol NumberType {}

public let πd = Double.pi
public let twoπd = πd * 2.0
public let halfπd = πd * 0.5

public let π = Float.pi
public let twoπ = π * 2.0
public let halfπ = π * 0.5
public let quarterπ = π * 0.25

//public func **<T:Integer>(lhs: T, rhs: T) -> T { return pow(lhs, rhs) }
//public func copysign<

//public extension SignedNumberType {
//  public var isSignMinus: Bool {
//    return
//  }
//}

public protocol IntegerConvertible {
  init(_ value: UInt8)
  init(_ value: Int8)
  init(_ value: UInt16)
  init(_ value: Int16)
  init(_ value: UInt32)
  init(_ value: Int32)
  init(_ value: UInt64)
  init(_ value: Int64)
  init(_ value: UInt)
  init(_ value: Int)
//  init(_ value: _IntegerProducibleType)
}

public extension IntegerConvertible {
//  init(_ value: _IntegerProducibleType) {
//    switch value {
//      case let v as UInt8: self.init(v)
//      case let v as UInt16: self.init(v)
//      case let v as UInt32: self.init(v)
//      case let v as UInt64: self.init(v)
//      case let v as Int8: self.init(v)
//      case let v as Int16: self.init(v)
//      case let v as Int32: self.init(v)
//      case let v as Int64: self.init(v)
//      default: logw("unknown '_IntegerProdocibleType"); self.init(0)
//    }
//  }
}

public protocol IntegerProducible {
  func toUInt8() -> UInt8
  func toInt8() -> Int8
  func toUInt16() -> UInt16
  func toInt16() -> Int16
  func toUInt32() -> UInt32
  func toInt32() -> Int32
  func toUInt64() -> UInt64
  func toInt64() -> Int64
  func toUInt() -> UInt
  func toInt() -> Int
}

//public protocol _IntegerProducibleType: FloatConvertible {}
//extension UInt8: _IntegerProducibleType {}
//extension Int8: _IntegerProducibleType {}
//extension UInt16: _IntegerProducibleType {}
//extension Int16: _IntegerProducibleType {}
//extension UInt32: _IntegerProducibleType {}
//extension Int32: _IntegerProducibleType {}
//extension UInt64: _IntegerProducibleType {}
//extension Int64: _IntegerProducibleType {}
//extension UInt: _IntegerProducibleType {}
//extension Int: _IntegerProducibleType {}
//
//extension UInt8: IntegerConvertible {}
//extension Int8: IntegerConvertible {}
//extension UInt16: IntegerConvertible {}
//extension Int16: IntegerConvertible {}
//extension UInt32: IntegerConvertible {}
//extension Int32: IntegerConvertible {}
//extension UInt64: IntegerConvertible {}
//extension Int64: IntegerConvertible {}
//extension UInt: IntegerConvertible {}
//extension Int: IntegerConvertible {}
//extension Float: IntegerConvertible {}
//extension Double: IntegerConvertible {}
//extension CGFloat: IntegerConvertible {}
//
//extension IntegerProducible where Self:_IntegerProducibleType {
//  public func toUInt8() -> UInt8 { return UInt8(self) }
//  public func toInt8() -> Int8 { return Int8(self) }
//  public func toUInt16() -> UInt16 { return UInt16(self) }
//  public func toInt16() -> Int16 { return Int16(self) }
//  public func toUInt32() -> UInt32 { return UInt32(self) }
//  public func toInt32() -> Int32 { return Int32(self) }
//  public func toUInt64() -> UInt64 { return UInt64(self) }
//  public func toInt64() -> Int64 { return Int64(self) }
//  public func toUInt() -> UInt { return UInt(self) }
//  public func toInt() -> Int { return Int(self) }
//
//}
//
//extension UInt8: IntegerProducible {}
//extension Int8: IntegerProducible {}
//extension UInt16: IntegerProducible {}
//extension Int16: IntegerProducible {}
//extension UInt32: IntegerProducible {}
//extension Int32: IntegerProducible {}
//extension UInt64: IntegerProducible {}
//extension Int64: IntegerProducible {}
//extension UInt: IntegerProducible {}
//extension Int: IntegerProducible {}
//extension Float: IntegerProducible {}
//extension Double: IntegerProducible {}
//extension CGFloat: IntegerProducible {}

public protocol FloatConvertible {
  init(_ value: Float)
  init(_ value: Double)
  init(_ value: CGFloat)
  init(_ value: _FloatProducibleType)
}
public protocol _FloatProducibleType { init() }
public protocol FloatProducible {
  func toFloat() -> Float
  func toDouble() -> Double
  func toCGFloat() -> CGFloat
}
extension Float: _FloatProducibleType {}
extension Double: _FloatProducibleType {}
extension CGFloat: _FloatProducibleType {}

public extension FloatConvertible { //where Self:_FloatProducibleType {
  init(_ value: _FloatProducibleType) {
    switch value {
      case let v as Float: self.init(v)
      case let v as Double: self.init(v)
      case let v as CGFloat: self.init(v)
      default:
        logw("unknown '_FloatProducibleType")
        self.init(0.0)
    }
  }
}

extension Float: FloatConvertible {}
extension Double: FloatConvertible {}
extension CGFloat: FloatConvertible {
  public init(_ value: CGFloat) { self = value }
}

extension UInt8: FloatConvertible {}
extension Int8: FloatConvertible {}
extension UInt16: FloatConvertible {}
extension Int16: FloatConvertible {}
extension UInt32: FloatConvertible {}
extension Int32: FloatConvertible {}
extension UInt64: FloatConvertible {}
extension Int64: FloatConvertible {}

public extension IntegerProducible where Self:_FloatProducibleType {
  func toUInt8() -> UInt8 { return UInt8(self) }
  func toInt8() -> Int8 { return Int8(self) }
  func toUInt16() -> UInt16 { return UInt16(self) }
  func toInt16() -> Int16 { return Int16(self) }
  func toUInt32() -> UInt32 { return UInt32(self) }
  func toInt32() -> Int32 { return Int32(self) }
  func toUInt64() -> UInt64 { return UInt64(self) }
  func toInt64() -> Int64 { return Int64(self) }
//  func toUInt() -> UInt { return UInt(self) }
//  func toInt() -> Int { return Int(self) }
}

//extension Float: ArithmeticType {
//  public func toIntMax() -> IntMax { return IntMax(self) }
//  public init(intMax: IntMax) { self = Float(intMax) }
//}
//extension Double: ArithmeticType {
//  public func toIntMax() -> IntMax { return IntMax(self) }
//  public init(intMax: IntMax) { self = Double(intMax) }
//}
//extension CGFloat: ArithmeticType {
//  public func toIntMax() -> IntMax { return IntMax(self) }
//  public init(intMax: IntMax) { self = CGFloat(intMax) }
//}
//extension Int: ArithmeticType {
//  public init(intMax: IntMax) { self = Int(intMax) }
//}
//extension UInt: ArithmeticType {
//  public init(intMax: IntMax) { self = UInt(intMax) }
//}
//extension Int8: ArithmeticType {
//  public init(intMax: IntMax) { self = Int8(intMax) }
//}
//extension UInt8: ArithmeticType {
//  public init(intMax: IntMax) { self = UInt8(intMax) }
//}
//extension Int16: ArithmeticType {
//  public init(intMax: IntMax) { self = Int16(intMax) }
//}
//extension UInt16: ArithmeticType {
//  public init(intMax: IntMax) { self = UInt16(intMax) }
//}
//extension Int32: ArithmeticType {
//  public init(intMax: IntMax) { self = Int32(intMax) }
//}
//extension UInt32: ArithmeticType {
//  public init(intMax: IntMax) { self = UInt32(intMax) }
//}
//extension Int64: ArithmeticType {
//  public init(intMax: IntMax) { self = Int64(intMax) }
//}
//extension UInt64: ArithmeticType {
//  public init(intMax: IntMax) { self = UInt64(intMax) }
//}

public protocol IntConvertible {
  var IntValue: Int { get }
  init(integerLiteral: Int)
}

extension Float: IntConvertible {
  public var IntValue: Int { return Int(self) }
  public init(integerLiteral: Int) { self.init(integerLiteral) }
}
extension CGFloat: IntConvertible {
  public var IntValue: Int { return Int(self) }
  public init(integerLiteral: Int) { self.init(integerLiteral) }
}
extension Double: IntConvertible {
  public var IntValue: Int { return Int(self) }
  public init(integerLiteral: Int) { self.init(integerLiteral) }
}
extension Int: IntConvertible {
  public var IntValue: Int { return self }
  public init(integerLiteral: Int) { self.init(integerLiteral) }
}
extension UInt: IntConvertible {
  public var IntValue: Int { return Int(self) }
  public init(integerLiteral: Int) { self.init(integerLiteral) }
}
extension Int8: IntConvertible {
  public var IntValue: Int { return Int(self) }
  public init(integerLiteral: Int) { self.init(integerLiteral) }
}
extension UInt8: IntConvertible {
  public var IntValue: Int { return Int(self) }
  public init(integerLiteral: Int) { self.init(integerLiteral) }
}
extension Int16: IntConvertible {
  public var IntValue: Int { return Int(self) }
  public init(integerLiteral: Int) { self.init(integerLiteral) }
}
extension UInt16: IntConvertible {
  public var IntValue: Int { return Int(self) }
  public init(integerLiteral: Int) { self.init(integerLiteral) }
}
extension Int32: IntConvertible {
  public var IntValue: Int { return Int(self) }
  public init(integerLiteral: Int) { self.init(integerLiteral) }
}
extension UInt32: IntConvertible {
  public var IntValue: Int { return Int(self) }
  public init(integerLiteral: Int) { self.init(integerLiteral) }
}
extension Int64: IntConvertible {
  public var IntValue: Int { return Int(self) }
  public init(integerLiteral: Int) { self.init(integerLiteral) }
}
extension UInt64: IntConvertible {
  public var IntValue: Int { return Int(self) }
  public init(integerLiteral: Int) { self.init(integerLiteral) }
}

public protocol DoubleConvertible {
  var DoubleValue: Double { get }
  init(doubleLiteral: Double)
}

extension Float: DoubleConvertible {
  public var DoubleValue: Double { return Double(self) }
  public init(doubleLiteral: Double) { self.init(doubleLiteral) }
}
extension CGFloat: DoubleConvertible {
  public var DoubleValue: Double { return Double(self) }
  public init(doubleLiteral: Double) { self.init(doubleLiteral) }
}
extension Double: DoubleConvertible {
  public var DoubleValue: Double { return Double(self) }
  public init(doubleLiteral: Double) { self.init(doubleLiteral) }
}
extension Int: DoubleConvertible {
  public var DoubleValue: Double { return Double(self) }
  public init(doubleLiteral: Double) { self.init(doubleLiteral) }
}
extension UInt: DoubleConvertible {
  public var DoubleValue: Double { return Double(self) }
  public init(doubleLiteral: Double) { self.init(doubleLiteral) }
}
extension Int8: DoubleConvertible {
  public var DoubleValue: Double { return Double(self) }
  public init(doubleLiteral: Double) { self.init(doubleLiteral) }
}
extension UInt8: DoubleConvertible {
  public var DoubleValue: Double { return Double(self) }
  public init(doubleLiteral: Double) { self.init(doubleLiteral) }
}
extension Int16: DoubleConvertible {
  public var DoubleValue: Double { return Double(self) }
  public init(doubleLiteral: Double) { self.init(doubleLiteral) }
}
extension UInt16: DoubleConvertible {
  public var DoubleValue: Double { return Double(self) }
  public init(doubleLiteral: Double) { self.init(doubleLiteral) }
}
extension Int32: DoubleConvertible {
  public var DoubleValue: Double { return Double(self) }
  public init(doubleLiteral: Double) { self.init(doubleLiteral) }
}
extension UInt32: DoubleConvertible {
  public var DoubleValue: Double { return Double(self) }
  public init(doubleLiteral: Double) { self.init(doubleLiteral) }
}
extension Int64: DoubleConvertible {
  public var DoubleValue: Double { return Double(self) }
  public init(doubleLiteral: Double) { self.init(doubleLiteral) }
}
extension UInt64: DoubleConvertible {
  public var DoubleValue: Double { return Double(self) }
  public init(doubleLiteral: Double) { self.init(doubleLiteral) }
}

public func numericCast<T:_FloatProducibleType, U:FloatConvertible>(_ x: T) -> U {
  return U(x)
}
//public func numericCast<T:FloatProducible>(x: T) -> Float { return x.toFloat() }
//public func numericCast<T:FloatProducible>(x: T) -> CGFloat { return x.toCGFloat() }

//public func +(lhs: CGFloat, rhs: CGFloatable) -> CGFloat { return lhs + rhs.CGFloatValue }
//public func -(lhs: CGFloat, rhs: CGFloatable) -> CGFloat { return lhs - rhs.CGFloatValue }
//
//public func +=(inout lhs: CGFloat, rhs: CGFloatable) {lhs += rhs }
//public func -=(inout lhs: CGFloat, rhs: CGFloatable) {lhs -= rhs }
//
//public func *(lhs: CGFloat, rhs: CGFloatable) -> CGFloat { return lhs * rhs.CGFloatValue }
//public func /(lhs: CGFloat, rhs: CGFloatable) -> CGFloat { return lhs / rhs.CGFloatValue }
//
//public func *=(inout lhs: CGFloat, rhs: CGFloatable) {lhs *= rhs }
//public func /=(inout lhs: CGFloat, rhs: CGFloatable) {lhs /= rhs }
//
//public func +(lhs: CGFloatable, rhs: CGFloat) -> CGFloat { return lhs.CGFloatValue + rhs }
//public func -(lhs: CGFloatable, rhs: CGFloat) -> CGFloat { return lhs.CGFloatValue - rhs }
//
//public func +=(inout lhs: CGFloatable, rhs: CGFloat) {lhs += rhs }
//public func -=(inout lhs: CGFloatable, rhs: CGFloat) {lhs -= rhs }
//
//public func *(lhs: CGFloatable, rhs: CGFloat) -> CGFloat { return lhs.CGFloatValue * rhs }
//public func /(lhs: CGFloatable, rhs: CGFloat) -> CGFloat { return lhs.CGFloatValue / rhs }
//
//public func *=(inout lhs: CGFloatable, rhs: CGFloat) {lhs *= rhs }
//public func /=(inout lhs: CGFloatable, rhs: CGFloat) {lhs /= rhs }

public func half(_ x: CGFloat) -> CGFloat { return x * 0.5                 }
public func half(_ x: Float)   -> Float   { return x * 0.5                 }
public func half(_ x: Double)  -> Double  { return x * 0.5                 }
public func half(_ x: Int)     -> Int     { return    Int(Double(x) * 0.5) }
public func half(_ x: Int8)    -> Int8    { return   Int8(Double(x) * 0.5) }
public func half(_ x: Int16)   -> Int16   { return  Int16(Double(x) * 0.5) }
public func half(_ x: Int32)   -> Int32   { return  Int32(Double(x) * 0.5) }
public func half(_ x: Int64)   -> Int64   { return  Int64(Double(x) * 0.5) }
public func half(_ x: UInt)    -> UInt    { return   UInt(Double(x) * 0.5) }
public func half(_ x: UInt8)   -> UInt8   { return  UInt8(Double(x) * 0.5) }
public func half(_ x: UInt16)  -> UInt16  { return UInt16(Double(x) * 0.5) }
public func half(_ x: UInt32)  -> UInt32  { return UInt32(Double(x) * 0.5) }
public func half(_ x: UInt64)  -> UInt64  { return UInt64(Double(x) * 0.5) }

public func modulo(_ x: Double, _ y: Double) -> (quotient: Double, remainder: Double) {
  let result = x / y, r = result - result.rounded(.towardZero), q = result - r
  return (quotient: q, remainder: r)
}

public protocol CGFloatable {
  var CGFloatValue: CGFloat { get }
}

extension CGFloat: CGFloatable { public var CGFloatValue: CGFloat { return self          } }
extension Float:   CGFloatable { public var CGFloatValue: CGFloat { return CGFloat(self) } }
extension Double:  CGFloatable { public var CGFloatValue: CGFloat { return CGFloat(self) } }
extension Int:     CGFloatable { public var CGFloatValue: CGFloat { return CGFloat(self) } }
extension Int8:    CGFloatable { public var CGFloatValue: CGFloat { return CGFloat(self) } }
extension Int16:   CGFloatable { public var CGFloatValue: CGFloat { return CGFloat(self) } }
extension Int32:   CGFloatable { public var CGFloatValue: CGFloat { return CGFloat(self) } }
extension Int64:   CGFloatable { public var CGFloatValue: CGFloat { return CGFloat(self) } }
extension UInt:    CGFloatable { public var CGFloatValue: CGFloat { return CGFloat(self) } }
extension UInt8:   CGFloatable { public var CGFloatValue: CGFloat { return CGFloat(self) } }
extension UInt16:  CGFloatable { public var CGFloatValue: CGFloat { return CGFloat(self) } }
extension UInt32:  CGFloatable { public var CGFloatValue: CGFloat { return CGFloat(self) } }
extension UInt64:  CGFloatable { public var CGFloatValue: CGFloat { return CGFloat(self) } }

public protocol Floatable {
  var FloatValue: Float { get }
}

extension CGFloat: Floatable { public var FloatValue: Float { return Float(self) } }
extension Float:   Floatable { public var FloatValue: Float { return self        } }
extension Double:  Floatable { public var FloatValue: Float { return Float(self) } }
extension Int:     Floatable { public var FloatValue: Float { return Float(self) } }
extension Int8:    Floatable { public var FloatValue: Float { return Float(self) } }
extension Int16:   Floatable { public var FloatValue: Float { return Float(self) } }
extension Int32:   Floatable { public var FloatValue: Float { return Float(self) } }
extension Int64:   Floatable { public var FloatValue: Float { return Float(self) } }
extension UInt:    Floatable { public var FloatValue: Float { return Float(self) } }
extension UInt8:   Floatable { public var FloatValue: Float { return Float(self) } }
extension UInt16:  Floatable { public var FloatValue: Float { return Float(self) } }
extension UInt32:  Floatable { public var FloatValue: Float { return Float(self) } }
extension UInt64:  Floatable { public var FloatValue: Float { return Float(self) } }

//public protocol FloatValueConvertible { var floatValue: Float { get }; init(_ floatValue: Float) }
//public protocol CGFloatValueConvertible { var cgfloatValue: CGFloat { get }; init(_ cgfloatValue: CGFloat) }
//public protocol DoubleValueConvertible { var doubleValue: Double { get }; init(_ doubleValue: Double) }
//
//extension Float: FloatValueConvertible { public var floatValue: Float { return self } }
//extension CGFloat: FloatValueConvertible { public var floatValue: Float { return Float(self) } }
//extension Double: FloatValueConvertible { public var floatValue: Float { return Float(self) } }
//extension IntMax: FloatValueConvertible { public var floatValue: Float { return Float(self) } }
//
//extension Float: CGFloatValueConvertible { public var cgfloatValue: CGFloat { return CGFloat(self) } }
//extension Double: CGFloatValueConvertible { public var cgfloatValue: CGFloat { return CGFloat(self) } }
//extension IntMax: CGFloatValueConvertible { public var cgfloatValue: CGFloat { return CGFloat(self) } }
//extension CGFloat: CGFloatValueConvertible {
//  public var cgfloatValue: CGFloat { return self }
//  public init(_ cgfloatValue: CGFloat) { self = cgfloatValue }
//}
//
//extension Float: DoubleValueConvertible { public var doubleValue: Double { return Double(self) } }
//extension CGFloat: DoubleValueConvertible { public var doubleValue: Double { return Double(self) } }
//extension IntMax: DoubleValueConvertible { public var doubleValue: Double { return Double(self) } }
//extension Double: DoubleValueConvertible { public var doubleValue: Double { return self } }
//
//
//public func numericCast<T:FloatValueConvertible>(x: T) -> Float {
//  return x.floatValue
//}
