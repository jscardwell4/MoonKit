//
//  OrderedDictionaryPerformanceTests.swift
//  MoonKit
//
//  Created by Jason Cardwell on 5/24/16.
//  Copyright © 2016 Jason Cardwell. All rights reserved.
//
import XCTest
@testable import MoonKit


final class OrderedDictionaryPerformanceTests: XCTestCase {

  static let emptyDictionaryStringInt = OrderedDictionary<String, Int>()
  static let emptyDictionaryStringString = OrderedDictionary<String, String>()
  static let emptyDictionaryIntInt = OrderedDictionary<Int, Int>()

  static let loadedDictionaryStringInt = OrderedDictionary<String, Int>(largeStringsIntegers0)
  static let loadedDictionaryStringString = OrderedDictionary<String, String>(largeStringsStrings0)
  static let loadedDictionaryIntInt = OrderedDictionary<Int, Int>(largeIntegersIntegers0)

  func testSubscriptKeyPerformanceStringInt() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      let stringsIntegers = largeStringsIntegers0
      let dictionary = OrderedDictionaryPerformanceTests.loadedDictionaryStringInt
      self.startMeasuring()
      for (key, _) in stringsIntegers { _ = dictionary[key] }
      self.stopMeasuring()
    }
  }

  func testSubscriptIndexPerformanceStringInt() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      let dictionary = OrderedDictionaryPerformanceTests.loadedDictionaryStringInt
      self.startMeasuring()
      var index = dictionary.startIndex
      while index < dictionary.endIndex {
        _ = dictionary[index]
        dictionary.formIndex(after: &index)
      }
      self.stopMeasuring()
    }
  }

  func testIndexForKeyPerformanceStringInt() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      let stringsIntegers = largeStringsIntegers0
      let dictionary = OrderedDictionaryPerformanceTests.loadedDictionaryStringInt
      self.startMeasuring()
      for (key, _) in stringsIntegers { _ = dictionary.index(forKey: key) }
      self.stopMeasuring()
    }
  }

  func testValueForKeyPerformanceStringInt() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      let stringsIntegers = largeStringsIntegers0
      let dictionary = OrderedDictionaryPerformanceTests.loadedDictionaryStringInt
      self.startMeasuring()
      for (key, _) in stringsIntegers { _ = dictionary.value(forKey: key) }
      self.stopMeasuring()
    }
  }

  func testCreationPerformanceStringInt() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      let dataSets = [largeStringsIntegers0, largeStringsIntegers1, largeStringsIntegers2, largeStringsIntegers3, largeStringsIntegers4,
                      largeStringsIntegers5, largeStringsIntegers6, largeStringsIntegers7, largeStringsIntegers8, largeStringsIntegers9]
      self.startMeasuring()
      for dataSet in dataSets { _ = OrderedDictionary(dataSet) }
      self.stopMeasuring()
    }
  }

  func testInsertValueForKeyPerformanceStringInt() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var dictionary = OrderedDictionaryPerformanceTests.emptyDictionaryStringInt
      let stringsIntegers = largeStringsIntegers0
      self.startMeasuring()
      for (key: key, value: value) in stringsIntegers { dictionary.insert(value: value, forKey: key) }
      self.stopMeasuring()
    }
  }

  func testRemoveAtIndexPerformanceStringInt() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var dictionary = OrderedDictionaryPerformanceTests.loadedDictionaryStringInt
      self.startMeasuring()
      while dictionary.startIndex != dictionary.endIndex {
        dictionary.remove(at: dictionary.startIndex)
      }
      self.stopMeasuring()
    }
  }

  func testRemoveValueForKeyPerformanceStringInt() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var dictionary = OrderedDictionaryPerformanceTests.loadedDictionaryStringInt
      let stringsIntegers = largeStringsIntegers0
      self.startMeasuring()
      for (key, _) in stringsIntegers { dictionary.removeValue(forKey: key) }
      self.stopMeasuring()
    }
  }

  func testUpdateValueForKeyPerformanceStringInt() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var dictionary = OrderedDictionaryPerformanceTests.loadedDictionaryStringInt
      let stringsIntegers = largeStringsIntegers1
      self.startMeasuring()
      for (key, value) in stringsIntegers { dictionary.updateValue(value, forKey: key) }
      self.stopMeasuring()
    }
  }

  func testOverallPerformanceStringInt() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var dictionary = OrderedDictionaryPerformanceTests.emptyDictionaryStringInt
      let dataSet0 = largeStringsIntegers0, dataSet1 = largeStringsIntegers1, dataSet2 = largeStringsIntegers2
      self.startMeasuring()
      for (key, value) in dataSet0 { dictionary[key] = value }
      for (key, _) in dataSet1 { dictionary[key] = nil }
      for (key, value) in dataSet2 { dictionary[key] = value }
      self.stopMeasuring()
    }
  }

  func testReplaceRangePerformanceStringInt() {
    var count = OrderedDictionaryPerformanceTests.loadedDictionaryStringInt.count
    var ranges: [(remove: Range<Int>, insert: Range<Int>)] = []
    ranges.reserveCapacity(1000)
    let coverage = 0.00025
    srandom(0)
    for _ in 0 ..< 1000 {
      let removeRange = randomRange(indices: 0 ..< count, coverage: coverage)
      let insertRange = randomRange(indices: largeStringsIntegers1.indices, coverage: coverage)
      ranges.append((removeRange, insertRange))
      count = count - removeRange.count + insertRange.count
      guard count > 0 else { break }
    }

    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var dictionary = OrderedDictionaryPerformanceTests.loadedDictionaryStringInt
      let stringsIntegers = largeStringsIntegers1
      self.startMeasuring()
      for (removeRange, insertRange) in ranges {
        dictionary.replaceSubrange(removeRange, with: stringsIntegers[insertRange])
      }
      self.stopMeasuring()
    }
  }

  func testSubscriptKeyPerformanceStringString() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      let stringsStrings = largeStringsStrings0
      let dictionary = OrderedDictionaryPerformanceTests.loadedDictionaryStringString
      self.startMeasuring()
      for (key, _) in stringsStrings { _ = dictionary[key] }
      self.stopMeasuring()
    }
  }

  func testSubscriptIndexPerformanceStringString() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      let dictionary = OrderedDictionaryPerformanceTests.loadedDictionaryStringString
      self.startMeasuring()
      var index = dictionary.startIndex
      while index < dictionary.endIndex {
        _ = dictionary[index]
        dictionary.formIndex(after: &index)
      }
      self.stopMeasuring()
    }
  }

  func testIndexForKeyPerformanceStringString() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      let stringsStrings = largeStringsStrings0
      let dictionary = OrderedDictionaryPerformanceTests.loadedDictionaryStringString
      self.startMeasuring()
      for (key, _) in stringsStrings { _ = dictionary.index(forKey: key) }
      self.stopMeasuring()
    }
  }

  func testValueForKeyPerformanceStringString() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      let stringsStrings = largeStringsStrings0
      let dictionary = OrderedDictionaryPerformanceTests.loadedDictionaryStringString
      self.startMeasuring()
      for (key, _) in stringsStrings { _ = dictionary.value(forKey: key) }
      self.stopMeasuring()
    }
  }

  func testCreationPerformanceStringString() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      let dataSets = [largeStringsStrings0, largeStringsStrings1, largeStringsStrings2, largeStringsStrings3, largeStringsStrings4,
                      largeStringsStrings5, largeStringsStrings6, largeStringsStrings7, largeStringsStrings8, largeStringsStrings9]
      self.startMeasuring()
      for dataSet in dataSets { _ = OrderedDictionary(dataSet) }
      self.stopMeasuring()
    }
  }

  func testInsertValueForKeyPerformanceStringString() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var dictionary = OrderedDictionaryPerformanceTests.emptyDictionaryStringString
      let stringsStrings = largeStringsStrings0
      self.startMeasuring()
      for (key: key, value: value) in stringsStrings { dictionary.insert(value: value, forKey: key) }
      self.stopMeasuring()
    }
  }

  func testRemoveAtIndexPerformanceStringString() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var dictionary = OrderedDictionaryPerformanceTests.loadedDictionaryStringString
      self.startMeasuring()
      while dictionary.startIndex != dictionary.endIndex {
        dictionary.remove(at: dictionary.startIndex)
      }
      self.stopMeasuring()
    }
  }

  func testRemoveValueForKeyPerformanceStringString() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var dictionary = OrderedDictionaryPerformanceTests.loadedDictionaryStringString
      let stringsStrings = largeStringsStrings0
      self.startMeasuring()
      for (key, _) in stringsStrings { dictionary.removeValue(forKey: key) }
      self.stopMeasuring()
    }
  }

  func testUpdateValueForKeyPerformanceStringString() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var dictionary = OrderedDictionaryPerformanceTests.loadedDictionaryStringString
      let stringsStrings = largeStringsStrings1
      self.startMeasuring()
      for (key, value) in stringsStrings { dictionary.updateValue(value, forKey: key) }
      self.stopMeasuring()
    }
  }

  func testOverallPerformanceStringString() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var dictionary = OrderedDictionaryPerformanceTests.emptyDictionaryStringString
      let dataSet0 = largeStringsStrings0, dataSet1 = largeStringsStrings1, dataSet2 = largeStringsStrings2
      self.startMeasuring()
      for (key, value) in dataSet0 { dictionary[key] = value }
      for (key, _) in dataSet1 { dictionary[key] = nil }
      for (key, value) in dataSet2 { dictionary[key] = value }
      self.stopMeasuring()
    }
  }

  func testReplaceRangePerformanceStringString() {
    var count = OrderedDictionaryPerformanceTests.loadedDictionaryStringString.count
    var ranges: [(remove: CountableRange<Int>, insert: CountableRange<Int>)] = []
    ranges.reserveCapacity(1000)
    let coverage = 0.00025
    srandom(0)
    for _ in 0 ..< 1000 {
      let removeRange = randomRange(indices: 0 ..< count, coverage: coverage)
      let insertRange = randomRange(indices: largeStringsStrings1.indices, coverage: coverage)
      ranges.append((removeRange, insertRange))
      count = count - removeRange.count + insertRange.count
      guard count > 0 else { break }
    }

    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var dictionary = OrderedDictionaryPerformanceTests.loadedDictionaryStringString
      let stringsStrings = largeStringsStrings1
      self.startMeasuring()
      for (removeRange, insertRange) in ranges {
        dictionary.replaceSubrange(removeRange, with: stringsStrings[insertRange])
      }
      self.stopMeasuring()
    }
  }

  func testSubscriptKeyPerformanceIntInt() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      let integersIntegers = largeIntegersIntegers0
      let dictionary = OrderedDictionaryPerformanceTests.loadedDictionaryIntInt
      self.startMeasuring()
      for (key, _) in integersIntegers { _ = dictionary[key: key] }
      self.stopMeasuring()
    }
  }

  func testSubscriptIndexPerformanceIntInt() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      let dictionary = OrderedDictionaryPerformanceTests.loadedDictionaryIntInt
      self.startMeasuring()
      var index = dictionary.startIndex
      while index < dictionary.endIndex {
        _ = dictionary[index: index]
        dictionary.formIndex(after: &index)
      }
      self.stopMeasuring()
    }
  }

  func testIndexForKeyPerformanceIntInt() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      let integersIntegers = largeIntegersIntegers0
      let dictionary = OrderedDictionaryPerformanceTests.loadedDictionaryIntInt
      self.startMeasuring()
      for (key, _) in integersIntegers { _ = dictionary.index(forKey: key) }
      self.stopMeasuring()
    }
  }

  func testValueForKeyPerformanceIntInt() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      let integersIntegers = largeIntegersIntegers0
      let dictionary = OrderedDictionaryPerformanceTests.loadedDictionaryIntInt
      self.startMeasuring()
      for (key, _) in integersIntegers { _ = dictionary.value(forKey: key) }
      self.stopMeasuring()
    }
  }

  func testCreationPerformanceIntInt() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      let dataSets = [largeIntegersIntegers0, largeIntegersIntegers1, largeIntegersIntegers2, largeIntegersIntegers3, largeIntegersIntegers4,
                      largeIntegersIntegers5, largeIntegersIntegers6, largeIntegersIntegers7, largeIntegersIntegers8, largeIntegersIntegers9]
      self.startMeasuring()
      for dataSet in dataSets { _ = OrderedDictionary(dataSet) }
      self.stopMeasuring()
    }
  }

  func testInsertValueForKeyPerformanceIntInt() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var dictionary = OrderedDictionaryPerformanceTests.emptyDictionaryIntInt
      let integersIntegers = largeIntegersIntegers0
      self.startMeasuring()
      for (key: key, value: value) in integersIntegers { dictionary.insert(value: value, forKey: key) }
      self.stopMeasuring()
    }
  }

  func testRemoveAtIndexPerformanceIntInt() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var dictionary = OrderedDictionaryPerformanceTests.loadedDictionaryIntInt
      self.startMeasuring()
      while dictionary.startIndex != dictionary.endIndex {
        dictionary.remove(at: dictionary.startIndex)
      }
      self.stopMeasuring()
    }
  }

  func testRemoveValueForKeyPerformanceIntInt() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var dictionary = OrderedDictionaryPerformanceTests.loadedDictionaryIntInt
      let integersIntegers = largeIntegersIntegers0
      self.startMeasuring()
      for (key, _) in integersIntegers { dictionary.removeValue(forKey: key) }
      self.stopMeasuring()
    }
  }

  func testUpdateValueForKeyPerformanceIntInt() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var dictionary = OrderedDictionaryPerformanceTests.loadedDictionaryIntInt
      let integersIntegers = largeIntegersIntegers1
      self.startMeasuring()
      for (key, value) in integersIntegers { dictionary.updateValue(value, forKey: key) }
      self.stopMeasuring()
    }
  }

  func testOverallPerformanceIntInt() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var dictionary = OrderedDictionaryPerformanceTests.emptyDictionaryIntInt
      let dataSet0 = largeIntegersIntegers0, dataSet1 = largeIntegersIntegers1, dataSet2 = largeIntegersIntegers2
      self.startMeasuring()
      for (key, value) in dataSet0 { dictionary[key] = value }
      for (key, _) in dataSet1 { dictionary[key] = nil }
      for (key, value) in dataSet2 { dictionary[key] = value }
      self.stopMeasuring()
    }
  }

  func testReplaceRangePerformanceIntInt() {
    var count = OrderedDictionaryPerformanceTests.loadedDictionaryIntInt.count
    var ranges: [(remove: CountableRange<Int>, insert: CountableRange<Int>)] = []
    ranges.reserveCapacity(1000)
    let coverage = 0.00025
    srandom(0)
    for _ in 0 ..< 1000 {
      let removeRange = randomRange(indices: 0 ..< count, coverage: coverage)
      let insertRange = randomRange(indices: largeIntegersIntegers1.indices, coverage: coverage)
      ranges.append((removeRange, insertRange))
      count = count - removeRange.count + insertRange.count
      guard count > 0 else { break }
    }

    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var dictionary = OrderedDictionaryPerformanceTests.loadedDictionaryIntInt
      let integersIntegers = largeIntegersIntegers1
      self.startMeasuring()
      for (removeRange, insertRange) in ranges {
        dictionary.replaceSubrange(removeRange, with: integersIntegers[insertRange])
      }
      self.stopMeasuring()
    }
  }
 
}

