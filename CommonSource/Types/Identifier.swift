//
//  Identifier.swift
//  MoonKit
//
//  Created by Jason Cardwell on 7/16/15.
//  Copyright © 2015 Jason Cardwell. All rights reserved.
//

import Foundation

/// An ordered collection of string values intended for use in object or category identification.
public struct Identifier: RandomAccessCollection, Comparable {

  public typealias Indices = Array<String>.Indices
  public typealias Index = Int
  public typealias Element = String
  public typealias _Element = String
  public typealias SubSequence = Array<String>.SubSequence

  public var startIndex: Int { return _tags.startIndex }
  public var endIndex: Int { return _tags.endIndex }

  public func index(before i: Int) -> Int { return _tags.index(before: i) }
  public func index(after i: Int) -> Int { return _tags.index(after: i) }
  public func makeIterator() -> Array<String>.Iterator { return _tags.makeIterator() }

  public subscript(position: Index) -> String { return _tags[position] }
  public subscript(bounds: Range<Index>) -> Array<String>.SubSequence { return _tags[bounds] }


  private var _tags: [String] = []

  public fileprivate(set) var tags: [String] {
    get { return _tags }
    set { _tags = filteredTags(newValue) }
  }

  public mutating func append(_ newElement: String) { _tags.append(newElement) }

  public var string: String { return tags.joined(separator: tagSeparator) }

  public var tagSeparator = Identifier.defaultTagSeparator

  public static let defaultTagSeparator = "-"

  private func filteredTag(_ tag: String) -> String {
    return tag.substitute(~/"\\\(tagSeparator)", "\(tagSeparator)")
  }

  private func filteredTags<Source>(_ tags: Source) -> [String]
    where Source:Collection, Source.Iterator.Element == String
  {
    return tags.map { filteredTag($0) }
  }

  public init() {}

  /// Initialize with the type name of an object and a list of strings
  public init(for object: Any, tags: String...) { _tags = filteredTags([typeName(object)] + tags) }

  /// Initialize from a sequence of strings
  public init<Source>(_ tags: Source)
    where Source:Sequence, Source.Iterator.Element == String
  {
    _tags = filteredTags(Array(tags))
  }

  /// Initialize from a string using the specified separator
  public init(_ tags: String..., tagSeparator: String = Identifier.defaultTagSeparator) {
    self.tagSeparator = tagSeparator
    _tags = filteredTags(tags.map({tagSeparator.split(~/$0)}).joined())
  }

  public static func ∋(lhs: Identifier, rhs: String) -> Bool {
    return lhs._tags.contains(rhs)
  }

  public static func ∈(lhs: String, rhs: Identifier) -> Bool {
    return rhs ∋ lhs
  }

  public static func +(lhs: Identifier, rhs: String) -> Identifier {
    var lhs = lhs
    lhs += rhs
    return lhs
  }

  public static func +=(lhs: inout Identifier, rhs: String) {
    lhs.append(rhs)
  }

  public static func ==(lhs: Identifier, rhs: Identifier) -> Bool {
    return lhs.string == rhs.string
  }

  public static func <(lhs: Identifier, rhs: Identifier) -> Bool {
    return lhs.string < rhs.string
  }

}

extension Identifier: ExpressibleByArrayLiteral {

  /// Initialize from an array literal of strings
  public init(arrayLiteral elements: String...) {
    self.init(elements)
  }

}

extension Identifier: ExpressibleByStringLiteral {

  /// Initialize from a literal string
  public init(stringLiteral value: String) {
    self.init(Identifier.defaultTagSeparator.split(~/value))
  }

  /// Initialize from a literal string
  public init(extendedGraphemeClusterLiteral value: String) {
    self.init(stringLiteral: value)
  }

  /// initialize from a literal string
  public init(unicodeScalarLiteral value: String) {
    self.init(stringLiteral: value)
  }

}

