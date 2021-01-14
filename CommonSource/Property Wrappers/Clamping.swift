//
//  Clamping.swift
//  MoonKit
//
//  Created by Jason Cardwell on 1/5/21.
//  Copyright © 2021 Moondeer Studios. All rights reserved.
//
import Foundation

@propertyWrapper
public struct Clamping<Bound> where Bound:Comparable {

  private let range: ClosedRange<Bound>
  private var value: Bound

  public var wrappedValue: Bound {
    get { value }
    set { value = range.clampValue(newValue) }
  }

  public init(_ range: ClosedRange<Bound>, _ value: Bound) {
    self.range = range
    self.value = value
  }

}
