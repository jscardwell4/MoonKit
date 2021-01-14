//
//  DirectoryMonitor.swift
//  MoonKit
//
//  Created by Jason Cardwell on 8/31/15.
//  Copyright © 2015 Jason Cardwell. All rights reserved.
//  source: This a port of code created by Martin Hwasser found here https://github.com/hwaxxer/MHWDirectoryWatcher
//

import Foundation

public final class DirectoryMonitor {

  /// The callback to invoke when the directory's contents have changed.
  public let callback: (_ added: [FileWrapper], _ removed: [FileWrapper]) -> Void

  /// The queue upon which `callback` shall be invoked.
  public var callbackQueue = OperationQueue.main

  /// The url of the directory to monitor
  public let directoryURL: URL

  /// The file wrapper for `directoryURL`.
  public let directoryWrapper: FileWrapper

  /// Whether the monitor is actively monitoring the directory.
  public var isMonitoring: Bool { return source != nil }

  /// Enumeration of possible errors thrown by `DirectoryMonitor`.
  public enum Error: String, Swift.Error {
    case notADirectory = "The URL provided must point to a directory"
  }

  /// Private queue used by the monitor.
  private let queue = DispatchQueue(label: "com.moondeerstudios.directorymonitor", qos: .background)

  /// The monitored source.
  private var source: DispatchSourceFileSystemObject?

  /// The handle whose file descriptor is provided to `source` for monitoring.
  private var fileHandle: FileHandle?

  private static let maxRetries = 5

  /// Default initializer for `DirectoryMonitor`.
  ///
  /// - Parameters:
  ///   - directoryURL: The url of the directory to monitor.
  ///   - start: Whether monitoring should start upon initialization. Default is `false`.
  ///   - callback: The closure to invoke when the monitored directory's contents have changed.
  ///   - added: An array of the names of files added to the directory.
  ///   - removed: An array of the names of files removed from the directory.
  /// - Throws: Any error thrown by `FileWrapper.init` or `Error.notADirectory` when `directoryURL`
  ///           does not actually point to a directory.
  public init(directoryURL: URL,
              start: Bool = false,
              callback: @escaping (_ added: [FileWrapper], _ removed: [FileWrapper]) -> Void) throws
  {

    self.directoryURL = directoryURL
    self.callback = callback

    directoryWrapper = try FileWrapper(url: directoryURL, options: [.immediate, .withoutMapping])
    cachedFileWrappers = directoryWrapper.fileWrappers

    guard directoryWrapper.isDirectory else { throw Error.notADirectory }

    if start { try startMonitoring() }
  }

  /// Invokes `stopMonitoring` to ensure the dispatch source is canceled.
  deinit { stopMonitoring() }

  /// Initializes and resumes `source` when `source == nil`; otherwise, does nothing.
  /// - Throws: Any error encountered creating a file handle for `directoryURL`.
  public func startMonitoring() throws {

    guard source == nil else { logw("already monitoring…"); return }

    let newHandle = try FileHandle(forReadingFrom: directoryURL)

    let newSource = DispatchSource.makeFileSystemObjectSource(fileDescriptor: newHandle.fileDescriptor,
                                                              eventMask: .write,
                                                              queue: .global(qos: .background))
    newSource.setEventHandler(handler: weakCapture(of: self, block: DirectoryMonitor.directoryDidChange))
    newSource.setCancelHandler(handler: { [weak self] in self?.fileHandle = nil })
    newSource.resume()

    fileHandle = newHandle
    source = newSource

  }

  /// Handler for `source` events. Begins polling when `!isDirectoryChanging`; otherwise, does nothing.
  private func directoryDidChange() {

    // Check we aren't already changing; otherwise, we should already be polling directory.
    guard !isPolling else { return }

    do {

      // Update flag, reset count.
      isPolling = true

      // Check the directory content again after `delay`.
      queue.asyncAfter(wallDeadline: DirectoryMonitor.delay) {
        [weak self, fileHash = try directoryFileHash()] in

        self?.pollDirectory(fileHash: fileHash)

      }

    } catch {

      // Simply log the error since we can't throw from within a `DispatchSourceHandler`.
      loge("\(error)")

    }

  }

  /// Cancels and nullifies `source` when `source != nil`.
  public func stopMonitoring() {

    guard let currentSource = source, currentSource.isCancelled == false else { return }

    currentSource.cancel()

    source = nil

  }

  /// Flag indicating whether the directory is currently being polled.
  private var isPolling = false {
    didSet {
      guard isPolling else { return }
      retryCount = DirectoryMonitor.maxRetries
    }
  }

  /// The number of invocations of `pollDirectory` that remain before polling should cease and the callback
  /// invoked with the current set of changes.
  private var retryCount = 0

  /// The most recent collection of file wrappers for the directory.
  private var cachedFileWrappers: [String:FileWrapper]?

  /// Determines which files have been added/removed and invokes `callback`.
  private func invokeCallback() {

    // Create sets for the old and new file wrappers that default to an empty set when `nil`.
    let oldWrappers = cachedFileWrappers == nil ? [] : Set(cachedFileWrappers!.values)
    let newWrappers = directoryWrapper.fileWrappers == nil ? [] : Set(directoryWrapper.fileWrappers!.values)

    // Get the names of added and removed files.
    let added = Array(newWrappers.subtracting(oldWrappers))
    let removed = Array(oldWrappers.subtracting(newWrappers))

    // Update the cache of file wrappers.
    cachedFileWrappers = directoryWrapper.fileWrappers

    // Invoke the callback
    callback(added, removed)

  }

  /// Returns a string composed of the unique file names and file sizes for the elements 
  /// in `directoryWrapper.fileWrappers`.
  private func directoryFileHash() throws -> String {

    // Refresh the directory wrapper from disk.
    try directoryWrapper.read(from: directoryURL, options: [.immediate, .withoutMapping])

    // Return a string formed by joining the name and size of each wrapper.
    return (directoryWrapper.fileWrappers ?? [:]).map({
      uniqueFileName, fileWrapper in

      "\(uniqueFileName)\(fileWrapper.fileAttributes[FileAttributeKey.size.rawValue] ?? 0)"

    }).joined(separator: ";")

  }

  /// Time between calls to `pollDirectory(filHash:)`.
  private static let delay = DispatchWallTime(seconds: 0.2)

  /// Checks `oldFileHash` against a new hash to do one of two things:
  /// 1) Schedule a new invocation of `pollDirectory(fileHash:)` with the new hash when the two hashes 
  /// are not equal or `retryCount > 0`.
  /// 2) Schedule `callback` on `callbackQueue` if the two hashes are equal and `0 < retryCount`.
  /// - parameter oldFileHash: The previous directory file hash to check for equality with a new hash.
  private func pollDirectory(fileHash oldFileHash: String) {

    do {

      let newFileHash = try directoryFileHash()

      // Continue polling, resetting the retry count, only if the two hashes are unequal.
      isPolling = newFileHash != oldFileHash

      switch isPolling {

        case true,
             false where 0 < retryCount:
          retryCount = retryCount &- 1
          queue.asyncAfter(wallDeadline: DirectoryMonitor.delay) {
            [weak self] in self?.pollDirectory(fileHash: newFileHash)
          }

        case false:
          callbackQueue.addOperation { [weak self] in self?.invokeCallback() }

      }

    } catch {

      // Simply log the error since we are invoked from within a closure that does not rethrow.
      loge("\(error)")

    }

  }

}
