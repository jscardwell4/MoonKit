//
//  DebugConsoleView.swift
//  MoonKit
//
//  Created by Jason Cardwell on 5/12/18.
//  Copyright © 2018 Moondeer Studios. All rights reserved.
//
import Foundation

#if os(iOS)

import UIKit
public typealias TextView = UITextView
public typealias TextViewDelegate = UITextViewDelegate

#else

import AppKit
public typealias TextView = NSTextView
public typealias TextViewDelegate = NSTextViewDelegate

#endif

/// A subclass of `UITextView` for displaying debug messages.
public final class DebugConsoleView: TextView {

  /// Overridden to prevent the assignment of a delegate.
  public override var delegate: TextViewDelegate? {
    get { return nil }
    set { super.delegate = nil }
  }

  /// Overridden to prevent editing.
  public override var isEditable: Bool {
    get { return false }
    set { super.isEditable = false }
  }

  /// Overridden to prevent selection.
  public override var isSelectable: Bool {
    get { return false }
    set { super.isSelectable = false }
  }

  #if os(iOS)

  /// Overridden to prevent data detection.
  public override var dataDetectorTypes: UIDataDetectorTypes {
    get { return [] }
    set { super.dataDetectorTypes = [] }
  }

  /// Overridden to prevent text attribute editing.
  public override var allowsEditingTextAttributes: Bool {
    get { return false }
    set { super.allowsEditingTextAttributes = false }
  }

  #else

  public override var isAutomaticDataDetectionEnabled: Bool {
    get { return false }
    set { super.isAutomaticDataDetectionEnabled = false }
  }

  #endif

  #if os(iOS)

  /// Overridden to prevent assigning text.
  public override var text: String! {
    get { return super.text }
    set {}
  }

  /// Overridden to prevent assigning text.
  public override var attributedText: NSAttributedString! {
    get { return super.attributedText }
    set {}
  }

  #else

  /// Overridden to prevent assigning text.
  public override var string: String {
    get { return super.string }
    set {}
  }

  #endif

  /// Overridden to initialize the `attributedText` with the 'Debug Console' header.
  ///
  /// - Parameters:
  ///   - frame: The frame for the debug console.
  ///   - textContainer: The text container or `nil`.
  public override init(frame: CGRect, textContainer: NSTextContainer?) {
    super.init(frame: frame, textContainer: textContainer)
    addHeader()
  }

  /// Overridden to initialize the `attributedText` with the 'Debug Console' header.
  ///
  /// - Parameter aDecoder: The decoder with an instance of `DebugConsoleView`.
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    addHeader()
  }

  /// Initializes `attributedText` with the 'Debug Console' header.
  private func addHeader() {
    #if os(iOS)
    super.attributedText = NSAttributedString(string: "\n", attributes: nil)
    #else
    textStorage?.append(NSAttributedString(string: "\n"))
    #endif
  }

  /// Updates the content offset such that the content and console are bottom-aligned.
  public func scrollToBottom() {

    #if os(iOS)
    let textContainer = self.textContainer
    #else
    guard let textContainer = textContainer else { fatalError("\(#function) nil container.") }
    guard let layoutManager = layoutManager else { fatalError("\(#function) nil layout manager.") }
    #endif

    // Get the glyph range for the text container.
    let glyphRange = layoutManager.glyphRange(for: textContainer)

    // Get the bounding rectangle for the full glyph range.
    let contentBounds = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)

    #if os(iOS)

    let boundingHeight = bounds.height

    #else

    guard let clipView = superview as? NSClipView else {
      fatalError("\(#function) console to embedded inside a clip view.")
    }

    let boundingHeight = clipView.bounds.height

    #endif

    // Calculate the difference between the height of the content and of the console.
    let 𝝙height = contentBounds.height - boundingHeight

    // Ensure the content does not all fit within the console's bounds.
    guard 𝝙height > 0 else { return }

    #if os(iOS)

    // Update the content offset.
    setContentOffset(CGPoint(x: 0, y: 𝝙height), animated: !isHidden)

    #else

    // Scroll to the new origin.
    scroll(NSPoint(x: 0, y: 𝝙height))

    #endif

  }

  /// Appends the specified log message to the console's `attributedText`.
  ///
  /// - Parameters:
  ///   - content: The content of the log message.
  ///   - level: The log level associated with the log message.
  public func append(message content: String, level: Logger.LogLevel) {

    // Initialize the message with the log level tag.
    let message = NSMutableAttributedString(attributedString: level.attributedTag)

    // Append a separator followed by the message content.
    message.append(": \(content)\n", style: .regular, color: .label)

    #if os(iOS)
    // Get the current attributed text.
    let attributedText = NSMutableAttributedString(attributedString: self.attributedText)
    #else
    guard let attributedText = textStorage else { fatalError("\(#function) `textStorage == nil`.") }
    #endif

    // Append the new message.
    attributedText.append(message)

    #if os(iOS)
    // Update `attributedText` using the `super` property setter.
    super.attributedText = attributedText
    #endif

    // Update the content offset.
    scrollToBottom()


  }

}
