//
//  KVOReceptionist.swift
//  MoonKit
//
//  Created by Jason Cardwell on 4/30/15.
//  Copyright (c) 2015 Jason Cardwell. All rights reserved.
//

import Foundation

fileprivate(set) var observingContext = UnsafeMutableRawPointer.allocate(byteCount: 1, alignment: 1)

public final class KVOReceptionist: NSObject {

  /// The callback invoked upon a key-value observation.
  ///
  /// - parameters:
  ///    - keyPath: The observed key path.
  ///    - object: The observed object.
  ///    - changeDictionary: The dictionary of observed changes.
  
  public typealias Callback = (_ keyPath: String,
                               _ object: NSObject,
                               _ changeDictionary: [NSKeyValueChangeKey:Any]) -> Void

  /// Index of KVO registrations. The `key` values are identifiers for the objects being observed.
  /// The `value` values are dictionaries mapping keypaths to observation data.
  private var observations: [Weak<NSObject>:[String:(queue: OperationQueue, callback: Callback)]] = [:]

  /// Registers the receptionist for changes to `keypath` of `object`.
  public func observe(object: NSObject,
                      forChangesTo keyPath: String,
                      withOptions options: NSKeyValueObservingOptions = .new,
                      queue: OperationQueue = OperationQueue.main,
                      callback: @escaping (String, Any, [NSKeyValueChangeKey:Any]) -> Void)
  {

    let weakObject = Weak(object)
    var bag = observations[weakObject] ?? [:]

    bag[keyPath] = (queue: queue, callback: callback)
    observations[weakObject] = bag

    object.addObserver(self, forKeyPath: keyPath, options: options, context: observingContext)
  }

  /// Removes receptionist as observer for changes to `keyPath` of `object`.
  public func stopObserving(object: NSObject, forChangesTo keyPath: String) {

    let weakObject = Weak(object)

    guard var bag = observations[weakObject] else { return }
    bag[keyPath] = nil

    observations[weakObject] = bag.isEmpty ? nil : bag

    object.removeObserver(self, forKeyPath: keyPath, context: observingContext)

  }

  /// Remove any observation registrations that remain before deallocation.
  deinit {

    for weakObject in observations.keys {

      guard let object = weakObject.reference,
            let keyPaths = observations[weakObject]?.keys
        else
      {
        continue
      }

      for keyPath in keyPaths {
        object.removeObserver(self, forKeyPath: keyPath, context: observingContext)
      }

    }

    observations.removeAll()

  }

  /// Locates queue and callback associated with `object` and `keyPath` and invokes `callback` on `queue`.
  public override func observeValue(forKeyPath keyPath: String?,
                                    of object: Any?,
                                    change: [NSKeyValueChangeKey:Any]?,
                                    context: UnsafeMutableRawPointer?)
  {
    guard context == observingContext,
          let keyPath = keyPath,
          let object = object as? NSObject,
          let change = change,
          let (queue, callback) = observations[Weak(object)]?[keyPath]
      else
    {
      return
    }

    queue.addOperation { callback(keyPath, object, change) }

  }

}
