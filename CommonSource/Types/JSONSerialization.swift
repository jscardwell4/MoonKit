//
//  JSONSerializationRedux.swift
//  MoonKit
//
//  Created by Jason Cardwell on 4/3/15.
//  Copyright (c) 2015 Jason Cardwell. All rights reserved.
//

import Foundation

public final class JSONSerialization {

  public static func parseDirectives(in url: URL) throws -> String {
    let result = try JSONIncludeDirective.parseDirectives(in: url)
    if JSONIncludeDirective.cacheSize > 100 { JSONIncludeDirective.emptyCache() }
    return result
  }

  public static func parse(string: String, options: ReadOptions = .none) throws -> JSONValue {
    let object = try JSONParser(string: string, ignoreExcess: options.contains(.ignoreExcess)).parse()
    return options.contains(.inflateKeypaths) ? object.inflatedValue : object
  }

  public static func parse(data: Data, options: ReadOptions = .none) throws -> JSONValue {
    guard let string = String(data: data) else { throw Error.invalidData }
    return try parse(string: string, options: options)
  }

  public static func parse(resource: String, in bundle: Bundle? = nil) throws -> JSONValue? {
    let bundle = bundle ?? Bundle.main
    guard let url = bundle.url(forResource: resource, withExtension: resource.hasSuffix(".json") ? nil : "json") else {
      return nil
    }
    return try parse(file: url)
  }

  /// This method calls `objectByParsingString:options:error` with the content of the specified file after 
  /// attempting to replace any '<@include file/to/include.json>' directives with their respective file content.
  public static func parse(file url: URL, options: ReadOptions = .none) throws -> JSONValue {
    return try parse(string: try parseDirectives(in: url), options: options)
  }

}

extension JSONSerialization {
  public enum Error: String, Swift.Error {
    case invalidData
  }
}

// Mark - Read/Write options type definitions
extension JSONSerialization {

  /** Enumeration for read format options */
  public struct ReadOptions: OptionSet {

    public var rawValue: UInt = 0

    public init(rawValue: UInt) { self.rawValue = rawValue }
    public init(nilLiteral: Void) { self = ReadOptions.none }

    public static var none            : ReadOptions = ReadOptions(rawValue: 0b0)
    public static var inflateKeypaths : ReadOptions = ReadOptions(rawValue: 0b1)
    public static var ignoreExcess    : ReadOptions = ReadOptions(rawValue: 0b01)

    public static var allZeros        : ReadOptions { return none }

  }

  /** Option set for write format options */
  public struct WriteOptions: OptionSet {

    public var rawValue: UInt = 0

    public init(rawValue: UInt) { self.rawValue = rawValue }
    public init(nilLiteral: Void) { self.rawValue = 0 }

    static var none                          : WriteOptions = WriteOptions(rawValue: 0b0000_0000_0000_0000)
    static var preserveWhitespace            : WriteOptions = WriteOptions(rawValue: 0b0000_0000_0000_0001)
    static var createKeypaths                : WriteOptions = WriteOptions(rawValue: 0b0000_0000_0000_0010)
    static var keepComments                  : WriteOptions = WriteOptions(rawValue: 0b0000_0000_0000_0100)
    static var indentByDepth                 : WriteOptions = WriteOptions(rawValue: 0b0000_0000_0000_1000)
    static var keepOneLiners                 : WriteOptions = WriteOptions(rawValue: 0b0000_0000_0001_0000)
    static var forceOneLiners                : WriteOptions = WriteOptions(rawValue: 0b0000_0000_0010_0000)
    static var breakAfterLeftSquareBracket   : WriteOptions = WriteOptions(rawValue: 0b0000_0000_0100_0000)
    static var breakBeforeRightSquareBracket : WriteOptions = WriteOptions(rawValue: 0b0000_0000_1000_0000)
    static var breakInsideSquareBrackets     : WriteOptions = WriteOptions(rawValue: 0b0000_0000_1100_0000)
    static var breakAfterLeftCurlyBracket    : WriteOptions = WriteOptions(rawValue: 0b0000_0001_0000_0000)
    static var breakBeforeRightCurlyBracket  : WriteOptions = WriteOptions(rawValue: 0b0000_0010_0000_0000)
    static var breakInsideCurlyBrackets      : WriteOptions = WriteOptions(rawValue: 0b0000_0011_0000_0000)
    static var breakAfterComma               : WriteOptions = WriteOptions(rawValue: 0b0000_0100_0000_0000)
    static var breakBetweenColonAndArray     : WriteOptions = WriteOptions(rawValue: 0b0000_1000_0000_0000)
    static var breakBetweenColonAndObject    : WriteOptions = WriteOptions(rawValue: 0b0001_0000_0000_0000)
    
    public static var allZeros               : WriteOptions { return WriteOptions.none }
  }
  
}
