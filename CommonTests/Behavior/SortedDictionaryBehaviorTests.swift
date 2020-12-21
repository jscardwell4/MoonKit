//
//  SortedDictionaryBehaviorTests.swift
//  MoonKitTests
//
//  Created by Jason Cardwell on 12/20/20.
//  Copyright © 2020 Moondeer Studios. All rights reserved.
//
import XCTest
import Nimble
@testable import MoonKit

final class SortedDictionaryBehaviorTests: XCTestCase {

  static let loadedDictionary = SortedDictionary(xxSmallStringsIntegers0)

  func testCreation() {
    var sortedDictionary1 = SortedDictionary<String, Int>(minimumCapacity: 8)
    expect(sortedDictionary1.capacity) >= 8
    expect(sortedDictionary1).to(haveCount(0))

    sortedDictionary1 = ["one": 1, "two": 2, "three": 3, "four": 4, "five": 5]

    expect(sortedDictionary1.capacity) >= 5
    expect(sortedDictionary1).to(haveCount(5))

    let pairs1 = [("1", 1), ("2", 2), ("3", 3), ("4", 4), ("5", 5)].map(keyValuePair)
    sortedDictionary1 = SortedDictionary<String, Int>(pairs1)
    expect(sortedDictionary1).to(haveCount(5))

    var sortedDictionary2 = SortedDictionary<Int, String>(minimumCapacity: 8)
    expect(sortedDictionary2.capacity) >= 8
    expect(sortedDictionary2).to(haveCount(0))

    sortedDictionary2 = [1: "one", 2: "two", 3: "three", 4: "four", 5: "five"]
    expect(sortedDictionary2.capacity) >= 5
    expect(sortedDictionary2).to(haveCount(5))

    let pairs2 = [(1, "1"), (2, "2"), (3, "3"), (4, "4"), (5, "5")].map(keyValuePair)
    sortedDictionary2 = SortedDictionary<Int, String>(pairs2)
    expect(sortedDictionary2).to(haveCount(5))
  }

  func testResize() {
    var sortedDictionary1 = SortedDictionary<String, Int>(minimumCapacity: 8)
    sortedDictionary1["one"] = 1
    sortedDictionary1["two"] = 2
    sortedDictionary1["three"] = 3
    sortedDictionary1["four"] = 4
    sortedDictionary1["five"] = 5
    sortedDictionary1["six"] = 6
    expect(sortedDictionary1.values).to(equal([5, 4, 1, 6, 3, 2]))
    sortedDictionary1["seven"] = 7
    expect(sortedDictionary1.values).to(equal([5, 4, 1, 7, 6, 3, 2]))
    sortedDictionary1["eight"] = 8
    sortedDictionary1["nine"] = 9
    sortedDictionary1["ten"] = 10
    expect(sortedDictionary1.values).to(equal([8, 5, 4, 9, 1, 7, 6, 10, 3, 2]))

    var sortedDictionary2 = SortedDictionary<Int, String>(minimumCapacity: 8)
    sortedDictionary2[1] = "one"
    sortedDictionary2[2] = "two"
    sortedDictionary2[3] = "three"
    sortedDictionary2[4] = "four"
    sortedDictionary2[5] = "five"
    sortedDictionary2[6] = "six"
    expect(sortedDictionary2.values).to(equal(["one", "two", "three", "four", "five", "six"]))
    sortedDictionary2[7] = "seven"
    expect(sortedDictionary2.values).to(equal(["one", "two", "three", "four", "five", "six", "seven"]))
    sortedDictionary2[8] = "eight"
    sortedDictionary2[9] = "nine"
    sortedDictionary2[10] = "ten"
    expect(sortedDictionary2.values) == ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten"]

  }

  func testCOW() {
    let sortedDictionary1: SortedDictionary<String, Int> = ["one": 1, "two": 2, "three": 3]
    var sortedDictionary2 = sortedDictionary1
    expect(sortedDictionary1).to(equal(sortedDictionary2))

    sortedDictionary2["four"] = 4
    expect(sortedDictionary1) != sortedDictionary2
  }

