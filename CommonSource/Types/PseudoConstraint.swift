//
//  PseudoConstraint.swift
//  MoonKit
//
//  Created by Jason Cardwell on 11/25/14.
//  Copyright (c) 2014 Jason Cardwell. All rights reserved.
//

import Foundation
import UIKit

public let 𝗩 = NSLayoutConstraint.Axis.vertical
public let 𝗛 = NSLayoutConstraint.Axis.horizontal

/// Operator examples:
///
///   𝗛∶|-[a]-|
///   𝗩∶|-≥20-[r]-[g]-[b]-[a]-≥20-|
///   formView.width ≤ (parent.bounds.width - 20)  --> id
///   first.top == self.top + 10.0
///   valueLabel.centerY == self.centerY + valueLabelOffset.vertical
public struct PseudoConstraint: Equatable, CustomStringConvertible, CustomDebugStringConvertible {

  /// The name used for the first object when describing the constraint.
  public var firstItem: String?

  /// The constraint's first object. Setting this property updates the value of `firstItem`.
  public var firstObject: ObjectValue? { didSet { updateFirstItem() } }

  /// The constraint's first attribute.
  public var firstAttribute: Attribute = .notAnAttribute

  /// The constraint's relation, default is `.equal`.
  public var relation: Relation = .equal

  /// The name used for the second object when describing the constraint.
  public var secondItem: String?

  /// The constraint's second object. Setting this property updates the value of `secondItem`.
  public var secondObject: ObjectValue? { didSet { updateSecondItem() } }

  /// The constraint's second attribute, default is `.notAnAttribute`.
  public var secondAttribute: Attribute = .notAnAttribute

  /// The constraint's constant.
  public var constant: Float = 0

  /// The constraint's multiplier.
  public var multiplier: Float = 1

  /// The constraint's priority, default is `UILayoutPriorityRequired`.
  public var priority: UILayoutPriority = UILayoutPriority.required

  /// The constraint's identifier.
  public var identifier: String?
  
  /// Updates `firstItem` by deriving a value from `firstObject`.
  private mutating func updateFirstItem() {

    guard firstItem == nil else { return }

    switch firstObject?.value {
      case let object as Named:
        firstItem = itemName(from: object.name)
      case let object as UIView where object.identifier != nil:
        firstItem = itemName(from: object.identifier)
      case let object as UILayoutGuide:
        firstItem = itemName(from: object.identifier)
      case .some:
        firstItem = "item1"
      default:
        break
    }

  }

  /// Updates `secondItem` by deriving a value from `secondObject`.
  private mutating func updateSecondItem() {

    guard secondItem == nil else { return }

    switch secondObject?.value {
      case let object as Named:
        secondItem = itemName(from: object.name)
      case let object as UIView where object.identifier != nil:
        secondItem = itemName(from: object.identifier)
      case let object as UILayoutGuide:
        secondItem = itemName(from: object.identifier)
      case .some:
        secondItem = "item2"
      default:
        break
    }

  }

  /// The view represented by `firstObject` or `nil`.
  public var firstView: UIView? {
    switch firstObject?.value {
      case let view as UIView: return view
      case let guide as UILayoutGuide: return guide.owningView
      default: return nil
    }
  }

  /// The view represented by `secondObject` or `nil`.
  public var secondView: UIView? {
    switch secondObject?.value {
      case let view as UIView: return view
      case let guide as UILayoutGuide: return guide.owningView
      default: return nil
    }
  }

  /// The nearest common ancestor of the constraint's views.
  public var nearestCommonAncestor: UIView? { return firstView?.nearestCommonAncestorWithView(secondView) }

  /// Generates an appropriate item name from `string` by replacing whitespace with '_' and ignoring any
  /// other non-alphanumeric characters.
  private func itemName(from string: String?) -> String? {

    guard let string = string else { return nil }

    var result = ""

    for u in string {

      if u.isWhitespace { result.append("_") }
      else if u.isLetter || u.isWholeNumber { result.append(u) }

    }

    return result.isEmpty ? nil : String(result)
  }

  /// Whether the pseudo constraint can actually be turned into an `NSLayoutConstraint` object
  public var validConstraint: Bool {
    return firstObject != nil
        && firstAttribute != .notAnAttribute
        && !expandable
        && (secondObject == nil || secondAttribute != .notAnAttribute)
  }

  /// Whether the pseudo constraint forms a valid 'pseudo' representation of a constraint
  public var validPseudo: Bool {
    return firstItem != nil
        && firstAttribute != .notAnAttribute
        && !expandable
        && (secondItem == nil || secondAttribute != .notAnAttribute)
  }

  /// Returns the array of `PseudoConstraint` objects by expanding a compatible attribute, 
  /// i.e. 'center' → 'centerX', 'centerY'
  public var expanded: [PseudoConstraint] {
    switch (firstAttribute, secondAttribute) {
      case (.center, .center):
        var x = self; x.firstAttribute = .centerX; x.secondAttribute = .centerX
        var y = self; y.firstAttribute = .centerY; y.secondAttribute = .centerY
        return [x, y]
      case (.centerWithinMargins, .centerWithinMargins):
        var x = self; x.firstAttribute = .centerXWithinMargins; x.secondAttribute = .centerXWithinMargins
        var y = self; y.firstAttribute = .centerYWithinMargins; y.secondAttribute = .centerYWithinMargins
        return [x, y]
      case (.size, .size):
        var w = self; w.firstAttribute = .width; w.secondAttribute = .width
        var h = self; h.firstAttribute = .height; h.secondAttribute = .height
        return [w, h]
      default:
        return [self]
    }
  }

  /// Whether the `PseudoConstraint` is expansion compatible
  public var expandable: Bool {
    return firstAttribute == secondAttribute
        && (([.center, .size, .centerWithinMargins] as Set).contains(firstAttribute))
  }

  /// Initialize with the specified property values.
  public init(firstItem: String? = nil,
              firstObject: ObjectValue? = nil,
              firstAttribute: Attribute = .notAnAttribute,
              relation: Relation = .equal,
              secondItem: String? = nil,
              secondObject: ObjectValue? = nil,
              secondAttribute: Attribute = .notAnAttribute,
              multiplier: Float = 1.0,
              constant: Float = 0.0,
              priority: UILayoutPriority = UILayoutPriority.required,
              identifier: String? = nil)
  {
    self.firstItem       = firstItem
    self.firstObject     = firstObject
    self.firstAttribute  = firstAttribute
    self.relation        = relation
    self.secondItem      = secondItem
    self.secondObject    = secondObject
    self.secondAttribute = secondAttribute
    self.multiplier      = multiplier
    self.constant        = constant
    self.priority        = priority
    self.identifier      = identifier
    updateFirstItem()
    updateSecondItem()
  }

