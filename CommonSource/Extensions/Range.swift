//
//  Range.swift
//  MoonKit
//
//  Created by Jason Cardwell on 7/26/15.
//  Copyright © 2015 Jason Cardwell. All rights reserved.
//

import Foundation

/// Type to represent the range of anything less than a specified value.
public struct UnboundedLowerRange<Bound:Comparable>: Equatable {

  public let upperBound: Bound

  public func contains(_ element: Bound) -> Bool { return element < upperBound }

  public static func ==(lhs: UnboundedLowerRange, rhs: UnboundedLowerRange) -> Bool {
    return lhs.upperBound == rhs.upperBound
  }

  public static func ~=(lhs: UnboundedLowerRange, rhs: Bound) -> Bool {
    return lhs.contains(rhs)
  }

}

/// `UnboundedLowerRange` formation operator.
public prefix func <-- <Bound: Comparable>(lhs: Bound) -> UnboundedLowerRange<Bound> {
  return UnboundedLowerRange(upperBound: lhs)
}

public extension Collection {

  subscript(r: UnboundedLowerRange<Index>) -> SubSequence { return prefix(upTo: r.upperBound) }

}

/// Type to represent the range of anything less than or equal to a specified value.
public struct ClosedUnboundedLowerRange<Bound:Comparable>: Equatable {

  public let upperBound: Bound

  public func contains(_ element: Bound) -> Bool { return element <= upperBound }

  public static func ==(lhs: ClosedUnboundedLowerRange, rhs: ClosedUnboundedLowerRange) -> Bool {
    return lhs.upperBound == rhs.upperBound
  }

  public static func ~=(pattern: ClosedUnboundedLowerRange, value: Bound) -> Bool {
    return pattern.contains(value)
  }
  
}

/// `ClosedUnboundedLowerRange` formation operator.
public prefix func <-| <Bound: Comparable>(lhs: Bound) -> ClosedUnboundedLowerRange<Bound> {
  return ClosedUnboundedLowerRange(upperBound: lhs)
}

/// Type to represent the range of anything greater than a specified value.
public struct UnboundedUpperRange<Bound:Comparable>: Equatable {

  public let lowerBound: Bound

  public func contains(_ element: Bound) -> Bool { return element > lowerBound }

  public static func ==(lhs: UnboundedUpperRange, rhs: UnboundedUpperRange) -> Bool {
    return lhs.lowerBound == rhs.lowerBound
  }

  public static func ~=(pattern: UnboundedUpperRange, value: Bound) -> Bool {
    return pattern.contains(value)
  }

}

/// `UnboundedUpperRange` formation operator.
public postfix func --> <Bound:Comparable>(rhs: Bound) -> UnboundedUpperRange<Bound> {
  return UnboundedUpperRange(lowerBound: rhs)
}

/// Type to represent the range of anything greater than or equal to a specified value.
public struct ClosedUnboundedUpperRange<Bound:Comparable>: Equatable {
  public let lowerBound: Bound
  public func contains(_ element: Bound) -> Bool { return element >= lowerBound }

  public static func ==(lhs: ClosedUnboundedUpperRange, rhs: ClosedUnboundedUpperRange) -> Bool {
    return lhs.lowerBound == rhs.lowerBound
  }

  public static func ~=(pattern: ClosedUnboundedUpperRange, value: Bound) -> Bool {
    return pattern.contains(value)
  }

}

/// `ClosedUnboundedUpperRange` formation operator.
public postfix func |-> <Bound:Comparable>(rhs: Bound) -> ClosedUnboundedUpperRange<Bound> {
  return ClosedUnboundedUpperRange(lowerBound: rhs)
}

public extension Collection {

  subscript(r: ClosedUnboundedUpperRange<Index>) -> SubSequence { return suffix(from: r.lowerBound) }

}


/// Type for presenting the elements in a `ClosedRange` in reverse order.
public struct ReverseClosedRange<Bound: Comparable>: Equatable, CustomStringConvertible {

  let base: ClosedRange<Bound>

  public init(_ range: ReverseClosedRange<Bound>) { self = range }

  public init(_ start: Bound, _ end: Bound) { base = (end ... start) }

  public init(_ base: ClosedRange<Bound>) { self.base = base }

  public func contains(_ value: Bound) -> Bool { return base.contains(value) }

  public func clamp(_ intervalToClamp: ReverseClosedRange<Bound>) -> ReverseClosedRange<Bound> {
    return ReverseClosedRange<Bound>(intervalToClamp.base.clamped(to: base))
  }

  public var isEmpty: Bool { return base.isEmpty }

  public var lowerBound: Bound { return base.upperBound }

  public var upperBound: Bound { return base.lowerBound }

  public func clampValue(_ value: Bound) -> Bound {
    if contains(value) { return value }
    else if upperBound > value { return upperBound }
    else { return lowerBound }
  }

