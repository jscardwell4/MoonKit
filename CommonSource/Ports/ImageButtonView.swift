//
//  ImageButtonView.swift
//  MoonKit
//
//  Created by Jason Cardwell on 5/20/15.
//  Copyright (c) 2015 Jason Cardwell. All rights reserved.
//

import UIKit

@IBDesignable
public class ImageButtonView: ToggleControl {

  override public var tintColor: UIColor! { didSet { setNeedsDisplay() } }

  public enum ImageState: String, Equatable, Hashable { case Default, Highlighted, Disabled, Selected }

  // MARK: - Images

  @IBInspectable public var image: UIImage? { 
    didSet { 
      if let image = image , image.renderingMode != .alwaysTemplate {
        self.image = image.withRenderingMode(.alwaysTemplate)
      }
      refresh() 
    } 
  }
  @IBInspectable public var highlightedImage: UIImage? { 
    didSet { 
      if let highlightedImage = highlightedImage , highlightedImage.renderingMode != .alwaysTemplate {
        self.highlightedImage = highlightedImage.withRenderingMode(.alwaysTemplate)
      }
      refresh() 
    } 
  }
  @IBInspectable public var disabledImage: UIImage? { 
    didSet { 
      if let disabledImage = disabledImage , disabledImage.renderingMode != .alwaysTemplate {
        self.disabledImage = disabledImage.withRenderingMode(.alwaysTemplate)
      }
      refresh() 
    } 
  }
  @IBInspectable public var selectedImage: UIImage? { 
    didSet { 
      if let selectedImage = selectedImage , selectedImage.renderingMode != .alwaysTemplate {
        self.selectedImage = selectedImage.withRenderingMode(.alwaysTemplate)
      }
      refresh() 
    } 
  }

  /**
  imageForState:

  - parameter state: ImageState

  - returns: UIImage?
  */
  public func imageForState(_ state: ImageState) -> UIImage? {
    switch state {
      case .Default: return image
      case .Highlighted: return highlightedImage
      case .Disabled: return disabledImage
      case .Selected: return selectedImage
    }
  }

  /**
  setImage:forState:

  - parameter image: UIImage?
  - parameter forState: ImageState
  */
  public func setImage(_ image: UIImage?, forState state: ImageState) {
    switch state {
        case .Default: self.image = image
        case .Highlighted: highlightedImage = image
        case .Disabled: disabledImage = image
        case .Selected: selectedImage = image
    }
  }

  fileprivate weak var _currentImage: UIImage? { didSet { if _currentImage != oldValue { setNeedsDisplay() } } }
  public var currentImage: UIImage? { return _currentImage ?? image }

  /**
  imageForState:

  - parameter state: UIControlState

  - returns: UIImage?
  */
  fileprivate func imageForState(_ state: UIControl.State) -> UIImage? {
    let img: UIImage?
    switch state {
      case [.disabled] where disabledImage != nil:                  img = disabledImage!
      case [.selected] where selectedImage != nil:                  img = selectedImage!
      case [.highlighted] where highlightedImage != nil:            img = highlightedImage!
      case [.disabled], [.selected], [.highlighted]:                img = currentImage
      default:                                                      img = image
    }
    return img
  }


  /**
  intrinsicContentSize

  - returns: CGSize
  */
  override public var intrinsicContentSize: CGSize { return image?.size ?? CGSize(square: UIView.noIntrinsicMetric) }

  /** refresh */
  public override func refresh() { super.refresh(); _currentImage = imageForState(state) }

  /** setup */
  fileprivate func setup() { isOpaque = false }

  /**
  initWithFrame:

  - parameter frame: CGRect
  */
  public override init(frame: CGRect) { super.init(frame: frame); setup() }

  /**
  encodeWithCoder:

  - parameter aCoder: NSCoder
  */
  public override func encode(with aCoder: NSCoder) {
    super.encode(with: aCoder)
    aCoder.encode(toggle,             forKey: "toggle")
    aCoder.encode(image,            forKey: "image")
    aCoder.encode(selectedImage,    forKey: "selectedImage")
    aCoder.encode(highlightedImage, forKey: "highlightedImage")
    aCoder.encode(disabledImage,    forKey: "disabledImage")
  }

  /**
  init:

  - parameter aDecoder: NSCoder
  */
  public required init?(coder aDecoder: NSCoder) { 
    super.init(coder: aDecoder); setup() 
    image            = aDecoder.decodeObject(forKey: "image")            as? UIImage
    selectedImage    = aDecoder.decodeObject(forKey: "selectedImage")    as? UIImage
    highlightedImage = aDecoder.decodeObject(forKey: "highlightedImage") as? UIImage
    disabledImage    = aDecoder.decodeObject(forKey: "disabledImage")    as? UIImage
  }

  /**
  drawRect:

  - parameter rect: CGRect
  */
  public override func draw(_ rect: CGRect) {
    guard let image = _currentImage else { return }

    let context = UIGraphicsGetCurrentContext()
    context?.saveGState()
    context?.clear(rect)
    UIRectClip(rect)

    let 𝝙size = image.size - rect.size
    let x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat

    switch contentMode {
      case .scaleToFill, .redraw:
        (x, y, w, h) = rect.unpack4
      case .scaleAspectFit:
        (w, h) = image.size.aspectMappedToSize(rect.size, binding: true).unpack
        x = rect.midX - w * 0.5
        y = rect.midY - h * 0.5
      case .scaleAspectFill:
        (w, h) = image.size.aspectMappedToSize(rect.size, binding: false).unpack
        x = rect.midX - w * 0.5
        y = rect.midY - h * 0.5
      case .center:
        x = rect.x - 𝝙size.width * 0.5
        y = rect.y - 𝝙size.height * 0.5
        (w, h) = image.size.unpack
      case .top:
        x = rect.x - 𝝙size.width * 0.5
        y = rect.y
        (w, h) = image.size.unpack
      case .bottom:
        x = rect.x - 𝝙size.width * 0.5
        y = rect.maxY - image.size.height
        (w, h) = image.size.unpack
      case .left:
        x = rect.x
        y = rect.y - 𝝙size.height * 0.5
        (w, h) = image.size.unpack
      case .right:
        x = rect.maxX - image.size.width
        y = rect.y - 𝝙size.height * 0.5
        (w, h) = image.size.unpack
      case .topLeft:
        (x, y) = rect.origin.unpack
        (w, h) = image.size.unpack
      case .topRight:
        x = rect.maxX - image.size.width
        y = rect.y
        (w, h) = image.size.unpack
      case .bottomLeft:
        x = rect.x
        y = rect.maxY - image.size.height
        (w, h) = image.size.unpack
      case .bottomRight:
        x = rect.maxX - image.size.width
        y = rect.maxY - image.size.height
        (w, h) = image.size.unpack
      @unknown default:
        fatalError("\(#fileID) \(#function) Unexpected case.")
    }

    image.draw(in: CGRect(x: x, y: y, width: w, height: h))

    tintColor.setFill()
    UIBezierPath(rect: rect).fill(with: .sourceIn, alpha: 1)

    context?.restoreGState()
  }
}