  /// Initialize from a string containing an extended visual format.
  public init?(_ format: String) {

    let name = "([\\p{L}$_][\\w]*)"
    let attributes = "|".join("(?:left|right|leading|trailing)(?:Margin)?",
                              "(?:top|bottom)(?:Margin)?",
                              "width",
                              "height",
                              "size",
                              "(?:center[XY]?)(?:WithinMargins)?",
                              "(?:firstB|b)aseline")
    let attribute = "(\(attributes))"
    let item = "\(name)\\.\(attribute)"
    let number = "((?:[-+] *)?\\p{N}+(?:\\.\\p{N}+)?)"
    let m = "(?: *[x*] *\(number))"
    let relatedBy = " *([=≥≤]) *"
    let p = "(?:@ *\(number))"
    let id = "(?:'([\\w ]+)' *)"
    let pattern = "^ *\(id)?\(item)\(relatedBy)(?:\(item)\(m)?)? *\(number)? *\(p)? *$"
    let regex = ~/pattern

    guard let match = regex.firstMatch(in: format) else { return nil }

    for case let .some(capture) in match.captures {
      switch capture.group {
        case 1: identifier = String(capture.substring)
        case 2: firstItem = String(capture.substring)
        case 3: guard let a = Attribute(rawValue: String(capture.substring)) else { return nil }; firstAttribute = a
        case 4: guard let r = Relation(rawValue: String(capture.substring)) else { return nil }; relation = r
        case 5: secondItem = String(capture.substring)
        case 6: guard let a = Attribute(rawValue: String(capture.substring)) else { return nil }; secondAttribute = a
        case 7: guard let m = Float(String(capture.substring)) else { return nil }; multiplier = m
        case 8: guard let c = Float(String(capture.substring)) else { return nil }; constant = c
        case 9: guard let p = Float(String(capture.substring)) else { return nil }; priority = UILayoutPriority(rawValue: p)
        default: assert(false, "should be unreachable")
      }
    }

  }

  /// Initialize from an instance of `NSLayoutConstraint`.
  public init(_ constraint: NSLayoutConstraint) {
    identifier      = constraint.identifier
    firstObject     = ObjectValue(constraint.firstItem)
    updateFirstItem()
    firstAttribute  = Attribute(constraint.firstAttribute)
    relation        = Relation(constraint.relation)
    secondObject    = ObjectValue(constraint.secondItem)
    updateSecondItem()
    secondAttribute = Attribute(constraint.secondAttribute)
    multiplier      = Float(constraint.multiplier)
    constant        = Float(constraint.constant)
    priority        = constraint.priority
  }

  public static func pseudoConstraintsByParsingFormat(_ format: String) -> [PseudoConstraint] {
    return Array(NSLayoutConstraint.splitFormat(format).compactMap({PseudoConstraint($0)?.expanded}).joined())
  }

  /// Derived `NSLayoutConstraint` using the current pseudo values.
  public var constraint: NSLayoutConstraint? {
    guard validConstraint else { return nil }

    let constraint = NSLayoutConstraint(item:       firstObject!.value,
                                        attribute:  firstAttribute.NSLayoutAttributeValue,
                                        relatedBy:  relation.NSLayoutRelationValue,
                                        toItem:     secondObject?.value,
                                        attribute:  secondAttribute.NSLayoutAttributeValue,
                                        multiplier: CGFloat(multiplier),
                                        constant:   CGFloat(constant))
    constraint.priority   = priority
    constraint.identifier = identifier
    return constraint
  }

  /// The `NSLayoutConstraint` obtained via `constraint` with `isActive == true` when non-nil.
  public var activeConstraint: NSLayoutConstraint? {
    guard let constraint = constraint else { return nil }
    constraint.isActive = true
    return constraint
  }

  /// Equatable compliance.
  public static func ==(lhs: PseudoConstraint, rhs: PseudoConstraint) -> Bool {
    return lhs.firstItem == rhs.firstItem
        && lhs.firstObject?.value === rhs.firstObject?.value
        && lhs.firstAttribute == rhs.firstAttribute
        && lhs.secondItem == rhs.secondItem
        && lhs.secondObject?.value === rhs.secondObject?.value
        && lhs.secondAttribute == rhs.secondAttribute
        && lhs.identifier == rhs.identifier
        && lhs.multiplier == rhs.multiplier
        && lhs.constant == rhs.constant
        && lhs.priority == rhs.priority
  }

  public static func !(lhs: PseudoConstraint, rhs: Float) -> PseudoConstraint {
    var lhs = lhs
    lhs.priority = min(UILayoutPriority(rawValue: rhs), UILayoutPriority.required)
    return lhs
  }

  public static func *(lhs: PseudoConstraint, rhs: Float) -> PseudoConstraint {
    var lhs = lhs
    lhs.multiplier = rhs
    return lhs
  }


  public static func +(lhs: PseudoConstraint, rhs: Float) -> PseudoConstraint {
    var lhs = lhs
    lhs.constant = rhs
    return lhs
  }

  public static func -(lhs: PseudoConstraint, rhs: Float) -> PseudoConstraint {
    var lhs = lhs
    lhs.constant = -rhs
    return lhs
  }

  public static func !(lhs: PseudoConstraint, rhs: CGFloat) -> PseudoConstraint {
    return lhs ! Float(rhs)
  }

  public static func *(lhs: PseudoConstraint, rhs: CGFloat) -> PseudoConstraint {
    return lhs * Float(rhs)
  }

  public static func +(lhs: PseudoConstraint, rhs: CGFloat) -> PseudoConstraint {
    return lhs + Float(rhs)
  }

  public static func -(lhs: PseudoConstraint, rhs: CGFloat) -> PseudoConstraint {
    return lhs - Float(rhs)
  }

  public static func !(lhs: PseudoConstraint, rhs: Double) -> PseudoConstraint {
    return lhs ! Float(rhs)
  }

  public static func *(lhs: PseudoConstraint, rhs: Double) -> PseudoConstraint {
    return lhs * Float(rhs)
  }

  public static func +(lhs: PseudoConstraint, rhs: Double) -> PseudoConstraint {
    return lhs + Float(rhs)
  }

  public static func -(lhs: PseudoConstraint, rhs: Double) -> PseudoConstraint {
    return lhs - Float(rhs)
  }

  public static func !(lhs: PseudoConstraint, rhs: Int) -> PseudoConstraint {
    return lhs ! Float(rhs)
  }

  public static func *(lhs: PseudoConstraint, rhs: Int) -> PseudoConstraint {
    return lhs * Float(rhs)
  }

  public static func +(lhs: PseudoConstraint, rhs: Int) -> PseudoConstraint {
    return lhs + Float(rhs)
  }

  public static func -(lhs: PseudoConstraint, rhs: Int) -> PseudoConstraint {
    return lhs - Float(rhs)
  }
  
