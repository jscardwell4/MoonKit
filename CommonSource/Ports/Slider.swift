//
//  Slider.swift
//  MoonKit
//
//  Created by Jason Cardwell on 9/2/15.
//  Copyright © 2015 Jason Cardwell. All rights reserved.
//
import Foundation
import UIKit
// import Chameleon

@IBDesignable
open class Slider: UIControl
{
  private func maybeSetNeedsDisplay<T: Equatable>(_ oldValue: T?, _ newValue: T?,
                                                  predicate: @autoclosure ()
                                                    -> Bool = true)
  {
    guard predicate(), oldValue != newValue else { return }
    setNeedsDisplay()
  }

  public enum TrackAlignment: String
  {
    case topOrLeft, center, bottomOrRight
  }

  public enum TextAlignment: String
  {
    case topLeft, top, topRight, left, center, right, bottomLeft, bottom, bottomRight

    /// Added to fix initialization via interface builder user defined attributes
    public init?(rawValue: String)
    {
      switch rawValue
      {
        case "topLeft": self = .topLeft
        case "topRight": self = .topRight
        case "top": self = .top
        case "left": self = .left
        case "center": self = .center
        case "right": self = .right
        case "bottomLeft": self = .bottomLeft
        case "bottomRight": self = .bottomRight
        case "bottom": self = .bottom
        default: return nil
      }
    }
  }

  @IBInspectable open var isVertical: Bool = false
  {
    didSet { maybeSetNeedsDisplay(oldValue, isVertical) }
  }

  // MARK: - Images

  private var _thumbImage: UIImage?
  {
    didSet { maybeSetNeedsDisplay(oldValue, _thumbImage) }
  }

  @IBInspectable open var thumbImage: UIImage?
  {
    get { return _thumbImage }
    set { _thumbImage = newValue?.image(withColor: thumbColor) }
  }

  private var _trackMinImage: UIImage?
  {
    didSet { maybeSetNeedsDisplay(oldValue, _trackMinImage) }
  }

  @IBInspectable open var trackMinImage: UIImage?
  {
    get { return _trackMinImage }
    set { _trackMinImage = newValue?.image(withColor: trackMinColor) }
  }

  private var _trackMaxImage: UIImage?
  {
    didSet { maybeSetNeedsDisplay(oldValue, _trackMaxImage) }
  }

  @IBInspectable open var trackMaxImage: UIImage?
  {
    get { return _trackMaxImage }
    set { _trackMaxImage = newValue?.image(withColor: trackMaxColor) }
  }

  // MARK: - Colors

  @IBInspectable open var thumbColor = UIColor(white: 1, alpha: 1)
  {
    didSet
    {
      guard oldValue != thumbColor else { return }
      _thumbImage = _thumbImage?.image(withColor: thumbColor)
    }
  }

  @IBInspectable open var trackMinColor: UIColor = #colorLiteral(red: 0.1134361252, green: 0.6369928718, blue: 0.9415513277, alpha: 1)
  {
    didSet
    {
      guard oldValue != trackMinColor else { return }
      _trackMinImage = _trackMinImage?.image(withColor: trackMinColor)
    }
  }

  @IBInspectable open var trackMaxColor: UIColor = #colorLiteral(red: 0.7709601521, green: 0.7709783912, blue: 0.7709685564, alpha: 1)
  {
    didSet
    {
      guard oldValue != trackMaxColor else { return }
      _trackMaxImage = _trackMaxImage?.image(withColor: trackMaxColor)
    }
  }

  @IBInspectable open var valueLabelTextColor: UIColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
  {
    didSet
    {
      maybeSetNeedsDisplay(oldValue, valueLabelTextColor, predicate: showsValueLabel)
    }
  }

  @IBInspectable open var trackLabelTextColor: UIColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
  {
    didSet
    {
      maybeSetNeedsDisplay(oldValue, trackLabelTextColor, predicate: showsTrackLabel)
    }
  }

