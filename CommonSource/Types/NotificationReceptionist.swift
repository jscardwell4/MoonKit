//
//  NotificationReceptionist.swift
//  MoonKit
//
//  Created by Jason Cardwell on 5/15/15.
//  Copyright (c) 2015 Jason Cardwell. All rights reserved.
//
import Foundation

/// A type for managing registration and reception of notifications.
public final class NotificationReceptionist: NSObject {

  /// Returns the `ObservationInfo` in `infos` matching the specified `notification` or `nil`.
  private subscript(notification: Notification) -> ObservationInfo? {
    return infos.first(where: {$0.match(notification)})
      ?? groups.values.joined().first(where: {$0.match(notification)})
  }

  /// Processes the received `notification` by invoking the registered callback on an
  /// appropriate queue
  @objc private func receiveNotification(_ notification: Notification) {
    guard let info = self[notification] else { return }
    (info.queue ?? callbackQueue ?? OperationQueue.current ?? OperationQueue.main).addOperation {
      info.callback(notification)
    }
  }

  /// The store of registrations.
  private var infos: Set<ObservationInfo> = []

  /// The store grouped registrations.
  private var groups: [UUID:Set<ObservationInfo>] = [:]

  /// The group identifier for batched registrations.
  private var batchUUID: UUID?

  /// Generates and returns a group identifier for operations within `performRegistrations`.
  /// Any registrations within `performRegistrations` that are not one-time registrations 
  /// are grouped by the `UUID` returned by this method. This identifier can then be used
  /// to unregister the group in one call.
  public func batch(_ performRegistrations: () -> Void) -> UUID {

    let uuid = UUID()

    batchUUID = uuid

    performRegistrations()

    batchUUID = nil

    return uuid

  }

  /// The queue upon which callbacks are scheduled upon receipt of a notification
  public var callbackQueue: OperationQueue?

  /// Create an new instance with the specified `callbackQueue`
  public init(callbackQueue queue: OperationQueue? = nil) {
    super.init()
    callbackQueue = queue
  }

  /// The total number of registrations.
  public var count: Int { return infos.count + groups.values.map({$0.count}).reduce(0, +) }

  /// Invokes `observe(name:from:queue:callback:)` for each object in `objects`.
  /// - Parameter name: The name of the notiication to observe.
  /// - Parameter objects: The collection of objects to observe.
  /// - Parameter queue: The queue upon which to invoke `callback`, default is `nil`.
  /// - Parameter callback: The handler for received notifications.
  /// - Parameter notification: The notification received by the receptionist.
  public func observe(name: String,
                      fromObjects objects: [AnyObject],
                      queue: OperationQueue? = nil,
                      callback: @escaping (_ notification: Notification) -> Void)
  {
    objects.forEach { observe(name: name, from: $0, queue: queue, callback: callback) }
  }

  /// Invokes `observeOnce(name:from:queue:callback:)` for each object in `objects`
  /// - Parameter name: The name of the notiication to observe.
  /// - Parameter objects: The collection of objects to observe.
  /// - Parameter queue: The queue upon which to invoke `callback`, default is `nil`.
  /// - Parameter callback: The handler for received notifications.
  /// - Parameter notification: The notification received by the receptionist.
  public func observeOnce(name: String,
                          fromObjects objects: [AnyObject],
                          queue: OperationQueue? = nil,
                          callback: @escaping (_ notification: Notification) -> Void)
  {
    objects.forEach { observeOnce(name: name, from: $0, queue: queue, callback: callback) }
  }

