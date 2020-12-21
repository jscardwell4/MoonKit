//
//  CountableRangeMap.swift
//  MoonKit
//
//  Created by Jason Cardwell on 5/25/16.
//  Copyright © 2016 Jason Cardwell. All rights reserved.
//

import Foundation
//import Surge

/// Type to serve as `value` for `CountableRangeMapStorage`
internal struct CountableRangeMapStorageHeader {
  var count = 0
  let capacity: Int
  init(capacity: Int) { self.capacity = capacity }
}

/// Backing storage for `RangeMapBuffer` and `CountableRangeMapBuffer`
internal class CountableRangeMapStorage<Bound>: ManagedBuffer<CountableRangeMapStorageHeader, Bound> {

  var elements: UnsafeMutablePointer<Bound> { return withUnsafeMutablePointerToElements {$0} }

  class func create(minimumCapacity: Int) -> CountableRangeMapStorage {
    return super.create(minimumCapacity: minimumCapacity) {
      CountableRangeMapStorageHeader(capacity: $0.capacity)
      } as! CountableRangeMapStorage
  }

  deinit {
    withUnsafeMutablePointers {
      $1.deinitialize(count: $0.pointee.count)
      $0.deinitialize(count: 1)
    }
  }
}

/// Iterator for enumerating ranges contained inside an instance of `CountableRangeMap`
public struct CountableRangeMapIterator<Bound:Strideable>: IteratorProtocol where Bound.Stride:SignedInteger {

  fileprivate typealias Storage = CountableRangeMapStorage<Bound>
  fileprivate let storage: Storage
  fileprivate var index = 0
  fileprivate let endIndex: Int
  fileprivate init(storage: Storage, indices: CountableRange<Int>? = nil) {
    self.storage = storage
    let indices = indices ?? 0 ..< storage.header.count
    index = indices.lowerBound
    endIndex = indices.upperBound
  }

  public mutating func next() -> CountableClosedRange<Bound>? {
    guard storage.header.count > (index &+ 1) else { return nil }
    defer { index = index &+ 2 }
    return storage.elements[index]...storage.elements[index &+ 1]
  }
}

/// Iterator for enumerating ranges contained inside an instance of `RangeMap`
public struct RangeMapIterator<Bound:Strideable>: IteratorProtocol {

  fileprivate typealias Storage = CountableRangeMapStorage<Bound>
  fileprivate let storage: Storage
  fileprivate var index = 0
  fileprivate let endIndex: Int
  fileprivate init(storage: Storage, indices: CountableRange<Int>? = nil) {
    self.storage = storage
    let indices = indices ?? 0 ..< storage.header.count
    index = indices.lowerBound
    endIndex = indices.upperBound
  }

  public mutating func next() -> ClosedRange<Bound>? {
    guard storage.header.count > (index &+ 1) else { return nil }
    defer { index = index &+ 2 }
    return storage.elements[index]...storage.elements[index &+ 1]
  }
}

/// Enumeration of possible representations for the elements stored by `CountableRangeMapStorage`
///
/// - lower: The lower bound of a given closed range.
/// - upper: The upper bound of a given closed range.
internal enum Limit {
  case lower, upper
  init(_ index: Int) { self = index % 2 == 0 ? .lower : .upper }
}


/// Enumeration for capturing the result of a value search over a `CountableRangeMapBuffer` instance.
///
/// - exact:       The index specifying an exact match for the searched value.
/// - predecessor: The index specifying the nearest value less than the searched value.
/// - successor:   The index specifying the nearest value greater than the searched value.
internal enum SearchIndex {

  case exact(Int), predecessor(Int), successor(Int)

  var limit: Limit {
    switch self {
      case .exact(let i), .predecessor(let i), .successor(let i):
        return Limit(i)
    }
  }

}

extension SearchIndex: Comparable {

  var index: Int {
    switch self { case .exact(let index), .predecessor(let index), .successor(let index): return index }
  }

  static func ==(lhs: SearchIndex, rhs: SearchIndex) -> Bool {
    switch (lhs, rhs) {
      case (.exact(let index1),       .exact(let index2)),
           (.predecessor(let index1), .predecessor(let index2)),
           (.successor(let index1),   .successor(let index2)):
        return index1 == index2
      default:
        return false
    }
  }

  static func <(lhs: SearchIndex, rhs: SearchIndex) -> Bool { return lhs.index < rhs.index }
}

