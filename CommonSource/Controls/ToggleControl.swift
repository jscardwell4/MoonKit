//
//  ToggleControl.swift
//  MoonKit
//
//  Created by Jason Cardwell on 10/11/15.
//  Copyright © 2015 Jason Cardwell. All rights reserved.
//

import Foundation
import UIKit

public class ToggleControl: TintColorControl {

  // MARK: - Toggling

  /// Whether changes to `highlighted` should toggle `selected`
  @IBInspectable public var toggle: Bool = false

  fileprivate var toggleBegan = false

  public override var isHighlighted: Bool {
    didSet {
      guard isHighlighted != oldValue else { return }
      if toggle && toggleBegan && !isHighlighted { isSelected.toggle() }
      else if toggle && !toggleBegan && isHighlighted { toggleBegan = true }
    }
  }

  /// Overridden to implement optional toggling
  public override var isSelected: Bool {
    get {
    return super.isSelected
    }
    set {
      if super.isSelected != newValue { toggleBegan = false }
      super.isSelected = newValue
    }
  }

  /**
  initWithFrame:

  - parameter frame: CGRect
  */
  public override init(frame: CGRect) { super.init(frame: frame) }

  /**
  encodeWithCoder:

  - parameter aCoder: NSCoder
  */
  public override func encode(with aCoder: NSCoder) {
    super.encode(with: aCoder)
    aCoder.encode(toggle, forKey: "toggle")
  }

  /**
  init:

  - parameter aDecoder: NSCoder
  */
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    toggle = aDecoder.decodeBool(forKey: "toggle")
  }
  
}
