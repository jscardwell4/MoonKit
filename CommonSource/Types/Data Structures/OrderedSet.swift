//
//  OrderedSet.swift
//  MoonKit
//
//  Created by Jason Cardwell on 12/18/20.
//  Copyright © 2020 Moondeer Studios. All rights reserved.
//
import Foundation

// MARK: - OrderedSetStorage

/// Specialization of `HashedStorage` for an ordered set
internal final class OrderedSetStorage<Member: Hashable>: HashedStorage {
  typealias Storage = OrderedSetStorage<Member>
  typealias Header = HashedStorageHeader

  /// Returns the number of bytes required to store the elements for a given `capacity`.
  @inline(__always) static func bytesForMembers(_ capacity: Int) -> Int {
    let padding = max(0, MemoryLayout<Member>.alignment - MemoryLayout<Int>.alignment)
    return MemoryLayout<Member>.stride * capacity + padding
  }

  var membersBytes: Int { return Storage.bytesForMembers(header.representedCapacity) }
  var members: UnsafeMutablePointer<Member> {
    let rawMembers = bucketMapAddress.advanced(by: bucketMapBytes)
    return rawMembers.bindMemory(to: Member.self, capacity: header.capacity)
//    return pointerCast(bucketMapAddress + bucketMapBytes)
  }

  /// Create a new storage instance.
  static func create(minimumCapacity: Int) -> OrderedSetStorage {
    let representedCapacity = round2(minimumCapacity)
    let requiredCapacity = bytesForBucketMap(representedCapacity)
      + bytesForMembers(representedCapacity)

    let storage = super.create(minimumCapacity: requiredCapacity) {
      Header(capacity: $0.capacity,
             representedCapacity: representedCapacity,
             bucketMapAddress: $0.withUnsafeMutablePointerToElements { pointerCast($0) })
    }

    return storage as! Storage
  }

  deinit {
    let members = self.members
    for bucket in bucketMap { (members + bucket.offset).deinitialize(count: 1) }
    let bucketMapBytes = self.bucketMapBytes
    withUnsafeMutablePointers {
      $1.deinitialize(count: bucketMapBytes)
      $0.deinitialize(count: 1)
    }
  }
}

// MARK: - OrderedSetBuffer

private struct OrderedSetBuffer<Member: Hashable>: _DestructorSafeContainer {
  typealias Element = Member
  typealias _Element = Element
  typealias Buffer = OrderedSetBuffer<Member>
  typealias BufferSlice = OrderedSetBufferSlice<Member>
  typealias Storage = OrderedSetStorage<Member>

  typealias PendingAssignments = [Bucket: Element]

  var indices: Range<Int> { startIndex..<endIndex }

  var storage: Storage
  let members: UnsafeMutablePointer<Member>
  let bucketMap: BucketMap

  @inline(__always)
  mutating func isUniquelyReferenced() -> Bool {
    Swift.isKnownUniquelyReferenced(&storage)
  }

  @inline(__always)
  mutating func requestUniqueBuffer(minimumCapacity: Int = 0) -> Buffer? {
    return isUniquelyReferenced() && capacity >= minimumCapacity ? self : nil
  }

  var startIndex: Int { 0 }
  var endIndex = 0

  var count: Int { endIndex }

  var capacity: Int { storage.header.representedCapacity }
  var remainingCapacity: Int { capacity &- count }

  /// Returns the minimum capacity for storing `count` elements.
  @inline(__always)
  static func minimumCapacityFor(_ count: Int) -> Int {
    // `requestedCount + 1` below ensures that we don't fill in the last hole
    let x = Int(Double(count) * maxLoadFactorInverse), y = count &+ 1
    return x > y ? x : y
  }

  var identity: UnsafeRawPointer { bucketMap.identity }

