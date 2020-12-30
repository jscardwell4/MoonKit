//
//  Dispatch.swift
//  MoonKit
//
//  Created by Jason Cardwell on 8/3/15.
//  Copyright © 2015 Jason Cardwell. All rights reserved.
//

import Foundation

/// Synchronously or asynchronously queues the specified closure for execution on the
/// main thread.
/// - Parameters:
///   - synchronous: Whether to queue synchronously.
///   - block: The closure to execute.
public func dispatchToMain(synchronous: Bool = false, _ block: @escaping () -> Void) {
  if Thread.isMainThread { block() }
  else if synchronous { DispatchQueue.main.sync(execute: block) }
  else { DispatchQueue.main.async(execute: block) }
}


/// Asynchronously queues the specified closure for background execution.
///
/// - Parameter block: The closure to execute.
public func backgroundDispatch(_ block: @escaping () -> Void) {
  DispatchQueue.global(qos: .background).async(execute: block)
}

extension DispatchWallTime {

  /// Initializing with a time seconds into the future.
  /// - Parameter seconds: The number of seconds into the future the
  ///                      time should represent.
  public init(seconds: Double) {
    let whole = seconds.rounded(.towardZero)
    let fractional = seconds - whole
    let time = timespec(tv_sec: Int(whole), tv_nsec: Int(fractional * Double(NSEC_PER_SEC)))
    self = DispatchWallTime(timespec: time)
  }

}
