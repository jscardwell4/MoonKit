//
//  UIEdgeInsets+MoonKitAdditions.swift
//  MoonKit
//
//  Created by Jason Cardwell on 10/8/15.
//  Copyright © 2015 Jason Cardwell. All rights reserved.
//

import Foundation
import UIKit

extension UIEdgeInsets {

  public func inset(_ rect: CGRect) -> CGRect { return rect.inset(by: self) }

  public func outset(_ rect: CGRect) -> CGRect { return inverted.inset(rect) }

  /// The insets formed by negating `top`, `left`, `bottom`, and `right`.
  public var inverted: UIEdgeInsets {
    return UIEdgeInsets(top: -top , left: -left , bottom: -bottom , right: -right)
  }

  /// Initialize from a string.
  public init?(_ string: String?) {
    guard let string = string else { return nil }
    self = NSCoder.uiEdgeInsets(for: string)
  }

  /// Initialize from two values.
  /// - Parameter horizontal: The value to use for `left` and `right`.
  /// - Parameter vertical: The value to use for `top` and `bottom`.
  public init(horizontal: CGFloat, vertical: CGFloat) {
    self.init(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
  }

  /// Initialize from one value.
  /// - Parameter inset: The value to use for `top`, `left`, `bottom`, and `right`.
  public init(inset: CGFloat) {
    self = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
  }

  /// The offset formed by adding `left` and `right`, as well as `top` and `bottom`.
  public var displacement: UIOffset { return UIOffset(horizontal: left + right, vertical: top + bottom) }

}

extension UIEdgeInsets: CustomStringConvertible {

  public var description: String { return NSCoder.string(for: self) }

}

extension UIEdgeInsets: Unpackable4, Packable4 {

  /// The tuple of `top`, `left`, `bottom`, and `right`.
  public var unpack4: (CGFloat, CGFloat, CGFloat, CGFloat) { return (top, left, bottom, right) }

  /// Intialize from a tuple interpretted as `(top, left, bottom, right)`.
  public init(_ elements: (CGFloat, CGFloat, CGFloat, CGFloat)) {
    self = UIEdgeInsets(top: elements.0, left: elements.1, bottom: elements.2, right: elements.3)
  }

}

extension UIEdgeInsets: Packable2 {

  /// Initialize from a tuple interpretted as `(horizontal, vertical)`.
  public init(_ elements: (CGFloat, CGFloat)) {
    self = UIEdgeInsets(top: elements.1, left: elements.0, bottom: elements.1, right: elements.0)
  }

}
