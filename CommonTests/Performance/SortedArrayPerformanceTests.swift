//
//  SortedArrayPerformanceTests.swift
//  MoonKit
//
//  Created by Jason Cardwell on 7/19/16.
//  Copyright © 2016 Jason Cardwell. All rights reserved.
//

import XCTest
import MoonKitTest
import MoonKit

private let testData = MoonKitTest.TestData(size: .small)

private let integers0 = testData.integers()
private let integers1 = testData.integers()
private let integers2 = testData.integers()
private let integers3 = testData.integers()
private let integers4 = testData.integers()
private let integers5 = testData.integers()
private let integers6 = testData.integers()
private let integers7 = testData.integers()
private let integers8 = testData.integers()
private let integers9 = testData.integers()

private let strings0 = testData.strings()
private let strings1 = testData.strings()
private let strings2 = testData.strings()
private let strings3 = testData.strings()
private let strings4 = testData.strings()
private let strings5 = testData.strings()
private let strings6 = testData.strings()
private let strings7 = testData.strings()
private let strings8 = testData.strings()
private let strings9 = testData.strings()


final class SortedArrayPerformanceTests: XCTestCase {

  static let emptyArrayInt = SortedArray<Int>()
  static let loadedArrayInt = SortedArray<Int>(integers0)
  static let emptyArrayString = SortedArray<String>()
  static let loadedArrayString = SortedArray<String>(strings0)

