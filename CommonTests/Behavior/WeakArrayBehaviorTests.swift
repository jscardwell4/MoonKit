//
//  WeakArrayBehaviorTests.swift
//  WeakArrayTests
//
//  Created by Jason Cardwell on 3/3/16.
//  Copyright © 2016 Jason Cardwell. All rights reserved.
//

import XCTest
import MoonKitTest
import MoonKit


final class WeakArrayBehaviorTests: XCTestCase {

  func testCreation() {
    let string1: NSString = "1", string2: NSString = "2", string3: NSString = "3"
    let weakArray: WeakArray<NSString> = [string1, string2, string3]
    expect(weakArray).to(haveCount(3))
    expect(weakArray[0]).toNot(beNil())
    expect(weakArray[0]).to(beIdenticalTo(string1))
    expect(weakArray[1]).to(beIdenticalTo(string2))
    expect(weakArray[2]).to(beIdenticalTo(string3))
  }

  func testInsertion() {
    var weakArray = WeakArray<NSString>()
    expect(weakArray).to(haveCount(0))
    let string1: NSString = "1", string2: NSString = "2", string3: NSString = "3"
    weakArray.insert(string1, at: 0)
    expect(weakArray).to(haveCount(1))
    expect(weakArray[0]).to(beIdenticalTo(string1))
    weakArray.insert(string2, at: 0)
    expect(weakArray).to(haveCount(2))
    expect(weakArray[0]).to(beIdenticalTo(string2))
    expect(weakArray[1]).to(beIdenticalTo(string1))
    weakArray.insert(Optional(string3), at: 1)
    expect(weakArray).to(haveCount(3))
    expect(weakArray[0]).to(beIdenticalTo(string2))
    expect(weakArray[1]).to(beIdenticalTo(string3))
    expect(weakArray[2]).to(beIdenticalTo(string1))
    weakArray.insert("Unretained", at: 0)
    expect(weakArray).to(haveCount(4))
    expect(weakArray[0]).to(beNil())
    expect(weakArray[1]).to(beIdenticalTo(string2))
    expect(weakArray[2]).to(beIdenticalTo(string3))
    expect(weakArray[3]).to(beIdenticalTo(string1))
    let string4: NSString = "4", string5: NSString = "5", string6: NSString = "6"
    weakArray.insert(contentsOf: Array<NSString?>(), at: 3)
    expect(weakArray).to(haveCount(4))
    weakArray.insert(contentsOf: [string4, string5, string6] as [NSString?], at: 3)
    expect(weakArray).to(haveCount(7))
    expect(weakArray[0]).to(beNil())
    expect(weakArray[1]).to(beIdenticalTo(string2))
    expect(weakArray[2]).to(beIdenticalTo(string3))
    expect(weakArray[3]).to(beIdenticalTo(string4))
    expect(weakArray[4]).to(beIdenticalTo(string5))
    expect(weakArray[5]).to(beIdenticalTo(string6))
    expect(weakArray[6]).to(beIdenticalTo(string1))
  }

  func testResize() {
    var weakArray = WeakArray<NSString>(minimumCapacity: 4)
    let string1: NSString = "1", string2: NSString = "2", string3: NSString = "3", string4: NSString = "4"
    expect(weakArray.capacity) == 4
    weakArray.append(contentsOf: [string1, string2, string3] as [NSString?])
    expect(weakArray.capacity) == 4
    weakArray.append(string4)
    expect(weakArray.capacity) == 4
    let string5: NSString = "5"
    weakArray.append(string5)
    expect(weakArray.capacity) == 8
    weakArray.reserveCapacity(20)
    expect(weakArray.capacity) == 20
  }

