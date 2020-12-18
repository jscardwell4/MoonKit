//
//  Queue.swift
//  Remote
//
//  Created by Jason Cardwell on 5/05/15.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation

fileprivate func describe<Element>(storage: QueueStorage<Element>, debug: Bool) -> String {
  guard storage.header.count > 0 else { return "[]" }
  var result = "["
  var first = true
  var iterator = QueueIterator(storage: storage)
  while let element = iterator.next() {
    if first { first = false } else { result += ", " }
    if debug { debugPrint(element, terminator: "", to: &result) }
    else { print(element, terminator: "", to: &result) }
  }
  result += "]"
  return result
}

fileprivate struct QueueStorageHeader {
  var head = 0
  var tail = 0
  var count = 0
  let capacity: Int
  init(capacity: Int) { self.capacity = capacity }
}

fileprivate final class QueueStorage<Element>: ManagedBuffer<QueueStorageHeader, Element> {

  class func create(minimumCapacity: Int) -> QueueStorage<Element> {
    super.create(minimumCapacity: minimumCapacity) {
      QueueStorageHeader(capacity: $0.capacity) } as! QueueStorage<Element>
  }

  var elements: UnsafeMutablePointer<Element> { return withUnsafeMutablePointerToElements {$0} }

  deinit {
    withUnsafeMutablePointers {

      switch ($0.pointee.head, $0.pointee.tail) {
        case let (h, t) where h < t: (
          $1 + h).deinitialize(count: t &- h &+ 1)
        case let (h, t) where t < h:
          ($1 + h).deinitialize(count: $0.pointee.capacity &- h)
          $1.deinitialize(count: t &+ 1)
        default: break
      }

      $0.deinitialize(count: 1)
    }
  }

}

fileprivate struct QueueBuffer<Element>: _DestructorSafeContainer {

  typealias Storage = QueueStorage<Element>
  typealias Buffer = QueueBuffer<Element>

  var storage: Storage
  let elements: UnsafeMutablePointer<Element>

  var identity: UnsafeRawPointer { return UnsafeRawPointer(elements) }

  @inline(__always)
  mutating func isUniquelyReferenced() -> Bool { Swift.isKnownUniquelyReferenced(&storage) }

  @inline(__always)
  mutating func isUniquelyReferencedWithCapacity(_ minimumCapacity: Int = 0) -> Bool {
    return isUniquelyReferenced() && storage.header.capacity >= minimumCapacity
  }

  var peek: Element? { guard !isEmpty else { return nil }; return elements[head] }

  mutating func enqueue(_ element: Element) {
    if count > 0 { tail = (tail &+ 1) % capacity }
    (elements + tail).initialize(to: element)
    storage.header.count = count &+ 1
  }

  @discardableResult mutating func dequeue() -> Element? {
    guard !isEmpty else { return nil }
    defer {
      storage.header.count = count &- 1
      if !isEmpty { head = (head &+ 1) % capacity
      }
    }
    return (elements + head).move()
  }

  mutating func reverse() {
    let count = self.count
    let capacity = self.capacity

    guard count > 1 else { return }


    if head < tail {
      // Simple swapping localized to the range head ... tail
      var left = head, right = tail
      repeat {
        swap(&elements[left], &elements[right])
        left = left &+ 1
        right = right &- 1
      } while left < right
    } else {
      // Full swap of range 0 ..< capacity
      func isInitialized(_ offset: Int) -> Bool { return !((tail &+ 1)..<head).contains(offset) }

      var left = 0, right = capacity &- 1
      repeat {
        switch (isInitialized(left), isInitialized(right)) {
          case (true, true): swap(&elements[left], &elements[right])
          case (true, false): (elements + right).initialize(to: (elements + left).move())
          case (false, true): (elements + left).initialize(to: (elements + right).move())
          case (false, false): break
        }
        left = left &+ 1
        right = right &- 1
      } while left < right

      // Adjust head and tail to align with new locations in memory
      head = capacity &- 1 &- head
      tail = capacity &- 1 &- tail
      swap(&head, &tail)
    }

  }

  var head: Int { get { return storage.header.head } nonmutating set { storage.header.head = newValue } }
  var tail: Int { get { return storage.header.tail } nonmutating set { storage.header.tail = newValue } }
  var count: Int { return storage.header.count }
  var capacity: Int { return storage.header.capacity }
  var isEmpty: Bool { return count == 0 }

  init(minimumCapacity: Int) { self = Buffer(storage: Storage.create(minimumCapacity: minimumCapacity)) }

  init() { self = Buffer(minimumCapacity: 0) }

  init(storage: Storage) { self.storage = storage; elements = storage.elements }

  init<Source:Collection>(_ sourceElements: Source) where Source.Iterator.Element == Element {
    let count: Int = numericCast(sourceElements.count)
    let storage = Storage.create(minimumCapacity: count)
    storage.withUnsafeMutablePointers {
      header, elements in

      _ = UnsafeMutableBufferPointer(start: elements, count: sourceElements.count)
            .initialize(from: sourceElements)

      guard count > 0 else { return }
      header.pointee.tail = count &- 1
      header.pointee.count = count
    }
    self = Buffer(storage: storage)
  }

  /// Create a clone of `buffer` with the specified `capacity`.
  init(buffer: Buffer, withCapacity capacity: Int) {
    let oldStorage = buffer.storage
    let newStorage = Storage.create(minimumCapacity: capacity)
    newStorage.withUnsafeMutablePointers {
      newHeader, newElements in
      oldStorage.withUnsafeMutablePointers {
          oldHeader, oldElements in
        switch (oldHeader.pointee.head, oldHeader.pointee.tail) {
        case let (h, t) where h < t:
            let oldElements = oldElements.advanced(by: h)
            let count = oldHeader.pointee.count
            newElements.initialize(from: oldElements, count: count)
          case let (h, t) where t < h:
            var newElements = newElements
            var oldElements = oldElements.advanced(by: h)
            var count = oldHeader.pointee.capacity &- h
            newElements.initialize(from: oldElements, count: count)
            newElements += count
            oldElements -= h
            count = t &+ 1
            newElements.initialize(from: oldElements, count: count)
          case let (h, _)/* where t == h*/:
            guard oldHeader.pointee.count == 1 else { break }
            newElements.initialize(to: oldElements.advanced(by: h).pointee)
        }
        newHeader.pointee.tail = Swift.max(0, oldHeader.pointee.count &- 1)
        newHeader.pointee.count = oldHeader.pointee.count
      }
    }

    self = Buffer(storage: newStorage)
  }

  /// Create a clone of `buffer`.
  init(buffer: Buffer) { self = Buffer(buffer: buffer, withCapacity: buffer.capacity) }

}