/// Buffer backing instances of `CountableRangeMap`.
internal struct CountableRangeMapBuffer< Bound:Strideable>: _DestructorSafeContainer
  where Bound.Stride:SignedInteger
{

  typealias Buffer = CountableRangeMapBuffer<Bound>
  typealias BufferSlice = CountableRangeMapBufferSlice<Bound>
  typealias Storage = CountableRangeMapStorage<Bound>
  var storage: Storage

  let elements: UnsafeMutablePointer<Element>

  @inline(__always)
  mutating func isUniquelyReferenced() -> Bool { return Swift.isKnownUniquelyReferenced(&storage) }

  @inline(__always)
  mutating func isUniquelyReferencedWithCapacity(_ minimumCapacity: Int = 0) -> Bool {
    return isUniquelyReferenced() && storage.header.capacity >= minimumCapacity
  }

  var capacity: Int { return storage.header.capacity }

  var identity: UnsafeRawPointer { return UnsafeRawPointer(elements) }  // coverage 0

  init(storage: Storage) {
    self.storage = storage
    elements = storage.elements
  }

  init(minimumCapacity: Int) {
    let storage = Storage.create(minimumCapacity: minimumCapacity)
    self = Buffer(storage: storage)
  }

  init(range: CountableClosedRange<Bound>) {
    let storage = Storage.create(minimumCapacity: 2)
    storage.elements.initialize(to: range.lowerBound)
    (storage.elements + 1).initialize(to: range.upperBound)
    storage.header.count = 2
    self = Buffer(storage: storage)
  }

  /// Create a clone of `buffer` with the specified `capacity`.
  init(buffer: Buffer, withCapacity capacity: Int) {
    let storage = Storage.create(minimumCapacity: Swift.max(capacity, buffer.capacity))
    storage.elements.initialize(from: buffer.elements, count: buffer.count)
    storage.header.count = buffer.count
    self = Buffer(storage: storage)
  }

  /// Returns whether the buffer holds a range containing `range`.
  func contains(_ range: CountableClosedRange<Bound>) -> Bool {
    return _elements(UnsafePointer(elements), contain: range, indices: indices)
  }

  /// Returns whether the buffer holds a range containing `element`.
  func contains(_ element: Bound) -> Bool {
    return _elements(UnsafePointer(elements), contain: element, indices: indices)
  }

  /// Returns the index of the lower bound of the range containing `element`; 
  /// returns nil if no range contains `element`.
  func index(of element: Bound) -> Int? {
    return _index(of: element, within: UnsafePointer(elements), indices: indices)
  }

  /// Returns the index of the lower bound of the range containing `range`; 
  /// returns nil if no range contains `range`.
  func index(of range: CountableClosedRange<Bound>) -> Int? {
    return _index(of: range, within: UnsafePointer(elements), indices: indices)
  }

  func search(for target: Bound) -> SearchIndex {
    return _search(elements: UnsafePointer(elements), for: target, indices: indices)
  }

  /// Returns the index found by searching for `value` adjusted via the following:
  /// - When `limiting == .lower`: return `0` if result was `nil`;
  /// given result `successor(let i)` return `max(0, i - 1)`
  /// - When `limiting == .upper`: return `count - 1` if result was `nil`;
  /// given result `predecessor(let i)` return `min(count - 1, i + 1)`
  func index(for value: Bound, limiting: Limit) -> Int {
    switch (search(for: value), limiting) {
    case (.exact(let i), .lower),
         (.predecessor(let i), .lower),
         (.exact(let i), .upper),
         (.successor(let i), .upper): return i
    case (.successor(let i), .lower): return Swift.max(0, i &- 1)
    case (.predecessor(let i), .upper): return Swift.min(count &- 1, i &+ 1)
    }
  }

  @discardableResult
  mutating func checkIndex(_ index: Int) -> Int {

    switch Limit(index) {

    case .lower where index == 0,  // begin coverage 0
    .upper where index &+ 1 == endIndex:
      return 0  // end coverage 0

    case .lower where elements[index].advanced(by: -1) <= elements[index &- 1]:
      // Predecessor is equal to or one less than the element at `index`. 
      // Remove index - 1 and index to bridge the ranges.
      _shift(from: index &+ 1, by: -2)
      return -2

    case .upper where elements[index].advanced(by: 1) >= elements[index &+ 1]:
      // Successor is equal to or one more than the element at `index`. 
      // Remove index and index + 1 to bridge the ranges.
      _shift(from: index &+ 2, by: -2)
      return -2

    case .lower, .upper:
      return 0

    }
  }

  mutating func insert(element: Bound) {

    guard count > 0 else {
      elements.initialize(repeating: element, count: 2)
      storage.header.count = 2
      return
    }

    let searchResult = search(for: element)

    switch (searchResult, searchResult.limit) {

    case (.exact, _), (.predecessor, .lower), (.successor, .upper):
      // `element` must be contained by an existing range
      break

    case (.successor(let i), .lower) where elements[i].advanced(by: -1) == element:
      // Element extends the range based at `i`.
      elements[i] = element
      checkIndex(i)

    case (.successor(let i), .lower) where i > 0 && elements[i &- 1] == element.advanced(by: -1):
      // Element extends the range based at `i - 2`.
      elements[i &- 1] = element

    case (.successor(let i), .lower):
      _shift(from: i, by: 2)
      (elements + i).initialize(repeating: element, count: 2)

    case (.predecessor(let i), .upper) where elements[i] == element.advanced(by: -1):
      // Element extends the range based at `i - 1`.
      elements[i] = element
      checkIndex(i)

    case (.predecessor(let i), .upper) where i &+ 1 < endIndex && elements[i &+ 1] == element.advanced(by: 1):
      // Element extends the range based at `i + 1`.
      elements[i &+ 1] = element

    case (.predecessor(let i), .upper):
      _shift(from: i &+ 1, by: 2)
      (elements + (i &+ 1)).initialize(repeating: element, count: 2)

    }

  }

  mutating func insert(elementsFor range: CountableClosedRange<Bound>) {

    guard count > 0 else {
      elements.initialize(to: range.lowerBound)
      (elements + 1).initialize(to: range.upperBound)
      storage.header.count = 2
      return
    }

    let lowerIndex = index(for: range.lowerBound, limiting: .lower)
    let upperIndex = index(for: range.upperBound, limiting: .upper)

    switch (Limit(lowerIndex), Limit(upperIndex)) {

    case (.lower, .upper):
      // intervening values get absorbed
      _shift(from: upperIndex, by: (lowerIndex &+ 1) &- upperIndex)

    case (.lower, .lower) where lowerIndex == upperIndex:
      _shift(from: lowerIndex, by: 2)
      (elements + lowerIndex).initialize(to: range.lowerBound)
      (elements + (lowerIndex &+ 1)).initialize(to: range.upperBound)
      checkIndex(lowerIndex &+ 1)

    case (.lower, .lower):
      // replace upper, lower and intervening values get absorbed
      _shift(from: upperIndex, by: (lowerIndex &+ 2) &- upperIndex)
      elements[lowerIndex &+ 1] = range.upperBound
      checkIndex(lowerIndex &+ 1)

    case (.upper, .lower):
      // replace upper and lower, intervening values get absorbed
      _shift(from: upperIndex, by: (lowerIndex &+ 3) &- upperIndex)
      (elements + (lowerIndex &+ 1)).initialize(to: range.lowerBound)
      (elements + (lowerIndex &+ 2)).initialize(to: range.upperBound)
      checkIndex(lowerIndex &+ 2 &+ checkIndex(lowerIndex &+ 1))

    case (.upper, .upper) where lowerIndex == upperIndex && upperIndex == endIndex &- 1:
      elements[lowerIndex &+ 1] = range.lowerBound
      elements[lowerIndex &+ 2] = range.upperBound
      storage.header.count = lowerIndex &+ 3
      checkIndex(lowerIndex &+ 1)

    case (.upper, .upper):
      // replace lower, upper and any intervening values get absorbed
      _shift(from: upperIndex, by: (lowerIndex &+ 2) &- upperIndex)
      elements[lowerIndex &+ 1] = range.lowerBound
      checkIndex(lowerIndex &+ 1)
    }

  }

  mutating func invert(coverage: CountableClosedRange<Bound>) {

    guard count > 0 else {
      elements.initialize(to: coverage.lowerBound)
      (elements + 1).initialize(to: coverage.upperBound)
      storage.header.count = 2
      return
    }

    let lowerBound = Swift.min(elements[0], coverage.lowerBound)
    let upperBound = Swift.max(elements[endIndex &- 1], coverage.upperBound)

    func update(at target: Int, from source: Int) {
      switch Limit(source) {
      case .upper: elements[target] = elements[source].advanced(by: 1)
      case .lower: elements[target] = elements[source].advanced(by: -1)
      }
    }

    switch (elements[0] == lowerBound, elements[endIndex &- 1] == upperBound) {

    case (true, true):
      for i in 1 ..< (endIndex &- 1) { update(at: i &- 1, from: i) }
      (elements + (endIndex &- 2)).deinitialize(count: 2)
      storage.header.count = storage.header.count &- 2

    case (true, false):
      for i in 0 ..< (endIndex &- 1) { update(at: i, from: i &+ 1) }
      elements[endIndex &- 1] = upperBound

    case (false, true):
      for i in (0 ..< (endIndex &- 1)).reversed() { update(at: i &+ 1, from: i) }
      elements[0] = lowerBound

    case (false, false):
      (elements + (endIndex &+ 1)).initialize(to: upperBound)
      (elements + endIndex).initialize(to: elements[endIndex &- 1].advanced(by: 1))
      for i in (0 ..< (endIndex &- 1)).reversed() { update(at: i &+ 1, from: i) }
      elements[0] = lowerBound
      storage.header.count = storage.header.count &+ 2

    }

  }

  mutating func remove(element: Bound) {

    guard let lowerIndex = index(of: element) else { return }

    switch (elements[lowerIndex], elements[lowerIndex &+ 1]) {

    case (element, _):
      // Increment lower
      elements[lowerIndex] = element.advanced(by: 1)

    case (_, element):
      // Decrement upper
      elements[lowerIndex &+ 1] = element.advanced(by: -1)

    default:
      // Split lower ... upper at `element`
      _shift(from: lowerIndex &+ 1, by: 2)
      (elements + (lowerIndex &+ 1)).initialize(to: element.advanced(by: -1))
      (elements + (lowerIndex &+ 2)).initialize(to: element.advanced(by: 1))

    }
  }

  fileprivate func _shift(from sourceIndex: Int, by count: Int) {
    switch count {
    case 0: return
    case Int.min..<0:
      // Shift left
      let source = elements + sourceIndex
      let target = source.advanced(by: count)
      let end = elements + (endIndex &+ count)
      target.assign(from: source, count: endIndex &- sourceIndex)
      end.deinitialize(count: abs(count))
      storage.header.count = endIndex &+ count
    default:
      // Shift right
      let source = elements + sourceIndex
      let target = source.advanced(by: count)
      target.moveInitialize(from: source, count: endIndex &- sourceIndex)
      storage.header.count = endIndex &+ count
    }
  }

  fileprivate func _removeLowerUpper(lowerIndex: Int, lowerValue: Bound, upperIndex: Int, upperValue: Bound) {

    switch (elements[lowerIndex], elements[upperIndex]) {

    case (lowerValue, upperValue):
      _shift(from: upperIndex &+ 1, by: lowerIndex &- (upperIndex &+ 1))

    case (lowerValue, _):
      _shift(from: upperIndex &- 1, by: (lowerIndex &+ 1) &- upperIndex)
      elements[lowerIndex] = upperValue.advanced(by: 1)

    case (_, upperValue):
      _shift(from: upperIndex &+ 1, by: (lowerIndex &+ 1) &- upperIndex)
      elements[lowerIndex &+ 1] = lowerValue.advanced(by: -1)

    default:
      _shift(from: upperIndex &- 1, by: (lowerIndex &+ 3) &- upperIndex)
      elements[lowerIndex &+ 1] = lowerValue.advanced(by: -1)
      elements[lowerIndex &+ 2] = upperValue.advanced(by: 1)

    }

  }

  fileprivate func _removeLowerLower(lowerIndex: Int, lowerValue: Bound, upperIndex: Int, upperValue: Bound) {

    switch (elements[lowerIndex], elements[upperIndex]) {

    case (lowerValue, _):
      _shift(from: upperIndex, by: lowerIndex &- upperIndex)

    case (_, upperValue) where elements[upperIndex &+ 1] == upperValue:
      _shift(from: upperIndex &+ 2, by: lowerIndex &- upperIndex)
      elements[lowerIndex &+ 1] = lowerValue.advanced(by: -1)

    case (_, upperValue):
      _shift(from: upperIndex, by: (lowerIndex &+ 2) &- upperIndex)
      elements[lowerIndex &+ 1] = lowerValue.advanced(by: -1)
      elements[lowerIndex &+ 2] = upperValue.advanced(by: 1)

    default:
      _shift(from: upperIndex, by: (lowerIndex &+ 2) &- upperIndex)
      elements[lowerIndex &+ 1] = lowerValue.advanced(by: -1)

    }

  }

  fileprivate func _removeUpperLower(lowerIndex: Int, lowerValue: Bound, upperIndex: Int, upperValue: Bound) {

    switch (elements[lowerIndex], elements[upperIndex]) {

    case (lowerValue, _) where elements[lowerIndex &- 1] == lowerValue:
      _shift(from: upperIndex, by: lowerIndex &- (upperIndex &+ 1))

    case (lowerValue, _):
      _shift(from: upperIndex, by: (lowerIndex &+ 1) &- upperIndex)
      elements[lowerIndex] = lowerValue.advanced(by: -1)

    case (_, upperValue) where elements[upperIndex &+ 1] == upperValue:
      _shift(from: upperIndex &+ 2, by: lowerIndex &- (upperIndex &+ 1))

    case (_, upperValue):  //FIXME: coverage 0
      elements[upperIndex] = upperValue.advanced(by: 1)
      _shift(from: upperIndex, by: (lowerIndex &+ 1) &- upperIndex)

    default:
      _shift(from: upperIndex, by: (lowerIndex &+ 1) &- upperIndex)

    }

  }

  fileprivate func _removeUpperUpper(lowerIndex: Int, lowerValue: Bound, upperIndex: Int, upperValue: Bound) {

    switch (elements[lowerIndex], elements[upperIndex]) {

    case (lowerValue, _) where elements[lowerIndex &- 1] == lowerValue:
      _shift(from: upperIndex &- 1, by: lowerIndex &- upperIndex)
      elements[lowerIndex &- 1] = upperValue.advanced(by: 1)

    case (lowerValue, _):
      _shift(from: upperIndex &- 1, by: (lowerIndex &+ 2) &- upperIndex)
      elements[lowerIndex] = lowerValue.advanced(by: -1)
      elements[lowerIndex &+ 1] = upperValue.advanced(by: 1)

    case (_, upperValue):
      _shift(from: upperIndex &+ 1, by: lowerIndex &- upperIndex)

    default:
      _shift(from: upperIndex &- 1, by: (lowerIndex &+ 2) &- upperIndex)
      elements[lowerIndex &+ 1] = upperValue.advanced(by: 1)

    }

  }

  mutating func remove(range: CountableClosedRange<Bound>) {

    guard range.count > 1 else { self.remove(element: range.lowerBound); return }

    let lowerIndex = index(for: range.lowerBound, limiting: .lower) // Exact or predecessor for range.lowerBound
    let upperIndex = index(for: range.upperBound, limiting: .upper) // Exact or successor for range.upperBound

    let remove: (_ lowerIndex: Int, _ lowerValue: Bound, _ upperIndex: Int, _ upperValue: Bound) -> Void

    switch (Limit(lowerIndex), Limit(upperIndex)) {
    case (.lower, .upper): remove = _removeLowerUpper
    case (.lower, .lower): remove = _removeLowerLower
    case (.upper, .lower): remove = _removeUpperLower
    case (.upper, .upper): remove = _removeUpperUpper
    }

    remove(lowerIndex, range.lowerBound, upperIndex, range.upperBound)
  }

}

