//
//  IntervalMap.swift
//  MoonKit
//
//  Created by Jason Cardwell on 12/6/16.
//  Copyright © 2016 Jason Cardwell. All rights reserved.
//

import Foundation

// MARK: - Supporting enumerations

private enum SearchIndex: Comparable {
  case exact(Int)       /// The target was found at this index.
  case predecessor(Int) /// The target was not found but would belong just after this index.
  case successor(Int)   /// The target was not found but would belong just before this index.

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

// MARK: - Storage

/// Backing storage `IntervalMapBuffer`
private final class IntervalMapStorage<Bound>: ManagedBuffer<(count: Int, capacity: Int), Interval<Bound>>
  where Bound:Comparable
{

  var elements: UnsafeMutablePointer<Interval<Bound>> { return withUnsafeMutablePointerToElements {$0} }

  class func create(minimumCapacity: Int) -> IntervalMapStorage<Bound> {
    return super.create(minimumCapacity: minimumCapacity) { (count: 0, capacity: $0.capacity) }
      as! IntervalMapStorage<Bound>
  }

  deinit {
    withUnsafeMutablePointers {
      $1.deinitialize(count: $0.pointee.count)
      $0.deinitialize(count: 1)
    }
  }

}

// MARK: - Buffer

/// Buffer backing instances of `IntervalMap`.
private struct IntervalMapBuffer<Bound:Comparable>: _DestructorSafeContainer {

  typealias Buffer      = IntervalMapBuffer<Bound>
  typealias BufferSlice = IntervalMapBufferSlice<Bound>
  typealias Storage     = IntervalMapStorage<Bound>
  typealias Element     = Interval<Bound>

  typealias Index = Int
  typealias SubSequence = BufferSlice
  typealias Indices = CountableRange<Int>
  typealias _Element = Element


  var storage: Storage

  let elements: UnsafeMutablePointer<Element>

  @inline(__always) mutating func isUniquelyReferenced() -> Bool {
    return Swift.isKnownUniquelyReferenced(&storage)
  }

  @inline(__always) mutating func isUniquelyReferenced(withCapacity minimumCapacity: Int = 0) -> Bool {
    return isUniquelyReferenced() && storage.header.capacity >= minimumCapacity
  }

  var capacity: Int { return storage.header.capacity }

  var identity: UnsafeRawPointer { return UnsafeRawPointer(elements) }

  init(storage: Storage) {
    self.storage = storage
    elements = storage.elements
  }

  init(minimumCapacity: Int) {
    let storage = Storage.create(minimumCapacity: minimumCapacity)
    self = Buffer(storage: storage)
  }

  init(interval: Element) {
    let storage = Storage.create(minimumCapacity: 2)
    storage.elements.initialize(to: interval)
    storage.header.count = 1
    self = Buffer(storage: storage)
  }

  init<Source>(intervals: Source)
    where Source:Sequence, Source.Iterator.Element == Element
  {
    let elements = _combiningSort(intervals)
    let storage = Storage.create(minimumCapacity: elements.count)
    let elementsPointer = UnsafeMutableBufferPointer(start: storage.elements, count: elements.count)
    _ = elementsPointer.initialize(from: elements)
    storage.header.count = elements.count
    self = Buffer(storage: storage)
  }

  /// Create a clone of `buffer` with the specified `capacity`.
  init(buffer: Buffer, withCapacity capacity: Int) {
    let storage = Storage.create(minimumCapacity: Swift.max(capacity, buffer.capacity))
    storage.elements.initialize(from: buffer.elements, count: buffer.count)
    storage.header.count = buffer.count
    self = Buffer(storage: storage)
  }

  /// Returns whether the buffer holds an interval equal to or containing `interval`.
  func contains(_ interval: Element) -> Bool {
    guard !(isEmpty || interval.isEmpty),
      case (.exact(let lowerIndex),
            .exact(let upperIndex)) = *_search(elements: elements, for: interval, indices: indices),
      lowerIndex == upperIndex
      else
    {
      return false
    }
    return true
  }

  /// Returns whether the buffer holds an interval containing `element`.
  func contains(_ element: Bound) -> Bool {
    guard case .exact = _search(elements: elements, for: element】, indices: indices) else {
      return false
    }
    return true
  }

  /// Returns the index of the interval containing `element`;
  /// returns nil if no interval contains `element`.
  func index(of element: Bound) -> Int? {
    guard case .exact(let index) = _search(elements: elements, for: element】, indices: indices) else {
      return nil
    }
    return index
  }

