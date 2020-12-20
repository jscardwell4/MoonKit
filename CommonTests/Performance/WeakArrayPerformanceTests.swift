//
//  WeakArrayPerformanceTests.swift
//  MoonKit
//
//  Created by Jason Cardwell on 7/17/16.
//  Copyright © 2016 Jason Cardwell. All rights reserved.
//

import XCTest
import MoonKitTest
import MoonKit

private let testData = MoonKitTest.TestData(size: .large)

private let numbers0 = testData.integerObjects()
private let numbers1 = testData.integerObjects()
private let numbers2 = testData.integerObjects()
private let numbers3 = testData.integerObjects()
private let numbers4 = testData.integerObjects()
private let numbers5 = testData.integerObjects()
private let numbers6 = testData.integerObjects()
private let numbers7 = testData.integerObjects()
private let numbers8 = testData.integerObjects()
private let numbers9 = testData.integerObjects()

final class WeakArrayPerformanceTests: XCTestCase {

  static let emptyArray = WeakArray<NSNumber>()
  static let loadedArray = WeakArray<NSNumber>(numbers0)

  override class func setUp() {
    
  }

  func testCreation() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      let numberArrays = [numbers0, numbers1, numbers2, numbers3, numbers4,
                          numbers5, numbers6, numbers7, numbers8, numbers9]
      self.startMeasuring()
      for numbers in numberArrays { _ = WeakArray(numbers) }
      self.stopMeasuring()
    }
  }

  func testReserveCapacity() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = WeakArrayPerformanceTests.loadedArray
      self.startMeasuring()
      for _ in 0..<10 { array.reserveCapacity(array.capacity*2) }
      self.stopMeasuring()
    }
  }

  func testAppend() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = WeakArrayPerformanceTests.emptyArray
      let numbers = numbers0
      self.startMeasuring()
      for number in numbers { array.append(number) }
      self.stopMeasuring()
    }
  }

  func testAppendContentsOf() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = WeakArrayPerformanceTests.emptyArray
      let numberArrays = [numbers0, numbers1, numbers2, numbers3, numbers4,
                          numbers5, numbers6, numbers7, numbers8, numbers9]
      self.startMeasuring()
      for numbers in numberArrays { array.append(contentsOf: numbers as [NSNumber?]) }
      self.stopMeasuring()
    }
  }

  func testInsert() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = WeakArrayPerformanceTests.emptyArray
      let numbers = numbers0
      self.startMeasuring()
      for number in numbers { array.insert(number, at: array.count/2) }
      self.stopMeasuring()
    }
  }

  func testInsertContentsOf() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = WeakArrayPerformanceTests.emptyArray
      let numberArrays = [numbers0, numbers1, numbers2, numbers3, numbers4,
                          numbers5, numbers6, numbers7, numbers8, numbers9]
      self.startMeasuring()
      for numbers in numberArrays { array.insert(contentsOf: numbers as [NSNumber?], at: array.count/2) }
      self.stopMeasuring()
    }
  }

  func testRemoveAt() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = WeakArrayPerformanceTests.loadedArray
      self.startMeasuring()
      while array.count > 0 { array.remove(at: array.count/2) }
      self.stopMeasuring()
    }
  }

  func testRemoveLast() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = WeakArrayPerformanceTests.loadedArray
      self.startMeasuring()
      while array.count > 0 { array.removeLast() }
      self.stopMeasuring()
    }
  }

  func testRemoveFirst() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = WeakArrayPerformanceTests.loadedArray
      self.startMeasuring()
      while array.count > 0 { array.removeFirst() }
      self.stopMeasuring()
    }
  }

  func testRemoveLastN() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = WeakArrayPerformanceTests.loadedArray
      self.startMeasuring()
      while array.count > 5 { array.removeLast(5) }
      self.stopMeasuring()
    }
  }

  func testRemoveFirstN() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = WeakArrayPerformanceTests.loadedArray
      self.startMeasuring()
      while array.count > 5 { array.removeFirst(5) }
      self.stopMeasuring()
    }
  }

  func testRemoveAll() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = WeakArrayPerformanceTests.loadedArray
      self.startMeasuring()
      array.removeAll(keepingCapacity: true)
      self.stopMeasuring()
    }
  }

  func testReplaceSubRange() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = WeakArrayPerformanceTests.loadedArray
      let numberArrays = [numbers0, numbers1, numbers2, numbers3, numbers4,
                          numbers5, numbers6, numbers7, numbers8, numbers9]
      self.startMeasuring()
      for numbers in numberArrays { array.replaceSubrange(array.count/4..<(array.count*3)/4, with: numbers as [NSNumber?]) }
      self.stopMeasuring()
    }
  }

  func testSubscriptIndexAccessor() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = WeakArrayPerformanceTests.loadedArray
      self.startMeasuring()
      for i in array.indices { _ = array[i] }
      self.stopMeasuring()
    }
  }

  func testSubscriptIndexMutator() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = WeakArrayPerformanceTests.loadedArray
      let numbers = numbers1
      self.startMeasuring()
      for i in array.indices { array[i] = numbers[i] }
      self.stopMeasuring()
    }
  }

}

