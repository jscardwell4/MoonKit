//
//  CGSize+MoonKitAdditions.swift
//  MoonKit
//
//  Created by Jason Cardwell on 10/8/15.
//  Copyright © 2015 Jason Cardwell. All rights reserved.
//

import Foundation
import UIKit

extension CGSize {

  public init?(_ string: String?) {
    if let s = string {
      self = NSCoder.cgSize(for: s)
    } else { return nil }
  }
  public init(square: CGFloat) { self = CGSize(width: square, height: square) }
  public func contains(_ size: CGSize) -> Bool { return width >= size.width && height >= size.height }

  public var minAxis: NSLayoutConstraint.Axis { return height < width ? .vertical : .horizontal }
  public var maxAxis: NSLayoutConstraint.Axis { return width < height ? .vertical : .horizontal }

  public var minAxisValue: CGFloat { return min(width, height) }
  public var maxAxisValue: CGFloat { return max(width, height) }
  public var area: CGFloat { return width * height }
  public var integralSize: CGSize { return CGSize(width: round(width), height: round(height)) }
  public var ceilSize: CGSize { return CGSize(width: ceil(width), height: ceil(height)) }
  public var floorSize: CGSize { return CGSize(width: floor(width), height: floor(height)) }
  public var integralSizeRoundingUp: CGSize {
  	var size = CGSize(width: round(width), height: round(height))
  	if size.width < width { size.width += CGFloat(1) }
  	if size.height < height { size.height += CGFloat(1) }
  	return size
  }
  public var integralSizeRoundingDown: CGSize {
  	var size = CGSize(width: round(width), height: round(height))
  	if size.width > width { size.width -= CGFloat(1) }
  	if size.height > height { size.height -= CGFloat(1) }
  	return size
  }

  public mutating func scaleBy(_ ratio: Fraction) {
    width = width * CGFloat(Double(ratio.numerator))
    height = height * CGFloat(Double(ratio.denominator))
  }

  public func ratioForFittingSize(_ size: CGSize) -> Fraction {
    fatalError("fix me after dust settles on Ratio")
    /*let (w, h) = min(aspectMappedToWidth(size.width), aspectMappedToHeight(size.height)).unpack
    return Ratio((width/w) / (height/h))*/
  }

  public func scaledBy(_ ratio: Fraction) -> CGSize { var s = self; s.scaleBy(ratio); return s }

  public func aspectMappedToWidth(_ w: CGFloat) -> CGSize { return CGSize(width: w, height: (w * height) / width) }
  public func aspectMappedToHeight(_ h: CGFloat) -> CGSize { return CGSize(width: (h * width) / height, height: h) }
  public func aspectMappedToSize(_ size: CGSize, binding: Bool = false) -> CGSize {
  	let widthMapped = aspectMappedToWidth(size.width)
  	let heightMapped = aspectMappedToHeight(size.height)
  	return binding ? min(widthMapped, heightMapped) : max(widthMapped, heightMapped)
  }
  public mutating func transform(_ transform: CGAffineTransform) {
    self = sizeByApplyingTransform(transform)
  }
  public func sizeByApplyingTransform(_ transform: CGAffineTransform) -> CGSize {
    return self.applying(transform)
  }
}
//extension CGSize: CustomStringConvertible {
//  public var description: String {
//    #if os(iOS)
//      return NSStringFromCGSize(self)
//      #else
//      return NSStringFromSize(self)
//    #endif
//
//  }
//}
extension CGSize: Unpackable2 {
  public var unpack: (CGFloat, CGFloat) { return (width, height) }
}
extension CGSize: Packable2 {
  public init(_ elements: (CGFloat, CGFloat)) { self.init(width: elements.0, height: elements.1) }
}
public func max(_ s1: CGSize, _ s2: CGSize) -> CGSize { return s1 > s2 ? s1 : s2 }
public func min(_ s1: CGSize, _ s2: CGSize) -> CGSize { return s1 < s2 ? s1 : s2 }

public func +(lhs: CGSize, rhs: CGFloat) -> CGSize { return CGSize(width: lhs.width + rhs, height: lhs.height + rhs) }

public func -(lhs: CGSize, rhs: CGFloat) -> CGSize { return CGSize(width: lhs.width - rhs, height: lhs.height - rhs) }
public func -(lhs: CGSize, rhs: CGSize) -> CGSize { return CGSize(width: lhs.width - rhs.width, height: lhs.height - rhs.height) }

public func >(lhs: CGSize, rhs: CGSize) -> Bool { return lhs.area > rhs.area }
public func <(lhs: CGSize, rhs: CGSize) -> Bool { return lhs.area < rhs.area }
public func >=(lhs: CGSize, rhs: CGSize) -> Bool { return lhs.area >= rhs.area }
public func <=(lhs: CGSize, rhs: CGSize) -> Bool { return lhs.area <= rhs.area }

public func *(lhs: CGSize, rhs: CGFloat) -> CGSize { return CGSize(width: lhs.width * rhs, height: lhs.height * rhs) }
public func *(lhs: CGFloat, rhs: CGSize) -> CGSize { return rhs * lhs }
public func *=(lhs: CGSize, rhs: CGFloat) { var lhs = lhs; lhs = lhs * rhs }
public func ∪(lhs: CGSize, rhs: CGSize) -> CGSize {
  return CGSize(width: max(lhs.width, rhs.width), height: max(lhs.height, rhs.height))
}
