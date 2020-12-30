//
//  Generic.swift
//  HomeRemote
//
//  Created by Jason Cardwell on 8/5/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit

public func stride<T:Strideable>(_ range: Range<T>, by stride: T.Stride) -> StrideTo<T> {
  return Swift.stride(from: range.lowerBound, to: range.upperBound, by: stride)
}

public func stride<T:Strideable>(_ range: CountableRange<T>, by stride: T.Stride) -> StrideTo<T> {
  return Swift.stride(from: range.lowerBound, to: range.upperBound, by: stride)
}

public func stride<T:Strideable>(_ range: ClosedRange<T>, by stride: T.Stride) -> StrideThrough<T> {
  return Swift.stride(from: range.lowerBound, through: range.upperBound, by: stride)
}

public func stride<T:Strideable>(_ range: CountableClosedRange<T>, by stride: T.Stride) -> StrideThrough<T> {
  return Swift.stride(from: range.lowerBound, through: range.upperBound, by: stride)
}

extension Comparable {
  public static func ≮(lhs: Self, rhs: Self) -> Bool { return !(lhs < rhs) }
  public static func !<(lhs: Self, rhs: Self) -> Bool { return !(lhs < rhs) }
  public static func ≯(lhs: Self, rhs: Self) -> Bool { return !(lhs > rhs) }
  public static func !>(lhs: Self, rhs: Self) -> Bool { return !(lhs > rhs) }
  public static func ≰(lhs: Self, rhs: Self) -> Bool { return !(lhs <= rhs) }
  public static func !<=(lhs: Self, rhs: Self) -> Bool { return !(lhs <= rhs) }
  public static func ≱(lhs: Self, rhs: Self) -> Bool { return !(lhs >= rhs) }
  public static func !>=(lhs: Self, rhs: Self) -> Bool { return !(lhs >= rhs) }
//  public static func ≥(lhs: Self, rhs: Self) -> Bool { return lhs >= rhs }
//  public static func ≤(lhs: Self, rhs: Self) -> Bool { return lhs <= rhs }
}

//public func `try`<R>(_ block: () throws -> R) -> R? {
//  var result: Any? = nil
//  return tryBlock({ do { result = try block() } catch { result = nil } }) == nil ? result as? R : nil
//}

public func encode<T>(_ value: T) -> Data {
  var value = value
  return withUnsafePointer(to: &value) { Data(bytes: UnsafeRawPointer($0), count: MemoryLayout<T>.size) }
}

public func fatal<R>(_ message: String) -> R {
  fatalError(message)
}


public func decode<T>(_ data: Data) -> T? {
  let pointer = UnsafeMutablePointer<T>.allocate(capacity: 1)
  let length = MemoryLayout<T>.size
  guard data.count == length else { return nil }
  (data as NSData).getBytes(pointer, length: length)
  return pointer.move()
}

public func ~=<T:Equatable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
    case let (lhs?, rhs?): return lhs ~= rhs
    case (nil, nil): return true
    default: return false
  }
}

public func typecast<T, S:Sequence>(_ sequence: S) -> [T]? {
  var result: [T] = []
  for s in sequence { guard let t = s as? T else { return nil }; result.append(t) }
  return result
}

public func typeCast<T,U>(_ t: T, _ u: U.Type) -> U? { return t as? U }
public func typeCast<T,U>(_ t: T?, _ u: U.Type) -> U? { return t != nil ? typeCast(t!, u) : nil }

public func weakMethod<T:AnyObject, U>(_ object: T, _ method: @escaping (T) -> (U) -> Void) -> (U) -> Void {
  return {
    [weak object] in
    guard object != nil else { return }
    method(object!)($0)
  }
}

