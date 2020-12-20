//
//  StackPerformanceTests.swift
//  MoonKit
//
//  Created by Jason Cardwell on 7/18/16.
//  Copyright © 2016 Jason Cardwell. All rights reserved.
//
import XCTest
@testable import MoonKit

final class StackPerformanceTests: XCTestCase {

  static let emptyIntegerStack = Stack<Int>()
  static let loadedIntegerStack = Stack<Int>(largeIntegers0)
  static let emptyStringStack = Stack<String>()
  static let loadedStringStack = Stack<String>(largeStrings0)

  func testCreationPerformanceInt() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      let dataSets = [largeIntegers0, largeIntegers1, largeIntegers2, largeIntegers3, largeIntegers4,
                      largeIntegers5, largeIntegers6, largeIntegers7, largeIntegers8, largeIntegers9]
      self.startMeasuring()
      for dataSet in dataSets { _ = Stack(dataSet) }
      self.stopMeasuring()
    }
  }

  func testPopPerformanceInt() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var stack = StackPerformanceTests.loadedIntegerStack
      self.startMeasuring()
      while !stack.isEmpty { stack.pop() }
      self.stopMeasuring()
    }
  }

  func testPushPerformanceInt() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var stack = StackPerformanceTests.emptyIntegerStack
      let integers = largeIntegers0
      self.startMeasuring()
      for integer in integers { stack.push(integer) }
      self.stopMeasuring()
    }
  }

  func testReversePerformanceInt() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var stack = StackPerformanceTests.loadedIntegerStack
      self.startMeasuring()
      stack.reverse()
      self.stopMeasuring()
    }
  }

  func testCreationPerformanceString() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      let dataSets = [largeStrings0, largeStrings1, largeStrings2, largeStrings3, largeStrings4,
                      largeStrings5, largeStrings6, largeStrings7, largeStrings8, largeStrings9]
      self.startMeasuring()
      for dataSet in dataSets { _ = Stack(dataSet) }
      self.stopMeasuring()
    }
  }

  func testPopPerformanceString() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var stack = StackPerformanceTests.loadedStringStack
      self.startMeasuring()
      while !stack.isEmpty { stack.pop() }
      self.stopMeasuring()
    }
  }

  func testPushPerformanceString() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var stack = StackPerformanceTests.emptyStringStack
      let strings = largeStrings0
      self.startMeasuring()
      for string in strings { stack.push(string) }
      self.stopMeasuring()
    }
  }

  func testReversePerformanceString() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var stack = StackPerformanceTests.loadedStringStack
      self.startMeasuring()
      stack.reverse()
      self.stopMeasuring()
    }
  }

}

