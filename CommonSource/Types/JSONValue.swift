//
//  JSONValue.swift
//  MoonKit
//
//  Created by Jason Cardwell on 4/1/15.
//  Copyright (c) 2015 Jason Cardwell. All rights reserved.
//
import Foundation
import UIKit

public protocol JSONValueConvertible {
  var jsonValue: JSONValue { get }
}

extension JSONValueConvertible where Self:RawRepresentable, Self.RawValue:JSONValueConvertible {
  public var jsonValue: JSONValue { return rawValue.jsonValue }
}

public protocol JSONValueInitializable {
  init?(_ jsonValue: JSONValue?)
}

extension JSONValueInitializable where Self:RawRepresentable, Self.RawValue:JSONValueInitializable {
  public init?(_ jsonValue: JSONValue?) {
    guard let rawValue = Self.RawValue(jsonValue) else { return nil }
    self.init(rawValue: rawValue)
  }
}

public protocol LosslessJSONValueConvertible: JSONValueConvertible, JSONValueInitializable {} 

// MARK: - JSONValue
/// Enumeration of discriminating union to represent a JSON value.
public enum JSONValue {
  public typealias ObjectValue = OrderedDictionary<String, JSONValue>
  public typealias ArrayValue = Array<JSONValue>
  public typealias AnyMappedObjectValue = OrderedDictionary<String, Any>
  public typealias AnyMappedArrayValue = Array<Any>

  case boolean (Bool)
  case string (String)
  indirect case array (Array<JSONValue>)
  indirect case object (OrderedDictionary<String, JSONValue>)
  case number (NSNumber)
  case null

  /// Initialize to `Null`.
  public init() {
    self = .null
  }

//  public init(_ dictionary: NSDictionary) {
//    self = dictionary.jsonValue
//  }

  /// Initialize to case `Array` using a `JSONValueConvertible` sequence
  public init<S:Sequence>(_ sequence: S) where S.Iterator.Element:JSONValueConvertible {
    self = .array(Array(sequence).map({$0.jsonValue}))
  }

//  public init(_ array: NSArray) {
//    self = array.jsonValue
//  }

  /// Initialize to case `Object` using a key-value collection
  public init<C:KeyValueCollection>(_ collection: C)
    where C.Iterator.Element == (key: C.Key, value: C.Value)
  {

    if let orderedDictionary = collection as? OrderedDictionary<String, JSONValue> {
      self = .object(orderedDictionary)
      return
    }

    var orderedDictionary: OrderedDictionary<String, JSONValue> = [:]

    for (key: key, value: value) in collection {
      guard let k = key as? StringValueConvertible else { continue }
      guard let v = value as? JSONValueConvertible else { continue }
      orderedDictionary[k.stringValue] = v.jsonValue
    }

    self = .object(orderedDictionary)
  }

  /// Initialize to case `Object` using a dictionary literal
  public init(dictionary: KeyValuePairs<StringValueConvertible,JSONValueConvertible>) {
    var objectValue: OrderedDictionary<String, JSONValue> = [:]
    for (k, v) in dictionary { objectValue[k.stringValue] = v.jsonValue }
    self = .object(objectValue)
  }

  public init(_ number: NSNumber) {
    self = .number(number)
  }

  public init(_ string: String) {
    self = .string(string)
  }

  public init(_ string: NSString) {
    self = .string(string as String)
  }

  public init(_ bool: Bool) {
    self = .boolean(bool)
  }

  public init(_ null: NSNull) {
    self = .null
  }

  public init(_ array: [JSONValue]) {
    self = .array(array)
  }

  public init(_ array: [JSONValueConvertible]) { //testJSONValueTypeComplex
    self = .array(array.map({$0.jsonValue}))
  }