  init(storage: Storage) {
    self.storage = storage
    bucketMap = storage.bucketMap
    members = storage.members
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

        newElements.withMemoryRebound(to: Int.self,
                                      capacity: newValue.pointee.capacity) {
          newBufferMapStorage in

          bufferElements.withMemoryRebound(to: Int.self,
                                           capacity: bufferValue.pointee.capacity) {
            sourceBufferMapStorage in
            newBufferMapStorage.initialize(from: sourceBufferMapStorage,
                                           count: buffer.capacity * 2 + 1)
          }
        }

        let newBucketMap = newValue.pointee.bucketMap
        let bucketMapBytes = HashedStorage.bytesForBucketMap(buffer.capacity)

        newElements.advanced(by: bucketMapBytes)
          .withMemoryRebound(to: Member.self, capacity: newValue.pointee.capacity) {
            newMemberStorage in

            bufferElements.advanced(by: bucketMapBytes)
              .withMemoryRebound(to: Member.self,
                                 capacity: bufferValue.pointee.capacity) {
                sourceMemberStorage in

                for bucket in newBucketMap {
                  newMemberStorage.advanced(by: bucket.offset)
                    .initialize(to: sourceMemberStorage
                      .advanced(by: bucket.offset).pointee)
                }
              }
          }

        newValue.pointee.count = bufferValue.pointee.count
      }
    }

    self = Buffer(storage: storage)
  }

  /// Returns whether `member` is present in the buffer.
  @inline(__always) func contains(_ member: Member) -> Bool {
    let (_, found) = find(member); return found
  }

  /// Returns the public-facing index for `member`; returns `nil` when `member`
  /// is not found.
  @inline(__always) func index(for member: Member) -> Int? {
    let (bucket, found) = find(member)
    guard found, let index = bucketMap[bucket] else { return nil }
    return index
  }

  /// Returns the hash value of `member` squeezed into `capacity`
  @inline(__always) func idealBucket(for member: Member, capacity: Int) -> Bucket {
    let offset = squeezeHashValue(member.hashValue, 0..<capacity)
    return Bucket(offset: offset,
                  capacity: capacity)
  }

  /// Returns the bucket containing `member` or `nil` if no bucket contains `member`.
  @inline(__always) func currentBucket(for member: Member) -> Bucket? {
    let (bucket, found) = find(member)
    return found ? bucket : nil
  }

  /// Returns an empty bucket suitable for holding `member` or `nil` if a bucket
  /// already contains `member`.
  @inline(__always)
  func emptyBucket(for member: Member,
                   pending: PendingAssignments? = nil) -> Bucket?
  {
    let (bucket, found) = find(member, pending: pending)
    return found ? nil : bucket
  }

  /// Returns the position for `member` or `nil` if `member` is not found.
  @inline(__always) func index(of member: Member) -> Int? {
    guard count > 0 else { return nil }
    let (bucket, found) = find(member)
    guard found, let index = bucketMap[bucket] else { return nil }
    return index
  }

  func _find(member: Member, startBucket: Bucket) -> (bucket: Bucket, found: Bool) {
    var bucket = startBucket
    repeat {
      guard bucketMap[bucket] != nil else { return (bucket, false) }
      guard members[bucket.offset] != member else { return (bucket, true) }
      bucket = bucket.advanced(by: 1)
    } while bucket != startBucket

    fatalError("failed to locate hole")
  }

  func _find(member: Member,
             startBucket: Bucket,
             pending: PendingAssignments) -> (bucket: Bucket, found: Bool)
  {
    var bucket = startBucket
    repeat {
      switch (bucketMap[bucket], pending[bucket]) {
        case (nil, nil): return (bucket, false)
        case (.some, _) where members[bucket.offset] == member: return (bucket, true)
        case (_, let pendingMember?) where pendingMember == member: return (bucket, true)
        default: bucket = bucket.advanced(by: 1)
      }
    } while bucket != startBucket

    fatalError("failed to locate hole")
  }

  /// Returns the current bucket for `member` and `true` when `member` is located;
  /// returns an open bucket for `member` and `false` otherwise
  ///
  /// - Parameter pending: Map of bucket to member assignments to be treated as if
  ///                      they have already been committed.
  /// - Requires: At least one empty bucket
  @inline(__always)
  func find(_ member: Member,
            pending: PendingAssignments? = nil) -> (bucket: Bucket, found: Bool)
  {
    let startBucket = idealBucket(for: member, capacity: capacity)
    guard let pending = pending else {
      return _find(member: member, startBucket: startBucket)
    }
    return _find(member: member, startBucket: startBucket, pending: pending)
  }

  /// Initializes a fresh bucket with `member` at `position` unless `member`
  /// is a duplicate.
  /// Returns `true` if a bucket was initialized and `false` otherwise.
  @discardableResult
  func initialize(member: Member, at position: Int) -> Bool {
    guard let bucket = emptyBucket(for: member) else { return false }
    (members + bucket.offset).initialize(to: member)
    bucketMap[position] = bucket
    return true
  }

  @discardableResult func update(member: Member) -> Member {
    guard let offset = currentBucket(for: member)?.offset else {
      fatalError("bucketless member: '\(member)'")
    }
    let oldMember = members[offset]
    (members + offset).initialize(to: member)
    return oldMember
  }

  /// Attempts to move the values of the buckets near `hole` into buckets nearer to
  /// their 'ideal' bucket
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
        let member = members[last.offset]
        let bucket = self.idealBucket(for: member, capacity: capacity)

        switch (bucket >= start, bucket <= hole) {
          case (true, true) where start <= hole,
               (true, _) where start > hole,
               (_, true) where start > hole:
            break FillHole
          default:
            last = last.advanced(by: -1)
        }
      }

      guard last != hole else { break }
      (members + hole.offset).initialize(to: (members + last.offset).move())
      bucketMap.replace(bucket: last, with: hole)
      hole = last
    }
  }

  mutating func remove(member: Member) -> Element? {
    let (bucket, found) = find(member)
    guard found else { return nil }
    let oldMember = members[bucket.offset]
    destroy(bucket: bucket)
    return oldMember
  }

  /// Removes members common with `members`.
  mutating func remove<Source: Sequence>(contentsOf sourceMembers: Source)
    where Source.Iterator.Element == Element
  {
    var ranges = CountableRangeMap<Int>()
    for member in sourceMembers {
      guard let index = index(of: member) else { continue }
      ranges.insert(index)
    }

    guard ranges.count > 0 else { return }

    for range in ranges.reversed() { removeSubrange(range) }
  }

  mutating func destroy(bucket: Bucket) {
    let idealBucket = self.idealBucket(for: members[bucket.offset], capacity: capacity)
    (members + bucket.offset).deinitialize(count: 1)
    bucketMap[bucket] = nil
    endIndex = endIndex &- 1
    storage.count = storage.count &- 1
    patch(hole: bucket, idealBucket: idealBucket)
  }

  /// Uninitializes the bucket for `position`, adjusts positions and
  /// `endIndex` and patches the hole.
  mutating func destroy(at position: Index) { destroy(bucket: bucketMap[position]) }
}

// MARK: RandomAccessCollection

extension OrderedSetBuffer: RandomAccessCollection {
  typealias Index = Int
  typealias SubSequence = BufferSlice

  func _failEarlyRangeCheck(_ index: Int, bounds: Range<Int>) {}
  func _failEarlyRangeCheck(_ range: Range<Int>, bounds: Range<Int>) {}

  @inline(__always) func distance(from start: Int, to end: Int) -> Int { end &- start }

  @inline(__always) func index(after i: Int) -> Int { i &+ 1 }
  @inline(__always) func index(before i: Int) -> Int { i &- 1 }
  @inline(__always) func index(_ i: Int, offsetBy n: Int) -> Int { i &+ n }
  @inline(__always) func index(_ i: Int, offsetBy n: Int, limitedBy limit: Int) -> Int? {
    switch (i &+ n, n < 0) {
      case (let iʹ, true) where iʹ >= limit,
           (let iʹ, false) where iʹ <= limit:
        return iʹ
      default: return nil
    }
  }

  @inline(__always)
  func formIndex(after i: inout Int) { i = i &+ 1 }
  @inline(__always)
  func formIndex(before i: inout Int) { i = i &- 1 }
  @inline(__always)
  func formIndex(_ i: inout Int, offsetBy n: Int) { i = i &+ n }
  @inline(__always)
  func formIndex(_ i: inout Int, offsetBy n: Int, limitedBy limit: Int) -> Bool {
    switch (i &+ n, n < 0) {
      case (let iʹ, true) where iʹ >= limit,
           (let iʹ, false) where iʹ <= limit:
        i = iʹ
        return true
      default: return false
    }
  }
}

// MARK: MutableCollection

extension OrderedSetBuffer: MutableCollection {
  subscript(index: Int) -> Member {
    get {
      precondition(index >= startIndex && index < endIndex, "invalid index '\(index)'")
      return members[bucketMap[index].offset]
    }
    set {
      precondition(index >= startIndex && index < endIndex, "invalid index '\(index)'")
      guard !contains(newValue) else { return }
      (members + bucketMap[index].offset).deinitialize(count: 1)
      initialize(member: newValue, at: index)
    }
  }

  subscript(subRange: Range<Int>) -> SubSequence {
    get { return SubSequence(buffer: self, indices: subRange) }
    set { replaceSubrange(subRange, with: newValue) }
  }
}