final class NativeArrayPerformanceTests: XCTestCase {

  static let emptyArray = Array<NSNumber>()
  static let loadedArray = Array<NSNumber>(numbers0)

  func testCreation() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      let numberArrays = [numbers0, numbers1, numbers2, numbers3, numbers4,
                          numbers5, numbers6, numbers7, numbers8, numbers9]
      self.startMeasuring()
      for numbers in numberArrays { _ = Array(numbers) }
      self.stopMeasuring()
    }
  }

  func testReserveCapacity() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = NativeArrayPerformanceTests.loadedArray
      self.startMeasuring()
      for _ in 0..<10 { array.reserveCapacity(array.capacity*2) }
      self.stopMeasuring()
    }
  }

  func testAppend() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = NativeArrayPerformanceTests.emptyArray
      let numbers = numbers0
      self.startMeasuring()
      for number in numbers { array.append(number) }
      self.stopMeasuring()
    }
  }

  func testAppendContentsOf() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = NativeArrayPerformanceTests.emptyArray
      let numberArrays = [numbers0, numbers1, numbers2, numbers3, numbers4,
                          numbers5, numbers6, numbers7, numbers8, numbers9]
      self.startMeasuring()
      for numbers in numberArrays { array.append(contentsOf: numbers) }
      self.stopMeasuring()
    }
  }

  func testInsert() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = NativeArrayPerformanceTests.emptyArray
      let numbers = numbers0
      self.startMeasuring()
      for number in numbers { array.insert(number, at: array.count/2) }
      self.stopMeasuring()
    }
  }

  func testInsertContentsOf() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = NativeArrayPerformanceTests.emptyArray
      let numberArrays = [numbers0, numbers1, numbers2, numbers3, numbers4,
                          numbers5, numbers6, numbers7, numbers8, numbers9]
      self.startMeasuring()
      for numbers in numberArrays { array.insert(contentsOf: numbers, at: array.count/2) }
      self.stopMeasuring()
    }
  }

  func testRemoveAt() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = NativeArrayPerformanceTests.loadedArray
      self.startMeasuring()
      while array.count > 0 { array.remove(at: array.count/2) }
      self.stopMeasuring()
    }
  }

  func testRemoveLast() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = NativeArrayPerformanceTests.loadedArray
      self.startMeasuring()
      while array.count > 0 { array.removeLast() }
      self.stopMeasuring()
    }
  }

  func testRemoveFirst() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = NativeArrayPerformanceTests.loadedArray
      self.startMeasuring()
      while array.count > 0 { array.removeFirst() }
      self.stopMeasuring()
    }
  }

  func testRemoveLastN() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = NativeArrayPerformanceTests.loadedArray
      self.startMeasuring()
      while array.count > 5 { array.removeLast(5) }
      self.stopMeasuring()
    }
  }

  func testRemoveFirstN() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = NativeArrayPerformanceTests.loadedArray
      self.startMeasuring()
      while array.count > 5 { array.removeFirst(5) }
      self.stopMeasuring()
    }
  }

  func testRemoveAll() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = NativeArrayPerformanceTests.loadedArray
      self.startMeasuring()
      array.removeAll(keepingCapacity: true)
      self.stopMeasuring()
    }
  }

  func testReplaceSubRange() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = NativeArrayPerformanceTests.loadedArray
      let numberArrays = [numbers0, numbers1, numbers2, numbers3, numbers4,
                          numbers5, numbers6, numbers7, numbers8, numbers9]
      self.startMeasuring()
      for numbers in numberArrays { array.replaceSubrange(array.count/4..<(array.count*3)/4, with: numbers) }
      self.stopMeasuring()
    }
  }

  func testSubscriptIndexAccessor() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = NativeArrayPerformanceTests.loadedArray
      self.startMeasuring()
      for i in array.indices { _ = array[i] }
      self.stopMeasuring()
    }
  }

  func testSubscriptIndexMutator() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var array = NativeArrayPerformanceTests.loadedArray
      let numbers = numbers1
      self.startMeasuring()
      for i in array.indices { array[i] = numbers[i] }
      self.stopMeasuring()
    }
  }

}
