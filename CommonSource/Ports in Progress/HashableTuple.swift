//
//  HashableTuple.swift
//  MoonKit
//
//  Created by Jason Cardwell on 1/27/16.
//  Copyright © 2016 Jason Cardwell. All rights reserved.
//

import Foundation

public struct HashableTuple<H1:Hashable,H2:Hashable>: Hashable {
  public let elements: (H1, H2)
  public var hashValue: Int { return elements.0.hashValue ^ elements.1.hashValue }
  public init(_ elements: (H1, H2)) { self.elements = elements }

  public static func ==(lhs: HashableTuple, rhs: HashableTuple) -> Bool {
    return lhs.elements == rhs.elements
  }
}

extension AnyHashable {
  public init<H1:Hashable, H2:Hashable>(_ base: (H1, H2)) {
    self = AnyHashable(HashableTuple(base))
  }
}