  func testInsertValueForKey() {
    var sortedDictionary1 = SortedDictionary<String, Int>(minimumCapacity: 8)

    sortedDictionary1.insert(value: 1, forKey: "one")
    expect(sortedDictionary1).to(haveCount(1))
    expect(sortedDictionary1["one"]).to(equal(1))
    expect(sortedDictionary1.values).to(equal([1]))

    sortedDictionary1.insert(value: 2, forKey: "two")
    expect(sortedDictionary1).to(haveCount(2))
    expect(sortedDictionary1["two"]).to(equal(2))
    expect(sortedDictionary1.values).to(equal([1, 2]))

    sortedDictionary1.insert(value: 3, forKey: "three")
    expect(sortedDictionary1).to(haveCount(3))
    expect(sortedDictionary1["three"]).to(equal(3))
    expect(sortedDictionary1.values).to(equal([1, 3, 2]))

    sortedDictionary1.insert(value: 4, forKey: "four")
    expect(sortedDictionary1).to(haveCount(4))
    expect(sortedDictionary1["four"]).to(equal(4))
    expect(sortedDictionary1.values).to(equal([4, 1, 3, 2]))

    sortedDictionary1.insert(value: 5, forKey: "five")
    expect(sortedDictionary1).to(haveCount(5))
    expect(sortedDictionary1["five"]).to(equal(5))
    expect(sortedDictionary1.values).to(equal([5, 4, 1, 3, 2]))

    var sortedDictionary2 = SortedDictionary<Int, String>(minimumCapacity: 8)

    sortedDictionary2.insert(value: "one", forKey: 1)
    expect(sortedDictionary2).to(haveCount(1))
    expect(sortedDictionary2[1]).to(equal("one"))
    expect(sortedDictionary2.values).to(equal(["one"]))

    sortedDictionary2.insert(value: "two", forKey: 2)
    expect(sortedDictionary2).to(haveCount(2))
    expect(sortedDictionary2[2]).to(equal("two"))
    expect(sortedDictionary2.values).to(equal(["one", "two"]))

    sortedDictionary2.insert(value: "three", forKey: 3)
    expect(sortedDictionary2).to(haveCount(3))
    expect(sortedDictionary2[3]).to(equal("three"))
    expect(sortedDictionary2.values).to(equal(["one", "two", "three"]))

    sortedDictionary2.insert(value: "four", forKey: 4)
    expect(sortedDictionary2).to(haveCount(4))
    expect(sortedDictionary2[4]).to(equal("four"))
    expect(sortedDictionary2.values).to(equal(["one", "two", "three", "four"]))

    sortedDictionary2.insert(value: "five", forKey: 5)
    expect(sortedDictionary2).to(haveCount(5))
    expect(sortedDictionary2[5]).to(equal("five"))
    expect(sortedDictionary2.values) == ["one", "two", "three", "four", "five"]

    var sortedDictionary3 = SortedDictionary<String, Int>()
    for (key, value) in xxSmallStringsIntegers0 {
      sortedDictionary3.updateValue(value, forKey: key)
    }
  }

  func testRemoveAll() {
    var sortedDictionary1: SortedDictionary<String, Int> = ["one": 1, "two": 2, "three": 3]
    expect(sortedDictionary1).toNot(beEmpty())
    sortedDictionary1.removeAll()
    expect(sortedDictionary1).to(beEmpty())

    var sortedDictionary2: SortedDictionary<Int, String> = [1: "one", 2: "two", 3: "three"]
    expect(sortedDictionary2).toNot(beEmpty())
    sortedDictionary2.removeAll()
    expect(sortedDictionary2).to(beEmpty())
  }

