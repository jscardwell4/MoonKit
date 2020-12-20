//
//  TestData.swift
//  MoonKit
//
//  Created by Jason Cardwell on 7/25/16.
//  Copyright © 2016 Jason Cardwell. All rights reserved.
//
import Foundation

/// Returns an array containing the even numbers within the specified range.
/// - Parameter range: The range with even numbers to include in the result.
/// - Returns: An array of even numbers within `range`.
func evenNumbers(range: Range<Int>) -> [Int] {
  range.lowerBound % 2 == 0
    ? Array(stride(from: range.lowerBound, to: range.upperBound, by: 2))
    : Array(stride(from: range.lowerBound + 1, to: range.upperBound, by: 2))
}

/// Returns an array containing the odd numbers within the specified range.
/// - Parameter range: The range with odd numbers to include in the result.
/// - Returns: An array of odd numbers within `range`.
func oddNumbers(range: Range<Int>) -> [Int] {
  range.lowerBound % 2 == 1
    ? Array(stride(from: range.lowerBound, to: range.upperBound, by: 2))
    : Array(stride(from: range.lowerBound + 1, to: range.upperBound, by: 2))
}

/// Returns an array of `count` randomly generated integers within `range`.
/// Integers generated with `arc4random`.
///
/// - Parameters:
///   - count: The number of integers to generate.
///   - range: The range by within which to limit generated values.
/// - Returns: The array of randomly generated values within `range`.
func randomIntegers(count: Int, range: Range<Int>) -> [Int] {
  var result = [Int]()
  result.reserveCapacity(count)
  for _ in 0 ..< count {
    result.append(Int(arc4random()) % range.count + range.lowerBound)
  }
  return result
}

/// Randomly generated range from within a given range.
///
/// - Parameters:
///   - indices: The indices bounding the generated range.
///   - coverage: The amount of the initial range that should be represented.
///   - limit: The maximum length of the generated range.
/// - Returns: The randomly generated range.
func randomRange(indices: Range<Int>, coverage: Double, limit: Int = 0) -> Range<Int> {
  let count = indices.count
  guard count > 0 else { return indices }

  var resultCount = Int(Double(count) * coverage)
  if limit > 0 { resultCount = max(limit, resultCount) }
  let offset = indices.lowerBound

  let end = Int(arc4random()) % count + offset
  let start = max(offset, end - resultCount)

  return start ..< end
}

/// Generates an array of randomly generated ranges from within a given range.
///
/// - Parameters:
///   - count: The total number of ranges to randomly generate.
///   - indices: The indices bounding the generated range.
///   - coverage: The amount of the initial range that should be represented per range.
///   - limit: The maximum length of any generated range.
/// - Returns: The array of randomly generated ranges.
func randomRanges(count: Int,
                  indices: Range<Int>,
                  coverage: Double,
                  limit: Int = 0) -> [Range<Int>]
{
  var result: [Range<Int>] = []
  for _ in 0 ..< count {
    result.append(randomRange(indices: indices, coverage: coverage, limit: limit))
  }
  return result
}

// MARK: - TestData

struct TestData {
  enum Size: Int {
    case xxxSmall = 50
    case xxSmall = 100
    case xSmall = 250
    case small = 500
    case medium = 10_000
    case large = 50_000
    case xLarge = 100_000
    case xxLarge = 150_000
    case xxxLarge = 200_000
  }

  init(size: Size) { self.size = size }
  let size: Size
  var count: Int { return size.rawValue }

  func ranges(withinRange indices: Range<Int>,
              coverage: Double, limit: Int = 0) -> [Range<Int>]
  {
    return randomRanges(count: count, indices: indices, coverage: coverage, limit: limit)
  }

  func integers(range: Range<Int>? = nil) -> [Int] {
    return randomIntegers(count: count, range: range ?? 0 ..< count)
  }

  func strings(range: Range<Int>? = nil) -> [String] {
    return integers(range: range).map(String.init)
  }

  func stringIntegerPairs(range: Range<Int>? = nil) -> [(key: String, value: Int)] {
    let integers = self.integers(range: range)
    let strings = integers.map(String.init)
    return zip(strings, integers).map { (key: $0, value: $1) }
  }

  func integerStringPairs(range: Range<Int>? = nil) -> [(key: Int, value: String)] {
    let integers = self.integers(range: range)
    let strings = integers.map(String.init)
    return zip(integers, strings).map { (key: $0, value: $1) }
  }

  func stringStringPairs(range: Range<Int>? = nil) -> [(key: String, value: String)] {
    let strings = self.strings(range: range)
    return zip(strings, strings).map { (key: $0, value: $1) }
  }

  func integerIntegerPairs(range: Range<Int>? = nil) -> [(key: Int, value: Int)] {
    let integers = self.integers(range: range)
    return zip(integers, integers).map { (key: $0, value: $1) }
  }

  func stringObjects(range: Range<Int>? = nil) -> [NSString] {
    return strings(range: range).map { NSString(string: $0) }
  }

  func integerObjects(range: Range<Int>? = nil) -> [NSNumber] {
    return integers(range: range).map { NSNumber(value: $0) }
  }
}

let largeTestData = TestData(size: .large)

let largeIntegers0 = largeTestData.integers()
let largeIntegers1 = largeTestData.integers()
let largeIntegers2 = largeTestData.integers()
let largeIntegers3 = largeTestData.integers()
let largeIntegers4 = largeTestData.integers()
let largeIntegers5 = largeTestData.integers()
let largeIntegers6 = largeTestData.integers()
let largeIntegers7 = largeTestData.integers()
let largeIntegers8 = largeTestData.integers()
let largeIntegers9 = largeTestData.integers()