  public var description: String {
    if !validPseudo { return "pseudo invalid" }

    var result = ""
    if let i = identifier { result += "'\(i)' " }

    let firstItemString: String

    if let f = firstItem { firstItemString = f }
    else if let f = firstObject as? Named { firstItemString = f.name.camelCaseString }
    else { firstItemString = "firstItem" }

    result += "\(firstItemString).\(firstAttribute.rawValue) \(relation.rawValue)"

    if secondAttribute != .notAnAttribute {
      let secondItemString: String
      if let s = secondItem { secondItemString = s }
      else if let s = secondObject as? Named { secondItemString = s.name.camelCaseString }
      else { secondItemString = "secondItem" }
      result += " \(secondItemString).\(secondAttribute.rawValue)"
    }

    if multiplier != 1.0 { result += " x \(multiplier)" }

    if constant != 0.0 {
      let sign = (constant.sign == .minus ? "-" : "+")
      result += " \(sign) \(abs(constant))"
    }
    if priority != UILayoutPriority.required { result += " @\(priority)" }

    return result
  }

  public var debugDescription: String {
    var result = "PseudoConstraint (\(description)) {\n"
    result += "  firstItem: \(firstItem ?? "nil")\n"
    result += "  firstObject: \(firstObject?.description ?? "nil")\n"
    result += "  secondItem: \(secondItem ?? "nil")\n"
    result += "  secondObject: \(secondObject?.description ?? "nil")\n"
    result += "  firstAttribute: \(firstAttribute.rawValue)\n"
    result += "  secondAttribute: \(secondAttribute.rawValue)\n"
    result += "  relation: \(relation.rawValue)\n"
    result += "  multiplier: \(multiplier)\n"
    result += "  constant: \(constant)\n"
    result += "  identifier: \(String(describing: identifier))\n"
    result += "  priority: \(priority)\n"
    result += "}"
    return result
  }
  
  public enum Attribute: String, Equatable {
    case left                 = "left"
    case right                = "right"
    case leading              = "leading"
    case trailing             = "trailing"
    case top                  = "top"
    case bottom               = "bottom"
    case size                 = "size"
    case width                = "width"
    case height               = "height"
    case center               = "center"
    case centerX              = "centerX"
    case centerY              = "centerY"
    case baseline             = "baseline"
    case firstBaseline        = "firstBaseline"
    case leftMargin           = "leftMargin"
    case rightMargin          = "rightMargin"
    case leadingMargin        = "leadingMargin"
    case trailingMargin       = "trailingMargin"
    case topMargin            = "topMargin"
    case bottomMargin         = "bottomMargin"
    case centerWithinMargins  = "centerWithinMargins"
    case centerXWithinMargins = "centerXWithinMargins"
    case centerYWithinMargins = "centerYWithinMargins"
    case notAnAttribute       = ""

    public static func ==(lhs: Attribute, rhs: Attribute) -> Bool {
      switch (lhs, rhs) {
        case (.left, .left),
             (.right, .right),
             (.leading, .leading),
             (.trailing, .trailing),
             (.top, .top),
             (.bottom, .bottom),
             (.size, .size),
             (.width, .width),
             (.height, .height),
             (.center, .center),
             (.centerX, .centerX),
             (.centerY, .centerY),
             (.baseline, .baseline),
             (.firstBaseline, .firstBaseline),
             (.leftMargin, .leftMargin),
             (.rightMargin, .rightMargin),
             (.leadingMargin, .leadingMargin),
             (.trailingMargin, .trailingMargin),
             (.topMargin, .topMargin),
             (.bottomMargin, .bottomMargin),
             (.centerWithinMargins, .centerWithinMargins),
             (.centerXWithinMargins, .centerXWithinMargins),
             (.centerYWithinMargins, .centerYWithinMargins),
             (.notAnAttribute, .notAnAttribute):
           return true
        default: 
           return false       
      }
    }

    public var NSLayoutAttributeValue: NSLayoutConstraint.Attribute {
      switch self {
        case .left:                  return .left
        case .right:                 return .right
        case .leading:               return .leading
        case .trailing:              return .trailing
        case .top:                   return .top
        case .bottom:                return .bottom
        case .size:                  return .notAnAttribute
        case .width:                 return .width
        case .height:                return .height
        case .center:                return .notAnAttribute
        case .centerX:               return .centerX
        case .centerY:               return .centerY
        case .baseline:              return .lastBaseline
        case .firstBaseline:         return .firstBaseline
        case .leftMargin:            return .leftMargin
        case .rightMargin:           return .rightMargin
        case .leadingMargin:         return .leadingMargin
        case .trailingMargin:        return .trailingMargin
        case .topMargin:             return .topMargin
        case .bottomMargin:          return .bottomMargin
        case .centerWithinMargins:   return .notAnAttribute
        case .centerXWithinMargins:  return .centerXWithinMargins
        case .centerYWithinMargins:  return .centerYWithinMargins
        case .notAnAttribute:        return .notAnAttribute
      }
    }

    public var axis: NSLayoutConstraint.Axis { return NSLayoutAttributeValue.axis }

    public init(_ NSLayoutAttributeValue: NSLayoutConstraint.Attribute) {
      switch NSLayoutAttributeValue {
        case .left:                  self = .left
        case .right:                 self = .right
        case .leading:               self = .leading
        case .trailing:              self = .trailing
        case .top:                   self = .top
        case .bottom:                self = .bottom
        case .width:                 self = .width
        case .height:                self = .height
        case .centerX:               self = .centerX
        case .centerY:               self = .centerY
        case .lastBaseline:          self = .baseline
        case .firstBaseline:         self = .firstBaseline
        case .leftMargin:            self = .leftMargin
        case .rightMargin:           self = .rightMargin
        case .leadingMargin:         self = .leadingMargin
        case .trailingMargin:        self = .trailingMargin
        case .topMargin:             self = .topMargin
        case .bottomMargin:          self = .bottomMargin
        case .centerXWithinMargins:  self = .centerXWithinMargins
        case .centerYWithinMargins:  self = .centerYWithinMargins
        default:                     self = .notAnAttribute
      }
    }
    public init(_ NSLayoutAttributeValue: NSLayoutConstraint.Attribute?) {
      if let value = NSLayoutAttributeValue { self.init(value) }
      else { self = .notAnAttribute }
    }
  }

  public enum Relation: String {
    case equal              = "="
    case greaterThanOrEqual = "≥"
    case lessThanOrEqual    = "≤"

    public var NSLayoutRelationValue: NSLayoutConstraint.Relation {
      switch self {
        case .equal:              return .equal
        case .greaterThanOrEqual: return .greaterThanOrEqual
        case .lessThanOrEqual:    return .lessThanOrEqual
      }
    }

    public init(_ NSLayoutRelationValue: NSLayoutConstraint.Relation) {
      switch NSLayoutRelationValue {
        case .greaterThanOrEqual: self = .greaterThanOrEqual
        case .lessThanOrEqual:    self = .lessThanOrEqual
        default:                  self = .equal
      }
    }
  }

