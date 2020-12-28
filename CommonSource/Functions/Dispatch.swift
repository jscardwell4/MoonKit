//
//  Dispatch.swift
//  MoonKit
//
//  Created by Jason Cardwell on 8/3/15.
//  Copyright © 2015 Jason Cardwell. All rights reserved.
//

import Foundation

public func secondsToNanoseconds(_ seconds: Double) -> UInt64 {
  return UInt64(seconds * Double(NSEC_PER_SEC))
}

public func nanosecondsToSeconds(_ nanoseconds: UInt64) -> Double {
  return Double(nanoseconds) / Double(NSEC_PER_SEC)
}

public func dispatchToMain(synchronous: Bool = false, _ block: @escaping () -> Void) {
  if Thread.isMainThread { block() }
  else if synchronous { DispatchQueue.main.sync(execute: block) }
  else { DispatchQueue.main.async(execute: block) }
}


public func backgroundDispatch(_ block: @escaping () -> Void) {
  DispatchQueue.global(qos: .background).async(execute: block)
}

extension DispatchWallTime {

  public init(seconds: Double) {
    let whole = seconds.rounded(.towardZero)
    let fractional = seconds - whole
    let time = timespec(tv_sec: Int(whole), tv_nsec: Int(fractional * Double(NSEC_PER_SEC)))
    self = DispatchWallTime(timespec: time)
  }

}
