//
//  OrderedSetBehaviorTests.swift
//  OrderedSetTests
//
//  Created by Jason Cardwell on 3/14/16.
//  Copyright © 2016 Jason Cardwell. All rights reserved.
//
@testable import MoonKit
import Nimble
import XCTest

final class OrderedSetBehaviorTests: XCTestCase {
  static let integerLoadedSet = MoonKit.OrderedSet(xxSmallIntegers1)
  static let stringLoadedSet = MoonKit.OrderedSet(xxSmallStrings1)

  func testCreation() {
    var orderedSet1 = MoonKit.OrderedSet<Int>(minimumCapacity: 8)
    expect(orderedSet1.capacity) >= 8
    expect(orderedSet1).to(haveCount(0))

    orderedSet1 = [1, 2, 3, 4, 5]
    expect(orderedSet1.capacity) >= 5
    expect(orderedSet1).to(haveCount(5))

    orderedSet1 = MoonKit.OrderedSet(xxSmallIntegers1)
    let set1 = Set(xxSmallIntegers1)
    expect(orderedSet1).to(haveCount(set1.count))

    var orderedSet2 = MoonKit.OrderedSet<String>(minimumCapacity: 8)
    expect(orderedSet2.capacity) >= 8
    expect(orderedSet2).to(haveCount(0))

    orderedSet2 = ["one", "two", "three", "four", "five"]
    expect(orderedSet2.capacity) >= 5
    expect(orderedSet2).to(haveCount(5))

    orderedSet2 = MoonKit.OrderedSet(xxSmallStrings1)
    let set2 = Set(xxSmallStrings1)
    expect(orderedSet2).to(haveCount(set2.count))
  }

