//
//  NimbleMatchers.swift
//  MoonKit
//
//  Created by Jason Cardwell on 8/10/16.
//  Copyright © 2016 Jason Cardwell. All rights reserved.
//
import Foundation
import Nimble

// MARK: Tuple equality

public func equal<A: Equatable, B: Equatable>(_ expectedValue: (A, B)?) -> Predicate<(A, B)> {
  return Predicate.define("equal <\(stringify(expectedValue))>") {
    actualExpression, msg in

    let actualValue = try actualExpression.evaluate()
    let matches = (actualValue != nil
      && expectedValue != nil
      && actualValue! == expectedValue!)
    return PredicateResult(bool: matches, message: msg)
  }
}

public func equal<A: Equatable, B: Equatable, C: Equatable>(_ expectedValue: (A, B, C)?) -> Predicate<(A, B, C)> {
  return Predicate.define("equal <\(stringify(expectedValue))>") { actualExpression, msg in

    let actualValue = try actualExpression.evaluate()
    let matches = (actualValue != nil
      && expectedValue != nil
      && actualValue! == expectedValue!)

    return PredicateResult(bool: matches, message: msg)
  }
}

public func equal<A: Equatable, B: Equatable, C: Equatable, D: Equatable>(_ expectedValue: (A, B, C, D)?) -> Predicate<(A, B, C, D)> {
  return Predicate.define("equal <\(stringify(expectedValue))>") { actualExpression, msg in
    let actualValue = try actualExpression.evaluate()
    let matches = actualValue != nil && expectedValue != nil && actualValue! == expectedValue!

    return PredicateResult(bool: matches, message: msg)
  }
}

public func equal<A: Equatable, B: Equatable, C: Equatable, D: Equatable, E: Equatable>(_ expectedValue: (A, B, C, D, E)?) -> Predicate<(A, B, C, D, E)> {
  return Predicate.define("equal <\(stringify(expectedValue))>") { actualExpression, msg in
    let actualValue = try actualExpression.evaluate()
    let matches = actualValue != nil && expectedValue != nil && actualValue! == expectedValue!

    return PredicateResult(bool: matches, message: msg)
  }
}

public func equal<A: Equatable, B: Equatable, C: Equatable, D: Equatable, E: Equatable, F: Equatable>(_ expectedValue: (A, B, C, D, E, F)?) -> Predicate<(A, B, C, D, E, F)> {
  return Predicate.define("equal <\(stringify(expectedValue))>") { actualExpression, msg in

    let actualValue = try actualExpression.evaluate()
    let matches = actualValue != nil && expectedValue != nil && actualValue! == expectedValue!

    return PredicateResult(bool: matches, message: msg)
  }
}

public func equalWithAccuracy<T: FloatingPoint>(_ expectedValue: T, _ accuracy: T) -> Predicate<T> {
  return Predicate.define("equal <\(stringify(expectedValue))>") { actualExpression, msg in
    guard let actualValue = try actualExpression.evaluate() else {
      return PredicateResult(bool: false, message: msg)
    }
    return PredicateResult(bool: actualValue == expectedValue ||
      Swift.abs(expectedValue - actualValue) <= accuracy,
      message: msg)
  }
}

public func == <A: Equatable, B: Equatable>(lhs: Expectation<(A, B)>, rhs: (A, B)?) {
  lhs.to(equal(rhs))
}

public func == <A: Equatable, B: Equatable, C: Equatable>(lhs: Expectation<(A, B, C)>, rhs: (A, B, C)?) {
  lhs.to(equal(rhs))
}

public func == <A: Equatable, B: Equatable, C: Equatable, D: Equatable>(lhs: Expectation<(A, B, C, D)>, rhs: (A, B, C, D)?) {
  lhs.to(equal(rhs))
}

public func == <A: Equatable, B: Equatable, C: Equatable, D: Equatable, E: Equatable>(lhs: Expectation<(A, B, C, D, E)>, rhs: (A, B, C, D, E)?) {
  lhs.to(equal(rhs))
}

public func == <A: Equatable, B: Equatable, C: Equatable, D: Equatable, E: Equatable, F: Equatable>(lhs: Expectation<(A, B, C, D, E, F)>, rhs: (A, B, C, D, E, F)?) {
  lhs.to(equal(rhs))
}

