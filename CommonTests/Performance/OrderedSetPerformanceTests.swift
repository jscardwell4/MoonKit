//
//  OrderedSetPerformanceTests.swift
//  MoonKit
//
//  Created by Jason Cardwell on 5/24/16.
//  Copyright © 2016 Jason Cardwell. All rights reserved.
//
@testable import MoonKit
import XCTest

// MARK: - OrderedSetPerformanceTests

final class OrderedSetPerformanceTests: XCTestCase {
  static let emptyIntegerSet: MoonKit.OrderedSet<Int> = []
  static let loadedIntegerSet = MoonKit.OrderedSet(largeIntegers0)
  static let loadedIntegerSubset = MoonKit.OrderedSet(largeSubIntegers0)
  static let evenIntegerSet = MoonKit.OrderedSet(largeEvenIntegers)
  static let oddIntegerSet = MoonKit.OrderedSet(largeOddIntegers)

  static let emptyStringSet: MoonKit.OrderedSet<String> = []
  static let loadedStringSet = MoonKit.OrderedSet(largeStrings0)
  static let loadedStringSubset = MoonKit.OrderedSet(largeSubStrings0)
  static let evenStringSet = MoonKit.OrderedSet(largeEvenStrings)
  static let oddStringSet = MoonKit.OrderedSet(largeOddStrings)

