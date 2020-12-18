//
//  WeakArray.swift
//  MoonKit
//
//  Created by Jason Cardwell on 2/5/16.
//  Copyright © 2016 Jason Cardwell. All rights reserved.
//

import Foundation

fileprivate func describe<Element:AnyObject>(_ elements: UnsafeMutablePointer<Weak<Element>>, count: Int, debug: Bool) -> String {
  guard count > 0 else { return "[]" }
  var result = "["
  var first = true
  for index in 0 ..< count {
    if first { first = false } else { result += ", " }
    switch elements[index].reference {
      case nil: print("nil", terminator: "", to: &result)
      case let element? where debug: debugPrint(element, terminator: "", to: &result)
      case let element?: print(element, terminator: "", to: &result)
    }
  }
  result += "]"
  return result
}

fileprivate final class WeakArrayStorage<WeakElement:AnyObject>: ManagedBuffer<(count: Int, capacity: Int), Weak<WeakElement>> {

  class func create(minimumCapacity: Int) -> WeakArrayStorage {
    return super.create(minimumCapacity: minimumCapacity) { (count: 0, capacity: $0.capacity) } as! WeakArrayStorage
  }

  var elements: UnsafeMutablePointer<Weak<WeakElement>> { return withUnsafeMutablePointerToElements {$0} }

  deinit {
    withUnsafeMutablePointers {
      $1.deinitialize(count: $0.pointee.count)
      $0.deinitialize()
    }
  }
}

fileprivate struct WeakArrayBuffer<WeakElement:AnyObject>: _DestructorSafeContainer {

  typealias Element = WeakElement?
  typealias _Element = Element
  typealias Buffer = WeakArrayBuffer<WeakElement>
  typealias BufferSlice = WeakArrayBufferSlice<WeakElement>
  typealias Storage = WeakArrayStorage<WeakElement>
  typealias StorageElement = Weak<WeakElement>

  var storage: Storage
  let elements: UnsafeMutablePointer<StorageElement>

  @inline(__always)
  mutating func isUniquelyReferenced() -> Bool { return Swift.isKnownUniquelyReferenced(&storage) }

  @inline(__always)
  mutating func requestUniqueBuffer(minimumCapacity: Int = 0) -> Buffer? {
    return isUniquelyReferenced() && capacity >= minimumCapacity ? self : nil
  }

  var startIndex: Int { return 0 }
  var endIndex: Int { get { return storage.header.count } set { storage.header.count = newValue } }

  var count: Int { return endIndex }
  var capacity: Int { return storage.capacity }

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

  init<Source:Collection>(_ elements: Source) where Source.Iterator.Element == StorageElement {
    let storage = Storage.create(minimumCapacity: numericCast(elements.count))
    storage.elements.initialize(from: elements)
    storage.header.count = numericCast(elements.count)
    self = Buffer(storage: storage)
  }

  mutating func destroy(at i: Int) {
    if i + 1 == endIndex { (elements + i).deinitialize() }
    else { (elements + i).assign(from: (elements + i + 1), count: endIndex - i - 1); (elements + endIndex - 1).deinitialize() }
    endIndex = endIndex &- 1
  }

  mutating func destroyAll() {
    guard !isEmpty else { return }
    elements.deinitialize(count: endIndex)
    endIndex = 0
  }

  mutating func replaceSubrange<Source:Collection>(_ subRange: CountableRange<Int>, with newElements: Source)
    where Source.Iterator.Element == StorageElement
  {
    removeSubrange(subRange)
    insert(contentsOf: newElements, at: subRange.lowerBound)
  }

  mutating func append(_ element: StorageElement) { (elements + endIndex).initialize(to: element); endIndex = endIndex &+ 1 }


  mutating func append<Source:Collection>(contentsOf newElements: Source) where Source.Iterator.Element == StorageElement {
    (elements + endIndex).initialize(from: newElements)
    endIndex = endIndex &+ numericCast(newElements.count)
  }

  mutating func insert(_ newElement: StorageElement, at i: Index) {
    (elements + i + 1).moveInitialize(from: (elements + i), count: endIndex - i)
    (elements + i).initialize(to: newElement)
    endIndex = endIndex &+ 1
  }

  mutating func insert<Source:Collection>(contentsOf newElements: Source, at i: Index)
    where Source.Iterator.Element == StorageElement
  {
    guard !newElements.isEmpty else { return }
    let 𝝙elements: Int = numericCast(newElements.count)

    (elements + (i &+ 𝝙elements)).moveInitialize(from: elements + i, count: endIndex &- i)
    (elements + i).initialize(from: newElements)
    endIndex = endIndex &+ 𝝙elements
  }

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

  subscript(index: Int) -> Element { get { return elements[index].reference } set { elements[index] = Weak(newValue) } }
  subscript(subRange: Range<Int>) -> SubSequence { return self[CountableRange(subRange)] }
  subscript(subRange: CountableRange<Int>) -> SubSequence { return SubSequence(buffer: self, indices: subRange) }

}

