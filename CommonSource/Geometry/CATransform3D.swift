//
//  CATransform3D.swift
//  MoonKit
//
//  Created by Jason Cardwell on 10/10/15.
//  Copyright © 2015 Jason Cardwell. All rights reserved.
//

import Foundation
import UIKit

extension CATransform3D {

  public var graphicDescription: String {
    let prefixes = ["┌─", "│ ", "│ ", "│ ", "│ ", "└─"]
    let suffixes = ["─┐", " │", " │", " │", " │", "─┘"]
    var col1 = ["", "\(m11)", "\(m21)", "\(m31)", "\(m41)", ""]
    var col2 = ["", "\(m12)", "\(m22)", "\(m32)", "\(m42)", ""]
    var col3 = ["", "\(m13)", "\(m23)", "\(m33)", "\(m43)", ""]
    var col4 = [" ", "\(m14)", "\(m24)", "\(m34)", "\(m44)", " "]
    let col1MaxCount = col1.map({$0.utf8.count}).max()!

    for row in 0 ... 5 {
      let delta = col1MaxCount - col1[row].utf8.count
      if delta > 0 {
        let leftPadCount = delta / 2
        let leftPad = " " * leftPadCount
        let rightPad = " " * (delta - leftPadCount)
        col1[row] = leftPad + col1[row] + rightPad
      }
    }

    let col2MaxCount = col2.map({$0.utf8.count}).max()!

    for row in 0 ... 5 {
      let delta = col2MaxCount - col2[row].utf8.count
      if delta > 0 {
        let leftPadCount = delta / 2
        let leftPad = " " * leftPadCount
        let rightPad = " " * (delta - leftPadCount)
        col2[row] = leftPad + col2[row] + rightPad
      }
    }

    let col3MaxCount = col3.map({$0.utf8.count}).max()!

    for row in 0 ... 5 {
      let delta = col3MaxCount - col3[row].utf8.count
      if delta > 0 {
        let leftPadCount = delta / 2
        let leftPad = " " * leftPadCount
        let rightPad = " " * (delta - leftPadCount)
        col3[row] = leftPad + col3[row] + rightPad
      }
    }

    let col4MaxCount = col4.map({$0.utf8.count}).max()!

    for row in 0 ... 5 {
      let delta = col4MaxCount - col4[row].utf8.count
      if delta > 0 {
        let leftPadCount = delta / 2
        let leftPad = " " * leftPadCount
        let rightPad = " " * (delta - leftPadCount)
        col4[row] = leftPad + col4[row] + rightPad
      }
    }

    var result = ""
    for i in 0 ... 5 {
      if i > 0 { result += "\n" }
      result += "\(prefixes[i]) \(col1[i]) \(col2[i]) \(col3[i]) \(col4[i]) \(suffixes[i])"
    }
    return result//NSStringFromCGAffineTransform(self)
  }

  public static var identity: CATransform3D { return CATransform3DIdentity }

  public static var perspective: CATransform3D {
    return CATransform3D(
      m11: 1, m12: 0, m13: 0, m14: 0,
      m21: 0, m22: 1, m23: 0, m24: 0,
      m31: 0, m32: 0, m33: 0, m34: CGFloat(-1.0/1000.0),
      m41: 0, m42: 0, m43: 0, m44: 1
    )
  }

  public init(tx: CGFloat, ty: CGFloat, tz: CGFloat) {
    self = CATransform3DMakeTranslation(tx, ty, tz)
  }

  public init(sx: CGFloat, sy: CGFloat, sz: CGFloat) {
    self = CATransform3DMakeScale(sx, sy, sz)
  }

  public init(angle: CGFloat, x: CGFloat, y: CGFloat, z: CGFloat) {
    self = CATransform3DMakeRotation(angle, x, y, z)
  }

  public func scaled(sx: CGFloat, sy: CGFloat, sz: CGFloat) -> CATransform3D {
    return CATransform3DScale(self, sx, sy, sz)
  }

  public mutating func scale(sx: CGFloat, sy: CGFloat, sz: CGFloat) {
    self = scaled(sx: sx, sy: sy, sz: sz)
  }

  public func translated(tx: CGFloat, ty: CGFloat, tz: CGFloat) -> CATransform3D {
    return CATransform3DTranslate(self, tx, ty, tz)
  }

  public mutating func translate(tx: CGFloat, ty: CGFloat, tz: CGFloat) {
    self = translated(tx: tx, ty: ty, tz: tz)
  }

  public func rotated(angle: CGFloat, x: CGFloat, y: CGFloat, z: CGFloat) -> CATransform3D {
    return CATransform3DRotate(self, angle, x, y, z)
  }

  public mutating func rotate(angle: CGFloat, x: CGFloat, y: CGFloat, z: CGFloat) {
    self = rotated(angle: angle, x: x, y: y, z: z)
  }

  public func inverted() -> CATransform3D { return CATransform3DInvert(self) }

  public mutating func invert() { self = inverted() }

  public func concatenated(_ t: CATransform3D) -> CATransform3D { return CATransform3DConcat(self, t) }

  public mutating func concatenate(_ t: CATransform3D) { self = concatenated(t) }

  public var isAffine: Bool { return CATransform3DIsAffine(self) }

  public var affineTransform: CGAffineTransform { return CATransform3DGetAffineTransform(self) }

  public var isIdentity: Bool { return CATransform3DIsIdentity(self) }

  public var rotation: CGFloat {
    get {
      guard m11 == m22 && m12 == -m21 else { return 0 }
      return m12.sign == .minus ? -acos(m11) : acos(m11)
    }
    set {
      let cosine = cos(abs(newValue))
      let sine = sin(abs(newValue))
      m11 = cosine
      m22 = cosine
      m12 = newValue.sign == .minus ? -sine : sine
      m21 = newValue.sign == .minus ? sine : -sine
    }
  }

  public init(affine: CGAffineTransform) {
    self = CATransform3DMakeAffineTransform(affine)
  }
}

extension CATransform3D: Equatable {}

public func ==(lhs: CATransform3D, rhs: CATransform3D) -> Bool {
  return CATransform3DEqualToTransform(lhs, rhs)
}
