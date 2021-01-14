//
//  Array+MoonKitAdditions.swift
//  Remote
//
//  Created by Jason Cardwell on 12/20/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation

extension Array: PrettyPrint {

  public var prettyDescription: String {
    guard count > 0 else { return "[]" }

    var result = "["

    var first = true

    for element in self {

      if first {
        first = false
        result += "\n  "
      } else {
        result += ",\n  "
      }

      result += (element as? PrettyPrint)?.prettyDescription ?? "\(element)"

    }

    result += "\n]"

    return result
  }

}

extension NSArray: PrettyPrint {
  public var prettyDescription: String { (self as Array<AnyObject>).prettyDescription }
}

extension NSArray: JSONValueConvertible {
  public var jsonValue: JSONValue {
    JSONValue.array(compactMap {($0 as? JSONValueConvertible)?.jsonValue})
  }
}

extension Array: JSONValueConvertible {
  public var jsonValue: JSONValue {
    JSONValue.array(compactMap {($0 as? JSONValueConvertible)?.jsonValue})
  }
}

extension Array {
  public init(minimumCapacity: Int) {
    self.init()
    reserveCapacity(minimumCapacity)
  }
}

extension ContiguousArray {
  public init(minimumCapacity: Int) {
    self.init()
    reserveCapacity(minimumCapacity)
  }
}

