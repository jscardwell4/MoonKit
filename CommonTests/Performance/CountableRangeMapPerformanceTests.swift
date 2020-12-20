//
//  CountableRangeMapPerformanceTests.swift
//  MoonKit
//
//  Created by Jason Cardwell on 7/3/16.
//  Copyright © 2016 Jason Cardwell. All rights reserved.
//

import XCTest
import MoonKitTest
import MoonKit

private let testData = TestData(size: .large)
private let integers = testData.integers()
private let ranges: [CountableClosedRange<Int>] = {
  ranges in
  return ranges.flatMap({
    range in
    guard !range.isEmpty else { return nil }
    return CountableClosedRange(range)
  })
}(testData.ranges(withinRange: 0..<testData.count, coverage: 0.01, limit: 3))


final class CountableRangeMapPerformanceTests: XCTestCase {

  static let emptyCountableRangeMap = CountableRangeMap<Int>()
  static let loadedCountableRangeMap = CountableRangeMap(ranges)

  func testCreationPerformance() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      let data = ranges
      self.startMeasuring()
      _ = CountableRangeMap(data)
      self.stopMeasuring()
    }
  }

  func testRangeInsertionPerformance() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      let data = ranges
      var rangeMap = CountableRangeMapPerformanceTests.emptyCountableRangeMap
      self.startMeasuring()
      for range in data { rangeMap.insert(range) }
      self.stopMeasuring()
    }
  }

  func testSingleValueInsertionPerformance() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      let data = integers
      var rangeMap = CountableRangeMapPerformanceTests.emptyCountableRangeMap
      self.startMeasuring()
      for integer in data { rangeMap.insert(integer) }
      self.stopMeasuring()
    }
  }

  func testFlattenedCountPerformance() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      let data = integers
      let rangeMap = CountableRangeMap(data)
      self.startMeasuring()
      _ = rangeMap.flattenedCount
      self.stopMeasuring()
    }
  }

  func testInvertPerformance() {
    measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
      var rangeMap = CountableRangeMapPerformanceTests.loadedCountableRangeMap
      let lowerBound = integers.min()!
      let upperBound = integers.max()!
      self.startMeasuring()
      rangeMap.invert(coverage: lowerBound...upperBound)
      self.stopMeasuring()
    }
  }

}
