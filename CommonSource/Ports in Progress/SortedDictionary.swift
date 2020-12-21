//
//  SortedDictionary.swift
//  MoonKit
//
//  Created by Jason Cardwell on 12/19/20.
//  Copyright © 2020 Moondeer Studios. All rights reserved.
//
import Foundation

// MARK: - SortedDictionary

/// A hash-based mapping from `Key` to `Value` instances that preserves elment order.
public struct SortedDictionary<Key: Hashable & Comparable, Value>: RandomAccessCollection,
                                                                   _DestructorSafeContainer
{
  fileprivate typealias Storage = OrderedDictionaryStorage<Key, Value>
  fileprivate typealias Buffer = OrderedDictionaryBuffer<Key, Value>

  public typealias Index = Int
  public typealias Element = (key: Key, value: Value)
  public typealias _Element = Element
  public typealias SubSequence = OrderedDictionarySlice<Key, Value>

  public var startIndex: Int { buffer.startIndex }
  public var endIndex: Int { buffer.endIndex }

  public subscript(position: Int) -> Element {
    get { return buffer[position] }
    set {
      _reserveCapacity(capacity)
      buffer.remove(at: position)
      insert(value: newValue.value, forKey: newValue.key)
    }
  }

  public subscript(subRange: Range<Index>) -> SubSequence {
    return SubSequence(buffer: buffer[subRange.lowerBound..<subRange.upperBound])
  }

  fileprivate var buffer: Buffer

  public init(minimumCapacity: Int) { self = SortedDictionary(buffer: Buffer(minimumCapacity: minimumCapacity)) }

  fileprivate init(buffer: Buffer) { self.buffer = buffer }

  public var indices: CountableRange<Index> {
    return CountableRange(uncheckedBounds: (lower: startIndex, upper: endIndex))
  }

  public var count: Int { return buffer.count }
  public var capacity: Int { return buffer.capacity }

  public init<Source: Sequence>(_ elements: Source) where Source.Iterator.Element == Element {
    self = SortedDictionary(buffer: Buffer(elements.sorted(by: { $0.key < $1.key })))
  }

  public init<Source: Collection>(_ elements: Source) where Source.Iterator.Element == Element {
    self = SortedDictionary(buffer: Buffer(elements.sorted(by: { $0.key < $1.key })))
  }

  public func _failEarlyRangeCheck(_ index: Index, bounds: Range<Index>) { /* no-op for performance reasons. */ }
  public func _failEarlyRangeCheck(_ range: Range<Index>, bounds: Range<Index>) { /* no-op for performance reasons. */ }

  @inline(__always)
  public func distance(from start: Index, to end: Index) -> Int { return end &- start }

  @inline(__always)
  public func index(after i: Index) -> Index { return i &+ 1 }
  @inline(__always)
  public func index(before i: Index) -> Index { return i &- 1 }
  @inline(__always)
  public func index(_ i: Index, offsetBy n: Int) -> Index { return i &+ n }
  @inline(__always)
  public func index(_ i: Index, offsetBy n: Int, limitedBy limit: Index) -> Index? {
    switch (i &+ n, n < 0) {
      case (let iʹ, true) where iʹ >= limit, (let iʹ, false) where iʹ <= limit: return iʹ
      default: return nil
    }
  }

  @inline(__always)
  public func formIndex(after i: inout Index) { i = i &+ 1 }
  @inline(__always)
  public func formIndex(before i: inout Index) { i = i &- 1 }
  @inline(__always)
  public func formIndex(_ i: inout Index, offsetBy n: Int) { i = i &+ n }
  @inline(__always)
  public func formIndex(_ i: inout Index, offsetBy n: Int, limitedBy limit: Index) -> Bool {
    switch (i &+ n, n < 0) {
      case (let iʹ, true) where iʹ >= limit, (let iʹ, false) where iʹ <= limit: i = iʹ; return true
      default: return false
    }
  }

  fileprivate mutating func _reserveCapacity(_ minimumCapacity: Int) {
    guard buffer.requestUniqueBuffer(minimumCapacity: minimumCapacity) == nil else { return }
    buffer = buffer.capacity < minimumCapacity
      ? OrderedDictionaryBuffer<Key, Value>(buffer: buffer, withCapacity: minimumCapacity)
      : OrderedDictionaryBuffer<Key, Value>(buffer: buffer)
  }
}

// MARK: SortedDictionary where Value:Equatable

public extension SortedDictionary where Value: Equatable {
  func _customContainsEquatableElement(_ element: Element) -> Bool? { return element.1 == self[element.0] }

  func _customIndexOfEquatableElement(_ element: Element) -> Index? {
    return buffer.index(for: element.key)
  }
}

// MARK: ExpressibleByDictionaryLiteral