public func != <A: Equatable, B: Equatable>(lhs: Expectation<(A, B)>, rhs: (A, B)?) {
  lhs.toNot(equal(rhs))
}

public func != <A: Equatable, B: Equatable, C: Equatable>(lhs: Expectation<(A, B, C)>, rhs: (A, B, C)?) {
  lhs.toNot(equal(rhs))
}

public func != <A: Equatable, B: Equatable, C: Equatable, D: Equatable>(lhs: Expectation<(A, B, C, D)>, rhs: (A, B, C, D)?) {
  lhs.toNot(equal(rhs))
}

public func != <A: Equatable, B: Equatable, C: Equatable, D: Equatable, E: Equatable>(lhs: Expectation<(A, B, C, D, E)>, rhs: (A, B, C, D, E)?) {
  lhs.toNot(equal(rhs))
}

public func != <A: Equatable, B: Equatable, C: Equatable, D: Equatable, E: Equatable, F: Equatable>(lhs: Expectation<(A, B, C, D, E, F)>, rhs: (A, B, C, D, E, F)?) {
  lhs.toNot(equal(rhs))
}

// MARK: SetAlgebra matchers

public func equal<S1: Sequence, S2: Sequence>(_ sequence: S2) -> Predicate<S1>
  where S1.Iterator.Element == S2.Iterator.Element, S1.Iterator.Element: Equatable
{
  return Predicate.define("equal \(sequence)") {
    actualExpression, msg in

    guard let actual = try actualExpression.evaluate() else {
      return PredicateResult(bool: false, message: msg)
    }
    return PredicateResult(bool: actual.elementsEqual(sequence), message: msg)
  }
}

public func == <S1: Sequence, S2: Sequence>(lhs: Expectation<S1>, rhs: S2)
  where S1.Iterator.Element == S2.Iterator.Element, S1.Iterator.Element: Equatable
{
  lhs.to(equal(rhs))
}

public func != <S1: Sequence, S2: Sequence>(lhs: Expectation<S1>, rhs: S2)
  where S1.Iterator.Element == S2.Iterator.Element, S1.Iterator.Element: Equatable
{
  lhs.toNot(equal(rhs))
}

public func equal<S1: Sequence, S2: Sequence>(_ sequence: S2,
                                              isEquivalent: @escaping (S1.Iterator.Element, S2.Iterator.Element) -> Bool) -> Predicate<S1>
  where S1.Iterator.Element == S2.Iterator.Element
{
  return Predicate.define("equal") {
    actualExpression, msg in

    guard let actual = try actualExpression.evaluate() else {
      return PredicateResult(bool: false, message: msg)
    }
    return PredicateResult(bool: actual.elementsEqual(sequence, by: isEquivalent),
                           message: msg)
  }
}

public func beSubsetOf<S1: SetAlgebra, S2: Sequence>(_ sequence: S2) -> Predicate<S1>
  where S1: Collection, S1.Element == S2.Element
{
  return Predicate.define {
    actualExpression in

    let actual = try actualExpression.evaluate()
    let bool = actual?.isSubset(of: S1(sequence)) ?? false
    return PredicateResult(
      bool: bool,
      message: .expectedCustomValueTo("to be a subset of \(sequence)",
                                      actual: String(describing: actual)))
  }
}

public func beStrictSubsetOf<S1: SetAlgebra, S2: Sequence>(_ sequence: S2) -> Predicate<S1>
  where S1: Collection, S1.Element == S2.Element
{
  return Predicate.define {
    actualExpression in
    let actual = try actualExpression.evaluate()
    let bool = actual?.isStrictSubset(of: S1(sequence)) ?? false
    return PredicateResult(
      bool: bool,
      message: .expectedCustomValueTo("to be a strict subset of \(sequence)",
                                      actual: String(describing: actual)))
  }
}