  func testRemoveValueForKey() {
    var sortedDictionary1: SortedDictionary<String, Int> = ["one": 1, "two": 2, "three": 3]
    expect(sortedDictionary1.values).to(equal([1, 3, 2]))
    expect(sortedDictionary1.removeValue(forKey: "two")) == 2
    expect(sortedDictionary1.values).to(equal([1, 3]))
    expect(sortedDictionary1.removeValue(forKey: "two")).to(beNil())
    expect(sortedDictionary1.removeValue(forKey: "one")) == 1
    expect(sortedDictionary1.values).to(equal([3]))
    sortedDictionary1["two"] = 2
    sortedDictionary1["one"] = 1
    expect(sortedDictionary1.values).to(equal([1, 3, 2]))

    var sortedDictionary2: SortedDictionary<Int, String> = [1: "one", 2: "two", 3: "three"]
    expect(sortedDictionary2.values).to(equal(["one", "two", "three"]))
    expect(sortedDictionary2.removeValue(forKey: 2)) == "two"
    expect(sortedDictionary2.values).to(equal(["one", "three"]))
    expect(sortedDictionary2.removeValue(forKey: 2)).to(beNil())
    expect(sortedDictionary2.removeValue(forKey: 1)) == "one"
    expect(sortedDictionary2.values).to(equal(["three"]))
    sortedDictionary2[2] = "two"
    sortedDictionary2[1] = "one"
    expect(sortedDictionary2.values) == ["one", "two", "three"]

    var sortedDictionary3 = SortedDictionaryBehaviorTests.loadedDictionary
    for (key, _) in xxSmallStringsIntegers0 {
      sortedDictionary3.removeValue(forKey: key)
    }

  }

  func testSubscriptKeyAccessors() {
    var sortedDictionary: SortedDictionary<String, Int> = ["one": 1, "two": 2, "three": 3]
    expect(sortedDictionary["two"]).to(equal(2))
    sortedDictionary["four"] = 4
    expect(sortedDictionary["four"]).to(equal(4))
    expect(sortedDictionary.keys).to(equal(["four", "one", "three", "two"]))
    expect(sortedDictionary.values) == [4, 1, 3, 2]
  }

  // func testSubscriptIndexAccessors() {
  //   var sortedDictionary: SortedDictionary<String, Int> = ["one": 1, "two": 2, "three": 3]
  //   expect(sortedDictionary[1]).to(equal(("three", 3)))
  //   sortedDictionary[2] = ("four", 4)
  //   expect(sortedDictionary[0]).to(equal(("four", 4)))
  //   expect(sortedDictionary.keys).to(equal(["one", "two", "four"]))
  //   expect(sortedDictionary.values) == [1, 2, 4]
  // }

  func testSubscriptRangeAccessors() {
    let sortedDictionary1: SortedDictionary<String, Int> = ["one": 1, "two": 2, "three": 3]
    let slice1 = sortedDictionary1[1 ... 2]
    expect(slice1.keys).to(equal(["three", "two"]))
    expect(slice1.values).to(equal([3, 2]))
//    slice1["four"] = 4
//    let slice1Keys = Array(slice1.keys)
//    let slice1Values = Array(slice1.values)
//    expect(slice1Keys).to(equal(["two", "three", "four"]))
//    expect(slice1Values).to(equal([2, 3, 4]))
//    expect(sortedDictionary1.keys).to(equal(["one", "two", "three"]))
//    expect(sortedDictionary1.values).to(equal([1, 2, 3]))
//    sortedDictionary1[1 ... 2] = slice1
//    expect(sortedDictionary1.keys).to(equal(["one", "two", "three", "four"]))
//    expect(sortedDictionary1.values).to(equal([1, 2, 3, 4]))

    let sortedDictionary2: SortedDictionary<Int, String> = [1: "one", 2: "two", 3: "three"]
    let slice2 = sortedDictionary2[1 ... 2]
    expect(slice2.keys).to(equal([2, 3]))
    expect(slice2.values).to(equal(["two", "three"]))
//    slice2[4] = "four"
//    expect(slice2.keys).to(equal([2, 3, 4]))
//    expect(slice2.values).to(equal(["two", "three", "four"]))
//    expect(sortedDictionary2.keys).to(equal([1, 2, 3]))
//    expect(sortedDictionary2.values).to(equal(["one", "two", "three"]))
//    sortedDictionary2[1 ... 2] = slice2
//    expect(sortedDictionary2.keys).to(equal([1, 2, 3, 4]))
//    expect(sortedDictionary2.values) == ["one", "two", "three", "four"]
  }