  /// Returns the index of the interval fully containing `interval` or `nil`.
  func index(of interval: Element) -> Int? {
    guard !(isEmpty || interval.isEmpty),
      case (.exact(let lowerIndex),
            .exact(let upperIndex)) = *_search(elements: elements, for: interval, indices: indices),
      lowerIndex == upperIndex
      else
    {
      return nil
    }
    return lowerIndex
  }

  /// Inserts a degenerate interval if `element` not present in collection.
  mutating func insert(element: Bound) {

    guard !isEmpty else {
      elements.initialize(to: 【element..element】)
      storage.header.count = 1
      return
    }

    switch _search(elements: UnsafePointer(elements), for: element】, indices: indices) {

      case .exact:
        // `element` must be contained by an existing range
        break

      case .successor(let i) where elements[i].upper.value == element:
        // Element extends the interval based at `i`.
        elements[i] = elements[i].lower..element】

      case .successor(let i):
        _shift(from: i, by: 1)
        (elements + i).initialize(to: 【element..element】)

      case .predecessor(let i) where elements[i].lower.value == element:
        // Element prepends the interval based at `i`.
        elements[i] = 【element..elements[i].upper

      case .predecessor(let i):
        _shift(from: i &+ 1, by: 1)
        (elements + (i &+ 1)).initialize(to: 【element..element】)

    }

  }

