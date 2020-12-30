//
//  UIColor+MoonKitAdditions.swift
//  MoonKit
//
//  Created by Jason Cardwell on 11/21/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
//import Chameleon

extension UIColor: JSONValueConvertible {
  public var jsonValue: JSONValue { return JSONValue.string(string!) }
}
extension UIColor /*: JSONValueInitializable */ {
  public convenience init?(_ jsonValue: JSONValue?) {
    if let string = String(jsonValue) {
      self.init(string: string)
    } else {
      self.init()
      return nil
    }
  }
}

extension UIColor: StringValueConvertible { public var stringValue: String { return string ?? "" } }

extension UIColor {

  /**
  initWithString:

  - parameter string: String
  */
  public convenience init?(string: String) {
    if let namedColor = NamedColor(name: string) {
      self.init(rgbaHex: namedColor.rawValue)
    } else if string ~= "@.*%" {
      let substrings = string.split(separator: "@")
      let base = String(substrings[0])
      let rawAlpha = String(substrings[1])
      guard let namedColor = NamedColor(name: base), let percentAlpha = Int(String(rawAlpha.dropLast())) else {
        return nil
      }
      let baseHex = namedColor.rawValue
      let red = CGFloat(baseHex >> 24 & 0xFF) / 255
      let green = CGFloat(baseHex >> 16 & 0xFF) / 255
      let blue = CGFloat(baseHex >> 8 & 0xFF) / 255
      let alpha = CGFloat(percentAlpha) / 255
      self.init(red: red, green: green, blue: blue, alpha: alpha)
    } else if string.hasPrefix("#") {
      switch string.count {
        case 7:
          guard let rgbHex = UInt32(String(string[string.index(after: string.startIndex)...]), radix: 16) else { return nil }
          self.init(rgbHex: rgbHex)
        case 9:
          guard let rgbaHex = UInt32(String(string[string.index(after: string.startIndex)...]), radix: 16) else { return nil }
          self.init(rgbaHex: rgbaHex)
        default: return nil
      }
    } else {
      let components = string.split(separator: " ").compactMap(Double.init).map({CGFloat($0)})
      switch components.count {
        case 3: self.init(red: components[0], green: components[1], blue: components[2], alpha: 1.0)
        case 4: self.init(red: components[0], green: components[1], blue: components[2], alpha: components[3])
        default: return nil
      }
    }
  }

  public var rgba: (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat)? {
    var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
    return getRed(&r, green: &g, blue: &b, alpha: &a) ? (r: r, g: g, b: b, a: a) : nil
  }

  public var hsba: (h: CGFloat, s: CGFloat, b: CGFloat, a: CGFloat)? {
    var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
    return getHue(&h, saturation: &s, brightness: &b, alpha: &a) ? (h: h, s: s, b: b, a: a) : nil
  }
  public var redValue: CGFloat? { return rgba?.r }
  public var greenValue: CGFloat? { return rgba?.g }
  public var blueValue: CGFloat? { return rgba?.b }

  public var hueValue: CGFloat? { return hsba?.h }
  public var saturationValue: CGFloat? { return hsba?.s }
  public var brightnessValue: CGFloat? { return hsba?.b }

  @nonobjc public var colorName: String? {
    guard let rgbaHex = self.rgbaHex, let namedColor = NamedColor(rawValue: rgbaHex) else { return nil }
    return namedColor.name
  }

  @nonobjc public convenience init?(name: String) {
    guard let namedColor = NamedColor(name: name) else { return nil }
    self.init(rgbaHex: namedColor.rawValue)
  }

  public var perceivedBrightness: CGFloat? {
    var value: CGFloat?
    if let rgba = self.rgba {
      let r = pow(rgba.r * rgba.a, 2)
      let g = pow(rgba.g * rgba.a, 2)
      let b = pow(rgba.b * rgba.a, 2)
      value = sqrt(0.241 * r + 0.691 * g + 0.068 * b)
    }
    return value
  }

  public var whiteValue: CGFloat? { var w: CGFloat = 0, a: CGFloat = 0; return getWhite(&w, alpha: &a) ? w : nil }

  public var alphaValue: CGFloat? { return rgba?.a }

  public var inverted: UIColor? {
    if let rgba = self.rgba {
      return UIColor(red: 1 - rgba.r, green: 1 - rgba.g, blue: 1 - rgba.b, alpha: 1 - rgba.a)
    } else {
      return nil
    }
  }

  public var luminanceMapped: UIColor? {
    if let rgba = self.rgba {
      return UIColor(white: rgba.r * 0.2126 + rgba.g * 0.7152 + rgba.b * 0.0722, alpha: rgba.a)
    } else {
      return nil
    }
  }

  public convenience init(rgbHex: UInt32) {
    let red = CGFloat(rgbHex >> 16 & 0xFF) / 255
    let green = CGFloat(rgbHex >> 8 & 0xFF) / 255
    let blue = CGFloat(rgbHex & 0xFF) / 255
    self.init(red: red, green: green, blue: blue, alpha: 1)
  }

  public convenience init(rgbaHex: UInt32) {
    let red = CGFloat(rgbaHex >> 24 & 0xFF) / 255
    let green = CGFloat(rgbaHex >> 16 & 0xFF) / 255
    let blue = CGFloat(rgbaHex >> 8 & 0xFF) / 255
    let alpha = CGFloat(rgbaHex & 0xFF) / 255
    self.init(red: red, green: green, blue: blue, alpha: alpha)
  }

  public var rgbaHexString: String? {
    if let hex = rgbaHex {
      var hexString = String(hex, radix: 16, uppercase: true)
      while hexString.count < 8 { hexString = "0" + hexString }
      return "#\(hexString)"
    } else {
      return nil
    }
  }

  public var rgbHexString: String? {
    if let hex = rgbHex {
      var hexString = String(hex, radix: 16, uppercase: true)
      while hexString.count < 6 { hexString = "0" + hexString }
      return "#\(hexString)"
    } else {
      return nil
    }
  }

