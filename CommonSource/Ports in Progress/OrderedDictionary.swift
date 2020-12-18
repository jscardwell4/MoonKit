//
//  OrderedDictionary.swift
//  MoonKit
//
//  Created by Jason Cardwell on 12/18/20.
//  Copyright © 2020 Moondeer Studios. All rights reserved.
//
import Foundation

// MARK: - OrderedDictionaryStorage
/// Specialization of `HashedStorage` for an ordered dictionary
fileprivate final class OrderedDictionaryStorage<Key:Hashable, Value>: HashedStorage {

  typealias Storage = OrderedDictionaryStorage<Key, Value>
  typealias Header = HashedStorageHeader

  /// Returns the number of bytes required to store the keys for a given `capacity`.
  @inline(__always) static func bytesForKeys(_ capacity: Int) -> Int {
    let padding = max(0, MemoryLayout<Key>.alignment - MemoryLayout<Int>.alignment)
    return MemoryLayout<Key>.stride * capacity + padding
  }

  var keysBytes: Int { return Storage.bytesForKeys(header.representedCapacity) }
  var keys: UnsafeMutablePointer<Key> {
    let rawKeys = bucketMapAddress.advanced(by: bucketMapBytes)
    return rawKeys.bindMemory(to: Key.self, capacity: header.capacity)
  }

  /// Returns the number of bytes required to store the values for a given `capacity`.
  @inline(__always) static func bytesForValues(_ capacity: Int) -> Int {
    let maxPrevAlignment = max(MemoryLayout<Key>.alignment, MemoryLayout<Int>.alignment)
    let padding = max(0, MemoryLayout<Value>.alignment - maxPrevAlignment)
    return MemoryLayout<Value>.stride * capacity + padding
  }

  var valuesBytes: Int { return Storage.bytesForValues(header.representedCapacity) }
  var values: UnsafeMutablePointer<Value> {
    let rawValues = bucketMapAddress.advanced(by: bucketMapBytes + keysBytes)
    return rawValues.bindMemory(to: Value.self, capacity: header.capacity)
  }

  /// Create a new storage instance.
  static func create(minimumCapacity: Int) -> OrderedDictionaryStorage {
    let representedCapacity = round2(minimumCapacity)
    let requiredCapacity = bytesForBucketMap(representedCapacity)
                         + bytesForKeys(representedCapacity)
                         + bytesForValues(representedCapacity)

    let storage = super.create(minimumCapacity: requiredCapacity) {
      Header(capacity: $0.capacity,
             representedCapacity: representedCapacity,
             bucketMapAddress: $0.withUnsafeMutablePointerToElements({pointerCast($0)}))
    }

    return storage as! Storage
  }

  deinit {
    let keys = self.keys, values = self.values
    for bucket in bucketMap { (keys + bucket.offset).deinitialize(count: 1); (values + bucket.offset).deinitialize(count: 1) }
    let bucketMapBytes = self.bucketMapBytes
    withUnsafeMutablePointers { $1.deinitialize(count: bucketMapBytes); $0.deinitialize(count: 1) }
  }

}

