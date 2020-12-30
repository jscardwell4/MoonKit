//
//  UIFont+MoonKitAdditions.swift
//  HomeRemote
//
//  Created by Jason Cardwell on 8/17/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit

extension UIFont {

  public class func loadFontAwesome() {
    if let moonkit = Bundle.allFrameworks.filter({$0.bundleIdentifier == "com.moondeerstudios.MoonKit"}).first,
      let fontPath = moonkit.path(forResource: "FontAwesome", ofType: "otf"),
      let fontData = try? Data(contentsOf: URL(fileURLWithPath: fontPath)),
      let provider = CGDataProvider(data: fontData as CFData),
      let font = CGFont(provider)
    {
      if !CTFontManagerRegisterGraphicsFont(font, nil) {
        loge("failed to register 'FontAwesome' font with font manager")
      }
    }
  }

  public class func fontFamilyAvailable(_ family: String) -> Bool {
    return UIFont.familyNames.contains(family)
  }

  public var characterWidth: CGFloat {
    return ("W" as NSString).size(withAttributes: [NSAttributedString.Key.font:self]).width
  }

}

extension UIFont: JSONValueConvertible {
  public var jsonValue: JSONValue { return "\(fontName)@\(pointSize)".jsonValue }
}

extension UIFont /*: JSONValueInitializable */ {
  public convenience init?(_ jsonValue: JSONValue?) {
    guard let string = String(jsonValue) else {
      self.init()
      return nil
    }

    let regex = ~/"^([^@]*)(?:@?([0-9]*\\.?[0-9]*))?"
    let match = regex.firstMatch(in: string)

    guard let name = match?.captures[1]?.substring , UIFont.familyNames.contains(String(name)) else {
      self.init()
      return nil
    }

    let size: CGFloat

    if let capturedSize = match?.captures[2]?.substring, let sizeFromString = Double(capturedSize) { size = CGFloat(sizeFromString) }
    else { size = UIFont.systemFontSize }

    self.init(name: String(name), size: size)

  }
}

