//
//  FontStyle.swift
//  MoonKit
//
//  Created by Jason Cardwell on 8/30/17.
//  Copyright (c) 2017 Moondeer Studios. All rights reserved.
//
import Foundation
import CoreText

#if os(iOS)
import class UIKit.UIColor
import class UIKit.UIFont
import class UIKit.NSParagraphStyle
import class UIKit.NSMutableParagraphStyle
#else
import class AppKit.NSColor
import class AppKit.NSFont
import class AppKit.NSParagraphStyle
import class AppKit.NSMutableParagraphStyle
#endif

private func ctHalfLineParagraphStyle() -> CTParagraphStyle {

  // Calculate the line spacing.
  var lineSpacing: CGFloat = -2.6

  // Create the paragraph style settings.
  var setting = CTParagraphStyleSetting(spec: .lineSpacingAdjustment,
                                        valueSize: MemoryLayout<CGFloat>.size,
                                        value: &lineSpacing)

  // Create the paragraph style.
  let paragraphStyle = CTParagraphStyleCreate(&setting, 1);

  return paragraphStyle

}

private func ctParagraphStyle() -> CTParagraphStyle {

  // Calculate the line spacing.
  var lineSpacing: CGFloat = -1.6

  // Create the paragraph style settings.
  var setting = CTParagraphStyleSetting(spec: .lineSpacingAdjustment,
                                        valueSize: MemoryLayout<CGFloat>.size,
                                        value: &lineSpacing)

  // Create the paragraph style.
  let paragraphStyle = CTParagraphStyleCreate(&setting, 1);

  return paragraphStyle

}

private func ctCenteredParagraphStyle() -> CTParagraphStyle {

  // Calculate the line spacing.
  var lineSpacing: CGFloat = -1.6

  // Create the paragraph style settings.
  let lineSpacingSetting = CTParagraphStyleSetting(spec: .lineSpacingAdjustment,
                                                   valueSize: MemoryLayout<CGFloat>.size,
                                                   value: &lineSpacing)

  var alignment: CTTextAlignment = .center
  let alignmentSetting = CTParagraphStyleSetting(spec: .alignment,
                                                 valueSize: MemoryLayout<CTTextAlignment>.size,
                                                 value: &alignment)

  let settings = [lineSpacingSetting, alignmentSetting]

  // Create the paragraph style.
  let paragraphStyle = CTParagraphStyleCreate(settings, 2);

  return paragraphStyle

}

private func nsHalfLineParagraphStyle() -> NSParagraphStyle {

  // Create the paragraph style.
  let paragraphStyle = NSMutableParagraphStyle()

  // Adjust the line spacing.
  paragraphStyle.lineSpacing = -2.6

  return paragraphStyle as NSParagraphStyle

}

private func nsParagraphStyle() -> NSParagraphStyle {

  // Create the paragraph style.
  let paragraphStyle = NSMutableParagraphStyle()

  // Adjust the line spacing.
  paragraphStyle.lineSpacing = -1.6

  return paragraphStyle as NSParagraphStyle

}

private func nsCenteredParagraphStyle() -> NSParagraphStyle {

  // Create the paragraph style.
  let paragraphStyle = NSMutableParagraphStyle()

  // Adjust the line spacing.
  paragraphStyle.lineSpacing = -2.6

  // Adjust the alignment.
  paragraphStyle.alignment = .center

  return paragraphStyle as NSParagraphStyle

}

public enum FontStyle {

  case halfLine

  case thin, extraLight, light, regular, medium, bold, black
  case thinItalic, extraLightItalic, lightItalic, italic, mediumItalic, boldItalic, blackItalic

  case thinCentered, extraLightCentered, lightCentered, regularCentered, mediumCentered,
       boldCentered, blackCentered
  case thinItalicCentered, extraLightItalicCentered, lightItalicCentered, italicCentered,
       mediumItalicCentered, boldItalicCentered, blackItalicCentered

  case ctHalfLine

  case ctThin, ctExtraLight, ctLight, ctRegular, ctMedium, ctBold, ctBlack
  case ctThinItalic, ctExtraLightItalic, ctLightItalic, ctItalic, ctMediumItalic, ctBoldItalic, ctBlackItalic