// MARK: - OrderedDictionaryBuffer
fileprivate struct OrderedDictionaryBuffer<Key:Hashable, Value>: _DestructorSafeContainer {

  typealias Element = (key: Key, value: Value)

  typealias _Element = Element
  typealias Buffer = OrderedDictionaryBuffer<Key, Value>
  typealias BufferSlice = OrderedDictionaryBufferSlice<Key, Value>
  typealias Storage = OrderedDictionaryStorage<Key, Value>

  typealias PendingAssignments = [Bucket:Element]

  var indices: CountableRange<Int> { return CountableRange(uncheckedBounds: (lower: startIndex, upper: endIndex)) }

  var storage: Storage
  let keys: UnsafeMutablePointer<Key>
  let values: UnsafeMutablePointer<Value>
  let bucketMap: BucketMap

  @inline(__always) mutating func isUniquelyReferenced() -> Bool { return Swift.isKnownUniquelyReferenced(&storage) }

  @inline(__always) mutating func requestUniqueBuffer(minimumCapacity: Int = 0) -> Buffer? {
    return isUniquelyReferenced() && capacity >= minimumCapacity ? self : nil
  }

  var startIndex: Int { return 0 }
  var endIndex = 0

  var count: Int { return endIndex }

  var capacity: Int { return storage.header.representedCapacity }
  var remainingCapacity: Int { return capacity &- count }

  /// Returns the minimum capacity for storing `count` elements.
  @inline(__always)
  static func minimumCapacityFor(_ count: Int) -> Int {
    // `requestedCount + 1` below ensures that we don't fill in the last hole
    let x = Int(Double(count) * maxLoadFactorInverse), y = count &+ 1
    return x > y ? x : y
  }

  var identity: UnsafeRawPointer { return bucketMap.identity }

  init(storage: Storage) {
    self.storage = storage
    bucketMap = storage.bucketMap
    keys = storage.keys
    values = storage.values
    endIndex = storage.count
  }

  init(minimumCapacity: Int) {
    let requiredCapacity = Buffer.minimumCapacityFor(minimumCapacity)
    let storage = Storage.create(minimumCapacity: requiredCapacity)
    self = Buffer(storage: storage)
  }

  /// Create a clone of `buffer` with the specified `capacity`.
  init(buffer: Buffer, withCapacity capacity: Int) {
    guard capacity != buffer.capacity else { self = Buffer(buffer: buffer); return }

    let requiredCapacity = capacity > buffer.count ? capacity : buffer.count &+ 1
    let storage = Storage.create(minimumCapacity: requiredCapacity)

    var newBuffer = Buffer(storage: storage)
    newBuffer.append(contentsOf: buffer)

    self = newBuffer
  }

  /// Create a clone of `buffer`.
  init(buffer: Buffer) {

    let storage = Storage.create(minimumCapacity: buffer.capacity)
    storage.withUnsafeMutablePointers {
      newValue, newElements in
        buffer.storage.withUnsafeMutablePointers {
          bufferValue, bufferElements in

          newElements.withMemoryRebound(to: Int.self, capacity: newValue.pointee.capacity) {
            newBufferMapStorage in

            bufferElements.withMemoryRebound(to: Int.self, capacity: bufferValue.pointee.capacity) {
              sourceBufferMapStorage in
                newBufferMapStorage.initialize(from: sourceBufferMapStorage, count: buffer.capacity * 2 + 1)
            }
          }

          let newBucketMap = newValue.pointee.bucketMap
          let bucketMapBytes = HashedStorage.bytesForBucketMap(buffer.capacity)


          newElements.advanced(by: bucketMapBytes).withMemoryRebound(to: Key.self, capacity: newValue.pointee.capacity) {
            newKeyStorage in

            bufferElements.advanced(by: bucketMapBytes).withMemoryRebound(to: Key.self, capacity: bufferValue.pointee.capacity) {
              sourceKeyStorage in

              newKeyStorage.advanced(by: buffer.capacity).withMemoryRebound(to: Value.self, capacity: newValue.pointee.capacity) {
                newValueStorage in


                sourceKeyStorage.advanced(by: buffer.capacity).withMemoryRebound(to: Value.self, capacity: bufferValue.pointee.capacity) {
                  sourceValueStorage in

                  for bucket in newBucketMap {
                    let newKeyAddress = newKeyStorage.advanced(by: bucket.offset)
                    let key = sourceKeyStorage.advanced(by: bucket.offset).pointee
                    newKeyAddress.initialize(to: key)
                    let newValueAddress = newValueStorage.advanced(by: bucket.offset)
                    let value = sourceValueStorage.advanced(by: bucket.offset).pointee
                    newValueAddress.initialize(to: value)
                  }

                }
              }
            }
          }

          newValue.pointee.count = bufferValue.pointee.count
      }
    }

    self = Buffer(storage: storage)
  }

  /// Returns whether `key` is present in the buffer.
  @inline(__always) func contains(key: Key) -> Bool { let (_, found) = find(key); return found }

  /// Returns the public-facing index for `key`; returns `nil` when `key` is not found.
  @inline(__always) func index(for key: Key) -> Int? {
    let (bucket, found) = find(key)
    guard found, let index = bucketMap[bucket] else { return nil }
    return index
  }

  @inline(__always) func key(at index: Int) -> Key {
    return keys[bucketMap[index].offset]
  }

  /// Returns the hash value of `key` squeezed into `capacity`
  @inline(__always) func idealBucket(for key: Key, capacity: Int) -> Bucket {
    return Bucket(offset: _squeezeHashValue(key.hashValue, 0..<capacity), capacity: capacity)
  }

  /// Returns the bucket containing `key` or `nil` if no bucket contains `key`.
  @inline(__always) func currentBucket(for key: Key) -> Bucket? {
    let (bucket, found) = find(key)
    return found ? bucket : nil
  }

  /// Returns an empty bucket suitable for holding `key` or `nil` if a bucket already contains `key`.
  @inline(__always) func emptyBucket(for key: Key, pending: PendingAssignments? = nil) -> Bucket? {
    let (bucket, found) = find(key, pending: pending)
    return found ? nil : bucket
  }

  /// Returns the position for `element` or `nil` if `element` is not found.
  @inline(__always) func index(of element: Element) -> Int? {
    guard count > 0 else { return nil }
    let (bucket, found) = find(element.key)
    guard found, let index = bucketMap[bucket] else { return nil }
    //FIXME: Shouldn't we test the value?
    return index
  }

  func _find(key: Key, startBucket: Bucket) -> (bucket: Bucket, found: Bool) {
    var bucket = startBucket
    repeat {
      guard bucketMap[bucket] != nil else { return (bucket, false) }
      guard keys[bucket.offset] != key else { return (bucket, true) }
      bucket = bucket.advanced(by: 1)
    } while bucket != startBucket

    fatalError("failed to locate hole")
  }

  func _find(key: Key, startBucket: Bucket, pending: PendingAssignments) -> (bucket: Bucket, found: Bool) {
    var bucket = startBucket
    repeat {
      switch (bucketMap[bucket], pending[bucket]) {
        case (nil, nil): return (bucket, false)
        case (.some, _) where keys[bucket.offset] == key: return (bucket, true)
        case (_, let element?) where element.key == key: return (bucket, true)
        default: bucket = bucket.advanced(by: 1)
      }
    } while bucket != startBucket

    fatalError("failed to locate hole")
  }

  /// Returns the current bucket for `key` and `true` when `key` is located;
  /// returns an open bucket for `key` and `false` otherwise
  /// - parameter pending: Map of bucket to element assignments to be treated as if they have already been committed.
  /// - requires: At least one empty bucket
  @inline(__always) func find(_ key: Key, pending: PendingAssignments? = nil) -> (bucket: Bucket, found: Bool) {
    let startBucket = idealBucket(for: key, capacity: capacity)
    guard let pending = pending else { return _find(key: key, startBucket: startBucket) }
    return _find(key: key, startBucket: startBucket, pending: pending)
  }

  /// Initializes a fresh bucket with `element` at `position` unless `element` is a duplicate.
  /// Returns `true` if a bucket was initialized and `false` otherwise.
  @discardableResult
  func initialize(element: Element, at position: Int) -> Bool {
    guard let bucket = emptyBucket(for: element.key) else { return false }
    (keys + bucket.offset).initialize(to: element.key)
    (values + bucket.offset).initialize(to: element.value)
    bucketMap[position] = bucket
    return true
  }

  @discardableResult func update(element: Element) -> Element {
    guard let offset = currentBucket(for: element.key)?.offset else {
      fatalError("bucketless element: '\(element)'")
    }
    let oldElement = (key: keys[offset], value: values[offset])
    (keys + offset).initialize(to: element.key)
    (values + offset).initialize(to: element.value)
    return oldElement
  }

  /// Attempts to move the values of the buckets near `hole` into buckets nearer to their 'ideal' bucket
  func patch(hole: Bucket, idealBucket: Bucket) {
    var hole = hole
    var start = idealBucket
    while bucketMap[start.predecessor()] != nil { start = start.advanced(by: -1) }

    var lastInChain = hole
    var last = lastInChain.successor()
    while bucketMap[last] != nil { lastInChain = last; last = last.advanced(by: 1) }

    let capacity = self.capacity
    while hole != lastInChain {
      last = lastInChain

      FillHole: while last != hole {
        let bucket = self.idealBucket(for: keys[last.offset], capacity: capacity)

        switch (bucket >= start, bucket <= hole) {
          case (true, true) where start <= hole, (true, _) where start > hole, (_, true) where start > hole:
            break FillHole
          default:
            last = last.advanced(by: -1)
        }
      }

      guard last != hole else { break }
      (keys + hole.offset).initialize(to: (keys + last.offset).move())
      (values + hole.offset).initialize(to: (values + last.offset).move())
      bucketMap.replace(bucket: last, with: hole)
      hole = last
    }

  }

  mutating func remove(key: Key) -> Element? {
    let (bucket, found) = find(key)
    guard found else { return nil }
    let oldElement = (key: keys[bucket.offset], value: values[bucket.offset])
    destroy(bucket: bucket)
    return oldElement
  }

  /// Removes elements common with `elements`.
  mutating func remove<Source:Sequence>(contentsOf elements: Source) where Source.Iterator.Element == Element {

    var ranges = CountableRangeMap<Int>()
    for element in elements {
      guard let index = index(of: element) else { continue }
      ranges.insert(index)
    }

    guard ranges.count > 0 else { return }

    for range in ranges.reversed() { removeSubrange(range) }

  }

  mutating func destroy(bucket: Bucket) {
    let idealBucket = self.idealBucket(for: keys[bucket.offset], capacity: capacity)
    (keys + bucket.offset).deinitialize()
    (values + bucket.offset).deinitialize()
    bucketMap[bucket] = nil
    endIndex = endIndex &- 1
    storage.count = endIndex
    patch(hole: bucket, idealBucket: idealBucket)
  }

  /// Uninitializes the bucket for `position`, adjusts positions and `endIndex` and patches the hole.
  mutating func destroy(at position: Index) { destroy(bucket: bucketMap[position]) }

}