  fileprivate func stringValueWithDepth(_ depth: Int) -> String {
    switch self {
      case .boolean, .null, .number, .string:
        return rawValue

      case .array(let a):
        let outerIndent = " " * (depth * 4)
        let innerIndent = outerIndent + " " * 4
        var string = "["
        let elements = a.map({$0.stringValueWithDepth(depth + 1)})
        switch elements.count {
          case 0: string += "]"
          case 1: string += "\n\(innerIndent)" + elements[0] + "\n\(outerIndent)]"
          default: string += "\n\(innerIndent)" + ",\n\(innerIndent)".join(elements) + "\n\(outerIndent)]"
        }
        return string

      case .object(let o):
        let outerIndent = " " * (depth * 4)
        let innerIndent = outerIndent + " " * 4
        var string = "{"
        let keyValuePairs = o.map({"\"\($0)\": \($1.stringValueWithDepth(depth + 1))"})
        switch keyValuePairs.count {
          case 0: string += "]"
          case 1: string += "\n\(innerIndent)" + keyValuePairs[0] + "\n\(outerIndent)}"
          default: string += "\n\(innerIndent)" + ",\n\(innerIndent)".join(keyValuePairs) + "\n\(outerIndent)}"
        }
        return string
    }
  }

  /// The formatted JSONValue string representation.
  public var prettyRawValue: String { return stringValueWithDepth(0) }

  /// An object representation of the value.
  public var anyObjectValue: AnyObject {
    switch self {
      case .boolean(let b): return NSNumber(value: b)
      case .null:           return NSNull()
      case .number(let n):  return n
      case .string(let s):  return s as NSString
      case .array(let a):   return a.map({$0.anyObjectValue}) as NSArray
      case .object(let o):
        let dictionary = NSMutableDictionary()
        for (key, value) in o {
          dictionary[key] = value.anyObjectValue
        }
        return dictionary
    }
  }

  /// The associated value.
  public var value: Any {
    switch self {
      case .boolean(let b): return b
      case .null:           return ()
      case .number(let n):  return n
      case .string(let s):  return s
      case .array(let a):   return a
      case .object(let o):  return o
    }
  }

  public var stringValue: String? { switch self { case .string(let s):  return s; default: return nil } }
  public var boolValue: Bool? { switch self { case .boolean(let b):  return b; default: return nil } }
  public var numberValue: NSNumber? { switch self { case .number(let n):  return n; default: return nil } }
  public var intValue: Int? { return numberValue?.intValue }
  public var int8Value: Int8? { return numberValue?.int8Value }
  public var int16Value: Int16? { return numberValue?.int16Value }
  public var int32Value: Int32? { return numberValue?.int32Value }
  public var int64Value: Int64? { return numberValue?.int64Value }
  public var uintValue: UInt? { return numberValue?.uintValue }
  public var uint8Value: UInt8? { return numberValue?.uint8Value }
  public var uint16Value: UInt16? { return numberValue?.uint16Value }
  public var uint32Value: UInt32? { return numberValue?.uint32Value }
  public var uint64Value: UInt64? { return numberValue?.uint64Value }
  public var floatValue: Float? { return numberValue?.floatValue }
  public var CGFloatValue: CGFloat? { if let d = doubleValue { return CGFloat(d) } else { return nil } }
  public var doubleValue: Double? { return numberValue?.doubleValue }
  public var CGSizeValue: CGSize? { stringValue == nil ? nil : NSCoder.cgSize(for: stringValue!) }
  public var UIEdgeInsetsValue: UIEdgeInsets? { stringValue == nil ? nil : NSCoder.uiEdgeInsets(for: stringValue!) }
  public var CGRectValue: CGRect? { stringValue == nil ? nil : NSCoder.cgRect(for: stringValue!) }
  public var CGPointValue: CGPoint? { stringValue == nil ? nil : NSCoder.cgPoint(for: stringValue!) }
  public var CGVectorValue: CGVector? { stringValue == nil ? nil : NSCoder.cgVector(for: stringValue!) }
  public var UIOffsetValue: UIOffset? { stringValue == nil ? nil : NSCoder.uiOffset(for: stringValue!) }
  public var CGAffineTransformValue: CGAffineTransform? { stringValue == nil ? nil : NSCoder.cgAffineTransform(for: stringValue!) }

  public var objectValue: ObjectValue? { switch self { case .object(let o):  return o; default: return nil } }
  public var mappedObjectValue: AnyMappedObjectValue? {
    guard let keyValuePairs = objectValue?.map({(key: $0, value: $1.mappedObjectValue ?? $1.mappedArrayValue ?? $1.value)}) else {
      return nil
    }
    return OrderedDictionary(keyValuePairs)
  }

