//
//  CollectionManipulations.swift
//  MoonKit
//
//  Created by Jason Cardwell on 4/12/15.
//  Copyright (c) 2015 Jason Cardwell. All rights reserved.
//

import Foundation

public extension MutableCollection where Index == Int, Iterator.Element:Named {
  mutating func sortByNameInPlace() {
    let sorted = self.sorted(by: { $0.name < $1.name })
    for i in sorted.indices {
      self[i] = sorted[i]
    }
  }
}

public extension Collection {
  var indexRange: Range<Index> { return startIndex ..< endIndex }
}

extension Collection where Indices:RandomAccessCollection {
  public func randomElements(_ count: Int) -> [Self.Iterator.Element] {

    var result: [Self.Iterator.Element] = []
    var indexes = Array(indices)

    for _ in 0 ..< (count < numericCast(self.count) ? count : numericCast(self.count)) {
      let index = Int(arc4random_uniform(numericCast(indexes.count)))
      let lastIndex = indexes.endIndex - 1

      result.append(self[indexes[index]])

      if index != lastIndex { indexes.swapAt(index, lastIndex) }

      indexes.removeLast()
    }

    return result
  }

}

public extension Collection where Index:Strideable, Index.Stride:SignedInteger {
  var countableIndexRange: CountableRange<Index> { return startIndex ..< endIndex }
}

/**
 Perform a binary search of the specified collection and return the index of `element` if found.

 - parameter collection: C
 - parameter element: C.Generator.Element

 - returns: C.Index?

 - requires: The collection to search is already sorted
 */
public func binarySearch<C:RandomAccessCollection>(_ collection: C, element: C.Iterator.Element) -> C.Index?
  where C.Iterator.Element: Comparable
{
  func searchSlice(_ slice: C.SubSequence) -> C.Index? {
    let index = slice.index(slice.startIndex, offsetBy: numericCast(slice.count / 2))
    let maybeElement = slice[index]
    guard maybeElement != element else { return index }
    if maybeElement < element && slice.index(after: index) != slice.endIndex {
      return searchSlice(slice[slice.index(after: index) ..< slice.endIndex])
    } else if maybeElement > element && index != slice.startIndex {
      return searchSlice(slice[slice.startIndex ..< index])
    }
    return nil
  }

  return searchSlice(collection[collection.startIndex ..< collection.endIndex])
}

/**
 Perform a binary search of the specified collection and return the index of the first
 element to satisfy `predicate` or nil.

 - parameter collection: C
 - parameter isOrderedBefore: (Element) -> Bool
 - parameter predicate: (Element) -> Bool

 - returns: C.Index?

 - requires: The collection to search is already sorted
 */
public func binarySearch<Element, C:RandomAccessCollection>(collection: C,
                         isOrderedBefore: @escaping (Element) throws -> Bool, predicate: @escaping (Element) throws -> Bool) rethrows -> C.Index?
  where C.SubSequence.Element == Element
{
  func searchSlice(_ slice: C.SubSequence) throws -> C.Index? {
    let index = slice.index(slice.startIndex, offsetBy: numericCast(slice.count / 2))
    let maybeElement = slice[index]
    guard try !predicate(maybeElement) else { return index }
    if try isOrderedBefore(maybeElement) && slice.index(after: index) != slice.endIndex {
      return try searchSlice(slice[slice.index(after: index) ..< slice.endIndex])
    } else if index != slice.startIndex {
      return try searchSlice(slice[slice.startIndex ..< index])
    }
    return nil
  }

  return try searchSlice(collection[collection.startIndex ..< collection.endIndex])
}


public func binaryInsertion<C:RandomAccessCollection>(_ collection: C, element: C.Iterator.Element) -> C.Index
  where C.Iterator.Element: Comparable
{
  guard !collection.isEmpty else { return collection.endIndex }
  guard collection[collection.startIndex] < element else { return collection.startIndex }
  guard collection[collection.index(before: collection.endIndex)] > element else { return collection.endIndex }

  func searchSlice(_ slice: C.SubSequence) -> C.Index {
    let index = slice.index(slice.startIndex, offsetBy: numericCast(slice.count / 2))
    let maybeElement = slice[index]
    guard maybeElement != element else { return index }
    if maybeElement < element {
      guard slice.index(after: index) != slice.endIndex else { return slice.endIndex }

      return searchSlice(slice[slice.index(after: index) ..< slice.endIndex])

    } else if maybeElement > element {
      guard index != slice.startIndex else { return slice.startIndex }
      return searchSlice(slice[slice.startIndex ..< index])

    }
    return collection.endIndex
  }
  
  return searchSlice(collection[collection.startIndex ..< collection.endIndex])
}