  func testCreationPerformanceInt() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      let dataSets = [largeIntegers0, largeIntegers1, largeIntegers2, largeIntegers3,
                      largeIntegers4, largeIntegers5, largeIntegers6, largeIntegers7,
                      largeIntegers8, largeIntegers9]
      self.startMeasuring()
      for dataSet in dataSets { _ = MoonKit.OrderedSet(dataSet) }
      self.stopMeasuring()
    }
  }

  func testInsertionPerformanceInt() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var set = OrderedSetPerformanceTests.emptyIntegerSet
      let integers = largeIntegers0
      self.startMeasuring()
      for integer in integers { set.insert(integer) }
      self.stopMeasuring()
    }
  }

  func testRemovePerformanceInt() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var set = OrderedSetPerformanceTests.loadedIntegerSet
      let integers = largeIntegers0
      self.startMeasuring()
      for integer in integers { set.remove(integer) }
      self.stopMeasuring()
    }
  }

  func testRemoveAtPerformanceInt() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var set = OrderedSetPerformanceTests.loadedIntegerSet
      self.startMeasuring()
      while !set.isEmpty { set.remove(at: Int(arc4random_uniform(numericCast(set.count)))) }
      self.stopMeasuring()
    }
  }

  func testUnionPerformanceInt() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var set = OrderedSetPerformanceTests.loadedIntegerSet
      let integers = largeIntegers1
      self.startMeasuring()
      set.formUnion(integers)
      self.stopMeasuring()
    }
  }

  func testIntersectionPerformanceInt() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var set = OrderedSetPerformanceTests.loadedIntegerSet
      let integers = largeIntegers1
      self.startMeasuring()
      set.formIntersection(integers)
      self.stopMeasuring()
    }
  }

  func testSubtractPerformanceInt() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var set = OrderedSetPerformanceTests.loadedIntegerSet
      let integers = largeIntegers1
      self.startMeasuring()
      set.subtract(integers)
      self.stopMeasuring()
    }
  }

  func testSymmetricDifferencePerformanceInt() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var set = OrderedSetPerformanceTests.loadedIntegerSet
      let integers = largeIntegers1
      self.startMeasuring()
      set.formSymmetricDifference(integers)
      self.stopMeasuring()
    }
  }

  func testOverallPerformanceInt() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var set = OrderedSetPerformanceTests.emptyIntegerSet
      let dataSet0 = largeIntegers0, dataSet1 = largeIntegers1, dataSet2 = largeIntegers2, dataSet3 = largeIntegers3
      self.startMeasuring()
      for integer in dataSet0 { set.insert(integer) }
      for integer in dataSet1 { set.remove(integer) }
      set.formUnion(dataSet1)
      set.subtract(dataSet0)
      set.formSymmetricDifference(dataSet2)
      set.formIntersection(dataSet3)
      self.stopMeasuring()
    }
  }

  func testSubsetOfPerformanceInt() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      let set = OrderedSetPerformanceTests.loadedIntegerSubset
      let dataSets = [largeIntegers0, largeIntegers1, largeIntegers2, largeIntegers3, largeIntegers4,
                      largeIntegers5, largeIntegers6, largeIntegers7, largeIntegers8, largeIntegers9]
      self.startMeasuring()
      for other in dataSets { _ = set.isSubset(of: other) }
      self.stopMeasuring()
    }
  }

  func testStrictSubsetOfPerformanceInt() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      let set = OrderedSetPerformanceTests.loadedIntegerSubset
      let dataSets = [largeIntegers0, largeIntegers1, largeIntegers2, largeIntegers3, largeIntegers4,
                      largeIntegers5, largeIntegers6, largeIntegers7, largeIntegers8, largeIntegers9]
      self.startMeasuring()
      for other in dataSets { _ = set.isStrictSubset(of: other) }
      self.stopMeasuring()
    }
  }

  func testSupersetOfPerformanceInt() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      let set = OrderedSetPerformanceTests.loadedIntegerSet
      let dataSets = [largeSubIntegers0, largeSubIntegers1, largeSubIntegers2, largeSubIntegers3, largeSubIntegers4,
                      largeSubIntegers5, largeSubIntegers6, largeSubIntegers7, largeSubIntegers8, largeSubIntegers9]
      self.startMeasuring()
      for other in dataSets { _ = set.isSuperset(of: other) }
      self.stopMeasuring()
    }
  }

  func testStrictSupersetOfPerformanceInt() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      let set = OrderedSetPerformanceTests.loadedIntegerSet
      let dataSets = [largeSubIntegers0, largeSubIntegers1, largeSubIntegers2, largeSubIntegers3, largeSubIntegers4,
                      largeSubIntegers5, largeSubIntegers6, largeSubIntegers7, largeSubIntegers8, largeSubIntegers9]
      self.startMeasuring()
      for other in dataSets { _ = set.isStrictSuperset(of: other) }
      self.stopMeasuring()
    }
  }

  func testDisjointWithPerformanceInt() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      let set = OrderedSetPerformanceTests.loadedIntegerSubset
      let evenSet = OrderedSetPerformanceTests.evenIntegerSet
      let oddSet = OrderedSetPerformanceTests.oddIntegerSet
      let dataSets = [largeSubIntegers0, largeSubIntegers1, largeSubIntegers2, largeSubIntegers3, largeSubIntegers4,
                      largeSubIntegers5, largeSubIntegers6, largeSubIntegers7, largeSubIntegers8, largeSubIntegers9]
      self.startMeasuring()
      for other in dataSets { _ = set.isDisjoint(with: other) }
      _ = evenSet.isDisjoint(with: oddSet)
      _ = oddSet.isDisjoint(with: evenSet)
      _ = evenSet.isDisjoint(with: largeOddIntegers)
      _ = oddSet.isDisjoint(with: largeEvenIntegers)
      self.stopMeasuring()
    }
  }

  func testReplaceRangePerformanceInt() {
    var count = OrderedSetPerformanceTests.loadedIntegerSet.count
    var ranges: [(remove: CountableRange<Int>, insert: CountableRange<Int>)] = []
    ranges.reserveCapacity(1000)
    let coverage = 0.00025

    for _ in 0 ..< 1000 {
      let removeRange = randomRange(indices: 0 ..< count, coverage: coverage)
      let insertRange = randomRange(indices: largeIntegers1.indices, coverage: coverage)
      ranges.append((removeRange, insertRange))
      count = count - removeRange.count + insertRange.count
      guard count > 0 else { break }
    }

    let integers = largeIntegers1

    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var set = OrderedSetPerformanceTests.loadedIntegerSet
      self.startMeasuring()
      for (removeRange, insertRange) in ranges {
        set.replaceSubrange(removeRange, with: integers[insertRange])
      }
      self.stopMeasuring()
    }
  }

  func testCreationPerformanceString() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      let dataSets = [largeStrings0, largeStrings1, largeStrings2, largeStrings3,
                      largeStrings4, largeStrings5, largeStrings6, largeStrings7,
                      largeStrings8, largeStrings9]
      self.startMeasuring()
      for dataSet in dataSets { _ = MoonKit.OrderedSet(dataSet) }
      self.stopMeasuring()
    }
  }

  func testInsertionPerformanceString() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var set = OrderedSetPerformanceTests.emptyStringSet
      let strings = largeStrings0
      self.startMeasuring()
      for string in strings { set.insert(string) }
      self.stopMeasuring()
    }
  }

  func testRemovePerformanceString() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var set = OrderedSetPerformanceTests.loadedStringSet
      let strings = largeStrings0
      self.startMeasuring()
      for string in strings { set.remove(string) }
      self.stopMeasuring()
    }
  }

  func testRemoveAtPerformanceString() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var set = OrderedSetPerformanceTests.loadedStringSet
      self.startMeasuring()
      while !set.isEmpty { set.remove(at: Int(arc4random_uniform(numericCast(set.count)))) }
      self.stopMeasuring()
    }
  }

  func testUnionPerformanceString() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var set = OrderedSetPerformanceTests.loadedStringSet
      let strings = largeStrings1
      self.startMeasuring()
      set.formUnion(strings)
      self.stopMeasuring()
    }
  }

  func testIntersectionPerformanceString() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var set = OrderedSetPerformanceTests.loadedStringSet
      let strings = largeStrings1
      self.startMeasuring()
      set.formIntersection(strings)
      self.stopMeasuring()
    }
  }

  func testSubtractPerformanceString() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var set = OrderedSetPerformanceTests.loadedStringSet
      let strings = largeStrings1
      self.startMeasuring()
      set.subtract(strings)
      self.stopMeasuring()
    }
  }

  func testSymmetricDifferencePerformanceString() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var set = OrderedSetPerformanceTests.loadedStringSet
      let strings = largeStrings1
      self.startMeasuring()
      set.formSymmetricDifference(strings)
      self.stopMeasuring()
    }
  }

  func testOverallPerformanceString() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var set = OrderedSetPerformanceTests.emptyStringSet
      let dataSet0 = largeStrings0, dataSet1 = largeStrings1, dataSet2 = largeStrings2, dataSet3 = largeStrings3
      self.startMeasuring()
      for string in dataSet0 { set.insert(string) }
      for string in dataSet1 { set.remove(string) }
      set.formUnion(dataSet1)
      set.subtract(dataSet0)
      set.formSymmetricDifference(dataSet2)
      set.formIntersection(dataSet3)
      self.stopMeasuring()
    }
  }

  func testSubsetOfPerformanceString() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      let set = OrderedSetPerformanceTests.loadedStringSubset
      let dataSets = [largeStrings0, largeStrings1, largeStrings2, largeStrings3,
                      largeStrings4, largeStrings5, largeStrings6, largeStrings7,
                      largeStrings8, largeStrings9]
      self.startMeasuring()
      for other in dataSets { _ = set.isSubset(of: other) }
      self.stopMeasuring()
    }
  }

  func testStrictSubsetOfPerformanceString() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      let set = OrderedSetPerformanceTests.loadedStringSubset
      let dataSets = [largeStrings0, largeStrings1, largeStrings2, largeStrings3,
                      largeStrings4, largeStrings5, largeStrings6, largeStrings7,
                      largeStrings8, largeStrings9]
      self.startMeasuring()
      for other in dataSets { _ = set.isStrictSubset(of: other) }
      self.stopMeasuring()
    }
  }

  func testSupersetOfPerformanceString() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      let set = OrderedSetPerformanceTests.loadedStringSet
      let dataSets = [largeSubStrings0, largeSubStrings1, largeSubStrings2,
                      largeSubStrings3, largeSubStrings4, largeSubStrings5,
                      largeSubStrings6, largeSubStrings7, largeSubStrings8, largeSubStrings9]
      self.startMeasuring()
      for other in dataSets { _ = set.isSuperset(of: other) }
      self.stopMeasuring()
    }
  }

  func testStrictSupersetOfPerformanceString() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      let set = OrderedSetPerformanceTests.loadedStringSet
      let dataSets = [largeSubStrings0, largeSubStrings1, largeSubStrings2, largeSubStrings3, largeSubStrings4,
                      largeSubStrings5, largeSubStrings6, largeSubStrings7, largeSubStrings8, largeSubStrings9]
      self.startMeasuring()
      for other in dataSets { _ = set.isStrictSuperset(of: other) }
      self.stopMeasuring()
    }
  }

  func testDisjointWithPerformanceString() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      let set = OrderedSetPerformanceTests.loadedStringSubset
      let evenSet = OrderedSetPerformanceTests.evenStringSet
      let oddSet = OrderedSetPerformanceTests.oddStringSet
      let dataSets = [largeSubStrings0, largeSubStrings1, largeSubStrings2, largeSubStrings3, largeSubStrings4,
                      largeSubStrings5, largeSubStrings6, largeSubStrings7, largeSubStrings8, largeSubStrings9]
      self.startMeasuring()
      for other in dataSets { _ = set.isDisjoint(with: other) }
      _ = evenSet.isDisjoint(with: oddSet)
      _ = oddSet.isDisjoint(with: evenSet)
      _ = evenSet.isDisjoint(with: largeOddStrings)
      _ = oddSet.isDisjoint(with: largeEvenStrings)
      self.stopMeasuring()
    }
  }

  func testReplaceRangePerformanceString() {
    var count = OrderedSetPerformanceTests.loadedStringSet.count
    var ranges: [(remove: CountableRange<Int>, insert: CountableRange<Int>)] = []
    ranges.reserveCapacity(1000)
    let coverage = 0.00025

    for _ in 0 ..< 1000 {
      let removeRange = randomRange(indices: 0 ..< count, coverage: coverage)
      let insertRange = randomRange(indices: largeStrings1.indices, coverage: coverage)
      ranges.append((removeRange, insertRange))
      count = count - removeRange.count + insertRange.count
      guard count > 0 else { break }
    }

    let strings = largeStrings1
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var set = OrderedSetPerformanceTests.loadedStringSet
      self.startMeasuring()
      for (removeRange, insertRange) in ranges {
        set.replaceSubrange(removeRange, with: strings[insertRange])
      }
      self.stopMeasuring()
    }
  }
}