  mutating func insert(interval: Element) {

    // Check there is something to insert.
    guard !interval.isEmpty else { return }

    // Check the collection is not empty.
    guard !isEmpty else {
      elements.initialize(to: interval)
      storage.header.count = 1
      return
    }

    // Switch on the lower and upper bounds of a search result for `interval`.
    switch *_search(elements: UnsafePointer(elements), for: interval, indices: indices) {

      case let (.exact(l), .exact(u)):
        // `interval` bridges 0 or more intervals.
        
        elements[l] = elements[l].lower..elements[u].upper
        _shift(from: u &+ 1, by: l &- u)

      case let (.exact(l), .predecessor(u))
        where u < endIndex && interval.upper.inverted == elements[u &+ 1].lower:
        // joining:  `interval` bridges 1 or more intervals, joining the interval at `u + 1`.
        
        elements[l] = elements[l].lower..elements[u &+ 1].upper
        _shift(from: u &+ 2, by: l &- (u &+ 1))

      case let (.exact(l), .predecessor(u)):
        // nonjoining:  `interval` bridges 0 or more intervals and extends the interval at `u`.
        
        elements[l] = elements[l].lower..interval.upper
        _shift(from: u &+ 1, by: l &- u)

      case let (.exact(l), .successor(u))
        where interval.upper.inverted == elements[u].lower:
        // joining:  `interval` bridges 1 or more intervals, joining the interval at `u`.
        
        elements[l] = elements[l].lower..elements[u].upper
        _shift(from: u &+ 1, by: l &- u)
        
      case let (.exact(l), .successor(u)):
        // nonjoining:  `interval` bridges 0 or more intervals and extends the interval at `u - 1`.
        
        elements[l] = elements[l].lower..interval.upper
        _shift(from: u, by: (l &+ 1) &- u)

      case let (.predecessor(l), .exact(u))
        where interval.lower.inverted == elements[l].upper:
        // joining:  `interval` bridges 1 or more intervals, joining interval at `l`.
        
        elements[u] = elements[l].lower..elements[u].upper
        _shift(from: u, by: l &- u)
        
      case let (.predecessor(l), .exact(u)):
        // nonjoining:  `interval` bridges 0 or more intervals and extends the interval at `l + 1`.
        
        elements[u] = interval.lower..elements[u].upper
        _shift(from: u, by: (l &+ 1) &- u)

      case let (.successor(l), .exact(u))
        where l > startIndex && interval.lower.inverted == elements[l &- 1].upper:
        // joining:  `interval` bridges 1 or more intervals, joining interval at `l - 1`.
        
        elements[l &- 1] = elements[l &- 1].lower..elements[u].upper
        _shift(from: u &+ 1, by: l &- (u &+ 1))

      case let (.successor(l), .exact(u)):
        // nonjoining:  `interval` bridges 0 or more intervals and prepends the interval at `l`.
        
        elements[l] = interval.lower..elements[u].upper
        _shift(from: u &+ 1, by: l &- u)
        
      case let (.predecessor(l), .predecessor(u))
        where interval.lower.inverted == elements[l].upper
           && u < endIndex && interval.upper.inverted == elements[u &+ 1].lower:
        // joining-joining:  `interval` joins the intervals at `l` and `u + 1`.
        
        elements[l] = elements[l].lower..elements[u &+ 1].upper
        _shift(from: u &+ 2, by: (l &+ 1) &- (u &+ 2))

      case let (.predecessor(l), .predecessor(u))
        where interval.lower.inverted == elements[l].upper:
        // joining-nonjoining:  `interval` bridges 1 or more intervals, joining interval at `l - 1`.
        
        elements[l] = elements[l].lower..interval.upper
        _shift(from: u &+ 1, by: l &- u)

      case let (.predecessor(l), .predecessor(u))
        where u &+ 1 < endIndex   && interval.upper.inverted == elements[u &+ 1].lower:
        // nonjoining-joining:  `interval` bridges 1 or more intervals, joining interval at `u + 1`.
        
        elements[l &+ 1] = interval.lower..elements[u &+ 1].upper
        _shift(from: u &+ 1, by: l &- u)

      case let (.predecessor(l), .predecessor(u)):
        // nonjoining-nonjoining:  `interval` fully contains 0 or more intervals.
        
        _shift(from: u &+ 1, by: (l &+ 1) &- u)
        elements[l &+ 1] = interval

      case let (.predecessor(l), .successor(u))
        where interval.lower.inverted == elements[l].upper
           && interval.upper.inverted == elements[u].lower:
        // joining-joining:  `interval` joins the intervals at `l` and `u`.
        
        elements[l] = elements[l].lower..elements[u].upper
        _shift(from: u + 1, by: l &- u)

      case let (.predecessor(l), .successor(u))
        where interval.lower.inverted == elements[l].upper:
        // joining-nonjoining:  `interval` bridges 1 or more intervals, joining interval at `l`.
        
        elements[l] = elements[l].lower..interval.upper
        _shift(from: u, by: (l &+ 1) &- u)

      case let (.predecessor(l), .successor(u))
        where interval.upper.inverted == elements[u].lower:
        // nonjoining-joining:  `interval` bridges 1 or more intervals, joining interval at `u`.
        
        elements[l &+ 1] = interval.lower..elements[u].upper
        _shift(from: u &+ 1, by: (l &+ 1) &- u)

      case let (.predecessor(l), .successor(u)):
        // nonjoining-nonjoining:  `interval` fully contains 1 or more intervals.
        
        elements[l &+ 1] = interval
        _shift(from: u, by: (l &+ 2) &- u)

      case let (.successor(l), .predecessor(u))
        where l > startIndex && interval.lower.inverted == elements[l &- 1].upper
           && u &+ 1 < endIndex && interval.upper.inverted == elements[u &+ 1].lower:
        // joining-joining:  `interval` joins the intervals at `l - 1` and `u + 1`.
        
        elements[l &- 1] = elements[l &- 1].lower..elements[u &+ 1].upper
        _shift(from: u &+ 2, by: (l &- 1) &- (u &+ 1))

      case let (.successor(l), .predecessor(u))
        where l > startIndex && interval.lower.inverted == elements[l &- 1].upper:
        // joining-nonjoining:  `interval` fully contains 1 or more intervals, joining interval at `l - 1`.
        
        elements[l &- 1] = elements[l &- 1].lower..interval.upper
        _shift(from: u &+ 1, by: (l &- 1) &- u)

      case let (.successor(l), .predecessor(u))
        where u &+ 1 < endIndex && interval.upper.inverted == elements[u &+ 1].lower:
        // nonjoining-joining:  `interval` fully contains 1 or more intervals, joining interval at `u + 1`.
        
        elements[l] = interval.lower..elements[u &+ 1].upper
        _shift(from: u &+ 2, by: l &- (u &+ 1))

      case let (.successor(l), .predecessor(u)):
        // nonjoining-nonjoining:  `interval` fully contains 0 or more intervals.
        
        _shift(from: u &+ 1, by: l &- u)
        elements[l] = interval

      case let (.successor(l), .successor(u))
        where l > startIndex && interval.lower.inverted == elements[l &- 1].upper
           && interval.upper.inverted == elements[u].lower:
        // joining-joining:  `interval` joins intervals at `l - 1` and `u`.
        
        elements[l &- 1] = elements[l &- 1].lower..elements[u].upper
        _shift(from: u &+ 1, by: (l &- 1) &- u)

      case let (.successor(l), .successor(u))
        where l > startIndex && interval.lower.inverted == elements[l &- 1].upper:
        // joining-nonjoining:  `interval` fully contains 1 or more intervals, joining interval at `l - 1`.
        
        elements[l &- 1] = elements[l &- 1].lower..interval.upper
        _shift(from: u, by: l &- u)

      case let (.successor(l), .successor(u))
        where interval.upper.inverted == elements[u].lower:
        // nonjoining-joining:  `interval` fully contains 1 or more intervals, joining interval at `u`.
        
        elements[l] = interval.lower..elements[u].upper
        _shift(from: u &+ 1, by: l &- u)

      case let (.successor(l), .successor(u)):
        // nonjoining-nonjoining:  `interval` fully contains 0 or more intervals.
        
        _shift(from: u, by: (l &+ 1) &- u)
        elements[l] = interval

    }

  }