extension CountableRangeMapBuffer: CustomStringConvertible {
  var description: String { return _describe(CountableRangeMapIterator(storage: storage)) }
}

extension CountableRangeMapBuffer: RandomAccessCollection {

  typealias Index = Int
  typealias SubSequence = BufferSlice
  typealias Indices = CountableRange<Int>
  typealias Element = Bound
  typealias _Element = Element

  var startIndex: Int { return 0 }
  var endIndex: Int { return storage.header.count }

  var count: Int { return storage.header.count }


  @inline(__always) func _failEarlyRangeCheck(_ index: Int, bounds: Range<Int>) {}
  @inline(__always) func _failEarlyRangeCheck(_ range: Range<Int>, bounds: Range<Int>) {}

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

  subscript(index: Int) -> Bound { return elements[index] }
  subscript(subRange: Range<Int>) -> SubSequence { return SubSequence(buffer: self, indices: subRange) }

}

internal struct CountableRangeMapBufferSlice<Bound:Strideable>: _DestructorSafeContainer where Bound.Stride:SignedInteger {

  typealias Buffer = CountableRangeMapBuffer<Bound>
  typealias BufferSlice = CountableRangeMapBufferSlice<Bound>
  typealias Storage = CountableRangeMapStorage<Bound>
  typealias Element = Bound
  typealias _Element = Element

