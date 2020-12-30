//
//  NSLayoutConstraint.swift
//  MSKit
//
//  Created by Jason Cardwell on 10/7/14.
//  Copyright (c) 2014 Jason Cardwell. All rights reserved.
//

import Foundation
import UIKit

extension NSLayoutConstraint {

  public var prettyDescription: String {
    let pseudo = PseudoConstraint(self)
    return pseudo.validPseudo ? pseudo.description : description
  }

  public class func splitFormat(_ format: String) -> [String] {
    var format = format.substitute("::", "\n")
    format = format.substitute("[⏎;]", "\n")
    format = format.substitute("  +", " ")

    return format.split(separator: "\n")
      .map({$0.trimmingCharacters(in: .whitespacesAndNewlines)})
      .filter({!$0.isEmpty})
  }

  public convenience init(_ pseudoConstraint: PseudoConstraint) {
    assert(pseudoConstraint.validConstraint)
    self.init(item: pseudoConstraint.firstObject!,
              attribute: pseudoConstraint.firstAttribute.NSLayoutAttributeValue,
              relatedBy: pseudoConstraint.relation.NSLayoutRelationValue,
              toItem: pseudoConstraint.secondObject,
              attribute: pseudoConstraint.secondAttribute.NSLayoutAttributeValue,
              multiplier: CGFloat(pseudoConstraint.multiplier),
              constant: CGFloat(pseudoConstraint.constant))
    identifier = pseudoConstraint.identifier
    priority = pseudoConstraint.priority
  }

  public class func constraints(byParsingFormat format: String,
                                options: NSLayoutConstraint.FormatOptions = [],
                                metrics: [String:AnyObject] = [:],
                                views: [String:AnyObject] = [:]) -> [NSLayoutConstraint]
  {
    var result: [NSLayoutConstraint] = []

    for string in splitFormat(format) {
      guard var pseudoConstraint = PseudoConstraint(string),
            let firstItem = pseudoConstraint.firstItem,
            let firstObject = views[firstItem],
            pseudoConstraint.firstAttribute != .notAnAttribute
              && ( pseudoConstraint.secondItem != nil
                || pseudoConstraint.secondAttribute == .notAnAttribute)
        else
      {
        result.append(contentsOf: self.constraints(withVisualFormat: string,
                                                   options: options,
                                                   metrics: metrics,
                                                   views: views))
        continue
      }

      pseudoConstraint.firstObject = PseudoConstraint.ObjectValue(firstObject)
      let secondObject: AnyObject? = pseudoConstraint.secondItem == nil
                                       ? nil
                                       : views[pseudoConstraint.secondItem!]

      guard pseudoConstraint.secondItem == nil || secondObject != nil else {
        result.append(contentsOf: self.constraints(withVisualFormat: string,
                                                   options: options,
                                                   metrics: metrics,
                                                   views: views))
        continue
      }

      pseudoConstraint.secondObject = PseudoConstraint.ObjectValue(secondObject)
      
      let constraints = pseudoConstraint.expanded.compactMap(NSLayoutConstraint.init)

      guard constraints.count > 0 else {
        result.append(contentsOf: self.constraints(withVisualFormat: string,
                                                   options: options,
                                                   metrics: metrics,
                                                   views: views))
        continue
      }

      result.append(contentsOf: constraints)
    }

    return result
  }

}

extension NSLayoutConstraint.Attribute {
  public var axis: NSLayoutConstraint.Axis {
    switch self {
      case .width,
           .left, .leftMargin,
           .leading, .leadingMargin,
           .right, .rightMargin,
           .trailing, .trailingMargin,
           .centerX, .centerXWithinMargins:
        return .horizontal
      default: return .vertical
    }
  }
}