  mutating func invert(coverage: Interval<Bound>) {

    guard !isEmpty else { return }

    var buffer = Swift.min(first?.lower ?? coverage.lower, coverage.lower)

    for index in startIndex..<endIndex {
      let interval = elements[index]
      elements[index] = buffer..interval.lower.inverted
      buffer = interval.upper.inverted
    }
    (elements + endIndex).initialize(to: buffer..Swift.max(last?.upper ?? coverage.upper, coverage.upper))
    storage.header.count += 1

  }

  mutating func remove(element: Bound) {

    guard let index = index(of: element) else { return }

    switch elements[index] {

      case let interval where interval.lower.value == element && interval.isDegenerate:
        // Remove interval at `index`
        _shift(from: index &+ 1, by: -1)

      case let interval where interval.lower.value == element:
        // Exclude lower endpoint
        elements[index] = 〖element..interval.upper

      case let interval where interval.upper.value == element:
        // Exclude upper endpoint
        elements[index] = interval.lower..element〗

      case let interval:
        // Split `interval` around `element`
        _shift(from: index &+ 1, by: 1)
        (elements + index).initialize(to: interval.lower..element〗)
        (elements + (index &+ 1)).initialize(to: 〖element..interval.upper)

    }

  }

  func _shift(from sourceIndex: Int, by count: Int) {

    switch count {

      case 0:
        return

      case <--0:
        // Shift left
        let source = elements + sourceIndex
        let target = source.advanced(by: count)
        let end = elements + (endIndex &+ count)
        target.assign(from: source, count: endIndex &- sourceIndex)
        end.deinitialize(count: abs(count))
        storage.header.count = endIndex &+ count

      default /* 0--> */:
        // Shift right
        let source = elements + sourceIndex
        let target = source.advanced(by: count)
        target.moveInitialize(from: source, count: endIndex &- sourceIndex)
        storage.header.count = endIndex &+ count

    }

  }