  public var description: String { return "\(lowerBound)...\(upperBound)" }

  public static func ==(lhs: ReverseClosedRange, rhs: ReverseClosedRange) -> Bool {
    return lhs.lowerBound == rhs.lowerBound && lhs.upperBound == rhs.upperBound
  }

}


extension ReverseClosedRange where Bound:BinarySignedNumeric, Bound.Magnitude == Bound {

  public var diameter: Bound { return abs(lowerBound - upperBound) }

  public func normalizeValue(_ value: Bound) -> Bound { return 1 - base.normalizeValue(value) as! Int as! Bound }

  public func valueForNormalizedValue(_ normalizedValue: Bound) -> Bound {
    guard normalizedValue >= 0 && normalizedValue <= 1 else {
      logw("normalized value must be in 0 ... 1")
      return normalizedValue
    }
    var value = diameter - diameter * normalizedValue
    if upperBound < 0 { value -= abs(upperBound) }
    else if upperBound > 0 { value += upperBound }

    return clampValue(value)
  }

  public func mapValue(_ value: Bound, from interval: ReverseClosedRange<Bound>) -> Bound {
    guard self != interval && !(isEmpty || interval.isEmpty) else { return clampValue(value) }
    return valueForNormalizedValue(interval.normalizeValue(value))
  }

  public var median: Bound { return (diameter / 2) + upperBound }

}

// MARK: - Additions to Range

public extension Range {

  static func ~=(lhs: Range, rhs: Bound?) -> Bool {
    guard let rhs = rhs else { return false }
    return lhs ~= rhs
  }

  func split(_ ranges: [Range<Bound>], noImplicitJoin: Bool = false) -> [Range<Bound>] {
    var result: [Range<Bound>] = []

    var n = lowerBound

    var q = Queue(ranges)

    while let r = q.dequeue() {

      switch r.lowerBound {
      case n:
        if noImplicitJoin { result.append(n ..< n) }
        n = r.upperBound
      case let s where s > n: result.append(n ..< s); n = r.upperBound
      default: break
      }

    }

    if n < upperBound { result.append(n ..< upperBound) }
    return result
  }

  func split(_ range: Range<Bound>) -> [Range<Bound>] {
    if range.lowerBound == lowerBound {
      return [range.upperBound ..< upperBound]
    } else {
      return [lowerBound ..< range.lowerBound, range.upperBound ..< upperBound]
    }
  }

}

public extension Range where Bound:Strideable {

  static func +(lhs: Range, rhs: Bound.Stride) -> Range {
    return lhs.lowerBound.advanced(by: rhs) ..< lhs.upperBound.advanced(by: rhs)
  }

  static func -(lhs: Range, rhs: Bound.Stride) -> Range {
    return lhs.lowerBound.advanced(by: -rhs) ..< lhs.upperBound.advanced(by: -rhs)
  }

}

extension Range: Unpackable2 {

  public var unpack: (Bound, Bound) { return (lowerBound, upperBound) }

}

/// Returns the range from `lhs` up to `lhs + rhs`.
public func +--><Bound:Strideable>(lhs: Bound, rhs: Bound) -> Range<Bound> where Bound.Stride == Bound {
  return lhs ..< lhs.advanced(by: rhs)
}

// MARK: - Additions to ClosedRange

public extension ClosedRange {

  func clampValue(_ value: Bound) -> Bound {
    if contains(value) { return value }
    else if lowerBound > value { return lowerBound }
    else { return upperBound }
  }

  func clampValue(_ value: inout Bound) { value = clampValue(value) }

  var reversed: ReverseClosedRange<Bound> { return ReverseClosedRange<Bound>(self) }


}

extension ClosedRange: Unpackable2 {

  public var unpack: (Bound, Bound) { return (lowerBound, upperBound) }

}

public extension ClosedRange where Bound:FloatingPoint {

  static var infinity: ClosedRange<Bound> { return -Bound.infinity...Bound.infinity }

}

