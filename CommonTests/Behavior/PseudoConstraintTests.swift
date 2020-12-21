//
//  PseudoConstraintTests.swift
//  PseudoConstraintTests
//
//  Created by Jason Cardwell on 12/28/16.
//  Copyright © 2016 Jason Cardwell. All rights reserved.
//
@testable import MoonKit
import Nimble
import UIKit
import XCTest

final class PseudoConstraintTests: XCTestCase {
  private func makeViews() -> (parent: UIView, child1: UIView, child2: UIView, guide: UILayoutGuide) {
    let parent = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
    parent.identifier = "parent"
    parent.layoutMarginsGuide.identifier = "guide"

    let child1 = UIView(autolayout: true)
    child1.identifier = "child1"
    parent.addSubview(child1)

    let child2 = UIView(autolayout: true)
    child2.identifier = "child2"
    parent.addSubview(child2)

    return (parent: parent, child1: child1, child2: child2, guide: parent.layoutMarginsGuide)
  }

  func testSingleConstraint() {
    let (parent, child1, child2, guide) = makeViews()

    let constraint1 = child1.width == child2.height
    expect(constraint1.firstItem) == "child1"
    expect(constraint1.firstObject?.value) === child1
    expect(constraint1.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint1.relation) == PseudoConstraint.Relation.equal
    expect(constraint1.secondItem) == "child2"
    expect(constraint1.secondObject?.value) === child2
    expect(constraint1.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint1.multiplier) == 1.0
    expect(constraint1.constant) == 0.0
    expect(constraint1.priority.rawValue) == UILayoutPriority.required.rawValue
    expect(constraint1.identifier).to(beNil())

    let constraint2 = child1.width == child2.height * 2
    expect(constraint2.firstItem) == "child1"
    expect(constraint2.firstObject?.value) === child1
    expect(constraint2.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint2.relation) == PseudoConstraint.Relation.equal
    expect(constraint2.secondItem) == "child2"
    expect(constraint2.secondObject?.value) === child2
    expect(constraint2.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint2.multiplier) == 2.0
    expect(constraint2.constant) == 0.0
    expect(constraint2.priority.rawValue) == UILayoutPriority.required.rawValue
    expect(constraint2.identifier).to(beNil())

    let constraint3 = child1.width == child2.height + 10
    expect(constraint3.firstItem) == "child1"
    expect(constraint3.firstObject?.value) === child1
    expect(constraint3.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint3.relation) == PseudoConstraint.Relation.equal
    expect(constraint3.secondItem) == "child2"
    expect(constraint3.secondObject?.value) === child2
    expect(constraint3.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint3.multiplier) == 1.0
    expect(constraint3.constant) == 10.0
    expect(constraint3.priority.rawValue) == UILayoutPriority.required.rawValue
    expect(constraint3.identifier).to(beNil())

    let constraint4 = child1.width == child2.height * 2 + 10
    expect(constraint4.firstItem) == "child1"
    expect(constraint4.firstObject?.value) === child1
    expect(constraint4.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint4.relation) == PseudoConstraint.Relation.equal
    expect(constraint4.secondItem) == "child2"
    expect(constraint4.secondObject?.value) === child2
    expect(constraint4.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint4.multiplier) == 2.0
    expect(constraint4.constant) == 10.0
    expect(constraint4.priority.rawValue) == UILayoutPriority.required.rawValue
    expect(constraint4.identifier).to(beNil())

    let constraint5 = child1.width == child2.height ! 450
    expect(constraint5.firstItem) == "child1"
    expect(constraint5.firstObject?.value) === child1
    expect(constraint5.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint5.relation) == PseudoConstraint.Relation.equal
    expect(constraint5.secondItem) == "child2"
    expect(constraint5.secondObject?.value) === child2
    expect(constraint5.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint5.multiplier) == 1.0
    expect(constraint5.constant) == 0.0
    expect(constraint5.priority.rawValue) == 450.0
    expect(constraint5.identifier).to(beNil())

    let constraint6 = child1.width == child2.height * 2 ! 450
    expect(constraint6.firstItem) == "child1"
    expect(constraint6.firstObject?.value) === child1
    expect(constraint6.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint6.relation) == PseudoConstraint.Relation.equal
    expect(constraint6.secondItem) == "child2"
    expect(constraint6.secondObject?.value) === child2
    expect(constraint6.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint6.multiplier) == 2.0
    expect(constraint6.constant) == 0.0
    expect(constraint6.priority.rawValue) == 450.0
    expect(constraint6.identifier).to(beNil())

    let constraint7 = child1.width == child2.height + 10 ! 450
    expect(constraint7.firstItem) == "child1"
    expect(constraint7.firstObject?.value) === child1
    expect(constraint7.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint7.relation) == PseudoConstraint.Relation.equal
    expect(constraint7.secondItem) == "child2"
    expect(constraint7.secondObject?.value) === child2
    expect(constraint7.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint7.multiplier) == 1.0
    expect(constraint7.constant) == 10.0
    expect(constraint7.priority.rawValue) == 450.0
    expect(constraint7.identifier).to(beNil())

    let constraint8 = child1.width == child2.height * 2 + 10 ! 450
    expect(constraint8.firstItem) == "child1"
    expect(constraint8.firstObject?.value) === child1
    expect(constraint8.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint8.relation) == PseudoConstraint.Relation.equal
    expect(constraint8.secondItem) == "child2"
    expect(constraint8.secondObject?.value) === child2
    expect(constraint8.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint8.multiplier) == 2.0
    expect(constraint8.constant) == 10.0
    expect(constraint8.priority.rawValue) == 450.0
    expect(constraint8.identifier).to(beNil())

    let constraint9 = child1.width == child2.height --> "identifier"
    expect(constraint9.firstItem) == "child1"
    expect(constraint9.firstObject?.value) === child1
    expect(constraint9.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint9.relation) == PseudoConstraint.Relation.equal
    expect(constraint9.secondItem) == "child2"
    expect(constraint9.secondObject?.value) === child2
    expect(constraint9.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint9.multiplier) == 1.0
    expect(constraint9.constant) == 0.0
    expect(constraint9.priority.rawValue) == UILayoutPriority.required.rawValue
    expect(constraint9.identifier) == "identifier"

    let constraint10 = child1.width == child2.height * 2 --> "identifier"
    expect(constraint10.firstItem) == "child1"
    expect(constraint10.firstObject?.value) === child1
    expect(constraint10.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint10.relation) == PseudoConstraint.Relation.equal
    expect(constraint10.secondItem) == "child2"
    expect(constraint10.secondObject?.value) === child2
    expect(constraint10.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint10.multiplier) == 2.0
    expect(constraint10.constant) == 0.0
    expect(constraint10.priority.rawValue) == UILayoutPriority.required.rawValue
    expect(constraint10.identifier) == "identifier"

    let constraint11 = child1.width == child2.height + 10 --> "identifier"
    expect(constraint11.firstItem) == "child1"
    expect(constraint11.firstObject?.value) === child1
    expect(constraint11.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint11.relation) == PseudoConstraint.Relation.equal
    expect(constraint11.secondItem) == "child2"
    expect(constraint11.secondObject?.value) === child2
    expect(constraint11.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint11.multiplier) == 1.0
    expect(constraint11.constant) == 10.0
    expect(constraint11.priority.rawValue) == UILayoutPriority.required.rawValue
    expect(constraint11.identifier) == "identifier"

    let constraint12 = child1.width == child2.height * 2 + 10 --> "identifier"
    expect(constraint12.firstItem) == "child1"
    expect(constraint12.firstObject?.value) === child1
    expect(constraint12.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint12.relation) == PseudoConstraint.Relation.equal
    expect(constraint12.secondItem) == "child2"
    expect(constraint12.secondObject?.value) === child2
    expect(constraint12.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint12.multiplier) == 2.0
    expect(constraint12.constant) == 10.0
    expect(constraint12.priority.rawValue) == UILayoutPriority.required.rawValue
    expect(constraint12.identifier) == "identifier"

    let constraint13 = child1.width == child2.height ! 450 --> "identifier"
    expect(constraint13.firstItem) == "child1"
    expect(constraint13.firstObject?.value) === child1
    expect(constraint13.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint13.relation) == PseudoConstraint.Relation.equal
    expect(constraint13.secondItem) == "child2"
    expect(constraint13.secondObject?.value) === child2
    expect(constraint13.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint13.multiplier) == 1.0
    expect(constraint13.constant) == 0.0
    expect(constraint13.priority.rawValue) == 450.0
    expect(constraint13.identifier) == "identifier"

    let constraint14 = child1.width == child2.height * 2 ! 450 --> "identifier"
    expect(constraint14.firstItem) == "child1"
    expect(constraint14.firstObject?.value) === child1
    expect(constraint14.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint14.relation) == PseudoConstraint.Relation.equal
    expect(constraint14.secondItem) == "child2"
    expect(constraint14.secondObject?.value) === child2
    expect(constraint14.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint14.multiplier) == 2.0
    expect(constraint14.constant) == 0.0
    expect(constraint14.priority.rawValue) == 450.0
    expect(constraint14.identifier) == "identifier"

    let constraint15 = child1.width == child2.height + 10 ! 450 --> "identifier"
    expect(constraint15.firstItem) == "child1"
    expect(constraint15.firstObject?.value) === child1
    expect(constraint15.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint15.relation) == PseudoConstraint.Relation.equal
    expect(constraint15.secondItem) == "child2"
    expect(constraint15.secondObject?.value) === child2
    expect(constraint15.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint15.multiplier) == 1.0
    expect(constraint15.constant) == 10.0
    expect(constraint15.priority.rawValue) == 450.0
    expect(constraint15.identifier) == "identifier"

    let constraint16 = child1.width == child2.height * 2 + 10 ! 450 --> "identifier"
    expect(constraint16.firstItem) == "child1"
    expect(constraint16.firstObject?.value) === child1
    expect(constraint16.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint16.relation) == PseudoConstraint.Relation.equal
    expect(constraint16.secondItem) == "child2"
    expect(constraint16.secondObject?.value) === child2
    expect(constraint16.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint16.multiplier) == 2.0
    expect(constraint16.constant) == 10.0
    expect(constraint16.priority.rawValue) == 450.0
    expect(constraint16.identifier) == "identifier"

    let constraint17 = parent.width == 64
    expect(constraint17.firstItem) == "parent"
    expect(constraint17.firstObject?.value) === parent
    expect(constraint17.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint17.relation) == PseudoConstraint.Relation.equal
    expect(constraint17.secondItem).to(beNil())
    expect(constraint17.secondObject?.value).to(beNil())
    expect(constraint17.secondAttribute) == PseudoConstraint.Attribute.notAnAttribute
    expect(constraint17.multiplier) == 1.0
    expect(constraint17.constant) == 64.0
    expect(constraint17.priority.rawValue) == UILayoutPriority.required.rawValue
    expect(constraint17.identifier).to(beNil())

    let constraint18 = parent.width == 64 ! 450
    expect(constraint18.firstItem) == "parent"
    expect(constraint18.firstObject?.value) === parent
    expect(constraint18.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint18.relation) == PseudoConstraint.Relation.equal
    expect(constraint18.secondItem).to(beNil())
    expect(constraint18.secondObject?.value).to(beNil())
    expect(constraint18.secondAttribute) == PseudoConstraint.Attribute.notAnAttribute
    expect(constraint18.multiplier) == 1.0
    expect(constraint18.constant) == 64.0
    expect(constraint18.priority.rawValue) == 450.0
    expect(constraint18.identifier).to(beNil())

    let constraint19 = parent.width == 64 --> "identifier"
    expect(constraint19.firstItem) == "parent"
    expect(constraint19.firstObject?.value) === parent
    expect(constraint19.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint19.relation) == PseudoConstraint.Relation.equal
    expect(constraint19.secondItem).to(beNil())
    expect(constraint19.secondObject?.value).to(beNil())
    expect(constraint19.secondAttribute) == PseudoConstraint.Attribute.notAnAttribute
    expect(constraint19.multiplier) == 1.0
    expect(constraint19.constant) == 64.0
    expect(constraint19.priority.rawValue) == UILayoutPriority.required.rawValue
    expect(constraint19.identifier) == "identifier"

    let constraint20 = parent.width == 64 ! 450 --> "identifier"
    expect(constraint20.firstItem) == "parent"
    expect(constraint20.firstObject?.value) === parent
    expect(constraint20.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint20.relation) == PseudoConstraint.Relation.equal
    expect(constraint20.secondItem).to(beNil())
    expect(constraint20.secondObject?.value).to(beNil())
    expect(constraint20.secondAttribute) == PseudoConstraint.Attribute.notAnAttribute
    expect(constraint20.multiplier) == 1.0
    expect(constraint20.constant) == 64.0
    expect(constraint20.priority.rawValue) == 450.0
    expect(constraint20.identifier) == "identifier"

    let constraint21 = child1.width >= child2.height
    expect(constraint21.firstItem) == "child1"
    expect(constraint21.firstObject?.value) === child1
    expect(constraint21.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint21.relation) == PseudoConstraint.Relation.greaterThanOrEqual
    expect(constraint21.secondItem) == "child2"
    expect(constraint21.secondObject?.value) === child2
    expect(constraint21.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint21.multiplier) == 1.0
    expect(constraint21.constant) == 0.0
    expect(constraint21.priority.rawValue) == UILayoutPriority.required.rawValue
    expect(constraint21.identifier).to(beNil())

    let constraint22 = child1.width >= child2.height * 2
    expect(constraint22.firstItem) == "child1"
    expect(constraint22.firstObject?.value) === child1
    expect(constraint22.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint22.relation) == PseudoConstraint.Relation.greaterThanOrEqual
    expect(constraint22.secondItem) == "child2"
    expect(constraint22.secondObject?.value) === child2
    expect(constraint22.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint22.multiplier) == 2.0
    expect(constraint22.constant) == 0.0
    expect(constraint22.priority.rawValue) == UILayoutPriority.required.rawValue
    expect(constraint22.identifier).to(beNil())

    let constraint23 = child1.width >= child2.height + 10
    expect(constraint23.firstItem) == "child1"
    expect(constraint23.firstObject?.value) === child1
    expect(constraint23.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint23.relation) == PseudoConstraint.Relation.greaterThanOrEqual
    expect(constraint23.secondItem) == "child2"
    expect(constraint23.secondObject?.value) === child2
    expect(constraint23.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint23.multiplier) == 1.0
    expect(constraint23.constant) == 10.0
    expect(constraint23.priority.rawValue) == UILayoutPriority.required.rawValue
    expect(constraint23.identifier).to(beNil())

    let constraint24 = child1.width >= child2.height * 2 + 10
    expect(constraint24.firstItem) == "child1"
    expect(constraint24.firstObject?.value) === child1
    expect(constraint24.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint24.relation) == PseudoConstraint.Relation.greaterThanOrEqual
    expect(constraint24.secondItem) == "child2"
    expect(constraint24.secondObject?.value) === child2
    expect(constraint24.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint24.multiplier) == 2.0
    expect(constraint24.constant) == 10.0
    expect(constraint24.priority.rawValue) == UILayoutPriority.required.rawValue
    expect(constraint24.identifier).to(beNil())

    let constraint25 = child1.width >= child2.height ! 450
    expect(constraint25.firstItem) == "child1"
    expect(constraint25.firstObject?.value) === child1
    expect(constraint25.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint25.relation) == PseudoConstraint.Relation.greaterThanOrEqual
    expect(constraint25.secondItem) == "child2"
    expect(constraint25.secondObject?.value) === child2
    expect(constraint25.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint25.multiplier) == 1.0
    expect(constraint25.constant) == 0.0
    expect(constraint25.priority.rawValue) == 450.0
    expect(constraint25.identifier).to(beNil())

    let constraint26 = child1.width >= child2.height * 2 ! 450
    expect(constraint26.firstItem) == "child1"
    expect(constraint26.firstObject?.value) === child1
    expect(constraint26.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint26.relation) == PseudoConstraint.Relation.greaterThanOrEqual
    expect(constraint26.secondItem) == "child2"
    expect(constraint26.secondObject?.value) === child2
    expect(constraint26.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint26.multiplier) == 2.0
    expect(constraint26.constant) == 0.0
    expect(constraint26.priority.rawValue) == 450.0
    expect(constraint26.identifier).to(beNil())

    let constraint27 = child1.width >= child2.height + 10 ! 450
    expect(constraint27.firstItem) == "child1"
    expect(constraint27.firstObject?.value) === child1
    expect(constraint27.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint27.relation) == PseudoConstraint.Relation.greaterThanOrEqual
    expect(constraint27.secondItem) == "child2"
    expect(constraint27.secondObject?.value) === child2
    expect(constraint27.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint27.multiplier) == 1.0
    expect(constraint27.constant) == 10.0
    expect(constraint27.priority.rawValue) == 450.0
    expect(constraint27.identifier).to(beNil())

    let constraint28 = child1.width >= child2.height * 2 + 10 ! 450
    expect(constraint28.firstItem) == "child1"
    expect(constraint28.firstObject?.value) === child1
    expect(constraint28.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint28.relation) == PseudoConstraint.Relation.greaterThanOrEqual
    expect(constraint28.secondItem) == "child2"
    expect(constraint28.secondObject?.value) === child2
    expect(constraint28.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint28.multiplier) == 2.0
    expect(constraint28.constant) == 10.0
    expect(constraint28.priority.rawValue) == 450.0
    expect(constraint28.identifier).to(beNil())

    let constraint29 = child1.width >= child2.height --> "identifier"
    expect(constraint29.firstItem) == "child1"
    expect(constraint29.firstObject?.value) === child1
    expect(constraint29.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint29.relation) == PseudoConstraint.Relation.greaterThanOrEqual
    expect(constraint29.secondItem) == "child2"
    expect(constraint29.secondObject?.value) === child2
    expect(constraint29.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint29.multiplier) == 1.0
    expect(constraint29.constant) == 0.0
    expect(constraint29.priority.rawValue) == UILayoutPriority.required.rawValue
    expect(constraint29.identifier) == "identifier"

    let constraint30 = child1.width >= child2.height * 2 --> "identifier"
    expect(constraint30.firstItem) == "child1"
    expect(constraint30.firstObject?.value) === child1
    expect(constraint30.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint30.relation) == PseudoConstraint.Relation.greaterThanOrEqual
    expect(constraint30.secondItem) == "child2"
    expect(constraint30.secondObject?.value) === child2
    expect(constraint30.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint30.multiplier) == 2.0
    expect(constraint30.constant) == 0.0
    expect(constraint30.priority.rawValue) == UILayoutPriority.required.rawValue
    expect(constraint30.identifier) == "identifier"

    let constraint31 = child1.width >= child2.height + 10 --> "identifier"
    expect(constraint31.firstItem) == "child1"
    expect(constraint31.firstObject?.value) === child1
    expect(constraint31.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint31.relation) == PseudoConstraint.Relation.greaterThanOrEqual
    expect(constraint31.secondItem) == "child2"
    expect(constraint31.secondObject?.value) === child2
    expect(constraint31.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint31.multiplier) == 1.0
    expect(constraint31.constant) == 10.0
    expect(constraint31.priority.rawValue) == UILayoutPriority.required.rawValue
    expect(constraint31.identifier) == "identifier"

    let constraint32 = child1.width >= child2.height * 2 + 10 --> "identifier"
    expect(constraint32.firstItem) == "child1"
    expect(constraint32.firstObject?.value) === child1
    expect(constraint32.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint32.relation) == PseudoConstraint.Relation.greaterThanOrEqual
    expect(constraint32.secondItem) == "child2"
    expect(constraint32.secondObject?.value) === child2
    expect(constraint32.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint32.multiplier) == 2.0
    expect(constraint32.constant) == 10.0
    expect(constraint32.priority.rawValue) == UILayoutPriority.required.rawValue
    expect(constraint32.identifier) == "identifier"

    let constraint33 = child1.width >= child2.height ! 450 --> "identifier"
    expect(constraint33.firstItem) == "child1"
    expect(constraint33.firstObject?.value) === child1
    expect(constraint33.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint33.relation) == PseudoConstraint.Relation.greaterThanOrEqual
    expect(constraint33.secondItem) == "child2"
    expect(constraint33.secondObject?.value) === child2
    expect(constraint33.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint33.multiplier) == 1.0
    expect(constraint33.constant) == 0.0
    expect(constraint33.priority.rawValue) == 450.0
    expect(constraint33.identifier) == "identifier"

    let constraint34 = child1.width >= child2.height * 2 ! 450 --> "identifier"
    expect(constraint34.firstItem) == "child1"
    expect(constraint34.firstObject?.value) === child1
    expect(constraint34.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint34.relation) == PseudoConstraint.Relation.greaterThanOrEqual
    expect(constraint34.secondItem) == "child2"
    expect(constraint34.secondObject?.value) === child2
    expect(constraint34.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint34.multiplier) == 2.0
    expect(constraint34.constant) == 0.0
    expect(constraint34.priority.rawValue) == 450.0
    expect(constraint34.identifier) == "identifier"

    let constraint35 = child1.width >= child2.height + 10 ! 450 --> "identifier"
    expect(constraint35.firstItem) == "child1"
    expect(constraint35.firstObject?.value) === child1
    expect(constraint35.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint35.relation) == PseudoConstraint.Relation.greaterThanOrEqual
    expect(constraint35.secondItem) == "child2"
    expect(constraint35.secondObject?.value) === child2
    expect(constraint35.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint35.multiplier) == 1.0
    expect(constraint35.constant) == 10.0
    expect(constraint35.priority.rawValue) == 450.0
    expect(constraint35.identifier) == "identifier"

    let constraint36 = child1.width >= child2.height * 2 + 10 ! 450 --> "identifier"
    expect(constraint36.firstItem) == "child1"
    expect(constraint36.firstObject?.value) === child1
    expect(constraint36.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint36.relation) == PseudoConstraint.Relation.greaterThanOrEqual
    expect(constraint36.secondItem) == "child2"
    expect(constraint36.secondObject?.value) === child2
    expect(constraint36.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint36.multiplier) == 2.0
    expect(constraint36.constant) == 10.0
    expect(constraint36.priority.rawValue) == 450.0
    expect(constraint36.identifier) == "identifier"

    let constraint37 = parent.width >= 64
    expect(constraint37.firstItem) == "parent"
    expect(constraint37.firstObject?.value) === parent
    expect(constraint37.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint37.relation) == PseudoConstraint.Relation.greaterThanOrEqual
    expect(constraint37.secondItem).to(beNil())
    expect(constraint37.secondObject?.value).to(beNil())
    expect(constraint37.secondAttribute) == PseudoConstraint.Attribute.notAnAttribute
    expect(constraint37.multiplier) == 1.0
    expect(constraint37.constant) == 64.0
    expect(constraint37.priority.rawValue) == UILayoutPriority.required.rawValue
    expect(constraint37.identifier).to(beNil())

    let constraint38 = parent.width >= 64 ! 450
    expect(constraint38.firstItem) == "parent"
    expect(constraint38.firstObject?.value) === parent
    expect(constraint38.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint38.relation) == PseudoConstraint.Relation.greaterThanOrEqual
    expect(constraint38.secondItem).to(beNil())
    expect(constraint38.secondObject?.value).to(beNil())
    expect(constraint38.secondAttribute) == PseudoConstraint.Attribute.notAnAttribute
    expect(constraint38.multiplier) == 1.0
    expect(constraint38.constant) == 64.0
    expect(constraint38.priority.rawValue) == 450.0
    expect(constraint38.identifier).to(beNil())

    let constraint39 = parent.width >= 64 --> "identifier"
    expect(constraint39.firstItem) == "parent"
    expect(constraint39.firstObject?.value) === parent
    expect(constraint39.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint39.relation) == PseudoConstraint.Relation.greaterThanOrEqual
    expect(constraint39.secondItem).to(beNil())
    expect(constraint39.secondObject?.value).to(beNil())
    expect(constraint39.secondAttribute) == PseudoConstraint.Attribute.notAnAttribute
    expect(constraint39.multiplier) == 1.0
    expect(constraint39.constant) == 64.0
    expect(constraint39.priority.rawValue) == UILayoutPriority.required.rawValue
    expect(constraint39.identifier) == "identifier"

    let constraint40 = parent.width >= 64 ! 450 --> "identifier"
    expect(constraint40.firstItem) == "parent"
    expect(constraint40.firstObject?.value) === parent
    expect(constraint40.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint40.relation) == PseudoConstraint.Relation.greaterThanOrEqual
    expect(constraint40.secondItem).to(beNil())
    expect(constraint40.secondObject?.value).to(beNil())
    expect(constraint40.secondAttribute) == PseudoConstraint.Attribute.notAnAttribute
    expect(constraint40.multiplier) == 1.0
    expect(constraint40.constant) == 64.0
    expect(constraint40.priority.rawValue) == 450.0
    expect(constraint40.identifier) == "identifier"

    let constraint41 = child1.width <= child2.height
    expect(constraint41.firstItem) == "child1"
    expect(constraint41.firstObject?.value) === child1
    expect(constraint41.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint41.relation) == PseudoConstraint.Relation.lessThanOrEqual
    expect(constraint41.secondItem) == "child2"
    expect(constraint41.secondObject?.value) === child2
    expect(constraint41.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint41.multiplier) == 1.0
    expect(constraint41.constant) == 0.0
    expect(constraint41.priority.rawValue) == UILayoutPriority.required.rawValue
    expect(constraint41.identifier).to(beNil())

    let constraint42 = child1.width <= child2.height * 2
    expect(constraint42.firstItem) == "child1"
    expect(constraint42.firstObject?.value) === child1
    expect(constraint42.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint42.relation) == PseudoConstraint.Relation.lessThanOrEqual
    expect(constraint42.secondItem) == "child2"
    expect(constraint42.secondObject?.value) === child2
    expect(constraint42.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint42.multiplier) == 2.0
    expect(constraint42.constant) == 0.0
    expect(constraint42.priority.rawValue) == UILayoutPriority.required.rawValue
    expect(constraint42.identifier).to(beNil())

    let constraint43 = child1.width <= child2.height + 10
    expect(constraint43.firstItem) == "child1"
    expect(constraint43.firstObject?.value) === child1
    expect(constraint43.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint43.relation) == PseudoConstraint.Relation.lessThanOrEqual
    expect(constraint43.secondItem) == "child2"
    expect(constraint43.secondObject?.value) === child2
    expect(constraint43.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint43.multiplier) == 1.0
    expect(constraint43.constant) == 10.0
    expect(constraint43.priority.rawValue) == UILayoutPriority.required.rawValue
    expect(constraint43.identifier).to(beNil())

    let constraint44 = child1.width <= child2.height * 2 + 10
    expect(constraint44.firstItem) == "child1"
    expect(constraint44.firstObject?.value) === child1
    expect(constraint44.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint44.relation) == PseudoConstraint.Relation.lessThanOrEqual
    expect(constraint44.secondItem) == "child2"
    expect(constraint44.secondObject?.value) === child2
    expect(constraint44.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint44.multiplier) == 2.0
    expect(constraint44.constant) == 10.0
    expect(constraint44.priority.rawValue) == UILayoutPriority.required.rawValue
    expect(constraint44.identifier).to(beNil())

    let constraint45 = child1.width <= child2.height ! 450
    expect(constraint45.firstItem) == "child1"
    expect(constraint45.firstObject?.value) === child1
    expect(constraint45.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint45.relation) == PseudoConstraint.Relation.lessThanOrEqual
    expect(constraint45.secondItem) == "child2"
    expect(constraint45.secondObject?.value) === child2
    expect(constraint45.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint45.multiplier) == 1.0
    expect(constraint45.constant) == 0.0
    expect(constraint45.priority.rawValue) == 450.0
    expect(constraint45.identifier).to(beNil())

    let constraint46 = child1.width <= child2.height * 2 ! 450
    expect(constraint46.firstItem) == "child1"
    expect(constraint46.firstObject?.value) === child1
    expect(constraint46.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint46.relation) == PseudoConstraint.Relation.lessThanOrEqual
    expect(constraint46.secondItem) == "child2"
    expect(constraint46.secondObject?.value) === child2
    expect(constraint46.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint46.multiplier) == 2.0
    expect(constraint46.constant) == 0.0
    expect(constraint46.priority.rawValue) == 450.0
    expect(constraint46.identifier).to(beNil())

    let constraint47 = child1.width <= child2.height + 10 ! 450
    expect(constraint47.firstItem) == "child1"
    expect(constraint47.firstObject?.value) === child1
    expect(constraint47.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint47.relation) == PseudoConstraint.Relation.lessThanOrEqual
    expect(constraint47.secondItem) == "child2"
    expect(constraint47.secondObject?.value) === child2
    expect(constraint47.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint47.multiplier) == 1.0
    expect(constraint47.constant) == 10.0
    expect(constraint47.priority.rawValue) == 450.0
    expect(constraint47.identifier).to(beNil())

    let constraint48 = child1.width <= child2.height * 2 + 10 ! 450
    expect(constraint48.firstItem) == "child1"
    expect(constraint48.firstObject?.value) === child1
    expect(constraint48.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint48.relation) == PseudoConstraint.Relation.lessThanOrEqual
    expect(constraint48.secondItem) == "child2"
    expect(constraint48.secondObject?.value) === child2
    expect(constraint48.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint48.multiplier) == 2.0
    expect(constraint48.constant) == 10.0
    expect(constraint48.priority.rawValue) == 450.0
    expect(constraint48.identifier).to(beNil())

    let constraint49 = child1.width <= child2.height --> "identifier"
    expect(constraint49.firstItem) == "child1"
    expect(constraint49.firstObject?.value) === child1
    expect(constraint49.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint49.relation) == PseudoConstraint.Relation.lessThanOrEqual
    expect(constraint49.secondItem) == "child2"
    expect(constraint49.secondObject?.value) === child2
    expect(constraint49.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint49.multiplier) == 1.0
    expect(constraint49.constant) == 0.0
    expect(constraint49.priority.rawValue) == UILayoutPriority.required.rawValue
    expect(constraint49.identifier) == "identifier"

    let constraint50 = child1.width <= child2.height * 2 --> "identifier"
    expect(constraint50.firstItem) == "child1"
    expect(constraint50.firstObject?.value) === child1
    expect(constraint50.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint50.relation) == PseudoConstraint.Relation.lessThanOrEqual
    expect(constraint50.secondItem) == "child2"
    expect(constraint50.secondObject?.value) === child2
    expect(constraint50.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint50.multiplier) == 2.0
    expect(constraint50.constant) == 0.0
    expect(constraint50.priority.rawValue) == UILayoutPriority.required.rawValue
    expect(constraint50.identifier) == "identifier"

    let constraint51 = child1.width <= child2.height + 10 --> "identifier"
    expect(constraint51.firstItem) == "child1"
    expect(constraint51.firstObject?.value) === child1
    expect(constraint51.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint51.relation) == PseudoConstraint.Relation.lessThanOrEqual
    expect(constraint51.secondItem) == "child2"
    expect(constraint51.secondObject?.value) === child2
    expect(constraint51.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint51.multiplier) == 1.0
    expect(constraint51.constant) == 10.0
    expect(constraint51.priority.rawValue) == UILayoutPriority.required.rawValue
    expect(constraint51.identifier) == "identifier"

    let constraint52 = child1.width <= child2.height * 2 + 10 --> "identifier"
    expect(constraint52.firstItem) == "child1"
    expect(constraint52.firstObject?.value) === child1
    expect(constraint52.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint52.relation) == PseudoConstraint.Relation.lessThanOrEqual
    expect(constraint52.secondItem) == "child2"
    expect(constraint52.secondObject?.value) === child2
    expect(constraint52.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint52.multiplier) == 2.0
    expect(constraint52.constant) == 10.0
    expect(constraint52.priority.rawValue) == UILayoutPriority.required.rawValue
    expect(constraint52.identifier) == "identifier"

    let constraint53 = child1.width <= child2.height ! 450 --> "identifier"
    expect(constraint53.firstItem) == "child1"
    expect(constraint53.firstObject?.value) === child1
    expect(constraint53.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint53.relation) == PseudoConstraint.Relation.lessThanOrEqual
    expect(constraint53.secondItem) == "child2"
    expect(constraint53.secondObject?.value) === child2
    expect(constraint53.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint53.multiplier) == 1.0
    expect(constraint53.constant) == 0.0
    expect(constraint53.priority.rawValue) == 450.0
    expect(constraint53.identifier) == "identifier"

    let constraint54 = child1.width <= child2.height * 2 ! 450 --> "identifier"
    expect(constraint54.firstItem) == "child1"
    expect(constraint54.firstObject?.value) === child1
    expect(constraint54.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint54.relation) == PseudoConstraint.Relation.lessThanOrEqual
    expect(constraint54.secondItem) == "child2"
    expect(constraint54.secondObject?.value) === child2
    expect(constraint54.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint54.multiplier) == 2.0
    expect(constraint54.constant) == 0.0
    expect(constraint54.priority.rawValue) == 450.0
    expect(constraint54.identifier) == "identifier"

    let constraint55 = child1.width <= child2.height + 10 ! 450 --> "identifier"
    expect(constraint55.firstItem) == "child1"
    expect(constraint55.firstObject?.value) === child1
    expect(constraint55.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint55.relation) == PseudoConstraint.Relation.lessThanOrEqual
    expect(constraint55.secondItem) == "child2"
    expect(constraint55.secondObject?.value) === child2
    expect(constraint55.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint55.multiplier) == 1.0
    expect(constraint55.constant) == 10.0
    expect(constraint55.priority.rawValue) == 450.0
    expect(constraint55.identifier) == "identifier"

    let constraint56 = child1.width <= child2.height * 2 + 10 ! 450 --> "identifier"
    expect(constraint56.firstItem) == "child1"
    expect(constraint56.firstObject?.value) === child1
    expect(constraint56.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint56.relation) == PseudoConstraint.Relation.lessThanOrEqual
    expect(constraint56.secondItem) == "child2"
    expect(constraint56.secondObject?.value) === child2
    expect(constraint56.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint56.multiplier) == 2.0
    expect(constraint56.constant) == 10.0
    expect(constraint56.priority.rawValue) == 450.0
    expect(constraint56.identifier) == "identifier"

    let constraint57 = parent.width <= 64
    expect(constraint57.firstItem) == "parent"
    expect(constraint57.firstObject?.value) === parent
    expect(constraint57.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint57.relation) == PseudoConstraint.Relation.lessThanOrEqual
    expect(constraint57.secondItem).to(beNil())
    expect(constraint57.secondObject?.value).to(beNil())
    expect(constraint57.secondAttribute) == PseudoConstraint.Attribute.notAnAttribute
    expect(constraint57.multiplier) == 1.0
    expect(constraint57.constant) == 64.0
    expect(constraint57.priority.rawValue) == UILayoutPriority.required.rawValue
    expect(constraint57.identifier).to(beNil())

    let constraint58 = parent.width <= 64 ! 450
    expect(constraint58.firstItem) == "parent"
    expect(constraint58.firstObject?.value) === parent
    expect(constraint58.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint58.relation) == PseudoConstraint.Relation.lessThanOrEqual
    expect(constraint58.secondItem).to(beNil())
    expect(constraint58.secondObject?.value).to(beNil())
    expect(constraint58.secondAttribute) == PseudoConstraint.Attribute.notAnAttribute
    expect(constraint58.multiplier) == 1.0
    expect(constraint58.constant) == 64.0
    expect(constraint58.priority.rawValue) == 450.0
    expect(constraint58.identifier).to(beNil())

    let constraint59 = parent.width <= 64 --> "identifier"
    expect(constraint59.firstItem) == "parent"
    expect(constraint59.firstObject?.value) === parent
    expect(constraint59.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint59.relation) == PseudoConstraint.Relation.lessThanOrEqual
    expect(constraint59.secondItem).to(beNil())
    expect(constraint59.secondObject?.value).to(beNil())
    expect(constraint59.secondAttribute) == PseudoConstraint.Attribute.notAnAttribute
    expect(constraint59.multiplier) == 1.0
    expect(constraint59.constant) == 64.0
    expect(constraint59.priority.rawValue) == UILayoutPriority.required.rawValue
    expect(constraint59.identifier) == "identifier"

    let constraint60 = parent.width <= 64 ! 450 --> "identifier"
    expect(constraint60.firstItem) == "parent"
    expect(constraint60.firstObject?.value) === parent
    expect(constraint60.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint60.relation) == PseudoConstraint.Relation.lessThanOrEqual
    expect(constraint60.secondItem).to(beNil())
    expect(constraint60.secondObject?.value).to(beNil())
    expect(constraint60.secondAttribute) == PseudoConstraint.Attribute.notAnAttribute
    expect(constraint60.multiplier) == 1.0
    expect(constraint60.constant) == 64.0
    expect(constraint60.priority.rawValue) == 450.0
    expect(constraint60.identifier) == "identifier"

    let constraint61 = child1.width == guide.height
    expect(constraint61.firstItem) == "child1"
    expect(constraint61.firstObject?.value) === child1
    expect(constraint61.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint61.relation) == PseudoConstraint.Relation.equal
    expect(constraint61.secondItem) == "guide"
    expect(constraint61.secondObject?.value) === guide
    expect(constraint61.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint61.multiplier) == 1.0
    expect(constraint61.constant) == 0.0
    expect(constraint61.priority.rawValue) == UILayoutPriority.required.rawValue
    expect(constraint61.identifier).to(beNil())

    let constraint62 = child1.width == guide.height * 2
    expect(constraint62.firstItem) == "child1"
    expect(constraint62.firstObject?.value) === child1
    expect(constraint62.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint62.relation) == PseudoConstraint.Relation.equal
    expect(constraint62.secondItem) == "guide"
    expect(constraint62.secondObject?.value) === guide
    expect(constraint62.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint62.multiplier) == 2.0
    expect(constraint62.constant) == 0.0
    expect(constraint62.priority.rawValue) == UILayoutPriority.required.rawValue
    expect(constraint62.identifier).to(beNil())

    let constraint63 = child1.width == guide.height + 10
    expect(constraint63.firstItem) == "child1"
    expect(constraint63.firstObject?.value) === child1
    expect(constraint63.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint63.relation) == PseudoConstraint.Relation.equal
    expect(constraint63.secondItem) == "guide"
    expect(constraint63.secondObject?.value) === guide
    expect(constraint63.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint63.multiplier) == 1.0
    expect(constraint63.constant) == 10.0
    expect(constraint63.priority.rawValue) == UILayoutPriority.required.rawValue
    expect(constraint63.identifier).to(beNil())

    let constraint64 = child1.width == guide.height * 2 + 10
    expect(constraint64.firstItem) == "child1"
    expect(constraint64.firstObject?.value) === child1
    expect(constraint64.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint64.relation) == PseudoConstraint.Relation.equal
    expect(constraint64.secondItem) == "guide"
    expect(constraint64.secondObject?.value) === guide
    expect(constraint64.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint64.multiplier) == 2.0
    expect(constraint64.constant) == 10.0
    expect(constraint64.priority.rawValue) == UILayoutPriority.required.rawValue
    expect(constraint64.identifier).to(beNil())

    let constraint65 = child1.width == guide.height ! 450
    expect(constraint65.firstItem) == "child1"
    expect(constraint65.firstObject?.value) === child1
    expect(constraint65.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint65.relation) == PseudoConstraint.Relation.equal
    expect(constraint65.secondItem) == "guide"
    expect(constraint65.secondObject?.value) === guide
    expect(constraint65.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint65.multiplier) == 1.0
    expect(constraint65.constant) == 0.0
    expect(constraint65.priority.rawValue) == 450.0
    expect(constraint65.identifier).to(beNil())

    let constraint66 = child1.width == guide.height * 2 ! 450
    expect(constraint66.firstItem) == "child1"
    expect(constraint66.firstObject?.value) === child1
    expect(constraint66.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint66.relation) == PseudoConstraint.Relation.equal
    expect(constraint66.secondItem) == "guide"
    expect(constraint66.secondObject?.value) === guide
    expect(constraint66.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint66.multiplier) == 2.0
    expect(constraint66.constant) == 0.0
    expect(constraint66.priority.rawValue) == 450.0
    expect(constraint66.identifier).to(beNil())

    let constraint67 = child1.width == guide.height + 10 ! 450
    expect(constraint67.firstItem) == "child1"
    expect(constraint67.firstObject?.value) === child1
    expect(constraint67.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint67.relation) == PseudoConstraint.Relation.equal
    expect(constraint67.secondItem) == "guide"
    expect(constraint67.secondObject?.value) === guide
    expect(constraint67.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint67.multiplier) == 1.0
    expect(constraint67.constant) == 10.0
    expect(constraint67.priority.rawValue) == 450.0
    expect(constraint67.identifier).to(beNil())

    let constraint68 = child1.width == guide.height * 2 + 10 ! 450
    expect(constraint68.firstItem) == "child1"
    expect(constraint68.firstObject?.value) === child1
    expect(constraint68.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint68.relation) == PseudoConstraint.Relation.equal
    expect(constraint68.secondItem) == "guide"
    expect(constraint68.secondObject?.value) === guide
    expect(constraint68.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint68.multiplier) == 2.0
    expect(constraint68.constant) == 10.0
    expect(constraint68.priority.rawValue) == 450.0
    expect(constraint68.identifier).to(beNil())

    let constraint69 = child1.width == guide.height --> "identifier"
    expect(constraint69.firstItem) == "child1"
    expect(constraint69.firstObject?.value) === child1
    expect(constraint69.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint69.relation) == PseudoConstraint.Relation.equal
    expect(constraint69.secondItem) == "guide"
    expect(constraint69.secondObject?.value) === guide
    expect(constraint69.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint69.multiplier) == 1.0
    expect(constraint69.constant) == 0.0
    expect(constraint69.priority.rawValue) == UILayoutPriority.required.rawValue
    expect(constraint69.identifier) == "identifier"

    let constraint70 = child1.width == guide.height * 2 --> "identifier"
    expect(constraint70.firstItem) == "child1"
    expect(constraint70.firstObject?.value) === child1
    expect(constraint70.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint70.relation) == PseudoConstraint.Relation.equal
    expect(constraint70.secondItem) == "guide"
    expect(constraint70.secondObject?.value) === guide
    expect(constraint70.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint70.multiplier) == 2.0
    expect(constraint70.constant) == 0.0
    expect(constraint70.priority.rawValue) == UILayoutPriority.required.rawValue
    expect(constraint70.identifier) == "identifier"

    let constraint71 = child1.width == guide.height + 10 --> "identifier"
    expect(constraint71.firstItem) == "child1"
    expect(constraint71.firstObject?.value) === child1
    expect(constraint71.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint71.relation) == PseudoConstraint.Relation.equal
    expect(constraint71.secondItem) == "guide"
    expect(constraint71.secondObject?.value) === guide
    expect(constraint71.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint71.multiplier) == 1.0
    expect(constraint71.constant) == 10.0
    expect(constraint71.priority.rawValue) == UILayoutPriority.required.rawValue
    expect(constraint71.identifier) == "identifier"

    let constraint72 = child1.width == guide.height * 2 + 10 --> "identifier"
    expect(constraint72.firstItem) == "child1"
    expect(constraint72.firstObject?.value) === child1
    expect(constraint72.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint72.relation) == PseudoConstraint.Relation.equal
    expect(constraint72.secondItem) == "guide"
    expect(constraint72.secondObject?.value) === guide
    expect(constraint72.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint72.multiplier) == 2.0
    expect(constraint72.constant) == 10.0
    expect(constraint72.priority.rawValue) == UILayoutPriority.required.rawValue
    expect(constraint72.identifier) == "identifier"

    let constraint73 = child1.width == guide.height ! 450 --> "identifier"
    expect(constraint73.firstItem) == "child1"
    expect(constraint73.firstObject?.value) === child1
    expect(constraint73.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint73.relation) == PseudoConstraint.Relation.equal
    expect(constraint73.secondItem) == "guide"
    expect(constraint73.secondObject?.value) === guide
    expect(constraint73.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint73.multiplier) == 1.0
    expect(constraint73.constant) == 0.0
    expect(constraint73.priority.rawValue) == 450.0
    expect(constraint73.identifier) == "identifier"

    let constraint74 = child1.width == guide.height * 2 ! 450 --> "identifier"
    expect(constraint74.firstItem) == "child1"
    expect(constraint74.firstObject?.value) === child1
    expect(constraint74.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint74.relation) == PseudoConstraint.Relation.equal
    expect(constraint74.secondItem) == "guide"
    expect(constraint74.secondObject?.value) === guide
    expect(constraint74.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint74.multiplier) == 2.0
    expect(constraint74.constant) == 0.0
    expect(constraint74.priority.rawValue) == 450.0
    expect(constraint74.identifier) == "identifier"

    let constraint75 = child1.width == guide.height + 10 ! 450 --> "identifier"
    expect(constraint75.firstItem) == "child1"
    expect(constraint75.firstObject?.value) === child1
    expect(constraint75.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint75.relation) == PseudoConstraint.Relation.equal
    expect(constraint75.secondItem) == "guide"
    expect(constraint75.secondObject?.value) === guide
    expect(constraint75.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint75.multiplier) == 1.0
    expect(constraint75.constant) == 10.0
    expect(constraint75.priority.rawValue) == 450.0
    expect(constraint75.identifier) == "identifier"

    let constraint76 = child1.width == guide.height * 2 + 10 ! 450 --> "identifier"
    expect(constraint76.firstItem) == "child1"
    expect(constraint76.firstObject?.value) === child1
    expect(constraint76.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint76.relation) == PseudoConstraint.Relation.equal
    expect(constraint76.secondItem) == "guide"
    expect(constraint76.secondObject?.value) === guide
    expect(constraint76.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint76.multiplier) == 2.0
    expect(constraint76.constant) == 10.0
    expect(constraint76.priority.rawValue) == 450.0
    expect(constraint76.identifier) == "identifier"

    let constraint77 = parent.width == 64
    expect(constraint77.firstItem) == "parent"
    expect(constraint77.firstObject?.value) === parent
    expect(constraint77.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint77.relation) == PseudoConstraint.Relation.equal
    expect(constraint77.secondItem).to(beNil())
    expect(constraint77.secondObject?.value).to(beNil())
    expect(constraint77.secondAttribute) == PseudoConstraint.Attribute.notAnAttribute
    expect(constraint77.multiplier) == 1.0
    expect(constraint77.constant) == 64.0
    expect(constraint77.priority.rawValue) == UILayoutPriority.required.rawValue
    expect(constraint77.identifier).to(beNil())

    let constraint78 = parent.width == 64 ! 450
    expect(constraint78.firstItem) == "parent"
    expect(constraint78.firstObject?.value) === parent
    expect(constraint78.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint78.relation) == PseudoConstraint.Relation.equal
    expect(constraint78.secondItem).to(beNil())
    expect(constraint78.secondObject?.value).to(beNil())
    expect(constraint78.secondAttribute) == PseudoConstraint.Attribute.notAnAttribute
    expect(constraint78.multiplier) == 1.0
    expect(constraint78.constant) == 64.0
    expect(constraint78.priority.rawValue) == 450.0
    expect(constraint78.identifier).to(beNil())

    let constraint79 = parent.width == 64 --> "identifier"
    expect(constraint79.firstItem) == "parent"
    expect(constraint79.firstObject?.value) === parent
    expect(constraint79.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint79.relation) == PseudoConstraint.Relation.equal
    expect(constraint79.secondItem).to(beNil())
    expect(constraint79.secondObject?.value).to(beNil())
    expect(constraint79.secondAttribute) == PseudoConstraint.Attribute.notAnAttribute
    expect(constraint79.multiplier) == 1.0
    expect(constraint79.constant) == 64.0
    expect(constraint79.priority.rawValue) == UILayoutPriority.required.rawValue
    expect(constraint79.identifier) == "identifier"

    let constraint80 = parent.width == 64 ! 450 --> "identifier"
    expect(constraint80.firstItem) == "parent"
    expect(constraint80.firstObject?.value) === parent
    expect(constraint80.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint80.relation) == PseudoConstraint.Relation.equal
    expect(constraint80.secondItem).to(beNil())
    expect(constraint80.secondObject?.value).to(beNil())
    expect(constraint80.secondAttribute) == PseudoConstraint.Attribute.notAnAttribute
    expect(constraint80.multiplier) == 1.0
    expect(constraint80.constant) == 64.0
    expect(constraint80.priority.rawValue) == 450.0
    expect(constraint80.identifier) == "identifier"

    let constraint81 = child1.width >= guide.height
    expect(constraint81.firstItem) == "child1"
    expect(constraint81.firstObject?.value) === child1
    expect(constraint81.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint81.relation) == PseudoConstraint.Relation.greaterThanOrEqual
    expect(constraint81.secondItem) == "guide"
    expect(constraint81.secondObject?.value) === guide
    expect(constraint81.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint81.multiplier) == 1.0
    expect(constraint81.constant) == 0.0
    expect(constraint81.priority.rawValue) == UILayoutPriority.required.rawValue
    expect(constraint81.identifier).to(beNil())

    let constraint82 = child1.width >= guide.height * 2
    expect(constraint82.firstItem) == "child1"
    expect(constraint82.firstObject?.value) === child1
    expect(constraint82.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint82.relation) == PseudoConstraint.Relation.greaterThanOrEqual
    expect(constraint82.secondItem) == "guide"
    expect(constraint82.secondObject?.value) === guide
    expect(constraint82.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint82.multiplier) == 2.0
    expect(constraint82.constant) == 0.0
    expect(constraint82.priority.rawValue) == UILayoutPriority.required.rawValue
    expect(constraint82.identifier).to(beNil())

    let constraint83 = child1.width >= guide.height + 10
    expect(constraint83.firstItem) == "child1"
    expect(constraint83.firstObject?.value) === child1
    expect(constraint83.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint83.relation) == PseudoConstraint.Relation.greaterThanOrEqual
    expect(constraint83.secondItem) == "guide"
    expect(constraint83.secondObject?.value) === guide
    expect(constraint83.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint83.multiplier) == 1.0
    expect(constraint83.constant) == 10.0
    expect(constraint83.priority.rawValue) == UILayoutPriority.required.rawValue
    expect(constraint83.identifier).to(beNil())

    let constraint84 = child1.width >= guide.height * 2 + 10
    expect(constraint84.firstItem) == "child1"
    expect(constraint84.firstObject?.value) === child1
    expect(constraint84.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint84.relation) == PseudoConstraint.Relation.greaterThanOrEqual
    expect(constraint84.secondItem) == "guide"
    expect(constraint84.secondObject?.value) === guide
    expect(constraint84.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint84.multiplier) == 2.0
    expect(constraint84.constant) == 10.0
    expect(constraint84.priority.rawValue) == UILayoutPriority.required.rawValue
    expect(constraint84.identifier).to(beNil())

    let constraint85 = child1.width >= guide.height ! 450
    expect(constraint85.firstItem) == "child1"
    expect(constraint85.firstObject?.value) === child1
    expect(constraint85.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint85.relation) == PseudoConstraint.Relation.greaterThanOrEqual
    expect(constraint85.secondItem) == "guide"
    expect(constraint85.secondObject?.value) === guide
    expect(constraint85.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint85.multiplier) == 1.0
    expect(constraint85.constant) == 0.0
    expect(constraint85.priority.rawValue) == 450.0
    expect(constraint85.identifier).to(beNil())

    let constraint86 = child1.width >= guide.height * 2 ! 450
    expect(constraint86.firstItem) == "child1"
    expect(constraint86.firstObject?.value) === child1
    expect(constraint86.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint86.relation) == PseudoConstraint.Relation.greaterThanOrEqual
    expect(constraint86.secondItem) == "guide"
    expect(constraint86.secondObject?.value) === guide
    expect(constraint86.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint86.multiplier) == 2.0
    expect(constraint86.constant) == 0.0
    expect(constraint86.priority.rawValue) == 450.0
    expect(constraint86.identifier).to(beNil())

    let constraint87 = child1.width >= guide.height + 10 ! 450
    expect(constraint87.firstItem) == "child1"
    expect(constraint87.firstObject?.value) === child1
    expect(constraint87.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint87.relation) == PseudoConstraint.Relation.greaterThanOrEqual
    expect(constraint87.secondItem) == "guide"
    expect(constraint87.secondObject?.value) === guide
    expect(constraint87.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint87.multiplier) == 1.0
    expect(constraint87.constant) == 10.0
    expect(constraint87.priority.rawValue) == 450.0
    expect(constraint87.identifier).to(beNil())

    let constraint88 = child1.width >= guide.height * 2 + 10 ! 450
    expect(constraint88.firstItem) == "child1"
    expect(constraint88.firstObject?.value) === child1
    expect(constraint88.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint88.relation) == PseudoConstraint.Relation.greaterThanOrEqual
    expect(constraint88.secondItem) == "guide"
    expect(constraint88.secondObject?.value) === guide
    expect(constraint88.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint88.multiplier) == 2.0
    expect(constraint88.constant) == 10.0
    expect(constraint88.priority.rawValue) == 450.0
    expect(constraint88.identifier).to(beNil())

    let constraint89 = child1.width >= guide.height --> "identifier"
    expect(constraint89.firstItem) == "child1"
    expect(constraint89.firstObject?.value) === child1
    expect(constraint89.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint89.relation) == PseudoConstraint.Relation.greaterThanOrEqual
    expect(constraint89.secondItem) == "guide"
    expect(constraint89.secondObject?.value) === guide
    expect(constraint89.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint89.multiplier) == 1.0
    expect(constraint89.constant) == 0.0
    expect(constraint89.priority.rawValue) == UILayoutPriority.required.rawValue
    expect(constraint89.identifier) == "identifier"

    let constraint90 = child1.width >= guide.height * 2 --> "identifier"
    expect(constraint90.firstItem) == "child1"
    expect(constraint90.firstObject?.value) === child1
    expect(constraint90.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint90.relation) == PseudoConstraint.Relation.greaterThanOrEqual
    expect(constraint90.secondItem) == "guide"
    expect(constraint90.secondObject?.value) === guide
    expect(constraint90.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint90.multiplier) == 2.0
    expect(constraint90.constant) == 0.0
    expect(constraint90.priority.rawValue) == UILayoutPriority.required.rawValue
    expect(constraint90.identifier) == "identifier"

    let constraint91 = child1.width >= guide.height + 10 --> "identifier"
    expect(constraint91.firstItem) == "child1"
    expect(constraint91.firstObject?.value) === child1
    expect(constraint91.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint91.relation) == PseudoConstraint.Relation.greaterThanOrEqual
    expect(constraint91.secondItem) == "guide"
    expect(constraint91.secondObject?.value) === guide
    expect(constraint91.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint91.multiplier) == 1.0
    expect(constraint91.constant) == 10.0
    expect(constraint91.priority.rawValue) == UILayoutPriority.required.rawValue
    expect(constraint91.identifier) == "identifier"

    let constraint92 = child1.width >= guide.height * 2 + 10 --> "identifier"
    expect(constraint92.firstItem) == "child1"
    expect(constraint92.firstObject?.value) === child1
    expect(constraint92.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint92.relation) == PseudoConstraint.Relation.greaterThanOrEqual
    expect(constraint92.secondItem) == "guide"
    expect(constraint92.secondObject?.value) === guide
    expect(constraint92.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint92.multiplier) == 2.0
    expect(constraint92.constant) == 10.0
    expect(constraint92.priority.rawValue) == UILayoutPriority.required.rawValue
    expect(constraint92.identifier) == "identifier"

    let constraint93 = child1.width >= guide.height ! 450 --> "identifier"
    expect(constraint93.firstItem) == "child1"
    expect(constraint93.firstObject?.value) === child1
    expect(constraint93.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint93.relation) == PseudoConstraint.Relation.greaterThanOrEqual
    expect(constraint93.secondItem) == "guide"
    expect(constraint93.secondObject?.value) === guide
    expect(constraint93.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint93.multiplier) == 1.0
    expect(constraint93.constant) == 0.0
    expect(constraint93.priority.rawValue) == 450.0
    expect(constraint93.identifier) == "identifier"

    let constraint94 = child1.width >= guide.height * 2 ! 450 --> "identifier"
    expect(constraint94.firstItem) == "child1"
    expect(constraint94.firstObject?.value) === child1
    expect(constraint94.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint94.relation) == PseudoConstraint.Relation.greaterThanOrEqual
    expect(constraint94.secondItem) == "guide"
    expect(constraint94.secondObject?.value) === guide
    expect(constraint94.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint94.multiplier) == 2.0
    expect(constraint94.constant) == 0.0
    expect(constraint94.priority.rawValue) == 450.0
    expect(constraint94.identifier) == "identifier"

    let constraint95 = child1.width >= guide.height + 10 ! 450 --> "identifier"
    expect(constraint95.firstItem) == "child1"
    expect(constraint95.firstObject?.value) === child1
    expect(constraint95.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint95.relation) == PseudoConstraint.Relation.greaterThanOrEqual
    expect(constraint95.secondItem) == "guide"
    expect(constraint95.secondObject?.value) === guide
    expect(constraint95.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint95.multiplier) == 1.0
    expect(constraint95.constant) == 10.0
    expect(constraint95.priority.rawValue) == 450.0
    expect(constraint95.identifier) == "identifier"

    let constraint96 = child1.width >= guide.height * 2 + 10 ! 450 --> "identifier"
    expect(constraint96.firstItem) == "child1"
    expect(constraint96.firstObject?.value) === child1
    expect(constraint96.firstAttribute) == PseudoConstraint.Attribute.width
    expect(constraint96.relation) == PseudoConstraint.Relation.greaterThanOrEqual
    expect(constraint96.secondItem) == "guide"
    expect(constraint96.secondObject?.value) === guide
    expect(constraint96.secondAttribute) == PseudoConstraint.Attribute.height
    expect(constraint96.multiplier) == 2.0
    expect(constraint96.constant) == 10.0
    expect(constraint96.priority.rawValue) == 450.0
    expect(constraint96.identifier) == "identifier"
  }