  func testInsertion() {
    var orderedSet1 = MoonKit.OrderedSet<Int>(minimumCapacity: 8)

    orderedSet1.insert(1)
    expect(orderedSet1).to(haveCount(1))
    expect(orderedSet1[0]).to(equal(1))
    expect(orderedSet1).to(equal([1]))

    orderedSet1.insert(2)
    expect(orderedSet1).to(haveCount(2))
    expect(orderedSet1[1]).to(equal(2))
    expect(orderedSet1).to(equal([1, 2]))

    orderedSet1.insert(3)
    expect(orderedSet1).to(haveCount(3))
    expect(orderedSet1[2]).to(equal(3))
    expect(orderedSet1).to(equal([1, 2, 3]))

    orderedSet1.insert(4)
    expect(orderedSet1).to(haveCount(4))
    expect(orderedSet1[3]).to(equal(4))
    expect(orderedSet1).to(equal([1, 2, 3, 4]))

    orderedSet1.insert(5)
    expect(orderedSet1).to(haveCount(5))
    expect(orderedSet1[4]).to(equal(5))
    expect(orderedSet1).to(equal([1, 2, 3, 4, 5]))

    orderedSet1.insert(6, at: 2)
    expect(orderedSet1).to(haveCount(6))
    expect(orderedSet1[2]).to(equal(6))
    expect(orderedSet1).to(equal([1, 2, 6, 3, 4, 5]))

    orderedSet1.append(contentsOf: [5, 6, 7, 8])
    expect(orderedSet1).to(haveCount(8))
    expect(orderedSet1[6]).to(equal(7))
    expect(orderedSet1[7]).to(equal(8))
    expect(orderedSet1).to(equal([1, 2, 6, 3, 4, 5, 7, 8]))

    orderedSet1.insert(contentsOf: [1, 3, 9, 10], at: 6)
    expect(orderedSet1).to(haveCount(10))
    expect(orderedSet1[6]).to(equal(9))
    expect(orderedSet1[7]).to(equal(10))
    expect(orderedSet1).to(equal([1, 2, 6, 3, 4, 5, 9, 10, 7, 8]))

    var orderedSet2 = MoonKit.OrderedSet<String>(minimumCapacity: 8)

    orderedSet2.insert("one")
    expect(orderedSet2).to(haveCount(1))
    expect(orderedSet2[0]).to(equal("one"))
    expect(orderedSet2).to(equal(["one"]))

    orderedSet2.insert("two")
    expect(orderedSet2).to(haveCount(2))
    expect(orderedSet2[1]).to(equal("two"))
    expect(orderedSet2).to(equal(["one", "two"]))

    orderedSet2.insert("three")
    expect(orderedSet2).to(haveCount(3))
    expect(orderedSet2[2]).to(equal("three"))
    expect(orderedSet2).to(equal(["one", "two", "three"]))

    orderedSet2.insert("four")
    expect(orderedSet2).to(haveCount(4))
    expect(orderedSet2[3]).to(equal("four"))
    expect(orderedSet2).to(equal(["one", "two", "three", "four"]))

    orderedSet2.insert("five")
    expect(orderedSet2).to(haveCount(5))
    expect(orderedSet2[4]).to(equal("five"))
    expect(orderedSet2).to(equal(["one", "two", "three", "four", "five"]))

    orderedSet2.insert("six", at: 2)
    expect(orderedSet2).to(haveCount(6))
    expect(orderedSet2[2]).to(equal("six"))
    expect(orderedSet2).to(equal(["one", "two", "six", "three", "four", "five"]))

    orderedSet2.append(contentsOf: ["five", "six", "seven", "eight"])
    expect(orderedSet2).to(haveCount(8))
    expect(orderedSet2[6]).to(equal("seven"))
    expect(orderedSet2[7]).to(equal("eight"))
    expect(orderedSet2).to(equal(["one", "two", "six", "three", "four", "five", "seven", "eight"]))

    orderedSet2.insert(contentsOf: ["one", "three", "nine", "ten"], at: 6)
    expect(orderedSet2).to(haveCount(10))
    expect(orderedSet2[6]).to(equal("nine"))
    expect(orderedSet2[7]).to(equal("ten"))
    expect(orderedSet2) == ["one", "two", "six", "three", "four", "five", "nine", "ten", "seven", "eight"]

    var orderedSet3 = MoonKit.OrderedSet<Int>()
    for integer in xxSmallIntegers1 { orderedSet3.insert(integer) }
    expect(orderedSet3).to(haveCount(Set(xxSmallIntegers1).count))

    var orderedSet4 = MoonKit.OrderedSet<String>()
    for string in xxSmallStrings1 { orderedSet4.insert(string) }
    expect(orderedSet4).to(haveCount(Set(xxSmallStrings1).count))
  }

  func testResize() {
    var orderedSet1 = MoonKit.OrderedSet<Int>(minimumCapacity: 8)
    orderedSet1.insert(1)
    orderedSet1.insert(2)
    orderedSet1.insert(3)
    orderedSet1.insert(4)
    orderedSet1.insert(5)
    orderedSet1.insert(6)
    expect(orderedSet1).to(equal([1, 2, 3, 4, 5, 6]))
    orderedSet1.insert(7)
    expect(orderedSet1).to(equal([1, 2, 3, 4, 5, 6, 7]))
    orderedSet1.insert(8)
    orderedSet1.insert(9)
    orderedSet1.insert(10)
    expect(orderedSet1).to(equal([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]))

    var orderedSet2 = MoonKit.OrderedSet<String>(minimumCapacity: 8)
    orderedSet2.insert("one")
    orderedSet2.insert("two")
    orderedSet2.insert("three")
    orderedSet2.insert("four")
    orderedSet2.insert("five")
    orderedSet2.insert("six")
    expect(orderedSet2).to(equal(["one", "two", "three", "four", "five", "six"]))
    orderedSet2.insert("seven")
    expect(orderedSet2).to(equal(["one", "two", "three", "four", "five", "six", "seven"]))
    orderedSet2.insert("eight")
    orderedSet2.insert("nine")
    orderedSet2.insert("ten")
    expect(orderedSet2) == ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten"]
  }