  var storage: Storage
  let elements: UnsafeMutablePointer<Element>

  @inline(__always) mutating func isUniquelyReferenced() -> Bool { return Swift.isKnownUniquelyReferenced(&storage) }

  let startIndex: Int
  let endIndex: Int

  var identity: UnsafeRawPointer { return UnsafeRawPointer(elements) }

  init(buffer: Buffer, indices: Range<Int>) {
    storage = buffer.storage
    elements = storage.elements
    startIndex = indices.lowerBound
    endIndex = indices.upperBound
  }

  init(bufferSlice: BufferSlice, indices: Range<Int>) {
    storage = bufferSlice.storage
    elements = storage.elements
    startIndex = indices.lowerBound
    endIndex = indices.upperBound
  }

  /// Returns whether the buffer holds a range containing `range`.
  func contains(_ range: CountableClosedRange<Bound>) -> Bool {
    return _elements(UnsafePointer(elements), contain: range, indices: indices)
  }

  /// Returns whether the buffer holds a range containing `element`.
  func contains(_ element: Bound) -> Bool {
    return _elements(UnsafePointer(elements), contain: element, indices: indices)
  }

  /// Returns the index of the lower bound of the range containing `element`; 
  /// returns nil if no range contains `element`.
  func index(of element: Bound) -> Int? {
    return _index(of: element, within: UnsafePointer(elements), indices: indices)
  }

