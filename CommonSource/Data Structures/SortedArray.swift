//
//  SortedArray.swift
//  MoonKit
//
//  Created by Jason Cardwell on 2/10/16.
//  Copyright © 2016 Jason Cardwell. All rights reserved.
//

import Foundation

private func describe<Element>(_ elements: UnsafePointer<Element>, count: Int, debug: Bool) -> String {
  guard count > 0 else { return "[]" }
  var result = "["
  var first = true
  for i in 0 ..< count {
    let element = elements[i]
    if first { first = false } else { result += ", " }
    if debug { debugPrint(element, terminator: "", to: &result) }
    else { print(element, terminator: "", to: &result) }
  }
  result += "]"
  return result
}

// MARK: - SortedArrayStorageHeader

private struct SortedArrayStorageHeader {
  var count = 0
  let capacity: Int
  init(capacity: Int) { self.capacity = capacity }
}

// MARK: - SortedArrayStorage

private final class SortedArrayStorage<Element: Comparable>: ManagedBuffer<SortedArrayStorageHeader, Element> {
  typealias Header = SortedArrayStorageHeader

  class func create(minimumCapacity: Int) -> SortedArrayStorage {
    return super.create(minimumCapacity: minimumCapacity) { Header(capacity: $0.capacity) } as! SortedArrayStorage
  }

  func sort() {
    withUnsafeMutablePointers {
      header, elements in
      var bufferPointer = UnsafeMutableBufferPointer<Element>(start: elements, count: header.pointee.count)
      bufferPointer.sort()
    }
  }

  deinit {
    withUnsafeMutablePointers {
      $1.deinitialize(count: $0.pointee.count)
      $0.deinitialize(count: 1)
    }
  }

  var elements: UnsafeMutablePointer<Element> { return withUnsafeMutablePointerToElements { $0 } }
}

// MARK: - SortedArrayBuffer

private struct SortedArrayBuffer<Element: Comparable>: _DestructorSafeContainer {
  typealias _Element = Element
  typealias Buffer = SortedArrayBuffer<Element>
  typealias BufferSlice = SortedArrayBufferSlice<Element>
  typealias Storage = SortedArrayStorage<Element>

  var indices: CountableRange<Int> {
    return CountableRange(uncheckedBounds: (lower: startIndex, upper: endIndex))
  }

  var storage: Storage
  let elements: UnsafeMutablePointer<Element>

  @inline(__always)
  mutating func isUniquelyReferenced() -> Bool { return Swift.isKnownUniquelyReferenced(&storage) }

  @inline(__always)
  mutating func isUniquelyReferencedWithCapacity(_ minimumCapacity: Int = 0) -> Bool {
    return isUniquelyReferenced() && storage.header.capacity >= minimumCapacity
  }

  var startIndex: Int { return 0 }
  var endIndex: Int { get { return storage.header.count } set { storage.header.count = newValue } }

  var count: Int { return endIndex }

  var capacity: Int { return storage.header.capacity }

  var identity: UnsafeRawPointer { return UnsafeRawPointer(elements) }

  init(storage: Storage) { self.storage = storage; elements = storage.elements }

  init(minimumCapacity: Int) { self = Buffer(storage: Storage.create(minimumCapacity: minimumCapacity)) }

  /// Create a clone of `buffer` with the specified `capacity`.
  init(buffer: Buffer, withCapacity capacity: Int) {
    let storage = Storage.create(minimumCapacity: capacity)
    storage.elements.initialize(from: buffer.elements, count: buffer.count)
    storage.header.count = buffer.count
    self = Buffer(storage: storage)
  }

  /// Create a clone of `buffer`.
  init(buffer: Buffer) { self = Buffer(buffer: buffer, withCapacity: buffer.capacity) }

  init<Source: Collection>(_ elements: Source) where Source.Iterator.Element == Element {
    let storage = Storage.create(minimumCapacity: numericCast(elements.count))
    _ = UnsafeMutableBufferPointer(start: storage.elements,
                                   count: elements.count).initialize(from: elements)
    storage.header.count = numericCast(elements.count)
    storage.sort()
    self = Buffer(storage: storage)
  }

  mutating func destroy(at i: Int) {
    if i &+ 1 == endIndex {
      (elements + i).deinitialize(count: 1)
    } else {
      (elements + i).assign(from: elements + (i &+ 1), count: endIndex &- i &- 1)
      (elements + (endIndex &- 1)).deinitialize(count: 1)
    }
    endIndex = endIndex &- 1
  }