  func testCreationInt() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      let integerArrays = [integers0, integers1, integers2, integers3, integers4,
                          integers5, integers6, integers7, integers8, integers9]
      self.startMeasuring()
      for integers in integerArrays { _ = SortedArray(integers) }
      self.stopMeasuring()
    }
  }

  func testReserveCapacityInt() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = SortedArrayPerformanceTests.loadedArrayInt
      self.startMeasuring()
      for _ in 0..<10 { array.reserveCapacity(array.capacity*2) }
      self.stopMeasuring()
    }
  }

  func testAppendInt() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = SortedArrayPerformanceTests.emptyArrayInt
      let integers = integers0
      self.startMeasuring()
      for integer in integers { array.append(integer) }
      self.stopMeasuring()
    }
  }

  func testAppendContentsOfInt() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = SortedArrayPerformanceTests.emptyArrayInt
      let integerArrays = [integers0, integers1, integers2, integers3, integers4,
                          integers5, integers6, integers7, integers8, integers9]
      self.startMeasuring()
      for integers in integerArrays { array.append(contentsOf: integers) }
      self.stopMeasuring()
    }
  }

  func testInsertInt() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = SortedArrayPerformanceTests.emptyArrayInt
      let integers = integers0
      self.startMeasuring()
      for integer in integers { array.insert(integer, at: array.count/2) }
      self.stopMeasuring()
    }
  }

  func testInsertContentsOfInt() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = SortedArrayPerformanceTests.emptyArrayInt
      let integerArrays = [integers0, integers1, integers2, integers3, integers4,
                          integers5, integers6, integers7, integers8, integers9]
      self.startMeasuring()
      for integers in integerArrays { array.insert(contentsOf: integers, at: array.count/2) }
      self.stopMeasuring()
    }
  }

  func testRemoveAtInt() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = SortedArrayPerformanceTests.loadedArrayInt
      self.startMeasuring()
      while array.count > 0 { array.remove(at: array.count/2) }
      self.stopMeasuring()
    }
  }

  func testRemoveLastInt() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = SortedArrayPerformanceTests.loadedArrayInt
      self.startMeasuring()
      while array.count > 0 { array.removeLast() }
      self.stopMeasuring()
    }
  }

  func testRemoveFirstInt() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = SortedArrayPerformanceTests.loadedArrayInt
      self.startMeasuring()
      while array.count > 0 { array.removeFirst() }
      self.stopMeasuring()
    }
  }

  func testRemoveLastNInt() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = SortedArrayPerformanceTests.loadedArrayInt
      self.startMeasuring()
      while array.count > 5 { array.removeLast(5) }
      self.stopMeasuring()
    }
  }

  func testRemoveFirstNInt() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = SortedArrayPerformanceTests.loadedArrayInt
      self.startMeasuring()
      while array.count > 5 { array.removeFirst(5) }
      self.stopMeasuring()
    }
  }

  func testRemoveAllInt() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = SortedArrayPerformanceTests.loadedArrayInt
      self.startMeasuring()
      array.removeAll(keepingCapacity: true)
      self.stopMeasuring()
    }
  }

  func testReplaceSubRangeInt() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = SortedArrayPerformanceTests.loadedArrayInt
      let integerArrays = [integers0, integers1, integers2, integers3, integers4,
                          integers5, integers6, integers7, integers8, integers9]
      self.startMeasuring()
      for integers in integerArrays { array.replaceSubrange(array.count/4..<(array.count*3)/4, with: integers) }
      self.stopMeasuring()
    }
  }

  func testSubscriptIndexAccessorInt() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = SortedArrayPerformanceTests.loadedArrayInt
      self.startMeasuring()
      for i in array.indices { _ = array[i] }
      self.stopMeasuring()
    }
  }

  func testSubscriptIndexMutatorInt() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = SortedArrayPerformanceTests.loadedArrayInt
      let integers = integers1
      self.startMeasuring()
      for i in array.indices { array[i] = integers[i] }
      self.stopMeasuring()
    }
  }
  
  func testCreationString() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      let stringArrays = [strings0, strings1, strings2, strings3, strings4,
                          strings5, strings6, strings7, strings8, strings9]
      self.startMeasuring()
      for strings in stringArrays { _ = SortedArray(strings) }
      self.stopMeasuring()
    }
  }

  func testReserveCapacityString() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = SortedArrayPerformanceTests.loadedArrayString
      self.startMeasuring()
      for _ in 0..<10 { array.reserveCapacity(array.capacity*2) }
      self.stopMeasuring()
    }
  }

  func testAppendString() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = SortedArrayPerformanceTests.emptyArrayString
      let strings = strings0
      self.startMeasuring()
      for string in strings { array.append(string) }
      self.stopMeasuring()
    }
  }

  func testAppendContentsOfString() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = SortedArrayPerformanceTests.emptyArrayString
      let stringArrays = [strings0, strings1, strings2, strings3, strings4,
                          strings5, strings6, strings7, strings8, strings9]
      self.startMeasuring()
      for strings in stringArrays { array.append(contentsOf: strings) }
      self.stopMeasuring()
    }
  }

  func testInsertString() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = SortedArrayPerformanceTests.emptyArrayString
      let strings = strings0
      self.startMeasuring()
      for string in strings { array.insert(string, at: array.count/2) }
      self.stopMeasuring()
    }
  }

  func testInsertContentsOfString() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = SortedArrayPerformanceTests.emptyArrayString
      let stringArrays = [strings0, strings1, strings2, strings3, strings4,
                          strings5, strings6, strings7, strings8, strings9]
      self.startMeasuring()
      for strings in stringArrays { array.insert(contentsOf: strings, at: array.count/2) }
      self.stopMeasuring()
    }
  }

  func testRemoveAtString() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = SortedArrayPerformanceTests.loadedArrayString
      self.startMeasuring()
      while array.count > 0 { array.remove(at: array.count/2) }
      self.stopMeasuring()
    }
  }

  func testRemoveLastString() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = SortedArrayPerformanceTests.loadedArrayString
      self.startMeasuring()
      while array.count > 0 { array.removeLast() }
      self.stopMeasuring()
    }
  }

  func testRemoveFirstString() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = SortedArrayPerformanceTests.loadedArrayString
      self.startMeasuring()
      while array.count > 0 { array.removeFirst() }
      self.stopMeasuring()
    }
  }

  func testRemoveLastNString() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = SortedArrayPerformanceTests.loadedArrayString
      self.startMeasuring()
      while array.count > 5 { array.removeLast(5) }
      self.stopMeasuring()
    }
  }

  func testRemoveFirstNString() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = SortedArrayPerformanceTests.loadedArrayString
      self.startMeasuring()
      while array.count > 5 { array.removeFirst(5) }
      self.stopMeasuring()
    }
  }

  func testRemoveAllString() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = SortedArrayPerformanceTests.loadedArrayString
      self.startMeasuring()
      array.removeAll(keepingCapacity: true)
      self.stopMeasuring()
    }
  }

  func testReplaceSubRangeString() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = SortedArrayPerformanceTests.loadedArrayString
      let stringArrays = [strings0, strings1, strings2, strings3, strings4,
                          strings5, strings6, strings7, strings8, strings9]
      self.startMeasuring()
      for strings in stringArrays { array.replaceSubrange(array.count/4..<(array.count*3)/4, with: strings) }
      self.stopMeasuring()
    }
  }

  func testSubscriptIndexAccessorString() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = SortedArrayPerformanceTests.loadedArrayString
      self.startMeasuring()
      for i in array.indices { _ = array[i] }
      self.stopMeasuring()
    }
  }

  func testSubscriptIndexMutatorString() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = SortedArrayPerformanceTests.loadedArrayString
      let strings = strings1
      self.startMeasuring()
      for i in array.indices { array[i] = strings[i] }
      self.stopMeasuring()
    }
  }

}

