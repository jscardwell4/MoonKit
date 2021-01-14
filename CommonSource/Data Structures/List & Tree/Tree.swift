//
//  Tree.swift
//  MoonKit
//
//  Created by Jason Cardwell on 9/19/15.
//  Copyright © 2015 Jason Cardwell. All rights reserved.
//  modified source code from http://airspeedvelocity.net/2015/07/22/a-persistent-tree-using-indirect-enums-in-swift
//

import Foundation

fileprivate enum Color { case red, black }

fileprivate indirect enum Node<Element: Comparable> {
  case none
  case some(Color, Node<Element>, Element, Node<Element>)

  fileprivate mutating func update(_ color: Color, left: Node<Element>, value: Element, right: Node<Element>) {
    self = .some(color, left, value, right)
  }
}

fileprivate enum FindOptions { case `default`, nearestNotGreaterThan, nearestNotLessThan }

public struct Tree<Element: Comparable> {


  fileprivate var root: Node<Element> = .none

  /// Whether the node is a leaf node
  public var isEmpty: Bool { if case .none = root { return true } else { return false } }

  /** Create an empty tree */
  public init() {}

  /**
   Create a tree with the specified elements

   - parameter source: S
   */
  public init<S: Sequence>(_ source: S) where S.Iterator.Element == Element {
    for element in source { insert(element) }
  }

  /**
  Whether the tree contains the specified element

  - parameter x: Element

  - returns: Bool
  */
  public func contains(_ element: Element) -> Bool {
    func subtreeContainsElement(_ subtree: Node<Element>) -> Bool {
      switch subtree {
        case .none: return false
        case let .some(_, left, value, _)  where element < value:  return subtreeContainsElement(left)
        case let .some(_, _, value, right) where element > value:  return subtreeContainsElement(right)
        case let .some(_, _, value, _)     where element == value: fallthrough
        default:                                                   return true
      }
    }
    return subtreeContainsElement(root)
  }

  /**
  Helper for balancing the tree

  - parameter tree: Node<Element>

  - returns: Node<Element>
  */
  fileprivate func balance(_ node: Node<Element>) -> Node<Element> {
    /**
    Helper for composing tree from case-extracted values

    - parameter a: Node<Element>
    - parameter x: Element
    - parameter b: Node<Element>
    - parameter y: Element
    - parameter c: Node<Element>
    - parameter z: Element
    - parameter d: Node<Element>

    - returns: Node<Element>
    */
    func result(_ a: Node<Element>, _ x: Element,
              _ b: Node<Element>, _ y: Element,
              _ c: Node<Element>, _ z: Element, _ d: Node<Element>) -> Node<Element>
    {
      return .some(.red, .some(.black, a, x, b), y, .some(.black, c, z, d))
    }

    switch node {
      case let .some(.black, .some(.red, .some(.red, a, x, b), y, c), z, d): return result(a, x, b, y, c, z, d)
      case let .some(.black, .some(.red, a, x, .some(.red, b, y, c)), z, d): return result(a, x, b, y, c, z, d)
      case let .some(.black, a, x, .some(.red, .some(.red, b, y, c), z, d)): return result(a, x, b, y, c, z, d)
      case let .some(.black, a, x, .some(.red, b, y, .some(.red, c, z, d))): return result(a, x, b, y, c, z, d)
      default:                                                               return node
    }

  }

  /**
  Replace an element in the tree

  - parameter element1: Element
  - parameter element2: Element
  */
  public mutating func replace(_ element1: Element, with element2: Element) {
    var elements = Array(self)
    guard let idx = elements.firstIndex(of: element1) else { return }
    elements[idx] = element2
    self = Tree(elements)
  }

  /**
  Replace some elements with some other elements

  - parameter elements1: S1
  - parameter elements2: S2
  */
  public mutating func replace<S1:Sequence, S2:Sequence>(_ elements1: S1, with elements2: S2)
    where S1.Iterator.Element == Element, S2.Iterator.Element == Element
  {
    self = Tree(filter({!elements1.contains($0)}) + Array(elements2))
  }