  /// Registers with the default `NSNotificationCenter` to receive notifications named `name` from
  /// object `object`; `ObervationInfo` is created for this registration and inserted into `infos`
  /// to be retrieved as notifications are received unless within the body of a closure passed to
  /// `batch(:)`; in which case, the observation info is added to open group.
  ///
  /// - Parameter name: The name of the notification for which to register the observer
  /// - Parameter object: The object whose notifications shall be received; passing `nil` will
  ///                      cause the receptionist to receive all notifications with `name`.
  /// - Parameter queue: The operation queue upon which to invoke `callback`, default is `nil`.
  ///                    The actual queue used is determined by checking the following values in this order:
  ///                    `queue`, `self.callbackQueue`, `OperationQueue.current`, `OperationQueue.main`.
  /// - Parameter callback: The code to run when a notification has been received.
  /// - Parameter notification: The notification received by the receptionist.
  @objc(observeName:from:queue:callback:)
  public func observe(name: Notification.Name,
                      from object: AnyObject? = nil,
                      queue: OperationQueue? = nil,
                      callback: @escaping (_ notification: Notification) -> Void)
  {

    // Register with the notification center.
    let selector = #selector(NotificationReceptionist.receiveNotification(_:))
    NotificationCenter.default.addObserver(self, selector: selector, name: name, object: object)

    // Check that there is an identifier for grouping; otherwise, store in `infos`.
    guard let batchUUID = batchUUID else {
      infos.insert(ObservationInfo(name: name, object: Weak(object), callback: callback, queue: queue))
      return
    }

    // Add the info to the group.
    var batchedInfos = groups[batchUUID] ?? []
    batchedInfos.insert(ObservationInfo(name: name, object: Weak(object), callback: callback, queue: queue))
    groups[batchUUID] = batchedInfos
    
  }
  
  /// Registers with the default `NSNotificationCenter` to receive notifications named `name` from
  /// object `object`; `ObervationInfo` is created for this registration and inserted into `infos` 
  /// to be retrieved as notifications are received unless within the body of a closure passed to
  /// `batch(:)`; in which case, the observation info is added to open group.
  ///
  /// - Parameter name: The name of the notification for which to register the observer
  /// - Parameter object: The object whose notifications shall be received; passing `nil` will
  ///                      cause the receptionist to receive all notifications with `name`.
  /// - Parameter queue: The operation queue upon which to invoke `callback`, default is `nil`.
  ///                    The actual queue used is determined by checking the following values in this order:
  ///                    `queue`, `self.callbackQueue`, `OperationQueue.current`, `OperationQueue.main`.
  /// - Parameter callback: The code to run when a notification has been received.
  /// - Parameter notification: The notification received by the receptionist.
  public func observe(name: String,
                      from object: AnyObject? = nil,
                      queue: OperationQueue? = nil,
                      callback: @escaping (_ notification: Notification) -> Void)
  {

    // Register with the notification center.
    let name = Notification.Name(rawValue: name)
    let selector = #selector(NotificationReceptionist.receiveNotification(_:))
    NotificationCenter.default.addObserver(self, selector: selector, name: name, object: object)

    // Check that there is an identifier for grouping; otherwise, store in `infos`.
    guard let batchUUID = batchUUID else {
      infos.insert(ObservationInfo(name: name, object: Weak(object), callback: callback, queue: queue))
      return
    }

    // Add the info to the group.
    var batchedInfos = groups[batchUUID] ?? []
    batchedInfos.insert(ObservationInfo(name: name, object: Weak(object), callback: callback, queue: queue))
    groups[batchUUID] = batchedInfos

  }

  /// Registers with the default `NSNotificationCenter` to receive notifications named `name` from
  /// object `object`; `ObervationInfo` is created for this registration and inserted into `infos`
  /// to be retrieved as notifications are received.
  ///
  /// - Parameter name: The name of the notification for which to register the observer
  /// - Parameter object: The object whose notifications shall be received; passing `nil` will
  ///                      cause the receptionist to receive all notifications with `name`.
  /// - Parameter queue: The operation queue upon which to invoke `callback`, default is `nil`.
  ///                    The actual queue used is determined by checking the following values in this order:
  ///                    `queue`, `self.callbackQueue`, `OperationQueue.current`, `OperationQueue.main`.
  /// - Parameter callback: The code to run when a notification has been received.
  /// - Parameter notification: The notification received by the receptionist.
  public func observe<N>(name: N.NotificationName,
                      from object: N,
                      queue: OperationQueue? = nil,
                      callback: @escaping (_ notification: Notification) -> Void)
    where N:NotificationDispatching
  {
    observe(name: name.description, from: object as AnyObject?, queue: queue, callback: callback)
  }