let largeSubIntegers0 = largeIntegers0.randomElements(largeTestData.count / 4)
let largeSubIntegers1 = largeIntegers1.randomElements(largeTestData.count / 4)
let largeSubIntegers2 = largeIntegers2.randomElements(largeTestData.count / 4)
let largeSubIntegers3 = largeIntegers3.randomElements(largeTestData.count / 4)
let largeSubIntegers4 = largeIntegers4.randomElements(largeTestData.count / 4)
let largeSubIntegers5 = largeIntegers5.randomElements(largeTestData.count / 4)
let largeSubIntegers6 = largeIntegers6.randomElements(largeTestData.count / 4)
let largeSubIntegers7 = largeIntegers7.randomElements(largeTestData.count / 4)
let largeSubIntegers8 = largeIntegers8.randomElements(largeTestData.count / 4)
let largeSubIntegers9 = largeIntegers9.randomElements(largeTestData.count / 4)

let largeEvenIntegers = evenNumbers(range: 0 ..< largeTestData.count * 2)
let largeOddIntegers = evenNumbers(range: 1 ..< (largeTestData.count * 2 + 1))

let largeRanges = largeTestData.ranges(withinRange: 0 ..< largeTestData.count,
                                       coverage: 0.25,
                                       limit: 5000)

let largeStrings0 = largeTestData.strings()
let largeStrings1 = largeTestData.strings()
let largeStrings2 = largeTestData.strings()
let largeStrings3 = largeTestData.strings()
let largeStrings4 = largeTestData.strings()
let largeStrings5 = largeTestData.strings()
let largeStrings6 = largeTestData.strings()
let largeStrings7 = largeTestData.strings()
let largeStrings8 = largeTestData.strings()
let largeStrings9 = largeTestData.strings()

let largeSubStrings0 = largeStrings0.randomElements(largeTestData.count / 4)
let largeSubStrings1 = largeStrings1.randomElements(largeTestData.count / 4)
let largeSubStrings2 = largeStrings2.randomElements(largeTestData.count / 4)
let largeSubStrings3 = largeStrings3.randomElements(largeTestData.count / 4)
let largeSubStrings4 = largeStrings4.randomElements(largeTestData.count / 4)
let largeSubStrings5 = largeStrings5.randomElements(largeTestData.count / 4)
let largeSubStrings6 = largeStrings6.randomElements(largeTestData.count / 4)
let largeSubStrings7 = largeStrings7.randomElements(largeTestData.count / 4)
let largeSubStrings8 = largeStrings8.randomElements(largeTestData.count / 4)
let largeSubStrings9 = largeStrings9.randomElements(largeTestData.count / 4)

let largeEvenStrings = evenNumbers(range: 0 ..< largeTestData.count * 2).map(String.init)
let largeOddStrings = evenNumbers(range: 1 ..< (largeTestData.count * 2 + 1)).map(String.init)

let largeStringsIntegers0 = largeTestData.stringIntegerPairs()
let largeStringsIntegers1 = largeTestData.stringIntegerPairs()
let largeStringsIntegers2 = largeTestData.stringIntegerPairs()
let largeStringsIntegers3 = largeTestData.stringIntegerPairs()
let largeStringsIntegers4 = largeTestData.stringIntegerPairs()
let largeStringsIntegers5 = largeTestData.stringIntegerPairs()
let largeStringsIntegers6 = largeTestData.stringIntegerPairs()
let largeStringsIntegers7 = largeTestData.stringIntegerPairs()
let largeStringsIntegers8 = largeTestData.stringIntegerPairs()
let largeStringsIntegers9 = largeTestData.stringIntegerPairs()

let largeStringsStrings0 = largeTestData.stringStringPairs()
let largeStringsStrings1 = largeTestData.stringStringPairs()
let largeStringsStrings2 = largeTestData.stringStringPairs()
let largeStringsStrings3 = largeTestData.stringStringPairs()
let largeStringsStrings4 = largeTestData.stringStringPairs()
let largeStringsStrings5 = largeTestData.stringStringPairs()
let largeStringsStrings6 = largeTestData.stringStringPairs()
let largeStringsStrings7 = largeTestData.stringStringPairs()
let largeStringsStrings8 = largeTestData.stringStringPairs()
let largeStringsStrings9 = largeTestData.stringStringPairs()

let largeIntegersIntegers0 = largeTestData.integerIntegerPairs()
let largeIntegersIntegers1 = largeTestData.integerIntegerPairs()
let largeIntegersIntegers2 = largeTestData.integerIntegerPairs()
let largeIntegersIntegers3 = largeTestData.integerIntegerPairs()
let largeIntegersIntegers4 = largeTestData.integerIntegerPairs()
let largeIntegersIntegers5 = largeTestData.integerIntegerPairs()
let largeIntegersIntegers6 = largeTestData.integerIntegerPairs()
let largeIntegersIntegers7 = largeTestData.integerIntegerPairs()
let largeIntegersIntegers8 = largeTestData.integerIntegerPairs()
let largeIntegersIntegers9 = largeTestData.integerIntegerPairs()

let xxSmallTestData = TestData(size: .xxSmall)

let xxSmallIntegers1 = xxSmallTestData.integers()
let xxSmallIntegers2 = xxSmallTestData.integers()

let xxSmallStrings1 = xxSmallTestData.strings()
let xxSmallStrings2 = xxSmallTestData.strings()

let xxSmallStringsIntegers0 = xxSmallTestData.stringIntegerPairs()
let xxSmallStringsIntegers1 = xxSmallTestData.stringIntegerPairs()