  /// Returns the index of the lower bound of the range containing `range`; 
  /// returns nil if no range contains `range`.
  func index(of range: CountableClosedRange<Bound>) -> Int? {
    return _index(of: range, within: UnsafePointer(elements), indices: indices)
  }
}

extension CountableRangeMapBufferSlice: RandomAccessCollection {
  typealias Index = Int
  typealias SubSequence = BufferSlice
  typealias Indices = CountableRange<Int>

  var count: Int { return endIndex &- startIndex } // Calculate since we are a slice

  @inline(__always) func _failEarlyRangeCheck(_ index: Int, bounds: Range<Int>) {}
  @inline(__always) func _failEarlyRangeCheck(_ range: Range<Int>, bounds: Range<Int>) {}

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

  subscript(index: Int) -> Element {
    precondition(indices.contains(index), "invalid index '\(index)'")
    return elements[index]
  }

  subscript(subRange: Range<Int>) -> SubSequence {
    precondition(indices.contains(subRange), "invalid subRange '\(subRange)'")
    return SubSequence(bufferSlice: self, indices: subRange)
  }

}

extension CountableRangeMapBufferSlice: CustomStringConvertible {
  var description: String { return _describe(CountableRangeMapIterator(storage: storage, indices: indices)) }
}

public struct CountableRangeMap<
  Bound:Strideable>: RandomAccessCollection, _DestructorSafeContainer where Bound.Stride:SignedInteger
  
