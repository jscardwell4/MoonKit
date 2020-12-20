//
//  OrderedDictionaryBehaviorTests.swift
//  OrderedDictionaryTests
//
//  Created by Jason Cardwell on 2/25/16.
//  Copyright © 2016 Jason Cardwell. All rights reserved.
//
import XCTest
import Nimble
@testable import MoonKit

final class OrderedDictionaryBehaviorTests: XCTestCase {

  static let loadedDictionary = OrderedDictionary(xxSmallStringsIntegers0)

  func testCreation() {
    var orderedDictionary1 = OrderedDictionary<String, Int>(minimumCapacity: 8)
    expect(orderedDictionary1.capacity) >= 8
    expect(orderedDictionary1).to(haveCount(0))

    orderedDictionary1 = ["one": 1, "two": 2, "three": 3, "four": 4, "five": 5]

    expect(orderedDictionary1.capacity) >= 5
    expect(orderedDictionary1).to(haveCount(5))

    let pairs1 = [("1", 1), ("2", 2), ("3", 3), ("4", 4), ("5", 5)].map(keyValuePair)
    orderedDictionary1 = OrderedDictionary<String, Int>(pairs1)
    expect(orderedDictionary1).to(haveCount(5))

    var orderedDictionary2 = OrderedDictionary<Int, String>(minimumCapacity: 8)
    expect(orderedDictionary2.capacity) >= 8
    expect(orderedDictionary2).to(haveCount(0))

    orderedDictionary2 = [1: "one", 2: "two", 3: "three", 4: "four", 5: "five"]
    expect(orderedDictionary2.capacity) >= 5
    expect(orderedDictionary2).to(haveCount(5))

    let pairs2 = [(1, "1"), (2, "2"), (3, "3"), (4, "4"), (5, "5")].map(keyValuePair)
    orderedDictionary2 = OrderedDictionary<Int, String>(pairs2)
    expect(orderedDictionary2).to(haveCount(5))
  }

  func testResize() {
    var orderedDictionary1 = OrderedDictionary<String, Int>(minimumCapacity: 8)
    orderedDictionary1["one"] = 1
    orderedDictionary1["two"] = 2
    orderedDictionary1["three"] = 3
    orderedDictionary1["four"] = 4
    orderedDictionary1["five"] = 5
    orderedDictionary1["six"] = 6
    expect(orderedDictionary1.values).to(equal([1, 2, 3, 4, 5, 6]))
    orderedDictionary1["seven"] = 7
    expect(orderedDictionary1.values).to(equal([1, 2, 3, 4, 5, 6, 7]))
    orderedDictionary1["eight"] = 8
    orderedDictionary1["nine"] = 9
    orderedDictionary1["ten"] = 10
    expect(orderedDictionary1.values).to(equal([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]))

    var orderedDictionary2 = OrderedDictionary<Int, String>(minimumCapacity: 8)
    orderedDictionary2[1] = "one"
    orderedDictionary2[2] = "two"
    orderedDictionary2[3] = "three"
    orderedDictionary2[4] = "four"
    orderedDictionary2[5] = "five"
    orderedDictionary2[6] = "six"
    expect(orderedDictionary2.values).to(equal(["one", "two", "three", "four", "five", "six"]))
    orderedDictionary2[7] = "seven"
    expect(orderedDictionary2.values).to(equal(["one", "two", "three", "four", "five", "six", "seven"]))
    orderedDictionary2[8] = "eight"
    orderedDictionary2[9] = "nine"
    orderedDictionary2[10] = "ten"
    expect(orderedDictionary2.values) == ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten"]

  }

  func testCOW() {
    let orderedDictionary1: OrderedDictionary<String, Int> = ["one": 1, "two": 2, "three": 3]
    var orderedDictionary2 = orderedDictionary1
    expect(orderedDictionary1).to(equal(orderedDictionary2))

    orderedDictionary2["four"] = 4
    expect(orderedDictionary1) != orderedDictionary2
  }

