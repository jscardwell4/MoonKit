//
//  CGRect+MoonKitAdditions.swift
//  MoonKit
//
//  Created by Jason Cardwell on 10/8/15.
//  Copyright © 2015 Jason Cardwell. All rights reserved.
//

import Foundation
import UIKit

extension CGRect {

  public var x: CGFloat { return origin.x }
  public var y: CGFloat { return origin.y }

  // MARK: - Initializers

  public init?(_ string: String?) {
    if let s = string {
      self = NSCoder.cgRect(for: s)
    } else { return nil }
  }

  public init(size: CGSize) { self = CGRect(origin: .zero, size: size) }

  public init(size: CGSize, center: CGPoint) {
    let origin = CGPoint(x: center.x - size.width * 0.5, y: center.y - size.height * 0.5)
    self = CGRect(origin: origin, size: size)
  }

  // MARK: - Centering

  public var centerInscribedSquare: CGRect {
    guard width != height else { return self }
    var result = self
    result.size = CGSize(square: size.minAxisValue)
    result.origin = CGPoint(x: result.origin.x + (size.width - result.size.width) * 0.5,
                            y: result.origin.y + (size.height - result.size.height) * 0.5)
    return result
  }

  public var center: CGPoint {
    get { return CGPoint(x: midX, y: midY) }
    set { self = CGRect(size: size, center: newValue) }
  }

  public typealias ResizingAxis = NSLayoutConstraint.Axis

  public enum ResizingAnchor {
    case TopLeft, Top, TopRight, Left, Center, Right, BottomLeft, Bottom, BottomRight
  }

  
  public func applyRatio(ratio: Fraction,
                    axis: ResizingAxis = .vertical,
                  anchor: ResizingAnchor = .Center) -> CGRect
  {
    var result = self
    result.applyRatioInPlace(ratio: ratio, axis: axis, anchor: anchor)
    return result
  }

  public mutating func applyRatioInPlace(ratio: Fraction,
                                    axis: ResizingAxis = .vertical,
                                  anchor: ResizingAnchor = .Center)
  {
    let newSize: CGSize
    switch axis {
      case .horizontal:
        newSize = CGSize(width: size.width,
                         height: size.height * (CGFloat(Double(ratio.numerator))/CGFloat(Double(ratio.denominator))))
      case .vertical:   newSize = CGSize(width: size.width * (CGFloat(Double(ratio.numerator))/CGFloat(Double(ratio.denominator))),
                                         height: size.height)
      @unknown default:
        fatalError("\(#fileID) \(#function) Unexpected case.")
    }

    let newOrigin: CGPoint
    switch anchor {
      case .TopLeft:     newOrigin = CGPoint(x: origin.x, y: origin.y)
      case .Top:         newOrigin = CGPoint(x: midX - newSize.width * 0.5, y: origin.y)
      case .TopRight:    newOrigin = CGPoint(x: maxX - newSize.width, y: origin.y)
      case .Left:        newOrigin = CGPoint(x: origin.x, y: midY - newSize.height * 0.5)
      case .Center:      newOrigin = CGPoint(x: midX - newSize.width * 0.5, y: midY - newSize.height * 0.5)
      case .Right:       newOrigin = CGPoint(x: maxX - newSize.width, y: midY - newSize.height * 0.5)
      case .BottomLeft:  newOrigin = CGPoint(x: origin.x, y: maxY - newSize.height)
      case .Bottom:      newOrigin = CGPoint(x: midX - newSize.width * 0.5, y: maxY - newSize.height)
      case .BottomRight: newOrigin = CGPoint(x: maxX - newSize.width, y: maxY - newSize.height)
    }
    size = newSize
    origin = newOrigin
  }

  // MARK: - Convenience methods that call to library `offsetBy` and `offsetInPlace` methods



  public func offsetBy(offset: UIOffset) -> CGRect { return offsetBy(dx: offset.horizontal, dy: offset.vertical) }

  
  public func offsetBy(point: CGPoint) -> CGRect { return offsetBy(dx: point.x, dy: point.y) }

//  public mutating func offsetInPlace(point: CGPoint) { offsetInPlace(dx: point.x, dy: point.y) }
//  public mutating func offsetInPlace(off: UIOffset) { offsetInPlace(dx: off.horizontal, dy: off.vertical) }

