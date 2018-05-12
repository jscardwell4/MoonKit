//
//  Fonts.swift
//  MoonKit
//
//  Created by Jason Cardwell on 8/30/17.
//  Copyright (c) 2017 Moondeer Studios. All rights reserved.
//
import Foundation
import CoreText

/// A set of names for bundled fonts that have been registered with the font manager.
private var registeredFonts: Set<String> = []

/// Retrieves the URL for a bundled font from the framework's bundle.
///
/// - Parameter name: The name of the font file without the extension.
/// - Returns: The URL for the bundled font with `name`.
private func url(forFont name: String) -> URL {

  let bundleIdentifer: String

  #if os(iOS)
    bundleIdentifer = "com.moondeerstudios.MoonKit-iOS"
  #else
    bundleIdentifer = "com.moondeerstudios.MoonKit-Mac"
  #endif

  guard let bundle = Bundle(identifier: bundleIdentifer) else {
    fatalError("Failed to retrieve the framework's bundle.")
  }

  guard let url = bundle.url(forResource: name, withExtension: "ttf") else {
    fatalError("Missing font '\(name)'")
  }

  return url

}

/// Registers a bundled font with the font manager.
///
/// - Parameter name: The name of the bundled font.
private func registerFont(name: String) {

  // Get the url for the bundled font.
  let fontURL = url(forFont: name) as NSURL

  // Register the font url with the font manager.
  guard CTFontManagerRegisterFontsForURL(fontURL, CTFontManagerScope.process, nil) else {
    fatalError("Font registration failed for font '\(name)'")
  }

  // Add the font name to the set of registered fonts.
  registeredFonts.insert(name)

}

/// Generates a `CTFont` from a font name. The font is registered with the font manager when
/// necessary.
///
/// - Parameters:
///   - name: The name of the font.
///   - size: The point size of the font. Default is `10`.
/// - Returns: A `CTFont` object with the specified `name` and `size`.
private func ctfont(name: String, size: CGFloat = 10) -> CTFont {

  // Make sure the font has been registered.
  if !registeredFonts.contains(name) { registerFont(name: name) }

  // Return the font with a point size of `10`.
  return CTFontCreateWithName(name as CFString, size, nil)

}

extension CTFont {

  public static var halfLine: CTFont { return ctfont(name: "InputMonoCompressed-Regular", size: 5) }
  public static var bold: CTFont { return ctfont(name: "InputMonoCompressed-Bold") }
  public static var boldItalic: CTFont { return ctfont(name: "InputMonoCompressed-BoldItalic") }
  public static var regular: CTFont { return ctfont(name: "InputMonoCompressed-Regular") }
  public static var italic: CTFont { return ctfont(name: "InputMonoCompressed-Italic") }
  public static var light: CTFont { return ctfont(name: "InputMonoCompressed-Light") }
  public static var lightItalic: CTFont { return ctfont(name: "InputMonoCompressed-LightItalic") }
  public static var extraLight: CTFont { return ctfont(name: "InputMonoCompressed-ExtraLight") }
  public static var extraLightItalic: CTFont { return ctfont(name: "InputMonoCompressed-ExtraLightItalic") }
  public static var thin: CTFont { return ctfont(name: "InputMonoCompressed-Thin") }
  public static var thinItalic: CTFont { return ctfont(name: "InputMonoCompressed-ThinItalic") }
  public static var medium: CTFont { return ctfont(name: "InputMonoCompressed-Medium") }
  public static var mediumItalic: CTFont { return ctfont(name: "InputMonoCompressed-MediumItalic") }
  public static var black: CTFont { return ctfont(name: "InputMonoCompressed-Black") }
  public static var blackItalic: CTFont { return ctfont(name: "InputMonoCompressed-BlackItalic") }

}

#if os(iOS)

import class UIKit.UIFont