// MARK: - RandomAccessCollection
extension OrderedDictionaryBuffer: RandomAccessCollection {
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

// MARK: - MutableCollection
extension OrderedDictionaryBuffer: MutableCollection {

  subscript(index: Int) -> Element {
    get {
      precondition(index >= startIndex && index < endIndex, "invalid index '\(index)'")
      let offset = bucketMap[index].offset
      return (key: keys[offset], value: values[offset])
    }
    set {
      precondition(index >= startIndex && index < endIndex, "invalid index '\(index)'")
      guard !contains(key: newValue.key) else { return }
      let offset = bucketMap[index].offset
      (keys + offset).deinitialize()
      (values + offset).deinitialize()
      initialize(element: newValue, at: index)
    }
  }

  subscript(subRange: Range<Int>) -> SubSequence {
    get { return SubSequence(buffer: self, indices: subRange) }
    set { replaceSubrange(subRange, with: newValue) }
  }

}

// MARK: RangeReplaceableCollection
extension OrderedDictionaryBuffer: RangeReplaceableCollection {

  /// Create an empty instance.
  init() { self = Buffer(minimumCapacity: 0) }

  mutating func replaceSubrange<Source:Collection>(_ subRange: Range<Int>, with newElements: Source)
    where Source.Iterator.Element == Element
  {
    removeSubrange(subRange)
    insert(contentsOf: newElements, at: subRange.lowerBound)
  }

  /// Creates an instance that contains `elements`.
  init<Source:Sequence>(_ elements: Source) where Source.Iterator.Element == Element {
    self = Buffer(Array(elements))
  }

  init<Source:Collection>(_ elements: Source) where Source.Iterator.Element == Element {
    let requiredCapacity = Buffer.minimumCapacityFor(numericCast(elements.count) + 1)
    storage = Storage.create(minimumCapacity: requiredCapacity)
    keys = storage.keys
    values = storage.values
    bucketMap = storage.bucketMap
    endIndex = 0

    for element in elements {
      guard let bucket = emptyBucket(for: element.key) else { continue }
      (keys + bucket.offset).initialize(to: element.key)
      (values + bucket.offset).initialize(to: element.value)
      bucketMap[endIndex] = bucket
      endIndex = endIndex &+ 1
      storage.count = endIndex
    }
  }

  /// Append `x` to `self`.
  ///
  /// Applying `successor()` to the index of the new element yields
  /// `self.endIndex`.
  ///
  /// - Complexity: Amortized O(1).
  mutating func append(_ element: Element) {
    guard initialize(element: element, at: endIndex) else { return }
    endIndex = endIndex &+ 1
    storage.count = endIndex
  }


  /// Append the elements of `newElements` to `self`.
  ///
  /// - Complexity: O(*length of result*).
  mutating func append<Source:Sequence>(contentsOf newElements: Source) where Source.Iterator.Element == Element {
    for element in newElements { append(element) }
  }


  /// Insert `newElement` at index `i`.
  ///
  /// Invalidates all indices with respect to `self`.
  ///
  /// - Complexity: O(`self.count`).
  mutating func insert(_ newElement: Element, at i: Index) {
    guard let bucket = emptyBucket(for: newElement.key) else { return }
    (keys + bucket.offset).initialize(to: newElement.key)
    (values + bucket.offset).initialize(to: newElement.value)

    bucketMap.insert(contentsOf: CollectionOfOne(bucket), at: i)
    endIndex = endIndex &+ 1
    storage.count = endIndex
  }


  /// Insert `newElements` at index `i`.
  ///
  /// Invalidates all indices with respect to `self`.
  ///
  /// - Complexity: O(`self.count + newElements.count`).
  mutating func insert<Source:Collection>(contentsOf newElements: Source, at i: Index) where Source.Iterator.Element == Element {

    // Insert new elements, accumulating a list of their buckets
    var newElementsBuckets = [Bucket](minimumCapacity: numericCast(newElements.count))

    var pending: PendingAssignments = [:]

    for element in newElements {
      guard let bucket = emptyBucket(for: element.key, pending: pending) else { continue }
      (keys + bucket.offset).initialize(to: element.key)
      (values + bucket.offset).initialize(to: element.value)
      pending[bucket] = element
      newElementsBuckets.append(bucket)
    }

    // Adjust positions
    bucketMap.insert(contentsOf: newElementsBuckets, at: i)

    // Adjust count and endIndex
    endIndex = endIndex &+ newElementsBuckets.count
    storage.count = endIndex

  }


  /// Remove the element at index `i`.
  ///
  /// Invalidates all indices with respect to `self`.
  ///
  /// - Complexity: O(`self.count`).
  @discardableResult mutating func remove(at i: Index) -> Element { let result = self[i]; destroy(at: i); return result }


  /// Remove the element at `startIndex` and return it.
  ///
  /// - Complexity: O(`self.count`)
  /// - Requires: `!self.isEmpty`.
  mutating func removeFirst() -> Element { return remove(at: startIndex) }


