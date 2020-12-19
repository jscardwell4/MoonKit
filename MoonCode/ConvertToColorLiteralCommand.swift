//
//  ConvertToColorLiteralCommand.swift
//  MoonKit
//
//  Created by Jason Cardwell on 12/21/16.
//  Copyright © 2016 Jason Cardwell. All rights reserved.
//

import Foundation
import XcodeKit

final class ConvertToColorLiteralCommand: NSObject, XCSourceEditorCommand {

  func perform(with invocation: XCSourceEditorCommandInvocation,
               completionHandler: @escaping (Error?) -> Void) -> Void
  {
    let lines = invocation.buffer.lines
    let selections = (invocation.buffer.selections as NSArray) as! [XCSourceTextRange]

    let regexRGBHex: NSRegularExpression
    let regexRGBAHex: NSRegularExpression
    let regexRGBFunc: NSRegularExpression
    let regexRGBAFunc: NSRegularExpression
    let regexRGBA: NSRegularExpression
    let regexWA: NSRegularExpression

    do {
      regexRGBHex = try NSRegularExpression(pattern: "UIColor\\s*\\(\\s*rgbHex\\s*:\\s*(?:(?:(?:0x)([0-9a-fA-F]+))|([0-9]+))\\s*\\)")
      regexRGBAHex = try NSRegularExpression(pattern: "UIColor\\s*\\(\\s*rgbaHex\\s*:\\s*(?:(?:(?:0x)([0-9a-fA-F]+))|([0-9]+))\\s*\\)")
      regexRGBFunc = try NSRegularExpression(pattern: "rgb\\(\\s*([0-9]+)\\s*,\\s*([0-9]+)\\s*,\\s*([0-9]+)\\s*\\)")
      regexRGBAFunc = try NSRegularExpression(pattern: "rgba\\(\\s*([0-9]+)\\s*,\\s*([0-9]+)\\s*,\\s*([0-9]+)\\s*,\\s*([0-9]+)\\s*\\)")
      regexRGBA = try NSRegularExpression(pattern: "UIColor\\s*\\(\\s*red\\s*:\\s*([0-9.]+)\\s*,\\s*green\\s*:\\s*([0-9.]+)\\s*,\\s*blue\\s*:\\s*([0-9.]+)\\s*,\\s*alpha\\s*:\\s*([0-9.]+)\\s*\\)")
      regexWA = try NSRegularExpression(pattern: "UIColor\\s*\\(\\s*white\\s*:\\s*([0-9.]+)\\s*,\\s*alpha\\s*:\\s*([0-9.]+)\\s*\\)")
    }

    catch {
      completionHandler(error)
      return
    }

    func performSubstitutions(in string: NSMutableString, with replacements: [(NSRange, String)]) {
      var offset = 0

      for (range, replacement) in replacements {
        let adjustedRange = NSRange(location: range.location &+ offset, length: range.length)
        let 𝝙length = replacement.utf16.count &- range.length
        offset += 𝝙length
        string.replaceCharacters(in: adjustedRange, with: replacement)
      }
    }

    for selection in selections {

      let (head, selected, tail) = gatherText(selection: selection, lines: (lines as NSArray) as! [String])

      let replacementSelected = NSMutableString(string: selected as NSString)

      let rgbHexMatches = regexRGBHex.matches(in: replacementSelected as String,
                                              range: NSRange(location: 0, length: replacementSelected.length))
      if !rgbHexMatches.isEmpty {

        let replacements: [(NSRange, String)] = rgbHexMatches.map {
          guard $0.numberOfRanges == 3 else {
            return ($0.range, replacementSelected.substring(with: $0.range))
          }
          let hex: UInt32?
          if $0.range(at: 1).location != NSNotFound {
            hex = UInt32(replacementSelected.substring(with: $0.range(at: 1)), radix: 16)
          } else {
            hex = UInt32(replacementSelected.substring(with: $0.range(at: 2)))
          }
          guard hex != nil else {
            return ($0.range, replacementSelected.substring(with: $0.range))
          }
          let red = CGFloat(hex! >> 16 & 0xFF) / 255
          let green = CGFloat(hex! >> 8 & 0xFF) / 255
          let blue = CGFloat(hex! & 0xFF) / 255
          return ($0.range, "#colorLiteral(red: \(red), green: \(green), blue: \(blue), alpha: 1.0)")
        }

        performSubstitutions(in: replacementSelected, with: replacements)
      }

      let rgbaHexMatches = regexRGBAHex.matches(in: replacementSelected as String,
                                                  range: NSRange(location: 0, length: replacementSelected.length))
      if !rgbaHexMatches.isEmpty {

        let replacements: [(NSRange, String)] = rgbaHexMatches.map {
          guard $0.numberOfRanges == 3 else {
            return ($0.range, replacementSelected.substring(with: $0.range))
          }
          let hex: UInt32?
          if $0.range(at: 1).location != NSNotFound {
            hex = UInt32(replacementSelected.substring(with: $0.range(at: 1)), radix: 16)
          } else {
            hex = UInt32(replacementSelected.substring(with: $0.range(at: 2)))
          }
          guard hex != nil else {
            return ($0.range, replacementSelected.substring(with: $0.range))
          }
          let red = CGFloat(hex! >> 24 & 0xFF) / 255
          let green = CGFloat(hex! >> 16 & 0xFF) / 255
          let blue = CGFloat(hex! >> 8 & 0xFF) / 255
          let alpha = CGFloat(hex! & 0xFF) / 255
          return ($0.range, "#colorLiteral(red: \(red), green: \(green), blue: \(blue), alpha: \(alpha))")
        }

        performSubstitutions(in: replacementSelected, with: replacements)
      }

      let rgbFuncMatches = regexRGBFunc.matches(in: replacementSelected as String,
                                                range: NSRange(location: 0, length: replacementSelected.length))
      if !rgbFuncMatches.isEmpty {

        let replacements: [(NSRange, String)] = rgbFuncMatches.map {
          guard $0.numberOfRanges == 4,
                let red = Int(replacementSelected.substring(with: $0.range(at: 1))),
                let green = Int(replacementSelected.substring(with: $0.range(at: 2))),
                let blue = Int(replacementSelected.substring(with: $0.range(at: 3)))
            else
          {
            return ($0.range, replacementSelected.substring(with: $0.range))
          }

          return ($0.range, "#colorLiteral(red: \(CGFloat(red)/255), green: \(CGFloat(green)/255), blue: \(CGFloat(blue)/255), alpha: 1.0)")
        }

        performSubstitutions(in: replacementSelected, with: replacements)
      }

      let rgbaFuncMatches = regexRGBAFunc.matches(in: replacementSelected as String,
                                                range: NSRange(location: 0, length: replacementSelected.length))
      if !rgbaFuncMatches.isEmpty {

        let replacements: [(NSRange, String)] = rgbaFuncMatches.map {
          guard $0.numberOfRanges == 5,
                let red = Int(replacementSelected.substring(with: $0.range(at: 1))),
                let green = Int(replacementSelected.substring(with: $0.range(at: 2))),
                let blue = Int(replacementSelected.substring(with: $0.range(at: 3))),
                let alpha = Int(replacementSelected.substring(with: $0.range(at: 4)))
            else
          {
            return ($0.range, replacementSelected.substring(with: $0.range))
          }

          return ($0.range, "#colorLiteral(red: \(CGFloat(red)/255), green: \(CGFloat(green)/255), blue: \(CGFloat(blue)/255), alpha: \(CGFloat(alpha)/255))")
        }

        performSubstitutions(in: replacementSelected, with: replacements)
      }

      let rgbaMatches = regexRGBA.matches(in: replacementSelected as String,
                                                range: NSRange(location: 0, length: replacementSelected.length))
      if !rgbaMatches.isEmpty {

        let replacements: [(NSRange, String)] = rgbaMatches.map {
          guard $0.numberOfRanges == 5 else {
            return ($0.range, replacementSelected.substring(with: $0.range))
          }

          return ($0.range, "#colorLiteral(red: \(replacementSelected.substring(with: $0.range(at: 1))), green: \(replacementSelected.substring(with: $0.range(at: 2))), blue: \(replacementSelected.substring(with: $0.range(at: 3))), alpha: \(replacementSelected.substring(with: $0.range(at: 4))))")
        }

        performSubstitutions(in: replacementSelected, with: replacements)
      }

      let waMatches = regexWA.matches(in: replacementSelected as String,
                                      range: NSRange(location: 0, length: replacementSelected.length))
      if !waMatches.isEmpty {

        let replacements: [(NSRange, String)] = waMatches.map {
          guard $0.numberOfRanges == 3 else {
            return ($0.range, replacementSelected.substring(with: $0.range))
          }

          return ($0.range, "#colorLiteral(red: \(replacementSelected.substring(with: $0.range(at: 1))), green: \(replacementSelected.substring(with: $0.range(at: 1))), blue: \(replacementSelected.substring(with: $0.range(at: 1))), alpha: \(replacementSelected.substring(with: $0.range(at: 2))))")
        }

        performSubstitutions(in: replacementSelected, with: replacements)
      }


      replace(selection: selection,
              in: lines,
              with: (head + "\(replacementSelected)" + (tail == "\n" ? "" : tail)).components(separatedBy: "\n"))

    }

    completionHandler(nil)

  }

}