  /**
  Remove an element from the tree

  - parameter element: Element
  */
  public mutating func remove(_ element: Element) {
    // TODO: Remove without using an Array
    var elements = Array(self)
    guard let idx = elements.firstIndex(of: element) else { return }
    elements.remove(at: idx)
    self = Tree(elements)
  }

  /**
  Remove some elements from the tree

  - parameter elements: S
  */
  public mutating func remove<S:Sequence>(_ elements: S) where S.Iterator.Element == Element {
    self = Tree(filter({!elements.contains($0)}))
  }

  /**
  Add some elements to the tree

  - parameter elements: S
  */
  public mutating func insert<S:Sequence>(_ elements: S) where S.Iterator.Element == Element {
    elements.forEach({insert($0)})
  }

  /**
  Add an element to the tree

  - parameter element: Element

  - returns: Tree
  */
  public mutating func insert(_ element: Element) {

    /**
    Helper to handle recursive balancing

    - parameter element: Element
    - parameter root: Tree<Element>

    - returns: Tree<Element>
    */
    func insert(_ element: Element, into root: Node<Element>) -> Node<Element> {
      switch root {
        case .none:
          return .some(.red, .none, element, .none)
        case let .some(color, left, value, right) where element < value:
          return balance(.some(color, insert(element, into: left), value, right))
        case let .some(color, left, value, right) where element > value:
          return balance(.some(color, left, value, insert(element, into: right)))
        default:
          return root
      }
    }

    guard case let .some(_, left, value, right) = insert(element, into: root) else {
      fatalError("insert should never return an empty tree")
    }

    root = .some(.black, left, value, right)
  }

  /** 
  Find an element in the tree using the specified comparator closures
  
  - parameter isOrderedBefore: (Element) -> Bool
  - parameter predicate: (Element) -> Bool
  
  - returns: Element?
  */
  public func find(_ isOrderedBefore: (Element) -> Bool, _ predicate: (Element) -> Bool) -> Element? {
    return find(root, isOrderedBefore: isOrderedBefore, predicate: predicate)
  }

  /**
   findNearestNotGreaterThan:

   - parameter value: Element

    - returns: Element?
  */
  public func findNearestNotGreaterThan(_ value: Element) -> Element? {
    return findNearestNotGreaterThan({$0 < value}, {$0 == value})
  }


  /**
   findNearestNotGreaterThan:predicate:

   - parameter isOrderedBefore: (Element) -> Bool
   - parameter predicate: (Element) -> Bool

    - returns: Element?
  */
  public func findNearestNotGreaterThan(_ isOrderedBefore: (Element) -> Bool,
                                  _ predicate: (Element) -> Bool) -> Element?
  {
    return find(root, options: .nearestNotGreaterThan, isOrderedBefore: isOrderedBefore, predicate: predicate)
  }

  /**
   findNearestNotLessThan:

   - parameter value: Element

    - returns: Element?
  */
  public func findNearestNotLessThan(_ value: Element) -> Element? {
    return findNearestNotLessThan({$0 < value}, {$0 == value})
  }

  /**
   findNearestNotLessThan:predicate:

   - parameter isOrderedBefore: (Element) -> Bool
   - parameter predicate: (Element) -> Bool

    - returns: Element?
  */
  public func findNearestNotLessThan(_ isOrderedBefore: (Element) -> Bool,
                                   _ predicate: (Element) -> Bool) -> Element?
  {
    return find(root, options: .nearestNotLessThan, isOrderedBefore: isOrderedBefore, predicate: predicate)
  }