  /// Registers with the default `NSNotificationCenter` to receive notifications named `name` from
  /// object `object`; `ObervationInfo` is created for this registration and inserted into `infos`
  /// to be retrieved as notifications are received.
  ///
  /// - Parameter name: The name of the notification for which to register the observer
  /// - Parameter object: The class whose notifications shall be received; passing `nil` will
  ///                      cause the receptionist to receive all notifications with `name`.
  /// - Parameter queue: The operation queue upon which to invoke `callback`, default is `nil`.
  ///                    The actual queue used is determined by checking the following values in this order:
  ///                    `queue`, `self.callbackQueue`, `OperationQueue.current`, `OperationQueue.main`.
  /// - Parameter callback: The code to run when a notification has been received.
  /// - Parameter notification: The notification received by the receptionist.
  public func observe<N>(name: N.NotificationName,
                      from object: N.Type,
                      queue: OperationQueue? = nil,
                      callback: @escaping (_ notification: Notification) -> Void)
    where N:NotificationDispatching
  {
    observe(name: name.description, from: object as AnyObject?, queue: queue, callback: callback)
  }

  /// Registers with the default `NSNotificationCenter` to receive notifications named `name` from
  /// object `object`; `ObervationInfo` is created for this registration and inserted into `infos`
  /// to be retrieved as notifications are received. Upon receiving a notification, `callback` is
  /// invoked and the receptionist unregisters for notifications named `name` from `object`.
  ///
  /// - Parameter name: The name of the notification for which to register the observer
  /// - Parameter object: The object whose notifications shall be received; passing `nil` will
  ///                      cause the receptionist to receive all notifications with `name`.
  /// - Parameter queue: The operation queue upon which to invoke `callback`, default is `nil`.
  ///                    The actual queue used is determined by checking the following values in this order:
  ///                    `queue`, `self.callbackQueue`, `OperationQueue.current`, `OperationQueue.main`.
  /// - Parameter callback: The code to run when a notification has been received.
  /// - Parameter notification: The notification received by the receptionist.
  @objc(observeOnceWithNotificationName:from:queue:callback:)
  public func observeOnce(name: Notification.Name,
                          from object: AnyObject? = nil,
                          queue: OperationQueue? = nil,
                          callback: @escaping (_ notification: Notification) -> Void)
  {

    observe(name: name, from: object, queue: queue) {
      [unowned self] notification in

      callback(notification)

      guard let info = self[notification] else {
        fatalError("info lookup failed for received notification: \(notification)")
      }

      self.stopObserving(info: info)
      
    }
    
  }
  
  /// Registers with the default `NSNotificationCenter` to receive notifications named `name` from
  /// object `object`; `ObervationInfo` is created for this registration and inserted into `infos`
  /// to be retrieved as notifications are received. Upon receiving a notification, `callback` is
  /// invoked and the receptionist unregisters for notifications named `name` from `object`.
  ///
  /// - Parameter name: The name of the notification for which to register the observer
  /// - Parameter object: The object whose notifications shall be received; passing `nil` will
  ///                      cause the receptionist to receive all notifications with `name`.
  /// - Parameter queue: The operation queue upon which to invoke `callback`, default is `nil`.
  ///                    The actual queue used is determined by checking the following values in this order:
  ///                    `queue`, `self.callbackQueue`, `OperationQueue.current`, `OperationQueue.main`.
  /// - Parameter callback: The code to run when a notification has been received.
  /// - Parameter notification: The notification received by the receptionist.
  public func observeOnce(name: String,
                          from object: AnyObject? = nil,
                          queue: OperationQueue? = nil,
                          callback: @escaping (_ notification: Notification) -> Void)
  {

    observe(name: name, from: object, queue: queue) {
      [unowned self] notification in

      callback(notification)

      guard let info = self[notification] else {
        fatalError("info lookup failed for received notification: \(notification)")
      }

      self.stopObserving(info: info)

    }

  }

