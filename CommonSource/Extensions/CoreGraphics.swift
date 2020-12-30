//
//  CoreGraphics.swift
//  MoonKit
//
//  Created by Jason Cardwell on 10/26/14.
//  Copyright (c) 2014 Jason Cardwell. All rights reserved.
//

import Foundation
import UIKit

public enum CircleQuadrant: String {
  case I, II, III, IV

  public init(point: CGPoint, center: CGPoint) {
    switch ((point.x, point.y), (center.x, center.y)) {
      case let ((px, py), (cx, cy)) where px >= cx && py <= cy: self = .I
      case let ((px, py), (cx, cy)) where px <= cx && py <= cy: self = .II
      case let ((px, py), (cx, cy)) where px <= cx && py >= cy: self = .III
      default:                                                  self = .IV
    }
  }

  public init(angle: Double) {
    switch angle {
      case 0 ... (.pi * 0.5):   self = .IV
      case (.pi * 0.5) ... .pi: self = .III
      case .pi ... (.pi * 1.5): self = .II
      default:                  self = .I
    }
  }

}
public enum RotationalDirection: Int, CustomStringConvertible {

  case counterClockwise = -1, unspecified, clockwise

  public init(from: CGPoint, to: CGPoint, about: CGPoint, trending: RotationalDirection?) {

    let direction: RotationalDirection
    let fromQuadrant = CircleQuadrant(point: from, center: about)
    let toQuadrant = CircleQuadrant(point: to, center: about)

    switch (fromQuadrant, toQuadrant) {

      case (.I, .II), (.II, .III), (.III, .IV), (.IV, .I):
        direction = .counterClockwise

      case (.I, .IV), (.IV, .III), (.III, .II), (.II, .I):
        direction = .clockwise

      default:
        switch ((from.x, from.y), (to.x, to.y)) {

          case let ((x1, y1), (x2, y2)) where y2 == y1 && x2 < x1:
            switch toQuadrant {
              case .I, .II: direction = .counterClockwise
              default: direction = .clockwise
            }

          case let ((x1, y1), (x2, y2)) where y2 == y1 && x2 >= x1:
            switch toQuadrant {
              case .I, .II: direction = .clockwise
              default: direction = .counterClockwise
            }

          case let ((x1, y1), (x2, y2)) where x2 == x1 && y2 <= y1:
            switch toQuadrant {
              case .II, .III: direction = .clockwise
              default: direction = .counterClockwise
            }

          case let ((x1, y1), (x2, y2)) where x2 == x1 && y2 >= y1:
            switch toQuadrant {
              case .II, .III: direction = .counterClockwise
              default: direction = .clockwise
            }

          case let ((x1, y1), (x2, y2)) where y2 < y1 && x2 < x1:
            switch toQuadrant {
              case .III: direction = .clockwise
              case .I:   direction = .counterClockwise
              case .II:  direction = trending ?? .unspecified
              case .IV:  direction = trending ?? .unspecified
            }

          case let ((x1, y1), (x2, y2)) where y2 < y1 && x2 > x1:
            switch toQuadrant {
              case .III: direction = trending ?? .counterClockwise
              case .I:   direction = trending ?? .clockwise
              case .II:  direction = .clockwise
              case .IV:  direction = .counterClockwise
            }

          case let ((x1, y1), (x2, y2)) where y2 > y1 && x2 < x1:
            switch toQuadrant {
              case .III: direction = trending ?? .unspecified
              case .I:   direction = trending ?? .unspecified
              case .II:  direction = .counterClockwise
              case .IV:  direction = .clockwise
            }

          case let ((x1, y1), (x2, y2)) where y2 > y1 && x2 > x1:
            switch toQuadrant {
              case .III: direction = trending ?? .unspecified
              case .I:   direction = trending ?? .unspecified
              case .II:  direction = .clockwise
              case .IV:  direction = .counterClockwise
            }

        default:
          direction = .unspecified

      }
      
    }

    self = direction
  }

  public var description: String {
    switch self {
      case .clockwise:        return "Clockwise"
      case .unspecified:      return "Unspecified"
      case .counterClockwise: return "CounterClockwise"
    }
  }

}


public enum VerticalAlignment: String { case Top, Center, Bottom }

