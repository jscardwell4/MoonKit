//
//  Strings.swift
//  SignalProcessing
//
//  Created by Jason Cardwell on 9/22/17.
//  Copyright © 2017 Moondeer Studios. All rights reserved.
//
import Foundation
#if os(iOS)
import UIKit
#endif

// MARK: Character Operator Support Functions

public extension Character {
  /// Operator providing a more convenient way to create a string by characeter
  /// repetition.
  ///
  /// - Parameters:
  ///   - lhs: The character to repeat.
  ///   - rhs: The number of times to repeat `lhs`.
  /// - Returns: A string composed of `lhs` repeated `rhs` times.
  static func *(lhs: Character, rhs: Int) -> String {
    String(repeating: lhs, count: rhs)
  }
}

// MARK: String Operator Support Functions

public extension String {
  /// Operator providing a more convenient way to create a string of a repeated
  /// characeter sequence.
  ///
  /// - Parameters:
  ///   - lhs: The character sequence to repeat.
  ///   - rhs: The number of times to repeat `lhs`.
  /// - Returns: A string composed of `lhs` repeated `rhs` times.
  static func *(lhs: String, rhs: Int) -> String {
    String(repeating: lhs, count: rhs)
  }
}

// MARK: - Forming New Strings

public extension String {
  // MARK: Replacements

  /// Replaces all characters in the string that belong to the specified
  /// character set with the specified character.
  ///
  /// - Parameters:
  ///   - characterSet: The set of characters to replace.
  ///   - replacement: The Unicode scalar value with which to replace each occurence.
  /// - Returns: The string formed by replacing characters in `characterSet`
  ///            with `replacement`.
  func replacingCharacters(in characterSet: CharacterSet,
                           with replacement: String) -> String
  {
    let scalarʹ = Unicode.Scalar(replacement)

    var scalars: [Unicode.Scalar] = []

    for scalar in unicodeScalars {
      if !characterSet.contains(scalar) { scalars.append(scalar) }
      else if let scalarʹ = scalarʹ { scalars.append(scalarʹ) }
    }

    return String(String.UnicodeScalarView(scalars))
  }

  // MARK: Padding

  /// An enumeration for specifying the location of a string's content within
  /// a padded string.
  enum PadAlignment {
    /// The padding follows the content.
    case left

    /// Pads either side of the content.
    case center

    /// The padding precedes the content.
    case right
  }

  /// Pads the string to create a new string.
  ///
  /// - Parameters:
  ///   - length: The length to which the string will be padded.
  ///   - alignment: The location of the string's content within the padded string.
  ///                Defaults to `left` alignment.
  ///   - padCharacter: The character used to pad the string to `length`.
  ///                   Defaults to `" "`.
  /// - Returns: The string padded to `length` using `padCharacter` and
  ///            aligned via `alignment`.
  func padded(to length: Int,
              alignment: PadAlignment = .left,
              padCharacter: Character = " ") -> String
  {
    // Check that the string does not satisfy `length`. If it does,
    // just return the string.
    guard count < length else { return self }

    // Switch on the specified pad alignment.
    switch alignment {
      case .left:
        // Add the string's content. Add the padding.

        let pad = length - count
        return self + padCharacter * pad

      case .center:
        // Add half the padding. Add the string's content. Add the remaing padding.

        let leftPad = (length - count) / 2
        let rightPad = length - count - leftPad
        return padCharacter * leftPad + self + padCharacter * rightPad

      case .right:
        // Add the padding. Add the string's content.

        let pad = length - count
        return padCharacter * pad + self
    }
  }

  // MARK: Joining

  /// Method of convenience that invokes the `joined(separator:)` method on the
  /// `sequence` using `self` as the separator.
  /// - Parameter sequence: The sequence of string types to join.
  /// - Returns: The string values of `sequence` joined by `self`.
  func join<S: Sequence>(_ sequence: S) -> String where S.Element: StringProtocol {
    sequence.joined(separator: self)
  }

  func join(_ strings: String...) -> String { strings.joined(separator: self) }
  func join(_ strings: [String]) -> String { strings.joined(separator: self) }
  

  // MARK: Splitting

  func split(_ regex: RegularExpression) -> [String] {
    let ranges = regex.matchRanges(in: self).compactMap {Range($0, in: self)}
    guard ranges.count > 0 else { return [self] }
    return (startIndex ..< endIndex).split(
      ranges,
      noImplicitJoin: true).compactMap { String(self[$0]) }
  }

  // MARK: Indenting