  public static func -->(lhs: PseudoConstraint, rhs: String?) ->  PseudoConstraint  {
    var lhs = lhs
    lhs.identifier = rhs
    return lhs
  }

  public static func -->(lhs: PseudoConstraint, rhs: Identifier?) ->  PseudoConstraint  {
    return lhs --> rhs?.string
  }

  public struct ObjectSpacingPair {

    let object: Object?
    let metric: SpacingMetric

    fileprivate init(object: Object?, metric: SpacingMetric) {
      self.object = object
      self.metric = metric
    }

    /// Returns a builder with `lhs` axis that pins `rhs.0` flush to `superview` at the head
    /// and pins `rhs.0` to `superview` at the tail with given metric.
    public static func ∶|(lhs: NSLayoutConstraint.Axis, rhs: ObjectSpacingPair) -> Builder {
      let builder = Builder(axis: lhs)
      builder.pending.metric = ==0
      builder.push(object: rhs.object, location: .head)
      builder.pending.metric = rhs.metric
      builder.push(object: rhs.object, location: .tail)
      return builder
    }

    /// Returns a builder with the specified axis that pins `rhs.0` to `superview` at the head with standard
    /// spacing and pins `rhs.0` to `superview` at the tail with the given metric.
    public static func ∶|-(lhs: NSLayoutConstraint.Axis, rhs: ObjectSpacingPair) -> Builder {
      let builder = Builder(axis: lhs)
      builder.pending.metric = ==20
      builder.push(object: rhs.object, location: .head)
      builder.pending.metric = rhs.metric
      builder.push(object: rhs.object, location: .tail)
      return builder
    }

    /// Returns a builder tail constraining `rhs.0` to `superview` along `lhs` with metric `rhs.1`.
    public static func ∶(lhs: NSLayoutConstraint.Axis, rhs: ObjectSpacingPair) -> Builder {
      let builder = Builder(axis: lhs)
      builder.pending.metric = rhs.metric
      builder.push(object: rhs.object, location: .tail)
      return builder
    }
    
  }

  public struct SpacingMetric: ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral, CustomStringConvertible {

    let value: Float
    let relation: Relation

    init(_ value: Float, _ relation: Relation) {
      self.value = value; self.relation = relation
    }

    public init(integerLiteral value: Int) {
      self.value = Float(value); relation = .equal
    }

    public init(floatLiteral value: Float) {
      self.value = value; relation = .equal
    }

    public var description: String {
      return "{value: \(value), relation: \(relation)}"
    }

    /// Tuples a spacing value for tail pinning, flipping the spacing metric.
    public static postfix func -|(value: SpacingMetric) -> ObjectSpacingPair {
      switch (value.relation, value.value) {
        case (.equal, let value):
          return ObjectSpacingPair(object: nil, metric: SpacingMetric(-value, .equal))
        case (.lessThanOrEqual, let value):
          return ObjectSpacingPair(object: nil, metric: SpacingMetric(-value, .greaterThanOrEqual))
        case (.greaterThanOrEqual, let value):
          return ObjectSpacingPair(object: nil, metric: SpacingMetric(-value, .lessThanOrEqual))
      }
    }

    /// Returns a builder with `lhs` axis with pending metric `==rhs.value` and pending location `.head`.
    public static func ∶|-(lhs: NSLayoutConstraint.Axis, rhs: SpacingMetric) -> Builder {
      let builder = Builder(axis: lhs)
      builder.pending.metric = rhs
      builder.pending.location = .head
      return builder
    }
    
    public static func !(lhs: SpacingMetric, rhs: Float) -> ObjectPredicate {
      return .valueBasedPredicate(lhs, rhs)
    }

    public static func !(lhs: SpacingMetric, rhs: CGFloat) -> ObjectPredicate {
      return lhs ! Float(rhs)
    }

    public static func !(lhs: SpacingMetric, rhs: Double) -> ObjectPredicate {
      return lhs ! Float(rhs)
    }

    public static func !(lhs: SpacingMetric, rhs: Int) -> ObjectPredicate {
      return lhs ! Float(rhs)
    }
    
  }

  public enum ObjectValue: CustomStringConvertible {
    case view (UIView)
    case guide (UILayoutGuide)

    public var value: AnyObject {
      switch self {
        case .view(let value): return value
        case .guide(let value): return value
      }
    }

    public var view: UIView? {
      switch self {
        case .view(let view): return view
        case .guide(let guide): return guide.owningView
      }
    }

    public init(_ view: UIView) { self = .view(view) }
    public init(_ guide: UILayoutGuide) { self = .guide(guide) }

    public init?(_ object: AnyObject?) {
      switch object {
        case let view as UIView: self = .view(view)
        case let guide as UILayoutGuide: self = .guide(guide)
        default: return nil
      }
    }

    public var right:    ObjectValueAttributePair { return ObjectValueAttributePair(self, .right   ) }
    public var left:     ObjectValueAttributePair { return ObjectValueAttributePair(self, .left    ) }
    public var top:      ObjectValueAttributePair { return ObjectValueAttributePair(self, .top     ) }
    public var bottom:   ObjectValueAttributePair { return ObjectValueAttributePair(self, .bottom  ) }
    public var centerX:  ObjectValueAttributePair { return ObjectValueAttributePair(self, .centerX ) }
    public var centerY:  ObjectValueAttributePair { return ObjectValueAttributePair(self, .centerY ) }
    public var width:    ObjectValueAttributePair { return ObjectValueAttributePair(self, .width   ) }
    public var height:   ObjectValueAttributePair { return ObjectValueAttributePair(self, .height  ) }
    public var baseline: ObjectValueAttributePair { return ObjectValueAttributePair(self, .baseline) }
    public var leading:  ObjectValueAttributePair { return ObjectValueAttributePair(self, .leading ) }
    public var trailing: ObjectValueAttributePair { return ObjectValueAttributePair(self, .trailing) }
    
    public var description: String {
      switch self {
        case .view(let view):   return "view(\(String(objectIdentifier: view)))"
        case .guide(let guide): return "guide(\(String(objectIdentifier: guide)))"
      }
    }

    public static func ===(lhs: ObjectValue, rhs: ObjectValue) -> Bool {
      switch (lhs, rhs) {
        case (.view(let view1), .view(let view2)):     return view1 === view2
        case (.guide(let guide1), .guide(let guide2)): return guide1 === guide2
        default:                                       return false
      }
    }

  }

  public enum ObjectPredicate: CustomStringConvertible {
    case viewBasedPredicate (Relation, ObjectValue, Float)
    case valueBasedPredicate (SpacingMetric, Float)

    init?(predicate: Any) {
      switch predicate {
        case let metric as SpacingMetric: self = .valueBasedPredicate(metric, UILayoutPriority.required.rawValue)
        case let objectPredicate as ObjectPredicate: self = objectPredicate
        default: return nil
      }
    }

