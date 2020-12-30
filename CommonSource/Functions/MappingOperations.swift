//
//  MappingOperations.swift
//  MoonKit
//
//  Created by Jason Cardwell on 4/12/15.
//  Copyright (c) 2015 Jason Cardwell. All rights reserved.
//

import Foundation

/// Closes over a weakly captured object and makes it available to a curried closure
/// that takes some `U` value and returns some `Rl` value.
///
/// - Parameters:
///   - object: The object to weakly reference.
///   - default: The `R` value `block` should return when `object` is `nil`.
///   - block: A closure that takes the unwrapped weak reference to `object` and
///            returns a closure that takes some `U` value and returns some `R` value.
/// - Returns: A closure that takes some `U` value and returns some `R` value.
public func weakCapture<T, U, R>(of object: T,
                                 default: R,
                                 block: @escaping (T) -> (U) -> R) -> (U) -> R
where T:AnyObject
{
  { [weak object] in object == nil ? `default`: block(object!)($0) }
}

/// Closes over a weakly captured object and makes it available to a curried closure
/// that takes some `U` value and returns nothing.
///
/// - Parameters:
///   - object: The object to weakly reference.
///   - block: A closure that takes the unwrapped weak reference to `object` and
///            returns a closure that takes some `U` value and returns nothing.
/// - Returns: A closure that takes some `U` value and returns nothing.
public func weakCapture<T, U>(of object: T,
                                 block: @escaping (T) -> (U) -> ()) -> (U) -> ()
where T:AnyObject
{
  { [weak object] in if let object = object { block(object)($0) } }
}


/// Closes over a weakly captured object and makes it available to a curried closure
/// that takes no value and returns nothing.
///
/// - Parameters:
///   - object: The object to weakly reference.
///   - block: A closure that takes the unwrapped weak reference to `object` and
///            returns a closure that takes no value and returns nothing.
/// - Returns: A closure that takes no value and returns nothing.
public func weakCapture<T>(of object: T,
                                 block: @escaping (T) -> () -> ()) -> () -> ()
where T:AnyObject
{
  { [weak object] in if let object = object { block(object)() } }
}

/// Closes over a weakly captured object and makes it available to a curried closure
/// that takes some `U` value and returns a `Bool` value. The returned closure will
/// always return `false` if the weak reference to `object` becomes `nil`.
///
/// - Parameters:
///   - object: The object to weakly reference.
///   - block: A closure that takes the unwrapped weak reference to `object` and
///            returns a closure that takes some `U` value and returns a `Bool` value.
/// - Returns: A closure that takes some `U` value and returns a `Bool` value.
public func weakCapture<T, U>(of object: T,
                              block: @escaping (T) -> (U) -> Bool) -> (U) -> Bool
where T:AnyObject
{
  weakCapture(of: object, default: false, block: block)
}

/// Closes over an unowned object reference and makes it available to a curried closure
/// that takes some `U` value and returns some `R` value.
/// - Parameters:
///   - object: The object to reference without ownership.
///   - block: A closure that takes an unowned reference to `object` and returns a
///            closure that takes some `U` value and returns some `R` value.
/// - Returns: A closure that takes some `U` value and returns some `R` value.
public func unownedCapture<T, U, R>(of object: T,
                                    block: @escaping (T) -> (U) -> R) -> (U) -> R
where T:AnyObject
{
  { [unowned object] in block(object)($0) }
}

/// Closes over an unowned object reference and makes it available to a curried closure
/// that takes some `U` value and returns nothing.
/// - Parameters:
///   - object: The object to reference without ownership.
///   - block: A closure that takes an unowned reference to `object` and returns a
///            closure that takes some `U` value and returns nothing.
/// - Returns: A closure that takes some `U` value and returns nothing.
public func unownedCapture<T, U>(of object: T,
                                    block: @escaping (T) -> (U) -> ()) -> (U) -> ()
where T:AnyObject
{
  { [unowned object] in block(object)($0) }
}

/// Unwrap a sequence of optionals.
/// - Parameter source: The sequence of optional values.
/// - Returns: The non-nil values of `source`.
public func compressed<S:Sequence, T>(_ source: S) -> [T] where S.Element == Optional<T> {
  source.filter({$0 != nil}).map({$0!})
}

/// Flattens a sequence into an array of a single type, non-T types are dropped.
///
/// - Parameter sequence: The sequence to flatten.
/// - Returns: An array of all elements in `sequence` of type `T`.
public func flattened<S:Sequence, T>(_ sequence: S) -> [T] {

  func flattenObjCTypes(array: [NSObject]) -> [T] {
    var result: [T] = []
    for element in array {
      if let childArray = element as? [NSObject] {
        result.append(contentsOf: flattenObjCTypes(array: childArray))
      } else if let elementAsT = element as? T {
        result.append(elementAsT)
      }
    }
    return result
  }

  func flattenSwiftTypes(mirror: Mirror) -> [T] {
    var result: [T] = []
    for index in mirror.children.indices {
      let (_, value) = mirror.children[index]
      if let valueAsT = value as? T {
        result.append(valueAsT)
      } else if let valueAsArray = value as? [NSObject] {
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
    if let elementAsT = element as? T , mirror.children.isEmpty {
      result.append(elementAsT)
    } else {
      result.append(contentsOf: flattenSwiftTypes(mirror: mirror))
    }
  }
  return result
}
