//
//  CircularBuffer.swift
//  MoonKit
//
//  Created by Jason Cardwell on 5/25/18.
//  Copyright © 2018 Moondeer Studios. All rights reserved.
//
import Foundation

public struct CirclularBuffer<Element> {

  private var array: Array<Element>

  public private(set) var startIndex: Int = 0

  public private(set) var endIndex: Int = 0

  public let capacity: Int

  public var count: Int {

    switch (startIndex, endIndex) {
      case let (start, end) where start == end: return 0
      case let (start, end) where end > start: return end - start
      case let (start, end) where end < start: return array.endIndex - start + end - 1
      default:                                 fatalError("The impossible happened.")
    }

  }

  public init(capacity: Int) {
    self.capacity = capacity
    array = []
    array.reserveCapacity(capacity)
  }

  public init<S>(_ s: S) where Element == S.Element, S:Sequence {
    array = Array<Element>(s)
    capacity = array.count
    endIndex = array.endIndex
  }

  public init(repeating repeatedValue: Element, count: Int) {
    capacity = count
    array = Array<Element>(repeating: repeatedValue, count: count)
    endIndex = array.endIndex
  }

  public mutating func append(_ newElement: Element) {

    guard array.capacity > 0 else { return }

    array.withUnsafeMutableBufferPointer {
      [capacity = self.capacity] buffer in

      guard let baseAddress = buffer.baseAddress else { return }

      (baseAddress + endIndex).initialize(repeating: newElement, count: 1)

      switch (startIndex, endIndex) {

      case let (start, end) where end >= start:

        endIndex = end + 1 >= capacity ? 0 : end + 1

      case let (start, end) where end < start:

        endIndex = endIndex &+ 1
        if endIndex == start {
          startIndex = startIndex &+ 1
          if startIndex == capacity { startIndex = 0 }
        }

      default:
        fatalError("The impossible happened.")

      }

    }

  }

  public mutating func append<S>(contentsOf newElements: S)
    where Element == S.Element, S:Sequence
  {
    for element in newElements { append(element) }
  }

}