  func testInsertValueForKey() {
    var orderedDictionary1 = OrderedDictionary<String, Int>(minimumCapacity: 8)

    orderedDictionary1.insert(value: 1, forKey: "one")
    expect(orderedDictionary1).to(haveCount(1))
    expect(orderedDictionary1["one"]).to(equal(1))
    expect(orderedDictionary1.values).to(equal([1]))

    orderedDictionary1.insert(value: 2, forKey: "two")
    expect(orderedDictionary1).to(haveCount(2))
    expect(orderedDictionary1["two"]).to(equal(2))
    expect(orderedDictionary1.values).to(equal([1, 2]))

    orderedDictionary1.insert(value: 3, forKey: "three")
    expect(orderedDictionary1).to(haveCount(3))
    expect(orderedDictionary1["three"]).to(equal(3))
    expect(orderedDictionary1.values).to(equal([1, 2, 3]))

    orderedDictionary1.insert(value: 4, forKey: "four")
    expect(orderedDictionary1).to(haveCount(4))
    expect(orderedDictionary1["four"]).to(equal(4))
    expect(orderedDictionary1.values).to(equal([1, 2, 3, 4]))

    orderedDictionary1.insert(value: 5, forKey: "five")
    expect(orderedDictionary1).to(haveCount(5))
    expect(orderedDictionary1["five"]).to(equal(5))
    expect(orderedDictionary1.values).to(equal([1, 2, 3, 4, 5]))

    var orderedDictionary2 = OrderedDictionary<Int, String>(minimumCapacity: 8)

    orderedDictionary2.insert(value: "one", forKey: 1)
    expect(orderedDictionary2).to(haveCount(1))
    expect(orderedDictionary2[1]).to(equal("one"))
    expect(orderedDictionary2.values).to(equal(["one"]))

    orderedDictionary2.insert(value: "two", forKey: 2)
    expect(orderedDictionary2).to(haveCount(2))
    expect(orderedDictionary2[2]).to(equal("two"))
    expect(orderedDictionary2.values).to(equal(["one", "two"]))

    orderedDictionary2.insert(value: "three", forKey: 3)
    expect(orderedDictionary2).to(haveCount(3))
    expect(orderedDictionary2[3]).to(equal("three"))
    expect(orderedDictionary2.values).to(equal(["one", "two", "three"]))

    orderedDictionary2.insert(value: "four", forKey: 4)
    expect(orderedDictionary2).to(haveCount(4))
    expect(orderedDictionary2[4]).to(equal("four"))
    expect(orderedDictionary2.values).to(equal(["one", "two", "three", "four"]))

    orderedDictionary2.insert(value: "five", forKey: 5)
    expect(orderedDictionary2).to(haveCount(5))
    expect(orderedDictionary2[5]).to(equal("five"))
    expect(orderedDictionary2.values) == ["one", "two", "three", "four", "five"]

    var orderedDictionary3 = OrderedDictionary<String, Int>()
    for (key, value) in xxSmallStringsIntegers0 {
      orderedDictionary3.insert(value: value, forKey: key)
    }
  }

  func testRemoveAll() {
    var orderedDictionary1: OrderedDictionary<String, Int> = ["one": 1, "two": 2, "three": 3]
    expect(orderedDictionary1).toNot(beEmpty())
    orderedDictionary1.removeAll()
    expect(orderedDictionary1).to(beEmpty())

    var orderedDictionary2: OrderedDictionary<Int, String> = [1: "one", 2: "two", 3: "three"]
    expect(orderedDictionary2).toNot(beEmpty())
    orderedDictionary2.removeAll()
    expect(orderedDictionary2).to(beEmpty())
  }