  func testAppend() {
    var weakArray = WeakArray<NSString>()
    expect(weakArray).to(haveCount(0))
    let string1: NSString = "1", string2: NSString = "2", string3: NSString = "3"
    weakArray.append(string1)
    expect(weakArray).to(haveCount(1))
    weakArray.append(Optional(string2))
    expect(weakArray).to(haveCount(2))
    weakArray.append(string3)
    expect(weakArray).to(haveCount(3))
    weakArray.append("Unretained")
    expect(weakArray).to(haveCount(4))
    expect(weakArray[0]).to(beIdenticalTo(string1))
    expect(weakArray[1]).to(beIdenticalTo(string2))
    expect(weakArray[2]).to(beIdenticalTo(string3))
    expect(weakArray[3]).to(beNil())
    let string4: NSString = "4", string5: NSString = "5", string6: NSString = "6"
    weakArray.append(contentsOf: Array<NSString?>())
    expect(weakArray).to(haveCount(4))
    weakArray.append(contentsOf: [string4, string5, string6] as [NSString?])
    expect(weakArray).to(haveCount(7))
    expect(weakArray[0]).to(beIdenticalTo(string1))
    expect(weakArray[1]).to(beIdenticalTo(string2))
    expect(weakArray[2]).to(beIdenticalTo(string3))
    expect(weakArray[3]).to(beNil())
    expect(weakArray[4]).to(beIdenticalTo(string4))
    expect(weakArray[5]).to(beIdenticalTo(string5))
    expect(weakArray[6]).to(beIdenticalTo(string6))
  }

  func testRemove() {
    let array: [NSString] = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
    var weakArray1 = WeakArray<NSString>(array)
    expect(weakArray1.flatMap({$0})) == ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
    weakArray1.remove(at: 5)
    expect(weakArray1.flatMap({$0})) == ["1", "2", "3", "4", "5", "7", "8", "9", "10"]
    weakArray1.removeLast()
    expect(weakArray1.flatMap({$0})) == ["1", "2", "3", "4", "5", "7", "8", "9"]
    weakArray1.removeFirst()
    expect(weakArray1.flatMap({$0})) == ["2", "3", "4", "5", "7", "8", "9"]
    weakArray1.removeFirst(2)
    expect(weakArray1.flatMap({$0})) == ["4", "5", "7", "8", "9"]
    weakArray1.removeLast(2)
    expect(weakArray1.flatMap({$0})) == ["4", "5", "7"]
    var weakArray2 = weakArray1
    weakArray1.removeAll(keepingCapacity: true)
    expect(weakArray1).to(haveCount(0))
    expect(weakArray1.capacity) == 10
    expect(weakArray2).to(haveCount(3))
    expect(weakArray2.capacity) == 10
    weakArray2.removeSubrange(Range(0..<0))
    expect(weakArray2).to(haveCount(3))
    expect(weakArray2.capacity) == 10
    weakArray2.removeAll(keepingCapacity: true)
    expect(weakArray2).to(haveCount(0))
    expect(weakArray2.capacity) == 10
    weakArray1.removeAll(keepingCapacity: false)
    expect(weakArray1).to(haveCount(0))
    expect(weakArray1.capacity) == 0
    weakArray2.removeAll(keepingCapacity: true)
    expect(weakArray2).to(haveCount(0))
    expect(weakArray2.capacity) == 10
    weakArray2.removeAll(keepingCapacity: false)
    expect(weakArray2).to(haveCount(0))
    expect(weakArray2.capacity) == 0
  }

  func testReplaceRange() {
    let string1: NSString = "1", string2: NSString = "2", string3: NSString = "3"
    var weakArray: WeakArray<NSString> = [string1, string2, string3]
    let string4: NSString = "4", string5: NSString = "5"
    weakArray.replaceSubrange(1 ..< 3, with: [Optional(string4), Optional(string5)])
    expect(weakArray).to(haveCount(3))
    expect(weakArray[0]).to(beIdenticalTo(string1))
    expect(weakArray[1]).to(beIdenticalTo(string4))
    expect(weakArray[2]).to(beIdenticalTo(string5))
    weakArray.replaceSubrange(CountableRange(0..<0), with: Array<NSString?>())
    expect(weakArray).to(haveCount(3))
    weakArray.replaceSubrange(Range(0 ..< 1), with: [Optional(string1), Optional(string2), Optional(string3)])
    expect(weakArray).to(haveCount(5))
    expect(weakArray[0]).to(beIdenticalTo(string1))
    expect(weakArray[1]).to(beIdenticalTo(string2))
    expect(weakArray[2]).to(beIdenticalTo(string3))
    expect(weakArray[3]).to(beIdenticalTo(string4))
    expect(weakArray[4]).to(beIdenticalTo(string5))

  }

