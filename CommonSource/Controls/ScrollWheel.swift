//
//  ScrollWheel.swift
//  MoonKit
//
//  Created by Jason Cardwell on 9/15/15.
//  Copyright © 2015 Jason Cardwell. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
public class ScrollWheel: UIControl {

  private let wheelLayer: CALayer = {
    let layer = CALayer()
    layer.anchorPoint = .zero
    layer.contentsScale = UIScreen.main.scale
    return layer
  }()

  private let dimpleLayer: CALayer = {
    let layer = CALayer()
    layer.anchorPoint = .zero
    layer.contentsScale = UIScreen.main.scale
    return layer
  }()

  private let dimpleFillLayer: CALayer = {
    let layer = CALayer()
    layer.anchorPoint = .zero
    layer.contentsScale = UIScreen.main.scale
    return layer
  }()

  /// Called as part of the initialization process
  private func setup() {

    layer.addSublayer(wheelLayer)
    layer.addSublayer(dimpleLayer)
    layer.addSublayer(dimpleFillLayer)

    calculateFrames()

  }

  public override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }


  // MARK: - Colors

  @IBInspectable public var wheelColor: UIColor = UIColor.gray {
    didSet {
      guard wheelColor != oldValue else { return }

      backgroundDispatch {
        [weak self] in
        self?._wheelImage = self?.wheelImage?.image(withColor: self!.wheelColor)
        dispatchToMain { self?.refreshLayers(.wheel) }
      }
    }
  }

  @IBInspectable public var dimpleColor: UIColor = UIColor.lightGray {
    didSet {
      guard dimpleColor != oldValue else { return }
      backgroundDispatch {
        [weak self] in
        self?._dimpleImage = self?.dimpleImage?.image(withColor: self!.dimpleColor)
        self?._dimpleFillImage = self?.dimpleFillImage?.image(withColor: self!.dimpleColor)
        dispatchToMain { self?.refreshLayers([.dimple, .dimpleFill]) }
      }
    }
  }

  // MARK: - Frames

  /// The frame for the wheel.
  private var baseFrame: CGRect = .zero

  /// The frame for the small dimple in the wheel.
  private var dimpleFrame: CGRect = .zero

  /// Recalculate the frames for the current bounds of the view.
  private func calculateFrames() {

    baseFrame = bounds.centerInscribedSquare

    let dimpleSize = CGSize(square: baseFrame.height * 0.25)

    dimpleFrame = CGRect(
      origin: CGPoint(x: baseFrame.midX - dimpleSize.width * 0.5, y: baseFrame.minY + 10),
      size: dimpleSize
    )

    wheelLayer.frame = baseFrame
    dimpleLayer.frame = dimpleFrame
    dimpleFillLayer.frame = dimpleFrame

    updateTouchPath()

    refreshLayers(.all)

  }

  // MARK: - Images

  private var _wheelImage: UIImage?

  @IBInspectable public var wheelImage: UIImage? {
    didSet {
      guard wheelImage != oldValue else { return }
      backgroundDispatch {
        [weak self] in
        self?._wheelImage = self?.wheelImage?.image(withColor: self!.wheelColor)
        dispatchToMain { self?.refreshLayers(.wheel) }
      }
    }
  }

  private func circle(size: CGSize, color: UIColor) -> UIImage {
    guard size != .zero else { return UIImage() }
    UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
    color.setFill()
    UIBezierPath(ovalIn: CGRect(size: size)).fill()
    guard let result = UIGraphicsGetImageFromCurrentImageContext() else {
      fatalError("Failed to retrieve image drawn to current context")
    }
    UIGraphicsEndImageContext()
    return result
  }

  private var defaultWheelImage: UIImage {
    return circle(size: baseFrame.size, color: wheelColor)
  }

  private var _dimpleImage: UIImage?

  @IBInspectable public var dimpleImage: UIImage? {
    didSet {
      guard dimpleImage != oldValue else { return }
      backgroundDispatch {
        [weak self] in
        self?._dimpleImage = self?.dimpleImage?.image(withColor: self!.dimpleColor)
        dispatchToMain { self?.refreshLayers(.dimple) }
      }
    }
  }

  private var defaultDimpleImage: UIImage {
    return circle(size: dimpleFrame.size, color: dimpleColor)
  }

  private var _dimpleFillImage: UIImage?

  @IBInspectable public var dimpleFillImage: UIImage? {
    didSet {
      guard dimpleFillImage != oldValue else { return }
      backgroundDispatch {
        [weak self] in
        self?._dimpleFillImage = self?.dimpleFillImage?.image(withColor: self!.dimpleColor)
        dispatchToMain { self?.refreshLayers(.dimpleFill) }
      }
    }
  }

  // MARK: - Styles

  public var dimpleStyle: CGBlendMode = .normal {
    didSet {
      guard dimpleStyle != oldValue else { return }
      setNeedsDisplay()
    }
  }

  public var dimpleFillStyle: CGBlendMode = .normal {
    didSet {
      guard dimpleFillStyle != oldValue else { return }
      setNeedsDisplay()
    }
  }

  @IBInspectable public var dimpleStyleString: String {
    get { return dimpleStyle.stringValue }
    set { dimpleStyle = CGBlendMode(stringValue: newValue) }
  }

  @IBInspectable public var dimpleFillStyleString: String {
    get { return dimpleFillStyle.stringValue }
    set { dimpleFillStyle = CGBlendMode(stringValue: newValue) }
  }

  // MARK: - Drawing

  /// The angle used in drawing the wheel
  public var angle: CGFloat = 0.0 {
    didSet {
      layer.sublayerTransform.rotation = angle
    }
  }

  /// The wheel's center point in window coordinates
  private var wheelCenter: CGPoint = .zero

  private func refreshLayers(_ layers: LayerMask = []) {
    if layers ∋ .wheel {
      wheelLayer.contents = _wheelImage?.cgImage ?? defaultWheelImage.cgImage
    }
    if layers ∋ .dimple {
      dimpleLayer.contents = _dimpleImage?.cgImage ?? defaultDimpleImage.cgImage
    }
    if layers ∋ .dimpleFill {
      dimpleFillLayer.contents = _dimpleFillImage?.cgImage
    }
  }

