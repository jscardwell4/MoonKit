//
//  LabelButton.swift
//  MoonKit
//
//  Created by Jason Cardwell on 5/23/15.
//  Copyright (c) 2015 Jason Cardwell. All rights reserved.
//

import UIKit

@IBDesignable
public class LabelButton: ToggleControl {

  public typealias Action = (LabelButton) -> Void

  /**
  intrinsicContentSize

  - returns: CGSize
  */
  public override var intrinsicContentSize: CGSize {
    return text?.size(withAttributes: [NSAttributedString.Key.font: font]) ?? CGSize(square: UIView.noIntrinsicMetric)
  }

  public var actions: [Action] = []

  /**
  sendActionsForControlEvents:

  - parameter controlEvents: UIControlEvents
  */
  public override func sendActions(for controlEvents: UIControl.Event) {
    super.sendActions(for: controlEvents)
    if controlEvents ∋ .touchUpInside { actions.forEach({ $0(self) }) }
  }

  // MARK: - Wrapping Label

  @IBInspectable public var text: String? {
    didSet { guard text != oldValue else { return }; invalidateIntrinsicContentSize(); setNeedsDisplay() }
  }

  public var font: UIFont = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.headline) {
    didSet {
      dummyBaselineViewHeightConstraint?.constant = font.ascender
      invalidateIntrinsicContentSize()
      setNeedsDisplay()
    }
  }

  public enum TextAlignment: String {
    case Left, Center, Right

    var value: NSTextAlignment {
      switch self {
        case .Left: return .left
        case .Center: return .center
        case .Right: return .right
      }
    }
  }

  public var textAlignment: TextAlignment = .Center { didSet { setNeedsDisplay() } }

  @IBInspectable public var textAlignmentString: String {
    get { return textAlignment.rawValue }
    set {
      guard let alignment = TextAlignment(rawValue: newValue) , textAlignment != alignment else { return }
      textAlignment = alignment
    }
  }

  fileprivate lazy var dummyBaselineView: UIView = {
    let view = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.font.ascender))
    view.isUserInteractionEnabled = false
    view.translatesAutoresizingMaskIntoConstraints = false
    self.addSubview(view)
    self.dummyBaselineView = view
    self.constrain(𝗛∶|[view]|, 𝗩∶|[view])
    guard let constraint = (view.height == self.font.ascender).constraint else { fatalError("something bad happened") }
    constraint.isActive = true
    self.dummyBaselineViewHeightConstraint = constraint
    return view
  }()

  fileprivate weak var dummyBaselineViewHeightConstraint: NSLayoutConstraint?

  public override var forFirstBaselineLayout: UIView { return dummyBaselineView  }
  public override var forLastBaselineLayout: UIView { return dummyBaselineView  }

  @objc @IBInspectable fileprivate var fontName: String {
    get { return font.fontName }
    set { if let font = UIFont(name: newValue, size: font.pointSize) { self.font = font } }
  }

  @objc @IBInspectable fileprivate var fontSize: CGFloat {
    get { return font.pointSize }
    set { font = font.withSize(newValue) }
  }

  /**
  drawRect:

  - parameter rect: CGRect
  */
  public override func draw(_ rect: CGRect) {
    guard let text = text else { return }
    text.draw(in: rect, withAttributes: [
      NSAttributedString.Key.font: font,
      NSAttributedString.Key.foregroundColor: tintColor ?? .tertiaryLabel,
      NSAttributedString.Key.paragraphStyle: NSParagraphStyle.paragraphStyleWithAttributes(alignment: textAlignment.value)
      ])
  }

}