  func testMultipleConstraints() {
    let (parent, child1, child2, _) = makeViews()

    let constraints1 = (𝗩∶[child1]|).constraints
    expect(constraints1) == [
      child1.bottom == parent.bottom
    ]

    let constraints2 = (𝗩∶[child1]-|).constraints
    expect(constraints2) == [
      child1.bottom == parent.bottom-20
    ]

    let constraints3 = (𝗩∶[child1]-10-|).constraints
    expect(constraints3) == [
      child1.bottom == parent.bottom-10
    ]

    let constraints4 = (𝗩∶|[child1]).constraints
    expect(constraints4) == [
      child1.top == parent.top
    ]

    let constraints5 = (𝗩∶|-[child1]).constraints
    expect(constraints5) == [
      child1.top == parent.top + 20
    ]

    let constraints6 = (𝗩∶|-10-[child1]).constraints
    expect(constraints6) == [
      child1.top == parent.top + 10
    ]

    let constraints7 = (𝗩∶[child1]-[child2]).constraints
    expect(constraints7) == [
      child2.top == child1.bottom + 8
    ]

    let constraints8 = (𝗩∶[child1]-10-[child2]).constraints
    expect(constraints8) == [
      child2.top == child1.bottom + 10
    ]

    let constraints9 = (𝗩∶[child1]-[child2]|).constraints
    expect(constraints9) == [
      child2.top == child1.bottom + 8,
      child2.bottom == parent.bottom
    ]

    let constraints10 = (𝗩∶[child1]-10-[child2]|).constraints
    expect(constraints10) == [
      child2.top == child1.bottom + 10,
      child2.bottom == parent.bottom
    ]

    let constraints11 = (𝗩∶[child1]-[child2]-|).constraints
    expect(constraints11) == [
      child2.top == child1.bottom + 8,
      child2.bottom == parent.bottom-20
    ]

    let constraints12 = (𝗩∶[child1]-10-[child2]-|).constraints
    expect(constraints12) == [
      child2.top == child1.bottom + 10,
      child2.bottom == parent.bottom-20
    ]

    let constraints13 = (𝗩∶[child1]-[child2]-10-|).constraints
    expect(constraints13) == [
      child2.top == child1.bottom + 8,
      child2.bottom == parent.bottom-10
    ]

    let constraints14 = (𝗩∶[child1]-10-[child2]-10-|).constraints
    expect(constraints14) == [
      child2.top == child1.bottom + 10,
      child2.bottom == parent.bottom-10
    ]

    let constraints15 = (𝗩∶|[child1]-[child2]).constraints
    expect(constraints15) == [
      child1.top == parent.top,
      child2.top == child1.bottom + 8
    ]

    let constraints16 = (𝗩∶|[child1]-10-[child2]).constraints
    expect(constraints16) == [
      child1.top == parent.top,
      child2.top == child1.bottom + 10
    ]

    let constraints17 = (𝗩∶|-[child1]-[child2]).constraints
    expect(constraints17) == [
      child1.top == parent.top + 20,
      child2.top == child1.bottom + 8
    ]

    let constraints18 = (𝗩∶|-[child1]-10-[child2]).constraints
    expect(constraints18) == [
      child1.top == parent.top + 20,
      child2.top == child1.bottom + 10
    ]

    let constraints19 = (𝗩∶|-10-[child1]-[child2]).constraints
    expect(constraints19) == [
      child1.top == parent.top + 10,
      child2.top == child1.bottom + 8
    ]

    let constraints20 = (𝗩∶|-10-[child1]-10-[child2]).constraints
    expect(constraints20) == [
      child1.top == parent.top + 10,
      child2.top == child1.bottom + 10
    ]

    let constraints21 = (𝗩∶|[child1]-[child2]|).constraints
    expect(constraints21) == [
      child1.top == parent.top,
      child2.top == child1.bottom + 8,
      child2.bottom == parent.bottom
    ]

    let constraints22 = (𝗩∶|[child1]-10-[child2]|).constraints
    expect(constraints22) == [
      child1.top == parent.top,
      child2.top == child1.bottom + 10,
      child2.bottom == parent.bottom
    ]

    let constraints23 = (𝗩∶|-[child1]-[child2]-|).constraints
    expect(constraints23) == [
      child1.top == parent.top + 20,
      child2.top == child1.bottom + 8,
      child2.bottom == parent.bottom-20
    ]

    let constraints24 = (𝗩∶|-[child1]-10-[child2]-|).constraints
    expect(constraints24) == [
      child1.top == parent.top + 20,
      child2.top == child1.bottom + 10,
      child2.bottom == parent.bottom-20
    ]

    let constraints25 = (𝗩∶|-10-[child1]-[child2]-10-|).constraints
    expect(constraints25) == [
      child1.top == parent.top + 10,
      child2.top == child1.bottom + 8,
      child2.bottom == parent.bottom-10
    ]

    let constraints26 = (𝗩∶|-10-[child1]-10-[child2]-10-|).constraints
    expect(constraints26) == [
      child1.top == parent.top + 10,
      child2.top == child1.bottom + 10,
      child2.bottom == parent.bottom-10
    ]

    let constraints27 = (𝗩∶|-10-[child1, ==child2]-10-[child2]-10-|).constraints
    expect(constraints27) == [
      child1.height == child2.height,
      child1.top == parent.top + 10,
      child2.top == child1.bottom + 10,
      child2.bottom == parent.bottom-10
    ]

    let constraints28 = (𝗩∶|-10-[child1, >=child2]-10-[child2]-10-|).constraints
    expect(constraints28) == [
      child1.height >= child2.height,
      child1.top == parent.top + 10,
      child2.top == child1.bottom + 10,
      child2.bottom == parent.bottom-10
    ]

    let constraints29 = (𝗩∶|-10-[child1, <=child2]-10-[child2]-10-|).constraints
    expect(constraints29) == [
      child1.height <= child2.height,
      child1.top == parent.top + 10,
      child2.top == child1.bottom + 10,
      child2.bottom == parent.bottom-10
    ]

    let constraints30 = (𝗩∶|-10-[child1, ==child2 ! 450]-10-[child2]-10-|).constraints
    expect(constraints30) == [
      child1.height == child2.height ! 450,
      child1.top == parent.top + 10,
      child2.top == child1.bottom + 10,
      child2.bottom == parent.bottom-10
    ]

    let constraints31 = (𝗩∶|-10-[child1, ==child2]-10-[child2, ==60]-10-|).constraints
    expect(constraints31) == [
      child1.height == child2.height,
      child1.top == parent.top + 10,
      child2.height == 60,
      child2.top == child1.bottom + 10,
      child2.bottom == parent.bottom-10
    ]

    let constraints32 = (𝗩∶|-10-[child1, ==child2]-10-[child2, >=60]-10-|).constraints
    expect(constraints32) == [
      child1.height == child2.height,
      child1.top == parent.top + 10,
      child2.height >= 60,
      child2.top == child1.bottom + 10,
      child2.bottom == parent.bottom-10
    ]

    let constraints33 = (𝗩∶|-10-[child1, ==child2]-10-[child2, <=60]-10-|).constraints
    expect(constraints33) == [
      child1.height == child2.height,
      child1.top == parent.top + 10,
      child2.height <= 60,
      child2.top == child1.bottom + 10,
      child2.bottom == parent.bottom-10
    ]

    let constraints34 = (𝗩∶|-10-[child1, ==child2]-10-[child2, ==60 ! 450]-10-|).constraints
    expect(constraints34) == [
      child1.height == child2.height,
      child1.top == parent.top + 10,
      child2.height == 60 ! 450,
      child2.top == child1.bottom + 10,
      child2.bottom == parent.bottom-10
    ]
  }
}