  @IBInspectable open var tintColorAlpha: CGFloat = 0
  {
    didSet
    {
      tintColorAlpha = (0 ... 1).clampValue(tintColorAlpha)
      maybeSetNeedsDisplay(oldValue, tintColorAlpha)
    }
  }

  // MARK: - Alignment

  //  open override var alignmentRectInsets: UIEdgeInsets {
  //    return isVertical
  //      ? UIEdgeInsets(horizontal: 0, vertical: (thumbSize.height * 0.5).rounded())
  //      : UIEdgeInsets(horizontal: (thumbSize.width * 0.5).rounded(), vertical: 0)
  //  }

  open var thumbAlignment: TrackAlignment = .center

  @IBInspectable open var thumbAlignmentString: String
  {
    get { return thumbAlignment.rawValue }
    set
    {
      guard let alignment = TrackAlignment(rawValue: newValue) else { return }
      thumbAlignment = alignment
    }
  }

  open var trackAlignment: TrackAlignment = .center

  @IBInspectable open var trackAlignmentString: String
  {
    get { return trackAlignment.rawValue }
    set
    {
      guard let alignment = TrackAlignment(rawValue: newValue) else { return }
      trackAlignment = alignment
    }
  }

  open var valueLabelAlignment: TextAlignment = .center
  {
    didSet
    {
      maybeSetNeedsDisplay(oldValue, valueLabelAlignment, predicate: showsValueLabel)
    }
  }

  @IBInspectable open var valueLabelAlignmentString: String
  {
    get { return valueLabelAlignment.rawValue }
    set
    {
      guard let alignment = TextAlignment(rawValue: newValue) else { return }
      valueLabelAlignment = alignment
    }
  }

  open var trackLabelAlignment: TextAlignment = .center
  {
    didSet
    {
      maybeSetNeedsDisplay(oldValue, trackLabelAlignment, predicate: showsTrackLabel)
    }
  }

  @IBInspectable open var trackLabelAlignmentString: String
  {
    get { return trackLabelAlignment.rawValue }
    set
    {
      guard let alignment = TextAlignment(rawValue: newValue) else { return }
      trackLabelAlignment = alignment
    }
  }

  open var valueLabelOffset: UIOffset = .zero
  {
    didSet
    {
      maybeSetNeedsDisplay(oldValue, valueLabelOffset, predicate: showsValueLabel)
    }
  }

  @IBInspectable open var valueLabelHorizontalOffset: CGFloat
  {
    get { return valueLabelOffset.horizontal }
    set { valueLabelOffset.horizontal = newValue }
  }

  @IBInspectable open var valueLabelVerticalOffset: CGFloat
  {
    get { return valueLabelOffset.vertical }
    set { valueLabelOffset.vertical = newValue }
  }

  open var trackLabelOffset: UIOffset = .zero
  {
    didSet
    {
      maybeSetNeedsDisplay(oldValue, trackLabelOffset, predicate: showsTrackLabel)
    }
  }

  @IBInspectable open var trackLabelHorizontalOffset: CGFloat
  {
    get { return trackLabelOffset.horizontal }
    set { trackLabelOffset.horizontal = newValue }
  }

  @IBInspectable open var trackLabelVerticalOffset: CGFloat
  {
    get { return trackLabelOffset.vertical }
    set { trackLabelOffset.vertical = newValue }
  }

  // MARK: - Text

  @IBInspectable open var showsValueLabel: Bool = false
  {
    didSet
    {
      maybeSetNeedsDisplay(oldValue, showsValueLabel)
    }
  }

  @IBInspectable open var valueLabelPrecision: Int = 2
  {
    didSet
    {
      maybeSetNeedsDisplay(oldValue, valueLabelPrecision, predicate: showsValueLabel)
    }
  }

  public static let defaultValueLabelFont = UIFont
    .preferredFont(forTextStyle: UIFont.TextStyle.caption1)