  mutating func remove(interval: Interval<Bound>) {

    // Check there is actually something to remove.
    guard !(isEmpty || interval.isEmpty) else { return }

    guard !interval.isDegenerate else {
      remove(element: interval.lower.value)
      return
    }

    // Switch on the lower and upper bounds of a search result for `interval`.
    switch *_search(elements: UnsafePointer(elements), for: interval, indices: indices) {

      case let (.exact(l), .exact(u)):
        // `interval` bridges 0 or more intervals.

        // Switch on the intervals at `l` and `u` minus the overlap with `interval`.
        switch (elements[l].lower..interval.lower.inverted,
                interval.upper.inverted..elements[u].upper)
        {

          case let (lowerReplacement, upperReplacement)
            where lowerReplacement.isEmpty && upperReplacement.isEmpty:
            // Clean removal from `l` through `u`.

            _shift(from: u &+ 1, by: l &- (u &+ 1))

          case let (lowerReplacement, upperReplacement)
            where lowerReplacement.isEmpty:
            // Clean removal of interval at `l`. Remove  `l..<u` and update interval at `u`.

            _shift(from: u, by: l &- u)
            elements[l] = upperReplacement

          case let (lowerReplacement, upperReplacement)
            where upperReplacement.isEmpty:
            // Clean removal of interval at `u`. Remove  `l + 1...u` and update interval at `l`.

            _shift(from: u &+ 1, by: (l &+ 1) &- (u &+ 1))
            elements[l] = lowerReplacement

          case let (lowerReplacement, upperReplacement):
            // Partial removal of intervals at `l` and `u`. Update the intervals and remove intervening.

            _shift(from: u, by: (l &+ 1) &- u)
            elements[l] = lowerReplacement
            elements[l &+ 1] = upperReplacement

        }

      case let (.exact(l), .predecessor(u)):
        // `interval` bridges 0 or more intervals and extends the interval at `u`.
        // Remove upper at `l` and remove from `(l + 1)...u`.

        // Switch on the interval at `l` minus `interval`.
        switch elements[l].lower..interval.lower.inverted {

          case let lowerReplacement where lowerReplacement.isEmpty:
            // Clean removal of interval at `l`.

            _shift(from: u &+ 1, by: l &- (u &+ 1))

          case let lowerReplacement:
            // Partial removal of interval at `l`.

            _shift(from: u &+ 1, by: (l &+ 1) &- (u &+ 1))
            elements[l] = lowerReplacement
            
        }
        
      case let (.exact(l), .successor(u)):
        // `interval` bridges 0 or more intervals and extends the interval at `u - 1`.
        // Remove upper at `l` and remove from `(l + 1)...(u - 1)`.

        // Switch on the interval at `l` minus `interval`.
        switch elements[l].lower..interval.lower.inverted {

          case let lowerReplacement where lowerReplacement.isEmpty:
            // Clean removal of interval at `l`.
            _shift(from: u , by: l &- u)

          case let lowerReplacement:
            // Partial removal of interval at `l`.

            _shift(from: u , by: (l &+ 1) &- u)
            elements[l] = lowerReplacement
            
        }
        
      case let (.predecessor(l), .exact(u)):
        // `interval` bridges 0 or more intervals and extends the interval at `l + 1`.
        // Remove lower at `u` and remove from `(l + 1)...(u - 1)`.

        // Switch on the interval at `u` minus `interval`.
        switch interval.upper.inverted..elements[u].upper {

          case let upperReplacment where upperReplacment.isEmpty:
            // Clean removal of interval at `u`.

            _shift(from: u &+ 1, by: (l &+ 1) &- (u &+ 1))

          case let upperReplacement:
            // Partial removal of interval at `u`.

            _shift(from: u, by: (l &+ 1) &- u)
            elements[l &+ 1] = upperReplacement
            
        }
        
      case let (.successor(l), .exact(u)):
        // `interval` bridges 0 or more intervals and prepends the interval at `l`.
        // Remove lower of interval at `u` and remove intervals from `l...(u - 1)`.

        // Switch on the interval at `u` minus `interval`.
        switch interval.upper.inverted..elements[u].upper {

          case let upperReplacement where upperReplacement.isEmpty:
            // Clean removal of interval at `u`.

            _shift(from: u &+ 1, by: l &- (u &+ 1))

          case let upperReplacement:
            // Partial removal of interval at `u`.

            _shift(from: u, by: l &- u)
            elements[l] = upperReplacement
          
        }

      case let (.predecessor(l), .predecessor(u)):
        // `interval` fully contains 0 or more intervals.

        _shift(from: u &+ 1, by: l &- u)

      case let (.predecessor(l), .successor(u)):
        // `interval` fully contains 1 or more intervals.
        // Remove from `(l + 1)...(u - 1)`.

        _shift(from: u, by: (l &+ 1) &- u)
        
      case let (.successor(l), .predecessor(u)):
        // `interval` fully contains 0 or more intervals. Remove from `l` to `u`.

        _shift(from: u &+ 1, by: l &- (u &+ 1))
        
      case let (.successor(l), .successor(u)):
        // `interval` fully contains 0 or more intervals.

        _shift(from: u, by: l &- u)

     }

  }

}

extension IntervalMapBuffer: CustomStringConvertible {

  var description: String { return _describe(storage, indices: indices) }

}

extension IntervalMapBuffer: RandomAccessCollection {

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

  subscript(index: Int) -> Element { return elements[index] }
  subscript(subRange: Range<Int>) -> SubSequence { return SubSequence(buffer: self, indices: subRange) }

}

extension IntervalMapBuffer where Bound:Strideable {

  func nearest(to element: Bound) -> Int? {
    return _nearest(to: element, elements: elements, indices: indices)
  }

}

// MARK: - Buffer Slice

private struct IntervalMapBufferSlice<Bound:Comparable>: _DestructorSafeContainer {

  typealias Buffer = IntervalMapBuffer<Bound>
  typealias BufferSlice = IntervalMapBufferSlice<Bound>
  typealias Storage = IntervalMapStorage<Bound>
  typealias Element = Interval<Bound>
  typealias _Element = Element
  typealias Index = Int
  typealias SubSequence = BufferSlice
  typealias Indices = CountableRange<Int>

  var storage: Storage
  let elements: UnsafeMutablePointer<Element>

  @inline(__always) mutating func isUniquelyReferenced() -> Bool {
    return Swift.isKnownUniquelyReferenced(&storage)
  }

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

  /// Returns whether the buffer holds an interval containing `interval`.
  func contains(_ interval: Interval<Bound>) -> Bool {
    guard !(isEmpty || interval.isEmpty),
      case (.exact(let lowerIndex),
            .exact(let upperIndex)) = *_search(elements: elements, for: interval, indices: indices),
      lowerIndex == upperIndex
      else
    {
      return false
    }
    return true
  }