// MARK: RangeReplaceableCollection

extension OrderedSetBuffer /*: RangeReplaceableCollection */ {
  /// Create an empty instance.
  init() { self = Buffer(minimumCapacity: 0) }

  mutating func replaceSubrange<Source: Collection>(_ subRange: Range<Int>,
                                                    with newMembers: Source)
    where Source.Iterator.Element == Member
  {
    removeSubrange(subRange)
    insert(contentsOf: newMembers, at: subRange.lowerBound)
  }

  /// Creates an instance that contains `members`.
  init<Source: Sequence>(_ members: Source) where Source.Iterator.Element == Member {
    self = Buffer(Array(members))
  }

  init<Source: Collection>(_ sourceMembers: Source)
    where Source.Iterator.Element == Member
  {
    let requiredCapacity = Buffer.minimumCapacityFor(numericCast(sourceMembers.count) + 1)
    storage = Storage.create(minimumCapacity: requiredCapacity)
    members = storage.members
    bucketMap = storage.bucketMap
    endIndex = 0

    for member in sourceMembers {
      guard let bucket = emptyBucket(for: member) else { continue }
      (members + bucket.offset).initialize(to: member)
      bucketMap[endIndex] = bucket
      endIndex = endIndex &+ 1
      storage.count = endIndex
    }
  }

  /// Append `x` to `self`.
  ///
  /// Applying `successor()` to the index of the new member yields
  /// `self.endIndex`.
  ///
  /// - Complexity: Amortized O(1).
  mutating func append(_ member: Member) {
    guard initialize(member: member, at: endIndex) else { return }
    endIndex = endIndex &+ 1
    storage.count = endIndex
  }

  /// Append the members of `newMembers` to `self`.
  ///
  /// - Complexity: O(*length of result*).
  mutating func append<Source: Sequence>(contentsOf newMembers: Source)
    where Source.Iterator.Element == Member
  {
    for member in newMembers { append(member) }
  }

  /// Insert `newMember` at index `i`.
  ///
  /// Invalidates all indices with respect to `self`.
  ///
  /// - Complexity: O(`self.count`).
  mutating func insert(_ newMember: Member, at i: Index) {
    guard let bucket = emptyBucket(for: newMember) else { return }
    (members + bucket.offset).initialize(to: newMember)
    bucketMap.insert(contentsOf: CollectionOfOne(bucket), at: i)
    endIndex = endIndex &+ 1
    storage.count = endIndex
  }

  /// Insert `newMembers` at index `i`.
  ///
  /// Invalidates all indices with respect to `self`.
  ///
  /// - Complexity: O(`self.count + newMembers.count`).
  mutating func insert<S: Collection>(contentsOf newMembers: S, at i: Index)
    where S.Iterator.Element == Member
  {
    // Insert new members, accumulating a list of their buckets
    var newMembersBuckets = [Bucket]()
    newMembersBuckets.reserveCapacity(numericCast(newMembers.count))

    var pending: PendingAssignments = [:]

    for member in newMembers {
      guard let bucket = emptyBucket(for: member, pending: pending) else { continue }
      (members + bucket.offset).initialize(to: member)
      pending[bucket] = member
      newMembersBuckets.append(bucket)
    }

    // Adjust positions
    bucketMap.insert(contentsOf: newMembersBuckets, at: i)

    let 𝝙members = newMembersBuckets.count

    // Adjust count and endIndex
    endIndex = endIndex &+ 𝝙members
    storage.count = endIndex
  }

  /// Remove the member at index `i`.
  ///
  /// Invalidates all indices with respect to `self`.
  ///
  /// - Complexity: O(`self.count`).
  mutating func remove(at i: Index) -> Member {
    let result = self[i]
    destroy(at: i)
    return result
  }

  /// Remove the member at `startIndex` and return it.
  ///
  /// - Complexity: O(`self.count`)
  /// - Requires: `!self.isEmpty`.
  mutating func removeFirst() -> Member { return remove(at: startIndex) }

  /// Remove the first `n` members.
  ///
  /// - Complexity: O(`self.count`)
  /// - Requires: `n >= 0 && self.count >= n`.
  mutating func removeFirst(_ n: Int) {
    removeSubrange(startIndex..<startIndex.advanced(by: n))
  }

  /// Remove the indicated `subRange` of members.
  ///
  /// Invalidates all indices with respect to `self`.
  ///
  /// - Complexity: O(`self.count`).
  mutating func removeSubrange(_ subRange: Range<Index>) {
    switch subRange.count {
      case 0: return
      case 1: destroy(at: subRange.lowerBound)
      default:
        var destroyed = 0
        for position in subRange {
          destroy(at: position &- destroyed)
          destroyed = destroyed &+ 1
        }
    }
  }

  mutating func removeSubrange(_ subRange: ClosedRange<Index>) {
    removeSubrange(subRange.lowerBound..<(subRange.upperBound + 1))
  }

  /// Remove all members.
  ///
  /// Invalidates all indices with respect to `self`.
  ///
  /// - parameter keepCapacity: If `true`, is a non-binding request to
  ///    avoid releasing storage, which can be a useful optimization
  ///    when `self` is going to be grown again.
  ///
  /// - Complexity: O(`self.count`).
  mutating func removeAll(keepingCapacity keepCapacity: Bool) {
    guard keepCapacity else { self = Buffer(); return }
    for bucket in bucketMap { (members + bucket.offset).deinitialize(count: 1) }
    bucketMap.initializeStorage()
    endIndex = 0
    storage.count = 0
  }
}

// MARK: CustomStringConvertible, CustomDebugStringConvertible

extension OrderedSetBuffer: CustomStringConvertible, CustomDebugStringConvertible {
  var membersDescription: String {
    if count == 0 { return "[]" }

    var result = "["
    var first = true
    for position in startIndex..<endIndex {
      if first { first = false } else { result += ", " }
      let bucket = bucketMap[position]
      debugPrint(members[bucket.offset], terminator: "", to: &result)
    }
    result += "]"
    return result
  }

  var description: String { return membersDescription }

