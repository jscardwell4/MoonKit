//
//  UILabel+MoonKitAdditions.swift
//  MoonKit
//
//  Created by Jason Cardwell on 8/3/15.
//  Copyright © 2015 Jason Cardwell. All rights reserved.
//

import Foundation
import UIKit

public extension UILabel {

  convenience init(autolayout: Bool = false, attributedText: NSAttributedString?) {
    self.init(autolayout: autolayout)
    self.attributedText = attributedText
  }

}
