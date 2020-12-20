//
//  NativeDictionaryPerformanceTests.swift
//  MoonKitTests
//
//  Created by Jason Cardwell on 12/20/20.
//  Copyright © 2020 Moondeer Studios. All rights reserved.
//
import XCTest
@testable import MoonKit

final class NativeDictionaryPerformanceTests: XCTestCase {
  static let emptyDictionaryStringInt = Dictionary<String, Int>()
  static let emptyDictionaryStringString = Dictionary<String, String>()
  static let emptyDictionaryIntInt = Dictionary<Int, Int>()

  static let loadedDictionaryStringInt = Dictionary<String, Int>(largeStringsIntegers0)
  static let loadedDictionaryStringString = Dictionary<String, String>(largeStringsStrings0)
  static let loadedDictionaryIntInt = Dictionary<Int, Int>(largeIntegersIntegers0)

 func testSubscriptKeyPerformanceStringInt() {
  measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      let stringsIntegers = largeStringsIntegers0
      let dictionary = NativeDictionaryPerformanceTests.loadedDictionaryStringInt
      self.startMeasuring()
      for (key, _) in stringsIntegers { _ = dictionary[key] }
      self.stopMeasuring()
    }
  }

  func testSubscriptIndexPerformanceStringInt() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      let dictionary = NativeDictionaryPerformanceTests.loadedDictionaryStringInt
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
      let dictionary = NativeDictionaryPerformanceTests.loadedDictionaryStringInt
      self.startMeasuring()
      for (key, _) in stringsIntegers { _ = dictionary.index(forKey: key) }
      self.stopMeasuring()
    }
  }

  func testValueForKeyPerformanceStringInt() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      let stringsIntegers = largeStringsIntegers0
      let dictionary = NativeDictionaryPerformanceTests.loadedDictionaryStringInt
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
      for dataSet in dataSets { _ = Dictionary(dataSet) }
      self.stopMeasuring()
    }
  }

  func testInsertValueForKeyPerformanceStringInt() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var dictionary = NativeDictionaryPerformanceTests.emptyDictionaryStringInt
      let stringsIntegers = largeStringsIntegers0
      self.startMeasuring()
      for (key: key, value: value) in stringsIntegers { dictionary.insert(value: value, forKey: key) }
      self.stopMeasuring()
    }
  }

  func testRemoveAtIndexPerformanceStringInt() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var dictionary = NativeDictionaryPerformanceTests.loadedDictionaryStringInt
      self.startMeasuring()
      while dictionary.startIndex != dictionary.endIndex {
        dictionary.remove(at: dictionary.startIndex)
      }
      self.stopMeasuring()
    }
  }

  func testRemoveValueForKeyPerformanceStringInt() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var dictionary = NativeDictionaryPerformanceTests.loadedDictionaryStringInt
      let stringsIntegers = largeStringsIntegers0
      self.startMeasuring()
      for (key, _) in stringsIntegers { dictionary.removeValue(forKey: key) }
      self.stopMeasuring()
    }
  }

  func testUpdateValueForKeyPerformanceStringInt() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var dictionary = NativeDictionaryPerformanceTests.loadedDictionaryStringInt
      let stringsIntegers = largeStringsIntegers1
      self.startMeasuring()
      for (key, value) in stringsIntegers { dictionary.updateValue(value, forKey: key) }
      self.stopMeasuring()
    }
  }

  func testOverallPerformanceStringInt() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var dictionary = NativeDictionaryPerformanceTests.emptyDictionaryStringInt
      let dataSet0 = largeStringsIntegers0, dataSet1 = largeStringsIntegers1, dataSet2 = largeStringsIntegers2
      self.startMeasuring()
      for (key, value) in dataSet0 { dictionary[key] = value }
      for (key, _) in dataSet1 { dictionary[key] = nil }
      for (key, value) in dataSet2 { dictionary[key] = value }
      self.stopMeasuring()
    }
  }

  func testSubscriptKeyPerformanceStringString() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      let stringsStrings = largeStringsStrings0
      let dictionary = NativeDictionaryPerformanceTests.loadedDictionaryStringString
      self.startMeasuring()
      for (key, _) in stringsStrings { _ = dictionary[key] }
      self.stopMeasuring()
    }
  }

  func testSubscriptIndexPerformanceStringString() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      let dictionary = NativeDictionaryPerformanceTests.loadedDictionaryStringString
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
      let dictionary = NativeDictionaryPerformanceTests.loadedDictionaryStringString
      self.startMeasuring()
      for (key, _) in stringsStrings { _ = dictionary.index(forKey: key) }
      self.stopMeasuring()
    }
  }

  func testValueForKeyPerformanceStringString() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      let stringsStrings = largeStringsStrings0
      let dictionary = NativeDictionaryPerformanceTests.loadedDictionaryStringString
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
      for dataSet in dataSets { _ = Dictionary(dataSet) }
      self.stopMeasuring()
    }
  }

  func testInsertValueForKeyPerformanceStringString() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var dictionary = NativeDictionaryPerformanceTests.emptyDictionaryStringString
      let stringsStrings = largeStringsStrings0
      self.startMeasuring()
      for (key: key, value: value) in stringsStrings { dictionary.insert(value: value, forKey: key) }
      self.stopMeasuring()
    }
  }

  func testRemoveAtIndexPerformanceStringString() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var dictionary = NativeDictionaryPerformanceTests.loadedDictionaryStringString
      self.startMeasuring()
      while dictionary.startIndex != dictionary.endIndex {
        dictionary.remove(at: dictionary.startIndex)
      }
      self.stopMeasuring()
    }
  }

  func testRemoveValueForKeyPerformanceStringString() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var dictionary = NativeDictionaryPerformanceTests.loadedDictionaryStringString
      let stringsStrings = largeStringsStrings0
      self.startMeasuring()
      for (key, _) in stringsStrings { dictionary.removeValue(forKey: key) }
      self.stopMeasuring()
    }
  }

  func testUpdateValueForKeyPerformanceStringString() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var dictionary = NativeDictionaryPerformanceTests.loadedDictionaryStringString
      let stringsStrings = largeStringsStrings1
      self.startMeasuring()
      for (key, value) in stringsStrings { dictionary.updateValue(value, forKey: key) }
      self.stopMeasuring()
    }
  }

  func testOverallPerformanceStringString() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var dictionary = NativeDictionaryPerformanceTests.emptyDictionaryStringString
      let dataSet0 = largeStringsStrings0, dataSet1 = largeStringsStrings1, dataSet2 = largeStringsStrings2
      self.startMeasuring()
      for (key, value) in dataSet0 { dictionary[key] = value }
      for (key, _) in dataSet1 { dictionary[key] = nil }
      for (key, value) in dataSet2 { dictionary[key] = value }
      self.stopMeasuring()
    }
  }

  func testSubscriptKeyPerformanceIntInt() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      let integersIntegers = largeIntegersIntegers0
      let dictionary = NativeDictionaryPerformanceTests.loadedDictionaryIntInt
      self.startMeasuring()
      for (key, _) in integersIntegers { _ = dictionary[key] }
      self.stopMeasuring()
    }
  }

  func testSubscriptIndexPerformanceIntInt() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      let dictionary = NativeDictionaryPerformanceTests.loadedDictionaryIntInt
      self.startMeasuring()
      var index = dictionary.startIndex
      while index < dictionary.endIndex {
        _ = dictionary[index]
        dictionary.formIndex(after: &index)
      }
      self.stopMeasuring()
    }
  }

  func testIndexForKeyPerformanceIntInt() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      let integersIntegers = largeIntegersIntegers0
      let dictionary = NativeDictionaryPerformanceTests.loadedDictionaryIntInt
      self.startMeasuring()
      for (key, _) in integersIntegers { _ = dictionary.index(forKey: key) }
      self.stopMeasuring()
    }
  }

  func testValueForKeyPerformanceIntInt() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      let integersIntegers = largeIntegersIntegers0
      let dictionary = NativeDictionaryPerformanceTests.loadedDictionaryIntInt
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
      for dataSet in dataSets { _ = Dictionary(dataSet) }
      self.stopMeasuring()
    }
  }

  func testInsertValueForKeyPerformanceIntInt() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var dictionary = NativeDictionaryPerformanceTests.emptyDictionaryIntInt
      let integersIntegers = largeIntegersIntegers0
      self.startMeasuring()
      for (key: key, value: value) in integersIntegers { dictionary.insert(value: value, forKey: key) }
      self.stopMeasuring()
    }
  }

  func testRemoveAtIndexPerformanceIntInt() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var dictionary = NativeDictionaryPerformanceTests.loadedDictionaryIntInt
      self.startMeasuring()
      while dictionary.startIndex != dictionary.endIndex {
        dictionary.remove(at: dictionary.startIndex)
      }
      self.stopMeasuring()
    }
  }

  func testRemoveValueForKeyPerformanceIntInt() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var dictionary = NativeDictionaryPerformanceTests.loadedDictionaryIntInt
      let integersIntegers = largeIntegersIntegers0
      self.startMeasuring()
      for (key, _) in integersIntegers { dictionary.removeValue(forKey: key) }
      self.stopMeasuring()
    }
  }

  func testUpdateValueForKeyPerformanceIntInt() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var dictionary = NativeDictionaryPerformanceTests.loadedDictionaryIntInt
      let integersIntegers = largeIntegersIntegers1
      self.startMeasuring()
      for (key, value) in integersIntegers { dictionary.updateValue(value, forKey: key) }
      self.stopMeasuring()
    }
  }

  func testOverallPerformanceIntInt() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      var dictionary = NativeDictionaryPerformanceTests.emptyDictionaryIntInt
      let dataSet0 = largeIntegersIntegers0, dataSet1 = largeIntegersIntegers1, dataSet2 = largeIntegersIntegers2
      self.startMeasuring()
      for (key, value) in dataSet0 { dictionary[key] = value }
      for (key, _) in dataSet1 { dictionary[key] = nil }
      for (key, value) in dataSet2 { dictionary[key] = value }
      self.stopMeasuring()
    }
  }

}