  func testRemoveValueForKey() {
    var orderedDictionary1: OrderedDictionary<String, Int> = ["one": 1, "two": 2, "three": 3]
    expect(orderedDictionary1.values).to(equal([1, 2, 3]))
    expect(orderedDictionary1.removeValue(forKey: "two")) == 2
    expect(orderedDictionary1.values).to(equal([1, 3]))
    expect(orderedDictionary1.removeValue(forKey: "two")).to(beNil())
    expect(orderedDictionary1.removeValue(forKey: "one")) == 1
    expect(orderedDictionary1.values).to(equal([3]))
    orderedDictionary1["two"] = 2
    orderedDictionary1["one"] = 1
    expect(orderedDictionary1.values).to(equal([3, 2, 1]))

    var orderedDictionary2: OrderedDictionary<Int, String> = [1: "one", 2: "two", 3: "three"]
    expect(orderedDictionary2.values).to(equal(["one", "two", "three"]))
    expect(orderedDictionary2.removeValue(forKey: 2)) == "two"
    expect(orderedDictionary2.values).to(equal(["one", "three"]))
    expect(orderedDictionary2.removeValue(forKey: 2)).to(beNil())
    expect(orderedDictionary2.removeValue(forKey: 1)) == "one"
    expect(orderedDictionary2.values).to(equal(["three"]))
    orderedDictionary2[2] = "two"
    orderedDictionary2[1] = "one"
    expect(orderedDictionary2.values) == ["three", "two", "one"]

    var orderedDictionary3 = OrderedDictionaryBehaviorTests.loadedDictionary
    for (key, _) in xxSmallStringsIntegers0 {
      orderedDictionary3.removeValue(forKey: key)
    }

  }

  func testSubscriptKeyAccessors() {
    var orderedDictionary: OrderedDictionary<String, Int> = ["one": 1, "two": 2, "three": 3]
    expect(orderedDictionary["two"]).to(equal(2))
    orderedDictionary["four"] = 4
    expect(orderedDictionary["four"]).to(equal(4))
    expect(orderedDictionary.keys).to(equal(["one", "two", "three", "four"]))
    expect(orderedDictionary.values) == [1, 2, 3, 4]
  }

  func testSubscriptIndexAccessors() {
    var orderedDictionary: OrderedDictionary<String, Int> = ["one": 1, "two": 2, "three": 3]
    expect(orderedDictionary[1]).to(equal(("two", 2)))
    orderedDictionary[2] = ("four", 4)
    expect(orderedDictionary[2]).to(equal(("four", 4)))
    expect(orderedDictionary.keys).to(equal(["one", "two", "four"]))
    expect(orderedDictionary.values) == [1, 2, 4]
  }

  func testSubscriptRangeAccessors() {
    let orderedDictionary1: OrderedDictionary<String, Int> = ["one": 1, "two": 2, "three": 3]
    let slice1 = orderedDictionary1[1 ... 2]
    expect(slice1.keys).to(equal(["two", "three"]))
    expect(slice1.values).to(equal([2, 3]))
//    slice1["four"] = 4
//    let slice1Keys = Array(slice1.keys)
//    let slice1Values = Array(slice1.values)
//    expect(slice1Keys).to(equal(["two", "three", "four"]))
//    expect(slice1Values).to(equal([2, 3, 4]))
//    expect(orderedDictionary1.keys).to(equal(["one", "two", "three"]))
//    expect(orderedDictionary1.values).to(equal([1, 2, 3]))
//    orderedDictionary1[1 ... 2] = slice1
//    expect(orderedDictionary1.keys).to(equal(["one", "two", "three", "four"]))
//    expect(orderedDictionary1.values).to(equal([1, 2, 3, 4]))

    let orderedDictionary2: OrderedDictionary<Int, String> = [1: "one", 2: "two", 3: "three"]
    let slice2 = orderedDictionary2[1 ... 2]
    expect(slice2.keys).to(equal([2, 3]))
    expect(slice2.values).to(equal(["two", "three"]))
//    slice2[4] = "four"
//    expect(slice2.keys).to(equal([2, 3, 4]))
//    expect(slice2.values).to(equal(["two", "three", "four"]))
//    expect(orderedDictionary2.keys).to(equal([1, 2, 3]))
//    expect(orderedDictionary2.values).to(equal(["one", "two", "three"]))
//    orderedDictionary2[1 ... 2] = slice2
//    expect(orderedDictionary2.keys).to(equal([1, 2, 3, 4]))
//    expect(orderedDictionary2.values) == ["one", "two", "three", "four"]
  }

