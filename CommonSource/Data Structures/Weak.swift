//
//  Weak.swift
//  MoonKit
//
//  Created by Jason Cardwell on 10/11/15.
//  Copyright © 2015 Jason Cardwell. All rights reserved.
//

import Foundation

// MARK: - Weak

public struct Weak<Reference: AnyObject>: Equatable, Hashable {
  public let identifier: ObjectIdentifier?
  public func hash(into hasher: inout Hasher) { identifier?.hash(into: &hasher) }
  public fileprivate(set) weak var reference: Reference?
  public init(_ ref: Reference?) {
    guard let ref = ref else { identifier = nil; return }
    defer { _fixLifetime(ref) }
    reference = ref
    identifier = ObjectIdentifier(ref)
  }
}

public func == <T: AnyObject>(lhs: Weak<T>, rhs: Weak<T>) -> Bool {
  lhs.hashValue == rhs.hashValue
}

// MARK: CustomStringConvertible

extension Weak: CustomStringConvertible {
  public var description: String {
    reference == nil ? "nil" : "\(type(of: reference!))(\(String(addressOf: reference!)))"
  }
}

public func compact<C: RangeReplaceableCollection, T: AnyObject>(_ collection: inout C)
  where C.Element == Weak<T>, C.SubSequence == C
{
  var result = collection.prefix(0)
  for element in collection where element.reference != nil { result.append(element) }
  collection = result
}

public func compact<T: AnyObject>(_ set: inout Set<Weak<T>>) {
  set = Set(set.filter { $0.reference != nil })
}
