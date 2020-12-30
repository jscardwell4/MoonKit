//
//  PopoverView.swift
//  MoonKit
//
//  Created by Jason Cardwell on 5/22/15.
//  Copyright (c) 2015 Jason Cardwell. All rights reserved.
//

import UIKit

//@IBDesignable
public class PopoverView: UIView {

  /** Enumeration to define which edge of the view will have an arrow */
  public enum Location: String { case Top, Bottom }

  /** Whether the arrow is drawn at the top or the bottom of the view, also affects label offsets and alignment rect */
  public var location: Location = .Bottom {
    didSet {
      guard oldValue != location else { return }
      refreshShape()
      let constraints = self.constraints(withIdentifier: constraintID)
      if constraints.count > 0 {
        removeConstraints(constraints)
        needsContentConstraints = true
        setNeedsUpdateConstraints()
      }
    }
  }
  @IBInspectable public var locationString: String {
    get { return location.rawValue }
    set { if let location = Location(rawValue: newValue) { self.location = location }  }
  }

  fileprivate var needsContentConstraints = false

  /** Value used to size the arrow's width */
  @IBInspectable public var arrowWidth: CGFloat = 10  { didSet { refreshShape() } }

  /** Value used to size the arrow's height */
  @IBInspectable public var arrowHeight: CGFloat = 10  { didSet { refreshShape() } }

  /** Value used to place arrow */
  @IBInspectable public var xOffset: CGFloat = 0 { didSet { refreshShape() } }


  /** Padding for the content view */
  public var contentInsets = UIEdgeInsets(inset: 0) {
    didSet {
      guard contentInsets != oldValue else { return }
      invalidateIntrinsicContentSize()
      removeConstraints(constraints(withIdentifier: Identifier(for: self, tags: "Content")))
      setNeedsUpdateConstraints()
    }
  }

  /**
  intrinsicConltentSize

  - returns: CGSize
  */
  public override var intrinsicContentSize: CGSize {
    guard let contentView = contentView else { return super.intrinsicContentSize }
    var size = contentView.intrinsicContentSize
    for subview in contentView.subviews {
      let subviewIntrinsicContentSize = subview.intrinsicContentSize
      size.width = max(size.width, subviewIntrinsicContentSize.width)
      size.height = max(size.height, subviewIntrinsicContentSize.height)
    }
    return CGSize(width: size.width + contentInsets.displacement.horizontal,
                  height: size.height + contentInsets.displacement.vertical)
  }

  /**
  Overridden to account for the top/bottom arrow

  - returns: UIEdgeInsets
  */
  public override var alignmentRectInsets: UIEdgeInsets {
    switch location {
      case .Top:    return UIEdgeInsets(top: arrowHeight, left: 0, bottom: 0, right: 0)
      case .Bottom: return UIEdgeInsets(top: 0, left: 0, bottom: arrowHeight, right: 0)
    }
  }

  /** Method for updating the shape layer's path according to the views `bounds` and `location` */
  fileprivate func refreshShape() {
    let (w, h) = bounds.size.unpack
    guard w > arrowWidth && h > arrowHeight else { return }

    let mid = round(w * 0.5 + xOffset)
    let arrowWidth_2 = arrowWidth / 2
    let path = UIBezierPath()

    switch location {
      case .Top:
        path.move   (to: CGPoint(x: 0,                     y: arrowHeight    ))
        path.addLine(to: CGPoint(x: mid - arrowWidth_2,    y: arrowHeight    ))
        path.addLine(to: CGPoint(x: mid,                   y: 0              ))
        path.addLine(to: CGPoint(x: mid + arrowWidth_2,    y: arrowHeight    ))
        path.addLine(to: CGPoint(x: w,                     y: arrowHeight    ))
        path.addLine(to: CGPoint(x: w,                     y: h              ))
        path.addLine(to: CGPoint(x: 0,                     y: h              ))
      case .Bottom:
        path.move   (to: CGPoint(x: 0,                     y: 0              ))
        path.addLine(to: CGPoint(x: w,                     y: 0              ))
        path.addLine(to: CGPoint(x: w,                     y: h - arrowHeight))
        path.addLine(to: CGPoint(x: mid + arrowWidth_2,    y: h - arrowHeight))
        path.addLine(to: CGPoint(x: mid,                   y: h              ))
        path.addLine(to: CGPoint(x: mid - arrowWidth_2,    y: h - arrowHeight))
        path.addLine(to: CGPoint(x: 0,                     y: h - arrowHeight))
    }

    path.close()

    maskingLayer.frame = CGRect(size: bounds.size)
    maskingLayer.path = path.cgPath
  }


