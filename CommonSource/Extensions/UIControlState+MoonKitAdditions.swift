//
//  UIControlState+MoonKitAdditions.swift
//  MoonKit
//
//  Created by Jason Cardwell on 10/11/15.
//  Copyright © 2015 Jason Cardwell. All rights reserved.
//

import Foundation
import UIKit

extension UIControl.State: CustomStringConvertible {
  public var description: String {
    var result = "UIControlState {"
    var strings: [String] = []
    if self ∋ .highlighted { strings.append("Highlighted") }
    if self ∋ .selected { strings.append("Selected") }
    if self ∋ .disabled { strings.append("Disabled") }
    if strings.isEmpty { strings.append("Normal") }
    result += ", ".join(strings)
    result += "}"
    return result
  }
}