  /// Returns whether the buffer holds an interval containing `element`.
  func contains(_ element: Bound) -> Bool {
    guard case .exact = _search(elements: elements, for: element】, indices: indices) else {
      return false
    }
    return true
  }

  /// Returns the index of the interval containing `element` or `nil`.
  func index(for element: Bound) -> Int? {
    guard case .exact(let index) = _search(elements: elements, for: element】, indices: indices) else {
      return nil
    }
    return index
  }

  /// Returns the index of the interval fully containing `interval` or `nil`.
  func index(of interval: Interval<Bound>) -> Int? {
    guard !(isEmpty || interval.isEmpty),
      case (.exact(let lowerIndex),
            .exact(let upperIndex)) = *_search(elements: elements, for: interval, indices: indices),
      lowerIndex == upperIndex
      else
    {
      return nil
    }

    return lowerIndex
  }

}

extension IntervalMapBufferSlice: RandomAccessCollection {

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

extension IntervalMapBufferSlice: CustomStringConvertible {

  var description: String { return _describe(storage, indices: indices) }

}

extension IntervalMapBufferSlice where Bound:Strideable {

  func nearest(to element: Bound) -> Int? {
    return _nearest(to: element, elements: elements, indices: indices)
  }

}

// MARK: - Interval Map
public struct IntervalMap<Bound:Comparable>: RandomAccessCollection, _DestructorSafeContainer {

  fileprivate typealias Buffer = IntervalMapBuffer<Bound>
  fileprivate typealias Storage = IntervalMapStorage<Bound>

  public typealias Element = Interval<Bound>
  public typealias _Element = Element
  public typealias Index = Int
  public typealias SubSequence = IntervalMapSlice<Bound>
  public typealias Indices = CountableRange<Int>


  fileprivate var buffer: Buffer

  fileprivate mutating func ensureUnique(withCapacity minimumCapacity: Int) {
    guard !buffer.isUniquelyReferenced(withCapacity: minimumCapacity) else { return }
    buffer = Buffer(buffer: buffer, withCapacity: Swift.max(buffer.count, minimumCapacity))
  }

  public func min() -> Interval<Bound>? { return first }
  public func max() -> Interval<Bound>? { return last }

  /// The interval consisting of `min().lower` and `max().upper` or `nil`.
  public var coverage: Interval<Bound>? {
    guard let first = first, let last = last else { return nil }
    return first.lower..last.upper
  }

  /// Whether the collection contains an interval that fully contains `interval`.
  public func contains(_ interval: Interval<Bound>) -> Bool {
    return buffer.contains(interval)
  }

  /// Whether the collection contains an interval that contains `element`.
  public func contains(_ element: Bound) -> Bool {
    return buffer.contains(element)
  }

  /// Index of the interval containing `element`, or `nil`.
  public func index(of element: Bound) -> Int? {
    return buffer.index(of: element)
  }

  /// The index of the element within which `interval` is fully contained, or `nil`.
  public func index(of interval: Interval<Bound>) -> Int? {
    return buffer.index(of: interval)
  }

  public init() {
    buffer = Buffer(minimumCapacity: 0)
  }

  public init(minimumCapacity: Int) {
    buffer = Buffer(minimumCapacity: minimumCapacity)
  }

  public init(_ element: Bound) {
    buffer = Buffer(interval: Interval(degenerate: element))
  }

  public init(_ interval: Interval<Bound>) {
    buffer = Buffer(interval: interval)
  }

  public init<Source>(_ intervals: Source)
    where Source:Sequence, Source.Iterator.Element == Interval<Bound>
  {
    buffer = Buffer(intervals: intervals)
  }

  /// Insert `element` into the collection. If an existing element contains `element`, no action is taken.
  /// If `element` prepends or extends an existing element, the existing element is updated.
  /// Otherwise, a new element is inserted for `element`.
  public mutating func insert(_ element: Bound) {
    ensureUnique(withCapacity: count &+ 1)
    buffer.insert(element: element)
  }

  /// Inserts the bound values in `interval` into the collection.
  public mutating func insert(_ interval: Interval<Bound>) {
    ensureUnique(withCapacity: count &+ 1)
    buffer.insert(interval: interval)
  }

  /// Removes `element` from the collection.
  public mutating func remove(_ element: Bound) {
    ensureUnique(withCapacity: count &+ 1)
    buffer.remove(element: element)
  }