  @IBOutlet public fileprivate(set) weak var contentView: UIView!

  /** Overridden so we can update our shape's path on bounds changes */
  public override var bounds: CGRect { didSet { refreshShape() } }

  /** Convenience accessor for the shape layer used to mask root layer */
  fileprivate var maskingLayer: CAShapeLayer { return layer.mask as! CAShapeLayer }

  /** initializeIVARs */
  func initializeIVARs() {
    translatesAutoresizingMaskIntoConstraints = false
    layer.mask = CAShapeLayer()
    refreshShape()
  }

  fileprivate let constraintID = Identifier("PopoverView", "Content")

  /** updateConstraints */
  public override func updateConstraints() {
    super.updateConstraints()

    guard needsContentConstraints && constraints(withIdentifier: constraintID).count == 0 else { return }

    let topOffset:    CGFloat = location == .Top    ? arrowHeight : 0
    let bottomOffset: CGFloat = location == .Bottom ? arrowHeight : 0
    constrain(identifier: constraintID,
              𝗩∶|-(contentInsets.top - topOffset)-[contentView!]-(contentInsets.bottom + bottomOffset)-|,
      𝗛∶|-contentInsets.left-[contentView!]-contentInsets.right-|
    )
    needsContentConstraints = false
  }

  /**
  requiresConstraintBasedLayout

  - returns: Bool
  */
  public override class var requiresConstraintBasedLayout: Bool { return true }

  /**
  initWithLabelData:dismissal:

  - parameter labelData: [LabelData]
  - parameter callback: ((PopoverView) -> Void
  */
  public override init(frame: CGRect) {
    super.init(frame: frame)
    #if !TARGET_INTERFACE_BUILDER
      let contentView = UIView(autolayout: true)
      addSubview(contentView)
      self.contentView = contentView
      needsContentConstraints = true
    #endif

    initializeIVARs()
  }

  /** layoutSubviews */
  public override func layoutSubviews() { super.layoutSubviews(); refreshShape() }

  /**
  encodeWithCoder:

  - parameter aCoder: NSCoder
  */
  public override func encode(with aCoder: NSCoder) {
    super.encode(with: aCoder)
    aCoder.encode(Double(arrowWidth), forKey: "arrowWidth")
    aCoder.encode(Double(arrowHeight), forKey: "arrowHeight")
    aCoder.encode(Double(xOffset), forKey: "xOffset")
    aCoder.encode(contentInsets, forKey: "contentInsets")
    aCoder.encode(location.rawValue, forKey: "location")
  }

  /**
  Initialization with coder is unsupported

  - parameter aDecoder: NSCoder
  */
  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)

    if aDecoder.containsValue(forKey: "arrowWidth") { arrowWidth = CGFloat(aDecoder.decodeDouble(forKey: "arrowWidth")) }
    if aDecoder.containsValue(forKey: "arrowHeight") { arrowHeight = CGFloat(aDecoder.decodeDouble(forKey: "arrowHeight")) }
    if aDecoder.containsValue(forKey: "xOffset") { xOffset = CGFloat(aDecoder.decodeDouble(forKey: "xOffset")) }
    if aDecoder.containsValue(forKey: "contentInsets") { contentInsets = aDecoder.decodeUIEdgeInsets(forKey: "contentInsets") }
    if aDecoder.containsValue(forKey: "location") {
      location = Location(rawValue: aDecoder.decodeObject(forKey: "location") as? String ?? Location.Bottom.rawValue)!
    }
    initializeIVARs()
  }

}