  /**
   find:isOrderedBefore:predicate:

   - parameter node: Node<Element>
   - parameter isOrderedBefore: (Element) -> Bool
   - parameter predicate: (Element) -> Bool

    - returns: Element?
  */
  fileprivate func find(_ node: Node<Element>,
            options: FindOptions = .default,
      possibleMatch: Element? = nil,
    isOrderedBefore: (Element) -> Bool,
          predicate: (Element) -> Bool) -> Element?
  {
    switch node {

      // The node's value satisfies the predicate
      case let .some(_, _, value, _) where predicate(value):
        return value

      // The node's value is greater than desired without a left child and options specify nearest not less than
      case let .some(_, .none, value, _) where !isOrderedBefore(value) && options == .nearestNotLessThan:
        return value

      // The node's value is greater than desired
      case let .some(_, left, value, _) where !isOrderedBefore(value):
        return find(left,
            options: options,
      possibleMatch: options == .nearestNotLessThan ? value : possibleMatch,
    isOrderedBefore: isOrderedBefore,
          predicate: predicate)

      // The node's value is less than desired without a right child and options specify nearest not greater
      case let .some(_, _, value, .none) where isOrderedBefore(value) && options == .nearestNotGreaterThan:
        return value

      // The node's value is less than desired
      case let .some(_, _, value, right) where isOrderedBefore(value):
        return find(right,
            options: options,
      possibleMatch: options == .nearestNotGreaterThan ? value : possibleMatch,
    isOrderedBefore: isOrderedBefore,
          predicate: predicate)

      // Leaf
      default:
        return possibleMatch
    }
  }

  /**
  Remove all elements after the specified element

  - parameter element: Element
  */
  public mutating func dropAfter(_ element: Element) {
    let elements = Array(self)
    guard let idx = elements.firstIndex(of: element) else { return }
    self = Tree(elements[elements.startIndex ... idx])
  }

  /**
  Remove all elements before the specified element

  - parameter element: Element
  */
  public mutating func dropBefore(_ element: Element) {
    let elements = Array(self)
    guard let idx = elements.firstIndex(of: element) else { return }
    self = Tree(elements[idx ..< elements.endIndex])
  }

}

// MARK: - SequenceType
extension Tree: Sequence {

  /**
  Create a generator for an in-order traversal

  - returns: AnyGenerator<Element>
  */
  public func makeIterator() -> AnyIterator<Element> {
    // stack-based iterative inorder traversal to make it easy to use with anyGenerator
    var stack: [Node<Element>] = []
    var current: Node<Element> = root
    return AnyIterator { 
      repeat {
        switch current {
          case .some(_, let left, _, _): 
            stack.append(current); current = left
          case .none where !stack.isEmpty:
            guard case let .some(_, _, value, right) = stack.removeLast() else { break }
            current = right
            return value
          case .none: 
            return nil
        }
      } while true
    }
  }

  /**
  The tree is already sorted so return it converted to an array

  - returns: [Element]
  */
  public func sort() -> [Element] { return Array(self) }

}

// MARK: - ArrayLiteralConvertible
extension Tree: ExpressibleByArrayLiteral {

  /**
  Create a tree from an array literal

  - parameter elements: Element...
  */
  public init(arrayLiteral elements: Element...) { self.init(elements) }

}

// MARK: - CustomStringConvertible
extension Tree: CustomStringConvertible {
  /// Array-like tree description
  public var description: String { return "[" + ", ".join(Array(self).map({String(describing: $0)})) + "]" }
}

// MARK: - CustomDebugStringConvertible
extension Tree: CustomDebugStringConvertible {

  /// A more visually tree-like description
  public var debugDescription: String {
    var result = ""
    func describeNode(_ node: Node<Element>, _ height: Int, _ kind: String ) {
        let indent = "  " * height
      let heightString = "[" + String(height).padded(to: 2, alignment: .left, padCharacter: " ") + "\(kind)]"
      switch node {
        case .none:
          result += "\(indent)\(heightString) <\(Color.black)> nil\n"
        case let .some(color, left, value, right):
          result += "\(indent)\(heightString) <\(color)> \(value)\n"
          describeNode(left,  height + 1, "L")
          describeNode(right, height + 1, "R")
      }
    }

    describeNode(root, 0, " ")
    return result
  }
}