  /// Removes the bound values in `interval` from the collection.
  public mutating func remove(_ interval: Interval<Bound>) {
    ensureUnique(withCapacity: count &+ 1)
    buffer.remove(interval: interval)
  }

  /// Returns a `IntervalMap` whose elements consist of the gaps between `intervals` over `coverage`.
  public func inverted(coverage: Interval<Bound>) -> IntervalMap<Bound> {
    var result = self
    result.invert(coverage: coverage)
    return result
  }

  /// Replaces `ranges` the gaps between `ranges` over `coverage`.
  public mutating func invert(coverage: Interval<Bound>) {
    ensureUnique(withCapacity: count &+ 1)
    buffer.invert(coverage: coverage)
  }

}

extension IntervalMap/*: RandomAccessIndexable*/ {

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

extension IntervalMap: Collection {

  public var startIndex: Int { return 0 }
  public var endIndex: Int { return buffer.endIndex }
  public var count: Int { return buffer.count }


  public var indices: CountableRange<Int> { return 0 ..< count }

  public subscript(index: Int) -> Interval<Bound> { return buffer.elements[index] }

  public subscript(subRange: Range<Int>) -> SubSequence { return SubSequence(buffer: buffer[subRange]) }

}

extension IntervalMap: Equatable {

  public static func ==(lhs: IntervalMap<Bound>, rhs: IntervalMap<Bound>) -> Bool {
    guard lhs.buffer.identity != rhs.buffer.identity else { return true }
    switch (lhs.coverage, rhs.coverage) {
      case (nil, _), (_, nil): return false
      case let (c1, c2) where c1 != c2: return false
      default: return lhs.buffer.elementsEqual(rhs.buffer)
    }
  }

}

extension IntervalMap: ExpressibleByArrayLiteral {

  public init(arrayLiteral: Element...) {
    buffer = Buffer(intervals: arrayLiteral)
  }

}

extension IntervalMap where Bound:Strideable {

  public func nearest(to element: Bound) -> Int? {
    return buffer.nearest(to: element)
  }

}

// MARK: - Interval Map Slice

public struct IntervalMapSlice<Bound:Comparable>: RandomAccessCollection, _DestructorSafeContainer {

  fileprivate typealias BufferSlice = IntervalMapBufferSlice<Bound>
  fileprivate typealias Storage = IntervalMapStorage<Bound>

  public typealias Index = Int
  public typealias SubSequence = IntervalMapSlice<Bound>
  public typealias Element = Interval<Bound>
  public typealias _Element = Element
  public typealias Indices = CountableRange<Int>


  fileprivate var buffer: BufferSlice

  fileprivate init(buffer: BufferSlice) {  self.buffer = buffer }

  public func min() -> Interval<Bound>? { return first }
  public func max() -> Interval<Bound>? { return last }

  /// The range containing the min `Bound` and the max `Bound` or nil if the collection is empty.
  public var coverage: Interval<Bound>? {
    guard let first = first, let last = last else { return nil }
    return first.lower..last.upper
  }

  public func contains(_ interval: Interval<Bound>) -> Bool { return buffer.contains(interval) }
  public func contains(_ element: Bound) -> Bool { return buffer.contains(element) }

  public func index(of element: Bound) -> Int? { return buffer.index(for: element) }
  public func index(of interval: Element) -> Int? { return buffer.index(of: interval) }

}

extension IntervalMapSlice/*: RandomAccessIndexable*/ {

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

extension IntervalMapSlice: Collection {

  public var startIndex: Index {  return buffer.startIndex }
  public var endIndex: Index {  return buffer.endIndex }
  public var count: Int {  return buffer.count }

  public subscript(index: Index) -> Element {
    precondition(index < buffer.endIndex, "Invalid index '\(index)'")
    return buffer[index]
  }

  public subscript(subRange: Range<Int>) -> SubSequence {
    return SubSequence(buffer: buffer[subRange.lowerBound << 1 ..< subRange.upperBound << 1])
  }

}

extension IntervalMapSlice: Equatable {

  public static func ==(lhs: IntervalMapSlice, rhs: IntervalMapSlice) -> Bool {
    guard lhs.buffer.identity != rhs.buffer.identity || lhs.indices != rhs.indices else { return true }
    switch (lhs.coverage, rhs.coverage) {
      case (nil, _), (_, nil): return false
      case let (c1, c2) where c1 != c2,
           let (c1, c2) where c1 == c2 && lhs.buffer.count != rhs.buffer.count: return false
      default: return lhs.buffer.elementsEqual(rhs.buffer)
    }
  }
}

extension IntervalMapSlice where Bound:Strideable {