  mutating func destroyAll() {
    guard count > 0 else { return }
    elements.deinitialize(count: count)
    endIndex = 0
  }

  func _customContainsEquatableElement(_ element: Element) -> Bool? {
    return Optional(_customIndexOfEquatableElement(element) != nil)
  }

  func _customIndexOfEquatableElement(_ element: Element) -> Int?? {
    let i = index(forInserting: element)
    return Optional(indices.contains(i) && elements[i] == element ? i : nil)
  }

  init<Source: Sequence>(_ elements: Source) where Source.Iterator.Element == Element {
    var buffer = Buffer(minimumCapacity: elements.underestimatedCount)
    for element in elements {
      if buffer.capacity == buffer.count { buffer = Buffer(buffer: buffer, withCapacity: buffer.count * 2) }
      buffer.append(element)
    }
    self = buffer
  }

  mutating func replaceSubrange<Source: Collection>(_ subRange: CountableRange<Int>, with newElements: Source)
    where Source.Iterator.Element == Element
  {
    removeSubrange(subRange)
    append(contentsOf: newElements)
  }

  mutating func _append(element: Element, possiblyAt requestedIndex: Int? = nil) {
    let i: Int

    switch (count, requestedIndex) {
    case (0, _),
         (_, 0) where elements[0] > element:
      i = 0

    case let (n, requestedIndex?) where requestedIndex == n && elements[n &- 1] <= element,
         let (n, requestedIndex?) where n > 2 && (1 ..< n &- 2).contains(requestedIndex)
           && elements[requestedIndex &- 1] <= element
           && elements[requestedIndex &+ 1] >= element:
      i = requestedIndex // FIXME: coverage 0

    default:
      i = index(forInserting: element)
    }

    (elements + (i &+ 1)).moveInitialize(from: elements + i, count: endIndex &- i)
    (elements + i).initialize(to: element)
    endIndex = endIndex &+ 1
  }

  mutating func append(_ element: Element) { _append(element: element) }

  mutating func append<Source: Collection>(contentsOf newElements: Source)
    where Source.Iterator.Element == Element
  {
    _ = UnsafeMutableBufferPointer(start: elements + endIndex,
                                   count: newElements.count).initialize(from: newElements)
    let 𝝙count: Int = numericCast(newElements.count)
    endIndex = endIndex &+ 𝝙count
    storage.sort()
  }

  func index(forInserting element: Element) -> Int {
    // Test for an edge value
    switch count {
    case 0,
         _ where elements[0] > element:
      return 0

    case let n where elements[n &- 1] <= element:
      return n

    default:
      break
    }

    // Helper for recursive binary search
    func search(range: CountableRange<Int>) -> Int {
      let pivot = range.count / 2 &+ range.lowerBound
      let pivotElement = elements[pivot]
      if pivotElement < element {
        guard pivot &+ 1 < range.upperBound else { return range.upperBound }
        return search(range: pivot &+ 1 ..< range.upperBound)
      } else if pivotElement > element {
        guard pivot > range.lowerBound else { return pivot }
        return search(range: range.lowerBound ..< pivot)
      } else {
        return pivot
      }
    }

    return search(range: indices)
  }

  /// Inserts `newElement` in sorted order regardless of the value of `i`
  mutating func insert(_ newElement: Element, at i: Index) { _append(element: newElement, possiblyAt: i) }

  mutating func removeSubrange(_ subRange: CountableRange<Index>) {
    switch subRange.count {
    case 0: return
    case 1: destroy(at: subRange.lowerBound)
    case let delta:
      (elements + subRange.lowerBound).deinitialize(count: delta)
      if endIndex &- subRange.upperBound > 0 {
        (elements + subRange.lowerBound).moveInitialize(from: elements + subRange.upperBound,
                                                        count: endIndex &- subRange.upperBound)
      }
      endIndex = endIndex &- delta
    }
  }
}

// MARK: RandomAccessCollection

extension SortedArrayBuffer: RandomAccessCollection {
  typealias Index = Int
  typealias SubSequence = BufferSlice

  func _failEarlyRangeCheck(_ index: Int, bounds: Range<Int>) { /* no-op for performance reasons. */ }
  func _failEarlyRangeCheck(_ range: Range<Int>, bounds: Range<Int>) { /* no-op for performance reasons. */ }

  @inline(__always) func distance(from start: Int, to end: Int) -> Int { return end &- start }

