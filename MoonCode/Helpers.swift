//
//  Helpers.swift
//  MoonKit
//
//  Created by Jason Cardwell on 9/16/16.
//  Copyright © 2016 Jason Cardwell. All rights reserved.
//

import Foundation
import XcodeKit

func gatherText(selection: XCSourceTextRange, lines: [String]) -> (head: String, selected: String, tail: String) {

  let head: String, selected: String, tail: String
  switch (selection.start, selection.end) {

    case let (start, end) where start.line == end.line:
      let line = lines[start.line]
      let startColumnIndex = line.index(line.startIndex, offsetBy: start.column)
      let endColumnIndex = line.index(line.startIndex, offsetBy: end.column + 1)
      head = String(line[line.startIndex..<startColumnIndex])
      selected = String(line[startColumnIndex..<endColumnIndex])
      tail = String(line[endColumnIndex..<line.endIndex])

    case let (start, end) where end.line == lines.endIndex:
      let headLine = lines[start.line]
      let startColumnIndex = headLine.index(headLine.startIndex, offsetBy: start.column)
      head = String(headLine[headLine.startIndex..<startColumnIndex])

      tail = ""

      let selectedLines = [String(headLine[startColumnIndex..<headLine.endIndex])]
                        + lines[start.line + 1..<end.line]
      selected = selectedLines.joined(separator: "")

    case let (start, end):
      let headLine = lines[start.line]
      let startColumnIndex = headLine.index(headLine.startIndex, offsetBy: start.column)
      head = String(headLine[headLine.startIndex..<startColumnIndex])

      let tailLine = lines[end.line]
      let endColumnIndex = tailLine.index(tailLine.startIndex, offsetBy: end.column + 1, limitedBy: tailLine.endIndex) ?? tailLine.endIndex
      tail = String(tailLine[endColumnIndex..<tailLine.endIndex])

      let lines1 = [String(headLine[startColumnIndex..<headLine.endIndex])]
      let lines2 = lines[start.line + 1..<end.line]
      let lines3 = [String(tailLine[tailLine.startIndex..<endColumnIndex])]
      let selectedLines = lines1 + lines2 + lines3
      selected = selectedLines.joined(separator: "")

  }

  return (head, selected, tail)
}

func replace(selection: XCSourceTextRange, in buffer: NSMutableArray, with lines: [Any]) {
  let replacementRange = NSRange(location: selection.start.line,
                                 length: selection.end.line - selection.start.line + 1)
  buffer.replaceObjects(in: replacementRange, withObjectsFrom: lines)
}
