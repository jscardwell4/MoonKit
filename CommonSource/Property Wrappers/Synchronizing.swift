//
//  Synchronizing.swift
//  MoonKit
//
//  Created by Jason Cardwell on 1/6/21.
//  Copyright © 2021 Moondeer Studios. All rights reserved.
//
import Foundation

@propertyWrapper
public struct Synchronizing<Value> {

  private let lock: AnyObject
  private var value: Value

  public var wrappedValue: Value {
    get {
      objc_sync_enter(lock)
      defer { objc_sync_exit(lock) }
      return value
    }
    set {
      objc_sync_enter(lock)
      defer { objc_sync_exit(lock) }
      value = newValue
    }
  }

  public init(_ lock: AnyObject, _ value: Value) {
    self.lock = lock
    self.value = value
  }

}

