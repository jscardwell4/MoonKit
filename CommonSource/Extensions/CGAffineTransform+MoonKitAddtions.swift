//
//  CGAffineTransform+MoonKitAddtions.swift
//  MoonKit
//
//  Created by Jason Cardwell on 10/8/15.
//  Copyright © 2015 Jason Cardwell. All rights reserved.
//

import Foundation
import UIKit

extension CGAffineTransform/*: CustomStringConvertible*/ {

  public var graphicDescription: String {
    let prefixes = ["┌─", "│ ", "│ ", "│ ", "└─"]
    let suffixes = ["─┐", " │", " │", " │", "─┘"]
    var col1 = ["", "\(a)", "\(c)", "\(tx)", ""]
    var col2 = ["", "\(b)", "\(d)", "\(ty)", ""]
    let col3 = [" ", "0", "0", "1", " "]
    let col1MaxCount = col1.map({$0.utf8.count}).max()!

    for row in 0 ... 4 {
      let delta = col1MaxCount - col1[row].utf8.count
      if delta > 0 {
        let leftPadCount = delta / 2 //(col1[row].hasPrefix("-") ? delta / 2 - 1 : delta / 2)
        let leftPad = " " * leftPadCount
        let rightPad = " " * (delta - leftPadCount)
        col1[row] = leftPad + col1[row] + rightPad
      }
    }

    let col2MaxCount = col2.map({$0.utf8.count}).max()!

    for row in 0 ... 4 {
      let delta = col2MaxCount - col2[row].utf8.count
      if delta > 0 {
        let leftPadCount = delta / 2 //(col2[row].hasPrefix("-") ? delta / 2 - 1 : delta / 2)
        let leftPad = " " * leftPadCount
        let rightPad = " " * (delta - leftPadCount)
        col2[row] = leftPad + col2[row] + rightPad
      }
    }

    var result = ""
    for i in 0 ... 4 {
      if i > 0 { result += "\n" }
      result += "\(prefixes[i]) \(col1[i]) \(col2[i]) \(col3[i]) \(suffixes[i])"
    }
    return result//NSStringFromCGAffineTransform(self)
  }

  public var rotation: CGFloat {
    get {
      guard a == d && b == -c else { return 0 }
      return b.sign == .minus ? -acos(a) : acos(a)
    }
    set {
      let cosine = cos(abs(newValue))
      let sine = sin(abs(newValue))
      a = cosine
      d = cosine
      b = newValue.sign == .minus ? -sine : sine
      c = newValue.sign == .minus ? sine : -sine
    }
  }
    
}

public func +(lhs: CGAffineTransform, rhs: CGAffineTransform) -> CGAffineTransform {
  return lhs.concatenating(rhs)
}
public func +=(lhs: CGAffineTransform, rhs: CGAffineTransform) { var lhs = lhs; lhs = lhs + rhs }
public func ==(lhs: CGAffineTransform, rhs: CGAffineTransform) -> Bool {
  return lhs.__equalTo(rhs)
}

extension CGAffineTransform {
//  public init(tx: CGFloat, ty: CGFloat) { self = CGAffineTransform(translationX: tx, y: ty) }
//  public init(translation: CGPoint) { self = CGAffineTransform(tx: translation.x, ty: translation.y) }
//  public init(sx: CGFloat, sy: CGFloat) { self = CGAffineTransform(scaleX: sx, y: sy) }
//  public init(angle: CGFloat) { self = CGAffineTransform(rotationAngle: angle) }
//  public var isIdentity: Bool { return self.isIdentity }
//  public mutating func translate(_ tx: CGFloat, _ ty: CGFloat) { self = translated(tx, ty) }
//  public func translated(_ tx: CGFloat, _ ty: CGFloat) -> CGAffineTransform { return self.translateBy(x: tx, y: ty) }
//  public mutating func scale(_ sx: CGFloat, sy: CGFloat) { self = scaled(sx, sy) }
//  public func scaled(_ sx: CGFloat, _ sy: CGFloat) -> CGAffineTransform { return self.scaleBy(x: sx, y: sy) }
//  public mutating func rotate(_ angle: CGFloat) { self = rotated(angle) }
//  public func rotated(_ angle: CGFloat) -> CGAffineTransform { return self.rotate(angle) }
//  public mutating func invert() { self = inverted }
//  public var inverted: CGAffineTransform { return self.invert() }
//  public static var identityTransform: CGAffineTransform { return CGAffineTransform.identity }
  public init?(_ string: String?) {
    if let s = string {
      self = NSCoder.cgAffineTransform(for: s)
    } else { return nil }
  }
}