  func testCOW() {
    let string1: NSString = "1", string2: NSString = "2", string3: NSString = "3"
    var weakArray1: WeakArray<NSString> = [string1, string2, string3]
    let weakArray2 = weakArray1
    weakArray1.remove(at: 0)
    expect(weakArray1).to(haveCount(2))
    expect(weakArray2).to(haveCount(3))
  }

  func testIterator() {
    let array: [NSString?] = ["1", "2", "3", "4"]
    let weakArray = WeakArray<NSString>(array)
    for (weakElement, sourceElemnt) in zip(weakArray, array) { expect(weakElement).to(beIdenticalTo(sourceElemnt)) }
  }

  func testSubscriptIndexAccessors() {
    let array: [NSString] = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
    var weakArray = WeakArray<NSString>(array)
    expect(weakArray[4]) == "5"
    expect(weakArray[4]).to(beIdenticalTo(array[4]))
    let string0: NSString = "0"
    weakArray[4] = string0
    expect(weakArray[4]) == "0"
    expect(weakArray[4]).to(beIdenticalTo(string0))
  }

  func testSubscriptRangeAccessors() {
    let array: [NSString] = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
    var weakArray = WeakArray<NSString>(array)
    let slice1 = weakArray[Range(0..<4)]
    expect(slice1).to(haveCount(4))
    expect(slice1.flatMap({$0})) == array[0..<4]
    expect(slice1[slice1.startIndex]) == array[slice1.startIndex]
    let slice2 = weakArray[CountableRange(3..<7)]
    expect(slice2).to(haveCount(4))
    expect(slice2.flatMap({$0})) == array[3..<7]
    expect(slice1 == slice2) == false
    let slice3 = slice1[Range(3..<4)]
    expect(slice3).to(haveCount(1))
    expect(slice3[3]) == array[3]
    let slice4 = slice2[CountableRange(3..<4)]
    expect(slice4).to(haveCount(1))
    expect(slice4[3]) == array[3]
    expect(slice3 == slice4) == true
    weakArray[Range(0..<0)] = slice1
    expect(weakArray).to(haveCount(14))
    expect(weakArray.flatMap({$0})) == ["1", "2", "3", "4", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
    weakArray[CountableRange(4..<8)] = slice4[3..<3]
    expect(weakArray).to(haveCount(10))
    expect(weakArray.flatMap({$0})) == ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
  }

  func testPrefix() {
    let array: [NSString] = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
    let weakArray = WeakArray<NSString>(array)
    expect(weakArray.prefix(4).flatMap({$0})).to(equal(array.prefix(4)))
  }

  func testSuffix() {
    let array: [NSString] = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
    let weakArray = WeakArray<NSString>(array)
    expect(weakArray.suffix(4).flatMap({$0})).to(equal(array.suffix(4)))
  }

  func testDescription() {
    let string1: NSString = "1", string2: NSString = "2", string3: NSString = "3"
    let weakArray: WeakArray<NSString> = [string1, string2, string3]
    expect(weakArray.description) == "[1, 2, 3]"
    expect(weakArray.debugDescription) == "[1, 2, 3]"
    let slice = weakArray[weakArray.indices]
    expect(slice.description) == "[1, 2, 3]"
    expect(slice.debugDescription) == "[1, 2, 3]"
  }

  func testEquatable() {
    let string1: NSString = "1", string2: NSString = "2", string3: NSString = "3"
    let weakArray1: WeakArray<NSString> = [string1, string2, string3]
    let weakArray2: WeakArray<NSString> = [string1, string2, string3]
    let weakArray3: WeakArray<NSString> = [string1, string2]
    let weakArray4 = weakArray3
    expect(weakArray1 == weakArray2) == true
    expect(weakArray1 == weakArray3) == false
    expect(weakArray3 == weakArray4) == true
    let slice1 = weakArray1[0..<2]
    let slice2 = weakArray2[0..<2]
    let slice3 = weakArray3[0..<2]
    let slice4 = weakArray1[1..<3]
    let slice5 = slice4
    expect(slice1 == slice2) == true
    expect(slice1 == slice3) == true
    expect(slice1 == slice4) == false
    expect(slice2 == slice3) == true
    expect(slice4 == slice5) == true
  }

}
