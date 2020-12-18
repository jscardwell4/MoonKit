//
//  RepeatingSequence.swift
//  MoonKit
//
//  Created by Jason Cardwell on 9/1/16.
//  Copyright © 2016 Jason Cardwell. All rights reserved.
//

import Foundation

public struct RepeatingSequence<Base:Sequence>: Sequence {
  private let _base: Base
  fileprivate init(_ base: Base) { _base = base }
  public func makeIterator() -> RepeatingIterator<Base.Iterator> {
    return RepeatingIterator(_base.makeIterator())
  }
}

extension Sequence {
  public func repeating() -> RepeatingSequence<Self> { return RepeatingSequence(self) }
}

public struct RepeatingIterator<Base:IteratorProtocol>: IteratorProtocol {

  private let _base: Base
  private var _currentBase: Base


  public init(_ base: Base) {
    _base = base
    _currentBase = base
  }

  public mutating func next() -> Base.Element? {
    switch _currentBase.next() {
      case let element?: return element
      case nil: _currentBase = _base; return _currentBase.next()
    }
  }
  
}