// MARK: - RandomAccessCollection
extension WeakArrayBuffer: RandomAccessCollection {
  typealias Index = Int
  typealias Indices = CountableRange<Int>
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

// MARK: CustomStringConvertible, CustomDebugStringConvertible
extension WeakArrayBuffer: CustomStringConvertible, CustomDebugStringConvertible {
  var description: String { return describe(elements, count: count, debug: false) }
  var debugDescription: String { return describe(elements, count: count, debug: true) }
}

// MARK: - WeakArrayBufferSlice
fileprivate struct WeakArrayBufferSlice<WeakElement:AnyObject>: _DestructorSafeContainer {
  typealias Element = WeakElement?
  typealias _Element = Element
  typealias Buffer = WeakArrayBuffer<WeakElement>
  typealias BufferSlice = WeakArrayBufferSlice<WeakElement>
  typealias Storage = WeakArrayStorage<WeakElement>
  typealias StorageElement = Weak<WeakElement>


  var storage: Storage
  let elements: UnsafeMutablePointer<StorageElement>

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

// MARK: - RandomAccessCollection
extension WeakArrayBufferSlice: RandomAccessCollection {
  typealias Index = Int
  typealias Indices = CountableRange<Int>
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

  subscript(index: Int) -> Element { return elements[index].reference }

  subscript(subRange: Range<Int>) -> SubSequence { return self[CountableRange(subRange)] }
  subscript(subRange: CountableRange<Int>) -> SubSequence { return SubSequence(bufferSlice: self, indices: subRange) }

}

// MARK: CustomStringConvertible, CustomDebugStringConvertible
extension WeakArrayBufferSlice: CustomStringConvertible, CustomDebugStringConvertible {
  var description: String { return describe(elements.advanced(by: startIndex), count: count, debug: false) }
  var debugDescription: String { return describe(elements.advanced(by: startIndex), count: count, debug: true) }
}

// MARK: - WeakArray

/// A hash-based set of elements that preserves element order.
@_fixed_layout
public struct WeakArray<WeakElement:AnyObject>: RandomAccessCollection, _DestructorSafeContainer {

  fileprivate typealias Buffer = WeakArrayBuffer<WeakElement>
  fileprivate typealias Storage = WeakArrayStorage<WeakElement>
  public typealias StorageElement = Weak<WeakElement>

  public typealias Index = Int
  public typealias Indices = CountableRange<Int>
  public typealias Element = WeakElement?
  public typealias _Element = Element
  public typealias SubSequence = WeakArraySlice<WeakElement>

  public var startIndex: Index { return 0 }

  public var endIndex: Index {  return buffer.endIndex }

  public subscript(index: Index) -> Element {
    get {  return buffer[index] }
    set { _reserveCapacity(capacity); buffer[index] = newValue }
  }

  public subscript(subRange: Range<Int>) -> SubSequence {
    get { return self[CountableRange(subRange)] }
    set { self[CountableRange(subRange)] = newValue }
  }

  public subscript(subRange: CountableRange<Int>) -> SubSequence {
    get { return SubSequence(buffer: buffer[subRange]) }
    set { replaceSubrange(subRange, with: newValue) }
  }

  fileprivate var buffer: Buffer

  /// The current number of elements
  public var count: Int {  return buffer.count }

  /// The number of elements this collection can hold without reallocating
  public var capacity: Int { return buffer.capacity }


  public init(minimumCapacity: Int) { self = WeakArray(buffer: Buffer(minimumCapacity: minimumCapacity)) }

  public init<Source:Sequence>(_ sourceElements: Source) where Source.Iterator.Element == Element {
    self = WeakArray(sourceElements.map(Weak.init))
  }

  public init<Source:Sequence>(_ sourceElements: Source) where Source.Iterator.Element == WeakElement {
    self = WeakArray(sourceElements.map(Weak.init))
  }

  public init<Source:Collection>(_ sourceElements: Source) where Source.Iterator.Element == StorageElement {
    self = WeakArray(buffer: Buffer(sourceElements))
  }

  fileprivate init(buffer: Buffer) {  self.buffer = buffer }

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

  fileprivate mutating func _reserveCapacity(_ minimumCapacity: Int) {
    guard buffer.requestUniqueBuffer(minimumCapacity: minimumCapacity) == nil else { return }
    buffer = Buffer(buffer: buffer, withCapacity: Swift.max(buffer.count * 2, minimumCapacity))
  }

}

// MARK: RangeReplaceableCollection
extension WeakArray: RangeReplaceableCollection {

  public init() { self = WeakArray(buffer: Buffer(minimumCapacity: 0)) }

  public mutating func reserveCapacity(_ minimumCapacity: Int) { _reserveCapacity(minimumCapacity) }

  public mutating func replaceSubrange<Source:Collection>(_ subRange: Range<Int>, with newElements: Source)
    where Source.Iterator.Element == Element
  {
    replaceSubrange(CountableRange(subRange), with: newElements)
  }

  public mutating func replaceSubrange<Source:Collection>(_ subRange: CountableRange<Int>, with newElements: Source)
    where Source.Iterator.Element == Element
  {
    let newElements = newElements.map(Weak.init)
    guard !(subRange.isEmpty && newElements.isEmpty) else { return }
    _reserveCapacity(count - subRange.count + numericCast(newElements.count))

    // Replace with uniqued collection
    buffer.replaceSubrange(subRange, with: newElements)
  }

  public mutating func append(_ element: Element) { _reserveCapacity(count &+ 1); buffer.append(Weak(element)) }

  public mutating func append<Source:Sequence>(contentsOf newElements: Source) where Source.Iterator.Element == Element {
    let newElements = newElements.map(Weak.init)
    guard !newElements.isEmpty else { return }
    let 𝝙count: Int = numericCast(newElements.count)
    _reserveCapacity(count &+ 𝝙count)
    buffer.append(contentsOf: newElements)
  }

  public mutating func insert(_ newElement: Element, at index: Index) {
    _reserveCapacity(count &+ 1)
    buffer.insert(Weak(newElement), at: index)
  }

  public mutating func insert<Source:Sequence>(contentsOf newElements: Source, at index: Index)
    where Source.Iterator.Element == Element
  {
    let newElements = newElements.map(Weak.init)
    _reserveCapacity(count &+ numericCast(newElements.count))
    buffer.insert(contentsOf: newElements, at: index)
  }

  @discardableResult public mutating func remove(at index: Index) -> Element {
    _reserveCapacity(capacity)
    defer { buffer.destroy(at: index) }
    return buffer[index]
  }

  @discardableResult public mutating func removeFirst() -> Element { return remove(at: startIndex) }

  public mutating func removeFirst(_ n: Int) { removeSubrange(0 ..< n) }

  @discardableResult public mutating func removeLast() -> Element { return remove(at: endIndex - 1) }

  public mutating func removeLast(_ n: Int) { removeSubrange(endIndex-n..<endIndex) }

  public mutating func removeSubrange(_ subRange: Range<Index>) { removeSubrange(CountableRange(subRange)) }

  public mutating func removeSubrange(_ subRange: CountableRange<Index>) {
    _reserveCapacity(capacity)
    buffer.removeSubrange(subRange)
  }

  public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
    guard keepCapacity else { if capacity > 0 { buffer = Buffer(minimumCapacity: 0) }; return }
    guard buffer.isUniquelyReferenced() else { buffer = Buffer(minimumCapacity: capacity); return }
    buffer.destroyAll()
  }

}

extension WeakArray: ExpressibleByArrayLiteral {
  public init(arrayLiteral elements: Element...) { self = WeakArray(elements) }
}

// MARK: CustomStringConvertible, CustomDebugStringConvertible
extension WeakArray: CustomStringConvertible, CustomDebugStringConvertible {
  public var description: String { return buffer.description }
  public var debugDescription: String { return buffer.debugDescription }
}

// MARK: Equatable
extension WeakArray: Equatable {
  public static func ==(lhs: WeakArray<WeakElement>, rhs: WeakArray<WeakElement>) -> Bool {
    guard !(lhs.buffer.identity == rhs.buffer.identity && lhs.count == rhs.count) else { return true }
    for (v1, v2) in zip(lhs, rhs) where v1 !== v2 { return false }
    return lhs.count == rhs.count
  }
}

// MARK: - WeakArraySlice

/// A hash-based set of elements that preserves element order.
@_fixed_layout
public struct WeakArraySlice<WeakElement:AnyObject>: RandomAccessCollection, _DestructorSafeContainer {