  var debugDescription: String {
    var result = membersDescription + "\n"
    result += "startIndex = \(startIndex)\n"
    result += "endIndex = \(endIndex)\n"
    result += "count = \(count)\n"
    result += "capacity = \(capacity)\n"
    for position in CountableRange(uncheckedBounds: (lower: startIndex, upper: endIndex)) {
      let bucket = bucketMap[position]
      result += "position \(position) ➞ bucket \(bucket) [\(members[bucket.offset])]\n"
    }
    for position in endIndex..<capacity {
      result += "position \(position), empty\n"
    }
    for bucketOffset in 0..<bucketMap.capacity {
      let bucket = Bucket(offset: bucketOffset, capacity: bucketMap.capacity)
      if let position = bucketMap[bucket] {
        let member = members[bucket.offset]
        result += [
          "bucket \(bucket)",
          "member = \(member)",
          "ideal bucket = \(idealBucket(for: member, capacity: capacity))",
          "position = \(position)\n"
        ].joined(separator: ", ")
      } else {
        result += "bucket \(bucket), empty\n"
      }
    }
    return result
  }
}

// MARK: - OrderedSetBufferSlice

private struct OrderedSetBufferSlice<Member: Hashable>: _DestructorSafeContainer {
  typealias Element = Member

  typealias _Element = Element
  typealias Buffer = OrderedSetBuffer<Member>
  typealias BufferSlice = OrderedSetBufferSlice<Member>
  typealias Storage = OrderedSetStorage<Member>

  var indices: Range<Int> { startIndex..<endIndex }

  var storage: Storage
  let members: UnsafeMutablePointer<Member>
  let bucketMap: BucketMapSlice

  @inline(__always)
  mutating func isUniquelyReferenced() -> Bool {
    Swift.isKnownUniquelyReferenced(&storage)
  }

  let startIndex: Int
  let endIndex: Int

  var count: Int { return endIndex &- startIndex } // Calculate since we are a slice

  var identity: UnsafeRawPointer { return bucketMap.identity }

  init(buffer: Buffer, indices: Range<Int>) {
    storage = buffer.storage
    bucketMap = buffer.bucketMap[indices]
    members = storage.members
    startIndex = indices.lowerBound
    endIndex = indices.upperBound
  }

  init(bufferSlice: BufferSlice, indices: Range<Int>) {
    storage = bufferSlice.storage
    bucketMap = bufferSlice.bucketMap[indices]
    members = storage.members
    startIndex = indices.lowerBound
    endIndex = indices.upperBound
  }

  /// Returns whether `member` is present in the buffer.
  @inline(__always)
  func contains(member: Member) -> Bool { let (_, found) = find(member); return found }

  /// Returns the public-facing index for `member`; returns `nil`
  /// when `member` is not found.
  @inline(__always) func index(for member: Member) -> Int? {
    let (bucket, found) = find(member)
    guard found, let index = bucketMap[bucket] else { return nil }
    return index
  }

  /// Returns the position for `member` or `nil` if `member` is not found.
  @inline(__always) func index(of member: Member) -> Int? {
    guard count > 0 else { return nil }
    let (bucket, found) = find(member)
    guard found, let index = bucketMap[bucket] else { return nil }
    return index
  }

  /// Returns the hash value of `value` squeezed into `capacity`
  @inline(__always) func idealBucket(for member: Member, capacity: Int) -> Bucket {
    let range = 0..<capacity
    let memberhash = member.hashValue
    let offset: Int = squeezeHashValue(memberhash, range)
    return Bucket(offset: offset, capacity: capacity)
  }

  @inline(__always) func find(_ member: Member) -> (bucket: Bucket, found: Bool) {
    let startBucket = idealBucket(for: member, capacity: storage.representedCapacity)
    var bucket = startBucket
    repeat {
      guard bucketMap[bucket] != nil else { return (bucket, false) }
      guard members[bucket.offset] != member else { return (bucket, true) }
      bucket = bucket.advanced(by: 1)
    } while bucket != startBucket

    fatalError("failed to locate hole")
  }
}

// MARK: MutableCollection, RandomAccessCollection

extension OrderedSetBufferSlice: MutableCollection, RandomAccessCollection {
  typealias Index = Int
  typealias SubSequence = BufferSlice

  func _failEarlyRangeCheck(_ index: Int, bounds: Range<Int>) {}
  func _failEarlyRangeCheck(_ range: Range<Int>, bounds: Range<Int>) {}

  @inline(__always) func distance(from start: Int, to end: Int) -> Int { end &- start }

  @inline(__always) func index(after i: Int) -> Int { i &+ 1 }
  @inline(__always) func index(before i: Int) -> Int { i &- 1 }
  @inline(__always) func index(_ i: Int, offsetBy n: Int) -> Int { i &+ n }
  @inline(__always) func index(_ i: Int, offsetBy n: Int, limitedBy limit: Int) -> Int? {
    switch (i &+ n, n < 0) {
      case (let iʹ, true) where iʹ >= limit,
           (let iʹ, false) where iʹ <= limit:
        return iʹ
      default: return nil
    }
  }

  @inline(__always) func formIndex(after i: inout Int) { i = i &+ 1 }
  @inline(__always) func formIndex(before i: inout Int) { i = i &- 1 }
  @inline(__always) func formIndex(_ i: inout Int, offsetBy n: Int) { i = i &+ n }
  @inline(__always)
  func formIndex(_ i: inout Int, offsetBy n: Int, limitedBy limit: Int) -> Bool {
    switch (i &+ n, n < 0) {
      case (let iʹ, true) where iʹ >= limit,
           (let iʹ, false) where iʹ <= limit:
        i = iʹ
        return true
      default: return false
    }
  }

  subscript(index: Int) -> Member {
    get {
      precondition(index >= startIndex && index < endIndex, "invalid index '\(index)'")
      return members[bucketMap[index].offset]
    }
    set {
      precondition(index >= startIndex && index < endIndex, "invalid index '\(index)'")
      members[bucketMap[index].offset] = newValue
    }
  }

  subscript(subRange: Range<Int>) -> SubSequence {
    precondition(subRange.lowerBound >= startIndex
      && subRange.upperBound <= endIndex, "invalid subRange '\(subRange)'")
    return SubSequence(bufferSlice: self, indices: subRange)
  }
}

// MARK: CustomStringConvertible, CustomDebugStringConvertible

extension OrderedSetBufferSlice: CustomStringConvertible, CustomDebugStringConvertible {
  var membersDescription: String {
    if count == 0 { return "[]" }

    var result = "["
    var first = true
    for position in startIndex..<endIndex {
      if first { first = false } else { result += ", " }
      let bucket = bucketMap[position]
      debugPrint(members[bucket.offset], terminator: "", to: &result)
    }
    result += "]"
    return result
  }

  var description: String { return membersDescription }

  var debugDescription: String {
    var result = membersDescription + "\n"
    result += "startIndex = \(startIndex)\n"
    result += "endIndex = \(endIndex)\n"
    result += "count = \(count)\n"
    return result
  }
}

// MARK: - OrderedSet