  public var string: String? {
    if let name = colorName {
      let a = alphaValue ?? 1.0
      return a == 1.0 ? name : "\(name)@\(Int(a * 100.0))%"
    } else {
      return rgbaHexString
    }
  }

  public var rgbHexValue: NSNumber? { if let hex = rgbHex { return NSNumber(value: hex) } else { return nil } }
  public var rgbaHexValue: NSNumber? { if let hex = rgbaHex { return NSNumber(value: hex) } else { return nil } }
  public var rgbHex: UInt32? { if let hex = rgbaHex { return hex >> 8 } else { return nil } }
  public var rgbaHex: UInt32? {
    if let rgba = self.rgba {
      let rHex: UInt32 = UInt32(rgba.r * 255.0) << 24
      let gHex: UInt32 = UInt32(rgba.g * 255.0) << 16
      let bHex: UInt32 = UInt32(rgba.b * 255.0) << 8
      let aHex: UInt32 = UInt32(rgba.a * 255.0) << 0
      return rHex | gHex | bHex | aHex
    } else {
      return nil
    }
  }

  /**
  randomColor

  - returns: UIColor
  */
  public class func randomColor() -> UIColor {
    let max = Int(RAND_MAX)
    let red   = CGFloat(max / numericCast(arc4random()))
    let green = CGFloat(max / numericCast(arc4random()))
    let blue  = CGFloat(max / numericCast(arc4random()))
    let alpha = CGFloat(max / numericCast(arc4random()))
    return UIColor(red: red, green: green, blue: blue, alpha: alpha)
  }

  public var colorSpaceModel: CGColorSpaceModel { return cgColor.colorSpace!.model }
  public var isPatternBased: Bool { return colorSpaceModel.rawValue == CGColorSpaceModel.pattern.rawValue }

  public var isRGBCompatible: Bool {
    switch colorSpaceModel.rawValue {
      case CGColorSpaceModel.rgb.rawValue, CGColorSpaceModel.monochrome.rawValue: return true
      default: return false
    }
  }

  public var RGB: (r: CGFloat, g: CGFloat, b: CGFloat) {
    let (r, g, b, _) = RGBA
    return (r: r, g: g, b: b)
  }

  public var RGBA: (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
    var r = CGFloat(), g = CGFloat(), b = CGFloat(), a = CGFloat()
    getRed(&r, green: &g, blue: &b, alpha: &a)
    return (r: r, g: g, b: b, a: a)
  }

  public var HSB: (h: CGFloat, s: CGFloat, b: CGFloat) {
    let (h, s, b, _) = HSBA
    return (h: h, s: s, b: b)
  }

  public var HSBA: (h: CGFloat, s: CGFloat, b: CGFloat, a: CGFloat) {
    var h = CGFloat(), s = CGFloat(), b = CGFloat(), a = CGFloat()
    getHue(&h, saturation: &s, brightness: &b, alpha: &a)
    return (h: h, s: s, b: b, a: a)
  }

  public var sRGB: (r: CGFloat, g: CGFloat, b: CGFloat) {
    let (r, g, b, _) = sRGBA
    return (r: r, g: g, b: b)
  }

  public var sRGBA: (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
    var (r, g, b, a) = RGBA
    (r, g, b) = rgbTosRGB(r, g, b)
    return (r: r, g: g, b: b, a: a)
  }

  public var XYZ: (x: CGFloat, y: CGFloat, z: CGFloat) {
    let (x, y, z, _) = XYZA
    return (x: x, y: y, z: z)
  }

  public var XYZA: (x: CGFloat, y: CGFloat, z: CGFloat, a: CGFloat) {
    let (r, g, b, a) = sRGBA
    let (x, y, z) = sRGBToXYZ(r, g, b)
    return (x: x, y: y, z: z, a: a)
  }

  public var LAB: (l: CGFloat, a: CGFloat, b: CGFloat) {
    let (l, a, b, _) = LABA
    return (l: l, a: a, b: b)
  }

  public var LABA: (l: CGFloat, a: CGFloat, b: CGFloat, alpha: CGFloat) {
    let (x, y, z, alpha) = XYZA
    let (l, a, b) = xyzToLAB(x, y, z)
    return (l: l, a: a, b: b, alpha)
  }

  public var rgbColor: UIColor? {

    switch colorSpaceModel.rawValue {
      case CGColorSpaceModel.rgb.rawValue:
        return self
      default:
        if let rgba = self.rgba {
          return UIColor(red: rgba.r, green: rgba.g, blue: rgba.b, alpha: rgba.a)
        } else {
          return nil
        }
    }
  }

  /**
  lightenedToRed:green:blue:alpha:

  - parameter r: CGFloat
  - parameter g: CGFloat
  - parameter b: CGFloat
  - parameter a: CGFloat

  - returns: UIColor?
  */
  public func lightenedToRed(_ r: CGFloat, green g: CGFloat, blue b: CGFloat, alpha a: CGFloat) -> UIColor? {
    if let rgba = self.rgba {
      return UIColor(red: max(rgba.r, r), green: max(rgba.g, g), blue: max(rgba.b, b), alpha: max(rgba.a, a))
    } else {
      return nil
    }
  }

  /**
  lightenedTo:

  - parameter value: CGFloat

  - returns: UIColor?
  */
  @objc(lightenedToValue:)
  public func lightened(to value: CGFloat) -> UIColor? { return lightenedToRed(value, green: value, blue: value, alpha: value) }

  /**
  lightenedToColor:

  - parameter color: UIColor

  - returns: UIColor?
  */
  @objc(lightenedToColor:)
  public func lightened(to color: UIColor) -> UIColor? {
    if let rgba = color.rgba {
      return lightenedToRed(rgba.r, green: rgba.g, blue: rgba.b, alpha: rgba.a)
    } else {
      return nil
    }
  }