    public var description: String {
      switch self {
        case .viewBasedPredicate(let relation, let objectValue, let priority):
          return "viewBasedPredicate(\(relation), \(String(objectIdentifier: objectValue.value)), \(priority))"
        case .valueBasedPredicate(let metric, let priority):
          return "valueBasedPredicate(\(metric), \(priority))"
      }

    }
    
    public static func !(lhs: ObjectPredicate, rhs: Float) -> ObjectPredicate {
      switch lhs {
        case .valueBasedPredicate(let metric, _): return .valueBasedPredicate(metric, rhs)
        case .viewBasedPredicate(let relation, let value, _): return .viewBasedPredicate(relation, value, rhs)
      }
    }
    
  }
  
  public struct Object: ExpressibleByArrayLiteral, CustomStringConvertible {

    fileprivate let value: ObjectValue
    fileprivate let predicates: [ObjectPredicate]

    /// Initialize from an array containing a view, optionally followed by metric or predicate instances.
    public init(arrayLiteral elements: Any...) {

      switch elements.first {
        case let view as UIView: value = .view(view)
        case let guide as UILayoutGuide: value = .guide(guide)
        default: fatalError("\(#function) requires `elements[0]` be of type `UIView` or `UILayoutGuide`.")
      }

      var predicates: [ObjectPredicate] = []

      for element in elements[1|->] {

        switch element {

          case let predicate as SpacingMetric:
            predicates.append(.valueBasedPredicate(predicate, UILayoutPriority.required.rawValue))

          case let predicate as ObjectPredicate:
            predicates.append(predicate)

          default:
            fatalError("\(#function) requires any elements after the first to be of type" +
                       " `SpacingMetric` or `ObjectPredicate`.")
        }

      }

      self.predicates = predicates

    }

    /// Tuples the specified object for pinning flush to `superview` tail.
    public static postfix func |(value: Object) -> ObjectSpacingPair {
      return ObjectSpacingPair(object: value, metric: SpacingMetric(0, .equal))
    }

    /// Tuples the specified object for pinning to `superview` tail with standard spacing.
    public static postfix func -|(value: Object) -> ObjectSpacingPair {
      return ObjectSpacingPair(object: value, metric: SpacingMetric(-20, .equal))
    }

    public var description: String {
      return "{value: \(value), predicates: \(predicates)}"
    }
    
    /// Returns a builder with `lhs` axis that pins `rhs` flush to `superview` at the head.
    public static func ∶|(lhs: NSLayoutConstraint.Axis, rhs: Object) -> Builder {
      let builder = Builder(axis: lhs)
      builder.pending.metric = ==0
      builder.push(object: rhs, location: .head)
      return builder
    }
    
    /// Returns a builder with `lhs` axis that pins `rhs` to `superview` at the head with standard spacing.
    public static func ∶|-(lhs: NSLayoutConstraint.Axis, rhs: Object) -> Builder {
      let builder = Builder(axis: lhs)
      builder.pending.metric = ==20
      builder.push(object: rhs, location: .head)
      return builder
    }
    
    /// Returns a builder with the specified axis and a pending view set to `rhs`.
    public static func ∶(lhs: NSLayoutConstraint.Axis, rhs: Object) -> Builder {
      let builder = Builder(axis: lhs)
      builder.pending.value = rhs.value
      builder.appendConstraints(for: rhs.value, with: rhs.predicates)
      return builder
    }
    
  }

  public struct ObjectValueAttributePair: CustomStringConvertible {

    fileprivate let value: ObjectValue
    fileprivate let attribute: Attribute

    fileprivate init(_ value: ObjectValue, _ attribute: Attribute) {
      self.value = value
      self.attribute = attribute
    }

    public var description: String { return "(\(value), \(attribute))" }

    public static func ==(lhs: ObjectValueAttributePair, rhs: ObjectValueAttributePair) -> PseudoConstraint {
      return PseudoConstraint(firstObject: lhs.value,
                              firstAttribute: lhs.attribute,
                              relation: .equal,
                              secondObject: rhs.value,
                              secondAttribute: rhs.attribute)
    }

    public static func >=(lhs: ObjectValueAttributePair, rhs: ObjectValueAttributePair) -> PseudoConstraint {
      return PseudoConstraint(firstObject: lhs.value,
                              firstAttribute: lhs.attribute,
                              relation: .greaterThanOrEqual,
                              secondObject: rhs.value,
                              secondAttribute: rhs.attribute)
    }

    public static func <=(lhs: ObjectValueAttributePair, rhs: ObjectValueAttributePair) -> PseudoConstraint {
      return PseudoConstraint(firstObject: lhs.value,
                              firstAttribute: lhs.attribute,
                              relation: .lessThanOrEqual,
                              secondObject: rhs.value,
                              secondAttribute: rhs.attribute)
    }

    public static func ==(lhs: ObjectValueAttributePair, rhs: PseudoConstraint) -> PseudoConstraint {
      var result = rhs
      result.firstObject = lhs.value
      result.firstAttribute = lhs.attribute
      result.relation = .equal
      return result
    }

    public static func >=(lhs: ObjectValueAttributePair, rhs: PseudoConstraint) -> PseudoConstraint {
      var result = rhs
      result.firstObject = lhs.value
      result.firstAttribute = lhs.attribute
      result.relation = .greaterThanOrEqual
      return result
    }

    public static func <=(lhs: ObjectValueAttributePair, rhs: PseudoConstraint) -> PseudoConstraint {
      var result = rhs
      result.firstObject = lhs.value
      result.firstAttribute = lhs.attribute
      result.relation = .lessThanOrEqual
      return result
    }

    public static func *(lhs: ObjectValueAttributePair, rhs: Float) -> PseudoConstraint {
      return PseudoConstraint(secondObject: lhs.value, secondAttribute: lhs.attribute, multiplier: rhs)
    }

    public static func +(lhs: ObjectValueAttributePair, rhs: Float) -> PseudoConstraint {
      return PseudoConstraint(secondObject: lhs.value, secondAttribute: lhs.attribute, constant: rhs)
    }

    public static func -(lhs: ObjectValueAttributePair, rhs: Float) -> PseudoConstraint {
      return PseudoConstraint(secondObject: lhs.value, secondAttribute: lhs.attribute, constant: -rhs)
    }

    public static func ==(lhs: ObjectValueAttributePair, rhs: Float) -> PseudoConstraint {
      return PseudoConstraint(firstObject: lhs.value,
                              firstAttribute: lhs.attribute,
                              relation: .equal,
                              constant: rhs)
    }

    public static func >=(lhs: ObjectValueAttributePair, rhs: Float) -> PseudoConstraint {
      return PseudoConstraint(firstObject: lhs.value,
                              firstAttribute: lhs.attribute,
                              relation: .greaterThanOrEqual,
                              constant: rhs)
    }

    public static func <=(lhs: ObjectValueAttributePair, rhs: Float) -> PseudoConstraint {
      return PseudoConstraint(firstObject: lhs.value,
                              firstAttribute: lhs.attribute,
                              relation: .lessThanOrEqual,
                              constant: rhs)
    }
    
