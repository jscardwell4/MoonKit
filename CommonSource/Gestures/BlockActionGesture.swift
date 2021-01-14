//
//  BlockActionGesture.swift
//  MoonKit
//
//  Created by Jason Cardwell on 11/18/14.
//  Copyright (c) 2014 Jason Cardwell. All rights reserved.
//

import Foundation
import UIKit
import UIKit.UIGestureRecognizerSubclass

@objc public class BlockActionGesture: UIGestureRecognizer {

  fileprivate let handlerTarget = Handler()

  public var handler: ((BlockActionGesture) -> Void)? {
    get { return handlerTarget.action }
    set { handlerTarget.action = newValue }
  }

  fileprivate class Handler {
    var action: ((BlockActionGesture) -> Void)?
    fileprivate var timestamp = DispatchTime.now()

    /** dispatchHandler */
    func dispatchHandler(_ sender: BlockActionGesture) {
      if secondsSince(timestamp) > 0.1 {
        timestamp = DispatchTime.now() + Double(0) / Double(NSEC_PER_SEC)
        action?(sender)
      }
    }

    /**
    secondsBetween:and:

    - parameter stamp1: dispatch_time_t
    - parameter stamp2: dispatch_time_t

    - returns: Double
    */
    fileprivate func secondsBetween(_ stamp1: DispatchTime, and stamp2: DispatchTime) -> Double {
      return (Double(stamp1.rawValue) - Double(stamp2.rawValue)) * Double(NSEC_PER_SEC)
    }

    /**
    secondsSince:

    - parameter stamp: dispatch_time_t

    - returns: Double
    */
    fileprivate func secondsSince(_ stamp: DispatchTime) -> Double {
      return secondsBetween(DispatchTime.now() + Double(0) / Double(NSEC_PER_SEC), and: stamp)
    }

  }

  /**
  centroidForTouches:

  - parameter touches: [UITouch]

  - returns: CGPoint
  */
  func centroidForTouches<C:Collection>(_ touches: C) -> CGPoint
     where C.Iterator.Element == UITouch
  {
    guard touches.count > 0, let view = view else { return CGPoint.null }
    let sum = touches.map {$0.location(in: view)}.reduce(CGPoint.zero, {CGPoint(x: $0.x + $1.x, y: $0.y + $1.y)})
    return CGPoint(x: sum.x / CGFloat(touches.count), y: sum.y / CGFloat(touches.count))
  }

  /**
  initWithHandler:

  - parameter handler: (LongPressGesture) -> Void
  */
  public convenience init(handler: ((BlockActionGesture) -> Void)?) {
    self.init()
    self.handler = handler
    addTarget(self, action: #selector(BlockActionGesture.dispatchHandler(_:)))
  }

  /**
  dispatchHandler:

  - parameter sender: BlockActionGesture
  */
  @objc public func dispatchHandler(_ sender: BlockActionGesture) { handlerTarget.dispatchHandler(sender) }

  public override var state: UIGestureRecognizer.State { didSet { handlerTarget.dispatchHandler(self) } }

  /**
  initWithTarget:action:

  - parameter target: AnyObject
  - parameter action: Selector
  */
  public override init(target: Any?, action: Selector?) {
    super.init(target: target, action: action)
    addTarget(self, action: #selector(BlockActionGesture.dispatchHandler(_:)))
  }

}