  @inline(__always) func index(after i: Int) -> Int { return i &+ 1 }
  @inline(__always) func index(before i: Int) -> Int { return i &- 1 }
  @inline(__always) func index(_ i: Int, offsetBy n: Int) -> Int { return i &+ n }
  @inline(__always) func index(_ i: Int, offsetBy n: Int, limitedBy limit: Int) -> Int? {
    switch (i &+ n, n < 0) {
    case (let iʹ, true) where iʹ >= limit, (let iʹ, false) where iʹ <= limit: return iʹ
    default: return nil
    }
  }

  @inline(__always) func formIndex(after i: inout Int) { i = i &+ 1 }
  @inline(__always) func formIndex(before i: inout Int) { i = i &- 1 }
  @inline(__always) func formIndex(_ i: inout Int, offsetBy n: Int) { i = i &+ n }
  @inline(__always) func formIndex(_ i: inout Int, offsetBy n: Int, limitedBy limit: Int) -> Bool {
    switch (i &+ n, n < 0) {
    case (let iʹ, true) where iʹ >= limit, (let iʹ, false) where iʹ <= limit: i = iʹ; return true
    default: return false
    }
  }
}

// MARK: Collection

extension SortedArrayBuffer: Collection {
  subscript(index: Int) -> Element {
    get {
      return elements[index]
    }
    set {
      elements[index] = newValue
      guard count > 1 else { return } // FIXME: coverage 0

      switch (index &- 1, index, index &+ 1) {
        case let (_, i, _) where i == 0 && elements[1] >= newValue:
          return
        case let (l, _, u) where u == endIndex && elements[l] <= newValue:
          return
        case let (l, _, u) where (2 ..< endIndex).contains(u)
              && (elements[l] ... elements[u]).contains(newValue):
        return
      default:
        storage.sort()
      }
    }
  }

  subscript(subRange: Range<Int>) -> SubSequence { SubSequence(buffer: self, indices: subRange) }
}

// MARK: CustomStringConvertible, CustomDebugStringConvertible

extension SortedArrayBuffer: CustomStringConvertible, CustomDebugStringConvertible {
  var description: String { return describe(elements, count: count, debug: false) }
  var debugDescription: String { return describe(elements, count: count, debug: true) }
}

// MARK: - SortedArrayBufferSlice

private struct SortedArrayBufferSlice<Element: Comparable>: _DestructorSafeContainer {
  typealias _Element = Element
  typealias Buffer = SortedArrayBuffer<Element>
  typealias BufferSlice = SortedArrayBufferSlice<Element>
  typealias Storage = SortedArrayStorage<Element>
  typealias Indices = CountableRange<Int>

  var storage: Storage
  let elements: UnsafeMutablePointer<Element>

  let startIndex: Int
  let endIndex: Int

  var count: Int { return endIndex &- startIndex } // Calculate since we are a slice

  var identity: UnsafeRawPointer { return UnsafeRawPointer(elements) }

  init(buffer: Buffer, indices: CountableRange<Int>) {
    storage = buffer.storage
    elements = storage.elements
    startIndex = indices.lowerBound
    endIndex = indices.upperBound
  }

  init(bufferSlice: BufferSlice, indices: CountableRange<Int>) {
    storage = bufferSlice.storage
    elements = storage.elements
    startIndex = indices.lowerBound
    endIndex = indices.upperBound
  }
}

// MARK: RandomAccessCollection

extension SortedArrayBufferSlice: RandomAccessCollection {
  typealias Index = Int
  typealias SubSequence = BufferSlice

  func _failEarlyRangeCheck(_ index: Int, bounds: Range<Int>) { /* no-op for performance reasons. */ }
  func _failEarlyRangeCheck(_ range: Range<Int>, bounds: Range<Int>) { /* no-op for performance reasons. */ }

  @inline(__always) func distance(from start: Int, to end: Int) -> Int { return end &- start }

  @inline(__always) func index(after i: Int) -> Int { return i &+ 1 }
  @inline(__always) func index(before i: Int) -> Int { return i &- 1 }
  @inline(__always) func index(_ i: Int, offsetBy n: Int) -> Int { return i &+ n }
  @inline(__always) func index(_ i: Int, offsetBy n: Int, limitedBy limit: Int) -> Int? {
    switch (i &+ n, n < 0) {
    case (let iʹ, true) where iʹ >= limit, (let iʹ, false) where iʹ <= limit: return iʹ
    default: return nil
    }
  }

