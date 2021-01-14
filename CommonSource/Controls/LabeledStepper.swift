//
//  LabeledStepper.swift
//  MoonKit
//
//  Created by Jason Cardwell on 5/20/15.
//  Copyright (c) 2015 Jason Cardwell. All rights reserved.
//

import UIKit

@IBDesignable
public class LabeledStepper: UIControl {

  public override init(frame: CGRect) { super.init(frame: frame); setup() }

  public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder); setup() }

  fileprivate func setup() {
    addSubview(label); addSubview(stepper)

    label.textColor = textColor
    label.font = font
    label.textAlignment = .right
    label.highlightedTextColor = highlightedTextColor
    updateLabel()

    stepper.setContentHuggingPriority(UILayoutPriority.required, for: .horizontal)
    stepper.addTarget(self, action: #selector(LabeledStepper.updateLabel), for: .valueChanged)
  }

  public override class var requiresConstraintBasedLayout: Bool { return true }

  public override func updateConstraints() {
    super.updateConstraints()
    let id = Identifier(for: self, tags: "Internal")
    guard constraints(withIdentifier: id).count == 0 else { return }
    constrain(identifier: id, 𝗛∶|[label]-8-[stepper]|)
    constrain(label.centerY == centerY --> id)
    constrain(stepper.centerY == label.centerY --> id)
  }

  public override var intrinsicContentSize: CGSize {
    let lsize = label.intrinsicContentSize
    let ssize = stepper.intrinsicContentSize
    return CGSize(width: lsize.width + 8 + ssize.width, height: max(lsize.height, ssize.height))
  }


  // MARK: - Label

  fileprivate let label = UILabel(autolayout: true, attributedText: nil)

  public override var forLastBaselineLayout: UIView { return label.forLastBaselineLayout }

  @objc fileprivate func updateLabel() {
    label.text = String(stepper.value, precision: precision)
    label.sizeToFit()
  }

  /// The number of characters from the fractional part of `stepper.value` to display, defaults to `0`
  public var precision = 0 { didSet { updateLabel() } }

  // MARK: Properties bounced to/from `UILabel` subview

  public static let defaultFont: UIFont = .preferredFont(forTextStyle: UIFont.TextStyle.headline)
  public var font: UIFont = LabeledStepper.defaultFont  { didSet { label.font = font } }

  @IBInspectable public var fontName: String  {
    get { return font.fontName }
    set { if let font = UIFont(name: newValue, size: self.font.pointSize) { self.font = font } }
  }

  @IBInspectable public var fontSize: CGFloat  {
    get { return font.pointSize }
    set { font = font.withSize(newValue) }
  }

  @IBInspectable public var highlightedTextColor: UIColor? { didSet { label.highlightedTextColor = highlightedTextColor } }

  @IBInspectable public var textColor: UIColor = UIColor.black { didSet { label.textColor = textColor } }

  @IBInspectable public var shadowColor: UIColor? { didSet { label.shadowColor = shadowColor } }

  @IBInspectable public var shadowOffset: CGSize = .zero { didSet { label.shadowOffset = shadowOffset } }

  @IBInspectable public var adjustsFontSizeToFitWidth: Bool {
    get { return label.adjustsFontSizeToFitWidth }
    set { label.adjustsFontSizeToFitWidth = newValue }
  }

  @IBInspectable public var baselineAdjustment: UIBaselineAdjustment {
    get { return label.baselineAdjustment }
    set { label.baselineAdjustment = newValue }
  }

  @IBInspectable public var minimumScaleFactor: CGFloat { get { return label.minimumScaleFactor } set { label.minimumScaleFactor = newValue } }

  @IBInspectable public var preferredMaxLayoutWidth: CGFloat {
    get { return label.preferredMaxLayoutWidth }
    set { label.preferredMaxLayoutWidth = newValue }
  }

  // MARK: - Stepper

  fileprivate let stepper = UIStepper(autolayout: true)

  // MARK: Properties bounced to/from the `UIStepper` subview

  @IBInspectable public var continuous: Bool { get { return stepper.isContinuous } set { stepper.isContinuous = newValue } }
  @IBInspectable public var autorepeat: Bool { get { return stepper.autorepeat } set { stepper.autorepeat = newValue } }
  @IBInspectable public var wraps: Bool { get { return stepper.wraps } set { stepper.wraps = newValue } }

  @IBInspectable public var value: Double { get { return stepper.value } set { stepper.value = newValue; updateLabel() } }
  @IBInspectable public var minimumValue: Double { get { return stepper.minimumValue } set { stepper.minimumValue = newValue } }
  @IBInspectable public var maximumValue: Double { get { return stepper.maximumValue } set { stepper.maximumValue = newValue } }
  @IBInspectable public var stepValue: Double { get { return stepper.stepValue } set { stepper.stepValue = newValue } }

  @IBInspectable public override var isEnabled: Bool { get { return stepper.isEnabled } set { stepper.isEnabled = newValue } }
  @IBInspectable public override var isSelected: Bool { get { return stepper.isSelected } set { stepper.isSelected = newValue } }
  @IBInspectable public override var isHighlighted: Bool { get { return stepper.isHighlighted } set { stepper.isHighlighted = newValue } }
  @IBInspectable public var highlightedTintColor: UIColor? {
    didSet {
      guard highlightedTintColor != oldValue, let color = highlightedTintColor else { return }
      if let image = incrementImageForState(.highlighted) ?? incrementImageForState(UIControl.State()) {
        setIncrementImage(image.image(withColor: color).withRenderingMode(.alwaysOriginal), forState: .highlighted)
      }
      if let image = decrementImageForState(.highlighted) ?? decrementImageForState(UIControl.State()) {
        setDecrementImage(image.image(withColor: color).withRenderingMode(.alwaysOriginal), forState: .highlighted)
      }
    }
  }

  public override var state: UIControl.State { return stepper.state }

  @IBInspectable public override var contentVerticalAlignment: UIControl.ContentVerticalAlignment {
    get { return stepper.contentVerticalAlignment }
    set { stepper.contentVerticalAlignment = newValue }
  }

  @IBInspectable public override var contentHorizontalAlignment: UIControl.ContentHorizontalAlignment {
    get { return stepper.contentHorizontalAlignment }
    set { stepper.contentHorizontalAlignment = newValue }
  }

  // MARK: Methods bounced to the `UIStepper` subview

  public func setBackgroundImage(_ image: UIImage?, forState state: UIControl.State) {
    stepper.setBackgroundImage(image, for: state)
  }

  public func backgroundImageForState(_ state: UIControl.State) -> UIImage? { return stepper.backgroundImage(for: state) }

  public func setDividerImage(_ image: UIImage?,
                              forLeftSegmentState leftState: UIControl.State,
                              rightSegmentState rightState: UIControl.State)
  {
    stepper.setDividerImage(image, forLeftSegmentState: leftState, rightSegmentState: rightState)
  }

  public func dividerImageForLeftSegmentState(_ lstate: UIControl.State, rightSegmentState rstate: UIControl.State) -> UIImage! {
    return stepper.dividerImage(forLeftSegmentState: lstate, rightSegmentState: rstate)
  }

  public func setIncrementImage(_ image: UIImage?, forState state: UIControl.State) {
    if let image = image, let color = highlightedTintColor , state == .highlighted {
      stepper.setIncrementImage(image.image(withColor: color).withRenderingMode(.alwaysOriginal), for: .highlighted)
    }  else if let image = image, let color = highlightedTintColor , state == UIControl.State() && incrementImageForState(.highlighted) == nil {
      stepper.setIncrementImage(image.image(withColor: color).withRenderingMode(.alwaysOriginal), for: .highlighted)
      stepper.setIncrementImage(image, for: UIControl.State())
    } else {
      stepper.setIncrementImage(image, for: state)
    }
  }

  public func incrementImageForState(_ state: UIControl.State) -> UIImage? { return stepper.incrementImage(for: state) }

  public func setDecrementImage(_ image: UIImage?, forState state: UIControl.State) {
    if let image = image, let color = highlightedTintColor , state == .highlighted {
      stepper.setDecrementImage(image.image(withColor: color).withRenderingMode(.alwaysOriginal), for: .highlighted)
    } else if let image = image, let color = highlightedTintColor , state == UIControl.State() && decrementImageForState(.highlighted) == nil {
      stepper.setDecrementImage(image.image(withColor: color).withRenderingMode(.alwaysOriginal), for: .highlighted)
      stepper.setDecrementImage(image, for: UIControl.State())
    } else {
      stepper.setDecrementImage(image, for: state)
    }
  }

  public func decrementImageForState(_ state: UIControl.State) -> UIImage? { return stepper.decrementImage(for: state) }

  public override var isTracking: Bool { return stepper.isTracking }
  public override var isTouchInside: Bool { return stepper.isTouchInside }

  public override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
    return stepper.beginTracking(touch, with: event)
  }
  public override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
    return stepper.continueTracking(touch, with: event)
  }
  public override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
    stepper.endTracking(touch, with: event)
  }
  public override func cancelTracking(with event: UIEvent?) {
    stepper.cancelTracking(with: event)
  }


  @IBInspectable public var backgroundImage: UIImage? {
    get { return backgroundImageForState(state) }
    set { setBackgroundImage(newValue, forState: state) }
  }

  @IBInspectable public var incrementImage: UIImage? {
    get { return incrementImageForState(state) }
    set { setIncrementImage(newValue, forState: state) }
  }

  @IBInspectable public var decrementImage: UIImage? {
    get { return decrementImageForState(state) }
    set { setDecrementImage(newValue, forState: state) }
  }

  @IBInspectable public var dividerHidden: Bool = false {
    didSet {
      setDividerImage(dividerHidden ? UIImage() : nil, forLeftSegmentState: UIControl.State(), rightSegmentState: UIControl.State())
    }
  }

  @IBInspectable public var backgroundHidden: Bool = false {
    didSet {
      let image: UIImage? = backgroundHidden ? UIImage() : nil

      setBackgroundImage(image, forState: UIControl.State())
      setBackgroundImage(image, forState: .highlighted)
      setBackgroundImage(image, forState: .disabled)
    }
  }

  public override func addTarget(_ target: Any?,
                          action: Selector,
                          for controlEvents: UIControl.Event)
  {
    stepper.addTarget(target, action: action, for: controlEvents)
  }

  public override func removeTarget(_ target: Any?,
                             action: Selector?,
                             for controlEvents: UIControl.Event)
  {
    stepper.removeTarget(target, action: action, for: controlEvents)
  }

  public override var allTargets: Set<AnyHashable> { return stepper.allTargets }
  public override var allControlEvents: UIControl.Event { return stepper.allControlEvents }

  public override func actions(forTarget target: Any?,
                               forControlEvent controlEvent: UIControl.Event) -> [String]?
  {
    return stepper.actions(forTarget: target, forControlEvent: controlEvent)
  }

  public override func sendAction(_ action: Selector, to target: Any?, for event: UIEvent?) {
    stepper.sendAction(action, to: target, for: event)
  }

  public override func sendActions(for controlEvents: UIControl.Event) {
    stepper.sendActions(for: controlEvents)
  }

}