  func testRemove() {
    var orderedSet1: MoonKit.OrderedSet = [1, 2, 3]
    expect(orderedSet1).to(equal([1, 2, 3]))
    orderedSet1.remove(at: 1)
    expect(orderedSet1).to(equal([1, 3]))
    orderedSet1.remove(at: 0)
    expect(orderedSet1).to(equal([3]))
    orderedSet1.insert(2)
    orderedSet1.insert(1)
    expect(orderedSet1).to(equal([3, 2, 1]))
    orderedSet1.remove(2)
    expect(orderedSet1).to(equal([3, 1]))
    orderedSet1.remove(9)
    expect(orderedSet1).to(equal([3, 1]))
    orderedSet1.removeFirst()
    expect(orderedSet1).to(equal([1]))
    orderedSet1.append(contentsOf: [2, 3, 4, 5, 6, 7, 8, 9, 10])
    expect(orderedSet1).to(equal([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]))
    orderedSet1.removeFirst(2)
    expect(orderedSet1).to(equal([3, 4, 5, 6, 7, 8, 9, 10]))
    orderedSet1.removeLast(4)
    expect(orderedSet1).to(equal([3, 4, 5, 6]))
    orderedSet1.removeSubrange(1 ..< 3)
    expect(orderedSet1).to(equal([3, 6]))
    orderedSet1.removeAll()
    expect(orderedSet1).to(beEmpty())

    var orderedSet2: MoonKit.OrderedSet<String> = ["one", "two", "three"]
    expect(orderedSet2).to(equal(["one", "two", "three"]))
    orderedSet2.remove(at: 1)
    expect(orderedSet2).to(equal(["one", "three"]))
    orderedSet2.remove(at: 0)
    expect(orderedSet2).to(equal(["three"]))
    orderedSet2.insert("two")
    orderedSet2.insert("one")
    expect(orderedSet2).to(equal(["three", "two", "one"]))
    orderedSet2.remove("two")
    expect(orderedSet2).to(equal(["three", "one"]))
    orderedSet2.remove("nine")
    expect(orderedSet2).to(equal(["three", "one"]))
    orderedSet2.removeFirst()
    expect(orderedSet2).to(equal(["one"]))
    orderedSet2.append(contentsOf: ["two", "three", "four", "five",
                                    "six", "seven", "eight", "nine", "ten"])
    expect(orderedSet2).to(equal(["one", "two", "three", "four", "five",
                                  "six", "seven", "eight", "nine", "ten"]))
    orderedSet2.removeFirst(2)
    expect(orderedSet2).to(equal(["three", "four", "five",
                                  "six", "seven", "eight", "nine", "ten"]))
    orderedSet2.removeLast(4)
    expect(orderedSet2).to(equal(["three", "four", "five", "six"]))
    orderedSet2.removeSubrange(1 ..< 3)
    expect(orderedSet2).to(equal(["three", "six"]))
    orderedSet2.removeAll()
    expect(orderedSet2).to(beEmpty())

    var orderedSet3 = type(of: self).integerLoadedSet
    while !orderedSet3.isEmpty {
      orderedSet3.remove(at: Int(arc4random_uniform(numericCast(orderedSet3.count))))
    }
    expect(orderedSet3).to(beEmpty())

    var orderedSet4 = type(of: self).stringLoadedSet
    while !orderedSet4.isEmpty {
      orderedSet4.remove(at: Int(arc4random_uniform(numericCast(orderedSet4.count))))
    }
    expect(orderedSet4).to(beEmpty())
  }

  func testReplaceRange() {
    var orderedSet1: MoonKit.OrderedSet = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    orderedSet1.replaceSubrange(0 ..< 5, with: [5, 4, 3, 2, 1])
    expect(orderedSet1).to(equal([5, 4, 3, 2, 1, 6, 7, 8, 9, 10]))
    orderedSet1.replaceSubrange(5 ..< 10, with: [0])
    expect(orderedSet1) == [5, 4, 3, 2, 1, 0]

    var orderedSet2: MoonKit.OrderedSet = ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten"]
    orderedSet2.replaceSubrange(0 ..< 5, with: ["five", "four", "three", "two", "one"])
    expect(orderedSet2).to(equal(["five", "four", "three", "two", "one",
                                  "six", "seven", "eight", "nine", "ten"]))
    orderedSet2.replaceSubrange(5 ..< 10, with: ["zero"])
    expect(orderedSet2) == ["five", "four", "three", "two", "one", "zero"]
  }

