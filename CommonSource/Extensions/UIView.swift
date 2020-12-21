//
//  UIView.swift
//  MoonKit
//
//  Created by Jason Cardwell on 10/14/14.
//  Copyright (c) 2014 Jason Cardwell. All rights reserved.
//

import Foundation
import UIKit

private var identifierKey: Void?

public extension UIView {


  var firstResponder: UIView? {
    var stop = false
    var responder: UIView?
    func findFirstResponder(_ view: UIView) {
      if !stop && view.isFirstResponder { stop = true; responder = view }
      else if !stop { view.subviews.forEach({findFirstResponder($0)}) }
    }
    findFirstResponder(self)
    return responder
  }

  @IBInspectable var identifier: String? {
    get { return objc_getAssociatedObject(self, &identifierKey) as? String ?? accessibilityIdentifier }
    set { objc_setAssociatedObject(self, &identifierKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC) }
  }

  var snapshot: UIImage {
    UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
    drawHierarchy(in: bounds, afterScreenUpdates: false)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image!
  }

  // MARK: - Initializers

  convenience init(autolayout: Bool) {
    self.init(frame: CGRect.zero)
    translatesAutoresizingMaskIntoConstraints = !autolayout
  }

  // MARK: - Descriptions

  func recursiveConstraintsDescription() -> String {
    var result = ""
    if let identifier = identifier {
      result += "<\(type(of: self).self)(\(identifier)):\(String(addressOf: self))>"
    } else {
      result += "<\(type(of: self).self):\(String(addressOf: self))>"
    }
    result += " {\n\t"
    result += "\n\t".join(constraints.map { $0.prettyDescription })
    let subviewsConstraints = subviews.map { $0.recursiveConstraintsDescription().indented(by: 8) }
    if subviewsConstraints.count > 0 { result += "\n" + "\n".join(subviewsConstraints) }
    result += "\n}"
    return result
  }

  // MARK: - Subscripts

  subscript(nametag: String) -> UIView? { return subviews.first(where: {$0.identifier == nametag}) }

  // MARK: - Ancestors

  func isStrictDescendent(of view: UIView) -> Bool { return isDescendant(of: view) && self !== view }

  func nearestCommonAncestorWithView(_ view: UIView?) -> UIView? {
    guard let view = view, view !== self else { return self }
    var ancestor: UIView? = nil
    var ancestors = Set<UIView>()
    var v: UIView? = self
    while v != nil { ancestors.insert(v!); v = v!.superview }
    v = view
    while v != nil { if ancestors.contains(v!) { ancestor = v; break } else { v = v!.superview } }
    return ancestor
  }

/*
   // MARK: - Subviews

  public func subviewsOfKind<T:UIView>(_ kind: T.Type) -> [T] { return subviews.flatMap({$0 as? T}) }

  public func firstSubviewOfKind<T:UIView>(_ kind: T.Type) -> T? {
    return subviews.first(where: {$0 as? T != nil}) as? T
  }

  public func subviewsOfType<T:UIView>(_ type: T.Type) -> [T] {
    let filtered = subviews.filter { (s:AnyObject) -> Bool in return type(of: s).self === T.self }
    return filtered.map {$0 as! T}
  }

  public func firstSubviewOfType<T:UIView>(_ type: T.Type) -> T? {
    return subviews.first(where: {(s:AnyObject) -> Bool in return type(of: s).self === T.self}) as? T
  }

  @objc(subviewsMatchingPredicate:)
  public func subviewsMatching(_ predicate: NSPredicate) -> [UIView] {
    return subviews.filter({(s:AnyObject) -> Bool in return predicate.evaluate(with: s)}) as [UIView]
  }

  @objc(firstSubviewMatchingPredicate:)
  public func firstSubviewMatching(_ predicate: NSPredicate) -> UIView? {
    return subviews.first(where: {predicate.evaluate(with: $0)})
  }

  public func subviewsMatching(_ predicate: (AnyObject) -> Bool) -> [UIView] {
    return subviews.filter(predicate) as [UIView]
  }

  public func firstSubviewMatching(_ predicate: (AnyObject) -> Bool) -> UIView? {
    return subviews.first(where: predicate)
  }

  public func subviewsWithIdentifier(_ id: String) -> [UIView] {
    return subviewsMatching(∀"self.identifier == '\(id)'")
  }

  public func subviewsWithIdentiferPrefix(_ prefix: String) -> [UIView] {
    return subviewsMatching(∀"self.identifier beginsWith '\(prefix)'")
  }

  public func subviewsWithIdentiferSuffix(_ suffix: String) -> [UIView] {
    return subviewsMatching(∀"self.identifier endsWith '\(suffix)'")
  }
*/

  // MARK: - Existing constraints