public extension ClosedRange
where Bound:BinarySignedNumeric, Bound.Magnitude == Bound
{
  // FIXME: I think this only works for positive start intervals and intervals of the form -x ... x
  var diameter: Bound { return abs(upperBound - lowerBound) }

  func normalizeValue(_ value: Bound) -> Bound {
    let value = clampValue(value)
    if lowerBound < 0 {

      return (value + lowerBound.magnitude) / diameter

    }
    else if lowerBound > 0 { return (value - lowerBound) / diameter }
    else { return value / diameter }
  }

  func valueForNormalizedValue(_ normalizedValue: Bound) -> Bound {
    guard normalizedValue >= 0 && normalizedValue <= 1 else {
      logw("normalized value must be in 0 ... 1")
      return normalizedValue
    }
    var value = diameter * normalizedValue
    if lowerBound < 0 { value -= abs(lowerBound) }
    else if lowerBound > 0 { value += lowerBound }

    return clampValue(value)
  }

  func mapValue(_ value: Bound, from interval: ClosedRange<Bound>) -> Bound {
    guard self != interval && !(isEmpty || interval.isEmpty) else { return clampValue(value) }
    return valueForNormalizedValue(interval.normalizeValue(value))
  }

  var median: Bound { return (diameter / 2) + lowerBound }


  func split(_ ranges: [ClosedRange<Bound>], noImplicitJoin: Bool = false) -> [ClosedRange<Bound>] {
    var result: [ClosedRange<Bound>] = []

    var n = lowerBound

    var q = Queue(ranges)

    while let r = q.dequeue() {

      switch r.lowerBound {
      case n:
        if noImplicitJoin { result.append(n ... n) }
        n = r.upperBound
      case let s where s > n: result.append(n ... s); n = r.upperBound
      default: break
      }

    }

    if n < upperBound { result.append(n ... upperBound) }
    return result
  }

  func split(_ range: ClosedRange<Bound>) -> [ClosedRange<Bound>] {
    if range.lowerBound == lowerBound {
      return [range.upperBound ... upperBound]
    } else {
      return [lowerBound ... range.lowerBound, range.upperBound ... upperBound]
    }
  }
  
}

/// Operator for creating a `ClosedRange` with a single bound value.
public postfix func ...<B:Comparable>(value: B) -> ClosedRange<B> { return value...value }

// MARK: - Additions to CountableRange

public extension CountableRange {

  static func ~=(lhs: CountableRange, rhs: Bound?) -> Bool {
    guard let rhs = rhs else { return false }
    return lhs ~= rhs
  }

  func split(_ ranges: [CountableRange<Bound>],
                    noImplicitJoin: Bool = false) -> [CountableRange<Bound>]
  {
    var result: [CountableRange<Bound>] = []

    var n = lowerBound

    var q = Queue(ranges)

    while let r = q.dequeue() {

      switch r.lowerBound {
      case n:
        if noImplicitJoin { result.append(n ..< n) }
        n = r.upperBound
      case let s where s > n: result.append(n ..< s); n = r.upperBound
      default: break
      }

    }

    if n < upperBound { result.append(n ..< upperBound) }
    return result
  }

  func split(_ range: CountableRange<Bound>) -> [CountableRange<Bound>] {
    if range.lowerBound == lowerBound {
      return [range.upperBound ..< upperBound]
    } else {
      return [lowerBound ..< range.lowerBound, range.upperBound ..< upperBound]
    }
  }

  var middleIndex: Bound {
    return index(lowerBound, offsetBy: distance(from: lowerBound, to: upperBound) / 2)
  }

  func contains(_ subRange: CountableRange<Bound>) -> Bool {
    return subRange.distance(from: subRange.lowerBound, to: lowerBound) <= 0
      && subRange.distance(from: subRange.upperBound, to: upperBound) >= 0
  }

  func contains<Source>(_ sequence: Source) -> Bool
    where Source:Sequence, Source.Iterator.Element == Bound
  {
    for element in sequence where !contains(element) { return false }
    return true
  }

  static func +(lhs: CountableRange, rhs: Bound.Stride) -> CountableRange<Bound> {
    return lhs.lowerBound.advanced(by: rhs) ..< lhs.upperBound.advanced(by: rhs)
  }

  static func -(lhs: CountableRange, rhs: Bound.Stride) -> CountableRange<Bound> {
    return lhs.lowerBound.advanced(by: -rhs) ..< lhs.upperBound.advanced(by: -rhs)
  }

  static func -(lhs: CountableRange<Int>, rhs: Int) -> CountableRange<Int> {
    return lhs.lowerBound - rhs ..< lhs.upperBound - rhs
  }

  static func +(lhs: CountableRange<Int>, rhs: Int) -> CountableRange<Int> {
    return lhs.lowerBound + rhs ..< lhs.upperBound + rhs
  }

  static func &-(lhs: CountableRange<Int>, rhs: Int) -> CountableRange<Int> {
    return lhs.lowerBound &- rhs ..< lhs.upperBound &- rhs
  }

  static func &+(lhs: CountableRange<Int>, rhs: Int) -> CountableRange<Int> {
    return lhs.lowerBound &+ rhs ..< lhs.upperBound &+ rhs
  }
  
}

//extension CountableRange: Unpackable2 {
//
//  public var unpack: (Bound, Bound) { return (lowerBound, upperBound) }
//
//}

// MARK: - Additions to CountableClosedRange

public extension CountableClosedRange {