  case ctThinCentered, ctExtraLightCentered, ctLightCentered, ctRegularCentered, ctMediumCentered,
       ctBoldCentered, ctBlackCentered
  case ctThinItalicCentered, ctExtraLightItalicCentered, ctLightItalicCentered, ctItalicCentered,
       ctMediumItalicCentered, ctBoldItalicCentered, ctBlackItalicCentered

  public var attributes: [NSAttributedString.Key:Any] {

    let font: Any
    let paragraphStyle: Any

    switch self {

#if os(iOS)

      case .halfLine:                   font = UIFont.halfLine
                                        paragraphStyle = nsHalfLineParagraphStyle()
      case .thin:                       font = UIFont.thin
                                        paragraphStyle = nsParagraphStyle()
      case .extraLight:                 font = UIFont.extraLight
                                        paragraphStyle = nsParagraphStyle()
      case .light:                      font = UIFont.light
                                        paragraphStyle = nsParagraphStyle()
      case .regular:                    font = UIFont.regular
                                        paragraphStyle = nsParagraphStyle()
      case .medium:                     font = UIFont.medium
                                        paragraphStyle = nsParagraphStyle()
      case .bold:                       font = UIFont.bold
                                        paragraphStyle = nsParagraphStyle()
      case .black:                      font = UIFont.black
                                        paragraphStyle = nsParagraphStyle()
      case .thinItalic:                 font = UIFont.thinItalic
                                        paragraphStyle = nsParagraphStyle()
      case .extraLightItalic:           font = UIFont.extraLightItalic
                                        paragraphStyle = nsParagraphStyle()
      case .lightItalic:                font = UIFont.lightItalic
                                        paragraphStyle = nsParagraphStyle()
      case .italic:                     font = UIFont.italic
                                        paragraphStyle = nsParagraphStyle()
      case .mediumItalic:               font = UIFont.mediumItalic
                                        paragraphStyle = nsParagraphStyle()
      case .boldItalic:                 font = UIFont.boldItalic
                                        paragraphStyle = nsParagraphStyle()
      case .blackItalic:                font = UIFont.blackItalic
                                        paragraphStyle = nsParagraphStyle()
      case .thinCentered:               font = UIFont.thin
                                        paragraphStyle = nsCenteredParagraphStyle()
      case .extraLightCentered:         font = UIFont.extraLight
                                        paragraphStyle = nsCenteredParagraphStyle()
      case .lightCentered:              font = UIFont.light
                                        paragraphStyle = nsCenteredParagraphStyle()
      case .regularCentered:            font = UIFont.regular
                                        paragraphStyle = nsCenteredParagraphStyle()
      case .mediumCentered:             font = UIFont.medium
                                        paragraphStyle = nsCenteredParagraphStyle()
      case .boldCentered:               font = UIFont.bold
                                        paragraphStyle = nsCenteredParagraphStyle()
      case .blackCentered:              font = UIFont.black
                                        paragraphStyle = nsCenteredParagraphStyle()
      case .thinItalicCentered:         font = UIFont.thinItalic
                                        paragraphStyle = nsCenteredParagraphStyle()
      case .extraLightItalicCentered:   font = UIFont.extraLightItalic
                                        paragraphStyle = nsCenteredParagraphStyle()
      case .lightItalicCentered:        font = UIFont.lightItalic
                                        paragraphStyle = nsCenteredParagraphStyle()
      case .italicCentered:             font = UIFont.italic
                                        paragraphStyle = nsCenteredParagraphStyle()
      case .mediumItalicCentered:       font = UIFont.mediumItalic
                                        paragraphStyle = nsCenteredParagraphStyle()
      case .boldItalicCentered:         font = UIFont.boldItalic
                                        paragraphStyle = nsCenteredParagraphStyle()
      case .blackItalicCentered:        font = UIFont.blackItalic
                                        paragraphStyle = nsCenteredParagraphStyle()
#else

      case .halfLine:                   font = NSFont.halfLine
                                        paragraphStyle = nsHalfLineParagraphStyle()
      case .thin:                       font = NSFont.thin
                                        paragraphStyle = nsParagraphStyle()
      case .extraLight:                 font = NSFont.extraLight
                                        paragraphStyle = nsParagraphStyle()
      case .light:                      font = NSFont.light
                                        paragraphStyle = nsParagraphStyle()
      case .regular:                    font = NSFont.regular
                                        paragraphStyle = nsParagraphStyle()
      case .medium:                     font = NSFont.medium
                                        paragraphStyle = nsParagraphStyle()
      case .bold:                       font = NSFont.bold
                                        paragraphStyle = nsParagraphStyle()
      case .black:                      font = NSFont.black
                                        paragraphStyle = nsParagraphStyle()
      case .thinItalic:                 font = NSFont.thinItalic
                                        paragraphStyle = nsParagraphStyle()
      case .extraLightItalic:           font = NSFont.extraLightItalic
                                        paragraphStyle = nsParagraphStyle()
      case .lightItalic:                font = NSFont.lightItalic
                                        paragraphStyle = nsParagraphStyle()
      case .italic:                     font = NSFont.italic
                                        paragraphStyle = nsParagraphStyle()
      case .mediumItalic:               font = NSFont.mediumItalic
                                        paragraphStyle = nsParagraphStyle()
      case .boldItalic:                 font = NSFont.boldItalic
                                        paragraphStyle = nsParagraphStyle()
      case .blackItalic:                font = NSFont.blackItalic
                                        paragraphStyle = nsParagraphStyle()
      case .thinCentered:               font = NSFont.thin
                                        paragraphStyle = nsCenteredParagraphStyle()
      case .extraLightCentered:         font = NSFont.extraLight
                                        paragraphStyle = nsCenteredParagraphStyle()
      case .lightCentered:              font = NSFont.light
                                        paragraphStyle = nsCenteredParagraphStyle()
      case .regularCentered:            font = NSFont.regular
                                        paragraphStyle = nsCenteredParagraphStyle()
      case .mediumCentered:             font = NSFont.medium
                                        paragraphStyle = nsCenteredParagraphStyle()
      case .boldCentered:               font = NSFont.bold
                                        paragraphStyle = nsCenteredParagraphStyle()
      case .blackCentered:              font = NSFont.black
                                        paragraphStyle = nsCenteredParagraphStyle()
      case .thinItalicCentered:         font = NSFont.thinItalic
                                        paragraphStyle = nsCenteredParagraphStyle()
      case .extraLightItalicCentered:   font = NSFont.extraLightItalic
                                        paragraphStyle = nsCenteredParagraphStyle()
      case .lightItalicCentered:        font = NSFont.lightItalic
                                        paragraphStyle = nsCenteredParagraphStyle()
      case .italicCentered:             font = NSFont.italic
                                        paragraphStyle = nsCenteredParagraphStyle()
      case .mediumItalicCentered:       font = NSFont.mediumItalic
                                        paragraphStyle = nsCenteredParagraphStyle()
      case .boldItalicCentered:         font = NSFont.boldItalic
                                        paragraphStyle = nsCenteredParagraphStyle()
      case .blackItalicCentered:        font = NSFont.blackItalic
                                        paragraphStyle = nsCenteredParagraphStyle()

#endif

      case .ctHalfLine:                 font = CTFont.halfLine
                                        paragraphStyle = ctHalfLineParagraphStyle()
      case .ctThin:                     font = CTFont.thin
                                        paragraphStyle = ctParagraphStyle()
      case .ctExtraLight:               font = CTFont.extraLight
                                        paragraphStyle = ctParagraphStyle()
      case .ctLight:                    font = CTFont.light
                                        paragraphStyle = ctParagraphStyle()
      case .ctRegular:                  font = CTFont.regular
                                        paragraphStyle = ctParagraphStyle()
      case .ctMedium:                   font = CTFont.medium
                                        paragraphStyle = ctParagraphStyle()
      case .ctBold:                     font = CTFont.bold
                                        paragraphStyle = ctParagraphStyle()
      case .ctBlack:                    font = CTFont.black
                                        paragraphStyle = ctParagraphStyle()
      case .ctThinItalic:               font = CTFont.thinItalic
                                        paragraphStyle = ctParagraphStyle()
      case .ctExtraLightItalic:         font = CTFont.extraLightItalic
                                        paragraphStyle = ctParagraphStyle()
      case .ctLightItalic:              font = CTFont.lightItalic
                                        paragraphStyle = ctParagraphStyle()
      case .ctItalic:                   font = CTFont.italic
                                        paragraphStyle = ctParagraphStyle()
      case .ctMediumItalic:             font = CTFont.mediumItalic
                                        paragraphStyle = ctParagraphStyle()
      case .ctBoldItalic:               font = CTFont.boldItalic
                                        paragraphStyle = ctParagraphStyle()
      case .ctBlackItalic:              font = CTFont.blackItalic
                                        paragraphStyle = ctParagraphStyle()
      case .ctThinCentered:             font = CTFont.thin
                                        paragraphStyle = ctParagraphStyle()
      case .ctExtraLightCentered:       font = CTFont.extraLight
                                        paragraphStyle = ctCenteredParagraphStyle()
      case .ctLightCentered:            font = CTFont.light
                                        paragraphStyle = ctCenteredParagraphStyle()
      case .ctRegularCentered:          font = CTFont.regular
                                        paragraphStyle = ctCenteredParagraphStyle()
      case .ctMediumCentered:           font = CTFont.medium
                                        paragraphStyle = ctCenteredParagraphStyle()
      case .ctBoldCentered:             font = CTFont.bold
                                        paragraphStyle = ctCenteredParagraphStyle()
      case .ctBlackCentered:            font = CTFont.black
                                        paragraphStyle = ctCenteredParagraphStyle()
      case .ctThinItalicCentered:       font = CTFont.thinItalic
                                        paragraphStyle = ctCenteredParagraphStyle()
      case .ctExtraLightItalicCentered: font = CTFont.extraLightItalic
                                        paragraphStyle = ctCenteredParagraphStyle()
      case .ctLightItalicCentered:      font = CTFont.lightItalic
                                        paragraphStyle = ctCenteredParagraphStyle()
      case .ctItalicCentered:           font = CTFont.italic
                                        paragraphStyle = ctCenteredParagraphStyle()
      case .ctMediumItalicCentered:     font = CTFont.mediumItalic
                                        paragraphStyle = ctCenteredParagraphStyle()
      case .ctBoldItalicCentered:       font = CTFont.boldItalic
                                        paragraphStyle = ctCenteredParagraphStyle()
      case .ctBlackItalicCentered:      font = CTFont.blackItalic
                                        paragraphStyle = ctCenteredParagraphStyle()

    }

    return [.font: font, .paragraphStyle: paragraphStyle]

  }

}

