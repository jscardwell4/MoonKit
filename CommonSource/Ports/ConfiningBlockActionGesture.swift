//
//  ConfiningBlockActionGesture.swift
//  Remote
//
//  Created by Jason Cardwell on 11/19/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit

public class ConfiningBlockActionGesture: BlockActionGesture {

  /// Whether only touches located within the gesture's view are to be considered valid.
  @IBInspectable public var confineToView: Bool = false

  /// Returns `false` when `view == nil`, `true` when `confineToView == false`, `true` when 
  /// `confineToView == true` and all touch locations reside within `view`, and `false` otherwise.
  func validateTouchLocations<C:Collection>(_ touches: C, withEvent event: UIEvent) -> Bool
     where C.Iterator.Element == UITouch
  {

    guard let view = view else { return false }

    guard confineToView else { return true }

    return touches.count == numericCast(touches.filter({ view.point(inside: $0.location(in: view),
                                                                    with: event) }).count)

  }


}