  /// Remove the first `n` elements.
  ///
  /// - Complexity: O(`self.count`)
  /// - Requires: `n >= 0 && self.count >= n`.
  mutating func removeFirst(_ n: Int) { removeSubrange(startIndex..<startIndex.advanced(by: n)) }


  /// Remove the indicated `subRange` of elements.
  ///
  /// Invalidates all indices with respect to `self`.
  ///
  /// - Complexity: O(`self.count`).
  mutating func removeSubrange(_ subRange: Range<Index>) {
    let subRange = CountableRange(subRange)
    switch subRange.count {
      case 0: return
      case 1: destroy(at: subRange.lowerBound)
    default: //case let delta:
//        var buckets: [Bucket] = [], idealBuckets: [Bucket] = []
      //TODO: Come back to this once other crashes stop
        var destroyed = 0
        for position in subRange {
          destroy(at: position &- destroyed)
          destroyed = destroyed &+ 1
//          let bucket = bucketMap[offset(position: position)]
//          buckets.append(bucket)
//          let idealBucket = suggestBucket(forValue: storage.key(at: bucket.offset), capacity: manager.value.representedCapacity)
//          idealBuckets.append(idealBucket)
//          storage.destroy(at: bucket.offset)
//          patch(hole: bucket, idealBucket: idealBucket)
        }
//        for (bucket, idealBucket) in zip(buckets, idealBuckets) { patch(hole: bucket, idealBucket: idealBucket) }

//        bucketMap.removeSubrange(Range(offset(position: subRange)))
//        manager.value.count = manager.value.count &- delta
//        endIndex = endIndex &- delta
    }

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
  mutating func removeAll(keepingCapacity keepCapacity: Bool) {
    guard keepCapacity else { self = Buffer.init(); return }
    for bucket in bucketMap { (keys + bucket.offset).deinitialize(); (values + bucket.offset).deinitialize() }
    bucketMap.initializeStorage()
    endIndex = 0
    storage.count = 0
  }

}

// MARK: CustomStringConvertible, CustomDebugStringConvertible
extension OrderedDictionaryBuffer: CustomStringConvertible, CustomDebugStringConvertible {

  var elementsDescription: String {
    if count == 0 { return "[:]" }

    var result = "["
    var first = true
    for position in CountableRange(uncheckedBounds: (lower: startIndex, upper: endIndex)) {
      if first { first = false } else { result += ", " }
      let bucket = bucketMap[position]
      debugPrint(keys[bucket.offset], terminator: ": ", to: &result)
      debugPrint(values[bucket.offset], terminator: "",   to: &result)
    }
    result += "]"
    return result
  }

  var description: String { return elementsDescription }

  var debugDescription: String {
    var result = elementsDescription + "\n"
    result += "startIndex = \(startIndex)\n"
    result += "endIndex = \(endIndex)\n"
    result += "count = \(count)\n"
    result += "capacity = \(capacity)\n"
    for position in CountableRange(uncheckedBounds: (lower: startIndex, upper: endIndex)) {
      let bucket = bucketMap[position]
      result += "position \(position) ➞ bucket \(bucket) [\(keys[bucket.offset]), \(values[bucket.offset]))]\n"
    }
    for position in endIndex..<capacity {
      result += "position \(position), empty\n"
    }
    for bucketOffset in 0..<bucketMap.capacity {
      let bucket = Bucket(offset: bucketOffset, capacity: bucketMap.capacity)
      if let position = bucketMap[bucket] {
        let key = keys[bucket.offset]
        result += [
          "bucket \(bucket)",
          "key = \(key)",
          "ideal bucket = \(idealBucket(for: key, capacity: capacity))",
          "position = \(position)\n"
          ].joined(separator: ", ")
      } else {
        result += "bucket \(bucket), empty\n"
      }
    }
    return result
  }


}

// MARK: - OrderedDictionaryBufferSlice
fileprivate struct OrderedDictionaryBufferSlice<Key:Hashable, Value>: _DestructorSafeContainer {

  typealias Element = (key: Key, value: Value)
  typealias _Element = Element
  typealias Storage = OrderedDictionaryStorage<Key, Value>
  typealias Buffer = OrderedDictionaryBuffer<Key, Value>
  typealias BufferSlice = OrderedDictionaryBufferSlice<Key, Value>

  var indices: CountableRange<Int> { return CountableRange(uncheckedBounds: (lower: startIndex, upper: endIndex)) }

  var storage: Storage
  let keys: UnsafeMutablePointer<Key>
  let values: UnsafeMutablePointer<Value>
  let bucketMap: BucketMapSlice

  @inline(__always) mutating func isUniquelyReferenced() -> Bool { return Swift.isKnownUniquelyReferenced(&storage) }

  let startIndex: Int
  let endIndex: Int

  var count: Int { return endIndex &- startIndex } // Calculate since we are a slice

  var identity: UnsafeRawPointer { return bucketMap.identity }

  init(buffer: Buffer, indices: Range<Int>) {
    storage = buffer.storage
    bucketMap = buffer.bucketMap[indices]
    keys = storage.keys
    values = storage.values
    startIndex = indices.lowerBound
    endIndex = indices.upperBound
  }

  init(bufferSlice: BufferSlice, indices: Range<Int>) {
    storage = bufferSlice.storage
    bucketMap = bufferSlice.bucketMap[indices]
    keys = storage.keys
    values = storage.values
    startIndex = indices.lowerBound
    endIndex = indices.upperBound
  }

  /// Returns whether `key` is present in the buffer.
  @inline(__always) func contains(key: Key) -> Bool { let (_, found) = find(key); return found }

  /// Returns the public-facing index for `key`; returns `nil` when `key` is not found.
  @inline(__always) func index(for key: Key) -> Int? {
    let (bucket, found) = find(key)
    guard found, let index = bucketMap[bucket] else { return nil }
    return index
  }

  /// Returns the position for `element` or `nil` if `element` is not found.
  @inline(__always) func index(of element: Element) -> Int? {
    guard count > 0 else { return nil }
    let (bucket, found) = find(element.key)
    guard found, let index = bucketMap[bucket] else { return nil }
    //FIXME: Test value here?
    return index
  }

  /// Returns the hash value of `key` squeezed into `capacity`
  @inline(__always) func idealBucket(for key: Key, capacity: Int) -> Bucket {
    return Bucket(offset: _squeezeHashValue(key.hashValue, 0..<capacity), capacity: capacity)
  }

  @inline(__always) func find(_ key: Key) -> (bucket: Bucket, found: Bool) {
    let startBucket = idealBucket(for: key, capacity: storage.representedCapacity)
    var bucket = startBucket
    repeat {
      guard bucketMap[bucket] != nil else { return (bucket, false) }
      guard keys[bucket.offset] != key else { return (bucket, true) }
      bucket = bucket.advanced(by: 1)
    } while bucket != startBucket

    fatalError("failed to locate hole")
  }

}

// MARK: - RandomAccessCollection
extension OrderedDictionaryBufferSlice: RandomAccessCollection {
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