public func +<U1:Unpackable2, U2:Unpackable2>(lhs: U1, rhs: U2) -> U1
  where U1:Packable2,
        U1.Packable2Element == U1.Unpackable2Element,
        U1.Unpackable2Element == U2.Unpackable2Element,
        U1.Unpackable2Element:Additive
{
  var values1 = lhs.unpack
  let values2 = rhs.unpack
  values1.0 += values2.0
  values1.1 += values2.1
  return U1(values1)
}

public func -<U1:Unpackable2, U2:Unpackable2>(lhs: U1, rhs: U2) -> U1
  where U1:Packable2,
        U1.Packable2Element == U1.Unpackable2Element,
        U1.Unpackable2Element == U2.Unpackable2Element,
        U1.Unpackable2Element:Subtractive
{
  var values1 = lhs.unpack
  let values2 = rhs.unpack
  values1.0 -= values2.0
  values1.1 -= values2.1
  return U1(values1)
}

public func *<U1:Unpackable2, U2:Unpackable2>(lhs: U1, rhs: U2) -> U1
  where U1:Packable2,
        U1.Packable2Element == U1.Unpackable2Element,
        U1.Unpackable2Element == U2.Unpackable2Element,
        U1.Unpackable2Element:Multiplicative
{
  var values1 = lhs.unpack
  let values2 = rhs.unpack
  values1.0 *= values2.0
  values1.1 *= values2.1
  return U1(values1)
}

public func /<U1:Unpackable2, U2:Unpackable2>(lhs: U1, rhs: U2) -> U1
  where U1:Packable2,
        U1.Packable2Element == U1.Unpackable2Element,
        U1.Unpackable2Element == U2.Unpackable2Element,
        U1.Unpackable2Element:Divisive
{
  var values1 = lhs.unpack
  let values2 = rhs.unpack
  values1.0 /= values2.0
  values1.1 /= values2.1
  return U1(values1)
}

public func %<U1:Unpackable2, U2:Unpackable2>(lhs: U1, rhs: U2) -> U1
  where U1:Packable2,
        U1.Packable2Element == U1.Unpackable2Element,
        U1.Unpackable2Element == U2.Unpackable2Element,
        U1.Unpackable2Element:BinaryInteger
{
  var values1 = lhs.unpack
  let values2 = rhs.unpack
  values1.0 = values1.0 % values2.0
  values1.1 = values1.1 % values2.1
  return U1(values1)
}

public func +=<U1:Unpackable2, U2:Unpackable2>(lhs: inout U1, rhs: U2)
  where U1:Packable2,
        U1.Packable2Element == U1.Unpackable2Element,
        U1.Unpackable2Element == U2.Unpackable2Element,
        U1.Unpackable2Element:Additive
{
  var values1 = lhs.unpack
  let values2 = rhs.unpack
  values1.0 += values2.0
  values1.1 += values2.1
  lhs = U1(values1)
}

public func -=<U1:Unpackable2, U2:Unpackable2>(lhs: inout U1, rhs: U2)
  where U1:Packable2,
        U1.Packable2Element == U1.Unpackable2Element,
        U1.Unpackable2Element == U2.Unpackable2Element,
        U1.Unpackable2Element:Subtractive
{
  var values1 = lhs.unpack
  let values2 = rhs.unpack
  values1.0 -= values2.0
  values1.1 -= values2.1
  lhs = U1(values1)
}

public func *=<U1:Unpackable2, U2:Unpackable2>(lhs: inout U1, rhs: U2)
  where U1:Packable2,
        U1.Packable2Element == U1.Unpackable2Element,
        U1.Unpackable2Element == U2.Unpackable2Element,
        U1.Unpackable2Element:Multiplicative
{
  var values1 = lhs.unpack
  let values2 = rhs.unpack
  values1.0 *= values2.0
  values1.1 *= values2.1
  lhs = U1(values1)
}

public func /=<U1:Unpackable2, U2:Unpackable2>(lhs: inout U1, rhs: U2)
  where U1:Packable2,
        U1.Packable2Element == U1.Unpackable2Element,
        U1.Unpackable2Element == U2.Unpackable2Element,
        U1.Unpackable2Element:Divisive
{
  var values1 = lhs.unpack
  let values2 = rhs.unpack
  values1.0 /= values2.0
  values1.1 /= values2.1
  lhs = U1(values1)
}