  /// Registers with the default `NSNotificationCenter` to receive notifications named `name` from
  /// object `object`; `ObervationInfo` is created for this registration and inserted into `infos`
  /// to be retrieved as notifications are received. Upon receiving a notification, `callback` is
  /// invoked and the receptionist unregisters for notifications named `name` from `object`.
  ///
  /// - Parameter name: The name of the notification for which to register the observer
  /// - Parameter object: The object whose notifications shall be received; passing `nil` will
  ///                      cause the receptionist to receive all notifications with `name`.
  /// - Parameter queue: The operation queue upon which to invoke `callback`, default is `nil`.
  ///                    The actual queue used is determined by checking the following values in this order:
  ///                    `queue`, `self.callbackQueue`, `OperationQueue.current`, `OperationQueue.main`.
  /// - Parameter callback: The code to run when a notification has been received.
  /// - Parameter notification: The notification received by the receptionist.
  public func observeOnce<N>(name: N.NotificationName,
                          from object: N,
                          queue: OperationQueue? = nil,
                          callback: @escaping (_ notification: Notification) -> Void)
    where N:NotificationDispatching
  {
    observeOnce(name: name.description, from: object as AnyObject?, queue: queue, callback: callback)
  }

  /// Registers with the default `NSNotificationCenter` to receive notifications named `name` from
  /// object `object`; `ObervationInfo` is created for this registration and inserted into `infos`
  /// to be retrieved as notifications are received. Upon receiving a notification, `callback` is
  /// invoked and the receptionist unregisters for notifications named `name` from `object`.
  ///
  /// - Parameter name: The name of the notification for which to register the observer
  /// - Parameter object: The class whose notifications shall be received; passing `nil` will
  ///                      cause the receptionist to receive all notifications with `name`.
  /// - Parameter queue: The operation queue upon which to invoke `callback`, default is `nil`.
  ///                    The actual queue used is determined by checking the following values in this order:
  ///                    `queue`, `self.callbackQueue`, `OperationQueue.current`, `OperationQueue.main`.
  /// - Parameter callback: The code to run when a notification has been received.
  /// - Parameter notification: The notification received by the receptionist.
  public func observeOnce<N>(name: N.NotificationName,
                          from object: N.Type,
                          queue: OperationQueue? = nil,
                          callback: @escaping (_ notification: Notification) -> Void)
    where N:NotificationDispatching
  {
    observeOnce(name: name.description, from: object as AnyObject?, queue: queue, callback: callback)
  }

  /// Unregisters the receptionist with the default notification center for notifications from `object`
  /// with name `name`. Does not include grouped registrations.
  ///
  /// Passing `nil` for `name` will unregister for all notifications from `object`.
  ///
  /// Passing `nil` for `object` will unregister for all notifications with `name`.
  ///
  /// Passing `nil` for both `name` and `object` will unregister for all notifications for which the
  /// receptionist is currently registered.
  @objc(stopObservingNotificationName:from:)
  public func stopObserving(name: Notification.Name?, from object: AnyObject? = nil) {

    switch (name, object) {
      case let (name?, object?):
        stopObserving(infos.filter({ $0.name == name && $0.object?.reference === object }))
      case let (nil, object?):
        stopObserving(infos.filter({ $0.object?.reference === object}))
      case let (name?, nil):
        stopObserving(infos.filter({ $0.name == name && $0.object == nil }))
      case (nil, nil):
        stopObserving(infos)
    }

  }

  /// Unregisters the receptionist with the default notification center for notifications from `object`
  /// with name `name`. Does not include grouped registrations.
  ///
  /// Passing `nil` for `name` will unregister for all notifications from `object`.
  ///
  /// Passing `nil` for `object` will unregister for all notifications with `name`.
  ///
  /// Passing `nil` for both `name` and `object` will unregister for all notifications for which the
  /// receptionist is currently registered.
  public func stopObserving(name: String?, from object: AnyObject? = nil) {

    switch (name, object) {
      case let (name?, object?):
        stopObserving(infos.filter({ $0.name.rawValue == name && $0.object?.reference === object }))
      case let (nil, object?):
        stopObserving(infos.filter({ $0.object?.reference === object}))
      case let (name?, nil):
        stopObserving(infos.filter({ $0.name.rawValue == name && $0.object == nil }))
      case (nil, nil):
        stopObserving(infos)
    }

  }

