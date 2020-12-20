//
//  NativeSetPerformanceTests.swift
//  MoonKitTests
//
//  Created by Jason Cardwell on 12/20/20.
//  Copyright © 2020 Moondeer Studios. All rights reserved.
//
@testable import MoonKit
import XCTest

// MARK: - NativeSetPerformanceTests

final class NativeSetPerformanceTests: XCTestCase {
  static let emptyIntegerSet: Set<Int> = []
  static let loadedIntegerSet = Set(largeIntegers0)
  static let loadedIntegerSubset = Set(largeSubIntegers0)
  static let evenIntegerSet = Set(largeEvenIntegers)
  static let oddIntegerSet = Set(largeOddIntegers)

  static let emptyStringSet: Set<String> = []
  static let loadedStringSet = Set(largeStrings0)
  static let loadedStringSubset = Set(largeSubStrings0)
  static let evenStringSet = Set(largeEvenStrings)
  static let oddStringSet = Set(largeOddStrings)

  func testCreationPerformanceInt() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      let dataSets = [largeIntegers0, largeIntegers1, largeIntegers2, largeIntegers3, largeIntegers4,
                      largeIntegers5, largeIntegers6, largeIntegers7, largeIntegers8, largeIntegers9]
      self.startMeasuring()
      for dataSet in dataSets { _ = Set(dataSet) }
      self.stopMeasuring()
    }
  }

  func testInsertionPerformanceInt() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var set = NativeSetPerformanceTests.emptyIntegerSet
      let integers = largeIntegers0
      self.startMeasuring()
      for integer in integers { set.insert(integer) }
      self.stopMeasuring()
    }
  }

  func testRemovePerformanceInt() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var set = NativeSetPerformanceTests.loadedIntegerSet
      let integers = largeIntegers0
      self.startMeasuring()
      for integer in integers { set.remove(integer) }
      self.stopMeasuring()
    }
  }

  func testRemoveAtPerformanceInt() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var set = NativeSetPerformanceTests.loadedIntegerSet
      self.startMeasuring()
      while !set.isEmpty {
        set.remove(at: set.index(set.startIndex, offsetBy: Int(arc4random_uniform(numericCast(set.count)))))
      }
      self.stopMeasuring()
    }
  }

  func testUnionPerformanceInt() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var set = NativeSetPerformanceTests.loadedIntegerSet
      let integers = largeIntegers1
      self.startMeasuring()
      set.formUnion(integers)
      self.stopMeasuring()
    }
  }

  func testIntersectionPerformanceInt() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var set = NativeSetPerformanceTests.loadedIntegerSet
      let integers = largeIntegers1
      self.startMeasuring()
      set.formIntersection(integers)
      self.stopMeasuring()
    }
  }

  func testSubtractPerformanceInt() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var set = NativeSetPerformanceTests.loadedIntegerSet
      let integers = largeIntegers1
      self.startMeasuring()
      set.subtract(integers)
      self.stopMeasuring()
    }
  }

  func testSymmetricDifferencePerformanceInt() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var set = NativeSetPerformanceTests.loadedIntegerSet
      let integers = largeIntegers1
      self.startMeasuring()
      set.formSymmetricDifference(integers)
      self.stopMeasuring()
    }
  }

  func testOverallPerformanceInt() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var set = NativeSetPerformanceTests.emptyIntegerSet
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
      let set = NativeSetPerformanceTests.loadedIntegerSubset
      let dataSets = [largeIntegers0, largeIntegers1, largeIntegers2, largeIntegers3, largeIntegers4,
                      largeIntegers5, largeIntegers6, largeIntegers7, largeIntegers8, largeIntegers9]
      self.startMeasuring()
      for other in dataSets { _ = set.isSubset(of: other) }
      self.stopMeasuring()
    }
  }

  func testStrictSubsetOfPerformanceInt() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      let set = NativeSetPerformanceTests.loadedIntegerSubset
      let dataSets = [largeIntegers0, largeIntegers1, largeIntegers2, largeIntegers3, largeIntegers4,
                      largeIntegers5, largeIntegers6, largeIntegers7, largeIntegers8, largeIntegers9]
      self.startMeasuring()
      for other in dataSets { _ = set.isStrictSubset(of: other) }
      self.stopMeasuring()
    }
  }

  func testSupersetOfPerformanceInt() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      let set = NativeSetPerformanceTests.loadedIntegerSet
      let dataSets = [largeSubIntegers0, largeSubIntegers1, largeSubIntegers2, largeSubIntegers3, largeSubIntegers4,
                      largeSubIntegers5, largeSubIntegers6, largeSubIntegers7, largeSubIntegers8, largeSubIntegers9]
      self.startMeasuring()
      for other in dataSets { _ = set.isSuperset(of: other) }
      self.stopMeasuring()
    }
  }

  func testStrictSupersetOfPerformanceInt() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      let set = NativeSetPerformanceTests.loadedIntegerSet
      let dataSets = [largeSubIntegers0, largeSubIntegers1, largeSubIntegers2, largeSubIntegers3, largeSubIntegers4,
                      largeSubIntegers5, largeSubIntegers6, largeSubIntegers7, largeSubIntegers8, largeSubIntegers9]
      self.startMeasuring()
      for other in dataSets { _ = set.isStrictSuperset(of: other) }
      self.stopMeasuring()
    }
  }

  func testDisjointWithPerformanceInt() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      let set = NativeSetPerformanceTests.loadedIntegerSubset
      let evenSet = NativeSetPerformanceTests.evenIntegerSet
      let oddSet = NativeSetPerformanceTests.oddIntegerSet
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

  func testCreationPerformanceString() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      let dataSets = [largeStrings0, largeStrings1, largeStrings2, largeStrings3, largeStrings4,
                      largeStrings5, largeStrings6, largeStrings7, largeStrings8, largeStrings9]
      self.startMeasuring()
      for dataSet in dataSets { _ = Set(dataSet) }
      self.stopMeasuring()
    }
  }

  func testInsertionPerformanceString() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var set = NativeSetPerformanceTests.emptyStringSet
      let strings = largeStrings0
      self.startMeasuring()
      for string in strings { set.insert(string) }
      self.stopMeasuring()
    }
  }

  func testRemovePerformanceString() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var set = NativeSetPerformanceTests.loadedStringSet
      let strings = largeStrings0
      self.startMeasuring()
      for string in strings { set.remove(string) }
      self.stopMeasuring()
    }
  }

  func testRemoveAtPerformanceString() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var set = NativeSetPerformanceTests.loadedStringSet
      self.startMeasuring()
      while !set.isEmpty {
        set.remove(at: set.index(set.startIndex, offsetBy: Int(arc4random_uniform(numericCast(set.count)))))
      }
      self.stopMeasuring()
    }
  }

  func testUnionPerformanceString() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var set = NativeSetPerformanceTests.loadedStringSet
      let strings = largeStrings1
      self.startMeasuring()
      set.formUnion(strings)
      self.stopMeasuring()
    }
  }

  func testIntersectionPerformanceString() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var set = NativeSetPerformanceTests.loadedStringSet
      let strings = largeStrings1
      self.startMeasuring()
      set.formIntersection(strings)
      self.stopMeasuring()
    }
  }

  func testSubtractPerformanceString() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var set = NativeSetPerformanceTests.loadedStringSet
      let strings = largeStrings1
      self.startMeasuring()
      set.subtract(strings)
      self.stopMeasuring()
    }
  }

  func testSymmetricDifferencePerformanceString() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var set = NativeSetPerformanceTests.loadedStringSet
      let strings = largeStrings1
      self.startMeasuring()
      set.formSymmetricDifference(strings)
      self.stopMeasuring()
    }
  }

  func testOverallPerformanceString() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var set = NativeSetPerformanceTests.emptyStringSet
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
      let set = NativeSetPerformanceTests.loadedStringSubset
      let dataSets = [largeStrings0, largeStrings1, largeStrings2, largeStrings3, largeStrings4,
                      largeStrings5, largeStrings6, largeStrings7, largeStrings8, largeStrings9]
      self.startMeasuring()
      for other in dataSets { _ = set.isSubset(of: other) }
      self.stopMeasuring()
    }
  }

  func testStrictSubsetOfPerformanceString() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      let set = NativeSetPerformanceTests.loadedStringSubset
      let dataSets = [largeStrings0, largeStrings1, largeStrings2, largeStrings3, largeStrings4,
                      largeStrings5, largeStrings6, largeStrings7, largeStrings8, largeStrings9]
      self.startMeasuring()
      for other in dataSets { _ = set.isStrictSubset(of: other) }
      self.stopMeasuring()
    }
  }

  func testSupersetOfPerformanceString() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      let set = NativeSetPerformanceTests.loadedStringSet
      let dataSets = [largeSubStrings0, largeSubStrings1, largeSubStrings2, largeSubStrings3, largeSubStrings4,
                      largeSubStrings5, largeSubStrings6, largeSubStrings7, largeSubStrings8, largeSubStrings9]
      self.startMeasuring()
      for other in dataSets { _ = set.isSuperset(of: other) }
      self.stopMeasuring()
    }
  }

  func testStrictSupersetOfPerformanceString() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      let set = NativeSetPerformanceTests.loadedStringSet
      let dataSets = [largeSubStrings0, largeSubStrings1, largeSubStrings2, largeSubStrings3, largeSubStrings4,
                      largeSubStrings5, largeSubStrings6, largeSubStrings7, largeSubStrings8, largeSubStrings9]
      self.startMeasuring()
      for other in dataSets { _ = set.isStrictSuperset(of: other) }
      self.stopMeasuring()
    }
  }

  func testDisjointWithPerformanceString() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      let set = NativeSetPerformanceTests.loadedStringSubset
      let evenSet = NativeSetPerformanceTests.evenStringSet
      let oddSet = NativeSetPerformanceTests.oddStringSet
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
}
