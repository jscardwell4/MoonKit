//
//  Interval.swift
//  MoonKit
//
//  Created by Jason Cardwell on 12/3/16.
//  Copyright © 2016 Jason Cardwell. All rights reserved.
//

import Foundation

public enum IntervalComparisonResult {

  /// `lhs`|`rhs` is empty.
  case undefined

  /// `lhs` fully precedes `rhs`.
  ///````
  /// █████ █████
  /// lhs__
  ///       rhs__
  ///````
  case ascending

  /// `lhs.upper` and `rhs.lower` are joining endpoints.
  ///````
  /// ████▒████
  /// lhs__
  ///     rhs__
  ///````
  case ascendingJoin

  /// `lhs` overlaps `rhs` and `lhs.lower < rhs.lower`.
  ///````
  ///   █████
  /// █████░░
  /// lhs____
  ///   rhs__
  ///````
  case ascendingOverlap

  /// `lhs` fully contains `rhs`.
  ///````
  ///  ███
  /// █████
  /// lhs__
  ///  rhs
  ///````
  case ascendingContainment

  /// Two identical intervals.
  ///````
  /// █████
  /// █████
  /// lhs__
  /// rhs__
  ///````
  case same

  /// `rhs.upper` and `lhs.lower` are joining endpoints.
  ///````
  /// ████▒████
  ///     lhs__
  /// rhs__
  ///````
  case descendingJoin

  /// `lhs` overlaps `rhs` and `rhs.lower < lhs.lower`.
  ///````
  /// ███░░░░
  ///   █████
  ///   lhs__
  /// rhs____
  ///````
  case descendingOverlap

  /// `rhs` fully contains `lhs`.
  ///````
  /// █████
  ///  ███
  ///  lhs
  /// rhs__
  ///````
  case descendingContainment

  /// `rhs` fully precedes `lhs`.
  ///````
  /// █████
  ///       █████
  ///       lhs__
  /// rhs__
  ///````
  case descending
}

public enum IntervalEndpointKind: String { case open, closed }

public enum IntervalEndpoint<Bound:Comparable>: Equatable {
  case some(kind: IntervalEndpointKind, value: Bound)

  public var kind: IntervalEndpointKind { switch self { case .some(let kind, _): return kind } }
  public var value: Bound { switch self { case .some(_, let value): return value } }

  public var inverted: IntervalEndpoint<Bound> {
    switch self {
      case .some(.open, let value): return .some(kind: .closed, value: value)
      case .some(.closed, let value): return .some(kind: .open, value: value)
    }
  }

  public static func ==(lhs: IntervalEndpoint, rhs: IntervalEndpoint) -> Bool {
    return lhs.kind == rhs.kind && lhs.value == rhs.value
  }

}

public enum IntervalLimit {
  case lower, upper

  public var inverted: IntervalLimit {
    switch self {
      case .lower: return .upper
      case .upper: return .lower
    }
  }

}

public struct DirectedIntervalEndpoint<Bound: Comparable>: Comparable, CustomStringConvertible {

  public let endpoint: IntervalEndpoint<Bound>
  public let limit: IntervalLimit

  public var kind: IntervalEndpointKind { return endpoint.kind }
  public var value: Bound { return endpoint.value }

  public var kindInverted: DirectedIntervalEndpoint<Bound> {
    return DirectedIntervalEndpoint(endpoint: endpoint.inverted, limit: limit)
  }

  public var limitInverted: DirectedIntervalEndpoint<Bound> {
    return DirectedIntervalEndpoint(endpoint: endpoint, limit: limit.inverted)
  }

  public var inverted: DirectedIntervalEndpoint<Bound> {
    return DirectedIntervalEndpoint(endpoint: endpoint.inverted, limit: limit.inverted)
  }

  public func withLimit(_ limit: IntervalLimit) -> DirectedIntervalEndpoint {
    return DirectedIntervalEndpoint(endpoint: endpoint, limit: limit)
  }