  /// Returns the string with the specified amount of leading space in the
  /// form of space characters.
  func indented(by indent: Int,
                preserveFirst: Bool = false,
                useTabs: Bool = false) -> String
  {
    let spacer = String(repeating: useTabs ? "\t" : " ", count: indent)
    let lines = split(separator: "\n")
    let result = lines.joined(separator: "\n\(spacer)")

    return preserveFirst ? result : "\(spacer)\(result)"
  }

  // MARK: Case conversions

  /// Returns the string converted to 'dash-case'.
  var dashCaseString: String {
    isDashCase
      ? self
      : (isCamelCase
        ? split(~/"(?<=\\p{Ll})(?=\\p{Lu})").joined(separator: "-").lowercased()
        : camelCaseString.dashCaseString)
  }

  /// Returns the string with the first character converted to lowercase.
  var lowercaseFirst: String {
    count < 2 ? lowercased() : self.first!.lowercased() + dropFirst()
  }

  /// Returns the string with the first character converted to uppercase.
  var uppercaseFirst: String {
    count < 2 ? uppercased() : self.first!.uppercased() + dropFirst()
  }

  /// Returns the string converted to 'camelCase'.
  var camelCaseString: String {

    guard !isCamelCase else { return self }

    var segments = split(~/#"(?<=\p{Ll})(?=\p{Lu})|(?<=\p{Lu})(?=\p{Lu})|(\p{Z}|\p{P})"#)

    guard segments.count > 0 else { return self }

    var i = 0
    while i < segments.count, segments[i] ~= ~/#"^\p{Lu}$"# {
      segments[i] = segments[i].lowercased(); i += 1
    }

    if i == 0 { i += 1; segments[0] = segments[0].lowercaseFirst }

    for j in i ..< segments.count where segments[j] ~= ~/"^\\p{Ll}" {
      segments[j] = segments[j].uppercaseFirst
    }

    return segments.joined(separator: "")
  }

