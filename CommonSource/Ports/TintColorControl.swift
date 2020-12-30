//
//  TintColorControl.swift
//  MoonKit
//
//  Created by Jason Cardwell on 10/20/15.
//  Copyright © 2015 Jason Cardwell. All rights reserved.
//

import Foundation
import UIKit

public class TintColorControl: UIControl {

  // MARK: - Colors

  public override var tintColor: UIColor! {
    didSet { if normalTintColor == nil { normalTintColor = tintColor } }
  }

  @IBInspectable public var normalTintColor:           UIColor? { didSet { refresh() } }
  @IBInspectable public var highlightedTintColor:      UIColor? { didSet { refresh() } }
  @IBInspectable public var disabledTintColor:         UIColor? { didSet { refresh() } }
  @IBInspectable public var selectedTintColor:         UIColor? { didSet { refresh() } }
  @IBInspectable public var disabledSelectedTintColor: UIColor? { didSet { refresh() } }

  // MARK: - State

  public override var isEnabled:     Bool { get { return super.isEnabled }     set { super.isEnabled     = newValue; refresh() } }
  public override var isHighlighted: Bool { get { return super.isHighlighted } set { super.isHighlighted = newValue; refresh() } }
  public override var isSelected:    Bool { get { return super.isSelected }    set { super.isSelected    = newValue; refresh() } }

  /**
  tintColorForState:

  - parameter state: UIControlState

  - returns: UIColor
  */
  fileprivate func tintColorForState(_ state: UIControl.State) -> UIColor {
    let color: UIColor
    switch state {
      case [.disabled, .selected] where disabledSelectedTintColor != nil: color = disabledSelectedTintColor!
      case [.disabled]            where disabledTintColor         != nil: color = disabledTintColor!
      case [.selected]            where selectedTintColor         != nil: color = selectedTintColor!
      case [.highlighted]         where highlightedTintColor      != nil: color = highlightedTintColor!
      default:                                                            color = normalTintColor ?? tintColor
    }
    return color
  }

  /** refresh */
  public func refresh() { tintColor = tintColorForState(state); setNeedsDisplay() }

  /**
  initWithFrame:

  - parameter frame: CGRect
  */
  public override init(frame: CGRect) { super.init(frame: frame); normalTintColor = tintColor }

  /**
  encodeWithCoder:

  - parameter aCoder: NSCoder
  */
  public override func encode(with aCoder: NSCoder) {
    super.encode(with: aCoder)
    aCoder.encode(normalTintColor,           forKey:"normalTintColor")
    aCoder.encode(selectedTintColor,         forKey:"selectedTintColor")
    aCoder.encode(highlightedTintColor,      forKey:"highlightedTintColor")
    aCoder.encode(disabledTintColor,         forKey:"disabledTintColor")
    aCoder.encode(disabledSelectedTintColor, forKey:"disabledSelectedTintColor")
  }

  /**
  init:

  - parameter aDecoder: NSCoder
  */
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    normalTintColor           = aDecoder.decodeObject(forKey: "normalTintColor")           as? UIColor
    selectedTintColor         = aDecoder.decodeObject(forKey: "selectedTintColor")         as? UIColor
    highlightedTintColor      = aDecoder.decodeObject(forKey: "highlightedTintColor")      as? UIColor
    disabledTintColor         = aDecoder.decodeObject(forKey: "disabledTintColor")         as? UIColor
    disabledSelectedTintColor = aDecoder.decodeObject(forKey: "disabledSelectedTintColor") as? UIColor
    if normalTintColor == nil { normalTintColor = tintColor }
    refresh()
  }
  
}