/// Generates a `UIFont` from a font name. The font is registered with the font manager when
/// necessary.
///
/// - Parameters:
///   - name: The name of the font.
///   - size: The point size of the font. Default is `10`.
/// - Returns: A `UIFont` object with the specified `name` and `size`.
private func uifont(name: String, size: CGFloat = 10) -> UIFont {

  // Make sure the font has been registered.
  if !registeredFonts.contains(name) { registerFont(name: name) }

  // Return the font with a point size of `10`.
  guard let font = UIFont(name: name, size: size) else {
    fatalError("Failed to create font using name '\(name)'")
  }

  return font

}

extension UIFont {

  public static var halfLine: UIFont { return uifont(name: "InputMonoCompressed-Regular", size: 5) }
  public static var bold: UIFont { return uifont(name: "InputMonoCompressed-Bold") }
  public static var boldItalic: UIFont { return uifont(name: "InputMonoCompressed-BoldItalic") }
  public static var regular: UIFont { return uifont(name: "InputMonoCompressed-Regular") }
  public static var italic: UIFont { return uifont(name: "InputMonoCompressed-Italic") }
  public static var light: UIFont { return uifont(name: "InputMonoCompressed-Light") }
  public static var lightItalic: UIFont { return uifont(name: "InputMonoCompressed-LightItalic") }
  public static var extraLight: UIFont { return uifont(name: "InputMonoCompressed-ExtraLight") }
  public static var extraLightItalic: UIFont { return uifont(name: "InputMonoCompressed-ExtraLightItalic") }
  public static var thin: UIFont { return uifont(name: "InputMonoCompressed-Thin") }
  public static var thinItalic: UIFont { return uifont(name: "InputMonoCompressed-ThinItalic") }
  public static var medium: UIFont { return uifont(name: "InputMonoCompressed-Medium") }
  public static var mediumItalic: UIFont { return uifont(name: "InputMonoCompressed-MediumItalic") }
  public static var black: UIFont { return uifont(name: "InputMonoCompressed-Black") }
  public static var blackItalic: UIFont { return uifont(name: "InputMonoCompressed-BlackItalic") }

}

#else

import class AppKit.NSFont

/// Generates a `NSFont` from a font name. The font is registered with the font manager when
/// necessary.
///
/// - Parameters:
///   - name: The name of the font.
///   - size: The point size of the font. Default is `10`.
/// - Returns: A `NSFont` object with the specified `name` and `size`.
private func nsfont(name: String, size: CGFloat = 10) -> NSFont {

  // Make sure the font has been registered.
  if !registeredFonts.contains(name) { registerFont(name: name) }

  // Return the font with a point size of `10`.
  guard let font = NSFont(name: name, size: size) else {
    fatalError("Failed to create font using name '\(name)'")
  }

  return font

}

extension NSFont {

  public static var halfLine: NSFont { return nsfont(name: "InputMonoCompressed-Regular", size: 5) }
  public static var bold: NSFont { return nsfont(name: "InputMonoCompressed-Bold") }
  public static var boldItalic: NSFont { return nsfont(name: "InputMonoCompressed-BoldItalic") }
  public static var regular: NSFont { return nsfont(name: "InputMonoCompressed-Regular") }
  public static var italic: NSFont { return nsfont(name: "InputMonoCompressed-Italic") }
  public static var light: NSFont { return nsfont(name: "InputMonoCompressed-Light") }
  public static var lightItalic: NSFont { return nsfont(name: "InputMonoCompressed-LightItalic") }
  public static var extraLight: NSFont { return nsfont(name: "InputMonoCompressed-ExtraLight") }
  public static var extraLightItalic: NSFont { return nsfont(name: "InputMonoCompressed-ExtraLightItalic") }
  public static var thin: NSFont { return nsfont(name: "InputMonoCompressed-Thin") }
  public static var thinItalic: NSFont { return nsfont(name: "InputMonoCompressed-ThinItalic") }
  public static var medium: NSFont { return nsfont(name: "InputMonoCompressed-Medium") }
  public static var mediumItalic: NSFont { return nsfont(name: "InputMonoCompressed-MediumItalic") }
  public static var black: NSFont { return nsfont(name: "InputMonoCompressed-Black") }
  public static var blackItalic: NSFont { return nsfont(name: "InputMonoCompressed-BlackItalic") }

}

#endif