/// A hash-based set of elements that preserves element order.
public struct OrderedSet<Member: Hashable>: RandomAccessCollection,
  _DestructorSafeContainer
{
  fileprivate typealias Buffer = OrderedSetBuffer<Member>
  fileprivate typealias Storage = OrderedSetStorage<Member>

  public typealias Index = Int
  public typealias Element = Member
  public typealias _Element = Element
  public typealias SubSequence = OrderedSetSlice<Member>

  public var startIndex: Index { buffer.startIndex }

  public var endIndex: Index { buffer.endIndex }

  public subscript(index: Index) -> Member {
    get { buffer[index] }
    set {
      _reserveCapacity(capacity)
      buffer[index] = newValue
    }
  }

  public subscript(subRange: Range<Int>) -> SubSequence {
    get { SubSequence(buffer: buffer[subRange]) }
    set { replaceSubrange(subRange, with: newValue) }
  }

  fileprivate var buffer: Buffer

  /// The current number of elements
  public var count: Int { return buffer.count }

  public var indices: Range<Int> { startIndex..<endIndex }

  /// The number of elements this collection can hold without reallocating
  public var capacity: Int { buffer.capacity }

  public init(minimumCapacity: Int) {
    self = OrderedSet(buffer: Buffer(minimumCapacity: minimumCapacity))
  }

  fileprivate init(buffer: Buffer) { self.buffer = buffer }

  public func hash(into hasher: inout Hasher) {
    for element in self {
      element.hash(into: &hasher)
    }
  }

  public func _customContainsEquatableElement(_ member: Member) -> Bool? {
    buffer.contains(member)
  }

  public func _customIndexOfEquatableElement(_ member: Member) -> Index?? {
    Optional(buffer.index(of: member))
  }

  public func index(of member: Member) -> Index? { buffer.index(of: member) }
  public func contains(_ member: Member) -> Bool { buffer.contains(member) }

  public func _failEarlyRangeCheck(_ index: Int, bounds: Range<Int>) {}
  public func _failEarlyRangeCheck(_ range: Range<Int>, bounds: Range<Int>) {}

  @inline(__always)
  public func distance(from start: Int, to end: Int) -> Int { end &- start }
  @inline(__always) public func index(after i: Int) -> Int { i &+ 1 }
  @inline(__always) public func index(before i: Int) -> Int { i &- 1 }
  @inline(__always) public func index(_ i: Int, offsetBy n: Int) -> Int { i &+ n }
  @inline(__always)
  public func index(_ i: Int, offsetBy n: Int, limitedBy limit: Int) -> Int? {
    switch (i &+ n, n < 0) {
      case (let iʹ, true) where iʹ >= limit, (let iʹ, false) where iʹ <= limit: return iʹ
      default: return nil
    }
  }

  @inline(__always) public func formIndex(after i: inout Int) { i = i &+ 1 }
  @inline(__always) public func formIndex(before i: inout Int) { i = i &- 1 }
  @inline(__always) public func formIndex(_ i: inout Int, offsetBy n: Int) { i = i &+ n }
  @inline(__always)
  public func formIndex(_ i: inout Int, offsetBy n: Int, limitedBy limit: Int) -> Bool {
    switch (i &+ n, n < 0) {
      case (let iʹ, true) where iʹ >= limit,
           (let iʹ, false) where iʹ <= limit:
        i = iʹ
        return true
      default: return false
    }
  }

  fileprivate mutating func _reserveCapacity(_ minimumCapacity: Int) {
    guard buffer.requestUniqueBuffer(minimumCapacity: minimumCapacity) == nil else {
      return
    }
    buffer = buffer.capacity < minimumCapacity
      ? OrderedSetBuffer<Member>(buffer: buffer, withCapacity: minimumCapacity)
      : OrderedSetBuffer<Member>(buffer: buffer)
  }
}

// MARK: SetType

extension OrderedSet: SetType {
  @discardableResult
  public mutating func insert(_ newMember: Member)
    -> (inserted: Bool, memberAfterInsert: Member)
  {
    guard !contains(newMember) else { return (false, newMember) }
    append(newMember)
    return (true, newMember)
  }

  @discardableResult
  public mutating func update(with newMember: Member) -> Member? {
    if let idx = index(of: newMember) {
      let oldMember = remove(at: idx)
      insert(newMember, at: idx)
      return oldMember
    } else {
      append(newMember)
      return nil
    }
  }

  public var isEmpty: Bool { return count == 0 }

  /// Removes and returns `member` from the collection,
  /// returns `nil` if `member` was not contained.
  @discardableResult
  public mutating func remove(_ member: Member) -> Member? {
    guard let index = buffer.index(of: member) else { return nil }
    _reserveCapacity(capacity)
    return buffer.remove(at: index)
  }

  /// Initialize with the unique members of `elements`.
  public init<Source: Sequence>(_ elements: Source)
    where Source.Iterator.Element == Member
  {
    let buffer = Buffer(elements)
    let orderedSet = OrderedSet(buffer: buffer)
    self = orderedSet
  }

  public init<Source: Collection>(_ elements: Source)
    where Source.Iterator.Element == Member
  {
    let buffer = Buffer(elements)
    let orderedSet = OrderedSet(buffer: buffer)
    self = orderedSet
  }

  fileprivate func result<Source: Sequence>(of query: (OrderedSet<Member>) -> Bool,
                                            downcasting sequence: Source) -> Bool
    where Source.Iterator.Element == Member
  {
    if let other = sequence as? OrderedSet<Member> { return query(other) }
    else { return query(OrderedSet(sequence)) }
  }

  fileprivate func _isSubset(of other: OrderedSet<Member>) -> Bool {
    guard count <= other.count else { return false }
    return first(where: { !other.contains($0) }) == nil
  }

  /// Returns true if the set is a subset of a finite sequence as a set.
  public func isSubset<Source: Sequence>(of sequence: Source) -> Bool
    where Source.Iterator.Element == Member
  {
    return result(of: _isSubset, downcasting: sequence)
  }

  public func isSubset(of other: OrderedSet<Member>) -> Bool { return _isSubset(of: other) }

  fileprivate func _isStrictSubset(of other: OrderedSet<Member>) -> Bool {
    guard count < other.count else { return false }
    return first(where: { !other.contains($0) }) == nil
  }

  /// Returns true if the set is a subset of a finite sequence as a set but not equal.
  public func isStrictSubset<Source: Sequence>(of sequence: Source) -> Bool
    where Source.Iterator.Element == Member
  {
    return result(of: _isStrictSubset, downcasting: sequence)
  }

