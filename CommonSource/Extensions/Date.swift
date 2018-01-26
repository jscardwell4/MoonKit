//
//  Date.swift
//  MoonKit
//
//  Created by Jason Cardwell on 1/25/18.
//  Copyright © 2018 Moondeer Studios. All rights reserved.
//
import Foundation

extension Date {

  /// Method of convenience for creating a string representation of a date.
  ///
  /// - Parameters:
  ///   - format: The `dateFormat` string for use with an instance of `DateFormatter`.
  ///   - abbreviation: One of the keys from `TimeZone.abbreviationDictionary` or `nil`.
  /// - Returns: A string representation of the date.
  public func string(format: String, timeZone abbreviation: String? = nil) -> String {
    let df = DateFormatter()
    if let abbreviation = abbreviation, let timeZone = TimeZone(abbreviation: abbreviation) {
      df.timeZone = timeZone
    }
    df.dateFormat = format
    return df.string(from: self)
  }

  /// The simple internet date time representation of the date.
  public var timestamp: String {
    return string(format: "yyyyMMdd'T'HHmmss'Z'", timeZone: "UTC")
  }

  /// The current date at the time when this property is accessed.
  static public var now: Date { return Date() }

}