{

  fileprivate typealias Buffer = CountableRangeMapBuffer<Bound>
  fileprivate typealias Storage = CountableRangeMapStorage<Bound>

  fileprivate var buffer: Buffer

  fileprivate mutating func ensureUnique(withCapacity minimumCapacity: Int) {
    guard !buffer.isUniquelyReferencedWithCapacity(minimumCapacity << 1) else { return }
    buffer = Buffer(buffer: buffer, withCapacity: Swift.max(buffer.count << 1, minimumCapacity << 1))
  }

  public var lowerBound: Bound? { return buffer.first }
  public var upperBound: Bound? { return buffer.last }

  public func min() -> CountableClosedRange<Bound>? { return first }
  public func max() -> CountableClosedRange<Bound>? { return last }

  /// The range containing the min `Bound` and the max `Bound` or nil if the collection is empty.
  public var coverage: CountableClosedRange<Bound>? {
    guard let lowerBound = lowerBound, let upperBound = upperBound else { return nil }
    return lowerBound ... upperBound
  }

  public func contains(_ range: CountableClosedRange<Bound>) -> Bool { return buffer.contains(range) }
  public func contains(_ element: Bound) -> Bool { return buffer.contains(element) }

  public func index(of element: Bound) -> Int? {
    guard let index = buffer.index(of: element) else { return nil }
    return index >> 1
  }

  public func index(of range: CountableClosedRange<Bound>) -> Int? {
    guard let index = buffer.index(of: range) else { return nil }
    return index >> 1
  }

  public var flattenedCount: Int {
    var result = 0

    for index in indices {
      let lowerBound = buffer[index << 1]
      let upperBound = buffer[index << 1 &+ 1]
      let distance = Int(lowerBound.distance(to: upperBound)) + 1
      result = result &+ numericCast(distance)
    }

    return result
  }

  public init() { buffer = Buffer(minimumCapacity: 0) }

  fileprivate init(_ ranges: ContiguousArray<CountableClosedRange<Bound>>) {
    let buffer = Buffer(minimumCapacity: ranges.count << 1)
    let elements = buffer.elements
    for (offset, range) in ranges.enumerated() {
      (elements + (offset << 1)).initialize(to: range.lowerBound)
      (elements + (offset << 1 &+ 1)).initialize(to: range.upperBound)
    }
    buffer.storage.header.count = ranges.count << 1
    self.buffer = buffer
  }

  public init<Source:Sequence>(_ sequence: Source) where Source.Iterator.Element == Bound {
    self = CountableRangeMap(_rangify(elements: sequence))
  }

  public init<Source:Sequence>(_ sequence: Source) where Source.Iterator.Element == CountableClosedRange<Bound> {
    self = CountableRangeMap(_rangify(ranges: sequence))
  }

  public init(_ range: CountableClosedRange<Bound>) { buffer = Buffer(range: range) }

//  public init(_ range: ClosedRange<Bound>) { buffer = Buffer(range: rangeCast(range)) }

//  public init(_ range: CountableRange<Bound>) {
//    buffer = range.isEmpty
//      ? Buffer(minimumCapacity: 0)
//      : Buffer(range: rangeCast(range))
//  }

  public init(_ range: Range<Bound>) {
    buffer = range.lowerBound == range.upperBound
      ? Buffer(minimumCapacity: 0)
      : Buffer(range: rangeCast(range))
  }


  /// Insert `element` into the collection. If an existing element contains `element`, no action is taken.
  /// If `element` prepends or extends an existing element, the existing element is updated.
  /// Otherwise, a new element is inserted for `element`.
  public mutating func insert(_ element: Bound) {
    ensureUnique(withCapacity: count &+ 1)
    buffer.insert(element: element)
  }

  fileprivate mutating func _insert(_ range: CountableClosedRange<Bound>) {
    ensureUnique(withCapacity: count &+ 1)
    buffer.insert(elementsFor: range)
  }

  public mutating func insert(_ range: CountableClosedRange<Bound>) { _insert(range) }

//  public mutating func insert(_ range: ClosedRange<Bound>) { _insert(rangeCast(range)) }

//  public mutating func insert(_ range: CountableRange<Bound>) {
//    guard !range.isEmpty else { return }
//    _insert(rangeCast(range))
//  }

  public mutating func insert(_ range: Range<Bound>) {
    guard range.upperBound > range.lowerBound else { return }
    _insert(rangeCast(range))
  }

  /// Merges `ranges` with the ranges expressed by `indices`.
  public mutating func insert<Source:Sequence>(_ elements: Source) where Source.Iterator.Element == Bound {
    let ranges = _rangify(elements: elements)
    ensureUnique(withCapacity: count &+ ranges.count)
    for range in ranges { buffer.insert(elementsFor: range) }
  }

  /// Merges `ranges` with `sequence`.
  public mutating func insert<Source:Sequence>(contentsOf ranges: Source)
    where Source.Iterator.Element == CountableClosedRange<Bound>
  {
    let ranges = _rangify(ranges: ranges)
    ensureUnique(withCapacity: count &+ ranges.count)
    for range in ranges { buffer.insert(elementsFor: range) }
  }

  public mutating func remove(_ element: Bound) {
    ensureUnique(withCapacity: count &+ 1)
    buffer.remove(element: element)
  }

  fileprivate mutating func _remove(_ range: CountableClosedRange<Bound>) {
    ensureUnique(withCapacity: count &+ 1)
    buffer.remove(range: range)
  }

  public mutating func remove(_ range: CountableClosedRange<Bound>) { _remove(range) }

//  public mutating func remove(_ range: ClosedRange<Bound>) { _remove(rangeCast(range)) }

//  public mutating func remove(_ range: CountableRange<Bound>) {
//    guard !range.isEmpty else { return }
//    _remove(rangeCast(range))
//  }

  public mutating func remove(_ range: Range<Bound>) {
    guard !range.isEmpty else { return }
    _remove(rangeCast(range))
  }

  fileprivate func _inverted(coverage: CountableClosedRange<Bound>) -> CountableRangeMap<Bound> {
    var result = self
    result._invert(coverage: coverage)
    return result
  }

  /// Returns a `CountableRangeMap` whose elements consist of the gaps between `ranges` over `coverage`.
  public func inverted(coverage: CountableClosedRange<Bound>) -> CountableRangeMap<Bound> {
    return _inverted(coverage: coverage)
  }

//  public func inverted(coverage: CountableRange<Bound>) -> CountableRangeMap<Bound> {
//    return _inverted(coverage: rangeCast(coverage))
//  }

//  public func inverted(coverage: ClosedRange<Bound>) -> CountableRangeMap<Bound> {
//    return _inverted(coverage: rangeCast(coverage))
//  }

  public func inverted(coverage: Range<Bound>) -> CountableRangeMap<Bound> {
    return _inverted(coverage: rangeCast(coverage))
  }

  fileprivate mutating func _invert(coverage: CountableClosedRange<Bound>) {
    ensureUnique(withCapacity: count &+ 1)
    buffer.invert(coverage: coverage)
  }

  /// Replaces `ranges` the gaps between `ranges` over `coverage`.
  public mutating func invert(coverage: CountableClosedRange<Bound>) { _invert(coverage: coverage) }
//  public mutating func invert(coverage: ClosedRange<Bound>) { _invert(coverage: rangeCast(coverage)) }
//  public mutating func invert(coverage: CountableRange<Bound>) { _invert(coverage: rangeCast(coverage)) }
  public mutating func invert(coverage: Range<Bound>) { _invert(coverage: rangeCast(coverage)) }

}

extension CountableRangeMap/*: RandomAccessIndexable*/ {