  public var description: String {
    switch (endpoint, limit) {
      case (.some(.open, let value), .lower):   return "(\(value)"
      case (.some(.closed, let value), .lower): return "[\(value)"
      case (.some(.open, let value), .upper):   return "\(value))"
      case (.some(.closed, let value), .upper): return "\(value)]"
    }
  }

  public static func ==(lhs: DirectedIntervalEndpoint, rhs: DirectedIntervalEndpoint) -> Bool {
    return lhs.endpoint == rhs.endpoint && lhs.limit == rhs.limit
  }

  public static func <(lhs: DirectedIntervalEndpoint, rhs: DirectedIntervalEndpoint) -> Bool {

    switch ((lhs.endpoint, lhs.limit), (rhs.endpoint, rhs.limit)) {

    case ((.some(.open, let leftValue), .lower), (.some(.open, let rightValue), .lower)):
      return leftValue < rightValue

    case ((.some(.open, let leftValue), .lower), (.some(.open, let rightValue), .upper)):
      return leftValue <= rightValue

    case ((.some(.open, let leftValue), .lower), (.some(.closed, let rightValue), .lower)):
      return leftValue < rightValue

    case ((.some(.open, let leftValue), .lower), (.some(.closed, let rightValue), .upper)):
      return leftValue <= rightValue

    case ((.some(.open, let leftValue), .upper), (.some(.open, let rightValue), .lower)):
      return leftValue < rightValue

    case ((.some(.open, let leftValue), .upper), (.some(.open, let rightValue), .upper)):
      return leftValue < rightValue

    case ((.some(.open, let leftValue), .upper), (.some(.closed, let rightValue), .lower)):
      return leftValue <= rightValue

    case ((.some(.open, let leftValue), .upper), (.some(.closed, let rightValue), .upper)):
      return leftValue <= rightValue
      
    case ((.some(.closed, let leftValue), .lower), (.some(.open, let rightValue), .lower)):
      return leftValue <= rightValue

    case ((.some(.closed, let leftValue), .lower), (.some(.open, let rightValue), .upper)):
      return leftValue <= rightValue

    case ((.some(.closed, let leftValue), .lower), (.some(.closed, let rightValue), .lower)):
      return leftValue < rightValue

    case ((.some(.closed, let leftValue), .lower), (.some(.closed, let rightValue), .upper)):
      return leftValue <= rightValue
      
    case ((.some(.closed, let leftValue), .upper), (.some(.open, let rightValue), .lower)):
      return leftValue <= rightValue

    case ((.some(.closed, let leftValue), .upper), (.some(.open, let rightValue), .upper)):
      return leftValue < rightValue

    case ((.some(.closed, let leftValue), .upper), (.some(.closed, let rightValue), .lower)):
      return leftValue < rightValue

    case ((.some(.closed, let leftValue), .upper), (.some(.closed, let rightValue), .upper)):
      return leftValue < rightValue

    }

  }

  public static func ..(lhs: DirectedIntervalEndpoint, rhs: DirectedIntervalEndpoint) -> Interval<Bound> {
    return Interval<Bound>(lower: lhs, upper: rhs)
  }
  
}

public prefix func 【<B:Comparable>(value: B) -> DirectedIntervalEndpoint<B> {
  return DirectedIntervalEndpoint(endpoint: .some(kind: .closed, value: value), limit: .lower)
}

public prefix func 〖<B:Comparable>(value: B) -> DirectedIntervalEndpoint<B> {
  return DirectedIntervalEndpoint(endpoint: .some(kind: .open, value: value), limit: .lower)
}

public postfix func 】<B:Comparable>(value: B) -> DirectedIntervalEndpoint<B> {
  return DirectedIntervalEndpoint(endpoint: .some(kind: .closed, value: value), limit: .upper)
}