  func testRemoveAtIndex() {
    var sortedDictionary1: SortedDictionary<String, Int> = ["one": 1, "two": 2, "three": 3]
    expect(sortedDictionary1.remove(at: 0)) == ("one", 1)
    expect(sortedDictionary1.remove(at: 1)) == ("two", 2)
    expect(sortedDictionary1.remove(at: 0)) == ("three", 3)

    var sortedDictionary2: SortedDictionary<Int, String> = [1: "one", 2: "two", 3: "three"]
    expect(sortedDictionary2.remove(at: 0)) == (1, "one")
    expect(sortedDictionary2.remove(at: 1)) == (3, "three")
    expect(sortedDictionary2.remove(at: 0)) == (2, "two")
  }

  func testIndexForKey() {
    let sortedDictionary1: SortedDictionary<String, Int> = ["one": 1, "two": 2, "three": 3]
    expect(sortedDictionary1.index(forKey: "one")) == 0
    expect(sortedDictionary1.index(forKey: "two")) == 2
    expect(sortedDictionary1.index(forKey: "three")) == 1
    expect(sortedDictionary1.index(forKey: "four")).to(beNil())

    let sortedDictionary2: SortedDictionary<Int, String> = [1: "one", 2: "two", 3: "three"]
    expect(sortedDictionary2.index(forKey: 1)) == 0
    expect(sortedDictionary2.index(forKey: 2)) == 1
    expect(sortedDictionary2.index(forKey: 3)) == 2
    expect(sortedDictionary2.index(forKey: 4)).to(beNil())
  }

  func testUpdateValueForKey() {
    var sortedDictionary1: SortedDictionary<String, Int> = ["one": 1, "two": 2, "three": 3]
    expect(sortedDictionary1.updateValue(4, forKey: "two")) == 2
    expect(sortedDictionary1.value(forKey: "two")) == 4

    var sortedDictionary2: SortedDictionary<Int, String> = [1: "one", 2: "two", 3: "three"]
    expect(sortedDictionary2.updateValue("four", forKey: 2)) == "two"
    expect(sortedDictionary2.value(forKey: 2)) == "four"

    var sortedDictionary3 = SortedDictionaryBehaviorTests.loadedDictionary
    for (key, value) in xxSmallStringsIntegers1 {
      sortedDictionary3.updateValue(value, forKey: key)
    }
  }

  func testReplaceRange() {
    var sortedDictionary: SortedDictionary<String, Int> = ["one": 1, "two": 2, "three": 3, "four": 4, "five": 5,
                                                             "six": 6, "seven": 7, "eight": 8, "nine": 9, "ten": 10]
    expect(sortedDictionary).to(equal(["eight": 8, "five": 5, "four": 4, "nine": 9, "one": 1,
                                             "seven": 7, "six": 6, "ten": 10, "three": 3, "two": 2] as SortedDictionary<String, Int>))
    sortedDictionary.replaceSubrange(0 ..< 5, with: [("five", 5), ("four", 4), ("three", 3), ("two", 2), ("one", 1)].map(keyValuePair))
    expect(sortedDictionary).to(equal(["five": 5, "four": 4, "one": 1, "seven": 7, "six": 6,
                                             "ten": 10, "three": 3, "two": 2] as SortedDictionary<String, Int>))
    sortedDictionary.replaceSubrange(5 ..< 8, with: [(key: "zero", value: 0)])
    expect(sortedDictionary) == (["five": 5, "four": 4, "one": 1, "seven": 7, "six": 6, "zero": 0] as SortedDictionary<String, Int>)
  }

  func testAppend() {
    var sortedDictionary1: SortedDictionary<String, Int> = ["one": 1, "two": 2, "three": 3]
    expect(sortedDictionary1.keys).to(equal(["one", "three", "two"]))
    expect(sortedDictionary1.values).to(equal([1, 3, 2]))
    sortedDictionary1.append((key: "four", value: 4))
    expect(sortedDictionary1.keys).to(equal(["four", "one", "three", "two"]))
    expect(sortedDictionary1.values).to(equal([4, 1, 3, 2]))

    var sortedDictionary2: SortedDictionary<Int, String> = [1: "one", 2: "two", 3: "three"]
    expect(sortedDictionary2.values).to(equal(["one", "two", "three"]))
    expect(sortedDictionary2.keys).to(equal([1, 2, 3]))
    sortedDictionary2.append((key: 4, value: "four"))
    expect(sortedDictionary2.keys).to(equal([1, 2, 3, 4]))
    expect(sortedDictionary2.values) == ["one", "two", "three", "four"]
  }

