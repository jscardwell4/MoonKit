//
//  HashedStorage.swift
//  MoonKit
//
//  Created by Jason Cardwell on 5/20/16.
//  Copyright © 2016 Jason Cardwell. All rights reserved.
//
import Foundation


internal func squeezeHashValue(hashValue: Int, _ resultRange: Range<Int>) -> Int {
  let resultCardinality = resultRange.endIndex - resultRange.startIndex
  if _isPowerOf2(resultCardinality) {
    return hashValue & (resultCardinality - 1)
  }
  return resultRange.startIndex + (hashValue % resultCardinality)
}

// MARK: - HashedStorageHeader
internal struct HashedStorageHeader {
  var count: Int = 0
  let representedCapacity: Int
  let capacity: Int
  let bucketMap: BucketMap

  init(capacity: Int,
       representedCapacity: Int,
       bucketMapAddress: UnsafeMutablePointer<Int>)
  {
    self.capacity = capacity
    self.representedCapacity = representedCapacity
    bucketMap = BucketMap(storage: bucketMapAddress, capacity: representedCapacity)
    bucketMap.initializeStorage()
  }
}

internal let maxLoadFactorInverse = 1.0/0.75

// MARK: - HashedStorage
internal class HashedStorage: ManagedBuffer<HashedStorageHeader, UInt8> {

  typealias Header = HashedStorageHeader

  /// Returns the number of bytes required for the map of buckets to
  /// positions given `capacity`
  @inline(__always) static func bytesForBucketMap(_ capacity: Int) -> Int {
    MemoryLayout<Int>.stride * (capacity * 2 + 1)
  }

  final var bucketMapBytes: Int {
    HashedStorage.bytesForBucketMap(header.representedCapacity)
  }

  /// Pointer to the first byte in pointee allocated for the position map
  final var bucketMapAddress: UnsafeMutableRawPointer {
    withUnsafeMutablePointerToElements {UnsafeMutableRawPointer($0)}
  }

  final var count: Int { get { header.count } set { header.count = newValue } }
  final var representedCapacity: Int { header.representedCapacity }
  final var bucketMap: BucketMap { header.bucketMap }
}


internal struct BucketMap: RandomAccessCollection {

  typealias Index = Int
  typealias _Element = Bucket
  typealias SubSequence = BucketMapSlice

  func _failEarlyRangeCheck(_ index: Int, bounds: Range<Int>) {
    /* no-op for performance reasons. */ }
  func _failEarlyRangeCheck(_ range: Range<Int>, bounds: Range<Int>) {
    /* no-op for performance reasons. */ }

  @inline(__always) func distance(from start: Int, to end: Int) -> Int { end &- start }

  @inline(__always) func index(after i: Int) -> Int { i &+ 1 }
  @inline(__always) func index(before i: Int) -> Int { i &- 1 }
  @inline(__always) func index(_ i: Int, offsetBy n: Int) -> Int { i &+ n }
  @inline(__always) func index(_ i: Int, offsetBy n: Int, limitedBy limit: Int) -> Int? {
    switch (i &+ n, n < 0) {
    case (let iʹ, true) where iʹ >= limit, (let iʹ, false) where iʹ <= limit: return iʹ
    default: return nil
    }
  }
  @inline(__always) func formIndex(after i: inout Int) { i = i &+ 1 }
  @inline(__always) func formIndex(before i: inout Int) { i = i &- 1 }
  @inline(__always) func formIndex(_ i: inout Int, offsetBy n: Int) { i = i &+ n }
  @inline(__always) func formIndex(_ i: inout Int,
                                   offsetBy n: Int,
                                   limitedBy limit: Int) -> Bool
  {
    switch (i &+ n, n < 0) {
    case (let iʹ, true) where iʹ >= limit, (let iʹ, false) where iʹ <= limit:
      i = iʹ; return true
    default: return false
    }
  }


  static let empty = -1 /// Represents an empty position or bucket in one of the buffers.

  var indices: Range<Int> { Range(uncheckedBounds: (lower: startIndex, upper: endIndex)) }

  /// The total number of 'bucket ⟷ position' mappings that can be managed.
  let capacity: Int

  /// Pointer to the memory allocated for tracking the position of each bucket.
  let buckets: UnsafeMutableBufferPointer<Int>

  /// Pointer to the memory allocated for tracking the bucket of each position
  let positions: UnsafeMutableBufferPointer<Int>

