//
//  QueuePerformanceTests.swift
//  MoonKit
//
//  Created by Jason Cardwell on 7/19/16.
//  Copyright © 2016 Jason Cardwell. All rights reserved.
//
import XCTest
@testable import MoonKit

final class QueuePerformanceTests: XCTestCase {

  static let emptyIntegerQueue = Queue<Int>()
  static let loadedIntegerQueue = Queue<Int>(largeIntegers0)
  static let emptyStringQueue = Queue<String>()
  static let loadedStringQueue = Queue<String>(largeStrings0)

  func testCreationPerformanceInt() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      let dataSets = [largeIntegers0, largeIntegers1, largeIntegers2, largeIntegers3, largeIntegers4,
                      largeIntegers5, largeIntegers6, largeIntegers7, largeIntegers8, largeIntegers9]
      self.startMeasuring()
      for dataSet in dataSets { _ = Queue(dataSet) }
      self.stopMeasuring()
    }
  }

  func testDequeuePerformanceInt() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var queue = QueuePerformanceTests.loadedIntegerQueue
      self.startMeasuring()
      while !queue.isEmpty { queue.dequeue() }
      self.stopMeasuring()
    }
  }

  func testEnqueuePerformanceInt() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var queue = QueuePerformanceTests.emptyIntegerQueue
      let integers = largeIntegers0
      self.startMeasuring()
      for integer in integers { queue.enqueue(integer) }
      self.stopMeasuring()
    }
  }

  func testReversePerformanceInt() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var queue = QueuePerformanceTests.loadedIntegerQueue
      self.startMeasuring()
      queue.reverse()
      self.stopMeasuring()
    }
  }

  func testCreationPerformanceString() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      let dataSets = [largeStrings0, largeStrings1, largeStrings2, largeStrings3, largeStrings4,
                      largeStrings5, largeStrings6, largeStrings7, largeStrings8, largeStrings9]
      self.startMeasuring()
      for dataSet in dataSets { _ = Queue(dataSet) }
      self.stopMeasuring()
    }
  }

  func testDequeuePerformanceString() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var queue = QueuePerformanceTests.loadedStringQueue
      self.startMeasuring()
      while !queue.isEmpty { queue.dequeue() }
      self.stopMeasuring()
    }
  }

  func testEnqueuePerformanceString() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var queue = QueuePerformanceTests.emptyStringQueue
      let strings = largeStrings0
      self.startMeasuring()
      for string in strings { queue.enqueue(string) }
      self.stopMeasuring()
    }
  }

  func testReversePerformanceString() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var queue = QueuePerformanceTests.loadedStringQueue
      self.startMeasuring()
      queue.reverse()
      self.stopMeasuring()
    }
  }
}