/// Extension of attributed strings with `FontStyle` related functionality.
extension NSAttributedString {

  public convenience init(_ string: String, style: FontStyle) {
    self.init(string: string, attributes: style.attributes)
  }

  #if os(iOS)

  public convenience init(_ string: String, style: FontStyle, color: UIColor) {
    var attributes = style.attributes
    attributes[.foregroundColor] = color
    self.init(string: string, attributes: attributes)
  }

  #else

  public convenience init(_ string: String, style: FontStyle, color: NSColor) {
    var attributes = style.attributes
    attributes[.foregroundColor] = color
    self.init(string: string, attributes: attributes)
  }

  #endif
}

/// Extension of mutable attributed strings with `FontStyle` related functionality.
extension NSMutableAttributedString {

  public func append(_ string: String, style: FontStyle) {
    append(NSAttributedString(string: string, attributes: style.attributes))
  }

  public static func +=(lhs: NSMutableAttributedString, rhs: (String, FontStyle)) {
    lhs.append(NSAttributedString(string: rhs.0, attributes: rhs.1.attributes))
  }

  #if os(iOS)

  public func append(_ string: String, style: FontStyle, color: UIColor) {
    var attributes = style.attributes
    attributes[.foregroundColor] = color
    append(NSAttributedString(string: string, attributes: attributes))
  }

  public static func +=(lhs: NSMutableAttributedString, rhs: (String, FontStyle, UIColor)) {
    var attributes = rhs.1.attributes
    attributes[.foregroundColor] = rhs.2
    lhs.append(NSAttributedString(string: rhs.0, attributes: attributes))
  }


  #else

  public func append(_ string: String, style: FontStyle, color: NSColor) {
    var attributes = style.attributes
    attributes[.foregroundColor] = color
    append(NSAttributedString(string: string, attributes: attributes))
  }

  public static func +=(lhs: NSMutableAttributedString, rhs: (String, FontStyle, NSColor)) {
    var attributes = rhs.1.attributes
    attributes[.foregroundColor] = rhs.2
    lhs.append(NSAttributedString(string: rhs.0, attributes: attributes))
  }

  #endif


}