  open var valueLabelFont: UIFont = .preferredFont(forTextStyle: .caption1)
  {
    didSet
    {
      maybeSetNeedsDisplay(oldValue, valueLabelFont, predicate: showsValueLabel)
    }
  }

  @IBInspectable open var valueLabelFontName: String
  {
    get { return valueLabelFont.fontName }
    set
    {
      guard let font = UIFont(name: newValue, size: valueLabelFont.pointSize)
      else { return }
      valueLabelFont = font
    }
  }

  @IBInspectable open var valueLabelFontSize: CGFloat
  {
    get { return valueLabelFont.pointSize }
    set
    {
      valueLabelFont = valueLabelFont.withSize(newValue)
    }
  }

  @IBInspectable open var showsTrackLabel: Bool = true
  {
    didSet
    {
      maybeSetNeedsDisplay(oldValue, showsTrackLabel)
    }
  }

  @IBInspectable open var trackLabelText: String?
  {
    didSet
    {
      guard showsTrackLabel, oldValue != trackLabelText else { return }
      setNeedsDisplay()
    }
  }

  public static let defaultTrackLabelFont = UIFont
    .preferredFont(forTextStyle: UIFont.TextStyle.body)

  open var trackLabelFont: UIFont = Slider.defaultTrackLabelFont
  {
    didSet
    {
      maybeSetNeedsDisplay(oldValue, trackLabelFont, predicate: showsTrackLabel)
    }
  }

  @IBInspectable open var trackLabelFontName: String
  {
    get { return trackLabelFont.fontName }
    set
    {
      guard let font = UIFont(name: newValue, size: trackLabelFont.pointSize)
      else { return }
      trackLabelFont = font
    }
  }

  @IBInspectable open var trackLabelFontSize: CGFloat
  {
    get { return trackLabelFont.pointSize }
    set { trackLabelFont = trackLabelFont.withSize(newValue) }
  }

  // MARK: - Sizes

  /// The default measurement of the track perpendicular to its primary axis.
  public static var defaultTrackBreadth: CGFloat = 4

  /// The measurement of the min portion of the track perpendicular to its primary axis.
  open var trackMinBreadthOverride: CGFloat?
  {
    didSet
    {
      maybeSetNeedsDisplay(oldValue, trackMinBreadthOverride)
    }
  }

  public var trackMinBreadth: CGFloat
  {
    guard trackMinBreadthOverride == nil else { return trackMinBreadthOverride! }

    guard let trackMinImage = trackMinImage else { return Slider.defaultTrackBreadth }

    return isVertical ? trackMinImage.size.width : trackMinImage.size.height
  }

  /// The measurement of the max portion of the track perpendicular to its primary axis.
  open var trackMaxBreadthOverride: CGFloat?
  {
    didSet
    {
      maybeSetNeedsDisplay(oldValue, trackMaxBreadthOverride)
    }
  }

  public var trackMaxBreadth: CGFloat
  {
    guard trackMaxBreadthOverride == nil else { return trackMaxBreadthOverride! }

    guard let trackMaxImage = trackMaxImage else { return Slider.defaultTrackBreadth }

    return isVertical ? trackMaxImage.size.width : trackMaxImage.size.height
  }

  public static var defaultThumbSize = CGSize(square: 43)

  open var thumbSizeOverride: CGSize?
  {
    didSet
    {
      maybeSetNeedsDisplay(oldValue, thumbSizeOverride)
    }
  }

  public var thumbSize: CGSize
  {
    return thumbImage?.size ?? thumbSizeOverride ?? Slider.defaultThumbSize
  }

  // MARK: - Values

  @IBInspectable open var value: Float = 0
  {
    didSet
    {
      maybeSetNeedsDisplay(oldValue, value)
    }
  }

  @IBInspectable open var minimumValue: Float = 0
  @IBInspectable open var maximumValue: Float = 1

  override open var intrinsicContentSize: CGSize
  {
    return isVertical
      ? CGSize(width: thumbSize.width, height: 150)
      : CGSize(width: 150, height: thumbSize.height)
  }