  func testRemoveAtIndex() {
    var orderedDictionary1: OrderedDictionary<String, Int> = ["one": 1, "two": 2, "three": 3]
    expect(orderedDictionary1.remove(at: 0)) == ("one", 1)
    expect(orderedDictionary1.remove(at: 1)) == ("three", 3)
    expect(orderedDictionary1.remove(at: 0)) == ("two", 2)

    var orderedDictionary2: OrderedDictionary<Int, String> = [1: "one", 2: "two", 3: "three"]
    expect(orderedDictionary2.remove(at: 0)) == (1, "one")
    expect(orderedDictionary2.remove(at: 1)) == (3, "three")
    expect(orderedDictionary2.remove(at: 0)) == (2, "two")
  }

  func testIndexForKey() {
    let orderedDictionary1: OrderedDictionary<String, Int> = ["one": 1, "two": 2, "three": 3]
    expect(orderedDictionary1.index(forKey: "one")) == 0
    expect(orderedDictionary1.index(forKey: "two")) == 1
    expect(orderedDictionary1.index(forKey: "three")) == 2
    expect(orderedDictionary1.index(forKey: "four")).to(beNil())

    let orderedDictionary2: OrderedDictionary<Int, String> = [1: "one", 2: "two", 3: "three"]
    expect(orderedDictionary2.index(forKey: 1)) == 0
    expect(orderedDictionary2.index(forKey: 2)) == 1
    expect(orderedDictionary2.index(forKey: 3)) == 2
    expect(orderedDictionary2.index(forKey: 4)).to(beNil())
  }

  func testUpdateValueForKey() {
    var orderedDictionary1: OrderedDictionary<String, Int> = ["one": 1, "two": 2, "three": 3]
    expect(orderedDictionary1.updateValue(4, forKey: "two")) == 2
    expect(orderedDictionary1.value(forKey: "two")) == 4

    var orderedDictionary2: OrderedDictionary<Int, String> = [1: "one", 2: "two", 3: "three"]
    expect(orderedDictionary2.updateValue("four", forKey: 2)) == "two"
    expect(orderedDictionary2.value(forKey: 2)) == "four"

    var orderedDictionary3 = OrderedDictionaryBehaviorTests.loadedDictionary
    for (key, value) in xxSmallStringsIntegers1 {
      orderedDictionary3.updateValue(value, forKey: key)
    }
  }

  func testReplaceRange() {
    var orderedDictionary: OrderedDictionary<String, Int> = ["one": 1, "two": 2, "three": 3, "four": 4, "five": 5,
                                                             "six": 6, "seven": 7, "eight": 8, "nine": 9, "ten": 10]
    orderedDictionary.replaceSubrange(0 ..< 5, with: [("five", 5), ("four", 4), ("three", 3), ("two", 2), ("one", 1)].map(keyValuePair))
    expect(orderedDictionary).to(equal(["five": 5, "four": 4, "three": 3, "two": 2, "one": 1,
                                              "six": 6, "seven": 7, "eight": 8, "nine": 9, "ten": 10] as OrderedDictionary<String, Int>))
    orderedDictionary.replaceSubrange(5 ..< 10, with: [(key: "zero", value: 0)])
    expect(orderedDictionary) == (["five": 5, "four": 4, "three": 3, "two": 2, "one": 1, "zero": 0] as OrderedDictionary<String, Int>)
  }

  func testAppend() {
    var orderedDictionary1: OrderedDictionary<String, Int> = ["one": 1, "two": 2, "three": 3]
    expect(orderedDictionary1.keys).to(equal(["one", "two", "three"]))
    expect(orderedDictionary1.values).to(equal([1, 2, 3]))
    orderedDictionary1.append((key: "four", value: 4))
    expect(orderedDictionary1.keys).to(equal(["one", "two", "three", "four"]))
    expect(orderedDictionary1.values).to(equal([1, 2, 3, 4]))

    var orderedDictionary2: OrderedDictionary<Int, String> = [1: "one", 2: "two", 3: "three"]
    expect(orderedDictionary2.values).to(equal(["one", "two", "three"]))
    expect(orderedDictionary2.keys).to(equal([1, 2, 3]))
    orderedDictionary2.append((key: 4, value: "four"))
    expect(orderedDictionary2.keys).to(equal([1, 2, 3, 4]))
    expect(orderedDictionary2.values) == ["one", "two", "three", "four"]
  }