  /// Pointer to the memory allocated for tracking the `endIndex` value.
  let _endIndex: UnsafeMutablePointer<Index>

  var identity: UnsafeRawPointer { return UnsafeRawPointer(_endIndex) }

  /// Indexing always starts with `0`.
  let startIndex: Index = 0

  /// 'past the end' position for the 'position ➞ bucket' mappings.
  var endIndex: Index {
    get { return _endIndex.pointee }
    nonmutating set { _endIndex.pointee = newValue }
  }

  /// The number of 'position ➞ bucket' mappings.
  var count: Int { return endIndex }

  /// Initialize with a pointer to the storage to use and its represented capacity
  /// as an element count.
  ///
  /// - Warning: `storage` must have been properly allocated.
  init(storage: UnsafeMutablePointer<Int>, capacity: Int) {
    self.capacity = capacity
    _endIndex = storage
    positions = UnsafeMutableBufferPointer<Int>(start: storage.advanced(by: 1),
                                                count: capacity)
    buckets = UnsafeMutableBufferPointer<Int>(start: storage.advanced(by: capacity + 1),
                                              count: capacity)
  }

  /// Initializes `positions` and `buckets` with `-1` and `endIndex` to `0`
  func initializeStorage() {
    _endIndex.initialize(to: 0)
    positions.initialize(repeating: BucketMap.empty)
    buckets.initialize(repeating: BucketMap.empty)
  }

  /// Accessors for the position mapped to `bucket`. The setter will remove any
  /// existing mapping with the current position for `bucket` when `newValue == nil`
  /// and replace any existing mapping with `newValue` otherwise.
  subscript(bucket: Bucket) -> Index? {
    get {
      assert((0..<capacity).contains(bucket.offset), "invalid bucket '\(bucket)'")
      let position = buckets[bucket.offset]
      return position == BucketMap.empty ? nil : position
    }
    nonmutating set {
      if let position = newValue { replace(bucketAt: position, with: bucket) }
      else if let oldPosition = self[bucket] { remove(at: oldPosition) }
    }
  }

  /// Accessors for getting and setting the bucket at a specified index. The setter
  /// will append `newValue` when `index == endIndex` and replace the currently
  /// mapped bucket otherwise.
  subscript(index: Index) -> Bucket {
    get {
      assert((0..<capacity).contains(index), "index invalid '\(index)'")
      return Bucket(offset: positions[index], capacity: capacity)
    }
    nonmutating set {
      assert((0..<capacity).contains(index), "index invalid '\(index)'")
      if index == endIndex { append(bucket: newValue) }
      else { replace(bucketAt: index, with: newValue) }
    }
  }

  /// Removes `bucket1` by inserting `bucket2` and giving it `bucket1`'s position
  /// - requires: `bucket1` has been assigned a position
  func replace(bucket bucket1: Bucket, with bucket2: Bucket) {
    assert((0..<capacity).contains(bucket1.offset), "bucket1 invalid '\(bucket1)'")
    assert((0..<capacity).contains(bucket2.offset), "bucket2 invalid '\(bucket2)'")

    let oldBucket1Position = buckets[bucket1.offset]
    let oldBucket2Position = buckets[bucket2.offset]

    buckets[bucket2.offset] = oldBucket1Position
    buckets[bucket1.offset] = BucketMap.empty

    if oldBucket1Position != BucketMap.empty {
      positions[oldBucket1Position] = bucket2.offset
    }

    if oldBucket2Position != BucketMap.empty {
      positions[oldBucket2Position] = BucketMap.empty
    }

    positions[oldBucket1Position] = bucket2.offset
    buckets[bucket1.offset] = BucketMap.empty
    buckets[bucket2.offset] = oldBucket1Position
  }

  /// Assigns `bucket` to `index`, removing the previously assigned bucket.
  /// - requires: `index ∋ startIndex..<endIndex`
  func replace(bucketAt index: Index, with bucket: Bucket) {
    assert((0..<capacity).contains(index), "index invalid '\(index)'")

    let bucketToRemove = positions[index]
    positions[index] = bucket.offset
    buckets[bucket.offset] = index
    if bucketToRemove != BucketMap.empty { buckets[bucketToRemove] = BucketMap.empty }
  }

  /// Assigns `bucket` to `endIndex`.
  /// - requires: `endIndex < capacity`
  /// - postcondition: `count = count + 1`
  func append(bucket: Bucket) {
    assert((0..<capacity).contains(bucket.offset), "bucket invalid '\(bucket)'")
    positions[endIndex] = bucket.offset
    buckets[bucket.offset] = endIndex
    endIndex = endIndex &+ 1
  }

