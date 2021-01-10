//
//  TripOnce.swift
//  MoonKit
//
//  Created by Jason Cardwell on 1/9/21.
//  Copyright © 2021 Moondeer Studios. All rights reserved.
//
import Foundation

@propertyWrapper
public struct TripOnce<Caller>
{
  public typealias Closure = (Caller) -> Void

  private var tripped = false
  private let trippedClosure: Closure

  public var projectedValue: Caller!

  public var wrappedValue: Closure
  {
    mutating get
    {
      guard !tripped else { return trippedClosure }
      trippedClosure(projectedValue)
      tripped = true
      return trippedClosure
    }
    set
    {}
  }

  public init(wrappedValue: @escaping Closure)
  {
    trippedClosure = wrappedValue
  }
}