  func testCOW() {
    let orderedSet1: MoonKit.OrderedSet = [1, 2, 3]
    var orderedSet2 = orderedSet1
    expect(orderedSet1).to(equal(orderedSet2))

    orderedSet2.insert(4)
    expect(orderedSet1) != orderedSet2

    let orderedSet3: MoonKit.OrderedSet = ["one", "two", "three"]
    var orderedSet4 = orderedSet3
    expect(orderedSet3).to(equal(orderedSet4))

    orderedSet4.insert("four")
    expect(orderedSet3) != orderedSet4
  }

  func testSubscriptIndexAccessors() {
    let orderedSet1: MoonKit.OrderedSet = [1, 2, 3]
    expect(orderedSet1[0]).to(equal(1))
    expect(orderedSet1[1]).to(equal(2))
    expect(orderedSet1[2]) == 3

    let orderedSet2: MoonKit.OrderedSet = ["one", "two", "three"]
    expect(orderedSet2[0]).to(equal("one"))
    expect(orderedSet2[1]).to(equal("two"))
    expect(orderedSet2[2]) == "three"
  }

  func testSubscriptRangeAccessors() {
    let orderedSet1: MoonKit.OrderedSet = [1, 2, 3]
    let slice1 = orderedSet1[1 ... 2]
    expect(slice1).to(equal([2, 3]))
//    slice1.append(4)
//    expect(slice1).to(equal([2, 3, 4]))
//    expect(orderedSet1).to(equal([1, 2, 3]))
//    orderedSet1[1 ... 2] = slice1
//    expect(orderedSet1).to(equal([1, 2, 3, 4]))

    let orderedSet2: MoonKit.OrderedSet = ["one", "two", "three"]
    let slice2 = orderedSet2[1 ... 2]
    expect(slice2).to(equal(["two", "three"]))
//    slice2.append("four")
//    expect(slice2).to(equal(["two", "three", "four"]))
//    expect(orderedSet2).to(equal(["one", "two", "three"]))
//    orderedSet2[1 ... 2] = slice2
//    expect(orderedSet2).to(equal(["one", "two", "three", "four"]))
  }

  func testSubsetOf() {
    let orderedSet1: MoonKit.OrderedSet = [1, 2, 3]
    expect(orderedSet1).to(beSubsetOf([1, 2, 3]))
    expect(orderedSet1).to(beSubsetOf([1, 2, 3, 4]))
    expect(orderedSet1).toNot(beSubsetOf([1, 2, 4]))

    let orderedSet2: MoonKit.OrderedSet = ["one", "two", "three"]
    expect(orderedSet2).to(beSubsetOf(["one", "two", "three"]))
    expect(orderedSet2).to(beSubsetOf(["one", "two", "three", "four"]))
    expect(orderedSet2).toNot(beSubsetOf(["one", "two", "four"]))
  }