  public func isStrictSubset(of other: OrderedSet<Member>) -> Bool {
    _isStrictSubset(of: other)
  }

  fileprivate func _isSuperset(of other: OrderedSet<Member>) -> Bool {
    guard count >= other.count else { return false }
    return other.first(where: { !contains($0) }) == nil
  }

  /// Returns true if the set is a superset of a finite sequence as a set.
  public func isSuperset<Source: Sequence>(of sequence: Source) -> Bool
    where Source.Iterator.Element == Member
  {
    return result(of: _isSuperset, downcasting: sequence)
  }

  public func isSuperset(of other: OrderedSet<Member>) -> Bool { _isSuperset(of: other) }

  fileprivate func _isStrictSuperset(of other: OrderedSet<Member>) -> Bool {
    guard count > other.count else { return false }
    return other.first(where: { !contains($0) }) == nil
  }

  /// Returns true if the set is a superset of a finite sequence as a set but not equal.
  public func isStrictSuperset<Source: Sequence>(of sequence: Source) -> Bool
    where Source.Iterator.Element == Member
  {
    return result(of: _isStrictSuperset, downcasting: sequence)
  }

  public func isStrictSuperset(of other: OrderedSet<Member>) -> Bool {
    _isStrictSuperset(of: other)
  }

  fileprivate func _isDisjoint(with other: OrderedSet<Member>) -> Bool {
    first(where: { other.contains($0) }) == nil
      && other.first(where: { contains($0) }) == nil
  }

  /// Returns true if no members in the set are in a finite sequence as a set.

  public func isDisjoint<Source: Sequence>(with sequence: Source) -> Bool
    where Source.Iterator.Element == Member
  {
    return result(of: _isDisjoint, downcasting: sequence)
  }

  public func isDisjoint(with other: OrderedSet<Member>) -> Bool {
    _isDisjoint(with: other)
  }

  /// Return a new `Set` with items in both this set and a finite sequence.

  public func union<Source: Sequence>(_ sequence: Source) -> OrderedSet<Element>
    where Source.Iterator.Element == Member
  {
    var result = self
    result.formUnion(sequence)
    return result
  }

  /// Insert elements of a finite sequence into this set.
  public mutating func formUnion<Source: Sequence>(_ sequence: Source)
    where Source.Iterator.Element == Member
  {
    append(contentsOf: sequence)
  }

  /// Insert elements of a finite collection into this set.
  public mutating func formUnion<Source: Collection>(_ collection: Source)
    where Source.Iterator.Element == Member
  {
    append(contentsOf: collection)
  }

  /// Return a new set with elements in this set that do not occur in a finite sequence.

  public func subtracting<Source: Sequence>(_ s: Source) -> OrderedSet<Element>
    where Source.Iterator.Element == Member
  {
    var result = self
    result.subtract(s)
    return result
  }

  /// Remove all members in the set that occur in a finite sequence.
  public mutating func subtract<Source: Sequence>(_ s: Source)
    where Source.Iterator.Element == Member
  {
    let other = s as? OrderedSet<Member> ?? OrderedSet(s)
    guard other.count > 0, count > 0 else { return }
    _reserveCapacity(capacity)
    buffer.remove(contentsOf: other)
  }

  /// Return a new set with elements common to this set and a finite sequence.

  public func intersection<Source: Sequence>(_ s: Source) -> OrderedSet<Member>
    where Source.Iterator.Element == Member
  {
    var result = self
    result.formIntersection(s)
    return result
  }

  /// Remove any members of this set that aren't also in `set`.
  public mutating func formIntersection(_ set: OrderedSet<Member>) {
    var ranges = CountableRangeMap<Int>()
    for index in indices where !set.contains(self[index]) { ranges.insert(index) }

    guard ranges.count > 0 else { return }

    _reserveCapacity(capacity)

    for range in ranges.reversed() { buffer.removeSubrange(range) }
  }

  /// Remove any members of this set that aren't also in a finite sequence.
  public mutating func formIntersection<Source: Sequence>(_ s: Source)
    where Source.Iterator.Element == Member
  {
    formIntersection(s as? OrderedSet<Member> ?? OrderedSet<Member>(s))
  }

  /// Return a new set with elements that are either in the set or a finite
  /// sequence but do not occur in both.
  public func symmetricDifference<Source: Sequence>(_ s: Source) -> OrderedSet<Member>
    where Source.Iterator.Element == Member
  {
    var result = self
    result.formSymmetricDifference(s)
    return result
  }

  /// Modify collection to contain elements that are either in this set or
  /// `set` but do not occur in both.
  public mutating func formSymmetricDifference(_ orderedSet: OrderedSet<Member>) {
    var ranges = CountableRangeMap<Int>()
    var otherRanges = CountableRangeMap<Int>()
    for otherIndex in orderedSet.indices {
      guard let index = index(of: orderedSet[otherIndex]) else { continue }
      ranges.insert(index)
      otherRanges.insert(otherIndex)
    }
    otherRanges.invert(coverage:
      orderedSet.startIndex
        ...
        orderedSet.index(before: orderedSet.endIndex))
    let removeCount = ranges.flattenedCount
    let addCount = otherRanges.flattenedCount

    guard removeCount > 0 || addCount > 0 else { return }

    _reserveCapacity(count + addCount - removeCount)

    for range in ranges.reversed() { buffer.removeSubrange(range) }

    for range in otherRanges { buffer.append(contentsOf: orderedSet[range]) }
  }

  /// For each element of a finite sequence, remove it from the set if it is a
  /// common element, otherwise add it to the set. Repeated elements of the sequence
  /// will be ignored.
  public mutating func formSymmetricDifference<Source: Sequence>(_ sequence: Source)
    where Source.Iterator.Element == Element
  {
    formSymmetricDifference(sequence as? OrderedSet<Element>
      ?? OrderedSet<Element>(sequence))
  }
}

// MARK: RangeReplaceableCollectionType

public extension OrderedSet /*: RangeReplaceableCollection */ {
  /// Create an empty instance.
  init() { self = OrderedSet(buffer: Buffer(minimumCapacity: 0)) }

  /// A non-binding request to ensure `n` elements of available storage.
  ///
  /// This works as an optimization to avoid multiple reallocations of
  /// linear data structures like `Array`.  Conforming types may
  /// reserve more than `n`, exactly `n`, less than `n` elements of
  /// storage, or even ignore the request completely.
  mutating func reserveCapacity(_ minimumCapacity: Int) {
    _reserveCapacity(minimumCapacity)
  }

