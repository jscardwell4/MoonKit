//
//  SortedArrayBehaviorTests.swift
//  SortedArrayTests
//
//  Created by Jason Cardwell on 7/19/16.
//  Copyright © 2016 Jason Cardwell. All rights reserved.
//
import XCTest
import Nimble
@testable import MoonKit

final class SortedArrayBehaviorTests: XCTestCase {
    
  func testCreation() {
    let sortedArray1 = SortedArray([1, 2, 3, 4])
    expect(sortedArray1).to(haveCount(4))
    expect(sortedArray1) == [1, 2, 3, 4]

    let sortedArray2 = SortedArray([2, 3, 1, 4])
    expect(sortedArray2).to(haveCount(4))
    expect(sortedArray2) == [1, 2, 3, 4]

    let sortedArray3 = SortedArray([4, 3, 2, 1])
    expect(sortedArray3).to(haveCount(4))
    expect(sortedArray3) == [1, 2, 3, 4]

    let sortedArray4 = SortedArray([3, 2, 1, 4])
    expect(sortedArray4).to(haveCount(4))
    expect(sortedArray4) == [1, 2, 3, 4]

    let sortedArray5 = SortedArray(AnySequence([1, 2, 3, 4]))
    expect(sortedArray5).to(haveCount(4))
    expect(sortedArray5) == [1, 2, 3, 4]
    
  }

  func testInsertion() {
    var sortedArray = SortedArray<String>()
    expect(sortedArray).to(haveCount(0))
    sortedArray.insert("1", at: 0)
    expect(sortedArray).to(haveCount(1))
    expect(sortedArray[0]) == "1"
    sortedArray.insert("2", at: 0)
    expect(sortedArray).to(haveCount(2))
    expect(sortedArray[0]) == "1"
    expect(sortedArray[1]) == "2"
    sortedArray.insert("3", at: 1)
    expect(sortedArray).to(haveCount(3))
    expect(sortedArray[0]) == "1"
    expect(sortedArray[1]) == "2"
    expect(sortedArray[2]) == "3"
    sortedArray.insert("4", at: 0)
    expect(sortedArray).to(haveCount(4))
    expect(sortedArray[0]) == "1"
    expect(sortedArray[1]) == "2"
    expect(sortedArray[2]) == "3"
    expect(sortedArray[3]) == "4"
    sortedArray.insert(contentsOf: ["4", "5", "6"], at: 3)
    expect(sortedArray).to(haveCount(7))
    expect(sortedArray[0]) == "1"
    expect(sortedArray[1]) == "2"
    expect(sortedArray[2]) == "3"
    expect(sortedArray[3]) == "4"
    expect(sortedArray[4]) == "4"
    expect(sortedArray[5]) == "5"
    expect(sortedArray[6]) == "6"
  }

  func testResize() {
    var sortedArray = SortedArray<String>(minimumCapacity: 4)
    expect(sortedArray.capacity) == 4
    sortedArray.append(contentsOf: ["1", "2", "3"])
    expect(sortedArray.capacity) == 4
    sortedArray.append("4")
    expect(sortedArray.capacity) == 4
    sortedArray.append("5")
    expect(sortedArray.capacity) == 8
    sortedArray.reserveCapacity(20)
    expect(sortedArray.capacity) == 20
  }

  func testAppend() {
    var sortedArray = SortedArray<String>()
    expect(sortedArray).to(haveCount(0))
    sortedArray.append("4")
    expect(sortedArray).to(haveCount(1))
    expect(sortedArray) == ["4"]
    sortedArray.append("2")
    expect(sortedArray).to(haveCount(2))
    expect(sortedArray) == ["2", "4"]
    sortedArray.append("3")
    expect(sortedArray).to(haveCount(3))
    expect(sortedArray) == ["2", "3", "4"]
    sortedArray.append("1")
    expect(sortedArray).to(haveCount(4))
    expect(sortedArray) == ["1", "2", "3", "4"]
    sortedArray.append(contentsOf: ["4", "5", "6"])
    expect(sortedArray).to(haveCount(7))
    expect(sortedArray) == ["1", "2", "3", "4", "4", "5", "6"]
    sortedArray.append(contentsOf: [])
    expect(sortedArray).to(haveCount(7))
    expect(sortedArray) == ["1", "2", "3", "4", "4", "5", "6"]
  }