  @inline(__always) public func _failEarlyRangeCheck(_ index: Int, bounds: Range<Int>) {}
  @inline(__always) public func _failEarlyRangeCheck(_ range: Range<Int>, bounds: Range<Int>) {}

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

extension CountableRangeMap: Collection {

  public typealias Index = Int
  public typealias SubSequence = CountableRangeMapSlice<Bound>
  public typealias Indices = CountableRange<Int>

  public var startIndex: Int { return 0 }
  public var endIndex: Int { return buffer.endIndex >> 1 }
  public var count: Int { return buffer.count >> 1 }


  public var indices: CountableRange<Int> { return 0 ..< count }

  public subscript(index: Int) -> CountableClosedRange<Bound> {
    precondition(index * 2 < buffer.count, "Invalid index '\(index)'")
    return buffer.elements[index << 1]...buffer.elements[index << 1 + 1]
  }

  public subscript(subRange: Range<Int>) -> SubSequence {
    return SubSequence(buffer: buffer[subRange.lowerBound << 1 ..< subRange.upperBound << 1])
  }

}

extension CountableRangeMap: Sequence {

  public typealias Element = CountableClosedRange<Bound>
  public typealias _Element = Element
  public typealias Iterator = CountableRangeMapIterator<Bound>

  public func makeIterator() -> Iterator { return Iterator(storage: buffer.storage) }

}

extension CountableRangeMap: Equatable {

  public static func ==(lhs: CountableRangeMap<Bound>, rhs: CountableRangeMap<Bound>) -> Bool {
    guard lhs.buffer.identity != rhs.buffer.identity else { return true }
    switch (lhs.coverage, rhs.coverage) {
    case (nil, _), (_, nil): return false
    case let (c1, c2) where c1 != c2: return false
    default: return lhs.buffer.elementsEqual(rhs.buffer)
    }
  }

}

public struct CountableRangeMapSlice<
  Bound:Strideable>: RandomAccessCollection, _DestructorSafeContainer where Bound.Stride:SignedInteger
  
{
  fileprivate typealias BufferSlice = CountableRangeMapBufferSlice<Bound>
  fileprivate typealias Storage = CountableRangeMapStorage<Bound>

  fileprivate var buffer: BufferSlice

  fileprivate init(buffer: BufferSlice) {  self.buffer = buffer }

  public var lowerBound: Bound? { return buffer.first }
  public var upperBound: Bound? { return buffer.last }

  public func min() -> CountableClosedRange<Bound>? { return first }
  public func max() -> CountableClosedRange<Bound>? { return last }

  /// The range containing the min `Bound` and the max `Bound` or nil if the collection is empty.
  public var coverage: CountableClosedRange<Bound>? {
    guard let lowerBound = lowerBound, let upperBound = upperBound else { return nil }
    return lowerBound ... upperBound
  }

  public func contains(_ range: CountableClosedRange<Bound>) -> Bool { return buffer.contains(range) }
  public func contains(_ element: Bound) -> Bool { return buffer.contains(element) }

  public func index(of element: Bound) -> Int? {
    guard let index = buffer.index(of: element) else { return nil }
    return index >> 1
  }

  public func index(of range: CountableClosedRange<Bound>) -> Int? {
    guard let index = buffer.index(of: range) else { return nil }
    return index >> 1
  }

  public var flattenedCount: Int {
    var result = 0

    for index in indices {
      let lowerBound = buffer[index << 1]
      let upperBound = buffer[index << 1 &+ 1]
      let distance = lowerBound.distance(to: upperBound) + 1
      result = result &+ numericCast(distance)
    }

    return result
  }

}

extension CountableRangeMapSlice/*: RandomAccessIndexable*/ {

  public typealias Indices = CountableRange<Int>

  @inline(__always) public func _failEarlyRangeCheck(_ index: Int, bounds: Range<Int>) {}
  @inline(__always) public func _failEarlyRangeCheck(_ range: Range<Int>, bounds: Range<Int>) {}

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

extension CountableRangeMapSlice: Collection {

  public typealias Index = Int
  public typealias SubSequence = CountableRangeMapSlice<Bound>

  public var startIndex: Index {  return buffer.startIndex >> 1 }
  public var endIndex: Index {  return buffer.endIndex >> 1 }
  public var count: Int {  return buffer.count >> 1 }

  public subscript(index: Index) -> CountableClosedRange<Bound> {
    precondition(index * 2 < buffer.endIndex, "Invalid index '\(index)'")
    return buffer[index * 2]...buffer[index * 2 &+ 1]
  }

  public subscript(subRange: Range<Int>) -> SubSequence {
    return SubSequence(buffer: buffer[subRange.lowerBound << 1 ..< subRange.upperBound << 1])
  }

}

extension CountableRangeMapSlice: Sequence {

  public typealias Element = CountableClosedRange<Bound>
  public typealias _Element = Element
  public typealias Iterator = CountableRangeMapIterator<Bound>

  public func makeIterator() -> Iterator { return Iterator(storage: buffer.storage, indices: buffer.indices) }

}

extension CountableRangeMapSlice: Equatable {