  /// Returns all elements in `constraints` with `identifier`.
  func constraints(withIdentifier identifier: Identifier) -> [NSLayoutConstraint] {
    return constraints.filter { $0.identifier == identifier.string }
  }

  /// Returns the first element in `constraints` with `identifier` or nil.
  func constraint(withIdentifier identifier: Identifier) -> NSLayoutConstraint? {
    return constraints.first { $0.identifier == identifier.string }
  }

  /// Returns all elements in `constraints` whose identifier property has prefix `identifier`.
  func constraints(withIdentifierPrefix identifier: Identifier) -> [NSLayoutConstraint] {
    return constraints.filter { [identifierString = identifier.string] in
      $0.identifier?.hasPrefix(identifierString) == true
    }
  }

  /// Returns the first element in `constraints` whose identifier property has prefix `identifier` or nil.
  func constraint(withIdentifierPrefix identifier: Identifier) -> NSLayoutConstraint? {
    return constraints.first { [identifierString = identifier.string] in
      $0.identifier?.hasPrefix(identifierString) == true
    }
  }

  /// Returns all elements in `constraints` whose identifier property has suffix `identifier`.
  func constraints(withIdentifierSuffix identifier: Identifier) -> [NSLayoutConstraint] {
    return constraints.filter { [identifierString = identifier.string] in
      $0.identifier?.hasSuffix(identifierString) == true
    }
  }

  /// Returns the first element in `constraints` whose identifier property has suffix `identifier` or nil.
  func constraint(withIdentifierSuffix identifier: Identifier) -> NSLayoutConstraint? {
    return constraints.first { [identifierString = identifier.string] in
      $0.identifier?.hasSuffix(identifierString) == true
    }
  }

  // MARK: - Adding constraints

  @discardableResult
  func constrain(identifier: Identifier? = nil,
                        _ pseudoConstraints: PseudoConstraint...) -> [NSLayoutConstraint]
  {
    return _constrain(identifier: identifier, pseudoConstraints: pseudoConstraints)
  }

  @discardableResult
  func constrain(identifier: Identifier? = nil,
                        _ builders: PseudoConstraint.Builder...) -> [NSLayoutConstraint]
  {
    return _constrain(identifier: identifier,
                      pseudoConstraints: Array(builders.map({$0.constraints}).joined()))
  }

  /// Method that actually processes the pseudo constraints into layout constraints.
  private func _constrain(identifier: Identifier?,
                          pseudoConstraints: [PseudoConstraint]) -> [NSLayoutConstraint]
  {
    var constraints: [PseudoConstraint] = pseudoConstraints

    // Process the constraints to make sure the deepest ancestor is the view

    var deepestAncestor: UIView?
    for constraint in constraints {
      switch (constraint.nearestCommonAncestor, deepestAncestor) {

        case let (ancestor?, nil):
          deepestAncestor = ancestor

        case let (ancestor?, currentDeepestAncestor?)
          where !ancestor.isDescendant(of: currentDeepestAncestor):
          guard let newDeepestAncestor = ancestor.nearestCommonAncestorWithView(currentDeepestAncestor) else {
            fatalError("Views must share a common ancestor")
          }
          deepestAncestor = newDeepestAncestor

        default:
          break

      }

    }

    // If `deepestAncestor` is nil then most likely the array was empty, return an empty array just to be safe
    if deepestAncestor == nil { return [] }

      // Check if we are not the ancestor but the ancestor descends from us, if so then replace ancestor with self
      // unless both the first and second objects are the ancestor
    else if let ancestor = deepestAncestor, self != ancestor && ancestor.isDescendant(of: self) {
      constraints = constraints.map {
        var constraint = $0
        if constraint.firstObject?.value === ancestor && constraint.secondObject?.value !== ancestor {
          constraint.firstObject = .view(self)
        } else if constraint.secondObject?.value === ancestor && constraint.firstObject?.value !== ancestor {
          constraint.secondObject = .view(self)
        }
        return constraint
      }
    }


    let result = constraints.flatMap({$0.expanded}).compactMap({$0.constraint})
    if let identifier = identifier { result.forEach { $0.identifier = identifier.string } }
    NSLayoutConstraint.activate(result)
    return result
  }

  // MARK: Insetting

  @discardableResult
  func inset(subview: UIView,
                    using insets: UIEdgeInsets,
                    identifier: Identifier? = nil) -> [NSLayoutConstraint]
  {
    guard subview.isDescendant(of: self) && subview !== self else {
      fatalError("\(#function) requires that `subview ∈ subviews`.")
    }
    return constrain(identifier: identifier,
                     𝗩∶|-insets.top-[subview]-insets.bottom-|,
                     𝗛∶|-insets.left-[subview]-insets.right-|)
  }

}