  func testStrictSubsetOf() {
    let orderedSet1: MoonKit.OrderedSet = [1, 2, 3]
    expect(orderedSet1.isStrictSubset(of: MoonKit.OrderedSet([1, 2, 3]))) == false
    expect(orderedSet1.isStrictSubset(of: MoonKit.OrderedSet([1, 2, 3, 4]))) == true
    expect(orderedSet1.isStrictSubset(of: MoonKit.OrderedSet([1, 2, 4]))) == false
    expect(orderedSet1.isStrictSubset(of: [1, 2, 3])) == false
    expect(orderedSet1.isStrictSubset(of: [1, 2, 3, 4])) == true
    expect(orderedSet1.isStrictSubset(of: [1, 2, 4])) == false
    expect(orderedSet1.isStrictSubset(of: AnySequence([1, 2, 3]))) == false
    expect(orderedSet1.isStrictSubset(of: AnySequence([1, 2, 3, 4]))) == true
    expect(orderedSet1.isStrictSubset(of: AnySequence([1, 2, 4]))) == false

    let orderedSet2: MoonKit.OrderedSet = ["one", "two", "three"]
    expect(orderedSet2.isStrictSubset(of: MoonKit.OrderedSet(["one", "two", "three"]))) == false
    expect(orderedSet2.isStrictSubset(of: MoonKit.OrderedSet(["one", "two", "three", "four"]))) == true
    expect(orderedSet2.isStrictSubset(of: MoonKit.OrderedSet(["one", "two", "four"]))) == false
    expect(orderedSet2.isStrictSubset(of: ["one", "two", "three"])) == false
    expect(orderedSet2.isStrictSubset(of: ["one", "two", "three", "four"])) == true
    expect(orderedSet2.isStrictSubset(of: ["one", "two", "four"])) == false
    expect(orderedSet2.isStrictSubset(of: AnySequence(["one", "two", "three"]))) == false
    expect(orderedSet2.isStrictSubset(of: AnySequence(["one", "two", "three", "four"]))) == true
    expect(orderedSet2.isStrictSubset(of: AnySequence(["one", "two", "four"]))) == false
  }

  func testSupersetOf() {
    let orderedSet1: MoonKit.OrderedSet = [1, 2, 3]
    expect(orderedSet1).to(beSupersetOf([1, 2, 3]))
    expect(orderedSet1).to(beSupersetOf([1, 2]))
    expect(orderedSet1).toNot(beSupersetOf([1, 2, 4]))

    let orderedSet2: MoonKit.OrderedSet = ["one", "two", "three"]
    expect(orderedSet2).to(beSupersetOf(["one", "two", "three"]))
    expect(orderedSet2).to(beSupersetOf(["one", "two"]))
    expect(orderedSet2).toNot(beSupersetOf(["one", "two", "four"]))
  }

  func testStrictSupersetOf() {
    let orderedSet1: MoonKit.OrderedSet = [1, 2, 3]
    expect(orderedSet1.isStrictSuperset(of: MoonKit.OrderedSet([1, 2, 3]))) == false
    expect(orderedSet1.isStrictSuperset(of: MoonKit.OrderedSet([1, 2]))) == true
    expect(orderedSet1.isStrictSuperset(of: MoonKit.OrderedSet([1, 2, 4]))) == false
    expect(orderedSet1.isStrictSuperset(of: [1, 2, 3])) == false
    expect(orderedSet1.isStrictSuperset(of: [1, 2])) == true
    expect(orderedSet1.isStrictSuperset(of: [1, 2, 4])) == false
    expect(orderedSet1.isStrictSuperset(of: AnySequence([1, 2, 3]))) == false
    expect(orderedSet1.isStrictSuperset(of: AnySequence([1, 2]))) == true
    expect(orderedSet1.isStrictSuperset(of: AnySequence([1, 2, 4]))) == false

    let orderedSet2: MoonKit.OrderedSet = ["one", "two", "three"]
    expect(orderedSet2.isStrictSuperset(of: MoonKit.OrderedSet(["one", "two", "three"]))) == false
    expect(orderedSet2.isStrictSuperset(of: MoonKit.OrderedSet(["one", "two"]))) == true
    expect(orderedSet2.isStrictSuperset(of: MoonKit.OrderedSet(["one", "two", "four"]))) == false
    expect(orderedSet2.isStrictSuperset(of: ["one", "two", "three"])) == false
    expect(orderedSet2.isStrictSuperset(of: ["one", "two"])) == true
    expect(orderedSet2.isStrictSuperset(of: ["one", "two", "four"])) == false
    expect(orderedSet2.isStrictSuperset(of: AnySequence(["one", "two", "three"]))) == false
    expect(orderedSet2.isStrictSuperset(of: AnySequence(["one", "two"]))) == true
    expect(orderedSet2.isStrictSuperset(of: AnySequence(["one", "two", "four"]))) == false
  }