public func %=<U1:Unpackable2, U2:Unpackable2>(lhs: inout U1, rhs: U2)
  where U1:Packable2,
        U1.Packable2Element == U1.Unpackable2Element,
        U1.Unpackable2Element == U2.Unpackable2Element,
        U1.Unpackable2Element:BinaryInteger
{
  var values1 = lhs.unpack
  let values2 = rhs.unpack
  values1.0 = values1.0 % values2.0
  values1.1 = values1.1 % values2.1
  lhs = U1(values1)
}

public func rounded(_ v: CGFloat, _ mantissaLength: Int) -> CGFloat {
  let remainder = v.truncatingRemainder(dividingBy: pow(10, -CGFloat(mantissaLength)))
  let x = pow(10, CGFloat(mantissaLength))
  let y = pow(10, CGFloat(mantissaLength))
  return v - remainder + round(remainder * x) / y
}

public func rounded(_ v: Double, _ mantissaLength: Int) -> Double {
  let remainder = v.truncatingRemainder(dividingBy: pow(10, -Double(mantissaLength)))
  let x = pow(10, Double(mantissaLength))
  let y = pow(10, Double(mantissaLength))
  return v - remainder + round(remainder * x) / y
}

extension CGFloat {
  public var degrees: CGFloat { return self * 180 / .pi }
  public var radians: CGFloat { return self * .pi / 180 }
  public func rounded(_ mantissaLength: Int) -> CGFloat { return MoonKit.rounded(self, mantissaLength) }
}

public extension CGBlendMode {
  var stringValue: String {
    switch self {
      case .normal:          return "Normal"
      case .multiply:        return "Multiply"
      case .screen:          return "Screen"
      case .overlay:         return "Overlay"
      case .darken:          return "Darken"
      case .lighten:         return "Lighten"
      case .colorDodge:      return "ColorDodge"
      case .colorBurn:       return "ColorBurn"
      case .softLight:       return "SoftLight"
      case .hardLight:       return "HardLight"
      case .difference:      return "Difference"
      case .exclusion:       return "Exclusion"
      case .hue:             return "Hue"
      case .saturation:      return "Saturation"
      case .color:           return "Color"
      case .luminosity:      return "Luminosity"
      case .clear:           return "Clear"
      case .copy:            return "Copy"
      case .sourceIn:        return "SourceIn"
      case .sourceOut:       return "SourceOut"
      case .sourceAtop:      return "SourceAtop"
      case .destinationOver: return "DestinationOver"
      case .destinationIn:   return "DestinationIn"
      case .destinationOut:  return "DestinationOut"
      case .destinationAtop: return "DestinationAtop"
      case .xor:             return "XOR"
      case .plusDarker:      return "PlusDarker"
      case .plusLighter:     return "PlusLighter"
      @unknown default:
        fatalError("\(#fileID) \(#function) Unexpected value.")
    }
  }
  init(stringValue: String) {
    switch stringValue {
      case "Multiply":        self = .multiply
      case "Screen":          self = .screen
      case "Overlay":         self = .overlay
      case "Darken":          self = .darken
      case "Lighten":         self = .lighten
      case "ColorDodge":      self = .colorDodge
      case "ColorBurn":       self = .colorBurn
      case "SoftLight":       self = .softLight
      case "HardLight":       self = .hardLight
      case "Difference":      self = .difference
      case "Exclusion":       self = .exclusion
      case "Hue":             self = .hue
      case "Saturation":      self = .saturation
      case "Color":           self = .color
      case "Luminosity":      self = .luminosity
      case "Clear":           self = .clear
      case "Copy":            self = .copy
      case "SourceIn":        self = .sourceIn
      case "SourceOut":       self = .sourceOut
      case "SourceAtop":      self = .sourceAtop
      case "DestinationOver": self = .destinationOver
      case "DestinationIn":   self = .destinationIn
      case "DestinationOut":  self = .destinationOut
      case "DestinationAtop": self = .destinationAtop
      case "XOR":             self = .xor
      case "PlusDarker":      self = .plusDarker
      case "PlusLighter":     self = .plusLighter
      default:                self = .normal
    }
  }
}