extension SortedDictionary: ExpressibleByDictionaryLiteral {
  public init(dictionaryLiteral elements: (Key, Value)...) { self = SortedDictionary(elements.map(keyValuePair)) }
}

// MARK: MutableKeyValueRandomAccessCollection

extension SortedDictionary: MutableKeyValueRandomAccessCollection {
  public mutating func insert(value: Value, forKey key: Key) {
    guard !buffer.contains(key: key) else { updateValue(value, forKey: key); return }

    _reserveCapacity(Buffer.minimumCapacityFor(count &+ 1))

    let position: Int

    switch count {
      case 0:
        position = 0
      case let n where buffer.key(at: n &- 1) <= key:
        position = n
      default:
        // Recursive binary search for key insertion point.
        func search(range: CountableRange<Int>) -> Int {
          let pivot = range.count / 2 &+ range.lowerBound
          let keyʹ = buffer.key(at: pivot)
          if keyʹ < key {
            guard pivot &+ 1 < range.upperBound else { return range.upperBound }
            return search(range: pivot &+ 1..<range.upperBound)
          } else if keyʹ > key {
            guard pivot > range.lowerBound else { return pivot }
            return search(range: range.lowerBound..<pivot)
          } else {
            return pivot
          }
        }
        position = search(range: 0..<count)
    }

    buffer.insert((key: key, value: value), at: position)
  }

  @discardableResult
  public mutating func updateValue(_ value: Value, forKey key: Key) -> Value? {
    let found = buffer.contains(key: key)

    let minCapacity = found ? capacity : Buffer.minimumCapacityFor(buffer.count + 1)

    _reserveCapacity(minCapacity)

    if found { return buffer.update(element: (key, value)).1 }
    else { insert(value: value, forKey: key); return nil }
  }

  /// Removes the value associated with `key` and returns it. Returns `nil` if `key` is not present.
  @discardableResult
  public mutating func removeValue(forKey key: Key) -> Value? {
    guard let index = index(forKey: key) else { return nil }
    return remove(at: index).1
  }

  /// Returns the index of `key` or `nil` if `key` is not present.
  public func index(forKey key: Key) -> Index? { buffer.index(for: key) }

  /// Returns the value associated with `key` or `nil` if `key` is not present.
  public func value(forKey key: Key) -> Value? {
    guard let index = index(forKey: key) else { return nil }
    return buffer[index].value
  }

  /// Access the value associated with the given key.
  /// Reading a key that is not present in self yields nil. Writing nil as the value for a given key erases that
  /// key from self.
  /// - attention: Is there a conflict when `Key` = `Index` or do the differing return types resolve ambiguity?
  public subscript(key: Key) -> Value? {
    get { return value(forKey: key) }
    set {
      switch (newValue, buffer.contains(key: key)) {
        case (let value?, true):
          _reserveCapacity(capacity)
          buffer.update(element: (key, value))
        case (let value?, false):
          insert(value: value, forKey: key)
        case (nil, true):
          _reserveCapacity(capacity)
          _ = buffer.remove(key: key)
        case (nil, false):
          break
      }
    }
  }
}

// MARK: RangeReplaceableCollection

public extension SortedDictionary /*: RangeReplaceableCollection */ {
  /// Create an empty instance.
  init() { self = SortedDictionary(buffer: Buffer(minimumCapacity: 0)) }

  /// A non-binding request to ensure `n` elements of available storage.
  ///
  /// This works as an optimization to avoid multiple reallocations of
  /// linear data structures like `Array`.  Conforming types may
  /// reserve more than `n`, exactly `n`, less than `n` elements of
  /// storage, or even ignore the request completely.
  mutating func reserveCapacity(_ minimumCapacity: Int) { _reserveCapacity(minimumCapacity) }

  /// Replace the given `subRange` of elements with `newElements`.
  ///
  /// Invalidates all indices with respect to `self`.
  ///
  /// - Complexity: O(`subRange.count`) if
  ///   `subRange.endIndex == self.endIndex` and `newElements.isEmpty`,
  ///   O(`self.count` + `newElements.count`) otherwise.
  mutating func replaceSubrange<Source: Collection>(_ subRange: Range<Index>, with newElements: Source)
    where Source.Iterator.Element == Element
  {
    guard !(subRange.isEmpty && newElements.isEmpty) else { return }
    let requiredCapacity = count - subRange.count + numericCast(newElements.count)

    _reserveCapacity(Buffer.minimumCapacityFor(requiredCapacity))

    buffer.removeSubrange(subRange.lowerBound..<subRange.upperBound)
    for (key, value) in newElements { insert(value: value, forKey: key) }
  }

  /// Append `x` to `self`.
  ///
  /// Applying `successor()` to the index of the new element yields
  /// `self.endIndex`.
  ///
  /// - Complexity: Amortized O(1).
  mutating func append(_ element: Element) {
    guard !buffer.contains(key: element.0) else { return }
    insert(value: element.value, forKey: element.key)
  }

