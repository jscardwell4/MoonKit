//
//  AttributedStrings.swift
//  MoonKit
//
//  Created by Jason Cardwell on 5/11/18.
//  Copyright © 2018 Moondeer Studios. All rights reserved.
//
import Foundation

#if os(iOS)
import UIKit
#else
import AppKit
#endif

extension NSAttributedString {

  /// Invokes `attributedSubstring(from:)` with a range derived from `location` and the length
  /// of the attributed string.
  ///
  /// - Parameter location: The location denoting the first character in the return substring.
  /// - Returns: The substring from `location` to the end of the string.
  public func attributedSubstring(from location: Int) -> NSAttributedString {

    return attributedSubstring(from: NSRange(location: location, length: length - location))

  }

  /// The full range of the attributed string's text.
  public var textRange: NSRange { return NSRange(location: 0, length: length) }

  /// Whether the string's content consists only of whitespace and/or newline characters.
  public var isWhitespace: Bool {

    let whitespaceCharacterSet = CharacterSet.whitespacesAndNewlines

    for unicodeScalar in string.unicodeScalars {

      guard whitespaceCharacterSet.contains(unicodeScalar) else { return false }

    }

    return true

  }

}

extension NSMutableAttributedString {

  /// Appends a string to the attributed string using the specified attributes or without
  /// attributes if the parameter is `nil`..
  ///
  /// - Parameters:
  ///   - string: The string to append.
  ///   - attributes: The attributes for `string` or `nil`.
  public func append(_ string: String, attributes:  [NSAttributedStringKey:Any]? = nil) {
    append(NSAttributedString(string: string, attributes: attributes))
  }

  /// Appends a string to the attributed string.
  ///
  /// - Parameters:
  ///   - lhs: The attributed string to which `rhs` will be appended.
  ///   - rhs: The string to append to `lhs`.
  public static func += (lhs: NSMutableAttributedString, rhs: String) {
    lhs.append(rhs)
  }

  /// Appends a string to an attributed string using the specified attributes.
  ///
  /// - Parameters:
  ///   - lhs: The attributed string to which `rhs.0` will be appended with attributes `rhs.1`.
  ///   - rhs: The tuple containing the string and attributes to be appended to `lhs`.
  public static func +=(lhs: NSMutableAttributedString, rhs: (String, [NSAttributedStringKey:Any])) {
    lhs.append(rhs.0, attributes: rhs.1)
  }

}