  private var valueInterval: ClosedRange<Float>
  {
    return minimumValue < maximumValue ? minimumValue ... maximumValue : 0 ... 1
  }

  // MARK: - Initializing

  override public init(frame: CGRect)
  {
    super.init(frame: frame)
  }

  override open func encode(with aCoder: NSCoder)
  {
    super.encode(with: aCoder)
    aCoder.encode(showsValueLabel, forKey: "showsValueLabel")
    aCoder.encode(showsTrackLabel, forKey: "showsTrackLabel")
    aCoder.encode(thumbAlignment.rawValue, forKey: "thumbAlignment")
    aCoder.encode(valueLabelAlignment.rawValue, forKey: "valueLabelAlignment")
    aCoder.encode(valueLabelOffset, forKey: "valueLabelOffset")
    aCoder.encode(valueLabelFont, forKey: "valueLabelFont")
    aCoder.encode(valueLabelTextColor, forKey: "valueLabelTextColor")
    aCoder.encode(trackLabelAlignment.rawValue, forKey: "trackLabelAlignment")
    aCoder.encode(trackLabelOffset, forKey: "trackLabelOffset")
    aCoder.encode(trackAlignment.rawValue, forKey: "trackAlignment")
    aCoder.encode(trackLabelFont, forKey: "trackLabelFont")
    aCoder.encode(trackLabelTextColor, forKey: "trackLabelTextColor")
    aCoder.encode(minimumValue, forKey: "minimumValue")
    aCoder.encode(maximumValue, forKey: "maximumValue")
    aCoder.encode(thumbImage, forKey: "thumbImage")
    aCoder.encode(trackMinImage, forKey: "trackMinImage")
    aCoder.encode(trackMaxImage, forKey: "trackMaxImage")
    aCoder.encode(thumbColor, forKey: "thumbColor")
    aCoder.encode(trackMinColor, forKey: "trackMinColor")
    aCoder.encode(trackMaxColor, forKey: "trackMaxColor")
    aCoder.encode(valueLabelPrecision, forKey: "valueLabelPrecision")
    aCoder.encodeConditionalObject(trackMinBreadthOverride, forKey: "trackMinBreadth")
    aCoder.encodeConditionalObject(trackMaxBreadthOverride, forKey: "trackMaxBreadth")
    aCoder.encodeConditionalObject(thumbSizeOverride, forKey: "thumbSize")
    aCoder.encode(trackLabelText, forKey: "trackLabelText")
    aCoder.encode(isVertical, forKey: "isVertical")
  }

