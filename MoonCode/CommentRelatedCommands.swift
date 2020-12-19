//
//  CommentRelatedCommands.swift
//  Moon Xcode Extensions
//
//  Created by Jason Cardwell on 7/18/16.
//  Copyright © 2016 Jason Cardwell. All rights reserved.
//

import Foundation
import XcodeKit

private func remove(openComment: String.Index, closeComment: String.Index, from string: String) -> String {
  let head = string.distance(from: string.startIndex, to: openComment) > 2
               ? string[string.startIndex..<string.index(openComment, offsetBy: -2)]
               : ""
  let mid = string[openComment..<closeComment]
  let tail = string.distance(from: closeComment, to: string.endIndex) > 2
               ? string[string.index(closeComment, offsetBy: 2)..<string.index(before: string.endIndex)]
               : ""
  return String(head + mid + tail)
}

final class ToggleBlockCommentCommand: NSObject, XCSourceEditorCommand {

  func perform(with invocation: XCSourceEditorCommandInvocation,
               completionHandler: @escaping (Error?) -> Void) -> Void
  {
    let lines = invocation.buffer.lines
    let selections = (invocation.buffer.selections as NSArray) as! [XCSourceTextRange]


    for selection in selections {

      let (head, selected, tail) = gatherText(selection: selection, lines: (lines as NSArray) as! [String])

      let scanner = Scanner(string: selected)
      let reverseScanner = Scanner(string: String(selected.reversed()))

      let replacementText: String

//      if scanner.
      if   scanner.scanString("/*", into: nil)
        && !scanner.scanString("*", into: nil)
        && reverseScanner.scanString("/*", into: nil)
      {
        replacementText = remove(openComment: selected.index(selected.startIndex,
                                                             offsetBy: scanner.scanLocation),
                                 closeComment: selected.index(selected.endIndex,
                                                              offsetBy: -reverseScanner.scanLocation),
                                 from: selected)
      } else {
        replacementText = "/*\(selected)*/"
      }

      replace(selection: selection,
              in: lines,
              with: (head + replacementText + (tail == "\n" ? "" : tail)).components(separatedBy: "\n"))


    }

    completionHandler(nil)
  }
}

final class RemoveBlockCommentCommand: NSObject, XCSourceEditorCommand {

  func perform(with invocation: XCSourceEditorCommandInvocation,
               completionHandler: @escaping (Error?) -> Void) -> Void
  {
    let lines = invocation.buffer.lines
    let selections = (invocation.buffer.selections as NSArray) as! [XCSourceTextRange]


    for selection in selections {

      let (head, selected, tail) = gatherText(selection: selection, lines: (lines as NSArray) as! [String])

      let scanner = Scanner(string: selected)
      let reverseScanner = Scanner(string: String(selected.reversed()))

      scanner.scanUpTo("/*", into: nil)
      reverseScanner.scanUpTo("/*", into: nil)

      guard    scanner.scanString("/*", into: nil)
            && !scanner.scanString("*", into: nil)
            && reverseScanner.scanString("/*", into: nil) else { continue }

      let replacementText = remove(openComment: selected.index(selected.startIndex,
                                                               offsetBy: scanner.scanLocation),
                                 closeComment: selected.index(selected.endIndex,
                                                              offsetBy: -reverseScanner.scanLocation),
                                 from: selected)

      replace(selection: selection,
              in: lines,
              with: (head + replacementText + (tail == "\n" ? "" : tail)).components(separatedBy: "\n"))


    }
    
    completionHandler(nil)
  }
}

final class AddBlockCommentCommand: NSObject, XCSourceEditorCommand {

  func perform(with invocation: XCSourceEditorCommandInvocation,
               completionHandler: @escaping (Error?) -> Void) -> Void
  {
    let lines = invocation.buffer.lines
    let selections = (invocation.buffer.selections as NSArray) as! [XCSourceTextRange]


    for selection in selections {

      let (head, selected, tail) = gatherText(selection: selection, lines: (lines as NSArray) as! [String])

      replace(selection: selection,
              in: lines,
              with: (head + "/*\(selected)*/" + (tail == "\n" ? "" : tail)).components(separatedBy: "\n"))

    }
    
    completionHandler(nil)
  }
}


