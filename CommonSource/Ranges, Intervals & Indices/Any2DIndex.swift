//
//  AnyIndexPath.swift
//  MoonKit
//
//  Created by Jason Cardwell on 12/19/16.
//  Copyright © 2016 Jason Cardwell. All rights reserved.
//

import Foundation

public struct Any2DIndex<Base1:Comparable, Base2:Comparable>: Comparable, CustomStringConvertible {

  public let index1: Base1
  public let index2: Base2

  public init(_ index1: Base1, _ index2: Base2) {
    self.index1 = index1
    self.index2 = index2
  }

  public static func == (lhs: Any2DIndex, rhs: Any2DIndex) -> Bool {
    return lhs.index1 == rhs.index1 && lhs.index2 == rhs.index2
  }

  public static func < (lhs: Any2DIndex, rhs: Any2DIndex) -> Bool {
    return lhs.index1 < rhs.index1 || lhs.index1 == rhs.index1 && lhs.index2 < rhs.index2
  }

  public var description: String { return "(\(index1), \(index2))" }
  
}

