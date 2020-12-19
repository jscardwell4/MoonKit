//
//  LineDeletingCommands.swift
//  MoonKit
//
//  Created by Jason Cardwell on 9/16/16.
//  Copyright © 2016 Jason Cardwell. All rights reserved.
//

import Foundation
import XcodeKit

final class DeleteSelectedLinesCommand: NSObject, XCSourceEditorCommand {
  func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void) -> Void {
    let lines = invocation.buffer.lines
    let selections = invocation.buffer.selections

    var indexSet = IndexSet()

    for selection in selections {
      let selection = selection as! XCSourceTextRange
      indexSet.insert(integersIn: Range(selection.start.line...selection.end.line))
    }

    lines.removeObjects(at: indexSet)
    completionHandler(nil)
  }

}
