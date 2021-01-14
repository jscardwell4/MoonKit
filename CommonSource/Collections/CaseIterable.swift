//
//  CaseIterable.swift
//  MoonKit
//
//  Created by Jason Cardwell on 1/14/21.
//  Copyright © 2021 Moondeer Studios. All rights reserved.
//
import Foundation

public extension CaseIterable where Self.AllCases == [Self], Self: Equatable
{
  var index: Int
  {
    guard let index = Self.allCases.firstIndex(of: self)
    else { fatalError("`allCases` does not contain \(self)") }
    return index
  }

  init(index: Int)
  {
    guard Self.allCases.indices.contains(index) else { fatalError("index out of bounds") }
    self = Self.allCases[index]
  }
}