  public required init?(coder aDecoder: NSCoder)
  {
    super.init(coder: aDecoder)

    if aDecoder.containsValue(forKey: "continuous")
    {
      continuous = aDecoder.decodeBool(forKey: "continuous")
    }

    if aDecoder.containsValue(forKey: "showsValueLabel")
    {
      showsValueLabel = aDecoder.decodeBool(forKey: "showsValueLabel")
    }

    if aDecoder.containsValue(forKey: "showsTrackLabel")
    {
      showsTrackLabel = aDecoder.decodeBool(forKey: "showsTrackLabel")
    }

    if aDecoder.containsValue(forKey: "thumbAlignment"),
       let alignmentString = aDecoder.decodeObject(forKey: "thumbAlignment") as? String,
       let alignment = TrackAlignment(rawValue: alignmentString)
    {
      thumbAlignment = alignment
    }

    if aDecoder.containsValue(forKey: "valueLabelAlignment"),
       let alignmentString = aDecoder
        .decodeObject(forKey: "valueLabelAlignment") as? String,
       let alignment = TextAlignment(rawValue: alignmentString)
    {
      valueLabelAlignment = alignment
    }

    if aDecoder.containsValue(forKey: "valueLabelOffset")
    {
      valueLabelOffset = aDecoder.decodeUIOffset(forKey: "valueLabelOffset")
    }

    if aDecoder.containsValue(forKey: "valueLabelFont"),
       let font = aDecoder.decodeObject(forKey: "valueLabelFont") as? UIFont
    {
      valueLabelFont = font
    }

    if aDecoder.containsValue(forKey: "valueLabelTextColor"),
       let color = aDecoder.decodeObject(forKey: "valueLabelTextColor") as? UIColor
    {
      valueLabelTextColor = color
    }

    if aDecoder.containsValue(forKey: "trackLabelAlignment"),
       let alignmentString = aDecoder
        .decodeObject(forKey: "trackLabelAlignment") as? String,
       let alignment = TextAlignment(rawValue: alignmentString)
    {
      trackLabelAlignment = alignment
    }

    if aDecoder.containsValue(forKey: "trackLabelOffset")
    {
      trackLabelOffset = aDecoder.decodeUIOffset(forKey: "trackLabelOffset")
    }

    if aDecoder.containsValue(forKey: "trackAlignment"),
       let alignmentString = aDecoder.decodeObject(forKey: "trackAlignment") as? String,
       let alignment = TrackAlignment(rawValue: alignmentString)
    {
      trackAlignment = alignment
    }

    if aDecoder.containsValue(forKey: "trackLabelFont"),
       let font = aDecoder.decodeObject(forKey: "trackLabelFont") as? UIFont
    {
      trackLabelFont = font
    }

    if aDecoder.containsValue(forKey: "trackLabelTextColor"),
       let color = aDecoder.decodeObject(forKey: "trackLabelTextColor") as? UIColor
    {
      trackLabelTextColor = color
    }

    if aDecoder.containsValue(forKey: "minimumValue")
    {
      minimumValue = aDecoder.decodeFloat(forKey: "minimumValue")
    }

    if aDecoder.containsValue(forKey: "maximumValue")
    {
      maximumValue = aDecoder.decodeFloat(forKey: "maximumValue")
    }

    if aDecoder.containsValue(forKey: "thumbImage")
    {
      thumbImage = aDecoder.decodeObject(forKey: "thumbImage") as? UIImage
    }

    if aDecoder.containsValue(forKey: "trackMinImage")
    {
      trackMinImage = aDecoder.decodeObject(forKey: "trackMinImage") as? UIImage
    }

    if aDecoder.containsValue(forKey: "trackMaxImage")
    {
      trackMaxImage = aDecoder.decodeObject(forKey: "trackMaxImage") as? UIImage
    }

    if aDecoder.containsValue(forKey: "thumbColor"),
       let color = aDecoder.decodeObject(forKey: "thumbColor") as? UIColor
    {
      thumbColor = color
    }

    if aDecoder.containsValue(forKey: "trackMinColor"),
       let color = aDecoder.decodeObject(forKey: "trackMinColor") as? UIColor
    {
      trackMinColor = color
    }

    if aDecoder.containsValue(forKey: "trackMaxColor"),
       let color = aDecoder.decodeObject(forKey: "trackMaxColor") as? UIColor
    {
      trackMaxColor = color
    }

    if aDecoder.containsValue(forKey: "valueLabelPrecision")
    {
      valueLabelPrecision = aDecoder.decodeInteger(forKey: "valueLabelPrecision")
    }

    if aDecoder.containsValue(forKey: "trackMinBreadthOverride")
    {
      trackMinBreadthOverride = CGFloat(aDecoder
                                          .decodeFloat(forKey: "trackMinBreadthOverride"))
    }

    if aDecoder.containsValue(forKey: "trackMaxBreadthOverride")
    {
      trackMaxBreadthOverride = CGFloat(aDecoder
                                          .decodeFloat(forKey: "trackMaxBreadthOverride"))
    }

    if aDecoder.containsValue(forKey: "thumbSizeOverride")
    {
      thumbSizeOverride = aDecoder.decodeCGSize(forKey: "thumbSizeOverride")
    }

    if aDecoder.containsValue(forKey: "trackLabelText"),
       let text = aDecoder.decodeObject(forKey: "trackLabelText") as? String
    {
      trackLabelText = text
    }

    if aDecoder.containsValue(forKey: "isVertical")
    {
      isVertical = aDecoder.decodeBool(forKey: "isVertical")
    }
  }

