//
//  Knob.swift
//  MoonKit
//
//  Created by Jason Cardwell on 8/31/15.
//  Copyright © 2015 Jason Cardwell. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
public class Knob: UIControl {

  @IBInspectable public var value: Float = 0.5 {
    didSet {
      guard oldValue != value else { return }
      value = valueInterval.clampValue(value)
      setNeedsDisplay()
    }
  }

  @IBInspectable public var minimumValue: Float {
    get { return valueInterval.lowerBound }
    set {
      guard valueInterval.lowerBound != newValue || newValue > valueInterval.upperBound else { return }
      valueInterval = newValue ... valueInterval.upperBound
    }
  }

  @IBInspectable public var maximumValue: Float {
    get { return valueInterval.upperBound }
    set {
      guard valueInterval.upperBound != newValue || newValue < valueInterval.lowerBound else { return }
      valueInterval = valueInterval.lowerBound ... newValue
    }
  }

  fileprivate var _knobBase: UIImage?
  @IBInspectable public var knobBase: UIImage? {
    didSet {
      guard oldValue != knobBase else { return }
      #if TARGET_INTERFACE_BUILDER
        _knobBase = knobBase?.image(withColor: knobColor)
        setNeedsDisplay()
      #else
        backgroundDispatch {
          [weak self] in
          self?._knobBase = self?.knobBase?.image(withColor: self!.knobColor)
          dispatchToMain { self?.setNeedsDisplay() }
        }
      #endif
    }
  }

  fileprivate var _indicatorImage: UIImage?
  @IBInspectable public var indicatorImage: UIImage? {
    didSet {
      guard indicatorImage != oldValue else { return }
      #if TARGET_INTERFACE_BUILDER
        _indicatorImage = indicatorImage?.image(withColor: indicatorColor)
        setNeedsDisplay()
      #else
        backgroundDispatch {
          [weak self] in
          self?._indicatorImage = self?.indicatorImage?.image(withColor: self!.indicatorColor)
          dispatchToMain { self?.setNeedsDisplay() }
        }
      #endif
    }
  }
  fileprivate var _indicatorFillImage: UIImage?
  @IBInspectable public var indicatorFillImage: UIImage? {
    didSet {
      guard indicatorFillImage != oldValue else { return }
      #if TARGET_INTERFACE_BUILDER
        _indicatorFillImage = indicatorFillImage?.image(withColor: indicatorFillColor)
        setNeedsDisplay()
      #else
        backgroundDispatch {
          [weak self] in
          self?._indicatorFillImage = self?.indicatorFillImage?.image(withColor: self!.indicatorFillColor)
          dispatchToMain { self?.setNeedsDisplay() }
        }
      #endif
    }
  }

  @IBInspectable public var tintColorAlpha: CGFloat = 0 {
    didSet {
      guard tintColorAlpha != oldValue else { return }
      tintColorAlpha = (0 ... 1).clampValue(tintColorAlpha)
      setNeedsDisplay()
    }
  }

  fileprivate var previousRotation: CGFloat = 0
  fileprivate weak var rotationGesture: UIRotationGestureRecognizer?
  fileprivate let rotationInterval: ClosedRange<CGFloat> = -.pi / 2 ... .pi / 2

  /**
  intrinsicContentSize

  - returns: CGSize
  */
  public override var intrinsicContentSize: CGSize {
    return knobBase?.size ?? CGSize(square: 44)
  }