  func testAppendContentsOf() {
    var sortedDictionary1: SortedDictionary<String, Int> = ["one": 1, "two": 2, "three": 3]
    expect(sortedDictionary1.keys).to(equal(["one", "three", "two"]))
    expect(sortedDictionary1.values).to(equal([1, 3, 2]))
    sortedDictionary1.append(contentsOf: [("four", 4), ("five", 5)].map(keyValuePair))
    expect(sortedDictionary1.keys).to(equal(["five", "four", "one", "three", "two"]))
    expect(sortedDictionary1.values).to(equal([5, 4, 1, 3, 2]))
    sortedDictionary1.append(contentsOf: [(key: "four", value: 4)])
    expect(sortedDictionary1.keys).to(equal(["five", "four", "one", "three", "two"]))
    expect(sortedDictionary1.values).to(equal([5, 4, 1, 3, 2]))

    var sortedDictionary2: SortedDictionary<Int, String> = [1: "one", 2: "two", 3: "three"]
    expect(sortedDictionary2.values).to(equal(["one", "two", "three"]))
    expect(sortedDictionary2.keys).to(equal([1, 2, 3]))
    sortedDictionary2.append(contentsOf: [(4, "four"), (5, "five")].map(keyValuePair))
    expect(sortedDictionary2.keys).to(equal([1, 2, 3, 4, 5]))
    expect(sortedDictionary2.values).to(equal(["one", "two", "three", "four", "five"]))
    sortedDictionary2.append(contentsOf: [(key: 4, value: "four")])
    expect(sortedDictionary2.keys).to(equal([1, 2, 3, 4, 5]))
    expect(sortedDictionary2.values) == ["one", "two", "three", "four", "five"]
  }

  func testRemoveRange() {
    var sortedDictionary1: SortedDictionary<String, Int> = ["one": 1, "two": 2, "three": 3]
    expect(sortedDictionary1.keys).to(equal(["one", "three", "two"]))
    expect(sortedDictionary1.values).to(equal([1, 3, 2]))
    sortedDictionary1.removeSubrange(1 ..< 3)
    expect(sortedDictionary1.keys).to(equal(["one"]))
    expect(sortedDictionary1.values).to(equal([1]))

    var sortedDictionary2: SortedDictionary<Int, String> = [1: "one", 2: "two", 3: "three"]
    expect(sortedDictionary2.keys).to(equal([1, 2, 3]))
    expect(sortedDictionary2.values).to(equal(["one", "two", "three"]))
    sortedDictionary2.removeSubrange(1 ..< 3)
    expect(sortedDictionary2.keys).to(equal([1]))
    expect(sortedDictionary2.values) == ["one"]
  }

  func testPrefix() {
    let sortedDictionary1: SortedDictionary<String, Int> = ["one": 1, "two": 2, "three": 3]
    expect(sortedDictionary1.keys).to(equal(["one", "three", "two"]))
    expect(sortedDictionary1.values).to(equal([1, 3, 2]))
    let result1 = sortedDictionary1.prefix(2)
    expect(result1.keys).to(equal(["one", "three"]))
    expect(result1.values).to(equal([1, 3]))

    let sortedDictionary2: SortedDictionary<Int, String> = [1: "one", 2: "two", 3: "three"]
    expect(sortedDictionary2.keys).to(equal([1, 2, 3]))
    expect(sortedDictionary2.values).to(equal(["one", "two", "three"]))
    let result2 = sortedDictionary2.prefix(2)
    expect(result2.keys).to(equal([1, 2]))
    expect(result2.values) == ["one", "two"]
  }