  /// Removes the bucket assigned to `index`.
  /// - requires: `index ∋ startIndex..<endIndex`
  /// - postcondition: count = count - 1
  func remove(at index: Index) { shift(from: (index + 1), by: -1) }

  subscript(bounds: Range<Index>) -> SubSequence {
    assert(bounds.lowerBound >= startIndex && bounds.upperBound <= endIndex,
           "bounds invalid '\(bounds)'")
    return BucketMapSlice(bucketMap: self, indices: bounds)
  }

  /// Inserts `newElements` at `index`
  func insert<Source:Collection>(contentsOf newElements: Source, at index: Int)
  where Source.Iterator.Element == Bucket
  {
    assert((0..<capacity).contains(index), "index invalid '\(index)'")

    let shiftAmount = numericCast(newElements.count) as Int
    shift(from: index, by: shiftAmount) // Adjusts `endIndex`

    _ = UnsafeMutableBufferPointer(start: positions.baseAddress! + index,
                                   count: newElements.count)
      .initialize(from: newElements.map { $0.offset })

    for position in index..<index + shiftAmount { buckets[positions[position]] = position }
  }

  /// Moves bucket assignments for positions `from` to `endIndex`
  /// by `amount` and updates `endIndex`.
  func shift(from: Int, by shiftAmount: Int) {
    assert((0..<capacity).contains(from), "from invalid '\(from)'")
    assert((0..<capacity).contains(from + shiftAmount), "amount invalid '\(shiftAmount)'")
    let shiftCount = endIndex - from // Number of elements to relocate

    switch shiftAmount {

      case -1 where shiftCount == 0:
        // Fast path for dropping last element
        buckets[positions[endIndex &- 1]] = BucketMap.empty
        positions[endIndex &- 1] = BucketMap.empty

      case <--0:
        // Shifting from right to left

        guard let basePosition = positions.baseAddress else {
          fatalError("positions.baseAddress == nil")
        }

        let sourcePosition = basePosition.advanced(by: from)
        let destinationPosition = sourcePosition.advanced(by: shiftAmount)

        // Clear positions assignments stored in `buckets` for overwritten positions
        for offset in 0..<abs(shiftAmount) {
          let position = destinationPosition.advanced(by: offset)
          let bucketOffset = position.pointee
          guard bucketOffset != BucketMap.empty else { continue }
          buckets[bucketOffset] = BucketMap.empty
        }

        // Move bucket assignments
        destinationPosition.moveInitialize(from: sourcePosition, count: shiftCount)
        for offset in 0..<shiftCount {
          let position = destinationPosition.advanced(by: offset)
          let bucketOffset = position.pointee
          assert(bucketOffset != BucketMap.empty, "expected a valid bucket assignment")
          let bucketPosition = basePosition.distance(to: position)
          buckets[bucketOffset] = bucketPosition
        }

        // Update emptied positions
        let firstEmptyPosition = destinationPosition.advanced(by: shiftCount)
        _ = UnsafeMutableBufferPointer(start: firstEmptyPosition, count: abs(shiftAmount))
          .initialize(from: repeatElement(BucketMap.empty, count: abs(shiftAmount)))

      case 0-->:
        // Shifting from left to right
        guard let basePosition = positions.baseAddress else {
          fatalError("positions.baseAddress == nil")
        }

        let sourcePosition = basePosition.advanced(by: from)
        let destinationPosition = sourcePosition.advanced(by: shiftAmount)

        // Move bucket assignments
        destinationPosition.moveInitialize(from: sourcePosition, count: shiftCount)

        // Update emptied positions
        _ = UnsafeMutableBufferPointer(start: sourcePosition, count: shiftAmount)
          .initialize(from: repeatElement(BucketMap.empty, count: shiftAmount))

        // Update position assignments stored in `buckets`
        for offset in 0..<shiftCount {
          let position = destinationPosition.advanced(by: offset)
          let bucketOffset = position.pointee
          assert(bucketOffset != BucketMap.empty, "expected a valid bucket assignment")
          let bucketPosition = basePosition.distance(to: position)
          buckets[bucketOffset] = bucketPosition
        }

      
      default:
        // No elements to shift
        break
    }

    // Update the 'past the end' index
    endIndex = endIndex &+ shiftAmount
  }

