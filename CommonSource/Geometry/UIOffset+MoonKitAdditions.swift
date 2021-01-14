//
//  UIOffset+MoonKitAdditions.swift
//  MoonKit
//
//  Created by Jason Cardwell on 10/8/15.
//  Copyright © 2015 Jason Cardwell. All rights reserved.
//

import Foundation
import UIKit

extension UIOffset {

  /// Initialize from a string.
  public init?(_ string: String?) {
    guard let string = string else { return nil }
    self = NSCoder.uiOffset(for: string)
  }

  /// Returns the rectangle formed by offsetting by `horizontal` and `vertical`.
  public func offset(_ rect: CGRect) -> CGRect {
    return rect.offsetBy(dx: horizontal, dy: vertical)
  }

}

extension UIOffset: Unpackable2, Packable2 {

  /// The tuple of `horizontal` and `vertical`.
  public var unpack: (CGFloat, CGFloat) { return (horizontal, vertical) }

  /// Initialize with a tuple interpretted as `(horizontal, vertical)`.
  public init(_ elements: (CGFloat, CGFloat)) {
    self = UIOffset(horizontal: elements.0, vertical: elements.1)
  }

}


extension UIOffset: CustomStringConvertible {

  public var description: String { return NSCoder.string(for: self) }

}