  /// Replace the given `subRange` of elements with `newElements`.
  ///
  /// Invalidates all indices with respect to `self`.
  ///
  /// - Complexity: O(`subRange.count`) if
  ///   `subRange.endIndex == self.endIndex` and `newElements.isEmpty`,
  ///   O(`self.count` + `newElements.count`) otherwise.
  mutating func replaceSubrange<Source: Collection>(_ subRange: Range<Int>,
                                                    with newElements: Source)
    where Source.Iterator.Element == Member
  {
    guard !(subRange.isEmpty && newElements.isEmpty) else { return }
    _reserveCapacity(count - subRange.count + numericCast(newElements.count))

    // Replace with uniqued collection
    buffer.replaceSubrange(subRange, with: newElements)
  }

  /// Append `element` to `self`.
  ///
  /// Applying `successor()` to the index of the new element yields
  /// `self.endIndex`.
  ///
  /// - Complexity: Amortized O(1).
  mutating func append(_ member: Member) {
    guard !contains(member) else { return }
    _reserveCapacity(Buffer.minimumCapacityFor(count &+ 1))
    buffer.append(member)
  }

  /// Append the elements of `newElements` to `self`.
  ///
  /// - Complexity: O(*length of result*).
  mutating func append<Source: Sequence>(contentsOf newElements: Source)
    where Source.Iterator.Element == Member
  {
    append(contentsOf: Array(newElements))
  }

  /// Append the elements of `newElements` to `self`.
  ///
  /// - Complexity: O(*length of result*).
  mutating func append<Source: Collection>(contentsOf newElements: Source)
    where Source.Iterator.Element == Member
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
  mutating func insert(_ newElement: Member, at index: Index) {
    guard !contains(newElement) else { return }
    _reserveCapacity(count + 1)
    buffer.insert(newElement, at: index)
  }

  /// Insert `newElements` at index `i`.
  ///
  /// Invalidates all indices with respect to `self`.
  ///
  /// - Complexity: O(`self.count + newElements.count`).
  mutating func insert<Source: Collection>(contentsOf newElements: Source,
                                           at index: Index)
    where Source.Iterator.Element == Member
  {
    _reserveCapacity(count + numericCast(newElements.count))
    buffer.insert(contentsOf: newElements, at: index)
  }

  /// Remove the element at index `i`.
  ///
  /// Invalidates all indices with respect to `self`.
  ///
  /// - Complexity: O(`self.count`).
  @discardableResult
  mutating func remove(at index: Index) -> Member {
    _reserveCapacity(capacity)
    return buffer.remove(at: index)
  }

  /// Remove the element at `startIndex` and return it.
  ///
  /// - Complexity: O(`self.count`)
  /// - Requires: `!self.isEmpty`.
  @discardableResult
  mutating func removeFirst() -> Member { return remove(at: startIndex) }

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
    buffer.removeSubrange(subRange)
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

// MARK: ExpressibleByArrayLiteral

extension OrderedSet: ExpressibleByArrayLiteral {
  public init(arrayLiteral elements: Member...) {
    self = OrderedSet(buffer: Buffer(elements))
  }
}

// MARK: CustomStringConvertible, CustomDebugStringConvertible

extension OrderedSet: CustomStringConvertible, CustomDebugStringConvertible {
  public var description: String {
    guard count > 0 else { return "[]" }

    var result = "["
    var first = true
    for element in self {
      if first { first = false } else { result += ", " }
      print(element, terminator: "", to: &result)
    }
    result += "]"
    return result
  }

  public var debugDescription: String {
    guard count > 0 else { return "[]" }

    var result = "["
    var first = true
    for element in self {
      if first { first = false } else { result += ", " }
      debugPrint(element, terminator: "", to: &result)
    }
    result += "]"
    return result
  }
}

// MARK: Equatable

extension OrderedSet: Equatable {
  public static func ==(lhs: OrderedSet<Member>, rhs: OrderedSet<Member>) -> Bool {
    guard !(lhs.buffer.identity == rhs.buffer.identity
      && lhs.count == rhs.count) else { return true }
    for (v1, v2) in zip(lhs, rhs) { guard v1 == v2 else { return false } }
    return true
  }
}

// MARK: - OrderedSetSlice

/// A hash-based set of elements that preserves element order.
public struct OrderedSetSlice<Member: Hashable>: RandomAccessCollection,
  _DestructorSafeContainer
{
  fileprivate typealias Buffer = OrderedSetBuffer<Member>
  fileprivate typealias BufferSlice = OrderedSetBufferSlice<Member>
  fileprivate typealias Storage = OrderedSetStorage<Member>

  public typealias Index = Int
  public typealias Element = Member
  public typealias _Element = Element
  public typealias SubSequence = OrderedSetSlice<Member>

  public var startIndex: Index { buffer.startIndex }

  public var endIndex: Index { buffer.endIndex }

  public subscript(index: Index) -> Member { buffer[index] }

  public subscript(subRange: Range<Int>) -> SubSequence {
    SubSequence(buffer: buffer[subRange])
  }

  fileprivate var buffer: BufferSlice

  /// The current number of elements
  public var count: Int { buffer.count }

  public var indices: CountableRange<Int> {
    return CountableRange(uncheckedBounds: (lower: startIndex, upper: endIndex))
  }

  fileprivate init(buffer: BufferSlice) { self.buffer = buffer }

  public func hash(into hasher: inout Hasher) {
    for element in self { element.hash(into: &hasher) }
  }

  public func _customContainsEquatableElement(_ element: Member) -> Bool? {
    return buffer.contains(member: element)
  }

  public func _customIndexOfEquatableElement(_ element: Member) -> Index?? {
    return Optional(buffer.index(of: element))
  }

  public func index(of member: Member) -> Index? { buffer.index(of: member) }
  public func contains(_ member: Member) -> Bool { buffer.contains(member: member) }

  public func _failEarlyRangeCheck(_ index: Int, bounds: Range<Int>) {}
  public func _failEarlyRangeCheck(_ range: Range<Int>, bounds: Range<Int>) {}

  @inline(__always)
  public func distance(from start: Int, to end: Int) -> Int { end &- start }
  @inline(__always) public func index(after i: Int) -> Int { i &+ 1 }
  @inline(__always) public func index(before i: Int) -> Int { i &- 1 }
  @inline(__always) public func index(_ i: Int, offsetBy n: Int) -> Int { i &+ n }
  @inline(__always)
  public func index(_ i: Int, offsetBy n: Int, limitedBy limit: Int) -> Int? {
    switch (i &+ n, n < 0) {
      case (let iʹ, true) where iʹ >= limit,
           (let iʹ, false) where iʹ <= limit:
        return iʹ
      default: return nil
    }
  }

  @inline(__always) public func formIndex(after i: inout Int) { i = i &+ 1 }
  @inline(__always) public func formIndex(before i: inout Int) { i = i &- 1 }
  @inline(__always) public func formIndex(_ i: inout Int, offsetBy n: Int) { i = i &+ n }
  @inline(__always)
  public func formIndex(_ i: inout Int, offsetBy n: Int, limitedBy limit: Int) -> Bool {
    switch (i &+ n, n < 0) {
      case (let iʹ, true) where iʹ >= limit,
           (let iʹ, false) where iʹ <= limit:
        i = iʹ
        return true
      default: return false
    }
  }
}

// MARK: SetType

public extension OrderedSetSlice /*: SetType */ {
  var isEmpty: Bool { return count == 0 }