//  public override func drawRect(rect: CGRect) {
//    let context = UIGraphicsGetCurrentContext()
//    CGContextSaveGState(context)
//    CGContextTranslateCTM(context, half(rect.width), half(rect.height))
//    CGContextRotateCTM(context, angle)
//    CGContextTranslateCTM(context, -half(rect.width), -half(rect.height))
//
//    let baseFrame = rect.centerInscribedSquare
//    if let wheelBase = _wheelImage {
//      wheelBase.drawInRect(baseFrame)
//    } else {
//      wheelColor.setFill()
//      UIBezierPath(ovalInRect: baseFrame).fill()
//    }
//
//
//    let dimpleSize = CGSize(square: baseFrame.height * 0.25)
//    let dimpleFrame = CGRect(origin: CGPoint(x: baseFrame.midX - half(dimpleSize.width),
//                                             y: baseFrame.minY + 10),
//                             size: dimpleSize)
//    if let dimple = _dimpleImage, dimpleFill = _dimpleFillImage {
//
//      UIBezierPath(ovalInRect: dimpleFrame).addClip()
//      dimple.drawInRect(dimpleFrame, blendMode: dimpleStyle, alpha: 1)
//
//      let dimpleFillFrame = dimpleFrame.insetBy(dx: 1, dy: 1)
//
//      UIBezierPath(ovalInRect: dimpleFillFrame.insetBy(dx: 1, dy: 1)).addClip()
//      dimpleFill.drawInRect(dimpleFillFrame, blendMode: dimpleFillStyle, alpha: 1)
//
//    } else {
//      dimpleColor.setFill()
//      UIBezierPath(ovalInRect: dimpleFrame).fill()
//    }
//
//    CGContextRestoreGState(context)
//  }

  // MARK: - Values

  /// Total rotation in radians
  public private(set) var radians = 0.0 {
    didSet {
      guard radians != oldValue else { return }
      sendActions(for: .valueChanged)
    }
  }

  @IBInspectable public var dimpleOffset: CGFloat = .pi * 0.5

  /// Total number of revolutions
  public var revolutions: Double {
    return radians / .pi * 2
  }

  @objc(deltaRevolutions)
  public var 𝝙revolutions: Double {
    return 𝝙radians / .pi * 2
  }

  @objc(deltaRadians)
  public private(set) var 𝝙radians = 0.0

  @objc(deltaSeconds)
  public private(set) var 𝝙seconds = 0.0

  /// Velocity in radians per second
  public var velocity: Double {
    return 𝝙radians / 𝝙seconds
  }

  /// The current direction of rotation
  public var direction: RotationalDirection {
    return directionalTrend
  }

  // MARK: - Touches

  /// The path within which valid touch events occur
  private var touchPath = UIBezierPath()

  /// The difference between the `angle` and the angle of the initial touch location
  private var touchOffset: CGFloat = 0.0

  private func updateTouchPath() {
    touchPath = UIBezierPath(ovalIn: baseFrame)
    let outterRadius = baseFrame.width * 0.5
    touchPath.move(to: CGPoint(x: baseFrame.minX + outterRadius + 1,
                               y: baseFrame.minY + outterRadius))
    touchPath.usesEvenOddFillRule = true
    touchPath.addArc(withCenter: baseFrame.center,
                     radius: 1,
                     startAngle: 0,
                     endAngle: .pi * 2,
                     clockwise: true)
  }

  public override var bounds: CGRect {
    didSet {
      guard bounds != oldValue else { return }
      calculateFrames()
    }
  }

  public override func prepareForInterfaceBuilder() {

    calculateFrames()

    super.prepareForInterfaceBuilder()
  }

  private func angle(for location: CGPoint) -> CGFloat {

    let 𝝙 = location - wheelCenter
    let quadrant = CircleQuadrant(point: location, center: wheelCenter)
    let (x, y) = 𝝙.absolute.unpack
    let h = hypot(x, y)
    var α = acos(x / h)

    // Adjust the angle for the quadrant
    switch quadrant {
      case .I:   α = .pi * 2 - α
      case .II:  α += .pi
      case .III: α = .pi - α
      case .IV:  break
    }

    // Adjust the angle for the rotated dimple
    α += dimpleOffset

    // Adjust for initial touch offset
    α += touchOffset

    return α
  }

  /// Values required for updating rotation
  private var preliminaryValues: (location: CGPoint, quadrant: CircleQuadrant, timestamp: TimeInterval)?

  /// The direction indicated by the weighted average of the contents of `directionHistory`
  private var directionalTrend: RotationalDirection {

    var n = 0.0

    let directions = directionHistory.reversed().prefix(5)

    guard directions.count > 0 else { return .unspecified }

    for (i, d) in zip((1 ... directions.count).reversed(), directions) {
      n += Double(d.rawValue) * (5.0 + Double(i) * 0.1)
    }

    let result: RotationalDirection
    switch n {
      case <--0: result = .counterClockwise
      case 0|->: result = .clockwise
      default:   result = .unspecified
    }

    return result
  }

  private func update(for touch: UITouch, withEvent event: UIEvent? = nil) {

    // Make sure the touch is located inside `touchPath`
    guard touchPath.contains(touch.location(in: self)) else { /*innerLastTouch = true;*/ return }

    // Get the new location, angle and quadrant
    let locationʹ = touch.location(in: nil)
    let angleʹ = angle(for: locationʹ)
    let quadrantʹ = CircleQuadrant(point: locationʹ, center: wheelCenter)

    // Make sure we already had some values or cache the new values and return
    guard let (location, quadrant, timestamp) = preliminaryValues else {
      preliminaryValues = (locationʹ, quadrantʹ, touch.timestamp)
      return
    }

    // Make sure the location has actually changed
    guard locationʹ != location else { return }

    // Get the current direction of rotation and cache it
    let direction = RotationalDirection(from: location, to: locationʹ, about: wheelCenter, trending: directionalTrend)
    directionHistory.append(direction)

    // Make sure we haven't changed direction or clear cached values and return
    guard direction == directionalTrend else { preliminaryValues = nil; return }

    // Get the absolute change in radians between the previous angle and the current angle
    var 𝝙angle = abs(angleʹ - angle)
    guard !𝝙angle.isNaN else { fatalError("unexptected NaN for 𝝙angle") }

    // Correct the value if we've crossed the 0/2π threshold
    switch (quadrantʹ, quadrant) {
      case (.IV, .I), (.I, .IV):
        𝝙angle -= .pi * 2
      default:
        break
    }

    // Get the change in radians signed for the current direction
    let 𝝙radiansʹ = Double(direction == .counterClockwise ? -𝝙angle : 𝝙angle)

    // Calculate the updated total radians
    let radiansʹ = radians + 𝝙radiansʹ

    // Calculate the number of seconds over which the change in radians occurred
    let 𝝙secondsʹ = touch.timestamp - timestamp

    // Update the cached values
    preliminaryValues = (locationʹ, quadrantʹ, touch.timestamp)

    // Update property values
    𝝙radians = 𝝙radiansʹ
    𝝙seconds = 𝝙secondsʹ
    angle = angleʹ

    // Update radians last so all values have been updated when actions are sent
    radians = radiansʹ
  }

  /// Cache of calculated direction values
  private var directionHistory: [RotationalDirection] = []

  public override var intrinsicContentSize: CGSize {
    return CGSize(square: wheelImage?.size.maxAxisValue ?? 100)
  }

  public override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
    guard touchPath.contains(touch.location(in: self)) else { return false }
    preliminaryValues = nil
    wheelCenter = window!.convert(self.center, from: superview)
    touchOffset = (angle - angle(for: touch.location(in: nil))).truncatingRemainder(dividingBy: .pi * 2)
    radians = 0
    𝝙radians = 0
    update(for: touch)
    return true
  }

  #if TARGET_INTERFACE_BUILDER
  @IBInspectable public override var isEnabled: Bool { didSet {} }
  #endif

  public override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
    update(for: touch, withEvent: event)
    return true
  }

  public override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
    guard let touch = touch  else { return }
    update(for: touch)
  }

  public override func cancelTracking(with event: UIEvent?) {
    sendActions(for: .touchCancel)
  }

}

extension ScrollWheel {

  fileprivate struct LayerMask: OptionSet {
    let rawValue: Int

    static let none       = LayerMask([])
    static let wheel      = LayerMask(rawValue: 0b001)
    static let dimple     = LayerMask(rawValue: 0b010)
    static let dimpleFill = LayerMask(rawValue: 0b100)
    static let all        = LayerMask(rawValue: 0b111)
  }

}