  /// Returns the string converted to 'PascalCase'.
  var pascalCaseString: String {
    isPascalCase
      ? self
      : (~/#"^(\p{Ll}+)"#).substitute(matchesIn: camelCaseString)
        {$0.substring.uppercased()}
  }

  var isCamelCase: Bool { ~/#"^\p{Ll}+((?:\p{Lu}|\p{N})+\p{Ll}*)*$"# ~= self }

  var isPascalCase: Bool { ~/#"^\p{Lu}+((?:\p{Ll}|\p{N})+\p{Lu}*)*$"# ~= self }

  var isDashCase: Bool { ~/#"^\p{Ll}+(-\p{Ll}*)*$"# ~= self }

  // MARK: Quotes

  var isQuoted: Bool { hasPrefix("\"") && hasSuffix("\"") }

  var quoted: String { isQuoted ? self : "\"\(self)\"" }

  var unquoted: String {
    isQuoted
      ? String(self[index(after: startIndex)..<index(before: endIndex)])
      : self
  }

  // MARK: URLs

  var lastPathComponent: String { fileURL.lastPathComponent }

  var baseNameExt: (baseName: String, ext: String) {
    let url = fileURL
    return (baseName: url.deletingPathExtension().lastPathComponent,
            ext: url.pathExtension)
  }

  var dropExtension: String { fileURL.deletingPathExtension().path }

  var fileURL: URL { URL(fileURLWithPath: self) }

  var pathEncoded: String { urlPathEncoded }

  var urlFragmentEncoded: String {
    addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) ?? self
  }

  var urlPathEncoded: String {
    addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? self
  }

  var urlQueryEncoded: String {
    addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? self
  }

  var urlUserEncoded: String {
    addingPercentEncoding(withAllowedCharacters: .urlUserAllowed) ?? self
  }

  var pathDecoded: String { return removingPercentEncoding ?? self }

  var forwardSlashEncoded: String { substitute("/", "%2F") }

  var forwardSlashDecoded: String { substitute(~/"%2[Ff]", "/") }

  // MARK: Regular Expressions

  /// Perform substitutions for matches against the specified regular expression.
  ///
  /// - Parameters:
  ///   - regex: The regular expression to test for matches.
  ///   - template: The template for replacing matched text.
  /// - Returns: The result of replacing matches for `regex` using `template`.
  func substitute(_ regex: RegularExpression, _ template: String) -> String {
    regex.substitute(matchesIn: self, using: template)
  }
  func substitute(_ string: String, _ template: String) -> String {
    substitute(~/string, template)
  }


  /// Perform substitutions for matches against the specified regular expression.
  ///
  /// - Parameters:
  ///   - regex: The regular expression to test for matches.
  ///   - block: The block for replacing matched text.
  /// - Returns: The result of replacing matches for `regex` using `block`.
  func substitute(_ regex: RegularExpression,
                  _ block: (RegularExpression.Match) -> String) -> String
  {
    regex.substitute(matchesIn: self, using: block)
  }

  func substitute(_ string: String,
                  _ block: (RegularExpression.Match) -> String) -> String
  {
    substitute(~/string, block)
  }

}

// MARK: - Initializers

extension String {
  /// Intialzing with a description of a floating point number given a specified
  /// precision.
  ///
  /// - Parameters:
  ///   - value: The floating point value to describe.
  ///   - maxPrecision: The maximum number of decimals to include.
  ///   - minPrecision: The minimum number of decimals to include.
  ///                   Trailing zeros are removed until this threshold
  ///                   is reached. If this value is less than `1` and
  ///                   the fractional part is all zeros, the decimal
  ///                   will also be removed.
  init<F>(describing value: F, maxPrecision: Int, minPrecision: Int)
    where F: FloatingPoint, F: CVarArg
  {
    guard minPrecision <= maxPrecision else {
      fatalError("\(#function) `minPrecision` must be ≤ `maxPrecision`.")
    }

    let pattern: String

    switch value {
      case is Float:
        pattern = "%.*f"
      case is Double,
           is CGFloat:
        pattern = "%.*lf"
      default:
        fatalError("\(#function) Unsupported floating point type: \(F.self)")
    }

    let string = String(format: pattern, value, maxPrecision)

    guard let decimal = string.firstIndex(of: ".") else { self = string; return }

    var end = string.endIndex
    while end > string.startIndex,
          string[string.index(before: end)] == "0"
          || string[string.index(before: end)] == ".",
          string.distance(from: decimal, to: end) > (minPrecision + 1)
    {
      end = string.index(before: end)
    }

    if string.index(before: end) == decimal { end = decimal }

    self = String(string[..<end])
  }

  /// Initializing with the description of a fixed width integer.
  ///
  /// - Parameters:
  ///   - value: The integer value the string is to describe.
  ///   - radix: The base in which to express `value`.
  ///   - uppercase: Whether to use uppercase letters when `radix == 16`.
  ///   - minCount: The target character count, `0`s will be used
  ///                        to pad the value.
  ///   - group: The group size for spacing digits or `0` to prevent grouping.
  ///   - separator: The string use to separate groups of digits when `group > 0`.
  init<T: FixedWidthInteger>(_ value: T,
                             radix: Int,
                             uppercase: Bool = false,
                             minCount: Int = 0,
                             group: Int = 0,
                             separator: String = " ")
  {
    self = String(value, radix: radix, uppercase: uppercase)
    guard minCount > 0 || group > 0 else { return }

    let padCount = minCount - count

    if padCount > 0 { self = String(repeating: "0", count: padCount).appending(self) }

    guard group > 0, count > group else { return }

    let segments = segment(group, options: .padFirstGroup(Character("0")))

    self = separator.join(segments.compactMap { String($0) })
  }

  /// Initializing with the hexadecimal representation for a sequence of byte values.
  ///
  /// - Parameter hexBytes: The sequence of byte values to describe.
  init<S: Sequence>(hexBytes: S) where S.Iterator.Element == UInt8 {
    self = " ".join(hexBytes.map { String($0, radix: 16, uppercase: true, minCount: 2) })
  }

  /// Initializes the string with the address of the specified object.
  ///
  /// - Parameter object: The object who's address in memory shall occupy the string.
  init(addressOf object: AnyObject) {
    var object = object
    self = withUnsafeBytes(of: &object) { UInt(bitPattern: $0.baseAddress!).description }
  }

  /// Initializes with an `ObjectIdentifier` or "nil" if `object == nil`.
  ///
  /// - Parameter object: The object being described.
  init<T: AnyObject>(objectIdentifier object: T?) {
    guard let object = object else { self = "nil"; return }
    let id = ObjectIdentifier(object).debugDescription
    self = "\(type(of: object))\(id[id.index(id.startIndex, offsetBy: 16)...])"
  }

  /// Initializing with a floating point value of the specified precision.
  /// - Parameters:
  ///   - value: The value being described.
  ///   - precision: The number maximum number of digits to appear after ".",
  ///                A negative value for `precision` ignores the digit count.
  init<F: BinaryFloatingPoint>(_ value: F, precision: Int = -1) {
    switch precision {
      case Int.min ... -1:
        self = String(value)
      case 0:
        self = String(Int(value))
      default:
        let s = String(value)
        self = s
        guard let decimal = s.firstIndex(of: ".") else { return }
        self = "\(s[..<decimal]).\(s[s.index(after: decimal)...].prefix(precision))"
    }
  }
}

// MARK: - String + PrettyPrint

extension String: PrettyPrint {
  public var prettyDescription: String { self }
}

// MARK: - String + StringValueConvertible

extension String: StringValueConvertible {
  public var stringValue: String { self }
}