public func beSupersetOf<S1: SetAlgebra, S2: Sequence>(_ sequence: S2) -> Predicate<S1>
  where S1: Collection, S1.Element == S2.Element
{
  return Predicate.define {
    actualExpression in
    let actual = try actualExpression.evaluate()
    let bool = actual?.isSuperset(of: S1(sequence)) ?? false
    return PredicateResult(
      bool: bool,
      message: .expectedCustomValueTo("to be a superset of \(sequence)",
                                      actual: String(describing: actual)))
  }
}

public func beStrictSupersetOf<S1: SetAlgebra, S2: Sequence>(_ sequence: S2) -> Predicate<S1>
  where S1: Collection, S1.Element == S2.Element
{
  return Predicate.define {
    actualExpression in
    let actual = try actualExpression.evaluate()
    let bool = actual?.isStrictSuperset(of: S1(sequence)) ?? false
    return PredicateResult(
      bool: bool,
      message: .expectedCustomValueTo("to be a strict superset of \(sequence)",
                                      actual: String(describing: actual)))
  }
}

public func beDisjointWith<S1: SetAlgebra, S2: Sequence>(_ sequence: S2) -> Predicate<S1>
  where S1: Collection, S1.Element == S2.Element
{
  return Predicate.define {
    actualExpression in
    let actual = try actualExpression.evaluate()
    let bool = actual?.isDisjoint(with: S1(sequence)) ?? false
    return PredicateResult(
      bool: bool,
      message: .expectedCustomValueTo("to be disjoint with \(sequence)",
                                      actual: String(describing: actual)))
  }
}

// MARK: - FloatingPoint matchers

public func beNaN<F: FloatingPoint>() -> Predicate<F> {
  return Predicate.define("equal nan") {
    actualExpression, msg in

    guard let actualValue = try actualExpression.evaluate() else {
      return PredicateResult(bool: false, message: msg)
    }
    return PredicateResult(bool: actualValue.isNaN, message: msg)
  }
}

public func beFinite<F: FloatingPoint>() -> Predicate<F> {
  return Predicate.define("equal a finite value") {
    actualExpression, msg in

    guard let actualValue = try actualExpression.evaluate() else {
      return PredicateResult(bool: false, message: msg)
    }
    return PredicateResult(bool: actualValue.isFinite, message: msg)
  }
}

public func beInfinite<F: FloatingPoint>() -> Predicate<F> {
  return Predicate.define("equal an infinite value") {
    actualExpression, msg in

    guard let actualValue = try actualExpression.evaluate() else {
      return PredicateResult(bool: false, message: msg)
    }
    return PredicateResult(bool: actualValue.isInfinite, message: msg)
  }
}

public func beZero<F: FloatingPoint>() -> Predicate<F> {
  return Predicate.define("equal 0") {
    actualExpression, msg in

    guard let actualValue = try actualExpression.evaluate() else {
      return PredicateResult(bool: false, message: msg)
    }
    return PredicateResult(bool: actualValue.isZero, message: msg)
  }
}

public func beNormal<F: FloatingPoint>() -> Predicate<F> {
  return Predicate.define("equal a normal value") {
    actualExpression, msg in

    guard let actualValue = try actualExpression.evaluate() else {
      return PredicateResult(bool: false, message: msg)
    }
    return PredicateResult(bool: actualValue.isNormal, message: msg)
  }
}

public func bePositive<F: FloatingPoint>() -> Predicate<F> {
  return Predicate.define("equal a positive value") {
    actualExpression, msg in

    guard let actualValue = try actualExpression.evaluate() else {
      return PredicateResult(bool: false, message: msg)
    }
    return PredicateResult(bool: actualValue.sign == .plus, message: msg)
  }
}

public func beNegative<F: FloatingPoint>() -> Predicate<F> {
  return Predicate.define("equal a negative value") {
    actualExpression, msg in

    guard let actualValue = try actualExpression.evaluate() else {
      return PredicateResult(bool: false, message: msg)
    }
    return PredicateResult(bool: actualValue.sign == .minus, message: msg)
  }
}

public func beSignalingNaN<F: FloatingPoint>() -> Predicate<F> {
  return Predicate.define("equal snan") {
    actualExpression, msg in

    guard let actualValue = try actualExpression.evaluate() else {
      return PredicateResult(bool: false, message: msg)
    }
    return PredicateResult(bool: actualValue.isSignalingNaN, message: msg)
  }
}
