//
//  List.swift
//  MoonKit
//  Source: https://gist.github.com/airspeedswift/list.swift
//  Created by Jason Cardwell on 8/16/15.
//  Copyright © 2015 Jason Cardwell. All rights reserved.
//

import Foundation
fileprivate enum ListNode<Element> {
  case end
  indirect case node(Element, tag: Int, next: ListNode<Element>)

  /// Computed property to fetch the tag. .End has an
  /// implicit tag of zero.
  var tag: Int { switch self { case .end: return 0; case let .node(_, n, _): return n } }

  func cons(_ x: Element) -> ListNode<Element> {
    // each cons increments the tag by one
    return .node(x, tag: tag+1, next: self)
  }
}

public struct ListIndex<Element> {
  fileprivate let node: ListNode<Element>
}

extension ListIndex {//: Comparable {
  public func successor() -> ListIndex<Element> {
    switch node {
      case .end: fatalError("cannot increment endIndex")
      case let .node(_, _, n): return ListIndex(node: n)
    }
  }
}

public func == <T>(lhs: ListIndex<T>, rhs: ListIndex<T>) -> Bool { return lhs.node.tag == rhs.node.tag }

public struct List<Element>: Collection {
  // Index's type could be inferred, but it helps make the
  // rest of the code clearer:
  public typealias Index = ListIndex<Element>

  public var startIndex: Index
  public var endIndex: Index

  public subscript(idx: Index) -> Element {
    switch idx.node {
      case .end: fatalError("Subscript out of range")
      case let .node(x, _, _): return x
    }
  }

  public func cons(_ x: Element) -> List<Element> {
    return List(startIndex: ListIndex(node: startIndex.node.cons(x)), endIndex: endIndex)
  }
}

extension List: ExpressibleByArrayLiteral {

  public init<S: Sequence>(_ seq: S) where S.Iterator.Element == Element {
    startIndex = ListIndex(node: seq.reversed().reduce(.end) { $0.cons($1) })
    endIndex = ListIndex(node: .end)
  }

  public init<C: Collection>(_ col: C) where C.Iterator.Element == Element {
    startIndex = ListIndex(node: col.reversed().reduce(.end) { $0.cons($1) })
    endIndex = ListIndex(node: .end)
  }

  public init(arrayLiteral elements: Element...) { self = List(elements) }
}

extension List: CustomStringConvertible {
  public var description: String { return "[" + ", ".join(self.map { String($0) }) + "]" }
}

extension List {
  public var count: Int { return startIndex.node.tag - endIndex.node.tag }
}

public func == <T: Equatable>(lhs: List<T>, rhs: List<T>) -> Bool {
  return lhs.elementsEqual(rhs)
}

extension List {
  fileprivate init(subRange: Range<Index>) { startIndex = subRange.lowerBound; endIndex = subRange.upperBound }
  public subscript(subRange: Range<Index>) -> List<Element> { return List(subRange: subRange) }
}

extension List {
  public func reverse() -> List<Element> {
    return List(startIndex: ListIndex(node: reduce(.end) { $0.cons($1) }), endIndex: ListIndex(node: .end))
  }
}