  @inline(__always) func formIndex(after i: inout Int) { i = i &+ 1 }
  @inline(__always) func formIndex(before i: inout Int) { i = i &- 1 }
  @inline(__always) func formIndex(_ i: inout Int, offsetBy n: Int) { i = i &+ n }
  @inline(__always) func formIndex(_ i: inout Int, offsetBy n: Int, limitedBy limit: Int) -> Bool {
    switch (i &+ n, n < 0) {
    case (let iʹ, true) where iʹ >= limit, (let iʹ, false) where iʹ <= limit: i = iʹ; return true
    default: return false
    }
  }

  subscript(index: Int) -> Element { elements[index] }

  subscript(subRange: Range<Int>) -> SubSequence { SubSequence(bufferSlice: self, indices: subRange) }
}

// MARK: CustomStringConvertible, CustomDebugStringConvertible

extension SortedArrayBufferSlice: CustomStringConvertible, CustomDebugStringConvertible {
  var description: String { describe(elements.advanced(by: startIndex), count: count, debug: false) }
  var debugDescription: String { describe(elements.advanced(by: startIndex), count: count, debug: true) }
}

// MARK: - SortedArray

public struct SortedArray<Element: Comparable>: RandomAccessCollection, _DestructorSafeContainer {
  fileprivate typealias Buffer = SortedArrayBuffer<Element>
  fileprivate typealias Storage = SortedArrayStorage<Element>

  public typealias Index = Int
  public typealias _Element = Element
  public typealias SubSequence = SortedArraySlice<Element>
  public typealias Indices = CountableRange<Int>

  public var startIndex: Index { return 0 }

  public var endIndex: Index { return buffer.endIndex }

  public subscript(index: Index) -> Element {
    get { return buffer[index] }
    set { ensureUnique(); buffer[index] = newValue }
  }

  public subscript(subRange: Range<Int>) -> SubSequence {
    get { return SubSequence(buffer: buffer[subRange]) }
    set { replaceSubrange(subRange, with: newValue) }
  }

  fileprivate var buffer: Buffer

  fileprivate mutating func ensureUnique(withCapacity minimumCapacity: Int? = nil) {
    guard !(minimumCapacity == nil
      ? buffer.isUniquelyReferenced()
      : buffer.isUniquelyReferencedWithCapacity(minimumCapacity!)) else { return }
    buffer = minimumCapacity == nil
      ? Buffer(buffer: buffer)
      : Buffer(buffer: buffer, withCapacity: Swift.max(buffer.count * 2, minimumCapacity!))
  }

  /// The current number of elements
  public var count: Int { return buffer.count }

  /// The number of elements this collection can hold without reallocating
  public var capacity: Int { return buffer.capacity }

  public init(minimumCapacity: Int) { buffer = Buffer(minimumCapacity: minimumCapacity) }

  public init<Source: Sequence>(_ sourceElements: Source) where Source.Iterator.Element == Element {
    buffer = Buffer(sourceElements)
  }

  public init<Source: Collection>(_ sourceElements: Source) where Source.Iterator.Element == Element {
    buffer = Buffer(sourceElements)
  }

  fileprivate init(buffer: Buffer) { self.buffer = buffer }

  public func _failEarlyRangeCheck(_ index: Int, bounds: Range<Int>) { /* no-op for performance reasons. */ }
  public func _failEarlyRangeCheck(_ range: Range<Int>, bounds: Range<Int>) { /* no-op for performance reasons. */ }

  @inline(__always) public func distance(from start: Int, to end: Int) -> Int { return end &- start }
  @inline(__always) public func index(after i: Int) -> Int { return i &+ 1 }
  @inline(__always) public func index(before i: Int) -> Int { return i &- 1 }
  @inline(__always) public func index(_ i: Int, offsetBy n: Int) -> Int { return i &+ n }
  @inline(__always) public func index(_ i: Int, offsetBy n: Int, limitedBy limit: Int) -> Int? {
    switch (i &+ n, n < 0) {
    case (let iʹ, true) where iʹ >= limit, (let iʹ, false) where iʹ <= limit: return iʹ
    default: return nil
    }
  }

  @inline(__always) public func formIndex(after i: inout Int) { i = i &+ 1 }
  @inline(__always) public func formIndex(before i: inout Int) { i = i &- 1 }
  @inline(__always) public func formIndex(_ i: inout Int, offsetBy n: Int) { i = i &+ n }
  @inline(__always) public func formIndex(_ i: inout Int, offsetBy n: Int, limitedBy limit: Int) -> Bool {
    switch (i &+ n, n < 0) {
    case (let iʹ, true) where iʹ >= limit, (let iʹ, false) where iʹ <= limit: i = iʹ; return true
    default: return false
    }
  }
}

