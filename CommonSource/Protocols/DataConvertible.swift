//
//  Bytes.swift
//  MoonKit
//
//  Created by Jason Cardwell on 11/8/15.
//  Copyright © 2015 Jason Cardwell. All rights reserved.
//
import Foundation

/// Protocol for types that can be fully converted to and from raw bytes.
public protocol DataConvertible {

  /// Assessor for the raw byte representation.
  var data: Data { get }

  /// Initialzing with a raw byte representation.
  init?(data: Data)
}

public extension DataConvertible where Self:NSCoding {

  var data: Data {
    tryOrDie { try NSKeyedArchiver.archivedData(withRootObject: self,
                                                requiringSecureCoding: true) }
  }

  init?(data: Data) {
    guard let coder = try? NSKeyedUnarchiver(forReadingFrom: data) else { return nil }
    self.init(coder: coder)
  }
  
}
