//
//  TemplateImageView.swift
//  MoonKit
//
//  Created by Jason Cardwell on 10/2/15.
//  Copyright © 2015 Jason Cardwell. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
public class TemplateImageView: UIImageView {

  override public var image: UIImage? {
    get { return super.image }
    set { super.image = newValue?.withRenderingMode(.alwaysTemplate) }
  }

  override public var highlightedImage: UIImage? {
    get { return super.highlightedImage }
    set {
      super.highlightedImage = newValue?.withRenderingMode(.alwaysTemplate).image(withColor: highlightedTintColor ?? tintColor)
    }
  }

  override public var tintColor: UIColor! {
    didSet {
      setNeedsDisplay()
    }
  }

  @IBInspectable public var highlightedTintColor: UIColor? {
    didSet {
      highlightedImage = highlightedImage?.image(withColor: highlightedTintColor ?? tintColor)
    }
  }

  /**
  initWithFrame:

  - parameter frame: CGRect
  */
  public override init(frame: CGRect) {
    super.init(frame: frame)
  }

  /**
  initWithImage:highlightedImage:

  - parameter image: UIImage?
  - parameter highlightedImage: UIImage?
  */
  public override init(image: UIImage?, highlightedImage: UIImage?) {
    super.init(image: image?.withRenderingMode(.alwaysTemplate),
               highlightedImage: highlightedImage?.withRenderingMode(.alwaysTemplate))
  }

  /**
  initWithImage:

  - parameter image: UIImage?
  */
  public override init(image: UIImage?) {
    super.init(image: image?.withRenderingMode(.alwaysTemplate))
  }

  /**
  init:

  - parameter aDecoder: NSCoder
  */
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    highlightedTintColor = aDecoder.decodeObject(forKey: "highlightedTintColor") as? UIColor
    super.image = image?.withRenderingMode(.alwaysTemplate)
    super.highlightedImage = highlightedImage?.withRenderingMode(.alwaysTemplate).image(withColor: highlightedTintColor ?? tintColor)
  }
}