  func testAppendContentsOf() {
    var orderedDictionary1: OrderedDictionary<String, Int> = ["one": 1, "two": 2, "three": 3]
    expect(orderedDictionary1.keys).to(equal(["one", "two", "three"]))
    expect(orderedDictionary1.values).to(equal([1, 2, 3]))
    orderedDictionary1.append(contentsOf: [("four", 4), ("five", 5)].map(keyValuePair))
    expect(orderedDictionary1.keys).to(equal(["one", "two", "three", "four", "five"]))
    expect(orderedDictionary1.values).to(equal([1, 2, 3, 4, 5]))
    orderedDictionary1.append(contentsOf: [(key: "four", value: 4)])
    expect(orderedDictionary1.keys).to(equal(["one", "two", "three", "four", "five"]))
    expect(orderedDictionary1.values).to(equal([1, 2, 3, 4, 5]))

    var orderedDictionary2: OrderedDictionary<Int, String> = [1: "one", 2: "two", 3: "three"]
    expect(orderedDictionary2.values).to(equal(["one", "two", "three"]))
    expect(orderedDictionary2.keys).to(equal([1, 2, 3]))
    orderedDictionary2.append(contentsOf: [(4, "four"), (5, "five")].map(keyValuePair))
    expect(orderedDictionary2.keys).to(equal([1, 2, 3, 4, 5]))
    expect(orderedDictionary2.values).to(equal(["one", "two", "three", "four", "five"]))
    orderedDictionary2.append(contentsOf: [(key: 4, value: "four")])
    expect(orderedDictionary2.keys).to(equal([1, 2, 3, 4, 5]))
    expect(orderedDictionary2.values) == ["one", "two", "three", "four", "five"]
  }

  func testInsertAtIndex() {
    var orderedDictionary1: OrderedDictionary<String, Int> = ["one": 1, "two": 2, "three": 3]
    expect(orderedDictionary1.keys).to(equal(["one", "two", "three"]))
    expect(orderedDictionary1.values).to(equal([1, 2, 3]))
    orderedDictionary1.insert((key: "zero", value: 0), at: 0)
    expect(orderedDictionary1.keys).to(equal(["zero", "one", "two", "three"]))
    expect(orderedDictionary1.values).to(equal([0, 1, 2, 3]))
    orderedDictionary1.insert((key: "two", value: 2), at: 1)
    expect(orderedDictionary1.keys).to(equal(["zero", "one", "two", "three"]))
    expect(orderedDictionary1.values).to(equal([0, 1, 2, 3]))

    var orderedDictionary2: OrderedDictionary<Int, String> = [1: "one", 2: "two", 3: "three"]
    expect(orderedDictionary2.values).to(equal(["one", "two", "three"]))
    expect(orderedDictionary2.keys).to(equal([1, 2, 3]))
    orderedDictionary2.insert((key: 0, value: "zero"), at: 0)
    expect(orderedDictionary2.keys).to(equal([0, 1, 2, 3]))
    expect(orderedDictionary2.values).to(equal(["zero", "one", "two", "three"]))
    orderedDictionary2.insert((key: 2, value: "two"), at: 1)
    expect(orderedDictionary2.keys).to(equal([0, 1, 2, 3]))
    expect(orderedDictionary2.values) == ["zero", "one", "two", "three"]
  }