public postfix func 〗<B:Comparable>(value: B) -> DirectedIntervalEndpoint<B> {
  return DirectedIntervalEndpoint(endpoint: .some(kind: .open, value: value), limit: .upper)
}

public struct Interval<Bound:Comparable> {

  public typealias Endpoint = DirectedIntervalEndpoint<Bound>

  public let lower: Endpoint
  public let upper: Endpoint

  public init(closed lowerEndpoint: Bound, closed upperEndpoint: Bound) {
    lower = 【lowerEndpoint
    upper = upperEndpoint】
  }

  public init(closed lowerEndpoint: Bound, open upperEndpoint: Bound) {
    lower = 【lowerEndpoint
    upper = upperEndpoint〗
  }

  public init(open lowerEndpoint: Bound, closed upperEndpoint: Bound) {
    lower = 〖lowerEndpoint
    upper = upperEndpoint】
  }

  public init(open lowerEndpoint: Bound, open upperEndpoint: Bound) {
    lower = 〖lowerEndpoint
    upper = upperEndpoint〗
  }

  fileprivate init(lower: Endpoint, upper: Endpoint) {
    self.lower = lower
    self.upper = upper
  }

  /// Initialize an interval of a single value.
  public init(degenerate value: Bound) {
    lower = 【value
    upper = value】
  }

  public init(_ range: Range<Bound>) {
    lower = 【range.lowerBound
    upper = range.upperBound〗
  }

  public init(_ range: ClosedRange<Bound>) {
    lower = 【range.lowerBound
    upper = range.upperBound】
  }

  /// Given a < b, the interval is empty if it has one of the following forms: [b,a], (a,a), [a,a), (a,a]
  public var isEmpty: Bool {
    switch (lower.endpoint, upper.endpoint) {
      case (.some(.open, let lowerValue), .some(.open, let upperValue)) where upperValue <= lowerValue,
           (.some(.open, let lowerValue), .some(.closed, let upperValue)) where upperValue <= lowerValue,
           (.some(.closed, let lowerValue), .some(.open, let upperValue)) where upperValue <= lowerValue,
           (.some(.closed, let lowerValue), .some(.closed, let upperValue)) where upperValue < lowerValue:
      return true
      default:
        return false
    }
  }

  public var isDegenerate: Bool {
    guard let leastElement = leastElement, let greatestElement = greatestElement else { return false }
    return leastElement == greatestElement
  }

  public var leastElement: Bound? {
    guard lower.kind == .closed else { return nil }
    return lower.value
  }

  public var greatestElement: Bound? {
    guard upper.kind == .closed else { return nil }
    return upper.value
  }

  public func contains(_ element: Bound) -> Bool {
    guard !isEmpty else { return false }
    return lower <= 【element && upper >= element】
  }

  public func contains(_ endpoint: Endpoint) -> Bool {
    guard !isEmpty else { return false }
    switch endpoint.limit {
      case .lower: return lower <= endpoint && endpoint.inverted < upper
      case .upper: return lower < endpoint.inverted && endpoint <= upper
    }
  }

  public func contains(_ other: Interval<Bound>) -> Bool {
    guard !(isEmpty || other.isEmpty) else { return false }
    return lower <= other.lower && upper >= other.upper
  }

  public func overlaps(_ other: Interval<Bound>) -> Bool {
    switch compare(to: other) {
      case .ascendingOverlap,
           .ascendingContainment,
           .descendingOverlap,
           .descendingContainment,
           .same:
        return true
      default:
        return false
    }
  }

}

extension Interval where Bound:Strideable, Bound.Stride:SignedInteger {

  public init(_ range: CountableRange<Bound>) {
    lower = 【range.lowerBound
    upper = range.upperBound〗
  }

  public init(_ range: CountableClosedRange<Bound>) {
    lower = 【range.lowerBound
    upper = range.upperBound】
  }

}

extension Interval: Equatable {

  public static func ==(lhs: Interval, rhs: Interval) -> Bool {
    return !(lhs.isEmpty || rhs.isEmpty) && lhs.lower == rhs.lower && lhs.upper == rhs.upper
  }

}