extension QueueBuffer: CustomStringConvertible, CustomDebugStringConvertible {
  fileprivate var description: String { return describe(storage: storage, debug: false) }
  fileprivate var debugDescription: String { return describe(storage: storage, debug: true) }
}

public struct QueueIterator<Element>: IteratorProtocol {
  fileprivate var storage: QueueStorage<Element>
  fileprivate var current: Int
  fileprivate var endReached = false
  fileprivate init(storage: QueueStorage<Element>) { self.storage = storage; current = storage.header.head }
  public mutating func next() -> Element? {
    switch (storage.header.tail, storage.header.count, storage.header.capacity) {

      case (_, 0, _),
           (_, _, _) where endReached:
        return nil

      case let (tail, _, _) where current == tail:
        defer { endReached = true }
        return storage.elements[current]

      case (_, _, let capacity):
        defer { current = (current &+ 1) % capacity }
        return storage.elements[current]

    }
  }
}

public struct Queue<Element>: Sequence, ExpressibleByArrayLiteral, _DestructorSafeContainer {
  fileprivate typealias Buffer = QueueBuffer<Element>
  public typealias Iterator = QueueIterator<Element>

  public func makeIterator() -> Iterator { return Iterator(storage: buffer.storage) }

  fileprivate var buffer: Buffer

  fileprivate mutating func ensureUnique(withCapacity minimumCapacity: Int? = nil) {
    guard !(minimumCapacity == nil
              ? buffer.isUniquelyReferenced()
              : buffer.isUniquelyReferencedWithCapacity(minimumCapacity!)) else { return }
    buffer = minimumCapacity == nil
      ? Buffer(buffer: buffer)
      : Buffer(buffer: buffer, withCapacity: Swift.max(buffer.count * 2, minimumCapacity!))
  }

  public var peek: Element? { return buffer.peek }
  public var count: Int { return buffer.count }
  public var underestimatedCount: Int { return buffer.count }
  public var capacity: Int { return buffer.capacity }
  public var isEmpty: Bool { return buffer.isEmpty }

  public mutating func reserveCapacity(minimumCapacity: Int) { ensureUnique(withCapacity: minimumCapacity) }

  public mutating func enqueue(_ element: Element) { ensureUnique(withCapacity: buffer.count &+ 1); buffer.enqueue(element) }

  @discardableResult public mutating func dequeue() -> Element? { ensureUnique(); return buffer.dequeue() }

  @discardableResult public mutating func dequeue(count: Int) -> Queue<Element> {
    ensureUnique();
    var result = Queue<Element>()
    for _ in 0..<count {
      guard let element = buffer.dequeue() else { break }
      result.enqueue(element)
    }

    return result
  }

  public func reversed() -> Queue { var result = self; result.buffer.reverse(); return result }

  public mutating func reverse() { ensureUnique(); buffer.reverse() }

  public init() { buffer = Buffer() }

  public init(minimumCapacity: Int) { buffer = Buffer(minimumCapacity: minimumCapacity) }

  public init<Source:Collection>(_ elements: Source) where Source.Iterator.Element == Element { buffer = Buffer(elements) }

  public init(arrayLiteral elements: Element...) { buffer = Buffer(elements) }

  public init<Source:Sequence>(_ elements: Source) where Source.Iterator.Element == Element {
    var queue = Queue(minimumCapacity: elements.underestimatedCount)
    for element in elements { queue.enqueue(element) }
    self = queue
  }

}

extension Queue: CustomStringConvertible, CustomDebugStringConvertible {
  public var description: String { return buffer.description }
  public var debugDescription: String { return buffer.debugDescription }
}

extension Queue where Element:Equatable {
  public static func ==(lhs: Queue<Element>, rhs: Queue<Element>) -> Bool {
    guard lhs.count == rhs.count else { return false }
    guard lhs.buffer.identity != rhs.buffer.identity else { return true }
    for (v1, v2) in zip(lhs, rhs) where v1 != v2 { return false }
    return true
  }
}

