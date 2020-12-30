//
//  ArrayJSONValue.swift
//  MoonKit
//
//  Created by Jason Cardwell on 4/12/15.
//  Copyright (c) 2015 Jason Cardwell. All rights reserved.
//

import Foundation

public struct ArrayJSONValue: JSONValueConvertible, JSONValueInitializable {
  public fileprivate(set) var value: [JSONValue]
  public var jsonValue: JSONValue { return .array(value) }
  public var count: Int { return value.count }

  public init(_ value: [JSONValue]) { self.value = value }
  public init<J:JSONValueConvertible>(_ value: [J]) { self.value = value.map({$0.jsonValue}) }
  public init?(_ jsonValue: JSONValue?) { switch jsonValue ?? .null { case .array(let a): value = a; default: return nil } }

  public func filter(_ includeElement: (JSONValue) -> Bool) -> ArrayJSONValue {
    return ArrayJSONValue(value.filter(includeElement))
  }

  public mutating func append<J:JSONValueConvertible>(_ j: J) { append(j.jsonValue) }
  public mutating func append(_ j: JSONValue) { value.append(j) }

  public mutating func appendContentsOf(_ other: ArrayJSONValue) { appendContentsOf(other.value) }
  public mutating func appendContentsOf(_ other: [JSONValue]) { value.append(contentsOf: other) }

  public func map<U>(_ transform: (JSONValue) -> U) -> [U] { return value.map(transform) }
  public func flatMap<U>(_ transform: (JSONValue) -> U?) -> [U] { return value.compactMap(transform) }
  public func map(_ transform: (JSONValue) -> JSONValue) -> ArrayJSONValue { return ArrayJSONValue(value.map(transform)) }

  public func compressedMap<U>(_ transform: (JSONValue) -> U?) -> [U] { return value.compactMap(transform) }

  public var objectMapped: [ObjectJSONValue] { return compressedMap({ObjectJSONValue($0)}) }

  public func contains(_ array: ArrayJSONValue) -> Bool {
    if array.count > count { return false }
    for object in array {
      switch object {
      case .null where value.contains(object): continue
      case .string(_) where value.contains(object): continue
      case .number(_) where value.contains(object): continue
      case .boolean(_) where value.contains(object): continue
      case .object(_) where value.contains(object): continue
      case .array(_) where value.contains(object): continue
      default: return false
      }
    }

    return true
  }

}
extension ArrayJSONValue: Collection {
  public typealias Index = JSONValue.ArrayValue.Index
  public typealias Iterator = JSONValue.ArrayValue.Iterator
  public var startIndex: Index { return value.startIndex }
  public var endIndex: Index { return value.endIndex }
  public func makeIterator() -> Iterator { return value.makeIterator() }
  public subscript(idx: Index) -> Iterator.Element { get { return value[idx] } set { value[idx] = newValue } }
  public func index(after i: Index) -> Index { return i + 1 }
}

extension ArrayJSONValue: CustomStringConvertible, CustomDebugStringConvertible {
  public var description: String { return value.description }
  public var debugDescription: String { return "MoonKit.ArrayJSONValue - value: \(description)" }
}

public func +(lhs: ArrayJSONValue, rhs: ArrayJSONValue) -> ArrayJSONValue { var lhs = lhs; lhs.appendContentsOf(rhs); return lhs }
public func +=(lhs: inout ArrayJSONValue, rhs: ArrayJSONValue) { lhs.appendContentsOf(rhs) }

public func +(lhs: ArrayJSONValue, rhs: JSONValue) -> ArrayJSONValue { var lhs = lhs; lhs.append(rhs); return lhs }
public func +=(lhs: inout ArrayJSONValue, rhs: JSONValue) { lhs.append(rhs) }

public func +(lhs: ArrayJSONValue, rhs: JSONValue.ArrayValue) -> ArrayJSONValue { var lhs = lhs; lhs.appendContentsOf(rhs); return lhs }
public func +=(lhs: inout ArrayJSONValue, rhs: JSONValue.ArrayValue) { lhs.appendContentsOf(rhs) }

public func +<J:JSONValueConvertible>(lhs: ArrayJSONValue, rhs: J) -> ArrayJSONValue { var lhs = lhs; lhs.append(rhs); return lhs }
public func +=<J:JSONValueConvertible>(lhs: inout ArrayJSONValue, rhs: J) { lhs.append(rhs) }
