//
//  JSONValueRelatedExtensions.swift
//  MoonKit
//
//  Created by Jason Cardwell on 4/12/15.
//  Copyright (c) 2015 Jason Cardwell. All rights reserved.
//

import Foundation
import UIKit

extension Bool: JSONValueConvertible {
  public var jsonValue: JSONValue { return .boolean(self) }
}

extension Bool/*: JSONValueInitializable*/ {
  public init?(_ jsonValue: JSONValue?) { if let b = jsonValue?.boolValue { self = b } else { return nil } }
}

extension NSString: JSONValueConvertible {
  public var jsonValue: JSONValue { return .string(self as String) }
}

extension String: JSONValueConvertible {
  public var jsonValue: JSONValue { return .string(self) }
}

extension String: JSONValueInitializable {
  public init?(_ jsonValue: JSONValue?) {
    if let string = jsonValue?.stringValue { self = string } else { return nil }
  }
}

extension KeyValuePairs: JSONValueConvertible {
  public var jsonValue: JSONValue {
    var dict = OrderedDictionary<String, JSONValue>()
    for (key: key, value: value) in self {
      guard let key = key as? StringValueConvertible, let value = value as? JSONValueConvertible else { continue }
      dict[key.stringValue] = value.jsonValue
    }
    return .object(dict)
  }
}

extension Int: JSONValueConvertible {
  public var jsonValue: JSONValue { return .number(NSNumber(value: self))}
}
extension Int: JSONValueInitializable {
  public init?(_ jsonValue: JSONValue?) { if let n = jsonValue?.intValue { self = n } else { return nil } }
}

extension Int8: JSONValueConvertible {
  public var jsonValue: JSONValue { return .number(NSNumber(value: self))}
}
extension Int8: JSONValueInitializable {
  public init?(_ jsonValue: JSONValue?) { if let n = jsonValue?.int8Value { self = n } else { return nil } }
}

extension Int16: JSONValueConvertible {
  public var jsonValue: JSONValue { return .number(NSNumber(value: self))}
}
extension Int16: JSONValueInitializable {
  public init?(_ jsonValue: JSONValue?) { if let n = jsonValue?.int16Value { self = n } else { return nil } }
}

extension Int32: JSONValueConvertible {
  public var jsonValue: JSONValue { return .number(NSNumber(value:self))}
}
extension Int32: JSONValueInitializable {
  public init?(_ jsonValue: JSONValue?) { if let n = jsonValue?.int32Value { self = n } else { return nil } }
}

extension Int64: JSONValueConvertible {
  public var jsonValue: JSONValue { return .number(NSNumber(value: self))}
}
extension Int64: JSONValueInitializable {
  public init?(_ jsonValue: JSONValue?) { if let n = jsonValue?.int64Value { self = n } else { return nil } }
}

extension UInt: JSONValueConvertible {
  public var jsonValue: JSONValue { return .number(NSNumber(value: self))}
}
extension UInt: JSONValueInitializable {
  public init?(_ jsonValue: JSONValue?) { if let n = jsonValue?.uintValue { self = n } else { return nil } }
}

extension UInt8: JSONValueConvertible {
  public var jsonValue: JSONValue { return .number(NSNumber(value: self))}
}
extension UInt8: JSONValueInitializable {
  public init?(_ jsonValue: JSONValue?) { if let n = jsonValue?.uint8Value { self = n } else { return nil } }
}

extension UInt16: JSONValueConvertible {
  public var jsonValue: JSONValue { return .number(NSNumber(value: self))}
}
extension UInt16: JSONValueInitializable {
  public init?(_ jsonValue: JSONValue?) { if let n = jsonValue?.uint16Value { self = n } else { return nil } }
}

extension UInt32: JSONValueConvertible {
  public var jsonValue: JSONValue { return .number(NSNumber(value: self))}
}
extension UInt32: JSONValueInitializable {
  public init?(_ jsonValue: JSONValue?) { if let n = jsonValue?.uint32Value { self = n } else { return nil } }
}