  func testDisjointWith() {
    let orderedSet1: MoonKit.OrderedSet = [1, 2, 3]
    expect(orderedSet1).toNot(beDisjointWith([1, 4, 5] as [Int]))
    expect(orderedSet1).to(beDisjointWith([4, 5] as [Int]))
    expect(orderedSet1).toNot(beDisjointWith([1, 2, 3, 4, 5] as [Int]))

    let orderedSet2: MoonKit.OrderedSet = ["one", "two", "three"]
    expect(orderedSet2).toNot(beDisjointWith(["one", "four", "five"] as [String]))
    expect(orderedSet2).to(beDisjointWith(["four", "five"] as [String]))
    expect(orderedSet2).toNot(beDisjointWith(["one", "two", "three", "four", "five"] as [String]))

    let evenIntegers = evenNumbers(range: 0 ..< 500)
    let oddIntegers = oddNumbers(range: 0 ..< 500)
    let orderedSet3 = MoonKit.OrderedSet(evenIntegers)
    expect(orderedSet3).to(beDisjointWith(oddIntegers))
    expect(orderedSet3).toNot(beDisjointWith(evenIntegers))

    let evenStrings = evenIntegers.map(String.init)
    let oddStrings = oddIntegers.map(String.init)
    let orderedSet4 = MoonKit.OrderedSet(evenStrings)
    expect(orderedSet4).to(beDisjointWith(oddStrings))
    expect(orderedSet4).toNot(beDisjointWith(evenStrings))
  }

  func testUnion() {
    var orderedSet1 = MoonKit.OrderedSet(xxSmallIntegers1)
    orderedSet1.formUnion(xxSmallIntegers2)
    var set1 = Set(xxSmallIntegers1)
    set1.formUnion(xxSmallIntegers2)
    expect(orderedSet1).to(haveCount(set1.count))

    var orderedSet2 = MoonKit.OrderedSet(xxSmallStrings1)
    orderedSet2.formUnion(xxSmallStrings2)
    var set2 = Set(xxSmallStrings1)
    set2.formUnion(xxSmallStrings2)
    expect(orderedSet2).to(haveCount(set2.count))
  }

  func testIntersection() {
    var orderedSet1 = MoonKit.OrderedSet(xxSmallIntegers1)
    orderedSet1.formIntersection(xxSmallIntegers2)
    var set1 = Set(xxSmallIntegers1)
    set1.formIntersection(xxSmallIntegers2)
    expect(orderedSet1).to(haveCount(set1.count))

    var orderedSet2 = MoonKit.OrderedSet(xxSmallStrings1)
    orderedSet2.formIntersection(xxSmallStrings2)
    var set2 = Set(xxSmallStrings1)
    set2.formIntersection(xxSmallStrings2)
    expect(orderedSet2).to(haveCount(set2.count))
  }

  func testSubtract() {
    var orderedSet1 = MoonKit.OrderedSet(xxSmallIntegers1)
    orderedSet1.subtract(xxSmallIntegers2)
    var set1 = Set(xxSmallIntegers1)
    set1.subtract(xxSmallIntegers2)
    expect(orderedSet1).to(haveCount(set1.count))

    var orderedSet2 = MoonKit.OrderedSet(xxSmallStrings1)
    orderedSet2.subtract(xxSmallStrings2)
    var set2 = Set(xxSmallStrings1)
    set2.subtract(xxSmallStrings2)
    expect(orderedSet2).to(haveCount(set2.count))
  }

  func testSymmetricDifference() {
    var orderedSet1 = MoonKit.OrderedSet(xxSmallIntegers1)
    var set1 = Set(xxSmallIntegers1)
    set1.formSymmetricDifference(xxSmallIntegers2)
    orderedSet1.formSymmetricDifference(xxSmallIntegers2)
    expect(orderedSet1).to(haveCount(set1.count))

    var orderedSet2 = MoonKit.OrderedSet(xxSmallStrings1)
    var set2 = Set(xxSmallStrings1)
    set2.formSymmetricDifference(xxSmallStrings2)
    orderedSet2.formSymmetricDifference(xxSmallStrings2)
    expect(orderedSet2).to(haveCount(set2.count))
  }
}