  // MARK: - Drawing

  override open func draw(_ rect: CGRect)
  {
    // Get a reference to the current context
    guard let context = UIGraphicsGetCurrentContext() else { return }

    // Save the context
    context.saveGState()

    // Make sure our rect is clear
    context.clear(rect)

    // Get the track heights and thumb size to use for drawing
    let trackMinBreadth = self.trackMinBreadth, trackMaxBreadth = self.trackMaxBreadth
    let thumbSize = self.thumbSize

    let trackMinFrame: CGRect, trackMaxFrame: CGRect, thumbFrame: CGRect

    let pad = ((isVertical ? thumbSize.height : thumbSize.width) * 0.5).rounded()
    let trackFrame = (isVertical ? bounds.insetBy(dx: 0, dy: pad) : bounds
                        .insetBy(dx: pad, dy: 0)).integral
    let normalizedValue = CGFloat(valueInterval.normalizeValue(value))
    let filledTrack = (isVertical ? trackFrame.height : trackFrame.width) * normalizedValue
    let unfilledTrack = (isVertical ? trackFrame.height : trackFrame.width) - filledTrack

    switch isVertical
    {
      case false:

        let trackMinY: CGFloat, trackMaxY: CGFloat

        switch trackAlignment
        {
          case .center:
            trackMinY = trackFrame.midY - trackMinBreadth * 0.5
            trackMaxY = trackFrame.midY - trackMaxBreadth * 0.5

          case .topOrLeft:
            trackMinY = trackFrame.minY
            trackMaxY = trackMinY

          case .bottomOrRight:
            trackMinY = trackFrame.maxY - trackMinBreadth
            trackMaxY = trackFrame.maxY - trackMaxBreadth
        }

        trackMinFrame = CGRect(origin: CGPoint(x: trackFrame.minX, y: trackMinY),
                               size: CGSize(width: filledTrack, height: trackMinBreadth))
        trackMaxFrame = CGRect(origin: CGPoint(x: trackMinFrame.maxX, y: trackMaxY),
                               size: CGSize(width: unfilledTrack, height: trackMaxBreadth))

        let thumbY: CGFloat

        switch thumbAlignment
        {
          case .center: thumbY = trackFrame.midY - thumbSize.height * 0.5
          case .topOrLeft: thumbY = trackFrame.minY
          case .bottomOrRight: thumbY = trackFrame.maxY - thumbSize.height
        }

        thumbFrame = CGRect(
          origin: CGPoint(x: trackMinFrame.maxX - pad, y: thumbY),
          size: thumbSize
        )

      case true:

        let trackX: CGFloat

        switch trackAlignment
        {
          case .center: trackX = trackFrame.midX - trackMinBreadth * 0.5
          case .topOrLeft: trackX = trackFrame.minX
          case .bottomOrRight: trackX = trackFrame.maxX - trackMinBreadth
        }

        trackMinFrame = CGRect(
          origin: CGPoint(x: trackX, y: trackFrame.minY + unfilledTrack),
          size: CGSize(width: trackMinBreadth, height: filledTrack)
        )
        trackMaxFrame = CGRect(origin: CGPoint(x: trackX, y: trackFrame.minY),
                               size: CGSize(width: trackMaxBreadth, height: unfilledTrack))

        let thumbX: CGFloat

        switch thumbAlignment
        {
          case .center: thumbX = trackFrame.midX - thumbSize.width * 0.5
          case .topOrLeft: thumbX = trackFrame.minX
          case .bottomOrRight: thumbX = trackFrame.maxX - thumbSize.width
        }

        thumbFrame = CGRect(
          origin: CGPoint(x: thumbX, y: trackMinFrame.minY - pad),
          size: thumbSize
        )
    }

    // Draw the track segments
    if let trackMinImage = trackMinImage, let trackMaxImage = trackMaxImage
    {
      // trackMinColor.setFill()
      trackMinImage.drawAsPattern(in: trackMinFrame)
      // trackMaxColor.setFill()
      trackMaxImage.drawAsPattern(in: trackMaxFrame)
    }
    else
    {
      trackMinColor.setFill()
      UIRectFill(trackMinFrame)
      trackMaxColor.setFill()
      UIRectFill(trackMaxFrame)
    }

    // Draw the track label
    if showsTrackLabel,
       let text = trackLabelText
    {
      let attributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.font: trackLabelFont,
        NSAttributedString.Key.foregroundColor: trackLabelTextColor
      ]

      let trackFrame = trackMinFrame.union(trackMaxFrame)
      let size = text.size(withAttributes: attributes)

      let origin: CGPoint

      switch trackLabelAlignment
      {
        case .topLeft:
          origin = CGPoint(x: trackFrame.minX,
                           y: trackFrame.minY)
        case .top:
          origin = CGPoint(x: trackFrame.midX - size.width * 0.5,
                           y: trackFrame.minY)
        case .topRight:
          origin = CGPoint(x: trackFrame.maxX - size.width,
                           y: trackFrame.minY)
        case .left:
          origin = CGPoint(x: trackFrame.minX,
                           y: trackFrame.midY - size.height * 0.5)
        case .center:
          origin = CGPoint(x: trackFrame.midX - size.width * 0.5,
                           y: trackFrame.midY - size.height * 0.5)
        case .right:
          origin = CGPoint(x: trackFrame.maxX - size.width,
                           y: trackFrame.midY - size.height * 0.5)
        case .bottomLeft:
          origin = CGPoint(x: trackFrame.minX,
                           y: trackFrame.maxY - size.height)
        case .bottom:
          origin = CGPoint(x: trackFrame.midX - size.width * 0.5,
                           y: trackFrame.maxY - size.height)
        case .bottomRight:
          origin = CGPoint(x: trackFrame.maxX - size.width,
                           y: trackFrame.maxY - size.height)
      }

      let frame = CGRect(origin: origin, size: size).offsetBy(offset: trackLabelOffset)

      context.saveGState()
      context.setBlendMode(.clear)
      text.draw(in: frame, withAttributes: attributes)
      context.restoreGState()
    }