  /**
  darkenedToRed:green:blue:alpha:

  - parameter r: CGFloat
  - parameter g: CGFloat
  - parameter b: CGFloat
  - parameter a: CGFloat

  - returns: UIColor?
  */
  public func darkenedToRed(_ r: CGFloat, green g: CGFloat, blue b: CGFloat, alpha a: CGFloat) -> UIColor? {
    if let rgba = self.rgba {
      return UIColor(red: min(rgba.r, r), green: min(rgba.g, g), blue: min(rgba.b, b), alpha: min(rgba.a, a))
    } else {
      return nil
    }
  }

  /**
  darkenedTo:

  - parameter value: CGFloat

  - returns: UIColor?
  */
  @objc(darkenedToValue:)
  public func darkened(to value: CGFloat) -> UIColor? { return darkenedToRed(value, green: value, blue: value, alpha: value) }

  /**
  brightnessAdjustedBy:

  - parameter value: CGFloat

  - returns: UIColor
  */
  public func brightnessAdjustedBy(_ value: CGFloat) -> UIColor {
    let laba = LABA
    let rgb = labToRGB(laba.l + value, laba.a, laba.b)
    return UIColor(red: rgb.r, green: rgb.g, blue: rgb.b, alpha: laba.alpha)
  }

  /**
  darkenedToColor:

  - parameter color: UIColor

  - returns: UIColor?
  */
  @objc(darkenedToColor:)
  public func darkened(to color: UIColor) -> UIColor? {
    if let rgba = color.rgba {
      return darkenedToRed(rgba.r, green: rgba.g, blue: rgba.b, alpha: rgba.a)
    } else {
      return nil
    }
  }

  /**
  addedWithRed:green:blue:alpha:

  - parameter r: CGFloat
  - parameter g: CGFloat
  - parameter b: CGFloat
  - parameter a: CGFloat

  - returns: UIColor?
  */
  public func addedWithRed(_ r: CGFloat, green g: CGFloat, blue b: CGFloat, alpha a: CGFloat) -> UIColor? {
    if let rgba = self.rgba {
      let red = max(0.0, min(1.0, rgba.r + r))
      let green = max(0.0, min(1.0, rgba.g + g))
      let blue = max(0.0, min(1.0, rgba.b + b))
      let alpha = max(0.0, min(1.0, rgba.a + a))
      return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    } else {
      return nil
    }
  }

  /**
  addedWith:

  - parameter value: CGFloat

  - returns: UIColor?
  */
  @objc(addedWithValue:)
  public func added(with value: CGFloat) -> UIColor? { return addedWithRed(value, green: value, blue: value, alpha: value) }

  /**
  addedWithColor:

  - parameter color: UIColor

  - returns: UIColor?
  */
  @objc(addedWithColor:)
  public func added(with color: UIColor) -> UIColor? {
    if let rgba = color.rgba {
      return addedWithRed(rgba.r, green: rgba.g, blue: rgba.b, alpha: rgba.a)
    } else {
      return nil
    }
  }

  /**
  multipliedBy:

  - parameter value: CGFloat

  - returns: UIColor
  */
  public func multiplied(by value: CGFloat) -> UIColor? {
    return multipliedByRed(value, green: value, blue: value, alpha: value)
  }

  /**
  multipliedByRed:green:blue:alpha:

  - parameter r: CGFloat
  - parameter g: CGFloat
  - parameter b: CGFloat
  - parameter a: CGFloat

  - returns: UIColor?
  */
  public func multipliedByRed(_ r: CGFloat, green g: CGFloat, blue b: CGFloat, alpha a: CGFloat) -> UIColor? {
    if let rgba = self.rgba {
      let red = max(0.0, min(1.0, rgba.r * r))
      let green = max(0.0, min(1.0, rgba.g * g))
      let blue = max(0.0, min(1.0, rgba.b * b))
      let alpha = max(0.0, min(1.0, rgba.a * a))
      return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    } else {
      return nil
    }
  }

  /**
  multipliedByColor:

  - parameter color: UIColor

  - returns: UIColor?
  */
  public func multiplie(by color: UIColor) -> UIColor? {
    if let rgba = color.rgba {
      return multipliedByRed(rgba.r, green: rgba.g, blue: rgba.b, alpha: rgba.a)
    } else {
      return nil
    }
  }

  /**
  colorWithRed:

  - parameter red: CGFloat

  - returns: UIColor
  */
  public func withRed(_ red: CGFloat) -> UIColor {
    if let rgba = self.rgba { return UIColor(red: red, green: rgba.g, blue: rgba.b, alpha: rgba.a) }
    else { return UIColor(red: red, green: 1, blue: 1, alpha: 1) }
  }

  /**
  colorWithGreen:

  - parameter green: CGFloat

  - returns: UIColor
  */
  public func withGreen(_ green: CGFloat) -> UIColor {
    if let rgba = self.rgba { return UIColor(red: rgba.r, green: green, blue: rgba.b, alpha: rgba.a) }
    else { return UIColor(red: 1, green: green, blue: 1, alpha: 1) }
  }

  /**
  colorWithBlue:

  - parameter blue: CGFloat

  - returns: UIColor
  */
  public func withBlue(_ blue: CGFloat) -> UIColor {
    if let rgba = self.rgba { return UIColor(red: rgba.r, green: rgba.g, blue: blue, alpha: rgba.a) }
    else { return UIColor(red: 1, green: 1, blue: blue, alpha: 1) }
  }

  /**
  colorWithHue:

  - parameter hue: CGFloat

  - returns: UIColor
  */
   public func withHue(_ hue: CGFloat) -> UIColor {
     if let hsba = self.hsba { return UIColor(hue: hue, saturation: hsba.s, brightness: hsba.b, alpha: hsba.a) }
     else { return UIColor(hue: hue, saturation: 1, brightness: 1, alpha: 1) }
   }

