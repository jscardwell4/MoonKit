//
//  Marquee.swift
//  MoonKit
//
//  Created by Jason Cardwell on 10/7/15.
//  Copyright © 2015 Jason Cardwell. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
public class Marquee: UIView {

  fileprivate let textLayer: CALayer = {
    let layer = CALayer()
    layer.contentsScale = UIScreen.main.scale
    return layer
  }()

  public var verticalAlignment: VerticalAlignment = .Center {
    didSet { guard verticalAlignment != oldValue else { return }; staleCache = true }
  }

  @IBInspectable public var verticalAlignmentString: String {
    get { return verticalAlignment.rawValue }
    set { verticalAlignment = VerticalAlignment(rawValue: newValue) ?? .Center }
  }

  fileprivate var staleCache = true { didSet { guard staleCache else { return }; setNeedsLayout() } }

  @IBInspectable public var text: String = "" {
    didSet {
      guard text != oldValue else { return }
      textStorage.mutableString.setString(text)
      staleCache = true
      invalidateIntrinsicContentSize()
    }
  }

  fileprivate var 𝝙w: CGFloat = 0

  fileprivate func updateTextLayer() {
    guard staleCache else { return }
    defer { staleCache = false; scrollCheck() }

    // Set the text container with the view's height and unlimited width
    textContainer.size = CGSize(width: CGFloat.greatestFiniteMagnitude, height: bounds.height)

    // Get the glyph range and the bounding rect for laying out all the glyphs
    let characterRange = NSRange(0 ..< text.utf16.count)
    let glyphRange = layoutManager.glyphRange(forCharacterRange: characterRange, actualCharacterRange: nil)
    layoutManager.ensureLayout(forGlyphRange: glyphRange)

    let textRect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
    𝝙w = max(textRect.width - bounds.width, 0)

    // Adjust the result according to how it fits the view's bounds
    var textFrame = textRect
    switch verticalAlignment {
      case .Top: textFrame.origin.y = 0
      case .Center: textFrame.origin.y += bounds.height * 0.5 - font.pointSize * 0.5
      case .Bottom: textFrame.origin.y += bounds.height - font.pointSize
    }

    let extendText: Bool

    switch bounds.contains(textRect) {
      case true:  textFrame.origin.x += (bounds.width - textRect.width) * 0.5; extendText = false
      case false: textFrame.size.width = textRect.width * 2;                 extendText = true
    }

    // Update the text layer's frame
    textLayer.frame = textFrame.integral

    // Ensure there is an appropriate size and content or exit
    guard !(textLayer.bounds.isEmpty || textStorage.string.isEmpty) else { textLayer.contents = nil; return }

    // Draw the text into a bitmap context
    UIGraphicsBeginImageContextWithOptions(textLayer.bounds.size, false, 0)

    layoutManager.drawGlyphs(forGlyphRange: glyphRange, at: .zero)

    // If we made the layer twice as wide, draw the text again
    if extendText {
      let separator = NSAttributedString(string: scrollSeparator,
                                         attributes: [NSAttributedString.Key.font: font,
                                                      NSAttributedString.Key.foregroundColor: textColor])
      separator.draw(at: CGPoint(x: textRect.width, y: 0))
      let wʹ = separator.size().width
      𝝙w += wʹ
      layoutManager.drawGlyphs(forGlyphRange: glyphRange, at: CGPoint(x: textRect.width + wʹ, y: 0))
    }

    guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
      fatalError("Failed to generate image for text layer")
    }

    UIGraphicsEndImageContext()

