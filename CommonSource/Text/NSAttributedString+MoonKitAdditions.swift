//
//  NSAttributedString+MoonKitAdditions.swift
//  Remote
//
//  Created by Jason Cardwell on 12/11/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit


extension NSAttributedString {
  public var font: UIFont? { return attribute(NSAttributedString.Key.font, at: 0, effectiveRange: nil) as? UIFont }

  public var foregroundColor: UIColor? {
    return length > 0 ? attribute(NSAttributedString.Key.foregroundColor, at: 0, effectiveRange: nil) as? UIColor : nil
  }

  public var backgroundColor: UIColor? {
    return length > 0 ? attribute(NSAttributedString.Key.backgroundColor, at: 0, effectiveRange: nil) as? UIColor : nil
  }

}

//extension NSMutableAttributedString {
//
//  @objc public var font: UIFont? {
//    get { return length > 0 ? attribute(NSAttributedString.Key.font, at: 0, effectiveRange: nil) as? UIFont : nil }
//    set {
//      if length > 0 {
//        if newValue != nil { addAttribute(NSAttributedString.Key.font, value: newValue!, range: NSRange(0..<length)) }
//        else { removeAttribute(NSAttributedString.Key.font, range: NSRange(0..<length)) }
//      }
//    }
//  }
//
//  /**
//  setFont:
//
//  - parameter font: UIFont
//  */
//  public func setFont(_ font: UIFont, range: CountableRange<Int>? = nil) {
//    if length > 0 { addAttribute(NSAttributedString.Key.font, value: font, range: NSRange(range ?? 0..<length)) }
//  }
//
//}

public prefix func ¶(string: String) -> NSAttributedString {
  return NSAttributedString(string: string)
}

public func |(lhs: NSAttributedString, rhs: UIColor) -> NSAttributedString {
  guard lhs.length > 0 else { return lhs }
  var attributes = lhs.attributes(at: 0, effectiveRange: nil)
  attributes[NSAttributedString.Key.foregroundColor] = rhs
  return NSAttributedString(string: lhs.string, attributes: attributes)
}

public func |(lhs: NSAttributedString, rhs: UIFont) -> NSAttributedString {
  guard lhs.length > 0 else { return lhs }
  var attributes = lhs.attributes(at: 0, effectiveRange: nil)
  attributes[NSAttributedString.Key.font] = rhs
  return NSAttributedString(string: lhs.string, attributes: attributes)
}

public func |(lhs: NSAttributedString, rhs: NSParagraphStyle) -> NSAttributedString {
  guard lhs.length > 0 else { return lhs }
  var attributes = lhs.attributes(at: 0, effectiveRange: nil)
  attributes[NSAttributedString.Key.paragraphStyle] = rhs
  return NSAttributedString(string: lhs.string, attributes: attributes)
}

public func |(lhs: NSAttributedString, rhs: NSShadow) -> NSAttributedString {
  guard lhs.length > 0 else { return lhs }
  var attributes = lhs.attributes(at: 0, effectiveRange: nil)
  attributes[NSAttributedString.Key.shadow] = rhs
  return NSAttributedString(string: lhs.string, attributes: attributes)
}

public func ¶|(string: String, attributes: [AnyObject]) -> NSAttributedString {
  var dict: [NSAttributedString.Key:Any] = [:]
  for attribute in attributes {
    switch attribute {
      case let font as UIFont: dict[.font] = font
      case let color as UIColor: dict[.foregroundColor] = color
      case let paragraphStyle as NSParagraphStyle: dict[.paragraphStyle] = paragraphStyle
      case let shadow as NSShadow: dict[.shadow] = shadow
      default: break
    }
  }
  return dict.count > 0 ? NSAttributedString(string: string, attributes: dict) : NSAttributedString(string: string)
}

