//
//  LineJoiningCommands.swift
//  MoonKit
//
//  Created by Jason Cardwell on 9/16/16.
//  Copyright © 2016 Jason Cardwell. All rights reserved.
//

import Foundation
import XcodeKit

/// Returns the string formed by trimming leading and/or trailing whitespace.
/// When not preserving the head of the string, consecutive forward-slash characters are also removed.
private func _trim(_ string: String, preserveHead: Bool = false, preserveTail: Bool = false) -> String {

  // Get the collection of scalars contained by the string.
  let scalars = string.unicodeScalars

  // Get the first index in the collection of scalars.
  var newStartIndex = scalars.startIndex

  // Process the leading characters when not preserving the head of the string.
  if !preserveHead {

    // Iterate through the indexes of the collection of scalars looking for whitespace.
    while newStartIndex < scalars.endIndex {

      // Check that `newStartIndex` marks the position of a whitespace or newline character.
      guard CharacterSet.whitespacesAndNewlines.contains(scalars[newStartIndex]) else {

        // Get the forward-slash character as a unicode scalar.
        let forwardSlash: UnicodeScalar = "/"

        // Check that `newStartIndex` marks the position of a forward-slash character.
        guard scalars[newStartIndex] == forwardSlash else { break }

        // Increment `newStartIndex`.
        scalars.formIndex(after: &newStartIndex)

        // Check that `newStartIndex` marks the position of a forward-slash character.
        guard scalars[newStartIndex] == forwardSlash else {

          // Decrement `newStartIndex` since the forward-slash is not part of a single-line comment.
          scalars.formIndex(before: &newStartIndex)

          break

        }

        // Increment `newStartIndex`.
        scalars.formIndex(after: &newStartIndex)

        // Iterate through the indexes of the collection of scalars looking for the 
        // forward-slash character.
        while newStartIndex < scalars.endIndex {

          // Check that `newStartIndex` marks the position of a forward-slash character.
          guard scalars[newStartIndex] == forwardSlash else { break }

          // Increment `newStartIndex`.
          scalars.formIndex(after: &newStartIndex)

        }

        // Continue iterating through the collection of scalars looking for whitespace.
        continue

      }

      // Increment `newStartIndex`.
      scalars.formIndex(after: &newStartIndex)

    }

  }

  // Get the last index in the collection of scalars.
  var newEndIndex = scalars.endIndex

  // Process the trailing characters when not preserving the tail of the string.
  if !preserveTail {

    // Decrement `newEndIndex` to get a valid scalar index.
    newEndIndex = scalars.index(scalars.endIndex, offsetBy: -1, limitedBy: scalars.startIndex)
                  ?? scalars.startIndex

    // Iterate through the indexes of the collection of scalars in reverse order.
    while newEndIndex > scalars.startIndex {

      // Check that `newEndIndex` marks the position of a whitespace or newline character.
      guard CharacterSet.whitespacesAndNewlines.contains(scalars[newEndIndex]) else { break }

      // Decrement `newEndIndex`.
      scalars.formIndex(before: &newEndIndex)

    }

    // Increment `newEndIndex` if it marks the position of a character that is neither whitespace or 
    // a newline.
    if   newEndIndex < scalars.endIndex
      && !CharacterSet.whitespacesAndNewlines.contains(scalars[newEndIndex])
    {

      scalars.formIndex(after: &newEndIndex)

    }

  }

  // Return the string composed of the scalars bounded by the new indices.
  return newStartIndex < newEndIndex ? String(scalars[newStartIndex..<newEndIndex]) : ""

}

/// Returns the string formed by trimming the leading and trailing whitespace.
private func trim(_ string: String) -> String { return _trim(string) }

/// Returns the string formed by trimming the leading whitespace.
private func trimHead(_ string: String) -> String { return _trim(string, preserveTail: true) }

/// Returns the string formed by trimming the traling whitespace.
private func trimTail(_ string: String) -> String { return _trim(string, preserveHead: true) }

