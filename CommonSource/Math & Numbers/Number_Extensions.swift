//
//  Number_Extensions.swift
//  MoonKit
//
//  Created by Jason Cardwell on 1/2/21.
//  Copyright © 2021 Moondeer Studios. All rights reserved.
//
import Foundation

public extension FixedWidthInteger {


  /// Initializing with an array of decimal digits.
  /// - Parameter decimalDigits: The little-endian ordered decimal digits.
  init(decimalDigits: [UInt8]) {

    var result: Self = 0

    for digit in decimalDigits {
      result *= 10
      result += Self(digit)
    }

    self = result

  }

}