  public mutating func transformInPlace(transform t: CGAffineTransform) { self = transform(transform: t) }
  public func transform(transform: CGAffineTransform) -> CGRect {
    return self.applying(transform)
  }

}

// MARK: - CustomStringConvertible

extension CGRect: CustomStringConvertible {
  public var description: String {
    return NSCoder.string(for: self)
  }
}

// MARK: - Unpacking

extension CGRect: Unpackable4 {

  public var unpack4: (CGFloat, CGFloat, CGFloat, CGFloat) {
    return (origin.x, origin.y, size.width, size.height)
  }

}

extension CGRect: NonHomogeneousUnpackable2 {

  public var unpack2: (CGPoint, CGSize) { return (origin, size) }

}

extension CGRect {

  public static func >> (lhs: CGRect, rhs: CGFloat) -> CGRect {
    var result = lhs
    result.origin.x += rhs
    return result
  }

  public static func << (lhs: CGRect, rhs: CGFloat) -> CGRect {
    var result = lhs
    result.origin.x -= rhs
    return result
  }

  public static func ⋁⋁ (lhs: CGRect, rhs: CGFloat) -> CGRect {
    var result = lhs
    result.origin.y += rhs
    return result
  }

  public static func ⋀⋀ (lhs: CGRect, rhs: CGFloat) -> CGRect {
    var result = lhs
    result.origin.y -= rhs
    return result
  }

  public static func >>= (lhs: inout CGRect, rhs: CGFloat) {
    lhs.origin.x += rhs
  }

  public static func <<= (lhs: inout CGRect, rhs: CGFloat) {
    lhs.origin.x -= rhs
  }

  public static func ⋁⋁= (lhs: inout CGRect, rhs: CGFloat) {
    lhs.origin.y += rhs
  }

  public static func ⋀⋀= (lhs: inout CGRect, rhs: CGFloat) {
    lhs.origin.y -= rhs
  }

}

extension CGRect {

  public func slices(dividingAtDistance distance: CGFloat, fromEdge edge: CGRectEdge) -> [CGRect] {

    var result: [CGRect] = []

    var remainingRect = self

    func canDivide() -> Bool {

      switch edge {

      case .minXEdge, .maxXEdge:
        return remainingRect.width > distance

      case .minYEdge, .maxYEdge:
        return remainingRect.height > distance

      }

    }


    func divide() -> CGRect {

      let (rect1, rect2) = remainingRect.divided(atDistance: distance, from: edge)
      remainingRect = rect2

      return rect1

    }

    while canDivide() {

      result.append(divide())

    }

    result.append(remainingRect)

    return result

  }

}

//extension CGRect: SetAlgebra {
//  public typealias Element = CGPoint
//  public func exclusiveOr(other: CGRect) -> CGRect {
//    return self
//  }
//  public mutating func exclusiveOrInPlace(other: CGRect) {
//
//  }
//  public mutating func insert(_ newMember: CGPoint) -> (inserted: Bool, memberAfterInsert: CGPoint) {
//    if contains(newMember) { return (false, newMember) }
//    let minX = min(origin.x, newMember.x)
//    let minY = min(origin.y, newMember.y)
//    let maxX = max(self.maxX, newMember.x)
//    let maxY = max(self.maxY, newMember.y)
//    self = CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
//  }
//  public mutating func remove(_ member: CGPoint) -> CGPoint? {
//    return nil
//  }
//}

// MARK: - Set operators

//public func ∪(lhs: CGRect, rhs: CGRect) -> CGRect { return lhs.union(rhs) }

//public func ∩(lhs: CGRect, rhs: CGRect) -> CGRect { return lhs.intersect(rhs) }

//public func ∪=(inout lhs: CGRect, rhs: CGRect) { lhs.formUnion(rhs) }

//public func ∩=(inout lhs: CGRect, rhs: CGRect) { lhs.intersectInPlace(rhs) }