    public static func *(lhs: ObjectValueAttributePair, rhs: CGFloat) -> PseudoConstraint {
      return lhs * Float(rhs)
    }

    public static func +(lhs: ObjectValueAttributePair, rhs: CGFloat) -> PseudoConstraint {
      return lhs + Float(rhs)
    }

    public static func -(lhs: ObjectValueAttributePair, rhs: CGFloat) -> PseudoConstraint {
      return lhs - Float(rhs)
    }

    public static func ==(lhs: ObjectValueAttributePair, rhs: CGFloat) -> PseudoConstraint {
      return lhs == Float(rhs)
    }

    public static func >=(lhs: ObjectValueAttributePair, rhs: CGFloat) -> PseudoConstraint {
      return lhs >= Float(rhs)
    }

    public static func <=(lhs: ObjectValueAttributePair, rhs: CGFloat) -> PseudoConstraint {
      return lhs <= Float(rhs)
    }
    
    public static func *(lhs: ObjectValueAttributePair, rhs: Double) -> PseudoConstraint {
      return lhs * Float(rhs)
    }

    public static func +(lhs: ObjectValueAttributePair, rhs: Double) -> PseudoConstraint {
      return lhs + Float(rhs)
    }

    public static func -(lhs: ObjectValueAttributePair, rhs: Double) -> PseudoConstraint {
      return lhs - Float(rhs)
    }

    public static func ==(lhs: ObjectValueAttributePair, rhs: Double) -> PseudoConstraint {
      return lhs == Float(rhs)
    }

    public static func >=(lhs: ObjectValueAttributePair, rhs: Double) -> PseudoConstraint {
      return lhs >= Float(rhs)
    }

    public static func <=(lhs: ObjectValueAttributePair, rhs: Double) -> PseudoConstraint {
      return lhs <= Float(rhs)
    }
    
    public static func *(lhs: ObjectValueAttributePair, rhs: Int) -> PseudoConstraint {
      return lhs * Float(rhs)
    }

    public static func +(lhs: ObjectValueAttributePair, rhs: Int) -> PseudoConstraint {
      return lhs + Float(rhs)
    }

    public static func -(lhs: ObjectValueAttributePair, rhs: Int) -> PseudoConstraint {
      return lhs - Float(rhs)
    }

    public static func ==(lhs: ObjectValueAttributePair, rhs: Int) -> PseudoConstraint {
      return lhs == Float(rhs)
    }

    public static func >=(lhs: ObjectValueAttributePair, rhs: Int) -> PseudoConstraint {
      return lhs >= Float(rhs)
    }

    public static func <=(lhs: ObjectValueAttributePair, rhs: Int) -> PseudoConstraint {
      return lhs <= Float(rhs)
    }
    
  }
  
  /// Accumulates `PseudoConstraint` values created via chaining operators.
  public class Builder: CustomStringConvertible {

    /// Controls to which axis created constraints shall be relative.
    private let axis: NSLayoutConstraint.Axis

    /// Greatest common ancestor for constrained views.
    private weak var superview: UIView? {
      didSet {

        // Check whether a head pinning constraint needs updating.
        switch (superview, oldValue) {

          case (let newValue?, let oldValue?)
            where newValue !== oldValue && didPinHead:
            guard var headConstraint = constraints.first else {
              fatalError("Internal inconsistency, failed to retrieve head constraint but `didPinHead == true`.")
            }
            guard let oldAncestor = headConstraint.nearestCommonAncestor else {
              fatalError("Internal inconsistency, failed to retrieve nearest ancestor for head constraint")
            }
            guard newValue !== oldAncestor else { return }
            switch (headConstraint.firstView === oldAncestor, headConstraint.secondView === oldAncestor) {
              case (true, false): headConstraint.firstObject = .view(newValue)
              case (false, true): headConstraint.secondObject = .view(newValue)
              default: fatalError("Internal inconsistency, invalid head constraint")
            }
            constraints[0] = headConstraint

          default:
            return

        }

      }
    }

    public var description: String {
      var result = "Builder {\n"
      result += "  axis: \(axis)\n"
      result += "  superview: \(String(objectIdentifier: superview))\n"
      result += "  constraints: \(constraints.map({$0.description}).joined(separator: "\n               "))"
      result += "\n}"
      return result
    }

    /// Pending values to be used when creating the next constraint.
    fileprivate var pending: (metric: SpacingMetric?, value: ObjectValue?, location: PinLocation?)

    /// Type for specifying alignment to `superview` at the head or tail relative to `axis`.
    public enum PinLocation { case none, head, tail }

    /// Whether the first constraint pins a view to `superview`.
    private var didPinHead = false

    /// Created constrains.
    public private(set) var constraints: [PseudoConstraint] = []

    /// Initialize with an axis.
    fileprivate init(axis: NSLayoutConstraint.Axis) {
      self.axis = axis
      pending = (nil, nil, nil)
    }

    /// Determines whether the constrained views and `view` share a common ancestor. If they do, `superview`
    /// is updated and the function returns `true`. Otherwise, the function returns `false`.
    private func isValid(value: ObjectValue) -> Bool {

      // To be valid the view must be part of a hierarchy.
      guard let view = value.view, view.superview != nil else { return false }

      // Update `superview` by deriving the nearest ancestor common to all constrained views.
      superview = view.superview?.nearestCommonAncestorWithView(constraints.reduce(nil as UIView?) {
        $1.nearestCommonAncestor!.nearestCommonAncestorWithView($0)
      })

      return superview != nil
    }

    /// Creates and appends a constraint for `pair1` and `pair2` with derived relation and constant.
    private func appendConstraint(_ pair1: ObjectValueAttributePair, _ pair2: ObjectValueAttributePair) {

      // Operator to relate `pair1` to `pair2` derived according to `pending.metric` value.
      let relationOperator: (ObjectValueAttributePair, ObjectValueAttributePair) -> PseudoConstraint

      switch pending.metric?.relation {
        case nil, .equal?:         relationOperator = (==)
        case .lessThanOrEqual?:    relationOperator = (<=)
        case .greaterThanOrEqual?: relationOperator = (>=)
      }

      // Use a constant equal to the pending metric value with a default value of `0`.
      let constant: Float = pending.metric?.value ?? 0

      // Create the constraint, appending to `constraints`.
      constraints.append(relationOperator(pair1, pair2) + constant)

    }

