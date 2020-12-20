//
//  MappingOperations.swift
//  MoonKit
//
//  Created by Jason Cardwell on 4/12/15.
//  Copyright (c) 2015 Jason Cardwell. All rights reserved.
//

import Foundation

// MARK: - Removing nil values from a sequence

/**
compressed:

- parameter source: S

- returns: [T]
*/
public func compressed<S:Sequence, T>(_ source: S) -> [T] where S.Iterator.Element == Optional<T> {
  return source.filter({$0 != nil}).map({$0!})
}

/**
compressed:

- parameter source: S

- returns: [T]
*/
//public func compressed<S:Sequence, T>(_ source: S) -> [T] where S.Iterator.Element == T?, T:ExpressibleByNilLiteral {
//  return source.filter({$0 != nil})
//}
//
//public extension Sequence where Iterator.Element: ExpressibleByNilLiteral {
//  public var compressed: [Self.Iterator.Element] { return filter({$0 != nil}) }
//}
//
/**
compressedMap:transform:

- parameter source: S
- parameter transform: (T) -> U?

- returns: [U]
*/
//public func compressedMap<S:Sequence, T, U>(_ source: S, _ transform: (T) -> U?) -> [U] where S.Iterator.Element == T {
//  return source.map(transform) >>> compressed
//}

/**
compressedMap:transform:

- parameter source: S?
- parameter transform: (T) -> U?

- returns: [U]?
*/
//public func compressedMap<S:Sequence, T, U>(_ source: S?, _ transform: (T) -> U?) -> [U]? where S.Iterator.Element == T {
//  return source >?> transform >?> compressedMap
//}

// MARK: - Uniqueing

/**
uniqued:

- parameter seq: S

- returns: [T]
*/
public func uniqued<T:Hashable, S:Sequence>(_ seq: S) -> [T] where S.Iterator.Element == T {
  return Array(Set(seq))
}

/**
uniqued:

- parameter seq: S

- returns: [T]
*/
public func uniqued<T:Equatable, S:Sequence>(_ seq: S) -> [T] where S.Iterator.Element == T {
  var result: [T] = []
  for element in seq { if !result.contains(element) { result.append(element) } }
  return result
}

/**
unique<T:Equatable>:

- parameter array: [T]
*/
//public func unique<T:Equatable>(inout array:[T]) { array = uniqued(array) }


// MARK: - Reducing

/**
Flattens a sequence into an array of a single type, non-T types are dropped

- parameter sequence: S

- returns: [T]
*/
public func flattened<S:Sequence, T>(_ sequence: S) -> [T] {

  func flattenObjCTypes(array: [NSObject]) -> [T] {
    var result: [T] = []
    for element in array {
      if let childArray = element as? [NSObject] {
        result.append(contentsOf: flattenObjCTypes(array: childArray))
      } else if let elementAsT = element as? T { result.append(elementAsT) }
    }
    return result
  }

  func flattenSwiftTypes(mirror: Mirror) -> [T] {
    var result: [T] = []
    for index in mirror.children.indices {
      let (_, value) = mirror.children[index]
      if let valueAsT = value as? T { result.append(valueAsT) }
      else if let valueAsArray = value as? [NSObject] {
        result.append(contentsOf: flattenObjCTypes(array: valueAsArray))
      }
      let valueMirror = Mirror(reflecting: value)
      guard !valueMirror.children.isEmpty else { continue }
      result.append(contentsOf: flattenSwiftTypes(mirror: valueMirror))
    }
    return result
  }

  var result: [T] = []
  for element in sequence {
    let mirror = Mirror(reflecting: element)
    if let elementAsT = element as? T , mirror.children.isEmpty { result.append(elementAsT) }
    else { result.append(contentsOf: flattenSwiftTypes(mirror: mirror)) }
  }
  return result
}

/**
flattenedMap:transform:

- parameter source: S
- parameter transform: (T) -> U

- returns: [V]
*/
public func flattenedMap<S:Sequence, T, U, V>(_ source: S, _ transform: (T) -> U) -> [V]
  where S.Iterator.Element == T
{
  return flattened(source.map(transform))
}

/**
flattenedCompressedMap:transform:

- parameter source: S
- parameter transform: (T) -> U?

- returns: [V]
*/
//public func flattenedCompressedMap<S:Sequence, T, U, V>(_ source: S, _ transform: (T) -> U?) -> [V]
//  where S.Iterator.Element == T
//{
//  return flattened(compressedMap(transform(source)))
//}

/**
function for recursively reducing a property of an element that contains child elements of its kind

- parameter initial: U The initial value for the reduction
- parameter subitems: (T) -> [T] Closure for producing child elements of the item
- parameter combine: (U, T) -> Closure for producing the reduction for the item without recursing
- parameter item: T The initial item

- returns: U The result of the reduction
*/
public func recursiveReduce<T, U>(_ initial: U, subitems: (T) -> [T], _ combine: (U, T) -> U, item: T) -> U {
  var body: ((U, (T) -> [T], (U,T) -> U, T) -> U)!
  body = { (i: U, s: (T) -> [T], c: (U,T) -> U, x: T) -> U in s(x).reduce(c(i, x)){body($0, s, c, $1)} }
  return body(initial, subitems, combine, item)
}

// MARK: - Enumerating

public func enumeratingMap<S: Sequence, T>(_ source: S, _ transform: (Int, S.Iterator.Element) -> T) -> [T] {
  return source.enumerated().map(transform)
}

