//
//  Timer.swift
//  MoonKit
//
//  Created by Jason Cardwell on 8/3/15.
//  Copyright © 2015 Jason Cardwell. All rights reserved.
//
import Foundation
import Dispatch


public final class Timer {

  fileprivate let queue: DispatchQueue
  fileprivate let source: DispatchSourceTimer

  public var interval: DispatchTimeInterval { didSet { updateTimer() } }
  public var leeway: DispatchTimeInterval  { didSet { updateTimer() } }
  public var handler: (() -> Void)?

  public fileprivate(set) var running = false
  fileprivate var handleEvents = true

  /// Starts the timer
  public func start() { guard !running else { return }; updateTimer(); source.resume(); running = true }

  /// Stops the timer
  public func stop() { guard running else { return }; source.suspend(); running = false }

  /// Sets the timer for `source` using the current property values
  fileprivate func updateTimer() {
    source.schedule(deadline: DispatchTime.now(), repeating: interval, leeway: leeway)
  }

  public init(queue q: DispatchQueue = DispatchQueue.main,
              interval i: DispatchTimeInterval = .seconds(1),
              leeway l: DispatchTimeInterval = .seconds(0),
              handler h: (() -> Void)? = nil)
  {
    queue = q; interval = i; leeway = l; handler = h
    source = DispatchSource.makeTimerSource(flags: DispatchSource.TimerFlags(rawValue: UInt(0)), queue: queue)
    source.setEventHandler { [weak self] in if self?.handleEvents == true { self?.handler?() } }
  }

  /// Cancels the dispatch source if it has not already been cancelled
  deinit {
    guard !source.isCancelled else { return }
    handleEvents = false
    if !running { source.resume() }
    source.cancel()
  }
}