  subscript(index: Int) -> Element {
    precondition(index >= startIndex && index < endIndex, "invalid index '\(index)'")
    let offset = bucketMap[index].offset
    return (key: keys[offset], value: values[offset])
  }

  subscript(subRange: Range<Int>) -> SubSequence {
    precondition(subRange.lowerBound >= startIndex && subRange.upperBound <= endIndex, "invalid subRange '\(subRange)'")
    return SubSequence(bufferSlice: self, indices: subRange)
  }

}

// MARK: CustomStringConvertible, CustomDebugStringConvertible
extension OrderedDictionaryBufferSlice: CustomStringConvertible, CustomDebugStringConvertible {

  var elementsDescription: String {
    if count == 0 { return "[:]" }

    var result = "["
    var first = true
    for position in CountableRange(uncheckedBounds: (lower: startIndex, upper: endIndex)) {
      if first { first = false } else { result += ", " }
      let bucket = bucketMap[position]
      debugPrint(keys[bucket.offset], terminator: ": ", to: &result)
      debugPrint(values[bucket.offset], terminator: "",   to: &result)
    }
    result += "]"
    return result
  }

  var description: String { return elementsDescription }

  var debugDescription: String {
    var result = elementsDescription + "\n"
    result += "startIndex = \(startIndex)\n"
    result += "endIndex = \(endIndex)\n"
    result += "count = \(count)\n"
    return result
  }


}

//public struct OrderedDictionaryIndex: BinaryInteger, Strideable, Hashable, ExpressibleByIntegerLiteral {
//  public typealias Words = Int.Words
//
//  public typealias Magnitude = Int.Magnitude
//
//  public static func + (lhs: OrderedDictionaryIndex, rhs: OrderedDictionaryIndex) -> OrderedDictionaryIndex {
//    Index(lhs.value + rhs.value)
//  }
//
//  public typealias Index = OrderedDictionaryIndex
//  public let value: Int
//  public init(_ value: Int) { self.value = value }
//  public init?(_ value: Int?) { guard let value = value else { return nil }; self.value = value }
//  public func advanced(by n: Int) -> Index { return Index(value &+ n) }
//  public func distance(to other: Index) -> Int { return other.value &- value }
//  public func hash(into hasher: inout Hasher) {
//    value.hash(into: &hasher)
//  }
//  public init(integerLiteral: Int) { self = Index(integerLiteral) }
//  public static func ==(lhs: Index, rhs: Index) -> Bool { return lhs.value == rhs.value }
//  public static func <(lhs: Index, rhs: Index) -> Bool { return lhs.value < rhs.value }
//  public static func +(lhs: Index, rhs: Int) -> Index { return Index(lhs.value + rhs) }
//  public static func -(lhs: Index, rhs: Int) -> Index { return Index(lhs.value - rhs) }
//  public static func &+(lhs: Index, rhs: Int) -> Index { return Index(lhs.value &+ rhs) }
//  public static func &-(lhs: Index, rhs: Int) -> Index { return Index(lhs.value &- rhs) }
//}


// MARK: - OrderedDictionary
/// A hash-based mapping from `Key` to `Value` instances that preserves elment order.
public struct OrderedDictionary<Key: Hashable, Value>: RandomAccessCollection, _DestructorSafeContainer {

  fileprivate typealias Storage = OrderedDictionaryStorage<Key, Value>
  fileprivate typealias Buffer = OrderedDictionaryBuffer<Key, Value>

  public typealias Index = Int
  public typealias Element = (key: Key, value: Value)
  public typealias _Element = Element
  public typealias SubSequence = OrderedDictionarySlice<Key, Value>

  public var startIndex: Int {  buffer.startIndex }
  public var endIndex: Int  {  buffer.endIndex }

  public subscript(index: Index) -> Element {
    get { return buffer[index] }
    set {
      _reserveCapacity(capacity)
      buffer[index] = newValue
    }
  }

  public subscript(subRange: Range<Index>) -> SubSequence {
    get { return SubSequence(buffer: buffer[subRange.lowerBound ..< subRange.upperBound]) }
    set { replaceSubrange(subRange, with: newValue) }
  }

  fileprivate var buffer: Buffer

  public init(minimumCapacity: Int) { self = OrderedDictionary(buffer: Buffer(minimumCapacity: minimumCapacity)) }

  fileprivate init(buffer: Buffer) { self.buffer = buffer }

  public mutating func insert(value: Value, forKey key: Key, atIndex index: Index) {
    guard !buffer.contains(key: key) else { return }
    _reserveCapacity(Buffer.minimumCapacityFor(count + 1))
    buffer.insert((key, value), at: index)
  }

  public var indices: CountableRange<Index> {
    return CountableRange(uncheckedBounds: (lower: startIndex, upper: endIndex))
  }

  public var count: Int { return buffer.count }
  public var capacity: Int { return buffer.capacity }

  public init<Source:Sequence>(_ elements: Source) where Source.Iterator.Element == Element {
    self = OrderedDictionary(buffer: Buffer(elements))
  }

  public init<Source:Collection>(_ elements: Source) where Source.Iterator.Element == Element {
    self = OrderedDictionary(buffer: Buffer(elements))
  }

  public func _failEarlyRangeCheck(_ index: Index, bounds: Range<Index>) { /* no-op for performance reasons. */ }
  public func _failEarlyRangeCheck(_ range: Range<Index>, bounds: Range<Index>) { /* no-op for performance reasons. */ }

  @inline(__always) public func distance(from start: Index, to end: Index) -> Int { return end &- start }