  fileprivate typealias Buffer = WeakArrayBuffer<WeakElement>
  fileprivate typealias BufferSlice = WeakArrayBufferSlice<WeakElement>
  fileprivate typealias Storage = WeakArrayStorage<WeakElement>

  public typealias Index = Int
  public typealias Indices = CountableRange<Int>
  public typealias Element = WeakElement?
  public typealias _Element = Element
  public typealias SubSequence = WeakArraySlice<WeakElement>

  public var startIndex: Index {  return buffer.startIndex }

  public var endIndex: Index {  return buffer.endIndex }

  public subscript(index: Index) -> Element { return buffer[index] }

  public subscript(subRange: Range<Int>) -> SubSequence { return self[CountableRange(subRange)] }
  public subscript(subRange: CountableRange<Int>) -> SubSequence { return SubSequence(buffer: buffer[subRange]) }

  fileprivate var buffer: BufferSlice

  /// The current number of elements
  public var count: Int {  return buffer.count }

  fileprivate init(buffer: BufferSlice) {  self.buffer = buffer }

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
extension WeakArraySlice: CustomStringConvertible, CustomDebugStringConvertible {
  public var description: String { return buffer.description }
  public var debugDescription: String { return buffer.debugDescription }
}

// MARK: Equatable
extension WeakArraySlice: Equatable {
  public static func ==(lhs: WeakArraySlice<WeakElement>, rhs: WeakArraySlice<WeakElement>) -> Bool {
    guard !(lhs.buffer.identity == rhs.buffer.identity && lhs.indices == rhs.indices) else { return true }
    for (v1, v2) in zip(lhs, rhs) where v1 !== v2 { return false }
    return lhs.count == rhs.count
  }
}