  func testInsertContentsOfAtIndex() {
    var orderedDictionary1: OrderedDictionary<String, Int> = ["one": 1, "two": 2, "three": 3]
    expect(orderedDictionary1.keys).to(equal(["one", "two", "three"]))
    expect(orderedDictionary1.values).to(equal([1, 2, 3]))
    orderedDictionary1.insert(contentsOf: [("negative one", -1), ("zero", 0)].map(keyValuePair), at: 0)
    expect(orderedDictionary1.keys).to(equal(["negative one", "zero", "one", "two", "three"]))
    expect(orderedDictionary1.values).to(equal([-1, 0, 1, 2, 3]))
    orderedDictionary1.insert(contentsOf: [("two", 2), ("three", 3)].map(keyValuePair), at: 1)
    expect(orderedDictionary1.keys).to(equal(["negative one", "zero", "one", "two", "three"]))
    expect(orderedDictionary1.values).to(equal([-1, 0, 1, 2, 3]))
    orderedDictionary1.insert(contentsOf: [("three", 3), ("four", 4)].map(keyValuePair), at: 3)
    expect(orderedDictionary1.keys).to(equal(["negative one", "zero", "one", "four", "two", "three"]))
    expect(orderedDictionary1.values).to(equal([-1, 0, 1, 4, 2, 3]))

    var orderedDictionary2: OrderedDictionary<Int, String> = [1: "one", 2: "two", 3: "three"]
    expect(orderedDictionary2.values).to(equal(["one", "two", "three"]))
    expect(orderedDictionary2.keys).to(equal([1, 2, 3]))
    orderedDictionary2.insert(contentsOf: [(-1, "negative one"), (0, "zero")].map(keyValuePair), at: 0)
    expect(orderedDictionary2.keys).to(equal([-1, 0, 1, 2, 3]))
    expect(orderedDictionary2.values).to(equal(["negative one", "zero", "one", "two", "three"]))
    orderedDictionary2.insert(contentsOf: [(2, "two"), (3, "three")].map(keyValuePair), at: 1)
    expect(orderedDictionary2.keys).to(equal([-1, 0, 1, 2, 3]))
    expect(orderedDictionary2.values).to(equal(["negative one", "zero", "one", "two", "three"]))
    orderedDictionary2.insert(contentsOf: [(3, "three"), (4, "four")].map(keyValuePair), at: 3)
    expect(orderedDictionary2.keys).to(equal([-1, 0, 1, 4, 2, 3]))
    expect(orderedDictionary2.values) == ["negative one", "zero", "one", "four", "two", "three"]
  }

  func testRemoveRange() {
    var orderedDictionary1: OrderedDictionary<String, Int> = ["one": 1, "two": 2, "three": 3]
    expect(orderedDictionary1.keys).to(equal(["one", "two", "three"]))
    expect(orderedDictionary1.values).to(equal([1, 2, 3]))
    orderedDictionary1.removeSubrange(1 ..< 3)
    expect(orderedDictionary1.keys).to(equal(["one"]))
    expect(orderedDictionary1.values).to(equal([1]))

    var orderedDictionary2: OrderedDictionary<Int, String> = [1: "one", 2: "two", 3: "three"]
    expect(orderedDictionary2.keys).to(equal([1, 2, 3]))
    expect(orderedDictionary2.values).to(equal(["one", "two", "three"]))
    orderedDictionary2.removeSubrange(1 ..< 3)
    expect(orderedDictionary2.keys).to(equal([1]))
    expect(orderedDictionary2.values) == ["one"]
  }

  func testPrefix() {
    let orderedDictionary1: OrderedDictionary<String, Int> = ["one": 1, "two": 2, "three": 3]
    expect(orderedDictionary1.keys).to(equal(["one", "two", "three"]))
    expect(orderedDictionary1.values).to(equal([1, 2, 3]))
    let result1 = orderedDictionary1.prefix(2)
    expect(result1.keys).to(equal(["one", "two"]))
    expect(result1.values).to(equal([1, 2]))

    let orderedDictionary2: OrderedDictionary<Int, String> = [1: "one", 2: "two", 3: "three"]
    expect(orderedDictionary2.keys).to(equal([1, 2, 3]))
    expect(orderedDictionary2.values).to(equal(["one", "two", "three"]))
    let result2 = orderedDictionary2.prefix(2)
    expect(result2.keys).to(equal([1, 2]))
    expect(result2.values) == ["one", "two"]
  }