  func split(_ ranges: [CountableClosedRange<Bound>],
                    noImplicitJoin: Bool = false) -> [CountableClosedRange<Bound>]
  {
    var result: [CountableClosedRange<Bound>] = []

    var n = lowerBound

    var q = Queue(ranges)

    while let r = q.dequeue() {

      switch r.lowerBound {
        case n:
          if noImplicitJoin { result.append(n ... n) }
          n = r.upperBound
        case let s where s > n: result.append(n ... s); n = r.upperBound
        default: break
      }

    }

    if n < upperBound { result.append(n ... upperBound) }
    return result
  }

  func split(_ range: CountableClosedRange<Bound>) -> [CountableClosedRange<Bound>] {
    if range.lowerBound == lowerBound {
      return [range.upperBound ... upperBound]
    } else {
      return [lowerBound ... range.lowerBound, range.upperBound ... upperBound]
    }
  }

  static func +(lhs: CountableClosedRange, rhs: Bound.Stride) -> CountableClosedRange {
    return lhs.lowerBound.advanced(by: rhs) ... lhs.upperBound.advanced(by: rhs)
  }

  static func -(lhs: CountableClosedRange, rhs: Bound.Stride) -> CountableClosedRange {
    return lhs.lowerBound.advanced(by: -rhs) ... lhs.upperBound.advanced(by: -rhs)
  }
  
}

public extension CountableClosedRange
  where Bound:SignedInteger, Bound.Stride == Int, Bound.IntegerLiteralType == Int
{

  var middleIndex: Bound { return Bound(integerLiteral: lowerBound.distance(to: upperBound) / 2) }

}

public extension CountableClosedRange where Bound:Strideable, Bound.Stride:SignedInteger {

  func contains(_ subRange: CountableClosedRange<Bound>) -> Bool {
    return subRange.lowerBound.distance(to: lowerBound) <= 0
      && subRange.upperBound.distance(to: upperBound) >= 0
  }

  func contains<S:Sequence>(_ sequence: S) -> Bool  where S.Iterator.Element == Bound{
    for element in sequence where !contains(element) { return false }
    return true
  }

}
//extension CountableClosedRange: Unpackable2 {
//
//  public var unpack: (Bound, Bound) { return (lowerBound, upperBound) }
//
//}

/// Operator for creating a `CountableClosedRange` with a single bound value.
public postfix func ...<B:Strideable>(value: B) -> CountableClosedRange<B> { return value...value }

// MARK: - Casting


public func rangeCast<Bound:Strideable>(_ range: CountableRange<Bound>) -> CountableClosedRange<Bound>
  where Bound.Stride:SignedInteger
{
  return CountableClosedRange(range)
}

//public func rangeCast<Bound:Strideable>(_ range: CountableRange<Bound>) -> ClosedRange<Bound>
//  where Bound.Stride:SignedInteger
//{
//  return ClosedRange(range)
//}

//public func rangeCast<Bound:Strideable>(_ range: CountableRange<Bound>) -> Range<Bound>
//  where Bound.Stride:SignedInteger
//{
//  return Range(range)
//}

public func rangeCast<Bound:Strideable>(_ range: CountableClosedRange<Bound>) -> CountableRange<Bound>
  where Bound.Stride:SignedInteger
{
  return CountableRange(range)
}

//public func rangeCast<Bound:Strideable>(_ range: CountableClosedRange<Bound>) -> ClosedRange<Bound>
//  where Bound.Stride:SignedInteger
//{
//  return ClosedRange(range)
//}

//public func rangeCast<Bound:Strideable>(_ range: CountableClosedRange<Bound>) -> Range<Bound>
//  where Bound.Stride:SignedInteger
//{
//  return Range(range)
//}

//public func rangeCast<Bound:Strideable>(_ range: Range<Bound>) -> CountableClosedRange<Bound>
//  where Bound.Stride:SignedInteger
//{
//  return CountableClosedRange(range)
//}

//public func rangeCast<Bound:Strideable>(_ range: Range<Bound>) -> ClosedRange<Bound>
//  where Bound.Stride:SignedInteger
//{
//  return ClosedRange(range)
//}

//public func rangeCast<Bound:Strideable>(_ range: Range<Bound>) -> CountableRange<Bound>
//  where Bound.Stride:SignedInteger
//{
//  return CountableRange(range)
//}

//public func rangeCast<Bound:Strideable>(_ range: ClosedRange<Bound>) -> CountableClosedRange<Bound>
//  where Bound.Stride:SignedInteger
//{
//  return CountableClosedRange(range)
//}

//public func rangeCast<Bound:Strideable>(_ range: ClosedRange<Bound>) -> CountableRange<Bound>
//  where Bound.Stride:SignedInteger
//{
//  return CountableRange(range)
//}

//public func rangeCast<Bound:Strideable>(_ range: ClosedRange<Bound>) -> Range<Bound>
//  where Bound.Stride:SignedInteger
//{
//  return Range(range)
//}

