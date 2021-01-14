//
//  Numbers.swift
//  MoonKit
//
//  Created by Jason Cardwell on 12/29/20.
//  Copyright © 2020 Moondeer Studios. All rights reserved.
//
import Foundation
import CoreGraphics

public protocol BinaryNumeric {
  associatedtype Magnitude: Comparable, Numeric
  var magnitude: Magnitude { get }
  static func / (lhs: Self, rhs: Self) -> Self
  static func /= (lhs: inout Self, rhs: Self)
  static func + (lhs: Self, rhs: Self) -> Self
  static func += (lhs: inout Self, rhs: Self)
  static func - (lhs: Self, rhs: Self) -> Self
  static func -= (lhs: inout Self, rhs: Self)
  static func * (lhs: Self, rhs: Self) -> Self
  static func *= (lhs: inout Self, rhs: Self)
}

public protocol BinarySignedNumeric: SignedNumeric, BinaryNumeric {
  prefix static func - (operand: Self) -> Self
}

extension Int: BinarySignedNumeric {}
extension Int8: BinarySignedNumeric {}
extension Int16: BinarySignedNumeric {}
extension Int32: BinarySignedNumeric {}
extension Int64: BinarySignedNumeric {}
extension UInt: BinaryNumeric {}
extension UInt8: BinaryNumeric {}
extension UInt16: BinaryNumeric {}
extension UInt32: BinaryNumeric {}
extension UInt64: BinaryNumeric {}
extension Float: BinarySignedNumeric {}
extension Double: BinarySignedNumeric {}
extension CGFloat: BinarySignedNumeric {}
