//
//  AnyCancellable.swift
//  MoonKit
//
//  Created by Jason Cardwell on 1/14/21.
//  Copyright © 2021 Moondeer Studios. All rights reserved.
//
import Combine
import Foundation

extension Set where Element == AnyCancellable
{
  public mutating func store(@CancellableBuilder _ cancellables: () -> [AnyCancellable])
  {
    formUnion(cancellables())
  }

  @_functionBuilder
  public enum CancellableBuilder
  {
    public static func buildBlock(_ cancellables: AnyCancellable...) -> [AnyCancellable]
    {
      cancellables
    }
  }
}