  /**
  colorWithSaturation:

  - parameter saturation: CGFloat

  - returns: UIColor
  */
   public func withSaturation(_ saturation: CGFloat) -> UIColor {
     if let hsba = self.hsba { return UIColor(hue: hsba.h, saturation: saturation, brightness: hsba.b, alpha: hsba.a) }
     else { return UIColor(hue: 1, saturation: saturation, brightness: 1, alpha: 1) }
   }

  /**
  colorWithBrightness:

  - parameter brightness: CGFloat

  - returns: UIColor
  */
   public func withBrightness(_ brightness: CGFloat) -> UIColor {
     if let hsba = self.hsba { return UIColor(hue: hsba.h, saturation: hsba.s, brightness: brightness, alpha: hsba.a) }
     else { return UIColor(hue: 1, saturation: 1, brightness: brightness, alpha: 1) }
   }

  /**
  colorWithAlpha:

  - parameter alpha: CGFloat

  - returns: UIColor
  */
//  public func colorWithAlpha(_ alpha: CGFloat) -> UIColor { return withAlphaComponent(alpha) }

  public func withHighlight(_ highlight: CGFloat) -> UIColor {
    if let rgba = self.rgba {
      return UIColor(red:   rgba.r * (1 - highlight) + highlight,
                     green: rgba.g * (1 - highlight) + highlight,
                     blue:  rgba.b * (1 - highlight) + highlight,
                     alpha: rgba.a * (1 - highlight) + highlight)
    } else {
      return self
    }
  }
  public func withShadow(_ shadow: CGFloat) -> UIColor {
    if let rgba = self.rgba {
      return UIColor(red:   rgba.r * (1 - shadow),
                     green: rgba.g * (1 - shadow),
                     blue:  rgba.b * (1 - shadow),
                     alpha: rgba.a * (1 - shadow) + shadow)
    } else {
      return self
    }
  }

  public func blended(with color: UIColor, factor: CGFloat) -> UIColor {
    var r1: CGFloat = 1.0, g1: CGFloat = 1.0, b1: CGFloat = 1.0, a1: CGFloat = 1.0
    var r2: CGFloat = 1.0, g2: CGFloat = 1.0, b2: CGFloat = 1.0, a2: CGFloat = 1.0

    self.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
    color.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)

