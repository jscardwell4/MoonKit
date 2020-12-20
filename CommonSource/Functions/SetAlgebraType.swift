//
//  SetAlgebraType.swift
//  MoonKit
//
//  Created by Jason Cardwell on 2/19/16.
//  Copyright © 2016 Jason Cardwell. All rights reserved.
//

import Foundation

// contains
public func ∈ <S: SetAlgebra>(lhs: S.Element, rhs: S) -> Bool { rhs.contains(lhs) }
public func ∋ <S: SetAlgebra>(lhs: S, rhs: S.Element) -> Bool { lhs.contains(rhs) }

public func ∉ <S: SetAlgebra>(lhs: S.Element, rhs: S) -> Bool { !(lhs ∈ rhs) }
public func ∌ <S: SetAlgebra>(lhs: S, rhs: S.Element) -> Bool { !(lhs ∋ rhs) }

// subset/superset
public func ⊂ <S: SetAlgebra>(lhs: S, rhs: S) -> Bool { lhs.isStrictSubset(of: rhs) }
public func ⊃ <S: SetAlgebra>(lhs: S, rhs: S) -> Bool { lhs.isStrictSuperset(of: rhs) }
public func ⊆ <S: SetAlgebra>(lhs: S, rhs: S) -> Bool { lhs.isSubset(of: rhs) }
public func ⊇ <S: SetAlgebra>(lhs: S, rhs: S) -> Bool { lhs.isSuperset(of: rhs) }

public func ⊄ <S: SetAlgebra>(lhs: S, rhs: S) -> Bool { !(lhs ⊂ rhs) }
public func ⊅ <S: SetAlgebra>(lhs: S, rhs: S) -> Bool { !(lhs ⊃ rhs) }
public func ⊈ <S: SetAlgebra>(lhs: S, rhs: S) -> Bool { !(lhs ⊆ rhs) }
public func ⊉ <S: SetAlgebra>(lhs: S, rhs: S) -> Bool { !(lhs ⊇ rhs) }

// union
//public func ∪ <S: SetAlgebra>(lhs: S, rhs: S) -> S where S.Element == S { lhs.union(rhs) }
//public func ∪= <S: SetAlgebra>(lhs: inout S, rhs: S) where S.Element == S { lhs.formUnion(rhs) }
public func ∪ <S: SetAlgebra>(lhs: S, rhs: S) -> S { lhs.union(rhs) }
public func ∪= <S: SetAlgebra>(lhs: inout S, rhs: S) { lhs.formUnion(rhs) }
public func ∪ <S: SetAlgebra>(lhs: S, rhs: S.Element) -> S { var lhs = lhs; lhs ∪= rhs; return lhs }
public func ∪= <S: SetAlgebra>(lhs: inout S, rhs: S.Element) { lhs.insert(rhs) }

// minus
//public func ∖ <S: SetAlgebra>(lhs: S, rhs: S) -> S where S.Element == S {
//  lhs.subtracting(rhs)
//}

//public func ∖= <S: SetAlgebra>(lhs: inout S, rhs: S) where S.Element == S { lhs.subtract(rhs) }
public func ∖ <S: SetAlgebra>(lhs: S, rhs: S) -> S { lhs.subtracting(rhs) }
public func ∖= <S: SetAlgebra>(lhs: inout S, rhs: S) { lhs.subtract(rhs) }
public func ∖ <S: SetAlgebra>(lhs: S, rhs: S.Element) -> S { var lhs = lhs; lhs ∖= rhs; return lhs }
public func ∖= <S: SetAlgebra>(lhs: inout S, rhs: S.Element) { lhs.remove(rhs) }

// intersect
public func ∩ <S: SetAlgebra>(lhs: S, rhs: S) -> S { lhs.intersection(rhs) }
public func ∩= <S: SetAlgebra>(lhs: inout S, rhs: S) { lhs.formIntersection(rhs) }

// xor
//public func ∆ <S: SetAlgebra>(lhs: S, rhs: S) -> S where S.Element == S { lhs.symmetricDifference(rhs) }
//public func ∆= <S: SetAlgebra>(lhs: inout S, rhs: S) where S.Element == S { lhs.formSymmetricDifference(rhs) }
public func ∆ <S: SetAlgebra>(lhs: S, rhs: S) -> S { lhs.symmetricDifference(rhs) }
public func ∆= <S: SetAlgebra>(lhs: inout S, rhs: S) { lhs.formSymmetricDifference(rhs) }
public func ∆ <S: SetAlgebra>(lhs: S, rhs: S.Element) -> S { lhs ∆ S([rhs]) }
public func ∆= <S: SetAlgebra>(lhs: inout S, rhs: S.Element) { lhs ∆= S([rhs]) }