  /// Removes buckets assigned to positions in `subRange`
  func removeSubrange(_ subRange: Range<Int>) {
    assert((0..<endIndex).contains(subRange), "subRange invalid '\(subRange)'")

    guard Range(uncheckedBounds: (lower: startIndex, upper: endIndex)) != subRange else {
      initializeStorage()
      return
    }

    shift(from: subRange.upperBound, by: -subRange.count)
  }

  /// Replaces buckets assigned to positions in `subRange` with `newElements`
  /// - requires: `newElements` contains unique values.
  func replaceSubrange<Source:Collection>(_ subRange: Range<Index>,
                                          with newElements: Source)
    where Source.Iterator.Element == Bucket

  {
    assert((0..<capacity).contains(subRange), "subRange invalid '\(subRange)'")

    let 𝝙count = numericCast(newElements.count) - subRange.count

    // Replace n values where n = max(subRange.count, newElements.count)
    for (index, bucket) in zip(subRange, newElements) {
      replace(bucketAt: index, with: bucket)
    }

    guard 𝝙count != 0 else { return }

    if 𝝙count < 0 {
      // Remove remaining positions from `subRange`
      removeSubrange(subRange.upperBound.advanced(by: 𝝙count)..<subRange.upperBound)
    } else {
      // Insert remaining elements from `newElements`
      insert(contentsOf: newElements.dropFirst(subRange.count), at: subRange.upperBound)
    }
  }

  /// A string containing the contents of `positions` and `buckets` wrapped with
  /// unicode box drawing characters.
  var bufferDescription: String {

    func boxedComponents(_ buffer: UnsafeMutableBufferPointer<Int>) -> (top: String,
                                                                        center: String,
                                                                        bottom: String)
    {

      var boxTops    = "┌"
      var boxCenters = "│"
      var boxBottoms = "└"

      var first = true
      for value in buffer {
        if first { first = false } else {
          boxTops    += "┬"
          boxCenters += "│"
          boxBottoms += "┴"
        }
        let boxContent = String(value)
        let horizontalBar = String(repeating: "─", count: boxContent.count)

        boxTops    += horizontalBar
        boxCenters += boxContent
        boxBottoms += horizontalBar
      }

      boxTops    += "┐"
      boxCenters += "│"
      boxBottoms += "┘"
      return (boxTops, boxCenters, boxBottoms)
    }

    let (positionBoxTops,
         positionBoxCenters,
         positionBoxBottoms) = boxedComponents(positions)

    let positionsDescription = [
      "           \(positionBoxTops)",
      " positions \(positionBoxCenters)",
      "           \(positionBoxBottoms)"
      ].joined(separator: "\n")

    let (bucketBoxTops, bucketBoxCenters, bucketBoxBottoms) = boxedComponents(buckets)
    let bucketsDescription = [
      "           \(bucketBoxTops)",
      "   buckets \(bucketBoxCenters)",
      "           \(bucketBoxBottoms)"
      ].joined(separator: "\n")

    return ["", positionsDescription, bucketsDescription].joined(separator: "\n")
  }

}

extension BucketMap: CustomStringConvertible, CustomDebugStringConvertible {

  var description: String {
    "\(Array(positions[Range(uncheckedBounds: (lower: startIndex, upper: endIndex))]))"
  }

  var debugDescription: String {
    return ["BucketMap(startIndex: \(startIndex)",
            "endIndex: \(endIndex)",
            "capacity: \(capacity)",
            "positions: \(Array(positions))",
            "buckets: \(Array(buckets)))"].joined(separator: ", ")
  }
  
}

internal struct BucketMapSlice: RandomAccessCollection {
  
  typealias Index = Int
  typealias _Element = Bucket
  typealias SubSequence = BucketMapSlice

  let identity: UnsafeRawPointer

  init(bucketMap: BucketMap, indices: Range<Int>) {
    positions = bucketMap.positions
    buckets = bucketMap.buckets
    startIndex = indices.lowerBound
    endIndex = indices.upperBound
    capacity = bucketMap.capacity
    identity = bucketMap.identity
  }

  init(positions: UnsafeMutableBufferPointer<Int>,
               buckets: UnsafeMutableBufferPointer<Int>, 
               indices: Range<Int>,
               capacity: Int,
               identity: UnsafeRawPointer)
  {
    self.positions = positions
    self.buckets = buckets
    self.capacity = capacity
    self.identity = identity
    startIndex = indices.lowerBound
    endIndex = indices.upperBound
  }

