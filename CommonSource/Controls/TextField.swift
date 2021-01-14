//
//  TextField.swift
//  MoonKit
//
//  Created by Jason Cardwell on 12/4/14.
//  Copyright (c) 2014 Jason Cardwell. All rights reserved.
//

import UIKit

@IBDesignable
public class TextField: UITextField {

  @IBInspectable public var gutter: UIEdgeInsets = .zero {
    didSet {
      guard gutter != oldValue else { return }
      invalidateIntrinsicContentSize()
    }
  }

  @IBInspectable public var tintColorAlpha: CGFloat = 0 {
    didSet {
      guard tintColorAlpha != oldValue else { return }
      tintColorAlpha = (0 ... 1).clampValue(tintColorAlpha)
      if !isHighlighted { setNeedsDisplay() }
    }
  }

  @IBInspectable public var highlightedTintColorAlpha: CGFloat = 0 {
    didSet {
      guard highlightedTintColorAlpha != oldValue else { return }
      highlightedTintColorAlpha = (0 ... 1).clampValue(highlightedTintColorAlpha)
      if isHighlighted { setNeedsDisplay() }
    }
  }

  public var verticalAlignment: VerticalAlignment = .Center {
    didSet { guard verticalAlignment != oldValue else { return }; setNeedsDisplay() }
  }

  @IBInspectable public var verticalAlignmentString: String {
    get { return verticalAlignment.rawValue }
    set { verticalAlignment = VerticalAlignment(rawValue: newValue) ?? .Center }
  }
  

  /**
  drawRect:

  - parameter rect: CGRect
  */
  public override func drawText(in rect: CGRect) {

    var textRect = self.textRect(forBounds: rect)
    switch verticalAlignment {
    case .Top:    break
      case .Center: textRect.origin.y += rect.height * 0.5 - textRect.height * 0.5
    case .Bottom: textRect.origin.y = rect.maxY - textRect.height
    }

    let alpha = isHighlighted ? highlightedTintColorAlpha : tintColorAlpha
    guard alpha > 0 else { super.drawText(in: textRect); return }

    UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
    super.drawText(in: textRect)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    let context = UIGraphicsGetCurrentContext()
    context?.saveGState()

    image?.addClip()
    tintColor.withAlphaComponent(alpha).setFill()
    UIRectFillUsingBlendMode(textRect, .color)

    context?.restoreGState()
  }

  /**
  intrinsicContentSize

  - returns: CGSize
  */
  public override var intrinsicContentSize: CGSize {
    return gutter.inset(CGRect(size: super.intrinsicContentSize)).size
  }

}
