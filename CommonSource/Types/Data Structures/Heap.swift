//
//  Heap.swift
//  MoonKit
//
//  Created by Jason Cardwell on 8/19/15.
//  Copyright © 2015 Jason Cardwell. All rights reserved.
//
//  Converted source https://gist.github.com/airspeedswift/COWTree.swift to 
//  mimic https://gist.github.com/airspeedswift/list.swift

import Foundation

fileprivate enum HeapNode<Element: Comparable> {
  case empty
  indirect case node(value: Element, left: HeapNode<Element>, right: HeapNode<Element>)

  /**
  initWithValue:

  - parameter value: Element
  */
  init(value: Element) { self = .node(value: value, left: .empty, right: .empty) }
}

public struct Heap<Element: Comparable> {

  fileprivate var root = HeapNode<Element>.empty

  /** init */
  public init() {}

  /**
  init:

  - parameter seq: S
  */
  public init<S: Sequence>(_ seq: S) where S.Iterator.Element == Element { seq.forEach { insert($0) } }

  /**
  insert:

  - parameter value: Element
  */
  public mutating func insert(_ value: Element) { root = insert(root, value) }

  /**
  insert:value:

  - parameter node: HeapNode<Element>
  - parameter value: Element

  - returns: HeapNode<Element>
  */
  fileprivate mutating func insert(_ node: HeapNode<Element>, _ value: Element) -> HeapNode<Element> {
    switch node {
      case .empty:                             return HeapNode(value: value)
      case let .node(v, l, r) where value < v: return .node(value: v, left: insert(l, value), right: r)
      case let .node(v, l, r):                 return .node(value: v, left: l, right: insert(r, value))
    }
  }

  /**
  contains:

  - parameter value: Element

  - returns: Bool
  */
  public func contains(_ value: Element) -> Bool { return contains(root, value) }

  /**
  contains:value:

  - parameter node: HeapNode<Element>
  - parameter value: Element

  - returns: Bool
  */
  fileprivate func contains(_ node: HeapNode<Element>, _ value: Element) -> Bool {
    switch node {
      case .empty:                              return false
      case let .node(v, _, _) where value == v: return true
      case let .node(v, l, r):                  return contains(value < v ? l : r, value)
    }
  }
}

extension Heap: Sequence {

  public typealias Iterator = AnyIterator<Element>

  /**
  generate

  - returns: Generator
  */
  public func makeIterator() -> Iterator {
    var stack: [HeapNode<Element>] = []
    var current = self.root
    return AnyIterator {
      while true {
        if case let .node(_, l, _) = current {
          stack.append(current)
          current = l
        } else if !stack.isEmpty, case let .node(v, _, r) = stack.removeLast() {
          current = r
          return v
        } else {
          return nil
        }
      }
    }
  }
}

extension Heap: CustomStringConvertible {
  public var description: String { return "[" + ", ".join(lazy.map({String(describing: $0)})) + "]" }
}