  func _failEarlyRangeCheck(_ index: Int, bounds: Range<Int>) {
    /* no-op for performance reasons. */ }
  func _failEarlyRangeCheck(_ range: Range<Int>, bounds: Range<Int>) {
    /* no-op for performance reasons. */ }

  @inline(__always) func distance(from start: Int, to end: Int) -> Int { end &- start }

  @inline(__always) func index(after i: Int) -> Int { i &+ 1 }
  @inline(__always) func index(before i: Int) -> Int { i &- 1 }
  @inline(__always) func index(_ i: Int, offsetBy n: Int) -> Int { i &+ n }
  @inline(__always) func index(_ i: Int, offsetBy n: Int, limitedBy limit: Int) -> Int? {
    switch (i &+ n, n < 0) {
    case (let iʹ, true) where iʹ >= limit, (let iʹ, false) where iʹ <= limit: return iʹ
    default: return nil
    }
  }
  @inline(__always) func formIndex(after i: inout Int) { i = i &+ 1 }
  @inline(__always) func formIndex(before i: inout Int) { i = i &- 1 }
  @inline(__always) func formIndex(_ i: inout Int, offsetBy n: Int) { i = i &+ n }
  @inline(__always)
  func formIndex(_ i: inout Int, offsetBy n: Int, limitedBy limit: Int) -> Bool {
    switch (i &+ n, n < 0) {
    case (let iʹ, true) where iʹ >= limit, (let iʹ, false) where iʹ <= limit:
      i = iʹ; return true
    default: return false
    }
  }

  var indices: CountableRange<Int> { CountableRange(uncheckedBounds: (lower: startIndex,
                                                                      upper: endIndex)) }

  /// The total number of 'bucket ⟷ position' mappings that can be managed.
  let capacity: Int

  /// Pointer to the memory allocated for tracking the position of each bucket.
  let buckets: UnsafeMutableBufferPointer<Int>

  /// Pointer to the memory allocated for tracking the bucket of each position
  let positions: UnsafeMutableBufferPointer<Int>

  let startIndex: Index
  let endIndex: Index

  var count: Int { return endIndex &- startIndex }

  /// Accessor for the position mapped to `bucket`.
  subscript(bucket: Bucket) -> Index? {
    assert((0..<capacity).contains(bucket.offset), "invalid bucket '\(bucket)'")
    let position = buckets[bucket.offset]
    return indices.contains(position) ? position : nil
  }

  /// Accessors for getting and setting the bucket at a specified index. The setter
  /// will append `newValue` when `index == endIndex` and replace the currently mapped
  /// bucket otherwise.
  subscript(index: Index) -> Bucket {
    assert(indices.contains(index), "index invalid '\(index)'")
    return Bucket(offset: positions[index], capacity: capacity)
  }

  subscript(bounds: Range<Index>) -> SubSequence {
    assert(indices.contains(bounds), "bounds invalid '\(bounds)'")
    return BucketMapSlice(positions: positions, 
                          buckets: buckets, 
                          indices: startIndex ..< endIndex,
                          capacity: capacity,
                          identity: identity)
  }

}

extension BucketMapSlice: CustomStringConvertible, CustomDebugStringConvertible {

  var description: String {
    "\(Array(positions[Range(uncheckedBounds: (lower: startIndex, upper: endIndex))]))"
  }

  var debugDescription: String {
    return ["BucketMapSlice(identity: \(identity)",
            "startIndex: \(startIndex)",
            "endIndex: \(endIndex)",
            "capacity: \(capacity)",
            "positions: \(Array(positions))",
            "buckets: \(Array(buckets)))"].joined(separator: ", ")
  }
  
}

internal struct Bucket: Comparable, Strideable, Hashable, CustomStringConvertible {
  let offset: Int
  let capacity: Int
  func predecessor() -> Bucket { advanced(by: -1) }
  func successor() -> Bucket { advanced(by: 1) }
  func advanced(by n: Int) -> Bucket { Bucket(offset: (offset &+ n) & (capacity &- 1),
                                              capacity: capacity) }
  func distance(to other: Bucket) -> Int { other.offset &- offset }
  func hash(into hasher: inout Hasher) {
    offset.hash(into: &hasher)
    capacity.hash(into: &hasher)
  }
  var description: String { "\(offset)" }
}

internal func ==(lhs: Bucket, rhs: Bucket) -> Bool { lhs.offset == rhs.offset }
internal func <(lhs: Bucket, rhs: Bucket) -> Bool { lhs.offset < rhs.offset }