    return UIColor(red: r1 * (1 - factor) + r2 * factor,
                   green: g1 * (1 - factor) + g2 * factor,
                   blue: b1 * (1 - factor) + b2 * factor,
                   alpha: a1 * (1 - factor) + a2 * factor)
  }

  public enum NamedColor: UInt32 {
    case clear                = 0x00000000
    case black                = 0x000000FF
    case systemOrange         = 0xFF8000FF
    case lightText            = 0xFFFFFF9A
    case brown                = 0x9A6633FF
    case flipside             = 0x1F2124FF
    case groupTable           = 0xEFEFF4FF
    case aliceBlue            = 0xF0F8FFFF
    case antiqueWhite         = 0xFAEBD7FF
    case aquamarine           = 0x7FFFD4FF
    case azure                = 0xF0FFFFFF
    case beige                = 0xF5F5DCFF
    case bisque               = 0xFFE4C4FF
    case blanchedAlmond       = 0xFFEBCDFF
    case blue                 = 0x0000FFFF
    case blueViolet           = 0x8A2BE2FF
    case burlyWood            = 0xDEB887FF
    case cadetBlue            = 0x5F9EA0FF
    case chartreuse           = 0x7FFF00FF
    case chocolate            = 0xD2691EFF
    case coral                = 0xFF7F50FF
    case cornflowerBlue       = 0x6495EDFF
    case cornsilk             = 0xFFF8DCFF
    case crimson              = 0xDC143CFF
    case cyan                 = 0x00FFFFFF
    case darkBlue             = 0x00008BFF
    case darkCyan             = 0x008B8BFF
    case darkGoldenRod        = 0xB8860BFF
    case darkGray             = 0xA9A9A9FF
    case darkGreen            = 0x006400FF
    case darkKhaki            = 0xBDB76BFF
    case darkMagenta          = 0x8B008BFF
    case darkOlivegreen       = 0x556B2FFF
    case darkOrange           = 0xFF8C00FF
    case darkOrchid           = 0x9932CCFF
    case darkRed              = 0x8B0000FF
    case darkSalmon           = 0xE9967AFF
    case darkSeaGreen         = 0x8FBC8FFF
    case darkSlateBlue        = 0x483D8BFF
    case darkSlateGray        = 0x2F4F4FFF
    case darkTurquoise        = 0x00CED1FF
    case darkViolet           = 0x9400D3FF
    case deepPink             = 0xFF1493FF
    case deepSkyBlue          = 0x00BFFFFF
    case dimGray              = 0x696969FF
    case dodgerBlue           = 0x1E90FFFF
    case fireBrick            = 0xB22222FF
    case floralWhite          = 0xFFFAF0FF
    case forestGreen          = 0x228B22FF
    case fuchsia              = 0xFF00FFFF
    case gainsboro            = 0xDCDCDCFF
    case ghostWhite           = 0xF8F8FFFF
    case gold                 = 0xFFD700FF
    case goldenRod            = 0xDAA520FF
    case gray                 = 0x808080FF
    case green                = 0x008000FF
    case greenYellow          = 0xADFF2FFF
    case honeyDew             = 0xF0FFF0FF
    case hotPink              = 0xFF69B4FF
    case indianRed            = 0xCD5C5CFF
    case indigo               = 0x4B0082FF
    case ivory                = 0xFFFFF0FF
    case khaki                = 0xF0E68CFF
    case lavender             = 0xE6E6FAFF
    case lavenderBlush        = 0xFFF0F5FF
    case lawnGreen            = 0x7CFC00FF
    case lemonChiffon         = 0xFFFACDFF
    case lightBlue            = 0xADD8E6FF
    case lightCoral           = 0xF08080FF
    case lightCyan            = 0xE0FFFFFF
    case lightGoldenRodYellow = 0xFAFAD2FF
    case lightGray            = 0xD3D3D3FF
    case lightGreen           = 0x90EE90FF
    case lightPink            = 0xFFB6C1FF
    case lightSalmon          = 0xFFA07AFF
    case lightSeaGreen        = 0x20B2AAFF
    case lightSkyBlue         = 0x87CEFAFF
    case lightSlateGray       = 0x778899FF
    case lightSteelBlue       = 0xB0C4DEFF
    case lightYellow          = 0xFFFFE0FF
    case lime                 = 0x00FF00FF
    case limeGreen            = 0x32CD32FF
    case linen                = 0xFAF0E6FF
    case maroon               = 0x800000FF
    case mediumAquamarine     = 0x66CDAAFF
    case mediumBlue           = 0x0000CDFF
    case mediumOrchid         = 0xBA55D3FF
    case mediumPurple         = 0x9370DBFF
    case mediumSeaGreen       = 0x3CB371FF
    case mediumSlateBlue      = 0x7B68EEFF
    case mediumSpringGreen    = 0x00FA9AFF
    case mediumTurquoise      = 0x48D1CCFF
    case mediumVioletRed      = 0xC71585FF
    case midnightBlue         = 0x191970FF
    case mintCream            = 0xF5FFFAFF
    case mistyRose            = 0xFFE4E1FF
    case moccasin             = 0xFFE4B5FF
    case navajoWhite          = 0xFFDEADFF
    case navy                 = 0x000080FF
    case oldLace              = 0xFDF5E6FF
    case olive                = 0x808000FF
    case oliveDrab            = 0x6B8E23FF
    case orange               = 0xFFA500FF
    case orangeRed            = 0xFF4500FF
    case orchid               = 0xDA70D6FF
    case paleGoldenRod        = 0xEEE8AAFF
    case paleGreen            = 0x98FB98FF
    case paleTurquoise        = 0xAFEEEEFF
    case paleVioletRed        = 0xDB7093FF
    case papayaWhip           = 0xFFEFD5FF
    case peachPuff            = 0xFFDAB9FF
    case peru                 = 0xCD853FFF
    case pink                 = 0xFFC0CBFF
    case plum                 = 0xDDA0DDFF
    case powderBlue           = 0xB0E0E6FF
    case purple               = 0x800080FF
    case red                  = 0xFF0000FF
    case rosyBrown            = 0xBC8F8FFF
    case royalBlue            = 0x4169E1FF
    case saddleBrown          = 0x8B4513FF
    case salmon               = 0xFA8072FF
    case sandyBrown           = 0xF4A460FF
    case seaGreen             = 0x2E8B57FF
    case seaShell             = 0xFFF5EEFF
    case sienna               = 0xA0522DFF
    case silver               = 0xC0C0C0FF
    case skyBlue              = 0x87CEEBFF
    case slateBlue            = 0x6A5ACDFF
    case slateGray            = 0x708090FF
    case snow                 = 0xFFFAFAFF
    case springGreen          = 0x00FF7FFF
    case steelBlue            = 0x4682B4FF
    case tan                  = 0xD2B48CFF
    case teal                 = 0x008080FF
    case thistle              = 0xD8BFD8FF
    case tomato               = 0xFF6347FF
    case turquoise            = 0x40E0D0FF
    case violet               = 0xEE82EEFF
    case wheat                = 0xF5DEB3FF
    case white                = 0xFFFFFFFF
    case whiteSmoke           = 0xF5F5F5FF
    case yellow               = 0xFFFF00FF
    case yellowGreen          = 0x9ACD32FF

    var name: String { var result = ""; print(self, to: &result); return result }

    init?(name: String) {
      switch name {
        case "clear":                self = .clear
        case "black":                self = .black
        case "systemOrange":         self = .systemOrange
        case "lightText":            self = .lightText
        case "brown":                self = .brown
        case "flipside":             self = .flipside
        case "groupTable":           self = .groupTable
        case "aliceBlue":            self = .aliceBlue
        case "antiqueWhite":         self = .antiqueWhite
        case "aquamarine":           self = .aquamarine
        case "azure":                self = .azure
        case "beige":                self = .beige
        case "bisque":               self = .bisque
        case "blanchedAlmond":       self = .blanchedAlmond
        case "blue":                 self = .blue
        case "blueViolet":           self = .blueViolet
        case "burlyWood":            self = .burlyWood
        case "cadetBlue":            self = .cadetBlue
        case "chartreuse":           self = .chartreuse
        case "chocolate":            self = .chocolate
        case "coral":                self = .coral
        case "cornflowerBlue":       self = .cornflowerBlue
        case "cornsilk":             self = .cornsilk
        case "crimson":              self = .crimson
        case "cyan":                 self = .cyan
        case "darkBlue":             self = .darkBlue
        case "darkCyan":             self = .darkCyan
        case "darkGoldenRod":        self = .darkGoldenRod
        case "darkGray":             self = .darkGray
        case "darkGreen":            self = .darkGreen
        case "darkKhaki":            self = .darkKhaki
        case "darkMagenta":          self = .darkMagenta
        case "darkOlivegreen":       self = .darkOlivegreen
        case "darkOrange":           self = .darkOrange
        case "darkOrchid":           self = .darkOrchid
        case "darkRed":              self = .darkRed
        case "darkSalmon":           self = .darkSalmon
        case "darkSeaGreen":         self = .darkSeaGreen
        case "darkSlateBlue":        self = .darkSlateBlue
        case "darkSlateGray":        self = .darkSlateGray
        case "darkTurquoise":        self = .darkTurquoise
        case "darkViolet":           self = .darkViolet
        case "deepPink":             self = .deepPink
        case "deepSkyBlue":          self = .deepSkyBlue
        case "dimGray":              self = .dimGray
        case "dodgerBlue":           self = .dodgerBlue
        case "fireBrick":            self = .fireBrick
        case "floralWhite":          self = .floralWhite
        case "forestGreen":          self = .forestGreen
        case "fuchsia":              self = .fuchsia
        case "gainsboro":            self = .gainsboro
        case "ghostWhite":           self = .ghostWhite
        case "gold":                 self = .gold
        case "goldenRod":            self = .goldenRod
        case "gray":                 self = .gray
        case "green":                self = .green
        case "greenYellow":          self = .greenYellow
        case "honeyDew":             self = .honeyDew
        case "hotPink":              self = .hotPink
        case "indianRed":            self = .indianRed
        case "indigo":               self = .indigo
        case "ivory":                self = .ivory
        case "khaki":                self = .khaki
        case "lavender":             self = .lavender
        case "lavenderBlush":        self = .lavenderBlush
        case "lawnGreen":            self = .lawnGreen
        case "lemonChiffon":         self = .lemonChiffon
        case "lightBlue":            self = .lightBlue
        case "lightCoral":           self = .lightCoral
        case "lightCyan":            self = .lightCyan
        case "lightGoldenRodYellow": self = .lightGoldenRodYellow
        case "lightGray":            self = .lightGray
        case "lightGreen":           self = .lightGreen
        case "lightPink":            self = .lightPink
        case "lightSalmon":          self = .lightSalmon
        case "lightSeaGreen":        self = .lightSeaGreen
        case "lightSkyBlue":         self = .lightSkyBlue
        case "lightSlateGray":       self = .lightSlateGray
        case "lightSteelBlue":       self = .lightSteelBlue
        case "lightYellow":          self = .lightYellow
        case "lime":                 self = .lime
        case "limeGreen":            self = .limeGreen
        case "linen":                self = .linen
        case "maroon":               self = .maroon
        case "mediumAquamarine":     self = .mediumAquamarine
        case "mediumBlue":           self = .mediumBlue
        case "mediumOrchid":         self = .mediumOrchid
        case "mediumPurple":         self = .mediumPurple
        case "mediumSeaGreen":       self = .mediumSeaGreen
        case "mediumSlateBlue":      self = .mediumSlateBlue
        case "mediumSpringGreen":    self = .mediumSpringGreen
        case "mediumTurquoise":      self = .mediumTurquoise
        case "mediumVioletRed":      self = .mediumVioletRed
        case "midnightBlue":         self = .midnightBlue
        case "mintCream":            self = .mintCream
        case "mistyRose":            self = .mistyRose
        case "moccasin":             self = .moccasin
        case "navajoWhite":          self = .navajoWhite
        case "navy":                 self = .navy
        case "oldLace":              self = .oldLace
        case "olive":                self = .olive
        case "oliveDrab":            self = .oliveDrab
        case "orange":               self = .orange
        case "orangeRed":            self = .orangeRed
        case "orchid":               self = .orchid
        case "paleGoldenRod":        self = .paleGoldenRod
        case "paleGreen":            self = .paleGreen
        case "paleTurquoise":        self = .paleTurquoise
        case "paleVioletRed":        self = .paleVioletRed
        case "papayaWhip":           self = .papayaWhip
        case "peachPuff":            self = .peachPuff
        case "peru":                 self = .peru
        case "pink":                 self = .pink
        case "plum":                 self = .plum
        case "powderBlue":           self = .powderBlue
        case "purple":               self = .purple
        case "red":                  self = .red
        case "rosyBrown":            self = .rosyBrown
        case "royalBlue":            self = .royalBlue
        case "saddleBrown":          self = .saddleBrown
        case "salmon":               self = .salmon
        case "sandyBrown":           self = .sandyBrown
        case "seaGreen":             self = .seaGreen
        case "seaShell":             self = .seaShell
        case "sienna":               self = .sienna
        case "silver":               self = .silver
        case "skyBlue":              self = .skyBlue
        case "slateBlue":            self = .slateBlue
        case "slateGray":            self = .slateGray
        case "snow":                 self = .snow
        case "springGreen":          self = .springGreen
        case "steelBlue":            self = .steelBlue
        case "tan":                  self = .tan
        case "teal":                 self = .teal
        case "thistle":              self = .thistle
        case "tomato":               self = .tomato
        case "turquoise":            self = .turquoise
        case "violet":               self = .violet
        case "wheat":                self = .wheat
        case "white":                self = .white
        case "whiteSmoke":           self = .whiteSmoke
        case "yellow":               self = .yellow
        case "yellowGreen":          self = .yellowGreen
        
        case "system-orange":           self = .systemOrange
        case "light-text":              self = .lightText
        case "group-table":             self = .groupTable
        case "alice-blue":              self = .aliceBlue
        case "antique-white":           self = .antiqueWhite
        case "blanched-almond":         self = .blanchedAlmond
        case "blue-violet":             self = .blueViolet
        case "burly-wood":              self = .burlyWood
        case "cadet-blue":              self = .cadetBlue
        case "cornflower-blue":         self = .cornflowerBlue
        case "dark-blue":               self = .darkBlue
        case "dark-cyan":               self = .darkCyan
        case "dark-golden-rod":         self = .darkGoldenRod
        case "dark-gray":               self = .darkGray
        case "dark-green":              self = .darkGreen
        case "dark-khaki":              self = .darkKhaki
        case "dark-magenta":            self = .darkMagenta
        case "dark-olivegreen":         self = .darkOlivegreen
        case "dark-orange":             self = .darkOrange
        case "dark-orchid":             self = .darkOrchid
        case "dark-red":                self = .darkRed
        case "dark-salmon":             self = .darkSalmon
        case "dark-sea-green":          self = .darkSeaGreen
        case "dark-slate-blue":         self = .darkSlateBlue
        case "dark-slate-gray":         self = .darkSlateGray
        case "dark-turquoise":          self = .darkTurquoise
        case "dark-violet":             self = .darkViolet
        case "deep-pink":               self = .deepPink
        case "deep-sky-blue":           self = .deepSkyBlue
        case "dim-gray":                self = .dimGray
        case "dodger-blue":             self = .dodgerBlue
        case "fire-brick":              self = .fireBrick
        case "floral-white":            self = .floralWhite
        case "forest-green":            self = .forestGreen
        case "ghost-white":             self = .ghostWhite
        case "golden-rod":              self = .goldenRod
        case "green-yellow":            self = .greenYellow
        case "honey-dew":               self = .honeyDew
        case "hot-pink":                self = .hotPink
        case "indian-red":              self = .indianRed
        case "lavender-blush":          self = .lavenderBlush
        case "lawn-green":              self = .lawnGreen
        case "lemon-chiffon":           self = .lemonChiffon
        case "light-blue":              self = .lightBlue
        case "light-coral":             self = .lightCoral
        case "light-cyan":              self = .lightCyan
        case "light-golden-rod-yellow": self = .lightGoldenRodYellow
        case "light-gray":              self = .lightGray
        case "light-green":             self = .lightGreen
        case "light-pink":              self = .lightPink
        case "light-salmon":            self = .lightSalmon
        case "light-sea-green":         self = .lightSeaGreen
        case "light-sky-blue":          self = .lightSkyBlue
        case "light-slate-gray":        self = .lightSlateGray
        case "light-steel-blue":        self = .lightSteelBlue
        case "light-yellow":            self = .lightYellow
        case "lime-green":              self = .limeGreen
        case "medium-aquamarine":       self = .mediumAquamarine
        case "medium-blue":             self = .mediumBlue
        case "medium-orchid":           self = .mediumOrchid
        case "medium-purple":           self = .mediumPurple
        case "medium-sea-green":        self = .mediumSeaGreen
        case "medium-slate-blue":       self = .mediumSlateBlue
        case "medium-spring-green":     self = .mediumSpringGreen
        case "medium-turquoise":        self = .mediumTurquoise
        case "medium-violet-red":       self = .mediumVioletRed
        case "midnight-blue":           self = .midnightBlue
        case "mint-cream":              self = .mintCream
        case "misty-rose":              self = .mistyRose
        case "navajo-white":            self = .navajoWhite
        case "old-lace":                self = .oldLace
        case "olive-drab":              self = .oliveDrab
        case "orange-red":              self = .orangeRed
        case "pale-golden-rod":         self = .paleGoldenRod
        case "pale-green":              self = .paleGreen
        case "pale-turquoise":          self = .paleTurquoise
        case "pale-violet-red":         self = .paleVioletRed
        case "papaya-whip":             self = .papayaWhip
        case "peach-puff":              self = .peachPuff
        case "powder-blue":             self = .powderBlue
        case "rosy-brown":              self = .rosyBrown
        case "royal-blue":              self = .royalBlue
        case "saddle-brown":            self = .saddleBrown
        case "sandy-brown":             self = .sandyBrown
        case "sea-green":               self = .seaGreen
        case "sea-shell":               self = .seaShell
        case "sky-blue":                self = .skyBlue
        case "slate-blue":              self = .slateBlue
        case "slate-gray":              self = .slateGray
        case "spring-green":            self = .springGreen
        case "steel-blue":              self = .steelBlue
        case "white-smoke":             self = .whiteSmoke
        case "yellow-green":            self = .yellowGreen
        default:                     return nil
      }
    }
  }

}