  /**
  addTarget:action:forControlEvents:

  - parameter target: AnyObject?
  - parameter action: Selector
  - parameter controlEvents: UIControlEvents
  */
  override public func addTarget(_ target: Any?, action: Selector, for controlEvents: UIControl.Event) {
    super.addTarget(target, action: action, for: controlEvents)
    guard self.rotationGesture == nil else { return }
    let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(Knob.didRotate))
    addGestureRecognizer(rotationGesture)
    self.rotationGesture = rotationGesture
  }

  /**
  didRotate:

  - parameter gesture: UIRotationGestureRecognizer
  */
  @objc fileprivate func didRotate() {
    guard let rotationGesture = rotationGesture else { return }
    let currentRotation = rotationInterval.clampValue(rotationGesture.rotation)
    guard currentRotation != previousRotation else { return }
    value = valueInterval.valueForNormalizedValue(Float(rotationInterval.normalizeValue(currentRotation)))
    previousRotation = currentRotation
  }

  @IBInspectable public var knobColor: UIColor = UIColor.darkGray {
    didSet {
      #if TARGET_INTERFACE_BUILDER
        _knobBase = knobBase?.image(withColor: knobColor)
        setNeedsDisplay()
        #else
      backgroundDispatch {
        [weak self] in
        self?._knobBase = self?.knobBase?.image(withColor: self!.knobColor)
        dispatchToMain { self?.setNeedsDisplay() }
      }
      #endif
    }
  }

  @IBInspectable public var indicatorColor: UIColor = UIColor.lightGray {
    didSet {
      guard indicatorColor != oldValue else { return }
      #if TARGET_INTERFACE_BUILDER
        _indicatorImage = indicatorImage?.image(withColor: indicatorColor)
      #else
      backgroundDispatch {
        [weak self] in
        self?._indicatorImage = self?.indicatorImage?.image(withColor: self!.indicatorColor)
        dispatchToMain { self?.setNeedsDisplay() }
      }
      #endif
    }
  }

  @IBInspectable public var indicatorFillColor: UIColor = UIColor.lightGray {
    didSet {
      guard indicatorFillColor != oldValue else { return }
      #if TARGET_INTERFACE_BUILDER
        _indicatorFillImage = indicatorFillImage?.image(withColor: indicatorFillColor)
        setNeedsDisplay()
      #else
      backgroundDispatch {
        [weak self] in
        self?._indicatorFillImage = self?.indicatorFillImage?.image(withColor: self!.indicatorFillColor)
        dispatchToMain { self?.setNeedsDisplay() }
      }
      #endif
    }
  }
  fileprivate var valueInterval: ClosedRange<Float> = 0 ... 1 { didSet { value = valueInterval.clampValue(value) } }

  // MARK: - Styles

  public var indicatorStyle: CGBlendMode = .normal {
    didSet {
      guard indicatorStyle != oldValue else { return }
      setNeedsDisplay()
    }
  }

  public var indicatorFillStyle: CGBlendMode = .normal {
    didSet {
      guard indicatorFillStyle != oldValue else { return }
      setNeedsDisplay()
    }
  }

  @IBInspectable public var indicatorStyleString: String {
    get { return indicatorStyle.stringValue }
    set { indicatorStyle = CGBlendMode(stringValue: newValue) }
  }

  @IBInspectable public var indicatorFillStyleString: String {
    get { return indicatorFillStyle.stringValue }
    set { indicatorFillStyle = CGBlendMode(stringValue: newValue) }
  }

  /**
  drawRect:

  - parameter rect: CGRect
  */
  public override func draw(_ rect: CGRect) {

    let context = UIGraphicsGetCurrentContext()
    context?.saveGState()
    context?.translateBy(x: rect.width * 0.5, y: rect.height * 0.5)
    context?.rotate(by: .pi * CGFloat(valueInterval.normalizeValue(value)) + .pi)
    context?.translateBy(x: -rect.width * 0.5, y: -rect.height * 0.5)

    let baseFrame = rect.centerInscribedSquare

    if let knobBase = _knobBase {
      knobBase.draw(in: baseFrame)
    } else {
      knobColor.setFill()
      UIBezierPath(ovalIn: baseFrame).fill()
    }

    if let indicator = _indicatorImage, let indicatorFill = _indicatorFillImage {
      indicator.draw(in: baseFrame, blendMode: indicatorStyle, alpha: 1)
      indicatorFill.draw(in: baseFrame, blendMode: indicatorFillStyle, alpha: 1)

    } else {
      let indicatorPath = UIBezierPath()
      indicatorPath.addArc(withCenter: baseFrame.center,
                           radius: baseFrame.width * 0.5,
                              startAngle: .pi / 20,
                              endAngle: -.pi / 20,
                           clockwise: false)
      indicatorPath.addLine(to: baseFrame.center)
      indicatorPath.close()

      indicatorFillColor.setFill()
      indicatorPath.fill(with: indicatorFillStyle, alpha: 1)
      indicatorPath.lineWidth = 2
      indicatorPath.lineJoinStyle = .bevel
      indicatorColor.setStroke()
      indicatorPath.stroke(with: indicatorStyle, alpha: 1)
    }

    if tintColorAlpha > 0 {
      UIBezierPath(ovalIn: baseFrame).addClip()
      tintColor.withAlphaComponent(tintColorAlpha).setFill()
      UIRectFillUsingBlendMode(baseFrame, .color)
    }

    context?.restoreGState()
  }

}