  /// Append the elements of `newElements` to `self`.
  ///
  /// - Complexity: O(*length of result*).
  mutating func append<Source: Sequence>(contentsOf newElements: Source)
    where Source.Iterator.Element == Element
  {
    for element in newElements { append(element) }
  }

  /// Append the elements of `newElements` to `self`.
  ///
  /// - Complexity: O(*length of result*).
  mutating func append<Source: Collection>(contentsOf newElements: Source)
    where Source.Iterator.Element == Element
  {
    let newElementsCount: Int = numericCast(newElements.count)
    guard newElementsCount > 0 else { return }
    _reserveCapacity(Buffer.minimumCapacityFor(count + newElementsCount))
    for element in newElements { append(element) }
  }

  /// Remove the element at index `index`.
  ///
  /// Invalidates all indices with respect to `self`.
  ///
  /// - Complexity: O(`self.count`).
  @discardableResult
  mutating func remove(at index: Index) -> Element {
    _reserveCapacity(capacity)
    return buffer.remove(at: index)
  }

  /// Remove the element at `startIndex` and return it.
  ///
  /// - Complexity: O(`self.count`)
  /// - Requires: `!self.isEmpty`.
  mutating func removeFirst() -> Element {
    return remove(at: startIndex)
  }

  /// Remove the first `n` elements.
  ///
  /// - Complexity: O(`self.count`)
  /// - Requires: `n >= 0 && self.count >= n`.
  mutating func removeFirst(_ n: Int) {
    _reserveCapacity(capacity)
    buffer.removeFirst(n)
  }

  /// Remove the indicated `subRange` of elements.
  ///
  /// Invalidates all indices with respect to `self`.
  ///
  /// - Complexity: O(`self.count`).
  mutating func removeSubrange(_ subRange: Range<Index>) {
    guard subRange.count > 0 else { return }
    _reserveCapacity(capacity)
    buffer.removeSubrange(Range<Int>(uncheckedBounds: (lower: subRange.lowerBound,
                                                       upper: subRange.upperBound)))
  }

  /// Remove all elements.
  ///
  /// Invalidates all indices with respect to `self`.
  ///
  /// - parameter keepCapacity: If `true`, is a non-binding request to
  ///    avoid releasing storage, which can be a useful optimization
  ///    when `self` is going to be grown again.
  ///
  /// - Complexity: O(`self.count`).
  mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
    guard count > 0 else { return }
    _reserveCapacity(capacity)
    buffer.removeAll(keepingCapacity: keepCapacity)
  }
}

// MARK: CustomStringConvertible, CustomDebugStringConvertible

extension SortedDictionary: CustomStringConvertible, CustomDebugStringConvertible {
  public var description: String {
    guard count > 0 else { return "[:]" }

    var result = "["
    var first = true
    for (key, value) in self {
      if first { first = false } else { result += ", " }
      print(key, terminator: "", to: &result)
      result += ": "
      print(value, terminator: "", to: &result)
    }
    result += "]"
    return result
  }

  public var debugDescription: String {
    guard count > 0 else { return "[:]" }

    var result = "["
    var first = true
    for (key, value) in self {
      if first { first = false } else { result += ", " }
      debugPrint(key, terminator: "", to: &result)
      result += ": "
      debugPrint(value, terminator: "", to: &result)
    }
    result += "]"
    return result
  }
}

// MARK: JSONValueConvertible

extension SortedDictionary: JSONValueConvertible {
  public var jsonValue: JSONValue {
    var orderedDictionary = OrderedDictionary<String, JSONValue>()
    for (key: key, value: value) in self {
      guard let k = key as? StringValueConvertible else { continue }
      guard let v = value as? JSONValueConvertible else { continue }
      orderedDictionary[k.stringValue] = v.jsonValue
    }
    return .object(orderedDictionary)
  }
}

// MARK: Equatable

extension SortedDictionary: Equatable {
  public static func ==(lhs: SortedDictionary<Key, Value>, rhs: SortedDictionary<Key, Value>) -> Bool {
    guard !(lhs.buffer.identity == rhs.buffer.identity && lhs.count == rhs.count) else { return true }
    for ((key: k1, value: _), (key: k2, value: _)) in zip(lhs, rhs) where k1 != k2 { return false }
    return lhs.count == rhs.count
  }
}

public extension SortedDictionary where Value: Equatable {
  static func ==(lhs: SortedDictionary<Key, Value>, rhs: SortedDictionary<Key, Value>) -> Bool {
    guard !(lhs.buffer.identity == rhs.buffer.identity && lhs.count == rhs.count) else { return true }
    for ((key: k1, value: v1), (key: k2, value: v2)) in zip(lhs, rhs) where k1 != k2 || v1 != v2 { return false }
    return lhs.count == rhs.count
  }
}
