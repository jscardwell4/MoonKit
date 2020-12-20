//
//  NativeArrayPerformance.swift
//  MoonKitTests
//
//  Created by Jason Cardwell on 12/20/20.
//  Copyright © 2020 Moondeer Studios. All rights reserved.
//
@testable import MoonKit
import XCTest

final class NativeArrayPerformanceTests: XCTestCase {
  static let emptyIntegerArray = [Int]()
  static let loadedIntegerArray = [Int](largeIntegers0)
  static let emptyStringArray = [String]()
  static let loadedStringArray = [String](largeStrings0)

  func testCreationPerformanceInt() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      let dataSets = [largeIntegers0, largeIntegers1, largeIntegers2, largeIntegers3, largeIntegers4,
                      largeIntegers5, largeIntegers6, largeIntegers7, largeIntegers8, largeIntegers9]
      self.startMeasuring()
      for dataSet in dataSets { _ = Array(dataSet) }
      self.stopMeasuring()
    }
  }

  func testPopPerformanceInt() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var array = NativeArrayPerformanceTests.loadedIntegerArray
      self.startMeasuring()
      while !array.isEmpty { array.removeLast() }
      self.stopMeasuring()
    }
  }

  func testPushPerformanceInt() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var array = NativeArrayPerformanceTests.emptyIntegerArray
      let integers = largeIntegers0
      self.startMeasuring()
      for integer in integers { array.append(integer) }
      self.stopMeasuring()
    }
  }

  func testReversePerformanceInt() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var array = NativeArrayPerformanceTests.loadedIntegerArray
      self.startMeasuring()
      array.reverse()
      self.stopMeasuring()
    }
  }

  func testCreationPerformanceString() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      let dataSets = [largeStrings0, largeStrings1, largeStrings2, largeStrings3, largeStrings4,
                      largeStrings5, largeStrings6, largeStrings7, largeStrings8, largeStrings9]
      self.startMeasuring()
      for dataSet in dataSets { _ = Array(dataSet) }
      self.stopMeasuring()
    }
  }

  func testPopPerformanceString() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var array = NativeArrayPerformanceTests.loadedStringArray
      self.startMeasuring()
      while !array.isEmpty { array.removeLast() }
      self.stopMeasuring()
    }
  }

  func testPushPerformanceString() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var array = NativeArrayPerformanceTests.emptyStringArray
      let strings = largeStrings0
      self.startMeasuring()
      for string in strings { array.append(string) }
      self.stopMeasuring()
    }
  }

  func testReversePerformanceString() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var array = NativeArrayPerformanceTests.loadedStringArray
      self.startMeasuring()
      array.reverse()
      self.stopMeasuring()
    }
  }
}