  /// Unregisters the receptionist with the default notification center for notifications from `object`
  /// with name `name`. Does not include grouped registrations.
  ///
  /// Passing `nil` for `name` will unregister for all notifications from `object`.
  ///
  /// Passing `nil` for `object` will unregister for all notifications with `name`.
  ///
  /// Passing `nil` for both `name` and `object` will unregister for all notifications for which the
  /// receptionist is currently registered.
  public func stopObserving<N>(name: N.NotificationName, from object: N)
    where N:NotificationDispatching
  {
    stopObserving(name: name.description, from: object as AnyObject?)
  }

  /// Unregisters the receptionist with the default notification center for notifications from `object`
  /// with name `name`. Does not include grouped registrations.
  ///
  /// Passing `nil` for `name` will unregister for all notifications from `object`.
  ///
  /// Passing `nil` for `object` will unregister for all notifications with `name`.
  ///
  /// Passing `nil` for both `name` and `object` will unregister for all notifications for which the
  /// receptionist is currently registered.
  public func stopObserving<N>(name: N.NotificationName, from object: N.Type)
    where N:NotificationDispatching
  {
    stopObserving(name: name.description, from: object as AnyObject?)
  }

  /// Unregisters the receptionist with the default notification center for all notifications from `object`
  public func stopObserving(object: AnyObject) {
    infos.filter({$0.object?.reference === object}).forEach({stopObserving(info: $0)})
  }

  /// Unregisters the receptionist for all registrations identified by `group`.
  public func stopObserving(group: UUID) {
    guard let batchedInfos = groups.removeValue(forKey: group) else { return }
    for info in batchedInfos {
      stopObserving(info: info)
    }
  }

  /// Unregisters the receptionist with the default notification using the `name` and `object` values from `info`
  private func stopObserving(info: ObservationInfo) {
    NotificationCenter.default.removeObserver(self, name: info.name, object: info.object?.reference)
  }

  /// Invokes `stopObserving(info:)` for each `info` in `infos`
  private func stopObserving<S:Sequence>(_ infos: S) where S.Iterator.Element == ObservationInfo {

    for info in infos {
      stopObserving(info: info)
      self.infos.remove(info)
    }

  }

  deinit {
    stopObserving(infos)
    for uuid in groups.keys { stopObserving(group: uuid) }
  }

  /// A structure for storing the notification registration data.
  private struct ObservationInfo: Hashable {

    /// The name of the observed notification.
    let name: Notification.Name

    /// The object from which the receptionist is registered to receive notifications.
    let object: Weak<AnyObject>?

    /// The handler invoke when a notification is received.
    /// - Parameter notification: The received notification.
    let callback: (_ notification: Notification) -> Void

    /// The queue upon which the handler is to be invoked.
    weak var queue: OperationQueue?

    /// Returns `true` iff `name == notification.name` and the observed objects are equal or both `nil`.
    func match(_ notification: Notification) -> Bool {

      // Check that the names match.
      guard name == notification.name else { return false }

      switch (object?.reference, notification.object) {

        case let (obj1?, obj2 as AnyObject):
          // Check for identical objects.

          return obj1 === obj2

        case (nil, nil),
             (nil, .some) where object == nil:
          return true

        default: return false

      }

    }

    func hash(into hasher: inout Hasher) {
      name.hash(into: &hasher)
      object?.hash(into: &hasher)
    }

    /// Returns `true` iff `lhs` and `rhs` have equal `name` and `object` values.
    static func ==(lhs: ObservationInfo, rhs: ObservationInfo) -> Bool {
      return lhs.name == rhs.name && lhs.object == rhs.object
    }

  }

}