  public var arrayValue: ArrayValue? { switch self { case .array(let a):  return a; default: return nil } }
  public var mappedArrayValue: AnyMappedArrayValue? {
    return arrayValue?.map({$0.mappedArrayValue ?? $0.mappedObjectValue ?? $0.value})
  }

  /// The value any dictionary keypaths expanded into deeper levels.
  public var inflatedValue: JSONValue {
    switch self {
      case .array(let a): return .array(a.map({$0.inflatedValue}))
      case .object(var o):
        func expand(keyPath: Stack<String>, leaf: ObjectValue) -> JSONValue {
          var keyPath = keyPath
          var leaf = leaf
          while let k = keyPath.pop() {
            leaf = [k:.object(leaf)]
          }
          return .object(leaf)
        }
        // Enumerate the list inflating each key
        for key in Array(o.keys.filter({$0 ~= "(?:\\w\\.)+\\w"})) {

          let keyComponents = key.split(separator: ".").map(String.init)
          let firstKey = keyComponents.first!
          let lastKey = keyComponents.last!
          let keyPath = Stack(keyComponents.dropFirst().dropLast())

          var value: Value

          // If our value is an array, we embed each value in the array and keep our value as an array
          if let valueArray = typeCast(o[key], Array<Value>.self) {
            value = valueArray.map({expand(keyPath: keyPath, leaf: [lastKey:$0.jsonValue])})
          }

            // Otherwise we embed the value
          else { value = expand(keyPath: keyPath, leaf: [lastKey: o[key]!]) }

          defer { _fixLifetime(value) }
          o.insert(value: value.jsonValue, forKey: firstKey, atIndex: o.index(forKey: key)!)
          o[key] = nil // Remove the compressed key-value entry
        }

        return .object(o)
      default: return self
    }
  }

  /// Returns the value at the specified index when self is Array or Object and index is valid, nil otherwise
  public subscript(idx: Int) -> JSONValue? {
    switch self {
      case .array(let a) where a.count > idx: return a[idx]
      case .object(let o) where o.count > idx: return o[idx].1
      default: return nil
    }
  }

  /// Returns the value for the specified key when self is Object and nil otherwise
  public subscript(key: String) -> JSONValue? {
    switch self { case .object(let o): return o[key]; default: return nil }
  }
}

extension JSONValue: JSONValueConvertible {
  public var jsonValue: JSONValue { return self }
}

// MARK: RawRepresentable
extension JSONValue: RawRepresentable {
  public var rawValue: String {
    switch self {
      case .boolean(let b): return String(describing: b)
      case .null:           return "null"
      case .number(let n):  return String(describing: n)
      case .string(let s):  return "\"\(s)\""
      case .array(let a):   return "[" + ",".join(a.map({$0.rawValue})) + "]"
      case .object(let o):  return "{" + ",".join(o.map({"\"\($0)\":\($1.rawValue)"})) + "}"
    }
  }
  public init?(rawValue: String) {
    guard rawValue.count > 0 else { return nil }
    let parser = JSONParser(string: rawValue, allowFragment: true)
    do {
      self = try parser.parse()
    } catch {
      loge("\(#fileID) \(#function) error: \(error)")
      return nil
    }
  }
}

// MARK: Equatable
extension JSONValue: Equatable {}
public func ==(lhs: JSONValue, rhs: JSONValue) -> Bool {
  switch (lhs, rhs) {
    case (.string(let ls), .string(let rs)) where ls == rs:
      return true
    case (.boolean(let lb), .boolean(let rb)) where lb == rb:
      return true
    case (.number(let ln), .number(let rn)) where ln.isEqual(to: rn):
      return true
    case (.null, .null):
      return true
    case (.array(let la), .array(let ra)) where la == ra:
      return true
    case (.object(let lo), .object(let ro)) where lo.count == ro.count && lo.keys.elementsEqual(ro.keys):
      let keys = Array(lo.keys)
      return keys.compactMap({lo[$0]}) == keys.compactMap({ro[$0]})
    default:
      return false
  }
}

// MARK: Hashable
extension JSONValue: Hashable {
  public var hashValue: Int { return rawValue.hashValue }
}

