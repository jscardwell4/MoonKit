//
//  KeyValueCollection.swift
//  MoonKit
//
//  Created by Jason Cardwell on 5/9/16.
//  Copyright © 2016 Jason Cardwell. All rights reserved.
//

import Foundation

public typealias KeyValuePair<Key: Hashable, Value> = (key: Key, value: Value)

public func keyValuePair<Key: Hashable, Value>(
  _ pair: (Key, Value)) -> KeyValuePair<Key, Value>
{
  return (key: pair.0, value: pair.1)
}

public func unnamedKeyValuePair<Key: Hashable, Value>(
  _ pair: KeyValuePair<Key, Value>) -> (Key, Value)
{
  return (pair.key, pair.value)
}

// MARK: - KeyValueBase

public protocol KeyValueBase: Collection {
  associatedtype Key: Hashable
  associatedtype Value
  associatedtype Element = KeyValuePair<Key, Value>
  associatedtype LazyKeys: LazyCollectionProtocol
  associatedtype LazyValues: LazyCollectionProtocol

  subscript(key: Key) -> Value? { get }
  subscript(index: Index) -> KeyValuePair<Key, Value> { get }

  func index(forKey key: Key) -> Index?
  func value(forKey key: Key) -> Value?

  var keys: LazyKeys { get }
  var values: LazyValues { get }
}

public extension KeyValueBase {
  var prettyDescription: String {
    var result = "["

    var first = true

    for (key, value) in zip(keys, values) {
      if first {
        first = false
        result += "\n  "
      } else {
        result += ",\n  "
      }

      let keyDescription = (key as? PrettyPrint)?.prettyDescription ?? "\(key)"
      let valueDescription = (value as? PrettyPrint)?.prettyDescription ?? "\(value)"

      if CharacterSet(charactersIn: valueDescription).isDisjoint(with: .newlines) {
        result += "\(keyDescription): \(valueDescription)"
      } else {
        result += "\(keyDescription): {\n\(valueDescription.indented(by: 4))\n  }"
      }
    }

    return result
  }
}

public extension KeyValueBase where Self.Iterator.Element == KeyValuePair<Key, Value> {
  func formattedDescription(indent: Int = 0) -> String {
    var components: [String] = []
    var keys: [Key] = []
    var values: [Value] = []
    for (key, value) in self { keys.append(key); values.append(value) }

    let keyDescriptions = keys.map { "\($0)" }

    let maxKeyLength = keyDescriptions.reduce(0) {
      let n = $1.count
      return $0 > n ? $0 : n
    }

    let indentation = " " * (indent * 4)
    for (key, value) in zip(keyDescriptions, values) {
      let keyString = "\(indentation)\(key): "
      var valueString: String
      var valueComponents = "\n".split(regex: ~/"\(value)")
      if valueComponents.count > 0 {
        valueString = valueComponents.remove(at: 0)
        if valueComponents.count > 0 {
          let spacer = "\t" * (Int(floor(Double(maxKeyLength + 1) / 4.0)) - 1)
          let subIndentString = "\n\(indentation)\(spacer)"
          valueString += subIndentString + subIndentString.join(valueComponents)
        }
      } else { valueString = "nil" }
      components += ["\(keyString)\(valueString)"]
    }
    return "\n".join(components)
  }
}

// MARK: - MutableKeyValueBase

public protocol MutableKeyValueBase: KeyValueBase {
  subscript(key: Key) -> Value? { get set }

  mutating func insert(value: Value, forKey key: Key)

  @discardableResult mutating func remove(at index: Index) -> KeyValuePair<Key, Value>
  @discardableResult mutating func removeValue(forKey key: Key) -> Value?

  @discardableResult mutating func updateValue(_ value: Value, forKey key: Key) -> Value?

  init<S: Sequence>(_ elements: S) where S.Iterator.Element == Element
}

// MARK: - KeyValueCollection

public protocol KeyValueCollection: KeyValueBase {
  associatedtype LazyKeys = LazyMapCollection<Self, Key>
  associatedtype LazyValues = LazyMapCollection<Self, Value>
}

public extension KeyValueCollection
where Self.Iterator.Element == KeyValuePair<Key, Value>
{
  var keys: LazyMapCollection<Self, Key> { return lazy.map { $0.key } }
  var values: LazyMapCollection<Self, Value> { return lazy.map { $0.value } }
}

// MARK: - MutableKeyValueCollection

public protocol MutableKeyValueCollection: MutableKeyValueBase, KeyValueCollection {}

// MARK: - KeyValueBidirectionalCollection

public protocol KeyValueBidirectionalCollection: KeyValueBase, BidirectionalCollection {
  associatedtype LazyKeys: BidirectionalCollection = LazyMapCollection<Self, Key>
  associatedtype LazyValues: BidirectionalCollection = LazyMapCollection<Self, Value>
  var keys: LazyKeys { get }
  var values: LazyValues { get }
}

public extension KeyValueBidirectionalCollection
  where Self.Iterator.Element == KeyValuePair<Key, Value>
{
  var keys: LazyMapCollection<Self, Key> { return lazy.map { $0.key } }
  var values: LazyMapCollection<Self, Value> { return lazy.map { $0.value } }
}

// MARK: - MutableKeyValueBidirectionalCollection

public protocol MutableKeyValueBidirectionalCollection: MutableKeyValueBase,
  KeyValueBidirectionalCollection {}

// MARK: - KeyValueRandomAccessCollection

public protocol KeyValueRandomAccessCollection: KeyValueBase, RandomAccessCollection {
  associatedtype LazyKeys: RandomAccessCollection = LazyMapCollection<Self, Key>
  associatedtype LazyValues: RandomAccessCollection = LazyMapCollection<Self, Value>
  var keys: LazyKeys { get }
  var values: LazyValues { get }
}

public extension KeyValueRandomAccessCollection
  where Self.Iterator.Element == KeyValuePair<Key, Value>
{
  var keys: LazyMapCollection<Self, Key> { return lazy.map { $0.key } }
  var values: LazyMapCollection<Self, Value> { return lazy.map { $0.value } }
}

// MARK: - MutableKeyValueRandomAccessCollection

public protocol MutableKeyValueRandomAccessCollection: MutableKeyValueBase,
  KeyValueRandomAccessCollection {}

// MARK: - Dictionary + KeyValueCollection

extension Dictionary: KeyValueCollection {}

// MARK: - Dictionary + MutableKeyValueCollection

extension Dictionary: MutableKeyValueCollection {
  public init<S>(_ elements: S) where S : Sequence, Self.Element == S.Element {
    self.init()
    for (key, value) in elements {
      self[key] = value
    }
  }
  
  public mutating func insert(value: Value, forKey key: Key) {
    self[key] = value
  }

  public func value(forKey key: Key) -> Value? {
    return self[key]
  }
}