extension UInt64: JSONValueConvertible {
  public var jsonValue: JSONValue { return .number(NSNumber(value: self))}
}
extension UInt64: JSONValueInitializable {
  public init?(_ jsonValue: JSONValue?) { if let n = jsonValue?.uint64Value { self = n } else { return nil } }
}

extension Float: JSONValueConvertible {
  public var jsonValue: JSONValue { return .number(NSNumber(value: self))}
}
extension Float: JSONValueInitializable {
  public init?(_ jsonValue: JSONValue?) { if let n = jsonValue?.floatValue { self = n } else { return nil } }
}
extension CGFloat: JSONValueConvertible {
  public var jsonValue: JSONValue { return .number(NSNumber(value: Double(self)))}
}
extension CGFloat: JSONValueInitializable {
  public init?(_ jsonValue: JSONValue?) { if let n = jsonValue?.CGFloatValue { self = n } else { return nil } }
}

extension Double: JSONValueConvertible {
  public var jsonValue: JSONValue { return .number(NSNumber(value: self))}
}
extension Double: JSONValueInitializable {
  public init?(_ jsonValue: JSONValue?) { if let n = jsonValue?.doubleValue { self = n } else { return nil } }
}

extension CGSize: JSONValueConvertible {
  public var jsonValue: JSONValue { return .string(NSCoder.string(for: self)) }
}
extension CGSize: JSONValueInitializable {
  public init?(_ jsonValue: JSONValue?) { if let s = jsonValue?.CGSizeValue { self = s } else { return nil } }
}

extension CGRect: JSONValueConvertible {
  public var jsonValue: JSONValue { return .string(NSCoder.string(for: self)) }
}
extension CGRect: JSONValueInitializable {
  public init?(_ jsonValue: JSONValue?) { if let s = jsonValue?.CGRectValue { self = s } else { return nil } }
}

extension Optional: JSONValueConvertible {
  public var jsonValue: JSONValue {
    switch self {
      case .some(let wrapped as JSONValueConvertible): return wrapped.jsonValue
      default: return .null
    }
  }
}

//extension CGPoint: JSONValueConvertible {
//  public var jsonValue: JSONValue { return .String(NSStringFromCGPoint(self)) }
//}
//extension CGPoint: JSONValueInitializable {
//  public init?(_ jsonValue: JSONValue?) { if let s = jsonValue?.CGPointValue { self = s } else { return nil } }
//}
//
//extension CGVector: JSONValueConvertible {
//  public var jsonValue: JSONValue { return .String(NSStringFromCGVector(self)) }
//}
//extension CGVector: JSONValueInitializable {
//  public init?(_ jsonValue: JSONValue?) { if let s = jsonValue?.CGVectorValue { self = s } else { return nil } }
//}

extension UIOffset: JSONValueConvertible {
  public var jsonValue: JSONValue { return .string(NSCoder.string(for: self)) }
}
extension UIOffset: JSONValueInitializable {
  public init?(_ jsonValue: JSONValue?) { if let s = jsonValue?.UIOffsetValue { self = s } else { return nil } }
}

extension CGAffineTransform: JSONValueConvertible {
  public var jsonValue: JSONValue { return .string(NSCoder.string(for: self)) }
}
extension CGAffineTransform: JSONValueInitializable {
  public init?(_ jsonValue: JSONValue?) {
    if let s = jsonValue?.CGAffineTransformValue { self = s } else { return nil }
  }
}

extension UIEdgeInsets: JSONValueConvertible {
  public var jsonValue: JSONValue { return .string(NSCoder.string(for: self)) }
}
extension UIEdgeInsets: JSONValueInitializable {
  public init?(_ jsonValue: JSONValue?) {
    if let u = jsonValue?.UIEdgeInsetsValue { self = u } else { return nil }
  }
}