  public func nearest(to element: Bound) -> Int? {
    return buffer.nearest(to: element)
  }

}

// MARK: - Supporting functions

/// Locates the index within a contiguous block of intervals that satisfies one of the following:
///
/// - The interval contains the target value.
/// - The target precedes the interval at the index.
/// - The target follows the interval at the index or the collection is empty and the index == 0.
///
/// - Parameters:
///   - elements: Pointer to memory containing the intervals to search.
///   - target: The endpoint to locate within `elements`
///   - indices: The range of indexes within which the search shall occur.
/// - Returns: `SearchIndex` value encapsulating the index and how it relates to `target`.
private func _search<B>(elements: UnsafePointer<Interval<B>>,
                     for target: DirectedIntervalEndpoint<B>,
                     indices: CountableRange<Int>) -> SearchIndex
  where B:Comparable

{

  guard !indices.isEmpty else {
    assert(false)
    return .successor(indices.lowerBound)
  }

  let index = indices.count / 2 &+ indices.lowerBound
  let element = elements[index]

  guard !element.contains(target) else { return .exact(index) }

  return element.upper < target
    ? indices.count == 1 || index &+ 1 == indices.upperBound
      ? .predecessor(index)
      : _search(elements: elements, for: target, indices: indices.suffix(from: index &+ 1))
    : indices.count == 1 || index == indices.lowerBound
      ? .successor(index)
      : _search(elements: elements, for: target, indices: indices.prefix(upTo: index))

}

/// Locates the range of indexes within a contiguous block of intervals that overlap `target`.
/// If no overlapping intervals exist, a single element range reflecting `target`'s location is returned.
///
/// - Parameters:
///   - elements: Pointer to memory containing the intervals to search.
///   - target: The value to locate within `elements`, must not be empty.
///   - indices: The range of indexes within which the search shall occur.
/// - Returns: Range of `SearchIndex` values encapsulating the indexes and how they relates to `target`.
private func _search<B>(elements: UnsafePointer<Interval<B>>,
                     for target: Interval<B>,
                     indices: CountableRange<Int>) -> ClosedRange<SearchIndex>
  where B:Comparable
{
  guard !indices.isEmpty else { return .successor(indices.lowerBound)... }

  let lowerSearch: SearchIndex = _search(elements: elements, for: target.lower, indices: indices)
  let upperSearch: SearchIndex = _search(elements: elements, for: target.upper, indices: indices)

  return lowerSearch...upperSearch

}

private func _nearest<B>(to element: B,
                      elements: UnsafePointer<Interval<B>>,
                      indices: CountableRange<Int>) -> Int?
  where B:Strideable
{

  guard !indices.isEmpty else { return nil }

  switch _search(elements: elements, for: element】, indices: indices) {

    case .exact(let index):
      return index

    case .predecessor(let index):
      guard index &+ 1 < indices.upperBound else { return index }
      let 𝝙predecessor = elements[index].upper.value.distance(to: element)
      let 𝝙successor = element.distance(to: elements[index &+ 1].lower.value)
      return 𝝙predecessor < 𝝙successor ? index : index &+ 1

    case .successor(let index):
      guard index > indices.lowerBound else { return index }
      let 𝝙predecessor = elements[index &- 1].upper.value.distance(to: element)
      let 𝝙successor = element.distance(to: elements[index].lower.value)
      return 𝝙predecessor < 𝝙successor ? index &- 1 : index

  }

}


/// Forms a collection of intervals sorted by their lower endpoints and merge when possible.
private func _combiningSort<B, S>(_ source: S) -> ContiguousArray<Interval<B>>
  where B:Comparable, S:Sequence, S.Iterator.Element == Interval<B>
{
  var result: ContiguousArray<Interval<B>> = []

  let sortedIntervals = source.sorted(by: {$0.lower < $1.lower})

  guard var currentInterval = sortedIntervals.first else {
    return []
  }

  for interval in sortedIntervals.dropFirst() {
    guard let mergedInterval = currentInterval.union(interval) else {
      result.append(currentInterval)
      currentInterval =  interval
      continue
    }
    currentInterval = mergedInterval
  }

  result.append(currentInterval)

  return result
}

/// Creates a description for the intervals contained by `source` over `indices`.
private func _describe<B>(_ source: IntervalMapStorage<B>, indices: CountableRange<Int>) -> String
  where B:Comparable
{
  var result = "["
  let start = UnsafePointer(source.elements + indices.lowerBound)
  let buffer = UnsafeBufferPointer<Interval<B>>(start: start, count: indices.count)
  result.append(buffer.map({$0.description}).joined(separator: ", "))
  result.append("]")
  return result
}