  func testSuffix() {
    let orderedDictionary1: OrderedDictionary<String, Int> = ["one": 1, "two": 2, "three": 3]
    expect(orderedDictionary1.keys).to(equal(["one", "two", "three"]))
    expect(orderedDictionary1.values).to(equal([1, 2, 3]))
    let result1 = orderedDictionary1.suffix(2)
    expect(result1.keys).to(equal(["two", "three"]))
    expect(result1.values).to(equal([2, 3]))

    let orderedDictionary2: OrderedDictionary<Int, String> = [1: "one", 2: "two", 3: "three"]
    expect(orderedDictionary2.keys).to(equal([1, 2, 3]))
    expect(orderedDictionary2.values).to(equal(["one", "two", "three"]))
    let result2 = orderedDictionary2.suffix(2)
    expect(result2.keys).to(equal([2, 3]))
    expect(result2.values) == ["two", "three"]
  }

  func testKeys() {
    let orderedDictionary1: OrderedDictionary<String, Int> = ["one": 1, "two": 2, "three": 3]
    expect(orderedDictionary1.keys).to(equal(["one", "two", "three"]))

    let orderedDictionary2: OrderedDictionary<Int, String> = [1: "one", 2: "two", 3: "three"]
    expect(orderedDictionary2.keys) == [1, 2, 3]
  }

  func testValues() {
    let orderedDictionary1: OrderedDictionary<String, Int> = ["one": 1, "two": 2, "three": 3]
    expect(orderedDictionary1.values).to(equal([1, 2, 3]))

    let orderedDictionary2: OrderedDictionary<Int, String> = [1: "one", 2: "two", 3: "three"]
    expect(orderedDictionary2.values) == ["one", "two", "three"]
  }

  func testEquatable() {
    let orderedDictionary1: OrderedDictionary<String, Int> = ["one": 1, "two": 2, "three": 3]
    expect(orderedDictionary1 == orderedDictionary1).to(beTrue())
    expect(orderedDictionary1 == (["one": 1, "two": 2, "three": 3] as OrderedDictionary<String, Int>)).to(beTrue())
    expect(orderedDictionary1 == (["one": 3, "two": 2, "three": 3] as OrderedDictionary<String, Int>)).to(beFalse())
    expect(orderedDictionary1 == (["two": 2, "three": 3] as OrderedDictionary<String, Int>)).to(beFalse())
    expect(orderedDictionary1 == (["one": 1, "two": 2, "three": 3, "four": 4] as OrderedDictionary<String, Int>)).to(beFalse())

    let orderedDictionary2: OrderedDictionary<Int, String> = [1: "one", 2: "two", 3: "three"]
    expect(orderedDictionary2 == orderedDictionary2).to(beTrue())
    expect(orderedDictionary2 == ([1: "one", 2: "two", 3: "three"] as OrderedDictionary<Int, String>)).to(beTrue())
    expect(orderedDictionary2 == ([1: "three", 2: "two", 3: "three"] as OrderedDictionary<Int, String>)).to(beFalse())
    expect(orderedDictionary2 == ([2: "two", 3: "three"] as OrderedDictionary<Int, String>)).to(beFalse())
    expect(orderedDictionary2 == ([1: "one", 2: "two", 3: "three", 4: "four"] as OrderedDictionary<Int, String>)).to(beFalse())
  }

  func testContainerAsValue() {
    var orderedDictionary = OrderedDictionary<String, Array<Int>>()
    orderedDictionary["first"] = [1, 2, 3, 4]
    orderedDictionary["second"] = [5, 6, 7, 8]
    orderedDictionary["third"] = [9, 10]
    expect(orderedDictionary).to(haveCount(3))
    expect(orderedDictionary[0].1).to(equal([1, 2, 3, 4]))
    expect(orderedDictionary[1].1).to(equal([5, 6, 7, 8]))
    expect(orderedDictionary[2].1).to(equal([9, 10]))

    var array = orderedDictionary[1].1
    array.append(contentsOf: [11, 12, 13, 14, 15, 16, 17, 18, 19, 20])
    orderedDictionary["second"] = array
    expect(orderedDictionary[1].1) == [5, 6, 7, 8, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20]
  }

}
