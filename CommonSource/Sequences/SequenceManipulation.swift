//
//  SequenceManipulation.swift
//  MoonKit
//
//  Created by Jason Cardwell on 12/7/17.
//  Copyright © 2017 Moondeer Studios. All rights reserved.
//
import Foundation

public extension Sequence {

  func flatCast<ElementOfResult>(as type: ElementOfResult.Type) -> [ElementOfResult] {
    return compactMap({$0 as? ElementOfResult})
  }

  func flatMap<CastElement, ElementOfResult>(as type: CastElement.Type,
                      _ transform: (CastElement) throws -> ElementOfResult?) rethrows -> [ElementOfResult]
  {
    return try flatCast(as: type).compactMap(transform)
  }

  func filterCast<CastElement>(as type: CastElement.Type,
                         _ isIncluded: (Self.Iterator.Element) throws -> Bool) rethrows -> [CastElement]
  {
    return try filter(isIncluded).flatCast(as: type)
  }

}

public extension Sequence
  where Iterator.Element:BinaryInteger
{
  var sum: Iterator.Element {
    let initial: Iterator.Element = 0
    return reduce(initial, {$0 + $1})
  }
}

public extension Sequence where Iterator.Element:FloatingPoint {

  var sum: Iterator.Element {
    let initial: Iterator.Element = 0
    return reduce(initial, {$0 + $1})
  }

}

public extension Sequence where Iterator.Element: Named {
  func sortByName() -> [Iterator.Element] {
    return sorted { $0.name < $1.name }
  }
}

public enum SegmentOptions<PadType> {
  case padFirstGroup(PadType)
  case padLastGroup(PadType)
  case unpaddedFirstGroup
  case unpaddedLastGroup
}

public extension Sequence {

  /**
   bisect:

   - parameter predicate: (Self.Generator.Element) throws -> Bool
  */
  func bisect(predicate: (Self.Iterator.Element) throws -> Bool) rethrows -> ([Self.Iterator.Element], [Self.Iterator.Element]) {
    var group1: [Self.Iterator.Element] = [], group2: [Self.Iterator.Element] = []
    for element in self { if try predicate(element) { group1.append(element) } else { group2.append(element) } }
    return (group1, group2)
  }


  /**
  segment:options:

  - parameter segmentSize: Int = 2
  - parameter options: SegmentOptions<Generator.Element> = .Default

  - returns: [[Generator.Element]]
  */
  func segment(_ segmentSize: Int = 2, options: SegmentOptions<Iterator.Element> = .unpaddedLastGroup) -> [[Iterator.Element]] {
    var result: [[Iterator.Element]] = []
    var array: [Iterator.Element] = []
    let segmentSize = segmentSize > 1 ? segmentSize : 1

    switch options {
      case .unpaddedLastGroup:
        for element in self {
          if array.count == segmentSize { result.append(array); array = [] }
          array.append(element)
        }
        result.append(array)

      case .padLastGroup(let p):
        for element in self {
          if array.count == segmentSize { result.append(array); array = [] }
          array.append(element)
        }
        while array.count < segmentSize { array.append(p) }
        result.append(array)

      case .unpaddedFirstGroup:
        for element in reversed() {
          if array.count == segmentSize { result.insert(array, at: 0); array = [] }
          array.insert(element, at: 0)
        }
        result.insert(array, at: 0)

      case .padFirstGroup(let p):
        for element in self {
          if array.count == segmentSize { result.insert(array, at: 0); array = [] }
          array.insert(element, at: 0)
        }
        while array.count < segmentSize { array.insert(p, at: 0) }
        result.append(array.reversed())

    }

    return result
  }

}


public struct InfiniteSequenceOf<T>: Sequence {
  fileprivate let value: T
  public init(_ v: T) { value = v }
  public func makeIterator() -> AnyIterator<T> { return AnyIterator({self.value}) }
}