public func rgba(_ r: Int, _ g: Int, _ b: Int, _ a: Int) -> UIColor {
  return UIColor(red: CGFloat(r)/255, green: CGFloat(g)/255, blue: CGFloat(b)/255, alpha: CGFloat(a)/255)
}

public func rgb(_ r: Int, _ g: Int, _ b: Int) -> UIColor {
  return UIColor(red: CGFloat(r)/255, green: CGFloat(g)/255, blue: CGFloat(b)/255, alpha: 1)
}

public func hsba(_ h: Int, _ s: Int, _ b: Int, _ a: Int) -> UIColor {
  return UIColor(hue: CGFloat(h)/360, saturation: CGFloat(s)/100, brightness: CGFloat(b)/100, alpha: CGFloat(a)/100)
}

public func hsb(_ h: Int, _ s: Int, _ b: Int) -> UIColor {
  return UIColor(hue: CGFloat(h)/360, saturation: CGFloat(s)/100, brightness: CGFloat(b)/100, alpha: 1)
}

public func hsbToRGB(_ h: Int, _ s: Int, _ b: Int) -> (r: Int, g: Int, b: Int) {

  let s = CGFloat(s) / 100
  let b = CGFloat(b) / 100
  let c = s * b
  let hPrime = CGFloat(h) / 60
  let x = c * (1 - abs(fmod(hPrime, 2) - 1))

  let (r1, g1, b1): (CGFloat, CGFloat, CGFloat)
  switch hPrime {
  case 0 ..< 1: (r1, g1, b1) = (c, x, 0)
  case 1 ..< 2: (r1, g1, b1) = (x, c, 0)
  case 2 ..< 3: (r1, g1, b1) = (0, c, x)
  case 3 ..< 4: (r1, g1, b1) = (0, x, c)
  case 4 ..< 5: (r1, g1, b1) = (x, 0, c)
  case 5 ..< 6: (r1, g1, b1) = (c, 0, x)
  default:      (r1, g1, b1) = (0, 0, 0)
  }

  let m = b - c
  return (r: Int((r1 + m) * 255), g: Int((g1 + m) * 255), b: Int((b1 + m) * 255))
}

