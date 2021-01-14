//
//  PassThrough.swift
//  MoonKit
//
//  Created by Jason Cardwell on 1/4/21.
//  Copyright © 2021 Moondeer Studios. All rights reserved.
//
import Foundation

@propertyWrapper
public struct PassThrough<Root, Value> {

  private let keyPath: KeyPath<Root, Value>

  public var projectedValue: Root!

  public var wrappedValue: Value {
      projectedValue[keyPath: keyPath]
  }

  public init(_ keyPath: KeyPath<Root, Value>) {
    self.keyPath = keyPath
  }

}

@propertyWrapper
public struct WritablePassThrough<Root, Value> {

  private let keyPath: WritableKeyPath<Root, Value>

  public var projectedValue: Root!

  public var wrappedValue: Value {
    get {
      projectedValue[keyPath: keyPath]
    }
    set {
      projectedValue[keyPath: keyPath] = newValue
    }
  }

  public init(_ keyPath: WritableKeyPath<Root, Value>) {
    self.keyPath = keyPath
  }

}

@propertyWrapper
public struct ClampingWritablePassThrough<Root, Value> where Value:Comparable {

  private let keyPath: WritableKeyPath<Root, Value>
  private let range: ClosedRange<Value>

  public var projectedValue: Root!

  public var wrappedValue: Value {
    get {
      projectedValue[keyPath: keyPath]
    }
    set {
      projectedValue[keyPath: keyPath] = range.clampValue(newValue)
    }
  }

  public init(_ keyPath: WritableKeyPath<Root, Value>, _ range: ClosedRange<Value>) {
    self.keyPath = keyPath
    self.range = range
  }

}
