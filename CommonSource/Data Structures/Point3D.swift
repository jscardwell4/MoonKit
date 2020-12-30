//
//  Point3D.swift
//  MoonKit
//
//  Created by Jason Cardwell on 11/24/16.
//  Copyright © 2016 Jason Cardwell. All rights reserved.
//
import Foundation

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

public struct Point3D {


  public var x: CGFloat

  public var y: CGFloat

  public var z: CGFloat


  public static var zero: Point3D { return Point3D() }

  public init() {
    x = 0
    y = 0
    z = 0
  }

  public init(x: CGFloat, y: CGFloat, z: CGFloat) {
    self.x = x
    self.y = y
    self.z = z
  }

  public init(x: Int, y: Int, z: Int) {
    self.x = CGFloat(x)
    self.y = CGFloat(y)
    self.z = CGFloat(z)
  }

  public init(x: Double, y: Double, z: Double) {
    self.x = CGFloat(x)
    self.y = CGFloat(y)
    self.z = CGFloat(z)
  }

  public init(_ point: CGPoint) {
    self = Point3D(x: point.x, y: point.y, z: 0)
  }

  public func applying(_ transform: CATransform3D) -> Point3D {
    return Point3D(
      x: transform.m11 * x + transform.m21 * y + transform.m31 * z + transform.m41,
      y: transform.m12 * x + transform.m22 * y + transform.m32 * z + transform.m42,
      z: transform.m13 * x + transform.m23 * y + transform.m33 * z + transform.m43
    )
  }
}

extension Point3D: CustomStringConvertible {

  public var description: String { return "(\(x), \(y), \(z))" }

}

extension Point3D: Equatable {

  public static func ==(lhs: Point3D, rhs: Point3D) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
  }

}

extension Point3D: CustomReflectable {

  public var customMirror: Mirror {
    return Mirror(self, children: ["x": x, "y": y, "z": z], displayStyle: .`struct`)
  }

}
