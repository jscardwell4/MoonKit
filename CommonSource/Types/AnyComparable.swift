//
//  AnyComparable.swift
//  MoonKit
//
//  Created by Jason Cardwell on 12/19/16.
//  Copyright © 2016 Jason Cardwell. All rights reserved.
//

import Foundation

fileprivate protocol AnyComparableBox {

  var typeID: ObjectIdentifier { get }
  func unbox<T:Comparable>() -> T?

  func isEqual(to: AnyComparableBox) -> Bool?
  func isLess(than: AnyComparableBox) -> Bool?

  var base: Any { get }
  func downCastConditional<T>(into result: UnsafeMutablePointer<T>) -> Bool
}

fileprivate struct ConcreteComparableBox<Base:Comparable> : AnyComparableBox {

  var baseComparable: Base

  init(_ base: Base) { baseComparable = base }

  var typeID: ObjectIdentifier { return ObjectIdentifier(type(of: self)) }

  func unbox<T:Comparable>() -> T? {
    return (self as AnyComparableBox as? ConcreteComparableBox<T>)?.baseComparable
  }

  func isEqual(to rhs: AnyComparableBox) -> Bool? {
    guard let rhs: Base = rhs.unbox() else { return nil }
    return baseComparable == rhs
  }

  func isLess(than rhs: AnyComparableBox) -> Bool? {
    guard let rhs: Base = rhs.unbox() else { return nil }
    return baseComparable < rhs
  }

  var base: Any { return baseComparable }

  func downCastConditional<T>(into result: UnsafeMutablePointer<T>) -> Bool {
    guard let value = baseComparable as? T else { return false }
    result.initialize(to: value)
    return true
  }
}

public struct AnyComparable {

  fileprivate let box: AnyComparableBox

  public init<C:Comparable>(_ base: C) { box = ConcreteComparableBox(base) }

  public var base: Any { return box.base }

  internal func downCastConditional<T>(into result: UnsafeMutablePointer<T>) -> Bool {
    return box.downCastConditional(into: result)
  }

}

extension AnyComparable: Equatable {
  public static func == (lhs: AnyComparable, rhs: AnyComparable) -> Bool {
    return lhs.box.isEqual(to: rhs.box) == true
  }
}

extension AnyComparable: Comparable {
  public static func < (lhs: AnyComparable, rhs: AnyComparable) -> Bool {
    return lhs.box.isLess(than: rhs.box) == true
  }
}

extension AnyComparable: CustomStringConvertible {
  public var description: String { return String(describing: base) }
}

extension AnyComparable: CustomDebugStringConvertible {
  public var debugDescription: String { return "AnyComparable(" + String(reflecting: base) + ")" }
}

extension AnyComparable: CustomReflectable {
  public var customMirror: Mirror { return Mirror(self, children: ["value": base]) }
}
