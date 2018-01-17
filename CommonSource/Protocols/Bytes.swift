//
//  Bytes.swift
//  MoonKit
//
//  Created by Jason Cardwell on 11/8/15.
//  Copyright © 2015 Jason Cardwell. All rights reserved.
//
import Foundation

// Typealiases for making working with bytes more natural.

public typealias Byte = UInt8
public typealias Byte2 = UInt16
public typealias Byte4 = UInt32
public typealias Byte8 = UInt64

/// Protocol for types that can be fully converted to and from raw bytes.
public protocol DataConvertible {

  /// Assessor for the raw byte representation.
  var data: Data { get }

  /// Initialzing with a raw byte representation.
  init?(data: Data)
}

public extension DataConvertible where Self:NSCoding {

  var data: Data {
    let data = NSMutableData()
    let coder = NSKeyedArchiver(forWritingWith: data)
    encode(with: coder)
    coder.finishEncoding()
    return data as Data
  }

  init?(data: Data) {
    let coder = NSKeyedUnarchiver(forReadingWith: data)
    self.init(coder: coder)
  }
  
}