public func rgbToHSB(_ r: Int, _ g: Int, _ b: Int) -> (h: Int, s: Int, b: Int) {
  let r = CGFloat(r) / 255, g = CGFloat(g) / 255, b = CGFloat(b) / 255
  let M = max(r, g, b)
  let m = min(r, g, b)
  let c = M - m
  let hPrime: CGFloat
  switch (c, M) {
  case (0, _): hPrime = 0
  case (_, r): hPrime = fmod((g - b) / c, 6)
  case (_, g): hPrime = (b - r) / c + 2
  case (_, b): hPrime = (r - g) / c + 4
  default:     hPrime = 0
  }
  let h = Int(60 * hPrime)
  let v = Int(M * 100)
  let s = Int(v == 0 ? 0 : c / M * 100)
  return (h: h, s: s, b: v)
}

public func rgbTosRGB(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) -> (r: CGFloat, g: CGFloat, b: CGFloat) {
  func convert(_ c: CGFloat) -> CGFloat { return c > 0.04045 ? pow((c + 0.055) / 1.055, 2.4) : c / 12.92 }
  return (r: convert(r), g: convert(g), b: convert(b))
}

public func sRGBToXYZ(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) -> (x: CGFloat, y: CGFloat, z: CGFloat) {
  let x = (r * 0.4124 + g * 0.3576 + b * 0.1805) * 100.0
  let y = (r * 0.2126 + g * 0.7152 + b * 0.0722) * 100.0
  let z = (r * 0.0193 + g * 0.1192 + b * 0.9505) * 100.0
  return (x: x, y: y, z: z)
}