public func zip<S:Sequence, T>(_ seq: S, value: T) -> [(S.Iterator.Element, T)] {
  return Array(zip(seq, InfiniteSequenceOf(value)))
}

/**
sequence:T):

- parameter v: (T
- parameter T):

- returns: SequenceOf<T>
*/
//public func sequence<T>(_ v: (T,T)) -> AnySequence<T> { return AnySequence([v.0, v.1]) }

/**
sequence:T:T):

- parameter v: (T
- parameter T:
- parameter T):

- returns: SequenceOf<T>
*/
//public func sequence<T>(_ v: (T,T,T)) -> AnySequence<T> { return AnySequence([v.0, v.1, v.2]) }

/**
sequence:T:T:T):

- parameter v: (T
- parameter T:
- parameter T:
- parameter T):

- returns: SequenceOf<T>
*/
//public func sequence<T>(_ v: (T,T,T,T)) -> AnySequence<T> { return AnySequence([v.0, v.1, v.2, v.3]) }

/**
disperse2:

- parameter s: S

- returns: (T, T)
*/
public func disperse2<S:Sequence,T>(_ s: S) -> (T, T) where S.Iterator.Element == T {
  let array = Array(s)
  return (array[0], array[1])
}

/**
disperse3:

- parameter s: S

- returns: (T, T, T)
*/
public func disperse3<S:Sequence,T>(_ s: S) -> (T, T, T) where S.Iterator.Element == T {
  let array = Array(s)
  return (array[0], array[1], array[2])
}

/**
disperse4:

- parameter s: S

- returns: (T, T, T, T)
*/
public func disperse4<S:Sequence,T>(_ s: S) -> (T, T, T, T) where S.Iterator.Element == T {
  let array = Array(s)
  return (array[0], array[1], array[2], array[3])
}

/**
Zip together two sequences as an array of tuples formed via cross product

- parameter s1: S1
- parameter s2: S2

- returns: [(S1.Generator.Element, S2.Generator.Element)]
*/
public func crossZip<S1:Sequence, S2:Sequence>(_ s1: S1, s2: S2) -> [(S1.Iterator.Element, S2.Iterator.Element)] {
  var result: [(S1.Iterator.Element, S2.Iterator.Element)] = []
  for outter in s1 {
    for inner in s2 {
      result.append((outter, inner))
    }
  }
  return result
}

/**
unzip:S1>:

- parameter z: Zip2<S0
- parameter S1>:

- returns: ([E0], [E1])
*/
public func unzip<S0:Sequence, S1:Sequence, E0, E1>(_ z: Zip2Sequence<S0, S1>) -> ([E0], [E1])
  where E0 == S0.Iterator.Element, E1 == S1.Iterator.Element
{
  return z.reduce(([], []), { (result: ([E0], [E1]), p: (E0, E1)) -> ([E0], [E1]) in
    var result = result
    result.0.append(p.0)
    result.1.append(p.1)
    return result
  })
}

/**
unzip:

- parameter s: S

- returns: ([E0], [E1])
*/
public func unzip<E0, E1, S:Sequence>(_ s: S) -> ([E0], [E1]) where S.Iterator.Element == (E0, E1) {
  return s.reduce(([], []), { (result: ([E0], [E1]), p: (E0, E1)) -> ([E0], [E1]) in
    var result = result
    result.0.append(p.0)
    result.1.append(p.1)
    return result
  })
}

public func collect<T>(_ generator: T) -> [T.Element] where T:IteratorProtocol {
  var generator = generator
  var result: [T.Element] = []
  var done = false
  while !done { if let e = generator.next() { result += [e] } else { done = true } }
  return result
}

public func collectFrom<C:Collection, S:Sequence>(_ source: C, indexes: S)
  -> [C.Iterator.Element] where C.Index == S.Iterator.Element
{
  var result: [C.Iterator.Element] = []
  for idx in indexes { result.append(source[idx]) }
  return result
}