// MARK: BooleanLiteralConvertible
extension JSONValue: ExpressibleByBooleanLiteral {
  public init(booleanLiteral b: Bool) { self = .boolean(b) }
}

// MARK: NilLiteralConvertible
extension JSONValue: ExpressibleByNilLiteral {
  public init(nilLiteral: ()) { self = .null }
}

// MARK: IntegerLiteralConvertible
extension JSONValue: ExpressibleByIntegerLiteral {
  public init(integerLiteral value: Int) { self = .number(NSNumber(value: value)) }
}

// MARK: FloatLiteralConvertible
extension JSONValue: ExpressibleByFloatLiteral {
  public init(floatLiteral value: Double) { self = .number(NSNumber(value: value)) }
}

// MARK: ArrayLiteralConvertible
extension JSONValue: ExpressibleByArrayLiteral {
  public init(arrayLiteral elements: JSONValue...) { self = .array(elements) }
}

// MARK: StringLiteralConvertible
extension JSONValue: ExpressibleByStringLiteral {
  public init(stringLiteral s: String) { self = .string(s) }
  public init(extendedGraphemeClusterLiteral s: String) { self = .string(s) }
  public init(unicodeScalarLiteral s: String) { self = .string(s) }
}

// MARK: StringInterpolationConvertible
extension JSONValue/*: ExpressibleByStringInterpolation*/ {
  public init(stringInterpolation strings: JSONValue...) {
    self = .string(strings.reduce("", {$0 + ($1.stringValue ?? "")}))
  }
  public init<T>(stringInterpolationSegment expr: T) { self = .string(String(describing: expr)) }
}

// MARK: Streamable
extension JSONValue: TextOutputStreamable {
  public func write<Target:TextOutputStream>(to target: inout Target) { target.write(rawValue) }
}

extension JSONValue: ExpressibleByDictionaryLiteral {
  public init(dictionaryLiteral elements: (StringValueConvertible, JSONValueConvertible)...) {
    var objectValue: OrderedDictionary<String, JSONValue> = [:]
    for (k, v) in elements {
      objectValue[k.stringValue] = v.jsonValue
    }
    self = .object(objectValue)
  }
}

// MARK: Printable
extension JSONValue: CustomStringConvertible { public var description: String { return rawValue } }

// MARK: DebugPrintable
extension JSONValue: CustomDebugStringConvertible {
  public var debugDescription: String {
    var description: String = "\n"
    switch self {
      case .boolean(let b):
        description += "JSONValue.Boolean(\(b))"
      case .null:
        description += "JSONValue.Null"
      case .number(let n):
        description += "JSONValue.Number(\(n))"
      case .string(let s):
        description += "JSONValue.String(\(s))"
      case .array(let a):
        let c = a.count
        if c == 1 {
          description += "JSONValue.Array(1 item)\nitem:\n\t{\n\(a[0].debugDescription.indented(by: 8))\n\t}"
        }
        else {
          description += "JSONValue.Array(\(c) items)"
          if c > 0 {
            let items = ",\n".join(a.map({"\t{\n\($0.debugDescription.indented(by: 8))\n\t}"}))
            description += "\nitems: \(items))"
          }
        }

      case .object(let o):
        let c = o.count
        if c == 1 {
          let k = o.keys[0], v = o.values[0].debugDescription.indented(by: 8)
          description += "JSONValue.Object(1 entry)\nentry:\n\t\(k): {\n\(v)\n\t}"
        } else {
          description += "JSONValue.Object(\(c) entries)"
          if c > 0 {
            let entries = ",\n".join(o.map({"\t\($0): {\n\($1.debugDescription.indented(by: 8))\n\t}"}))
            description += "\nentries:\n\(entries)"
          }
        }
    }
    return description
  }
}

extension JSONValue: DataConvertible {
  public var data: Data { return rawValue.data as Data }
  public var prettyData: Data { return prettyRawValue.data as Data }
  public init?(data: Data) {
    guard let string = String(data: data) else { return nil }
    self.init(rawValue: string)
  }
}

private func typeCast<T,U>(_ t: T, _ u: U.Type) -> U? { t as? U }
private func typeCast<T,U>(_ t: T?, _ u: U.Type) -> U? { t != nil ? typeCast(t!, u) : nil }