public func rgbToXYZ(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) -> (x: CGFloat, y: CGFloat, z: CGFloat) {
  let (r, g, b) = rgbTosRGB(r, g, b)
  return sRGBToXYZ(r, g, b)
}

public func rgbToLAB(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) -> (l: CGFloat, a: CGFloat, b: CGFloat) {
  let (x, y, z) = rgbToXYZ(r, g, b)
  return xyzToLAB(x, y, z)
}

public func xyzToLAB( _ x: CGFloat, _ y: CGFloat, _ z: CGFloat) -> (l: CGFloat, a: CGFloat, b: CGFloat) {
  // The corresponding original XYZ values are such that white is D65 with unit luminance (X,Y,Z = 0.9505, 1.0000, 1.0890).
  // Calculations are also to assume the 2° standard colorimetric observer.
  // D65: http://en.wikipedia.org/wiki/CIE_Standard_Illuminant_D65
  // Standard Colorimetric Observer: http://en.wikipedia.org/wiki/Standard_colorimetric_observer#CIE_standard_observer
  // Since we mutiplied our XYZ values by 100 to produce a percentage we should also multiply our unit luminance values
  // by 100.
  var x = x / 95.05, y = y / 100.0, z = z / 108.9

  // Use the forward transformation function for CIELAB-CIEXYZ conversions
  // Function: http://upload.wikimedia.org/math/e/5/1/e513d25d50d406bfffb6ed3c854bd8a4.png
  // 0.0088564517 = pow(6.0 / 29.0, 3.0)
  // 7.787037037 = 1.0 / 3.0 * pow(29.0 / 6.0, 2.0)
  // 0.1379310345 = 4.0 / 29.0
  func convert(_ f: CGFloat) -> CGFloat { return f > 0.0088564517 ? pow(f, 1.0 / 3.0) : 7.787037037 * f + 0.1379310345 }
  (x, y, z) = (convert(x), convert(y), convert(z))
  return (l: 116.0 * y - 16.0, a: 500.0 * (x - y), b: 200.0 * (y - z))
}

public func labToXYZ(_ l: CGFloat, _ a: CGFloat, _ b: CGFloat) -> (x: CGFloat, y: CGFloat, z: CGFloat) {
  var y1 = (l + 16)/116
  var x1 = a/500 + y1
  var z1 = -b/200 + y1
  func convert(_ f: CGFloat) -> CGFloat { return f > 0.206893 ? pow(f, 3) : (f - 16/116)/7.787 }
  x1 = convert(x1); y1 = convert(y1); z1 = convert(z1)
  return (x: x1 * 95.05, y: y1 * 100, z: z1 * 108.9)
}

public func xyzTosRGB(_ x: CGFloat, _ y: CGFloat, _ z: CGFloat) -> (r: CGFloat, g: CGFloat, b: CGFloat) {
  let r = (3.2406 * x - 1.5372 * y - 0.4986 * z)/100
  let g = (-0.9689 * x + 1.8758 * y + 0.0415 * z)/100
  let b = (0.0557 * x - 0.204 * y + 1.057 * z) / 100
  return (r: r, g: g, b: b)
}

public func sRGBToRGB(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) -> (r: CGFloat, g: CGFloat, b: CGFloat) {
  func convert(_ f: CGFloat) -> CGFloat { return f > 0.0031308 ? 1.055 * pow(f, 1/2.4) - 0.055 : 12.92 * f }
  return (r: convert(r), g: convert(g), b: convert(b))
}

public func xyzToRGB(_ x: CGFloat, _ y: CGFloat, _ z: CGFloat) -> (r: CGFloat, g: CGFloat, b: CGFloat) {
  let (r, g, b) = xyzTosRGB(x, y, z)
  return sRGBToRGB(r, g, b)
}

public func labToRGB(_ l: CGFloat, _ a: CGFloat, _ b: CGFloat) -> (r: CGFloat, g: CGFloat, b: CGFloat) {
  let (x, y, z) = labToXYZ(l, a, b)
  return xyzToRGB(x, y, z)
}

public func hexStringFromRGB(_ r: Int, _ g: Int, _ b: Int) -> String {
  assert((0...255).contains(r) && (0...255).contains(g) && (0...255).contains(b), "rgb values expected to be in the range 0...255")
  let hex = (r << 16) | (g << 8) | b
  var string = String(hex, radix: 16, uppercase: false)
  while string.count < 6 { string.insert(Character("0"), at: string.startIndex) }
  string.insert(Character("#"), at: string.startIndex)
  return string
}

public func hexStringFromHSB(_ h: Int, _ s: Int, _ b: Int) -> String {
  let (r, g, b) = hsbToRGB(h, s, b)
  return hexStringFromRGB(r, g, b)
}