// MARK: RangeReplaceableCollection

extension SortedArray: RangeReplaceableCollection {

  /// Create an empty instance.
  public init() { self = SortedArray(buffer: Buffer(minimumCapacity: 0)) }

  /// A non-binding request to ensure `n` elements of available storage.
  ///
  /// This works as an optimization to avoid multiple reallocations of
  /// linear data structures like `Array`.  Conforming types may
  /// reserve more than `n`, exactly `n`, less than `n` elements of
  /// storage, or even ignore the request completely.
  public mutating func reserveCapacity(_ minimumCapacity: Int) { ensureUnique(withCapacity: minimumCapacity) }

  public mutating func replaceSubrange<Source: Collection>(_ subRange: ClosedRange<Int>, with newElements: Source)
    where Source.Iterator.Element == Element
  {
    replaceSubrange(Range(subRange), with: newElements)
  }

  public mutating func replaceSubrange<Source: Collection>(_ subRange: Range<Int>, with newElements: Source)
    where Source.Iterator.Element == Element
  {
    guard !(subRange.isEmpty && newElements.isEmpty) else { return }
    ensureUnique(withCapacity: count - subRange.count + numericCast(newElements.count))

    // Replace with uniqued collection
    buffer.replaceSubrange(subRange, with: newElements)
  }

  /// Append `element` to `self`.
  ///
  /// Applying `successor()` to the index of the new element yields
  /// `self.endIndex`.
  ///
  /// - Complexity: Amortized O(1).
  public mutating func append(_ element: Element) { ensureUnique(withCapacity: count &+ 1); buffer.append(element) }

  public mutating func append<Source: Sequence>(contentsOf newElements: Source)
    where Source.Iterator.Element == Element
  {
    append(contentsOf: Array(newElements))
  }

  /// Append the elements of `newElements` to `self`.
  ///
  /// - Complexity: O(*length of result*).
  public mutating func append<Source: Collection>(contentsOf newElements: Source)
    where Source.Iterator.Element == Element
  {
    let 𝝙count = newElements.count
    guard 𝝙count > 0 else { return }
    ensureUnique(withCapacity: count &+ 𝝙count)
    buffer.append(contentsOf: newElements)
  }

  /// Insert `newElement` at index `i`.
  ///
  /// Invalidates all indices with respect to `self`.
  ///
  /// - Complexity: O(`self.count`).
  public mutating func insert(_ newElement: Element, at index: Index) {
    ensureUnique(withCapacity: count &+ 1)
    buffer.insert(newElement, at: index)
  }

  /// Insert `newElements` at index `i`.
  ///
  /// Invalidates all indices with respect to `self`.
  ///
  /// - Complexity: O(`self.count + newElements.count`).
  public mutating func insert<Source: Collection>(contentsOf newElements: Source, at index: Index)
    where Source.Iterator.Element == Element
  {
    ensureUnique(withCapacity: count &+ numericCast(newElements.count))
    buffer.append(contentsOf: newElements)
  }

  /// Remove the element at index `i`.
  ///
  /// Invalidates all indices with respect to `self`.
  ///
  /// - Complexity: O(`self.count`).
  @discardableResult
  public mutating func remove(at index: Index) -> Element {
    ensureUnique()
    defer { buffer.destroy(at: index) }
    return buffer[index]
  }

  /// Remove the element at `startIndex` and return it.
  ///
  /// - Complexity: O(`self.count`)
  /// - Requires: `!self.isEmpty`.
  @discardableResult
  public mutating func removeFirst() -> Element { return remove(at: startIndex) }

  /// Remove the first `n` elements.
  ///
  /// - Complexity: O(`self.count`)
  /// - Requires: `n >= 0 && self.count >= n`.
  public mutating func removeFirst(_ n: Int) { removeSubrange(0 ..< n) }

  @discardableResult public mutating func removeLast() -> Element { return remove(at: endIndex - 1) }

  public mutating func removeLast(_ n: Int) { removeSubrange(endIndex - n ..< endIndex) }

  public mutating func removeSubrange(_ subRange: ClosedRange<Index>) { removeSubrange(Range(subRange)) }

  public mutating func removeSubrange(_ subRange: Range<Index>) {
    guard !subRange.isEmpty else { return }
    ensureUnique()
    buffer.removeSubrange(subRange)
  }

