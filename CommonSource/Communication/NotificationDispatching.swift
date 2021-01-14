//
//  NotificationDispatching.swift
//  MoonKit
//
//  Created by Jason Cardwell on 10/5/15.
//  Copyright © 2015 Jason Cardwell. All rights reserved.
//
import Foundation

// MARK: - NotificationDispatching

/// A protocol for types that dispatch notifications. Simplifies notification
/// posting via some default implementations.
public protocol NotificationDispatching
{
  /// The type used to generate the final `Notification.Name` value when posting.
  typealias Name = Notification.Name

  /// The type used to attach user info data to posted notifications.
  typealias UserInfo = [AnyHashable: Any]

  /// The type used to specify how notification's get posted to the notification center.
  typealias Style = NotificationQueue.PostingStyle

  /// The type used to specify how notification's are coalesced by the notification center.
  typealias Coalescing = NotificationQueue.NotificationCoalescing

  /// The notification queue used for posting notifications.
  var notificationQueue: NotificationQueue? { get }

  /// The style used when posting notifications.
  var postingStyle: Style { get }

  /// The way notifications shall be coalesced.
  var coalescing: Coalescing { get }

  /// The queue used for posting notifications via `class` or `static` methods.
  static var notificationQueue: NotificationQueue? { get }

  /// The style used when posting notifications via `class` or `static` methods.
  static var postingStyle: Style { get }

  /// The way notifications shall be coalesced via `class` or `static` methods.
  static var coalescing: Coalescing { get }

  /// The notification center to which notifications shall be posted.
  static var notificationCenter: NotificationCenter { get }

  /// Instance method used to post new notifications to the notification center.
  ///
  /// - Parameters:
  ///   - name: The notification's name.
  ///   - object: The object officially posting the notification.
  ///   - userInfo: The user info to send alongside the notification.
  func postNotification(name: Name, object: Any?, userInfo: UserInfo?)

  /// Type method used to post new notifications to the notification center.
  ///
  /// - Parameters:
  ///   - name: The notification's name.
  ///   - object: The object officially posting the notification.
  ///   - userInfo: The user info to send alongside the notification.
  static func postNotification(name: Name, object: Any?, userInfo: UserInfo?)
}

/// Default implementations for the properties and methods of `NotificationDispatching`.
public extension NotificationDispatching
{

  /// The notification queue used for posting notifications.
  /// The default value returned here is `.default`.
  var notificationQueue: NotificationQueue? { .default }

  /// The style used when posting notifications.
  /// The default value returned here is `.now`.
  var postingStyle: Style { .now }

  /// The way notifications shall be coalesced.
  /// The default value returned here is `[.onName, .onSender]`.
  var coalescing: Coalescing { [.onName, .onSender] }

  /// The queue used for posting notifications via `class` or `static` methods.
  /// The default value returned here is `.default`.
  static var notificationQueue: NotificationQueue? { .default }

  /// The style used when posting notifications via `class` or `static` methods.
  /// The default value returned here is `.now`.
  static var postingStyle: Style { .now }

  /// The way notifications shall be coalesced via `class` or `static` methods.
  /// The default value returned here is `[.onName, .onSender]`.
  static var coalescing: Coalescing { [.onName, .onSender] }

  /// The notification center to which notifications shall be posted.
  static var notificationCenter: NotificationCenter { .default }

  /// Instance method used to post new notifications to the notification center.
  ///
  /// - Parameters:
  ///   - name: The notification's name.
  ///   - object: The object officially posting the notification. Default is `nil`.
  ///   - userInfo: The user info to send alongside the notification. Default is `nil`.
  func postNotification(name: Name, object: Any? = nil, userInfo: UserInfo? = nil)
  {
    let notification = Notification(
      name: name,
      object: object,
      userInfo: userInfo
    )
    if let queue = notificationQueue
    {
      queue.enqueue(notification,
                    postingStyle: postingStyle,
                    coalesceMask: coalescing,
                    forModes: nil)
    }
    else
    {
      Self.notificationCenter.post(notification)
    }
  }

  /// Type method used to post new notifications to the notification center.
  ///
  /// - Parameters:
  ///   - name: The notification's name.
  ///   - object: The object officially posting the notification. Default is `nil`.
  ///   - userInfo: The user info to send alongside the notification. Default is `nil`.
  static func postNotification(name: Name, object: Any? = nil, userInfo: UserInfo? = nil)
  {
    let notification = Notification(name: name, object: object, userInfo: userInfo)

    if let queue = notificationQueue
    {
      queue.enqueue(notification,
                    postingStyle: postingStyle,
                    coalesceMask: coalescing,
                    forModes: nil)
    }
    else
    {
      NotificationCenter.default.post(notification)
    }
  }
}