    // Update the layer's contents
    textLayer.contents = image.cgImage
    invalidateIntrinsicContentSize()
    setNeedsDisplay()
  }

  @IBInspectable public var scrollSeparator: String = "•"
  @IBInspectable public var textColor: UIColor = UIColor.black {
    didSet {
      textStorage.beginEditing()
      textStorage.addAttribute(NSAttributedString.Key.foregroundColor,
                               value: textColor,
                               range: NSRange(0 ..< textStorage.length))
      textStorage.endEditing()
      staleCache = true
      setNeedsDisplay()
    }
  }
  public static let defaultFont = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.headline)
  public var font: UIFont = Marquee.defaultFont {
    didSet {
      textStorage.beginEditing()
      textStorage.addAttribute(NSAttributedString.Key.font, value: font, range: NSRange(0 ..< textStorage.length))
      textStorage.endEditing()
      staleCache = true
      invalidateIntrinsicContentSize()
      setNeedsDisplay()
    }
  }

  @IBInspectable public var fontName: String = Marquee.defaultFont.fontName {
    didSet { if let font = UIFont(name: fontName, size: font.pointSize) { self.font = font } }
  }

  @IBInspectable public var fontSize: CGFloat = Marquee.defaultFont.pointSize {
    didSet { font = font.withSize(fontSize) }
  }

  /// How fast to scroll text in characters per second.
  @IBInspectable public var scrollSpeed: Double = 1

  /// Whether the text should scroll when it does not all fit.
  @IBInspectable public var scrollEnabled: Bool = true { didSet { scrollCheck() } }

  fileprivate var isScrolling: Bool {
    return textLayer.animationKeys()?.contains(Marquee.AnimationKey) == true
  }

  fileprivate static let AnimationKey = "MarqueeScroll"

  fileprivate func scrollCheck() {
    switch (scrollEnabled, isScrolling) {
      case (true, false) where  shouldScroll: beginScrolling()
      case (true,  true) where !shouldScroll: endScrolling()
      case (false, true):                     endScrolling()
      default:                                break
    }
  }

  fileprivate var shouldScroll: Bool {
    guard scrollEnabled && window != nil else { return false }
    return textLayer.bounds.width > bounds.width
  }

  public let layoutManager: NSLayoutManager = NSLayoutManager()
  public let textStorage: NSTextStorage = NSTextStorage()
  public let textContainer: NSTextContainer = {
    let container = NSTextContainer()
    container.lineBreakMode = .byCharWrapping
    container.lineFragmentPadding = 0
    container.maximumNumberOfLines = 1
    return container
    }()

  fileprivate func setup() {
    isUserInteractionEnabled = false
    layoutManager.usesFontLeading = false
    layoutManager.addTextContainer(textContainer)
    textStorage.addLayoutManager(layoutManager)
    textStorage.beginEditing()
    textStorage.addAttribute(NSAttributedString.Key.font, value: font, range: NSRange(location: 0, length: 0))
    textStorage.addAttribute(NSAttributedString.Key.foregroundColor,
                             value: textColor,
                             range: NSRange(location: 0, length: 0))
    textStorage.endEditing()
    layer.addSublayer(textLayer)
    layer.masksToBounds = true
  }

  public override init(frame: CGRect) { super.init(frame: frame); setup() }

  public override func encode(with aCoder: NSCoder) {
    super.encode(with: aCoder)
    aCoder.encode(font, forKey: "font")
    aCoder.encode(fontName, forKey: "fontName")
    aCoder.encode(Float(fontSize), forKey: "fontSize")
    aCoder.encode(textColor, forKey: "textColor")
    aCoder.encode(text, forKey: "text")
    aCoder.encode(scrollSeparator, forKey: "scrollSeparator")
    aCoder.encode(scrollSpeed, forKey: "scrollSpeed")
  }

  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    if let font = aDecoder.decodeObject(forKey: "font") as? UIFont { self.font = font }
    if let fontName = aDecoder.decodeObject(forKey: "fontName") as? String { self.fontName = fontName }
    fontSize = CGFloat(aDecoder.decodeFloat(forKey: "fontSize"))
    if let text = aDecoder.decodeObject(forKey: "text") as? String { self.text = text }
    if let textColor = aDecoder.decodeObject(forKey: "textColor") as? UIColor { self.textColor = textColor }
    if let scrollSeparator = aDecoder.decodeObject(forKey: "scrollSeparator") as? String {
      self.scrollSeparator = scrollSeparator
    }
    scrollSpeed = aDecoder.decodeDouble(forKey: "scrollSpeed")
    setup()
  }

  public override func layoutSubviews() { super.layoutSubviews(); updateTextLayer() }

  public override var frame: CGRect {
    didSet {
      guard frame.size != oldValue.size else { return }
      staleCache = true
    }
  }

  public override var bounds: CGRect {
    didSet {
      guard bounds.size != oldValue.size else { return }
      staleCache = true
    }
  }

  public override var intrinsicContentSize: CGSize { return textStorage.size().ceilSize }

  public override func didMoveToWindow() {
    super.didMoveToWindow()
    guard window != nil else { return }
    scrollCheck()
  }

  fileprivate func beginScrolling() {
    guard scrollEnabled && !isScrolling else { return }

    let animation = CABasicAnimation(keyPath: "transform.translation.x")
    animation.duration = scrollSpeed * CFTimeInterval(text.utf16.count + scrollSeparator.utf16.count)
    animation.toValue = -bounds.width - 𝝙w
    animation.repeatCount = Float.infinity
    textLayer.add(animation, forKey: Marquee.AnimationKey)
  }

  fileprivate func endScrolling() {
    guard isScrolling else { return }
    textLayer.removeAnimation(forKey: Marquee.AnimationKey)
  }

}