  public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
    guard keepCapacity else { if !isEmpty { buffer = Buffer(minimumCapacity: 0) }; return }
    guard buffer.isUniquelyReferenced() else { buffer = Buffer(minimumCapacity: capacity); return }
    buffer.destroyAll()
  }
}

// MARK: ExpressibleByArrayLiteral

extension SortedArray: ExpressibleByArrayLiteral {
  public init(arrayLiteral elements: Element...) { buffer = Buffer(elements) }
}

// MARK: CustomStringConvertible, CustomDebugStringConvertible

extension SortedArray: CustomStringConvertible, CustomDebugStringConvertible {
  public var description: String { return buffer.description }
  public var debugDescription: String { return buffer.debugDescription }
}

// MARK: Equatable

extension SortedArray: Equatable {
  public static func ==(lhs: SortedArray<Element>, rhs: SortedArray<Element>) -> Bool {
    guard !(lhs.buffer.identity == rhs.buffer.identity && lhs.count == rhs.count) else { return true }
    for (v1, v2) in zip(lhs, rhs) where v1 != v2 { return false }
    return lhs.count == rhs.count
  }
}

// MARK: - SortedArraySlice

/// A hash-based set of elements that preserves element order.
public struct SortedArraySlice<Element: Comparable>: RangeReplaceableCollection, RandomAccessCollection, _DestructorSafeContainer {
  public init() {
    fatalError("\(#fileID) \(#function) Unexpected invocation.")
  }

  fileprivate typealias Buffer = SortedArrayBuffer<Element>
  fileprivate typealias BufferSlice = SortedArrayBufferSlice<Element>
  fileprivate typealias Storage = SortedArrayStorage<Element>

  public typealias Index = Int
  public typealias _Element = Element
  public typealias SubSequence = SortedArraySlice<Element>

  public var startIndex: Index { return buffer.startIndex }

  public var endIndex: Index { return buffer.endIndex }

  public subscript(index: Index) -> Element { return buffer[index] }

  public subscript(subRange: Range<Int>) -> SubSequence { return SubSequence(buffer: buffer[subRange]) }

  fileprivate var buffer: BufferSlice

  /// The current number of elements
  public var count: Int { return buffer.count }

  public var indices: CountableRange<Int> { return buffer.indices }

  fileprivate init(buffer: BufferSlice) { self.buffer = buffer }

  public func _failEarlyRangeCheck(_ index: Int, bounds: Range<Int>) { /* no-op for performance reasons. */ }
  public func _failEarlyRangeCheck(_ range: Range<Int>, bounds: Range<Int>) { /* no-op for performance reasons. */ }

  @inline(__always) public func distance(from start: Int, to end: Int) -> Int { return end &- start }
  @inline(__always) public func index(after i: Int) -> Int { return i &+ 1 }
  @inline(__always) public func index(before i: Int) -> Int { return i &- 1 }
  @inline(__always) public func index(_ i: Int, offsetBy n: Int) -> Int { return i &+ n }
  @inline(__always) public func index(_ i: Int, offsetBy n: Int, limitedBy limit: Int) -> Int? {
    switch (i &+ n, n < 0) {
    case (let iʹ, true) where iʹ >= limit, (let iʹ, false) where iʹ <= limit: return iʹ
    default: return nil
    }
  }

  @inline(__always) public func formIndex(after i: inout Int) { i = i &+ 1 }
  @inline(__always) public func formIndex(before i: inout Int) { i = i &- 1 }
  @inline(__always) public func formIndex(_ i: inout Int, offsetBy n: Int) { i = i &+ n }
  @inline(__always) public func formIndex(_ i: inout Int, offsetBy n: Int, limitedBy limit: Int) -> Bool {
    switch (i &+ n, n < 0) {
    case (let iʹ, true) where iʹ >= limit, (let iʹ, false) where iʹ <= limit: i = iʹ; return true
    default: return false
    }
  }
}

// MARK: CustomStringConvertible, CustomDebugStringConvertible

extension SortedArraySlice: CustomStringConvertible, CustomDebugStringConvertible {
  public var description: String { return buffer.description }
  public var debugDescription: String { return buffer.debugDescription }
}

// MARK: Equatable

extension SortedArraySlice: Equatable {
  public static func ==(lhs: SortedArraySlice<Element>, rhs: SortedArraySlice<Element>) -> Bool {
    guard !(lhs.buffer.identity == rhs.buffer.identity && lhs.indices == rhs.indices) else { return true }
    for (v1, v2) in zip(lhs, rhs) where v1 != v2 { return false }
    return lhs.count == rhs.count
  }
}