  func testSuffix() {
    let sortedDictionary1: SortedDictionary<String, Int> = ["one": 1, "two": 2, "three": 3]
    expect(sortedDictionary1.keys).to(equal(["one", "three", "two"]))
    expect(sortedDictionary1.values).to(equal([1, 3, 2]))
    let result1 = sortedDictionary1.suffix(2)
    expect(result1.keys).to(equal(["three", "two"]))
    expect(result1.values).to(equal([3, 2]))

    let sortedDictionary2: SortedDictionary<Int, String> = [1: "one", 2: "two", 3: "three"]
    expect(sortedDictionary2.keys).to(equal([1, 2, 3]))
    expect(sortedDictionary2.values).to(equal(["one", "two", "three"]))
    let result2 = sortedDictionary2.suffix(2)
    expect(result2.keys).to(equal([2, 3]))
    expect(result2.values) == ["two", "three"]
  }

  func testKeys() {
    let sortedDictionary1: SortedDictionary<String, Int> = ["one": 1, "two": 2, "three": 3]
    expect(sortedDictionary1.keys).to(equal(["one", "three", "two"]))

    let sortedDictionary2: SortedDictionary<Int, String> = [1: "one", 2: "two", 3: "three"]
    expect(sortedDictionary2.keys) == [1, 2, 3]
  }

  func testValues() {
    let sortedDictionary1: SortedDictionary<String, Int> = ["one": 1, "two": 2, "three": 3]
    expect(sortedDictionary1.values).to(equal([1, 3, 2]))

    let sortedDictionary2: SortedDictionary<Int, String> = [1: "one", 2: "two", 3: "three"]
    expect(sortedDictionary2.values) == ["one", "two", "three"]
  }

  func testEquatable() {
    let sortedDictionary1: SortedDictionary<String, Int> = ["one": 1, "two": 2, "three": 3]
    expect(sortedDictionary1 == sortedDictionary1).to(beTrue())
    expect(sortedDictionary1 == (["one": 1, "two": 2, "three": 3] as SortedDictionary<String, Int>)).to(beTrue())
    expect(sortedDictionary1 == (["one": 3, "two": 2, "three": 3] as SortedDictionary<String, Int>)).to(beFalse())
    expect(sortedDictionary1 == (["two": 2, "three": 3] as SortedDictionary<String, Int>)).to(beFalse())
    expect(sortedDictionary1 == (["one": 1, "two": 2, "three": 3, "four": 4] as SortedDictionary<String, Int>)).to(beFalse())

    let sortedDictionary2: SortedDictionary<Int, String> = [1: "one", 2: "two", 3: "three"]
    expect(sortedDictionary2 == sortedDictionary2).to(beTrue())
    expect(sortedDictionary2 == ([1: "one", 2: "two", 3: "three"] as SortedDictionary<Int, String>)).to(beTrue())
    expect(sortedDictionary2 == ([1: "three", 2: "two", 3: "three"] as SortedDictionary<Int, String>)).to(beFalse())
    expect(sortedDictionary2 == ([2: "two", 3: "three"] as SortedDictionary<Int, String>)).to(beFalse())
    expect(sortedDictionary2 == ([1: "one", 2: "two", 3: "three", 4: "four"] as SortedDictionary<Int, String>)).to(beFalse())
  }

  func testContainerAsValue() {
    var sortedDictionary = SortedDictionary<String, Array<Int>>()
    sortedDictionary["first"] = [1, 2, 3, 4]
    sortedDictionary["second"] = [5, 6, 7, 8]
    sortedDictionary["third"] = [9, 10]
    expect(sortedDictionary).to(haveCount(3))
    expect(sortedDictionary[0].1).to(equal([1, 2, 3, 4]))
    expect(sortedDictionary[1].1).to(equal([5, 6, 7, 8]))
    expect(sortedDictionary[2].1).to(equal([9, 10]))

    var array = sortedDictionary[1].1
    array.append(contentsOf: [11, 12, 13, 14, 15, 16, 17, 18, 19, 20])
    sortedDictionary["second"] = array
    expect(sortedDictionary[1].1) == [5, 6, 7, 8, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20]
  }

}
