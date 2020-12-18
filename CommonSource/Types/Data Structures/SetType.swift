//
//  SetType.swift
//  PerpetualGroove
//
//  Created by Jason Cardwell on 2/19/16.
//  Copyright © 2016 Moondeer Studios. All rights reserved.
//

import Foundation
public protocol SetType: SetAlgebra, Collection {

  @discardableResult mutating func remove(at: Index) -> Element
  init(minimumCapacity: Int)
  func isStrictSubset(of possibleStrictSuperset: Self) -> Bool
  func isStrictSuperset(of possibleStrictSubset: Self) -> Bool

}

extension SetType {
  // contains
  public static func ∈ (lhs: Element, rhs: Self) -> Bool { return rhs.contains(lhs) }
  public static func ∉ (lhs: Element, rhs: Self) -> Bool { return !(lhs ∈ rhs) }
  public static func ∋ (lhs: Self, rhs: Element) -> Bool { return lhs.contains(rhs) }
  public static func ∌ (lhs: Self, rhs: Element) -> Bool { return !(lhs ∋ rhs) }

  // subset
  public static func ⊂<S:Sequence>(lhs: Self, rhs: S) -> Bool where Self.Element == S.Iterator.Element {
    return lhs.isStrictSubset(of: Self(rhs))
  }
  public static func ⊄<S:Sequence>(lhs: Self, rhs: S) -> Bool where Self.Element == S.Iterator.Element {
    return !(lhs ⊂ rhs)
  }
  public static func ⊂(lhs: Self, rhs: Self) -> Bool { return lhs.isStrictSubset(of: rhs) }
  public static func ⊄(lhs: Self, rhs: Self) -> Bool { return !(lhs ⊂ rhs) }

  public static func ⊆<S:Sequence>(lhs: Self, rhs: S) -> Bool where Self.Element == S.Iterator.Element {
    return lhs.isSubset(of: Self(rhs))
  }
  public static func ⊈<S:Sequence>(lhs: Self, rhs: S) -> Bool where Self.Element == S.Iterator.Element {
    return !(lhs ⊆ rhs)
  }
  public static func ⊆(lhs: Self, rhs: Self) -> Bool { return lhs.isSubset(of: rhs) }
  public static func ⊈(lhs: Self, rhs: Self) -> Bool  { return !(lhs ⊆ rhs) }

  // superset
  public static func ⊃<S:Sequence>(lhs: Self, rhs: S) -> Bool where Self.Element == S.Iterator.Element {
    return lhs.isStrictSuperset(of: Self(rhs))
  }
  public static func ⊅<S:Sequence>(lhs: Self, rhs: S) -> Bool where Self.Element == S.Iterator.Element {
    return !(lhs ⊃ rhs)
  }
  public static func ⊃(lhs: Self, rhs: Self) -> Bool { return lhs.isStrictSuperset(of: rhs) }
  public static func ⊅(lhs: Self, rhs: Self) -> Bool { return !(lhs ⊃ rhs) }

  public static func ⊇<S:Sequence>(lhs: Self, rhs: S) -> Bool where Self.Element == S.Iterator.Element {
    return lhs.isSuperset(of: Self(rhs))
  }
  public static func ⊉<S:Sequence>(lhs: Self, rhs: S) -> Bool where Self.Element == S.Iterator.Element {
    return !(lhs ⊇ rhs)
  }
  public static func ⊇(lhs: Self, rhs: Self) -> Bool { return lhs.isSuperset(of: rhs) }
  public static func ⊉(lhs: Self, rhs: Self) -> Bool { return !(lhs ⊇ rhs) }

  // disjoint
//  public static func !⚭<S:Sequence>(lhs: Self, rhs: S) -> Bool where Self.Element == S.Iterator.Element {
//    return lhs.isDisjoint(with: Self(rhs))
//  }
//  public static func ⚭<S:Sequence>(lhs: Self, rhs: S) -> Bool where Self.Element == S.Iterator.Element {
//    return !(lhs ⚭ rhs)
//  }
//  public static func !⚭(lhs: Self, rhs: Self) -> Bool { return lhs.isDisjoint(with: rhs) }
//  public static func ⚭(lhs: Self, rhs: Self) -> Bool { return !(lhs ⚭ rhs) }

  // union
  public static func ∪<S:Sequence>(lhs: Self, rhs: S) -> Self where Self.Element == S.Iterator.Element {
    return lhs.union(Self(rhs))
  }
  public static func ∪=<S:Sequence>(lhs: inout Self, rhs: S) where Self.Element == S.Iterator.Element {
    lhs.formUnion(Self(rhs))
  }
  public static func ∪(lhs: Self, rhs: Self) -> Self { return lhs.union(rhs) }
  public static func ∪=(lhs: inout Self, rhs: Self) { lhs.formUnion(rhs) }
  public static func ∪(lhs: Self, rhs: Element) -> Self { var lhs = lhs; lhs ∪= rhs; return lhs }
  public static func ∪=(lhs: inout Self, rhs: Element) { lhs.insert(rhs) }

  // minus
  public static func ∖<S:Sequence>(lhs: Self, rhs: S) -> Self where Self.Element == S.Iterator.Element {
    return lhs.subtracting(Self(rhs))
  }
  public static func ∖=<S:Sequence>(lhs: inout Self, rhs: S) where Self.Element == S.Iterator.Element {
    lhs.subtract(Self(rhs))
  }
  public static func ∖(lhs: Self, rhs: Self) -> Self { return lhs.subtracting(rhs) }
  public static func ∖=(lhs: inout Self, rhs: Self) { lhs.subtract(rhs) }
  public static func ∖(lhs: Self, rhs: Element) -> Self { var lhs = lhs; lhs ∖= rhs; return lhs }
  public static func ∖=(lhs: inout Self, rhs: Element) { lhs.remove(rhs) }

  // intersect
  public static func ∩<S:Sequence>(lhs: Self, rhs: S) -> Self where Self.Element == S.Iterator.Element {
    return lhs.intersection(Self(rhs))
  }
  public static func ∩=<S:Sequence>(lhs: inout Self, rhs: S) where Self.Element == S.Iterator.Element {
    lhs.formIntersection(Self(rhs))
  }
  public static func ∩(lhs: Self, rhs: Self) -> Self { return lhs.intersection(rhs) }
  public static func ∩=(lhs: inout Self, rhs: Self) { lhs.formIntersection(rhs) }

  // xor
  public static func ∆<S:Sequence>(lhs: Self, rhs: S) -> Self where Self.Element == S.Iterator.Element {
    return lhs.symmetricDifference(Self(rhs))
  }
  public static func ∆=<S:Sequence>(lhs: inout Self, rhs: S) where Self.Element == S.Iterator.Element {
    lhs.formSymmetricDifference(Self(rhs))
  }
  public static func ∆(lhs: Self, rhs: Self) -> Self { return lhs.symmetricDifference(rhs) }
  public static func ∆=(lhs: inout Self, rhs: Self) { lhs.formSymmetricDifference(rhs) }
}