  @inline(__always) public func index(after i: Index) -> Index { return i &+ 1 }
  @inline(__always) public func index(before i: Index) -> Index { return i &- 1 }
  @inline(__always) public func index(_ i: Index, offsetBy n: Int) -> Index { return i &+ n }
  @inline(__always) public func index(_ i: Index, offsetBy n: Int, limitedBy limit: Index) -> Index? {
    switch (i &+ n, n < 0) {
    case (let iʹ, true) where iʹ >= limit, (let iʹ, false) where iʹ <= limit: return iʹ
    default: return nil
    }
  }
  @inline(__always) public func formIndex(after i: inout Index) { i = i &+ 1 }
  @inline(__always) public func formIndex(before i: inout Index) { i = i &- 1 }
  @inline(__always) public func formIndex(_ i: inout Index, offsetBy n: Int) { i = i &+ n }
  @inline(__always) public func formIndex(_ i: inout Index, offsetBy n: Int, limitedBy limit: Index) -> Bool {
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

// MARK: OrderedDictionary where Value:Equatable
extension OrderedDictionary where Value:Equatable {

  public func _customContainsEquatableElement(_ element: Element) -> Bool? { return element.1 == self[element.0] }

  public func _customIndexOfEquatableElement(_ element: Element) -> Index? {
    return buffer.index(for: element.key)
  }
}

// MARK: DictionaryLiteralConvertible
extension OrderedDictionary: ExpressibleByDictionaryLiteral {
  public init(dictionaryLiteral elements: (Key, Value)...) { self = OrderedDictionary(elements.map(keyValuePair)) }
}

// MARK: MutableKeyValueRandomAccessCollection
extension OrderedDictionary: MutableKeyValueRandomAccessCollection {

  public mutating func insert(value: Value, forKey key: Key) { self[key] = value }

  @discardableResult
  public mutating func updateValue(_ value: Value, forKey key: Key) -> Value? {
    let found = buffer.contains(key: key)

    let minCapacity = found ? capacity : Buffer.minimumCapacityFor(buffer.count + 1)

    _reserveCapacity(minCapacity)

    if found { return buffer.update(element: (key, value)).1 }
    else { buffer.append((key, value)); return nil }
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
          _reserveCapacity(Buffer.minimumCapacityFor(count &+ 1))
          buffer.append((key, value))
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
extension OrderedDictionary/*: RangeReplaceableCollection */{


  /// Create an empty instance.
  public init() { self = OrderedDictionary(buffer: Buffer(minimumCapacity: 0)) }

  /// A non-binding request to ensure `n` elements of available storage.
  ///
  /// This works as an optimization to avoid multiple reallocations of
  /// linear data structures like `Array`.  Conforming types may
  /// reserve more than `n`, exactly `n`, less than `n` elements of
  /// storage, or even ignore the request completely.
  public mutating func reserveCapacity(_ minimumCapacity: Int) { _reserveCapacity(minimumCapacity) }

  /// Replace the given `subRange` of elements with `newElements`.
  ///
  /// Invalidates all indices with respect to `self`.
  ///
  /// - Complexity: O(`subRange.count`) if
  ///   `subRange.endIndex == self.endIndex` and `newElements.isEmpty`,
  ///   O(`self.count` + `newElements.count`) otherwise.
  public mutating func replaceSubrange<Source:Collection>(_ subRange: Range<Index>, with newElements: Source)
    where Source.Iterator.Element == Element
  {
    guard !(subRange.isEmpty && newElements.isEmpty) else { return }
    let requiredCapacity = count - subRange.count + numericCast(newElements.count)

    _reserveCapacity(Buffer.minimumCapacityFor(requiredCapacity))

    // Replace with uniqued collection
    buffer.replaceSubrange(Range<Int>(uncheckedBounds: (lower: subRange.lowerBound,
                                                        upper: subRange.upperBound)),
                           with: newElements)
  }

  /// Append `x` to `self`.
  ///
  /// Applying `successor()` to the index of the new element yields
  /// `self.endIndex`.
  ///
  /// - Complexity: Amortized O(1).
  public mutating func append(_ element: Element) {
    guard !buffer.contains(key: element.0) else { return }
    _reserveCapacity(Buffer.minimumCapacityFor(count &+ 1))
    buffer.append(element)
  }

  /// Append the elements of `newElements` to `self`.
  ///
  /// - Complexity: O(*length of result*).
  public mutating func append<Source:Sequence>(contentsOf newElements: Source)
    where Source.Iterator.Element == Element
  {
    append(contentsOf: Array(newElements))
  }

  /// Append the elements of `newElements` to `self`.
  ///
  /// - Complexity: O(*length of result*).
  public mutating func append<Source:Collection>(contentsOf newElements: Source)
    where Source.Iterator.Element == Element
  {
    let newElementsCount: Int = numericCast(newElements.count)
    guard newElementsCount > 0 else { return }
    _reserveCapacity(Buffer.minimumCapacityFor(count + newElementsCount))
    buffer.append(contentsOf: newElements)
  }

  /// Insert `newElement` at index `i`.
  ///
  /// Invalidates all indices with respect to `self`.
  ///
  /// - Complexity: O(`self.count`).
  public mutating func insert(_ newElement: Element, at index: Index) {
    guard !buffer.contains(key: newElement.0) else { return }
    _reserveCapacity(Buffer.minimumCapacityFor(count &+ 1))
    buffer.insert(newElement, at: index)
  }

  /// Insert `newElements` at index `i`.
  ///
  /// Invalidates all indices with respect to `self`.
  ///
  /// - Complexity: O(`self.count + newElements.count`).
  public mutating func insert<Source:Collection>(contentsOf newElements: Source, at index: Index)
    where Source.Iterator.Element == Element
  {
    _reserveCapacity(count + numericCast(newElements.count))
    buffer.insert(contentsOf: newElements, at: index)
  }

  /// Remove the element at index `index`.
  ///
  /// Invalidates all indices with respect to `self`.
  ///
  /// - Complexity: O(`self.count`).
  @discardableResult
  public mutating func remove(at index: Index) -> Element {
    _reserveCapacity(capacity)
    return buffer.remove(at: index)
  }

  /// Remove the element at `startIndex` and return it.
  ///
  /// - Complexity: O(`self.count`)
  /// - Requires: `!self.isEmpty`.
  public mutating func removeFirst() -> Element {
    return remove(at: startIndex)
  }

  /// Remove the first `n` elements.
  ///
  /// - Complexity: O(`self.count`)
  /// - Requires: `n >= 0 && self.count >= n`.
  public mutating func removeFirst(_ n: Int) {
    _reserveCapacity(capacity)
    buffer.removeFirst(n)
  }

  /// Remove the indicated `subRange` of elements.
  ///
  /// Invalidates all indices with respect to `self`.
  ///
  /// - Complexity: O(`self.count`).
  public mutating func removeSubrange(_ subRange: Range<Index>) {
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
  public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
    guard count > 0 else { return }
    _reserveCapacity(capacity)
    buffer.removeAll(keepingCapacity: keepCapacity)
  }


}

// MARK: CustomStringConvertible, CustomDebugStringConvertible
extension OrderedDictionary: CustomStringConvertible, CustomDebugStringConvertible {

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
extension OrderedDictionary: JSONValueConvertible {
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
extension OrderedDictionary: Equatable {

  public static func ==(lhs: OrderedDictionary<Key, Value>, rhs: OrderedDictionary<Key, Value>) -> Bool {
    guard !(lhs.buffer.identity == rhs.buffer.identity && lhs.count == rhs.count) else { return true }
    for ((key: k1, value: _), (key: k2, value: _)) in zip(lhs, rhs) where k1 != k2 { return false }
    return lhs.count == rhs.count
  }
}

extension OrderedDictionary where Value:Equatable {
  public static func ==(lhs: OrderedDictionary<Key, Value>, rhs: OrderedDictionary<Key, Value>) -> Bool {
    guard !(lhs.buffer.identity == rhs.buffer.identity && lhs.count == rhs.count) else { return true }
    for ((key: k1, value: v1), (key: k2, value: v2)) in zip(lhs, rhs) where k1 != k2 || v1 != v2 { return false }
    return lhs.count == rhs.count
  }

}

// MARK: - SortedDictionary
/// A hash-based mapping from `Key` to `Value` instances that preserves elment order.
public struct SortedDictionary<Key: Hashable & Comparable, Value>: RandomAccessCollection, _DestructorSafeContainer {

  fileprivate typealias Storage = OrderedDictionaryStorage<Key, Value>
  fileprivate typealias Buffer = OrderedDictionaryBuffer<Key, Value>

  public typealias Index = Int
  public typealias Element = (key: Key, value: Value)
  public typealias _Element = Element
  public typealias SubSequence = OrderedDictionarySlice<Key, Value>

  public var startIndex: Int {  buffer.startIndex }
  public var endIndex: Int  {  buffer.endIndex }

  public subscript(position: Int) -> Element {
    get { return buffer[position] }
    set {
      _reserveCapacity(capacity)
      buffer.remove(at: position)
      insert(value: newValue.value, forKey: newValue.key)
    }
  }

  public subscript(subRange: Range<Index>) -> SubSequence {
    return SubSequence(buffer: buffer[subRange.lowerBound ..< subRange.upperBound])
  }

  fileprivate var buffer: Buffer

  public init(minimumCapacity: Int) { self = SortedDictionary(buffer: Buffer(minimumCapacity: minimumCapacity)) }

  fileprivate init(buffer: Buffer) { self.buffer = buffer }

  public var indices: CountableRange<Index> {
    return CountableRange(uncheckedBounds: (lower: startIndex, upper: endIndex))
  }

  public var count: Int { return buffer.count }
  public var capacity: Int { return buffer.capacity }

  public init<Source:Sequence>(_ elements: Source) where Source.Iterator.Element == Element {
    self = SortedDictionary(buffer: Buffer(elements.sorted(by: {$0.key < $1.key})))
  }

  public init<Source:Collection>(_ elements: Source) where Source.Iterator.Element == Element {
    self = SortedDictionary(buffer: Buffer(elements.sorted(by: {$0.key < $1.key})))
  }

  public func _failEarlyRangeCheck(_ index: Index, bounds: Range<Index>) { /* no-op for performance reasons. */ }
  public func _failEarlyRangeCheck(_ range: Range<Index>, bounds: Range<Index>) { /* no-op for performance reasons. */ }

  @inline(__always) public func distance(from start: Index, to end: Index) -> Int { return end &- start }

  @inline(__always) public func index(after i: Index) -> Index { return i &+ 1 }
  @inline(__always) public func index(before i: Index) -> Index { return i &- 1 }
  @inline(__always) public func index(_ i: Index, offsetBy n: Int) -> Index { return i &+ n }
  @inline(__always) public func index(_ i: Index, offsetBy n: Int, limitedBy limit: Index) -> Index? {
    switch (i &+ n, n < 0) {
    case (let iʹ, true) where iʹ >= limit, (let iʹ, false) where iʹ <= limit: return iʹ
    default: return nil
    }
  }
  @inline(__always) public func formIndex(after i: inout Index) { i = i &+ 1 }
  @inline(__always) public func formIndex(before i: inout Index) { i = i &- 1 }
  @inline(__always) public func formIndex(_ i: inout Index, offsetBy n: Int) { i = i &+ n }
  @inline(__always) public func formIndex(_ i: inout Index, offsetBy n: Int, limitedBy limit: Index) -> Bool {
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
extension SortedDictionary where Value:Equatable {

  public func _customContainsEquatableElement(_ element: Element) -> Bool? { return element.1 == self[element.0] }

  public func _customIndexOfEquatableElement(_ element: Element) -> Index? {
    return buffer.index(for: element.key)
  }
}

// MARK: DictionaryLiteralConvertible
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
            return search(range: pivot &+ 1 ..< range.upperBound)
          } else if keyʹ > key {
            guard pivot > range.lowerBound else { return pivot }
            return search(range: range.lowerBound ..< pivot)
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
extension SortedDictionary/*: RangeReplaceableCollection */{


  /// Create an empty instance.
  public init() { self = SortedDictionary(buffer: Buffer(minimumCapacity: 0)) }

  /// A non-binding request to ensure `n` elements of available storage.
  ///
  /// This works as an optimization to avoid multiple reallocations of
  /// linear data structures like `Array`.  Conforming types may
  /// reserve more than `n`, exactly `n`, less than `n` elements of
  /// storage, or even ignore the request completely.
  public mutating func reserveCapacity(_ minimumCapacity: Int) { _reserveCapacity(minimumCapacity) }

  /// Replace the given `subRange` of elements with `newElements`.
  ///
  /// Invalidates all indices with respect to `self`.
  ///
  /// - Complexity: O(`subRange.count`) if
  ///   `subRange.endIndex == self.endIndex` and `newElements.isEmpty`,
  ///   O(`self.count` + `newElements.count`) otherwise.
  public mutating func replaceSubrange<Source:Collection>(_ subRange: Range<Index>, with newElements: Source)
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
  public mutating func append(_ element: Element) {
    guard !buffer.contains(key: element.0) else { return }
    insert(value: element.value, forKey: element.key)
  }

  /// Append the elements of `newElements` to `self`.
  ///
  /// - Complexity: O(*length of result*).
  public mutating func append<Source:Sequence>(contentsOf newElements: Source)
    where Source.Iterator.Element == Element
  {
    for element in newElements { append(element) }
  }

  /// Append the elements of `newElements` to `self`.
  ///
  /// - Complexity: O(*length of result*).
  public mutating func append<Source:Collection>(contentsOf newElements: Source)
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
  public mutating func remove(at index: Index) -> Element {
    _reserveCapacity(capacity)
    return buffer.remove(at: index)
  }

  /// Remove the element at `startIndex` and return it.
  ///
  /// - Complexity: O(`self.count`)
  /// - Requires: `!self.isEmpty`.
  public mutating func removeFirst() -> Element {
    return remove(at: startIndex)
  }

  /// Remove the first `n` elements.
  ///
  /// - Complexity: O(`self.count`)
  /// - Requires: `n >= 0 && self.count >= n`.
  public mutating func removeFirst(_ n: Int) {
    _reserveCapacity(capacity)
    buffer.removeFirst(n)
  }

  /// Remove the indicated `subRange` of elements.
  ///
  /// Invalidates all indices with respect to `self`.
  ///
  /// - Complexity: O(`self.count`).
  public mutating func removeSubrange(_ subRange: Range<Index>) {
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
  public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
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

extension SortedDictionary where Value:Equatable {
  public static func ==(lhs: SortedDictionary<Key, Value>, rhs: SortedDictionary<Key, Value>) -> Bool {
    guard !(lhs.buffer.identity == rhs.buffer.identity && lhs.count == rhs.count) else { return true }
    for ((key: k1, value: v1), (key: k2, value: v2)) in zip(lhs, rhs) where k1 != k2 || v1 != v2 { return false }
    return lhs.count == rhs.count
  }

}

// MARK: - OrderedDictionarySlice
/// A hash-based mapping from `Key` to `Value` instances that preserves elment order.
public struct OrderedDictionarySlice<Key: Hashable, Value>: RandomAccessCollection, _DestructorSafeContainer {

  fileprivate typealias Storage = OrderedDictionaryStorage<Key, Value>
  fileprivate typealias Buffer = OrderedDictionaryBuffer<Key, Value>
  fileprivate typealias BufferSlice = OrderedDictionaryBufferSlice<Key, Value>

  public typealias Index = Int
  public typealias Element = (key: Key, value: Value)
  public typealias _Element = Element
  public typealias SubSequence = OrderedDictionarySlice<Key, Value>

  public var startIndex: Int {  buffer.startIndex }
  public var endIndex: Int  {  buffer.endIndex }

  public subscript(index: Int) -> Element { return buffer[index] }

  public subscript(subRange: Range<Int>) -> SubSequence { return SubSequence(buffer: buffer[subRange]) }

  fileprivate var buffer: BufferSlice

  fileprivate init(buffer: BufferSlice) { self.buffer = buffer }

  public var indices: CountableRange<Index> { return CountableRange(uncheckedBounds: (lower: startIndex, upper: endIndex)) }

  public var count: Int { return buffer.count }

  public func _failEarlyRangeCheck(_ index: Index, bounds: Range<Index>) { /* no-op for performance reasons. */ }
  public func _failEarlyRangeCheck(_ range: Range<Index>, bounds: Range<Index>) { /* no-op for performance reasons. */ }

  @inline(__always) public func distance(from start: Index, to end: Index) -> Int { return end &- start }

  @inline(__always) public func index(after i: Index) -> Index { return i &+ 1 }
  @inline(__always) public func index(before i: Index) -> Index { return i &- 1 }
  @inline(__always) public func index(_ i: Index, offsetBy n: Int) -> Index { return i &+ n }
  @inline(__always) public func index(_ i: Index, offsetBy n: Int, limitedBy limit: Index) -> Index? {
    switch (i &+ n, n < 0) {
    case (let iʹ, true) where iʹ >= limit, (let iʹ, false) where iʹ <= limit: return iʹ
    default: return nil
    }
  }
  @inline(__always) public func formIndex(after i: inout Index) { i = i &+ 1 }
  @inline(__always) public func formIndex(before i: inout Index) { i = i &- 1 }
  @inline(__always) public func formIndex(_ i: inout Index, offsetBy n: Int) { i = i &+ n }
  @inline(__always) public func formIndex(_ i: inout Index, offsetBy n: Int, limitedBy limit: Index) -> Bool {
    switch (i &+ n, n < 0) {
    case (let iʹ, true) where iʹ >= limit, (let iʹ, false) where iʹ <= limit: i = iʹ; return true
    default: return false
    }
  }

}

// MARK: OrderedDictionarySlice where Value:Equatable
extension OrderedDictionarySlice where Value:Equatable {

  public func _customContainsEquatableElement(_ element: Element) -> Bool? { return element.1 == self[element.0] }

  public func _customIndexOfEquatableElement(_ element: Element) -> Index?? {
    return Optional(index(forKey: element.key))
  }
}

// MARK: KeyValueRandomAccessCollection
extension OrderedDictionarySlice: KeyValueRandomAccessCollection {

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
  public subscript(key: Key) -> Value? { return value(forKey: key) }

}

// MARK: CustomStringConvertible, CustomDebugStringConvertible
extension OrderedDictionarySlice: CustomStringConvertible, CustomDebugStringConvertible {

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
extension OrderedDictionarySlice: JSONValueConvertible {
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
extension OrderedDictionarySlice: Equatable {
  public static func ==(lhs: OrderedDictionarySlice<Key, Value>, rhs: OrderedDictionarySlice<Key, Value>) -> Bool {
    guard !(lhs.buffer.identity == rhs.buffer.identity && lhs.indices == rhs.indices) else { return true }
    for ((key: k1, value: _), (key: k2, value: _)) in zip(lhs, rhs) where k1 != k2 { return false }
    return lhs.count == rhs.count
  }
}

extension OrderedDictionarySlice where Value:Equatable {
  public static func ==(lhs: OrderedDictionarySlice<Key, Value>, rhs: OrderedDictionarySlice<Key, Value>) -> Bool {
    guard !(lhs.buffer.identity == rhs.buffer.identity && lhs.indices == rhs.indices) else { return true }
    for ((key: k1, value: v1), (key: k2, value: v2)) in zip(lhs, rhs) where k1 != k2 || v1 != v2 { return false }
    return lhs.count == rhs.count
  }
}