    /// Creates and appends a constraint for each element in `predicates` targetting `objectValue`.
    fileprivate func appendConstraints(for objectValue: ObjectValue, with predicates: [ObjectPredicate]) {

      let attribute: Attribute = axis == .vertical ? .height : .width

      for predicate in predicates {
        switch predicate {
          case .valueBasedPredicate(let metric, let priority):
            constraints.append(PseudoConstraint(firstObject: objectValue,
                                                firstAttribute: attribute,
                                                relation: metric.relation,
                                                constant: metric.value,
                                                priority: UILayoutPriority(rawValue: priority)))
          case .viewBasedPredicate(let relation, let relatedValue, let priority):
            constraints.append(PseudoConstraint(firstObject: objectValue,
                                                firstAttribute: attribute,
                                                relation: relation,
                                                secondObject: relatedValue,
                                                secondAttribute: attribute,
                                                priority: UILayoutPriority(rawValue: priority)))
        }
      }

    }

    /// Creates a constraint pinning `view` or `pendingObject` to `superview` according to `location`.
    /// - requires: `!(view == nil && pendingObject == nil)`.
    fileprivate func push(object: Object?, location: PinLocation) {

      // Use `pending.location` if not `nil`.
      let location = pending.location == nil ? location : pending.location!

      let value: ObjectValue, pendingValue = pending.value, previousValue = constraints.last?.firstObject

      switch (object, pendingValue, previousValue) {
        case (.some, nil, nil) where location == .none:
          fatalError("Missing pending or previous view for second item of constraint.")
        case let (object?, _, _):
          value = object.value
          appendConstraints(for: value, with: object.predicates)
        case (nil, let pendingValue?, _):
          value = pendingValue
        case (nil, nil, let previousValue?):
          value = previousValue
        default:
          fatalError("Failed to obtain a valid view.")
      }

      // Ensure we have a view and a superview and that they are not the same view.
      guard isValid(value: value), let superview = superview, superview !== value.view else {
        fatalError("A proper view hierarchy is required.")
      }

      // Derive two view-attribute pairs according to pin location and axis.
      let pair1: ObjectValueAttributePair, pair2: ObjectValueAttributePair

      switch (location, axis) {
        case (.none, .vertical):
          pair1 = value.top
          pair2 = (previousValue ?? pendingValue)!.bottom
        case (.none, .horizontal):
          pair1 = value.left
          pair2 = (previousValue ?? pendingValue)!.right
        case (.head, .vertical):
          pair1 = value.top
          pair2 = superview.top
          didPinHead = true
        case (.head, .horizontal):
          pair1 = value.left
          pair2 = superview.left
          didPinHead = true
        case (.tail, .vertical):
          pair1 = value.bottom
          pair2 = superview.bottom
        case (.tail, .horizontal):
          pair1 = value.right
          pair2 = superview.right
        case (_, _):
          fatalError("\(#fileID) \(#function) Unexpected value for location or axis.")
      }

      // Append a constraint relating the two pairs.
      appendConstraint(pair1, pair2)

      // Clear any pending values.
      pending = (nil, nil, nil)

    }

    /// Sets a pending metric for `lhs` equal to `rhs`.
    public static func -(lhs: Builder, rhs: SpacingMetric) -> Builder {
      lhs.pending.metric = rhs
      return lhs
    }

    /// Sets a pending metric for `lhs` equal to `==rhs`.
    public static func -(lhs: Builder, rhs: Float) -> Builder { return lhs - ==rhs }

    /// Pushes `rhs` into `lhs` to be resolved using pending builder values. If `pending.metric == nil`,
    /// a standard inner-spacing value of `8` is used.
    public static func -(lhs: Builder, rhs: Object) -> Builder {
      if lhs.pending.metric == nil { lhs.pending.metric = ==8 }
      lhs.push(object: rhs, location: .none)
      return lhs
    }

    /// Pushes `rhs.object` into `lhs` to be resolved using pending builder values and then tail aligns 
    /// `rhs.object` using the specified metric when `rhs.object != nil`. If `pending.metric == nil`, a
    /// standard inner-spacing value of `8` is used between the previous object and `rhs.object`.
    /// Otherwise, Tail aligns the first object of the previously created constraint using `rhs.metric`.
    public static func -(lhs: Builder, rhs: ObjectSpacingPair) -> Builder {

      switch rhs.object {

        case let object?:
          // `rhs` provides an object. Check pending meric ➞ push ➞ set pending metric ➞ push

          if lhs.pending.metric == nil { lhs.pending.metric = ==8 }
          lhs.push(object: object, location: .none)
          lhs.pending.metric = rhs.metric
          lhs.push(object: object, location: .tail)

        case nil:
          // `rhs` does not provide an object. Set pending metric ➞ push

          lhs.pending.metric = rhs.metric
          lhs.push(object: nil, location: .tail)

      }

      return lhs

    }

    /// Sets a pending metric for `lhs` equal to `==rhs`.
    public static func -(lhs: Builder, rhs: CGFloat) -> Builder { return lhs - Float(rhs) }

    /// Sets a pending metric for `lhs` equal to `==rhs`.
    public static func -(lhs: Builder, rhs: Double) -> Builder { return lhs - Float(rhs) }

    /// Sets a pending metric for `lhs` equal to `==rhs`.
    public static func -(lhs: Builder, rhs: Int) -> Builder { return lhs - Float(rhs) }

  }
}

extension UIView {

  public typealias ObjectValueAttributePair = PseudoConstraint.ObjectValueAttributePair
  public typealias ObjectPredicate = PseudoConstraint.ObjectPredicate

  public var right:    ObjectValueAttributePair { return ObjectValueAttributePair(.view(self), .right   ) }
  public var left:     ObjectValueAttributePair { return ObjectValueAttributePair(.view(self), .left    ) }
  public var top:      ObjectValueAttributePair { return ObjectValueAttributePair(.view(self), .top     ) }
  public var bottom:   ObjectValueAttributePair { return ObjectValueAttributePair(.view(self), .bottom  ) }
  public var centerX:  ObjectValueAttributePair { return ObjectValueAttributePair(.view(self), .centerX ) }
  public var centerY:  ObjectValueAttributePair { return ObjectValueAttributePair(.view(self), .centerY ) }
  public var width:    ObjectValueAttributePair { return ObjectValueAttributePair(.view(self), .width   ) }
  public var height:   ObjectValueAttributePair { return ObjectValueAttributePair(.view(self), .height  ) }
  public var baseline: ObjectValueAttributePair { return ObjectValueAttributePair(.view(self), .baseline) }
  public var leading:  ObjectValueAttributePair { return ObjectValueAttributePair(.view(self), .leading ) }
  public var trailing: ObjectValueAttributePair { return ObjectValueAttributePair(.view(self), .trailing) }

  public static prefix func ==(value: UIView) -> ObjectPredicate {
    return .viewBasedPredicate(.equal, .view(value), UILayoutPriority.required.rawValue)
  }

  public static prefix func <=(value: UIView) -> ObjectPredicate {
    return .viewBasedPredicate(.lessThanOrEqual, .view(value), UILayoutPriority.required.rawValue)
  }

  public static prefix func >=(value: UIView) -> ObjectPredicate {
    return .viewBasedPredicate(.greaterThanOrEqual, .view(value), UILayoutPriority.required.rawValue)
  }

}

