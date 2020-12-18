//
//  Ratio.swift
//  MoonKit
//
//  Created by Jason Cardwell on 8/22/15.
//  Copyright © 2015 Jason Cardwell. All rights reserved.
//

import Foundation

public func ∶<I:SignedInteger>(lhs: I, rhs: I) -> Ratio { return Ratio(lhs╱rhs) }
public struct Ratio {

//  public static func ∶<I:UnsignedInteger>(lhs: I, rhs: I) -> Ratio { return Ratio(lhs╱rhs) }

//  public fileprivate(set) var fraction: Fraction = 1╱1
  public var numerator: UInt128 { get { return fraction.numerator } /*set { fraction.numerator = newValue }*/ }
  public var denominator: UInt128 { get { return fraction.denominator } /*set { fraction.denominator = newValue }*/ }

  public init(_ f: Fraction) { fraction = f }

  public static func -=(lhs: inout Ratio, rhs: Ratio) { lhs = lhs - rhs }
  public static func +=(lhs: inout Ratio, rhs: Ratio) { lhs = lhs + rhs }
  public static func *=(lhs: inout Ratio, rhs: Ratio) { lhs = lhs * rhs }
  public static func /=(lhs: inout Ratio, rhs: Ratio) { lhs = lhs / rhs }

  public static prefix func -(x: Ratio) -> Ratio { return Ratio(-x.fraction) }
  public static func -(lhs: Ratio, rhs: Ratio) -> Ratio { return Ratio(lhs.fraction - rhs.fraction) }
  public static func +(lhs: Ratio, rhs: Ratio) -> Ratio { return Ratio(lhs.fraction + rhs.fraction) }
  public static func *(lhs: Ratio, rhs: Ratio) -> Ratio { return Ratio(lhs.fraction * rhs.fraction) }
  public static func /(lhs: Ratio, rhs: Ratio) -> Ratio { return Ratio(lhs.fraction / rhs.fraction) }
}

// MARK: - CustomStringConvertible
extension Ratio: CustomStringConvertible {
  public var description: String { return "\(numerator):\(denominator)" }
}

// MARK: - Comparable, Equatable
extension Ratio: Comparable, Equatable {
  public static func <(lhs: Ratio, rhs: Ratio) -> Bool { return lhs.fraction < rhs.fraction }
  public static func ==(lhs: Ratio, rhs: Ratio) -> Bool { return lhs.fraction == rhs.fraction }
}

// MARK: - Hashable
extension Ratio: Hashable {
  public var hashValue: Int { return fraction.hashValue }
}

extension Ratio {
  public static var infinity: Ratio { return Ratio(Fraction.infinity) }
  public static var nan: Ratio { return Ratio(Fraction.nan) }
}