  func testRemove() {
    var sortedArray1: SortedArray<String> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
    expect(sortedArray1) == ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
    sortedArray1.remove(at: 5)
    expect(sortedArray1) == ["0", "1", "2", "3", "4", "6", "7", "8", "9"]
    sortedArray1.removeLast()
    expect(sortedArray1) == ["0", "1", "2", "3", "4", "6", "7", "8"]
    sortedArray1.removeFirst()
    expect(sortedArray1) == ["1", "2", "3", "4", "6", "7", "8"]
    sortedArray1.removeFirst(2)
    expect(sortedArray1) == ["3", "4", "6", "7", "8"]
    sortedArray1.removeLast(2)
    expect(sortedArray1) == ["3", "4", "6"]
    sortedArray1.removeAll(keepingCapacity: true)
    expect(sortedArray1.capacity) == 10
    sortedArray1.append(contentsOf: ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"])
    expect(sortedArray1.capacity) == 10
    sortedArray1.removeSubrange(0..<0)
    expect(sortedArray1).to(haveCount(10))
    expect(sortedArray1) == ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
    sortedArray1.removeSubrange(3..<4)
    expect(sortedArray1).to(haveCount(9))
    expect(sortedArray1) == ["0", "1", "2", "4", "5", "6", "7", "8", "9"]
    sortedArray1.removeSubrange(4...6)
    expect(sortedArray1).to(haveCount(6))
    expect(sortedArray1) == ["0", "1", "2", "4", "8", "9"]
    sortedArray1.removeSubrange(2...3)
    expect(sortedArray1).to(haveCount(4))
    expect(sortedArray1) == ["0", "1", "8", "9"]
    var sortedArray2 = sortedArray1
    sortedArray2.removeAll(keepingCapacity: true)
    expect(sortedArray2.capacity) == 10
    expect(sortedArray2).to(haveCount(0))
    sortedArray2.removeAll(keepingCapacity: true)
    expect(sortedArray2.capacity) == 10
    expect(sortedArray2).to(haveCount(0))
    sortedArray1.removeAll(keepingCapacity: false)
    expect(sortedArray1).to(haveCount(0))
    expect(sortedArray1.capacity) == 0
  }

  func testEquatable() {
    let sortedArray1 = SortedArray(["1", "3", "2", "4"])
    var sortedArray2 = sortedArray1
    expect(sortedArray1 == sortedArray2) == true

    let sortedArray3 = SortedArray(["2", "3", "1", "4"])
    expect(sortedArray1 == sortedArray3) == true
    expect(sortedArray2 == sortedArray3) == true

    sortedArray2.append("five")
    expect(sortedArray1 == sortedArray2) == false
    expect(sortedArray2 == sortedArray3) == false
    expect(sortedArray1 == sortedArray3) == true
  }

  func testReplaceRange() {
    var sortedArray: SortedArray<String> = ["1", "2", "3"]
    sortedArray.replaceSubrange(1 ..< 3, with: ["4", "5"])
    expect(sortedArray).to(haveCount(3))
    expect(sortedArray) == ["1", "4", "5"]

    sortedArray.replaceSubrange(0 ... 0, with: ["1", "2", "3"])
    expect(sortedArray).to(haveCount(5))
    expect(sortedArray) == ["1", "2", "3", "4", "5"]

    sortedArray.replaceSubrange(3...3, with: EmptyCollection())
    expect(sortedArray).to(haveCount(4))
    expect(sortedArray) == ["1", "2", "3", "5"]

    sortedArray.replaceSubrange(3 ..< 3, with: ["4"])
    expect(sortedArray).to(haveCount(5))
    expect(sortedArray) == ["1", "2", "3", "4", "5"]

    sortedArray.replaceSubrange(5..<5, with: ["8", "4", "9", "2"])
    expect(sortedArray).to(haveCount(9))
    expect(sortedArray) == ["1", "2", "2", "3", "4", "4", "5", "8", "9"]

  }

  func testCOW() {
    var sortedArray1: SortedArray<String> = ["1", "2", "3"]
    let sortedArray2 = sortedArray1
    sortedArray1.remove(at: 0)
    expect(sortedArray1).to(haveCount(2))
    expect(sortedArray2).to(haveCount(3))
  }

  func testIterator() {
    let array: [String] = ["1", "2", "3", "4"]
    let sortedArray = SortedArray<String>(array)
    for (sortedElement, sourceElemnt) in zip(sortedArray, array) { expect(sortedElement) == sourceElemnt }
  }

  func testSubscriptIndexAccessors() {
    let array: [String] = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
    var sortedArray = SortedArray<String>(array)
    expect(sortedArray[4]) == "4"
    sortedArray[4] = "0"
    expect(sortedArray[4]) == "3"
  }

  func testSubscriptRangeAccessors() {
    var sortedArray1 = SortedArray<String>(["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"])
    let slice1 = sortedArray1[4..<8]
    expect(slice1).to(haveCount(4))
    expect(slice1) == ["4", "5", "6", "7"]
    expect(slice1[5]) == "5"
    let slice2 = slice1[6..<8]
    expect(slice2).to(haveCount(2))
    expect(slice2) == ["6", "7"]
    sortedArray1.replaceSubrange(4..<10, with: ["9"])
    expect(sortedArray1).to(haveCount(5))
    expect(sortedArray1) == ["0", "1", "2", "3", "9"]
    expect(slice1) == ["4", "5", "6", "7"]
    expect(slice2) == ["6", "7"]
    expect(slice1 == slice2) == false
    let slice3 = slice1[slice1.indices]
    expect(slice1 == slice3) == true
    let sortedArray2 = SortedArray(["4", "5", "6", "7"])
    let slice4 = sortedArray2[sortedArray2.indices]
    expect(slice1 == slice4) == true
    sortedArray1[0..<1] = slice4
    expect(sortedArray1).to(haveCount(8))
    expect(sortedArray1) == ["1", "2", "3", "4", "5", "6", "7", "9"]
  }

  func testPrefix() {
    let array: [String] = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
    let sortedArray = SortedArray<String>(array)
    expect(sortedArray.prefix(4).compactMap({$0})).to(equal(array.prefix(4)))
  }

  func testSuffix() {
    let array: [String] = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
    let sortedArray = SortedArray<String>(array)
    expect(sortedArray.suffix(4).compactMap({$0})).to(equal(array.suffix(4)))
  }

  func testDescription() {
    expect(SortedArray<Int>([3, 2, 5, 4, 1]).description) == "[1, 2, 3, 4, 5]"
    expect(SortedArray<Int>([3, 2, 5, 4, 1]).debugDescription) == "[1, 2, 3, 4, 5]"
    expect(SortedArray<Int>([3, 2, 5, 4, 1])[0..<5].description) == "[1, 2, 3, 4, 5]"
    expect(SortedArray<Int>([3, 2, 5, 4, 1])[0..<5].debugDescription) == "[1, 2, 3, 4, 5]"
  }

}