extension UILayoutGuide {

  public typealias ObjectValueAttributePair = PseudoConstraint.ObjectValueAttributePair
  public typealias ObjectPredicate = PseudoConstraint.ObjectPredicate

  public var right:    ObjectValueAttributePair { return ObjectValueAttributePair(.guide(self), .right   ) }
  public var left:     ObjectValueAttributePair { return ObjectValueAttributePair(.guide(self), .left    ) }
  public var top:      ObjectValueAttributePair { return ObjectValueAttributePair(.guide(self), .top     ) }
  public var bottom:   ObjectValueAttributePair { return ObjectValueAttributePair(.guide(self), .bottom  ) }
  public var centerX:  ObjectValueAttributePair { return ObjectValueAttributePair(.guide(self), .centerX ) }
  public var centerY:  ObjectValueAttributePair { return ObjectValueAttributePair(.guide(self), .centerY ) }
  public var width:    ObjectValueAttributePair { return ObjectValueAttributePair(.guide(self), .width   ) }
  public var height:   ObjectValueAttributePair { return ObjectValueAttributePair(.guide(self), .height  ) }
  public var baseline: ObjectValueAttributePair { return ObjectValueAttributePair(.guide(self), .baseline) }
  public var leading:  ObjectValueAttributePair { return ObjectValueAttributePair(.guide(self), .leading ) }
  public var trailing: ObjectValueAttributePair { return ObjectValueAttributePair(.guide(self), .trailing) }

  public static prefix func ==(value: UILayoutGuide) -> ObjectPredicate {
    return .viewBasedPredicate(.equal, .guide(value), UILayoutPriority.required.rawValue)
  }

  public static prefix func <=(value: UILayoutGuide) -> ObjectPredicate {
    return .viewBasedPredicate(.lessThanOrEqual, .guide(value), UILayoutPriority.required.rawValue)
  }

  public static prefix func >=(value: UILayoutGuide) -> ObjectPredicate {
    return .viewBasedPredicate(.greaterThanOrEqual, .guide(value), UILayoutPriority.required.rawValue)
  }

}

extension Float {

  public typealias SpacingMetric = PseudoConstraint.SpacingMetric
  public typealias ObjectSpacingPair = PseudoConstraint.ObjectSpacingPair
  public typealias Builder = PseudoConstraint.Builder

  /// Creates a spacing metric using `value` and `.greaterThanOrEqual`.
  public static prefix func >=(value: Float) -> SpacingMetric {
    return SpacingMetric(value, .greaterThanOrEqual)
  }

  /// Creates a spacing metric using `value` and `.lessThanOrEqual`.
  public static prefix func <=(value: Float) -> SpacingMetric {
    return SpacingMetric(value, .lessThanOrEqual)
  }

  /// Creates a spacing metric using `value` and `.equal`.
  public static prefix func ==(value: Float) -> SpacingMetric {
    return SpacingMetric(value, .equal)
  }

  /// Tuples a spacing value for tail pinning.
  public static postfix func -|(value: Float) -> ObjectSpacingPair {
    return SpacingMetric(value, .equal)-|
  }

  /// Returns a builder with the `lhs` axis with pending metric `==rhs` and pending location `.head`.
  public static func ∶|-(lhs: NSLayoutConstraint.Axis, rhs: Float) -> Builder {
    return lhs∶|-SpacingMetric(rhs, .equal)
  }

}

extension CGFloat {

  public typealias SpacingMetric = PseudoConstraint.SpacingMetric
  public typealias ObjectSpacingPair = PseudoConstraint.ObjectSpacingPair
  public typealias Builder = PseudoConstraint.Builder

  /// Creates a spacing metric using `value` and `.greaterThanOrEqual`.
  public static prefix func >=(value: CGFloat) -> SpacingMetric {
    return >=Float(value)
  }

  /// Creates a spacing metric using `value` and `.lessThanOrEqual`.
  public static prefix func <=(value: CGFloat) -> SpacingMetric {
    return <=Float(value)
  }

  /// Creates a spacing metric using `value` and `.equal`.
  public static prefix func ==(value: CGFloat) -> SpacingMetric {
    return ==Float(value)
  }

  /// Tuples a spacing value for tail pinning.
  public static postfix func -|(value: CGFloat) -> ObjectSpacingPair {
    return Float(value)-|
  }

  /// Returns a builder with the `lhs` axis with pending metric `==rhs` and pending location `.head`.
  public static func ∶|-(lhs: NSLayoutConstraint.Axis, rhs: CGFloat) -> Builder {
    return lhs∶|-Float(rhs)
  }

}

extension Double {

  public typealias SpacingMetric = PseudoConstraint.SpacingMetric
  public typealias ObjectSpacingPair = PseudoConstraint.ObjectSpacingPair
  public typealias Builder = PseudoConstraint.Builder

  /// Creates a spacing metric using `value` and `.greaterThanOrEqual`.
  public static prefix func >=(value: Double) -> SpacingMetric {
    return >=Float(value)
  }

  /// Creates a spacing metric using `value` and `.lessThanOrEqual`.
  public static prefix func <=(value: Double) -> SpacingMetric {
    return <=Float(value)
  }

  /// Creates a spacing metric using `value` and `.equal`.
  public static prefix func ==(value: Double) -> SpacingMetric {
    return ==Float(value)
  }

  /// Tuples a spacing value for tail pinning.
  public static postfix func -|(value: Double) -> ObjectSpacingPair {
    return Float(value)-|
  }

  /// Returns a builder with the `lhs` axis with pending metric `==rhs` and pending location `.head`.
  public static func ∶|-(lhs: NSLayoutConstraint.Axis, rhs: Double) -> Builder {
    return lhs∶|-Float(rhs)
  }

}

extension Int {

  public typealias SpacingMetric = PseudoConstraint.SpacingMetric
  public typealias ObjectSpacingPair = PseudoConstraint.ObjectSpacingPair
  public typealias Builder = PseudoConstraint.Builder

  /// Creates a spacing metric using `value` and `.greaterThanOrEqual`.
  public static prefix func >=(value: Int) -> SpacingMetric {
    return >=Float(value)
  }

  /// Creates a spacing metric using `value` and `.lessThanOrEqual`.
  public static prefix func <=(value: Int) -> SpacingMetric {
    return <=Float(value)
  }

  /// Creates a spacing metric using `value` and `.equal`.
  public static prefix func ==(value: Int) -> SpacingMetric {
    return ==Float(value)
  }

  /// Tuples a spacing value for tail pinning.
  public static postfix func -|(value: Int) -> ObjectSpacingPair {
    return Float(value)-|
  }

  /// Returns a builder with the `lhs` axis with pending metric `==rhs` and pending location `.head`.
  public static func ∶|-(lhs: NSLayoutConstraint.Axis, rhs: Int) -> Builder {
    return lhs∶|-Float(rhs)
  }

}