    // Draw the thumb
    if let thumbImage = thumbImage
    {
      // thumbColor.setFill()
      thumbImage.draw(in: thumbFrame)
    }
    else
    {
      thumbColor.setFill()
      trackMaxColor.setStroke()

      let thumbPath = UIBezierPath(ovalIn: thumbFrame)
      thumbPath.fill()
      thumbPath.stroke()
    }

    // Draw the value label
    if showsValueLabel
    {
      let text = String(value, precision: valueLabelPrecision)

      let attributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.font: valueLabelFont,
        NSAttributedString.Key.foregroundColor: valueLabelTextColor
      ]

      let size = text.size(withAttributes: attributes)
      let origin: CGPoint

      switch valueLabelAlignment
      {
        case .topLeft:
          origin = CGPoint(x: thumbFrame.minX,
                           y: thumbFrame.minY)
        case .top:
          origin = CGPoint(x: thumbFrame.midX - size.width * 0.5,
                           y: thumbFrame.minY)
        case .topRight:
          origin = CGPoint(x: thumbFrame.maxX - size.width,
                           y: thumbFrame.minY)
        case .left:
          origin = CGPoint(x: thumbFrame.minX,
                           y: thumbFrame.midY - size.height * 0.5)
        case .center:
          origin = CGPoint(x: thumbFrame.midX - size.width * 0.5,
                           y: thumbFrame.midY - size.height * 0.5)
        case .right:
          origin = CGPoint(x: thumbFrame.maxX - size.width,
                           y: thumbFrame.midY - size.height * 0.5)
        case .bottomLeft:
          origin = CGPoint(x: thumbFrame.minX,
                           y: thumbFrame.maxY - size.height)
        case .bottom:
          origin = CGPoint(x: thumbFrame.midX - size.width * 0.5,
                           y: thumbFrame.maxY - size.height)
        case .bottomRight:
          origin = CGPoint(x: thumbFrame.maxX - size.width,
                           y: thumbFrame.maxY - size.height)
      }

