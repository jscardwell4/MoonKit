//
//  Stack.swift
//  MoonKit
//
//  Created by Jason Cardwell on 9/17/14.
//  Copyright (c) 2014 Jason Cardwell. All rights reserved.
//

import Foundation

fileprivate func describe<Element>(_ elements: UnsafePointer<Element>, count: Int, debug: Bool) -> String {
  guard count > 0 else { return "[]" }
  var result = "["
  var first = true
  var iterator = StackIterator(elements: elements, top: count &- 1)
  while let element = iterator.next() {
    if first { first = false } else { result += ", " }
    if debug { debugPrint(element, terminator: "", to: &result) }
    else { print(element, terminator: "", to: &result) }
  }
  result += "]"
  return result
}

final class StackStorage<Element>: ManagedBuffer<(count: Int, capacity: Int), Element> {

  class func create(minimumCapacity: Int) -> StackStorage<Element> {
    super.create(minimumCapacity: minimumCapacity) { (0, $0.capacity) }
      as! StackStorage<Element>
  }

  var elements: UnsafeMutablePointer<Element> { withUnsafeMutablePointerToElements {$0} }

  deinit {
    withUnsafeMutablePointers {
      $1.deinitialize(count: $0.pointee.count)
      $0.deinitialize(count: 1) }
  }

}

fileprivate struct StackBuffer<Element>: _DestructorSafeContainer {

  typealias Storage = StackStorage<Element>
  typealias Buffer = StackBuffer<Element>

  var storage: Storage
  let elements: UnsafeMutablePointer<Element>

  var identity: UnsafeRawPointer { return UnsafeRawPointer(elements) }

  var count: Int {
    get { return storage.header.count }
    nonmutating set { storage.header.count = newValue }
  }

  var capacity: Int { return storage.header.capacity }

  @inline(__always)
  mutating func isUniquelyReferenced() -> Bool { Swift.isKnownUniquelyReferenced(&storage) }

  @inline(__always)
  mutating func isUniquelyReferencedWithCapacity(_ minimumCapacity: Int = 0) -> Bool {
    return isUniquelyReferenced() && storage.header.capacity >= minimumCapacity
  }

  var isEmpty: Bool { return count == 0 }

  var peek: Element? { return isEmpty ? nil : elements[count &- 1] }

  mutating func push(_ element: Element) {
    (elements + count).initialize(to: element)
    count = count &+ 1
  }

  mutating func pop() -> Element? {
    guard !isEmpty else { return nil }
    count = count &- 1
    return (elements + count).move()
  }

  mutating func reverse() {
    guard count > 1 else { return }
    var left = 0, right = count &- 1
    repeat {
      swap(&elements[left], &elements[right])
      left = left &+ 1
      right = right &- 1
    } while left < right
  }

  init(storage: Storage) {
    self.storage = storage
    elements = storage.elements
  }

  init(minimumCapacity: Int) {
    let storage = Storage.create(minimumCapacity: minimumCapacity)
    self = Buffer(storage: storage)
  }

  init() { self = Buffer(minimumCapacity: 0) }

  /// Create a clone of `buffer` with the specified `capacity`.
  init(buffer: Buffer, withCapacity capacity: Int) {
    let storage = Storage.create(minimumCapacity: capacity)
    storage.elements.initialize(from: buffer.elements, count: buffer.count)
    storage.header.count = buffer.count
    self = Buffer(storage: storage)
  }

  /// Create a clone of `buffer`.
  init(buffer: Buffer) { self = Buffer(buffer: buffer, withCapacity: buffer.capacity) }

  init<Source:Collection>(_ elements: Source) where Source.Iterator.Element == Element {
    let storage = Storage.create(minimumCapacity: numericCast(elements.count))
    _ = UnsafeMutableBufferPointer(start: storage.elements,
                                   count: elements.count).initialize(from: elements)
    storage.header.count = numericCast(elements.count)
    self = Buffer(storage: storage)
  }

}

extension StackBuffer: CustomStringConvertible, CustomDebugStringConvertible {
  fileprivate var description: String {
    return describe(UnsafePointer<Element>(elements), count: count, debug: false)
  }
  fileprivate var debugDescription: String {
    return describe(UnsafePointer<Element>(elements), count: count, debug: true)
  }
}

public struct StackIterator<Element>: IteratorProtocol {

  fileprivate let elements: UnsafePointer<Element>
  fileprivate var top: Int

  public mutating func next() -> Element? {
    guard top > -1 else { return nil }
    defer { top = top &- 1 }
    return elements[top]
  }

}

public struct Stack<Element>: Sequence, ExpressibleByArrayLiteral, _DestructorSafeContainer {

  fileprivate typealias Buffer = StackBuffer<Element>
  public typealias Iterator = StackIterator<Element>

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

  public func makeIterator() -> Iterator {
    return Iterator(elements: UnsafePointer(buffer.elements), top: buffer.count - 1)
  }

  public func reversed() -> Stack {
    var result = self
    result.buffer.reverse()
    return result }

  public mutating func reverse() {
    ensureUnique()
    buffer.reverse()
  }

  public mutating func push(_ element: Element) {
    ensureUnique(withCapacity: buffer.count + 1)
    buffer.push(element)
  }

  @discardableResult public mutating func pop() -> Element? {
    ensureUnique()
    return buffer.pop()
  }

  public init() { buffer = Buffer() }

  public init(minimumCapacity: Int) { buffer = Buffer(minimumCapacity: minimumCapacity) }

  public init<Source:Collection>(_ elements: Source)
  where Source.Iterator.Element == Element
  {
    buffer = Buffer(elements)
  }

  public init(arrayLiteral elements: Element...) { buffer = Buffer(elements) }

}

extension Stack: CustomStringConvertible, CustomDebugStringConvertible {
  public var description: String { buffer.description }
  public var debugDescription: String { buffer.debugDescription }
}

extension Stack where Element:Equatable {
  public static func ==(lhs: Stack<Element>, rhs: Stack<Element>) -> Bool {
    guard lhs.count == rhs.count else { return false }
    guard lhs.buffer.identity != rhs.buffer.identity else { return true }
    for (v1, v2) in zip(lhs, rhs) where v1 != v2 { return false }
    return true
  }
}
