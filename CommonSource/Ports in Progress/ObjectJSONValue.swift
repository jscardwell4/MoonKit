//
//  ObjectJSONValue.swift
//  MoonKit
//
//  Created by Jason Cardwell on 4/12/15.
//  Copyright (c) 2015 Jason Cardwell. All rights reserved.
//

import Foundation

/** Convenience struct for manipulating `JSONValue.Object` cases */
public struct ObjectJSONValue: JSONValueConvertible, JSONValueInitializable {
  public var jsonValue: JSONValue { return .object(value) }
  public fileprivate(set) var value: JSONValue.ObjectValue
  public var count: Int { return value.count }
  public init() { value = JSONValue.ObjectValue() }
  public init(_ value: JSONValue.ObjectValue) { self.value = value }
  public init<J:JSONValueConvertible>(_ value: OrderedDictionary<String, J>) { self.value = OrderedDictionary(value.map({($0, $1.jsonValue)})) }
  public init(_ value: [String:JSONValue]) {
    self.init()
    for (key, value) in value {
      self.value[key] = value
    }
  }
//  public init<J:JSONValueConvertible>(_ value: [String:J]) { self.value = OrderedDictionary(value).map({$1.jsonValue}) }

  public init?(_ jsonValue: JSONValue?) { switch jsonValue ?? .null { case .object(let o): value = o; default: return nil } }
  public subscript(key: String) -> JSONValue? { get { return value[key] } mutating set { value[key] = newValue } }
  public var keys: LazyMapRandomAccessCollection<JSONValue.ObjectValue, String> { return value.keys }
  public var values: LazyMapRandomAccessCollection<JSONValue.ObjectValue, JSONValue> { return value.values }
  public func filter(_ includeElement: (Int, String, JSONValue) -> Bool) -> ObjectJSONValue {
    return ObjectJSONValue(OrderedDictionary(value.enumerated().filter({includeElement($0, $1.0, $1.1)}).map({$1})))
  }
  public func map<U>(_ transform: (Int, String, JSONValue) -> U) -> OrderedDictionary<String, U> {
    return OrderedDictionary(value.enumerated().map({($1.0, transform($0, $1.0, $1.1))}))
  }
  public func map(_ transform: (Int, String, JSONValue) -> JSONValue) -> ObjectJSONValue {
    return ObjectJSONValue(OrderedDictionary(value.enumerated().map({($1.0, transform($0, $1.0, $1.1))})))
  }

  public func compressedMap<U>(_ transform: (Int, String, JSONValue) -> U?) -> OrderedDictionary<String, U> {
    return OrderedDictionary(value.enumerated().flatMap({
      guard let value = transform($0, $1.0, $1.1) else { return nil }
      return ($1.0, value)
    }))
  }

  public func contains(_ object: ObjectJSONValue) -> Bool {
    let objectKeys = Set(object.keys)
    if objectKeys ⊈ keys { return false }
    for objectKey in objectKeys {
      if let objectValue = object[objectKey], let selfValue = self[objectKey] {
        switch (objectValue, selfValue) {
        case (.null, .null): continue
        case (.string(let os), .string(let ss)) where os == ss: continue
        case (.boolean(let ob), .boolean(let sb)) where ob == sb: continue
        case (.number(let on), .number(let sn)) where on.isEqual(to: sn): continue
        case (.array(let oa), .array(let sa)): return ArrayJSONValue(sa).contains(ArrayJSONValue(oa))
        case (.object(let oo), .object(let so)): return ObjectJSONValue(so).contains(ObjectJSONValue(oo))
        default: return false
        }
      } else { return false }
    }
    return true
  }

  public mutating func appendContentsOf(_ other: ObjectJSONValue) { value.append(contentsOf: other.value) }
}

extension ObjectJSONValue: Collection {
  public typealias Index = JSONValue.ObjectValue.Index
  public typealias Iterator = JSONValue.ObjectValue.Iterator
  public var startIndex: Index { return value.startIndex }
  public var endIndex: Index { return value.endIndex }
  public func makeIterator() -> Iterator { return value.makeIterator() }
  public subscript(idx: Index) -> Iterator.Element { get { return value[idx] } set { value[idx] = newValue } }
  public func index(after i: Index) -> Index { return value.index(after: i) }
}

extension ObjectJSONValue: CustomStringConvertible, CustomDebugStringConvertible {
  public var description: String { return value.description }
  public var debugDescription: String { return "MoonKit.ObjectJSONValue - value: \(description)" }
}

public func +(lhs: ObjectJSONValue, rhs: ObjectJSONValue) -> ObjectJSONValue {
  var lhs = lhs; lhs.appendContentsOf(rhs); return lhs
}
public func +=(lhs: inout ObjectJSONValue, rhs: ObjectJSONValue) { lhs.appendContentsOf(rhs) }
public func +(lhs: ObjectJSONValue, rhs: JSONValue) -> ObjectJSONValue {
  if let o = ObjectJSONValue(rhs) { var lhs = lhs; lhs.appendContentsOf(o) }; return lhs
}
public func +=(lhs: inout ObjectJSONValue, rhs: JSONValue) {
  if let o = ObjectJSONValue(rhs) { lhs.appendContentsOf(o) }
}
public func +(lhs: ObjectJSONValue, rhs: JSONValue.ObjectValue) -> ObjectJSONValue {
  var lhs = lhs; lhs.value.append(contentsOf: rhs); return lhs
}
public func +=(lhs: inout ObjectJSONValue, rhs: JSONValue.ObjectValue) { lhs.value.append(contentsOf: rhs) }
public func +<J:JSONValueConvertible>(lhs: ObjectJSONValue, rhs: (String, J)) -> ObjectJSONValue {
  var lhs = lhs; lhs[rhs.0] = rhs.1.jsonValue; return lhs
}
public func +=<J:JSONValueConvertible>(lhs: inout ObjectJSONValue, rhs: (String, J)) {
  lhs[rhs.0] = rhs.1.jsonValue
}
public func +(lhs: ObjectJSONValue, rhs: (String, JSONValue)) -> ObjectJSONValue {
  var lhs = lhs; lhs[rhs.0] = rhs.1; return lhs
}
public func +=(lhs: inout ObjectJSONValue, rhs: (String, JSONValue)) { lhs[rhs.0] = rhs.1 }