      let frame = CGRect(origin: origin, size: size).offsetBy(offset: valueLabelOffset)
      text.draw(in: frame, withAttributes: attributes)
    }

    if tintColorAlpha > 0
    {
      tintColor.withAlphaComponent(tintColorAlpha).setFill()

      if let trackMinImage = trackMinImage,
         let trackMaxImage = trackMaxImage,
         let thumbImage = thumbImage
      {
        UIGraphicsBeginImageContextWithOptions(trackFrame.size, false, 0)
        trackMinImage.drawAsPattern(in: trackMinFrame)
        trackMaxImage.drawAsPattern(in: trackMaxFrame)
        thumbImage.draw(in: thumbFrame)

        guard let image = UIGraphicsGetImageFromCurrentImageContext()
        else
        {
          loge("Failed to produce image from context")
          return
        }

        UIGraphicsEndImageContext()
        image.addClip()
        UIRectFillUsingBlendMode(trackFrame, .color)
      }
      else
      {
        UIRectFillUsingBlendMode(trackMinFrame, .color)
        UIRectFillUsingBlendMode(trackMaxFrame, .color)
        UIBezierPath(ovalIn: thumbFrame).addClip()
        UIRectFillUsingBlendMode(thumbFrame, .color)
      }
    }

    // Restore the context to previous state
    context.restoreGState()
  }

  // MARK: - Touch handling

  @IBInspectable open var continuous: Bool = true

  private var touch: UITouch?

  private var touchTime: TimeInterval = 0

  private var touchInterval: ClosedRange<Float>
  {
    return isVertical
      ? Float(frame.minY) ... Float(frame.maxY)
      : Float(frame.minX) ... Float(frame.maxX)
  }

  override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
  {
    guard self.touch == nil,
          let touch = touches.filter({ point(inside: $0.location(in: self), with: event) })
            .first
    else
    {
      return
    }

    self.touch = touch
  }

  private func updateValue(for touch: UITouch, sendActions: Bool)
  {
    guard touchTime != touch.timestamp else { return }

    let location = touch.location(in: self)
    let previousLocation = touch.previousLocation(in: self)

    let delta: CGFloat, distance: CGFloat
    let distanceInterval: ClosedRange<CGFloat>
    switch isVertical
    {
      case false:
        delta = (location - previousLocation).x
        distanceInterval = bounds.minY ... bounds.maxY
        distance = location.y
      case true:
        delta = (previousLocation - location).y
        distanceInterval = bounds.minX ... bounds.maxX
        distance = location.x
    }

    guard delta != 0 else { return }

    let valueInterval = self.valueInterval, touchInterval = self.touchInterval

    let newValue = valueInterval.mapValue(
      touchInterval.mapValue(value, from: valueInterval) + Float(delta),
      from: touchInterval
    )

    var valueDelta = value - newValue

    if !distanceInterval.contains(distance)
    {
      let clampedDistance = distanceInterval.clampValue(distance)
      let deltaDistance = max(Float(abs(distance - clampedDistance)), 1)
      valueDelta *= 1 / deltaDistance
    }

    value -= valueDelta
    touchTime = touch.timestamp

    guard sendActions else { return }

    self.sendActions(for: .valueChanged)
  }

  override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
  {
    guard let touch = touch, touches.contains(touch) else { return }

    updateValue(for: touch, sendActions: continuous)
  }

  override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?)
  {
    guard let touch = touch, touches.contains(touch) == true else { return }

    self.touch = nil
  }

  override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
  {
    guard let touch = touch, touches.contains(touch) else { return }

    updateValue(for: touch, sendActions: true)

    self.touch = nil
  }
}