final class NativeArrayPerformanceTests: XCTestCase {

  static let emptyArrayInt = Array<Int>()
  static let loadedArrayInt = Array<Int>(integers0.sorted())
  static let emptyArrayString = Array<String>()
  static let loadedArrayString = Array<String>(strings0.sorted())

  func testCreationInt() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      let integerArrays = [integers0, integers1, integers2, integers3, integers4,
                          integers5, integers6, integers7, integers8, integers9]
      self.startMeasuring()
      for integers in integerArrays { _ = integers.sorted() }
      self.stopMeasuring()
    }
  }

  func testReserveCapacityInt() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = NativeArrayPerformanceTests.loadedArrayInt
      self.startMeasuring()
      for _ in 0..<10 { array.reserveCapacity(array.capacity*2) }
      self.stopMeasuring()
    }
  }

  func testAppendInt() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = NativeArrayPerformanceTests.emptyArrayInt
      let integers = integers0
      self.startMeasuring()
      for integer in integers { array.append(integer); array.sort() }
      self.stopMeasuring()
    }
  }

  func testAppendContentsOfInt() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = NativeArrayPerformanceTests.emptyArrayInt
      let integerArrays = [integers0, integers1, integers2, integers3, integers4,
                          integers5, integers6, integers7, integers8, integers9]
      self.startMeasuring()
      for integers in integerArrays { array.append(contentsOf: integers); array.sort() }
      self.stopMeasuring()
    }
  }

  func testInsertInt() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = NativeArrayPerformanceTests.emptyArrayInt
      let integers = integers0
      self.startMeasuring()
      for integer in integers { array.insert(integer, at: array.count/2); array.sort() }
      self.stopMeasuring()
    }
  }

  func testInsertContentsOfInt() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = NativeArrayPerformanceTests.emptyArrayInt
      let integerArrays = [integers0, integers1, integers2, integers3, integers4,
                          integers5, integers6, integers7, integers8, integers9]
      self.startMeasuring()
      for integers in integerArrays { array.insert(contentsOf: integers, at: array.count/2); array.sort() }
      self.stopMeasuring()
    }
  }

  func testRemoveAtInt() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = NativeArrayPerformanceTests.loadedArrayInt
      self.startMeasuring()
      while array.count > 0 { array.remove(at: array.count/2) }
      self.stopMeasuring()
    }
  }

  func testRemoveLastInt() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = NativeArrayPerformanceTests.loadedArrayInt
      self.startMeasuring()
      while array.count > 0 { array.removeLast() }
      self.stopMeasuring()
    }
  }

  func testRemoveFirstInt() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = NativeArrayPerformanceTests.loadedArrayInt
      self.startMeasuring()
      while array.count > 0 { array.removeFirst() }
      self.stopMeasuring()
    }
  }

  func testRemoveLastNInt() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = NativeArrayPerformanceTests.loadedArrayInt
      self.startMeasuring()
      while array.count > 5 { array.removeLast(5) }
      self.stopMeasuring()
    }
  }

  func testRemoveFirstNInt() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = NativeArrayPerformanceTests.loadedArrayInt
      self.startMeasuring()
      while array.count > 5 { array.removeFirst(5) }
      self.stopMeasuring()
    }
  }

  func testRemoveAllInt() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = NativeArrayPerformanceTests.loadedArrayInt
      self.startMeasuring()
      array.removeAll(keepingCapacity: true)
      self.stopMeasuring()
    }
  }

  func testReplaceSubRangeInt() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = NativeArrayPerformanceTests.loadedArrayInt
      let integerArrays = [integers0, integers1, integers2, integers3, integers4,
                          integers5, integers6, integers7, integers8, integers9]
      self.startMeasuring()
      for integers in integerArrays { array.replaceSubrange(array.count/4..<(array.count*3)/4, with: integers); array.sort() }
      self.stopMeasuring()
    }
  }

  func testSubscriptIndexAccessorInt() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = NativeArrayPerformanceTests.loadedArrayInt
      self.startMeasuring()
      for i in array.indices { _ = array[i] }
      self.stopMeasuring()
    }
  }

  func testSubscriptIndexMutatorInt() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = NativeArrayPerformanceTests.loadedArrayInt
      let integers = integers1
      self.startMeasuring()
      for i in array.indices { array[i] = integers[i]; array.sort() }
      self.stopMeasuring()
    }
  }
  
  func testCreationString() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      let stringArrays = [strings0, strings1, strings2, strings3, strings4,
                          strings5, strings6, strings7, strings8, strings9]
      self.startMeasuring()
      for strings in stringArrays { _ = strings.sorted() }
      self.stopMeasuring()
    }
  }

  func testReserveCapacityString() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = NativeArrayPerformanceTests.loadedArrayString
      self.startMeasuring()
      for _ in 0..<10 { array.reserveCapacity(array.capacity*2) }
      self.stopMeasuring()
    }
  }

  func testAppendString() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = NativeArrayPerformanceTests.emptyArrayString
      let strings = strings0
      self.startMeasuring()
      for string in strings { array.append(string); array.sort() }
      self.stopMeasuring()
    }
  }

  func testAppendContentsOfString() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = NativeArrayPerformanceTests.emptyArrayString
      let stringArrays = [strings0, strings1, strings2, strings3, strings4,
                          strings5, strings6, strings7, strings8, strings9]
      self.startMeasuring()
      for strings in stringArrays { array.append(contentsOf: strings); array.sort() }
      self.stopMeasuring()
    }
  }

  func testInsertString() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = NativeArrayPerformanceTests.emptyArrayString
      let strings = strings0
      self.startMeasuring()
      for string in strings { array.insert(string, at: array.count/2); array.sort() }
      self.stopMeasuring()
    }
  }

  func testInsertContentsOfString() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = NativeArrayPerformanceTests.emptyArrayString
      let stringArrays = [strings0, strings1, strings2, strings3, strings4,
                          strings5, strings6, strings7, strings8, strings9]
      self.startMeasuring()
      for strings in stringArrays { array.insert(contentsOf: strings, at: array.count/2); array.sort() }
      self.stopMeasuring()
    }
  }

  func testRemoveAtString() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = NativeArrayPerformanceTests.loadedArrayString
      self.startMeasuring()
      while array.count > 0 { array.remove(at: array.count/2) }
      self.stopMeasuring()
    }
  }

  func testRemoveLastString() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = NativeArrayPerformanceTests.loadedArrayString
      self.startMeasuring()
      while array.count > 0 { array.removeLast() }
      self.stopMeasuring()
    }
  }

  func testRemoveFirstString() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = NativeArrayPerformanceTests.loadedArrayString
      self.startMeasuring()
      while array.count > 0 { array.removeFirst() }
      self.stopMeasuring()
    }
  }

  func testRemoveLastNString() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = NativeArrayPerformanceTests.loadedArrayString
      self.startMeasuring()
      while array.count > 5 { array.removeLast(5) }
      self.stopMeasuring()
    }
  }

  func testRemoveFirstNString() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = NativeArrayPerformanceTests.loadedArrayString
      self.startMeasuring()
      while array.count > 5 { array.removeFirst(5) }
      self.stopMeasuring()
    }
  }

  func testRemoveAllString() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = NativeArrayPerformanceTests.loadedArrayString
      self.startMeasuring()
      array.removeAll(keepingCapacity: true)
      self.stopMeasuring()
    }
  }

  func testReplaceSubRangeString() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = NativeArrayPerformanceTests.loadedArrayString
      let stringArrays = [strings0, strings1, strings2, strings3, strings4,
                          strings5, strings6, strings7, strings8, strings9]
      self.startMeasuring()
      for strings in stringArrays { array.replaceSubrange(array.count/4..<(array.count*3)/4, with: strings) }
      self.stopMeasuring()
    }
  }

  func testSubscriptIndexAccessorString() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = NativeArrayPerformanceTests.loadedArrayString
      self.startMeasuring()
      for i in array.indices { _ = array[i] }
      self.stopMeasuring()
    }
  }

  func testSubscriptIndexMutatorString() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = NativeArrayPerformanceTests.loadedArrayString
      let strings = strings1
      self.startMeasuring()
      for i in array.indices { array[i] = strings[i]; array.sort() }
      self.stopMeasuring()
    }
  }

}