  fileprivate func result<Source: Sequence>(of query: (OrderedSet<Member>) -> Bool,
                                            downcasting sequence: Source) -> Bool
    where Source.Iterator.Element == Member
  {
    if let other = sequence as? OrderedSet<Member> { return query(other) }
    else { return query(OrderedSet(sequence)) }
  }

  fileprivate func _isSubset(of other: OrderedSet<Member>) -> Bool {
    guard !(other.buffer.identity == buffer.identity
      && other.buffer.indices.contains(buffer.indices)) else { return true }
    guard count <= other.count else { return false }
    return first(where: { !other.contains($0) }) == nil
  }

  /// Returns true if the set is a subset of a finite sequence as a set.

  func isSubset<Source: Sequence>(of sequence: Source) -> Bool
    where Source.Iterator.Element == Member
  {
    return result(of: _isSubset, downcasting: sequence)
  }

  func isSubset(of other: OrderedSet<Member>) -> Bool { return _isSubset(of: other) }

  fileprivate func _isStrictSubset(of other: OrderedSet<Member>) -> Bool {
    guard !(other.buffer.identity == buffer.identity
      && other.buffer.indices.contains(buffer.indices)
      && buffer.indices.count < other.buffer.indices.count) else { return true }
    guard count < other.count else { return false }
    return first(where: { !other.contains($0) }) == nil
  }

  /// Returns true if the set is a subset of a finite sequence as a set but not equal.

  func isStrictSubset<Source: Sequence>(of sequence: Source) -> Bool
    where Source.Iterator.Element == Member
  {
    return result(of: _isStrictSubset, downcasting: sequence)
  }

  func isStrictSubset(of other: OrderedSet<Member>) -> Bool { _isStrictSubset(of: other) }

  fileprivate func _isSuperset(of other: OrderedSet<Member>) -> Bool {
    guard !(other.buffer.identity == buffer.identity
      && buffer.indices.contains(other.buffer.indices)) else { return true }
    guard count >= other.count else { return false }
    return other.first(where: { !contains($0) }) == nil
  }

  /// Returns true if the set is a superset of a finite sequence as a set.

  func isSuperset<Source: Sequence>(of sequence: Source) -> Bool
    where Source.Iterator.Element == Member
  {
    return result(of: _isSuperset, downcasting: sequence)
  }

  func isSuperset(of other: OrderedSet<Member>) -> Bool { return _isSuperset(of: other) }

  fileprivate func _isStrictSuperset(of other: OrderedSet<Member>) -> Bool {
    guard !(other.buffer.identity == buffer.identity
      && buffer.indices.contains(other.buffer.indices)
      && buffer.indices.count > other.buffer.indices.count) else { return true }

    guard count > other.count else { return false }
    return other.first(where: { !contains($0) }) == nil
  }

  /// Returns true if the set is a superset of a finite sequence as a set but not equal.

  func isStrictSuperset<Source: Sequence>(of sequence: Source) -> Bool
    where Source.Iterator.Element == Member
  {
    result(of: _isStrictSuperset, downcasting: sequence)
  }

  func isStrictSuperset(of other: OrderedSet<Member>) -> Bool {
    _isStrictSuperset(of: other)
  }

  fileprivate func _isDisjoint(with other: OrderedSet<Member>) -> Bool {
    guard other.buffer.identity != buffer.identity else {
      return !buffer.indices.overlaps(other.buffer.indices)
    }
    return first(where: { other.contains($0) }) == nil
      && other.first(where: { contains($0) }) == nil
  }

  /// Returns true if no members in the set are in a finite sequence as a set.

  func isDisjoint<Source: Sequence>(with sequence: Source) -> Bool
    where Source.Iterator.Element == Member
  {
    return result(of: _isDisjoint, downcasting: sequence)
  }

  func isDisjoint(with other: OrderedSet<Member>) -> Bool { return _isDisjoint(with: other) }

  func union<Source: Sequence>(_ sequence: Source) -> OrderedSet<Member>
    where Source.Iterator.Element == Member
  {
    return OrderedSet(self).union(sequence)
  }

  func subtracting<Source: Sequence>(_ sequence: Source) -> OrderedSet<Member>
    where Source.Iterator.Element == Member
  {
    return OrderedSet(self).subtracting(sequence)
  }

  func intersection<Source: Sequence>(_ sequence: Source) -> OrderedSet<Member>
    where Source.Iterator.Element == Member
  {
    return OrderedSet(self).intersection(sequence)
  }

  func symmetricDifference<Source: Sequence>(_ sequence: Source) -> OrderedSet<Member>
    where Source.Iterator.Element == Member
  {
    return OrderedSet(self).symmetricDifference(sequence)
  }
}

// MARK: CustomStringConvertible, CustomDebugStringConvertible

extension OrderedSetSlice: CustomStringConvertible, CustomDebugStringConvertible {
  public var description: String {
    guard count > 0 else { return "[]" }

    var result = "["
    var first = true
    for element in self {
      if first { first = false } else { result += ", " }
      print(element, terminator: "", to: &result)
    }
    result += "]"
    return result
  }

  public var debugDescription: String {
    guard count > 0 else { return "[]" }

    var result = "["
    var first = true
    for element in self {
      if first { first = false } else { result += ", " }
      debugPrint(element, terminator: "", to: &result)
    }
    result += "]"
    return result
  }
}

// MARK: Equatable

extension OrderedSetSlice: Equatable {
  public static func ==(lhs: OrderedSetSlice<Element>,
                        rhs: OrderedSetSlice<Element>) -> Bool
  {
    guard !(lhs.buffer.identity == rhs.buffer.identity
      && lhs.indices == rhs.indices) else { return true }
    for (v1, v2) in zip(lhs, rhs) where v1 != v2 { return false }
    return lhs.count == rhs.count
  }
}
