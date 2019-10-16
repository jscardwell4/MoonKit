//
//  Logging.swift
//  MoonKit
//
//  Created by Jason Cardwell on 1/20/18.
//  Copyright © 2018 Moondeer Studios. All rights reserved.
//
import Foundation

#if os(iOS)
import class UIKit.UIColor
#else
import class AppKit.NSColor
#endif

public final class Logger {

  /// The shared singleton instance of `Logger`.
  public static let shared: Logger = Logger()

  /// Background priority queue used for logging messages.
  private let logQueue = DispatchQueue(label: "com.moonkit.logging", qos: .background)

  /// The default initializer for `Logger`.
  private init() {}

  /// The current log level controlling which messages are actually logged.
  public var logLevel: LogLevel = .warning

  /// Flag indicating whether the debug console view will be enabled.
  public var enableDebugConsole = true

  /// An array for holding log message content dispatched when `enableDebugConsole == true` but
  /// `debugConsoleView == nil`
  private var debugConsoleBuffer: [(LogLevel, String)] = []

  /// The `UITextView` serving as the debug console or `nil`.
  public weak var debugConsoleView: DebugConsoleView? {
    didSet {

      // Ensure the console view has changed from `nil` to an actual view.
      guard debugConsoleView != nil && debugConsoleView != oldValue else { return }

      // Append each of the buffered log messages.
      for (level, message) in debugConsoleBuffer {
        debugConsoleView!.append(message: message, level: level)
      }

      // Empty the buffer.
      debugConsoleBuffer.removeAll()

    }
  }

  /// Logs the specified message unless `level` is not included in the shared `Environment`
  /// instance's `logLevel`.
  ///
  /// - Parameters:
  ///   - format: he format of the message.
  ///   - arguments: Any arguments required by `format`.
  ///   - level: The log level for the message.
  public func log(_ format: String, _ arguments: [CVarArg], level: LogLevel) {

    // Check the log level.
    guard logLevel.includes(level: level) else { return }
    
    // Move to the logging queue.
    logQueue.async {

      [unowned self] in

      // Compose the message content.
      let message = String(format: "\(format)\n", arguments: arguments)

      // Print the message.
      self.logQueue.async { print(level.tag, ": ", message, separator: "", terminator: "") }

      // Check whether the debug console is enabled.
      guard self.enableDebugConsole else { return }

      // Check whether the debug console view has been set.
      switch self.debugConsoleView {

        case nil:
          // Store the message in the buffer.

          self.debugConsoleBuffer.append((level, message))

        case let view?:
          // Append the message to the debug console view's text.

          DispatchQueue.main.async { view.append(message: message, level: level) }

      }

    }

  }

}

extension Logger {

  /// An enumeration of available log levels.
  public enum LogLevel: String {
    case none, error, warning, info, verbose

    #if os(iOS)
    public typealias Color = UIColor
    #else
    public typealias Color = NSColor
    #endif

    public var color: Color {
      switch self {
        case .none:    return #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        case .error:   return #colorLiteral(red: 0.5807225108, green: 0.066734083, blue: 0, alpha: 1)
        case .warning: return #colorLiteral(red: 0.5738074183, green: 0.5655357838, blue: 0, alpha: 1)
        case .info:    return #colorLiteral(red: 0.1960784346, green: 0.3411764801, blue: 0.1019607857, alpha: 1)
        case .verbose: return #colorLiteral(red: 0, green: 0.3285208941, blue: 0.5748849511, alpha: 1)
      }
    }

    public func includes(level: LogLevel) -> Bool {
      switch self {
        case .none:    return false
        case .error:   return level == .error
        case .warning: return level != .info && level != .verbose
        case .info :   return level != .verbose
        case .verbose: return true
      }
    }

    public var tag: String {
      switch self {
        case .none:  return ""
        default: return rawValue
      }
    }

    public var attributedTag: NSAttributedString {
      return NSAttributedString(tag, style: .italic, color: color)
    }

  }

}

/// A function for logging messages that takes variadic format arguments.
///
/// - Parameters:
///   - format: The string containing the message format.
///   - arguments: Any arguments used by `format`.
///   - level: The log level to associate with the log message.
public func log(_ format: String, _ arguments: CVarArg..., level: Logger.LogLevel) {
  log(format, arguments, level: level)
}

/// A function for logging messages that takes an array of format arguments.
///
/// - Parameters:
///   - format: The string containing the message format.
///   - arguments: Any arguments used by `format`.
///   - level: The log level to associate with the log message.
public func log(_ format: String, _ arguments: [CVarArg], level: Logger.LogLevel) {
  Logger.shared.log(format, arguments, level: level)
}

/// Function of convenience for invoking `log(_:_,level:)` with `level == .error`.
///
/// - Parameters:
///   - format: The string containing the message format.
///   - arguments: Any arguments used by `format`.
public func loge(_ format: String, _ arguments: CVarArg...) { log(format, arguments, level: .error  ) }

/// Function of convenience for invoking `log(_:_,level:)` with `level == .warning`.
///
/// - Parameters:
///   - format: The string containing the message format.
///   - arguments: Any arguments used by `format`.
public func logw(_ format: String, _ arguments: CVarArg...) { log(format, arguments, level: .warning) }

/// Function of convenience for invoking `log(_:_,level:)` with `level == .info`.
///
/// - Parameters:
///   - format: The string containing the message format.
///   - arguments: Any arguments used by `format`.
public func logi(_ format: String, _ arguments: CVarArg...) { log(format, arguments, level: .info   ) }

/// Function of convenience for invoking `log(_:_,level:)` with `level == .verbose`.
///
/// - Parameters:
///   - format: The string containing the message format.
///   - arguments: Any arguments used by `format`.
public func logv(_ format: String, _ arguments: CVarArg...) { log(format, arguments, level: .verbose) }

