//
//  CGVector+MoonKitAdditions.swift
//  MoonKit
//
//  Created by Jason Cardwell on 10/8/15.
//  Copyright © 2015 Jason Cardwell. All rights reserved.
//

import Foundation
import UIKit

extension CGVector {

  /// Initialize from a string
  public init?(_ string: String?) {
    guard let string = string else { return nil }
    self = NSCoder.cgVector(for: string)
  }

  /// A vector for representing a null or invalid value.
  public static var null: CGVector = CGVector(dx: CGFloat.nan, dy: CGFloat.nan)

  /// True when either `dx` or `dy` is nan.
  public var isNull: Bool { return dx.isNaN || dy.isNaN }

  /// The vector with a `dx` and `dy` set to their absolute values.
  public var absolute: CGVector { return isNull ? self : CGVector(dx: abs(dx), dy: abs(dy)) }

  /// Initialize from any type that unpacks into two `CGFloat` values.
  public init<Source>(_ source: Source) where Source:Unpackable2, Source.Unpackable2Element == CGFloat {
    let (dx, dy) = source.unpack
    self.init(dx: dx, dy: dy)
  }

  /// The greater value between `dx` and `dy`.
  public var max: CGFloat { return dy > dx ? dy : dx }

  /// The lesser value between `dx` and `dy`.
  public var min: CGFloat { return dy < dx ? dy : dx }

  /// The angle described by the vector.
  public var angle: CGFloat {
    get {
      switch (dx, dy) {
        case (0, 0): return .nan
        case (0, _): return .pi * 0.5
        case (_, 0): return 0
        default:     return atan(dy / dx)
      }
    }
    set {
      rotate(to: newValue)
    }
  }

  /// Rotates the vector by `angle`.
  public mutating func rotate(by angle: CGFloat) {
    let dxʹ = dx * cos(angle) - dy * sin(angle)
    let dyʹ = dx * sin(angle) + dy * cos(angle)
    dx = dxʹ; dy = dyʹ
  }

  /// Rotates the vector such that its angle equals `angle`.
  public mutating func rotate(to angle: CGFloat) { rotate(by: angle - self.angle) }

  /// Returns the vector rotated by `angle`.
  public func rotated(to angle: CGFloat) -> CGVector { var v = self; v.rotate(to: angle); return v }

  /// Returns the vector rotated such that its angle equals `angle`.
  public func rotated(by angle: CGFloat) -> CGVector { var v = self; v.rotate(by: angle); return v }

  /// Returns a description of the vector with its `dx` and `dy` values rounded to `precision` decimals.
  public func description(_ precision: Int) -> String {
    return precision >= 0 ? "(\(dx.rounded(precision)), \(dy.rounded(precision)))" : description
  }

  /// Returns the vector formed by dividing `lhs` `dx` and `dy` values by `rhs`.
  public static func /(lhs: CGVector, rhs: CGFloat) -> CGVector {
    return CGVector(dx: lhs.dx / rhs, dy: lhs.dy / rhs)
  }

  /// Assigning version of the `/` operator.
  public static func /=(lhs: inout CGVector, rhs: CGFloat) { lhs = lhs / rhs }

  /// Returns the vector formed by multiplying `lhs` `dx` and `dy` values by `rhs`.
  public static func *(lhs: CGVector, rhs: CGFloat) -> CGVector {
    return CGVector(dx: lhs.dx * rhs, dy: lhs.dy * rhs)
  }

  /// Assigning version of the `*` operator.
  public static func *=(lhs: inout CGVector, rhs: CGFloat) { lhs = lhs * rhs }

  /// Returns the vector formed by summing the `dx` and `dy` values for each element in `source`.
  public static func sum<Source>(_ source: Source) -> CGVector
    where Source: Sequence, Source.Iterator.Element == CGVector
  {
    return source.reduce(CGVector(), {CGVector(dx: $0.dx + $1.dx, dy: $0.dy + $1.dy)})
  }

   /// Returns the vector formed by summing the `dx` and `dy` values for each element in `source` and then dividing `dx` and `dy` by the number of elements in `source`..
  public static func mean<Source>(_ source: Source) -> CGVector
    where Source: Sequence , Source.Iterator.Element == CGVector
  {
    var count: CGFloat = 0
    var sum = zero

    for vector in source {
      sum.dx += vector.dx
      sum.dy += vector.dy
      count = count + 1
    }

    return sum / count

  }
  
}

extension CGVector: CustomStringConvertible {

  public var description: String { return "(\(dx), \(dy))" }

  public var debugDescription: String { return NSCoder.string(for: self) }

}

extension CGVector: Unpackable2, Packable2 {

  /// The tuple `(dx, dy)`.
  public var unpack: (CGFloat, CGFloat) { return (dx, dy) }

  /// Initialize from a tuple interpretted as `(dx, dy)`.
  public init(_ elements: (CGFloat, CGFloat)) { self.init(dx: elements.0, dy: elements.1) }

}

extension CGVector: JSONValueConvertible, JSONValueInitializable {

  /// The json object describing the vector.
  public var jsonValue: JSONValue {
    return ObjectJSONValue(["dx": dx.jsonValue, "dy": dy.jsonValue]).jsonValue
  }

  /// Initialize from a json object with keys 'dx' and 'dy' whose values may be converted to `CGFloat`.
  public init?(_ jsonValue: JSONValue?) {

    guard let dict = ObjectJSONValue(jsonValue),
          let dx = CGFloat(dict["dx"]),
          let dy = CGFloat(dict["dy"])
      else
    {
      return nil
    }

    self.init(dx: dx, dy: dy)

  }

}