extension Interval: CustomStringConvertible {

  public var description: String { return "\(lower), \(upper)" }

}

extension Interval {

  public func union(_ other: Interval<Bound>) -> Interval<Bound>? {

    // Ensure neither interval is empty.
    guard !(isEmpty || other.isEmpty) else { return nil }

    // Check for overlap.
    guard !overlaps(other) else {
      // Return smallest lower with largest upper.
      return Interval(lower: min(lower, other.lower), upper: max(upper, other.upper))
    }

    switch compare(to: other) {
      case .ascendingJoin:
        return Interval(lower: lower, upper: other.upper)
      case .descendingJoin:
        return Interval(lower: other.lower, upper: upper)
      case .ascendingContainment:
        return self
      case .descendingContainment:
        return other
      default:
        return nil
    }

  }

  public func intersection(_ other: Interval<Bound>) -> Interval<Bound> {

    // Ensure neither interval is empty.
    guard !isEmpty else { return self }
    guard !other.isEmpty else { return other }

    // Return largest lower with smallest upper.
    return Interval(lower: max(lower, other.lower), upper: min(upper, other.upper))

  }

  public func compare(to other: Interval<Bound>) -> IntervalComparisonResult {

    // Check for two empty or two equivalent intervals.
    guard !(isEmpty || other.isEmpty) else { return .undefined }


    switch (lower, upper, other.lower, other.upper) {

      case let (lower, upper, otherLower, otherUpper)
            where lower == otherLower && upper == otherUpper:
        // ██████
        // ██████
        return .same

      case let (_, upper, otherLower, _)
            where upper.value == otherLower.value && upper.kind != otherLower.kind:
        //       ██████
        // ██████
        return .ascendingJoin

      case let (lower, _, _, otherUpper)
            where otherUpper.value == lower.value && otherUpper.kind != lower.kind:
        // ██████
        //       ██████
        return .descendingJoin

      case let (lower, upper, otherLower, otherUpper)
            where lower <= otherLower
               && upper >= otherUpper:
        //  ████
        // ██████
        return .ascendingContainment

      case let (lower, upper, otherLower, otherUpper)
            where otherLower <= lower
               && otherUpper >= upper:
        // ██████
        //  ████
        return .descendingContainment

      case let (lower, upper, otherLower, otherUpper)
            where upper.kind == .closed && otherLower.kind == .closed
               && otherLower.withLimit(.upper) == upper
               && lower.withLimit(.upper) < otherUpper
               && upper.withLimit(.lower) == otherLower
               && otherUpper.withLimit(.lower) > lower,
           let (lower, upper, otherLower, otherUpper)
            where lower < otherLower
               && upper <= otherUpper
               && upper.withLimit(.lower) > otherLower:
        //   ██████
        // ██████░░
        return .ascendingOverlap

      case let (lower, upper, otherLower, otherUpper)
            where lower.kind == .closed && otherUpper.kind == .closed
               && otherLower.withLimit(.upper) < upper
               && lower.withLimit(.upper) == otherUpper
               && upper.withLimit(.lower) > otherLower
               && otherUpper.withLimit(.lower) == lower,
           let (lower, upper, otherLower, otherUpper)
            where otherLower < lower
               && otherUpper <= upper
               && otherUpper.withLimit(.lower) > lower:
        // ███░░░░░
        //   ██████
        return .descendingOverlap

      case let (lower, upper, otherLower, _)
            where lower < otherLower
               && upper.withLimit(.lower) <= otherLower:
        //        ██████
        // ██████
        return .ascending

      case let (lower, _, otherLower, otherUpper)
            where otherLower < lower
               && otherUpper.withLimit(.lower) <= lower:
        // ██████
        //        ██████
        return .descending

      default:
        fatalError("If we found a case that gets here we need to rework our control flow.")

    }

  }

}
