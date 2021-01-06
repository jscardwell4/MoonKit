//
//  NotificationDispatching.swift
//  MoonKit
//
//  Created by Jason Cardwell on 10/5/15.
//  Copyright © 2015 Jason Cardwell. All rights reserved.
//

import Foundation

public protocol NotificationDispatching {

  associatedtype NotificationName: LosslessStringConvertible

  typealias PostingStyle = NotificationQueue.PostingStyle
  typealias NotificationCoalescing = NotificationQueue.NotificationCoalescing

  var notificationQueue: NotificationQueue? { get }
  var postingStyle: PostingStyle { get }
  var coalescing: NotificationCoalescing { get }

  static var notificationQueue: NotificationQueue? { get }
  static var postingStyle: PostingStyle { get }
  static var coalescing: NotificationCoalescing { get }

}


extension NotificationDispatching {

  public var notificationQueue: NotificationQueue? { NotificationQueue.default }
  public var postingStyle: PostingStyle { .now }
  public var coalescing: NotificationCoalescing { [.onName, .onSender] }

  public static var notificationQueue: NotificationQueue? { .default }
  public static var postingStyle: PostingStyle { .now }
  public static var coalescing: NotificationCoalescing { [.onName, .onSender] }

  public func postNotification(name: NotificationName,
                               object: Any? = nil,
                               userInfo: [AnyHashable:Any]? = nil)
  {
    let notificationName = Notification.Name(rawValue: name.description)
    let notification = Notification(name: notificationName, object: object, userInfo: userInfo)
    if let queue = notificationQueue {
      queue.enqueue(notification,
                    postingStyle: postingStyle,
                    coalesceMask: coalescing,
                    forModes: nil)
    } else {
      NotificationCenter.default.post(notification)
    }
  }

  public static func postNotification(name: NotificationName,
                                      object: Any? = nil,
                                      userInfo: [AnyHashable:Any]? = nil)
  {
    let notificationName = Notification.Name(rawValue: name.description)
    let notification = Notification(name: notificationName, object: object, userInfo: userInfo)
    if let queue = notificationQueue {
      queue.enqueue(notification,
                    postingStyle: postingStyle,
                    coalesceMask: coalescing,
                    forModes: nil)
    } else {
      NotificationCenter.default.post(notification)
    }
  }

}