  public static func ==(lhs: CountableRangeMapSlice<Bound>, rhs: CountableRangeMapSlice<Bound>) -> Bool {
    guard lhs.buffer.identity != rhs.buffer.identity || lhs.indices != rhs.indices else { return true }
    switch (lhs.coverage, rhs.coverage) {
    case (nil, _), (_, nil): return false
    case let (c1, c2) where c1 != c2,
         let (c1, c2) where c1 == c2 && lhs.buffer.count != rhs.buffer.count: return false
    default: return lhs.buffer.elementsEqual(rhs.buffer)
    }
  }
}

// MARK: - Helpers to convert to an array of non-overlapping ranges

fileprivate func _elements<Bound:Strideable>(_ elements: UnsafePointer<Bound>,
                       contain range: CountableClosedRange<Bound>,
                       indices: CountableRange<Int>) -> Bool
  where Bound.Stride:SignedInteger
{
  guard let lowerIndex = _index(of: range.lowerBound, within: elements, indices: indices) else { return false }
  return elements[lowerIndex &+ 1] >= range.upperBound
}

fileprivate func _elements<Bound:Strideable>(_ elements: UnsafePointer<Bound>,
                       contain element: Bound,
                       indices: CountableRange<Int>) -> Bool
  where Bound.Stride:SignedInteger
{
  switch _search(elements: elements, for: element, indices: indices) {
  case .exact: return true
  case .predecessor(let i) where Limit(i) == .lower,
       .successor(let i) where Limit(i) == .upper: return true
  default: return false
  }
}

fileprivate func _index<Bound:Strideable>(of element: Bound,
                    within elements: UnsafePointer<Bound>,
                    indices: CountableRange<Int>) -> Int?
  where Bound.Stride:SignedInteger
{
  switch _search(elements: elements, for: element, indices: indices) {
  case .exact(let i) where Limit(i) == .lower,
       .predecessor(let i) where Limit(i) == .lower: return i
  case .exact(let i) where Limit(i) == .upper,
       .successor(let i) where Limit(i) == .upper: return i &- 1
  default: return nil
  }
}

fileprivate func _index<Bound:Strideable>(of range: CountableClosedRange<Bound>,
                    within elements: UnsafePointer<Bound>,
                    indices: CountableRange<Int>) -> Int? where Bound.Stride:SignedInteger
{
  guard let lowerIndex = _index(of: range.lowerBound, within: elements, indices: indices) else { return nil }
  return elements[lowerIndex &+ 1] >= range.upperBound ? lowerIndex : nil
}

fileprivate func _search<Bound:Strideable>(elements: UnsafePointer<Bound>,
                     for target: Bound,
                     indices: CountableRange<Int>) -> SearchIndex
  where Bound.Stride:SignedInteger

{

  guard !indices.isEmpty else { return .successor(indices.lowerBound) }

  // Helper for recursive binary search
  func search(range: CountableRange<Int>) -> SearchIndex {
    switch range.count {
    case 1:
      let bound = elements[range.lowerBound]
      return bound == target
        ? .exact(range.lowerBound)
        : bound < target
        ? .predecessor(range.lowerBound)
        : .successor(range.lowerBound)
    default:
      let m = range.count / 2 &+ range.lowerBound
      switch elements[m] {
      case target: return .exact(m)
      case let boundʹ where boundʹ < target:
        guard m &+ 1 < range.upperBound else { return .predecessor(m) }
        return search(range: m &+ 1 ..< range.upperBound)
      default:
        guard m > range.lowerBound else { return .successor(m) }
        return search(range: range.lowerBound ..< m)
      }
    }
  }

  return search(range: indices)
}


fileprivate func _describe<Bound:Strideable>(_ source: CountableRangeMapIterator<Bound>) -> String
  where Bound.Stride:SignedInteger
{
  var result = "["
  var first = true
  for range in IteratorSequence(source) {
    if first { first = false } else { print(", ", terminator: "", to: &result) }
    print(range.lowerBound == range.upperBound
      ? range.lowerBound
      : "\(range.lowerBound)...\(range.upperBound)", terminator: "", to: &result)
  }
  print("]", terminator: "", to: &result)
  return result
}

fileprivate func _rangify<S:Sequence, B:Strideable>(elements: S) -> ContiguousArray<CountableClosedRange<B>>
  where B.Stride:SignedInteger, S.Iterator.Element == B
{
  let sortedElements = elements.sorted { $0 < $1 }
  guard sortedElements.count > 0 else { return [] }
  guard sortedElements.count > 1 else { return [sortedElements[0] ... sortedElements[0]] }

  var ranges = ContiguousArray<CountableClosedRange<B>>()
  var lower = sortedElements[0]
  var upper = lower

  for element in sortedElements.dropFirst() {
    guard upper < element else { continue }
    if upper.advanced(by:1) == element { upper = element }
    else { ranges.append(lower ... upper); lower = element; upper = element }
  }

  if ranges.isEmpty || ranges[ranges.index(before: ranges.endIndex)] != lower ... upper {
    ranges.append(lower ... upper)
  }
  return ranges
}

fileprivate func _rangify<S:Sequence, B:Strideable>(ranges: S) -> ContiguousArray<CountableClosedRange<B>>
  where B.Stride:SignedInteger, S.Iterator.Element == CountableClosedRange<B>

{
  let sortedRanges = ranges.sorted { $0.lowerBound < $1.lowerBound }
  guard sortedRanges.count > 0 else { return [] }

  var result = ContiguousArray<CountableClosedRange<B>>()

  var range = sortedRanges[0]

  for rangeʹ in sortedRanges.dropFirst() {
    guard !(range.contains(rangeʹ)) else { continue }
    if rangeʹ.lowerBound > range.upperBound { result.append(range); range = rangeʹ }
    else { range = range.lowerBound ... rangeʹ.upperBound }
  }
  
  if result.isEmpty || result[(result.endIndex - 1)] != range { result.append(range) }
  return result
}