/// Joins the lines within `lines` marked by the `start` and `end` positions using `separator`.
private func joinLines(lines: NSMutableArray,
                       start: XCSourceTextPosition,
                       end: XCSourceTextPosition,
                       separator: String = "")
{

  // Handle according to the relationship between `start.line` and `end.line`.
  switch (start, end) {

    case let (start, end)
      where (start.line == end.line && start.column == end.column)
         || (start.line &+ 1) == end.line:
      // The two text positions are equal or mark adjoining lines. Join the line containing the
      // start position with the line that follows.

      // Create the head of the replacement line by trimming the tail of the line at the specified 
      // position.
      let head = trimTail(String(lines[start.line] as! String))

      // Create the tail of the replacement line by trimming the head of the line that follows.
      let tail = trimHead(String(lines[start.line + 1] as! String))

      // Create the replacement line by joining its head and tail with the specified separator.
      let replacementLine = head + separator + tail

      // Create the range of lines to replace within `lines`.
      let range = NSRange(location: start.line, length: 2)

      // Replace the two lines with the replacement line.
      lines.replaceObjects(in: range, withObjectsFrom: [replacementLine])

    case let (start, end) where (start.line + 1) < end.line:
      // The two text positions mark a selection spanning more than two lines.

      // Create the head of the replacement line by trimming the tail of the first line in the selection.
      let head = trimTail(String(lines[start.line] as! String))

      // Create the tail of the replacment line by trimming the head of the last line in the selection.
      let tail = trimHead(String(lines[end.line] as! String))

      // Create a range marking the lines between the first and last in the selection.
      var range = NSRange(location: start.line + 1, length: end.line - start.line - 1)

      // Create the middle of the replacement line by joining the trimmed lines from the subarray of 
      // lines within `range` using `separator`.
      let meat = lines.subarray(with: range).map({$0 as! String}).map(trim).joined(separator: separator)

      // Create the replacement line by joining the head, middle, and tail lines using `separator`.
      let replacementLine = head + separator + meat + separator + tail

      // Adjust the previously created range to include the first and last lines.
      range.location -= 1
      range.length += 2

      // Replace the selected lines with the replacement line.
      lines.replaceObjects(in: range, withObjectsFrom: [replacementLine])

    default:
      // Unhandled relationship between the start and end positions.

      break

  }

}

/// Iterates over the selections in `buffer` joining the selected lines using `separator`.
private func joinSelectedLines(buffer: XCSourceTextBuffer, separator: String = "") {

  // Downcast the buffer's selections into an array of `XCSourceTextRange` instances.
  guard let selections = (buffer.selections as NSArray) as? [XCSourceTextRange] else { return }

  // Iterate the selections witin the buffer.
  for selection in selections {

    // Join the lines within `selection` using `separator`.
    joinLines(lines: buffer.lines, start: selection.start, end: selection.end, separator: separator)
  }

}

/// An editor command for joining selected lines ''.
final class JoinLinesCommand: NSObject, XCSourceEditorCommand {

  func perform(with invocation: XCSourceEditorCommandInvocation,
               completionHandler: @escaping (Error?) -> Void ) -> Void
  {
    joinSelectedLines(buffer: invocation.buffer)
    completionHandler(nil)
  }

}

/// An editor command for joining selected lines with '; '.
final class JoinLinesWithSemicolonSpaceCommand: NSObject, XCSourceEditorCommand {

  func perform(with invocation: XCSourceEditorCommandInvocation,
               completionHandler: @escaping (Error?) -> Void ) -> Void
  {
    joinSelectedLines(buffer: invocation.buffer, separator: "; ")
    completionHandler(nil)
  }

}

/// An editor command for joining selected lines with ' '.
final class JoinLinesWithSpaceCommand: NSObject, XCSourceEditorCommand {

  func perform(with invocation: XCSourceEditorCommandInvocation,
               completionHandler: @escaping (Error?) -> Void ) -> Void
  {
    joinSelectedLines(buffer: invocation.buffer, separator: " ")
    completionHandler(nil)
  }

}

