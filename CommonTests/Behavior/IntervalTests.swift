//
//  IntervalTests.swift
//  MoonKit
//
//  Created by Jason Cardwell on 12/4/16.
//  Copyright © 2016 Jason Cardwell. All rights reserved.
//
@testable import MoonKit
import Nimble
import XCTest

final class IntervalTests: XCTestCase {
  let closedClosedInterval = 【7.9..8.6】
  let closedOpenInterval = 【7.9..8.6〗
  let openClosedInterval = 〖7.9..8.6】
  let openOpenInterval = 〖7.9..8.6〗
  let degenerateInterval = 【8.6..8.6】
  let backwardInterval = 【8.6..7.9】
  let emptyInterval = 【8.6..8.6〗

  func testDirectedIntervalComparable() {
    expect(【0.5) < 【1.0
    expect(〖0.5) < 【1.0
    expect(【0.5) < 〖1.0
    expect(〖0.5) < 〖1.0
    expect(【0.5) < 1.0〗
    expect(〖0.5) < 1.0〗
    expect(【0.5) < 1.0】
    expect(〖0.5) < 1.0】

    expect(【1.5) > 【1.0
    expect(〖1.5) > 【1.0
    expect(【1.5) > 〖1.0
    expect(〖1.5) > 〖1.0
    expect(【1.5) > 1.0〗
    expect(〖1.5) > 1.0〗
    expect(【1.5) > 1.0】
    expect(〖1.5) > 1.0】

    expect(【1.0) < 〖1.0
    expect(【1.0) < 1.0〗
    expect(【1.0) < 1.0】

    expect(〖1.0) < 1.0〗
    expect(〖1.0) < 1.0】

    expect(1.0〗) < 1.0】
  }

  func testIntervalComparison() {
    expect((【3.0..4.0】).compare(to: 【3.0..3.0〗)) == IntervalComparisonResult.undefined
    expect((【3.0..3.0〗).compare(to: 【3.0..4.0】)) == IntervalComparisonResult.undefined
    expect((【3.0..3.0〗).compare(to: 【4.0..3.0】)) == IntervalComparisonResult.undefined
    expect((【4.0..3.0】).compare(to: 【3.0..3.0〗)) == IntervalComparisonResult.undefined

    expect((【3.0..4.0】).compare(to: 【5.0..6.0】)) == IntervalComparisonResult.ascending
    expect((【3.0..5.0〗).compare(to: 【5.0..6.0】)) == IntervalComparisonResult.ascendingJoin
    expect((【3.0..5.0】).compare(to: 【5.0..6.0】)) == IntervalComparisonResult.ascendingOverlap
    expect((【2.0..6.0】).compare(to: 【3.0..5.0】)) == IntervalComparisonResult.ascendingContainment
    expect((【3.0..5.0】).compare(to: 【3.0..5.0】)) == IntervalComparisonResult.same
    expect((【5.0..6.0】).compare(to: 【3.0..5.0〗)) == IntervalComparisonResult.descendingJoin
    expect((【5.0..6.0】).compare(to: 【3.0..5.0】)) == IntervalComparisonResult.descendingOverlap
    expect((【3.0..5.0】).compare(to: 【2.0..6.0】)) == IntervalComparisonResult.descendingContainment
    expect((【5.0..6.0】).compare(to: 【3.0..4.0】)) == IntervalComparisonResult.descending

    expect(self.openClosedInterval.compare(to: 【6.3..7.9〗)) == IntervalComparisonResult.descending
    expect(self.closedClosedInterval.compare(to: 【7.9..8.0】)) == IntervalComparisonResult.ascendingContainment
  }

  func testCreation() {
    expect(self.closedClosedInterval.lower.value) == 7.9
    expect(self.closedClosedInterval.upper.value) == 8.6
    expect(self.closedClosedInterval.leastElement) == 7.9
    expect(self.closedClosedInterval.greatestElement) == 8.6
    expect(self.closedClosedInterval.lower.kind) == IntervalEndpointKind.closed
    expect(self.closedClosedInterval.upper.kind) == IntervalEndpointKind.closed
    expect(self.closedClosedInterval.isDegenerate) == false
    expect(self.closedClosedInterval.isEmpty) == false

    expect(self.closedOpenInterval.lower.value) == 7.9
    expect(self.closedOpenInterval.upper.value) == 8.6
    expect(self.closedOpenInterval.leastElement) == 7.9
    expect(self.closedOpenInterval.greatestElement).to(beNil())
    expect(self.closedOpenInterval.lower.kind) == IntervalEndpointKind.closed
    expect(self.closedOpenInterval.upper.kind) == IntervalEndpointKind.open
    expect(self.closedOpenInterval.isDegenerate) == false
    expect(self.closedOpenInterval.isEmpty) == false

    expect(self.openClosedInterval.lower.value) == 7.9
    expect(self.openClosedInterval.upper.value) == 8.6
    expect(self.openClosedInterval.leastElement).to(beNil())
    expect(self.openClosedInterval.greatestElement) == 8.6
    expect(self.openClosedInterval.lower.kind) == IntervalEndpointKind.open
    expect(self.openClosedInterval.upper.kind) == IntervalEndpointKind.closed
    expect(self.openClosedInterval.isDegenerate) == false
    expect(self.openClosedInterval.isEmpty) == false

    expect(self.openOpenInterval.lower.value) == 7.9
    expect(self.openOpenInterval.upper.value) == 8.6
    expect(self.openOpenInterval.leastElement).to(beNil())
    expect(self.openOpenInterval.greatestElement).to(beNil())
    expect(self.openOpenInterval.lower.kind) == IntervalEndpointKind.open
    expect(self.openOpenInterval.upper.kind) == IntervalEndpointKind.open
    expect(self.openOpenInterval.isDegenerate) == false
    expect(self.openOpenInterval.isEmpty) == false

    expect(self.degenerateInterval.lower.value) == 8.6
    expect(self.degenerateInterval.upper.value) == 8.6
    expect(self.degenerateInterval.leastElement) == 8.6
    expect(self.degenerateInterval.greatestElement) == 8.6
    expect(self.degenerateInterval.lower.kind) == IntervalEndpointKind.closed
    expect(self.degenerateInterval.upper.kind) == IntervalEndpointKind.closed
    expect(self.degenerateInterval.isDegenerate) == true
    expect(self.degenerateInterval.isEmpty) == false

    expect(self.backwardInterval.lower.value) == 8.6
    expect(self.backwardInterval.upper.value) == 7.9
    expect(self.backwardInterval.leastElement) == 8.6
    expect(self.backwardInterval.greatestElement) == 7.9
    expect(self.backwardInterval.lower.kind) == IntervalEndpointKind.closed
    expect(self.backwardInterval.upper.kind) == IntervalEndpointKind.closed
    expect(self.backwardInterval.isDegenerate) == false
    expect(self.backwardInterval.isEmpty) == true

    expect(self.emptyInterval.lower.value) == 8.6
    expect(self.emptyInterval.upper.value) == 8.6
    expect(self.emptyInterval.leastElement) == 8.6
    expect(self.emptyInterval.greatestElement).to(beNil())
    expect(self.emptyInterval.lower.kind) == IntervalEndpointKind.closed
    expect(self.emptyInterval.upper.kind) == IntervalEndpointKind.open
    expect(self.emptyInterval.isDegenerate) == false
    expect(self.emptyInterval.isEmpty) == true
  }

  func testContainsBound() {
    expect(self.closedClosedInterval.contains(6.9)) == false
    expect(self.closedClosedInterval.contains(7.9)) == true
    expect(self.closedClosedInterval.contains(8.0)) == true
    expect(self.closedClosedInterval.contains(8.6)) == true
    expect(self.closedClosedInterval.contains(8.9)) == false

    expect(self.closedOpenInterval.contains(6.9)) == false
    expect(self.closedOpenInterval.contains(7.9)) == true
    expect(self.closedOpenInterval.contains(8.0)) == true
    expect(self.closedOpenInterval.contains(8.6)) == false
    expect(self.closedOpenInterval.contains(8.9)) == false

    expect(self.openClosedInterval.contains(6.9)) == false
    expect(self.openClosedInterval.contains(7.9)) == false
    expect(self.openClosedInterval.contains(8.0)) == true
    expect(self.openClosedInterval.contains(8.6)) == true
    expect(self.openClosedInterval.contains(8.9)) == false

    expect(self.openOpenInterval.contains(6.9)) == false
    expect(self.openOpenInterval.contains(7.9)) == false
    expect(self.openOpenInterval.contains(8.0)) == true
    expect(self.openOpenInterval.contains(8.6)) == false
    expect(self.openOpenInterval.contains(8.9)) == false

    expect(self.degenerateInterval.contains(6.9)) == false
    expect(self.degenerateInterval.contains(7.9)) == false
    expect(self.degenerateInterval.contains(8.0)) == false
    expect(self.degenerateInterval.contains(8.6)) == true
    expect(self.degenerateInterval.contains(8.9)) == false

    expect(self.backwardInterval.contains(6.9)) == false
    expect(self.backwardInterval.contains(7.9)) == false
    expect(self.backwardInterval.contains(8.0)) == false
    expect(self.backwardInterval.contains(8.6)) == false
    expect(self.backwardInterval.contains(8.9)) == false

    expect(self.emptyInterval.contains(6.9)) == false
    expect(self.emptyInterval.contains(7.9)) == false
    expect(self.emptyInterval.contains(8.0)) == false
    expect(self.emptyInterval.contains(8.6)) == false
    expect(self.emptyInterval.contains(8.9)) == false
  }

  func testContainsInterval() {
    expect(self.closedClosedInterval.contains(【7.9..8.0】)) == true
    expect(self.closedClosedInterval.contains(【6.3..7.9】)) == false
    expect(self.closedClosedInterval.contains(【8.0..8.0】)) == true
    expect(self.closedClosedInterval.contains(【8.3..8.5】)) == true
    expect(self.closedClosedInterval.contains(【8.3..8.6】)) == true
    expect(self.closedClosedInterval.contains(【8.9..9.9】)) == false
    expect(self.closedClosedInterval.contains(【6.3..9.9】)) == false

    expect(self.closedOpenInterval.contains(【7.9..8.0】)) == true
    expect(self.closedOpenInterval.contains(【6.3..7.9】)) == false
    expect(self.closedOpenInterval.contains(【8.0..8.0】)) == true
    expect(self.closedOpenInterval.contains(【8.3..8.5】)) == true
    expect(self.closedOpenInterval.contains(【8.3..8.6】)) == false
    expect(self.closedOpenInterval.contains(【8.9..9.9】)) == false
    expect(self.closedOpenInterval.contains(【6.3..9.9】)) == false

    expect(self.openClosedInterval.contains(【7.9..8.0】)) == false
    expect(self.openClosedInterval.contains(【6.3..7.9】)) == false
    expect(self.openClosedInterval.contains(【8.0..8.0】)) == true
    expect(self.openClosedInterval.contains(【8.3..8.5】)) == true
    expect(self.openClosedInterval.contains(【8.3..8.6】)) == true
    expect(self.openClosedInterval.contains(【8.9..9.9】)) == false
    expect(self.openClosedInterval.contains(【6.3..9.9】)) == false

    expect(self.openOpenInterval.contains(【7.9..8.0】)) == false
    expect(self.openOpenInterval.contains(【6.3..7.9】)) == false
    expect(self.openOpenInterval.contains(【8.0..8.0】)) == true
    expect(self.openOpenInterval.contains(【8.3..8.5】)) == true
    expect(self.openOpenInterval.contains(【8.3..8.6】)) == false
    expect(self.openOpenInterval.contains(【8.9..9.9】)) == false
    expect(self.openOpenInterval.contains(【6.3..9.9】)) == false

    expect(self.degenerateInterval.contains(【7.9..8.0】)) == false
    expect(self.degenerateInterval.contains(【6.3..7.9】)) == false
    expect(self.degenerateInterval.contains(【8.0..8.0】)) == false
    expect(self.degenerateInterval.contains(【8.3..8.5】)) == false
    expect(self.degenerateInterval.contains(【8.3..8.6】)) == false
    expect(self.degenerateInterval.contains(【8.9..9.9】)) == false
    expect(self.degenerateInterval.contains(【6.3..9.9】)) == false

    expect(self.backwardInterval.contains(【7.9..8.0】)) == false
    expect(self.backwardInterval.contains(【6.3..7.9】)) == false
    expect(self.backwardInterval.contains(【8.0..8.0】)) == false
    expect(self.backwardInterval.contains(【8.3..8.5】)) == false
    expect(self.backwardInterval.contains(【8.3..8.6】)) == false
    expect(self.backwardInterval.contains(【8.9..9.9】)) == false
    expect(self.backwardInterval.contains(【6.3..9.9】)) == false

    expect(self.emptyInterval.contains(【7.9..8.0】)) == false
    expect(self.emptyInterval.contains(【6.3..7.9】)) == false
    expect(self.emptyInterval.contains(【8.0..8.0】)) == false
    expect(self.emptyInterval.contains(【8.3..8.5】)) == false
    expect(self.emptyInterval.contains(【8.3..8.6】)) == false
    expect(self.emptyInterval.contains(【8.9..9.9】)) == false
    expect(self.emptyInterval.contains(【6.3..9.9】)) == false

    expect(self.closedClosedInterval.contains(【7.9..8.0〗)) == true
    expect(self.closedClosedInterval.contains(【6.3..7.9〗)) == false
    expect(self.closedClosedInterval.contains(【8.0..8.0〗)) == false
    expect(self.closedClosedInterval.contains(【8.3..8.5〗)) == true
    expect(self.closedClosedInterval.contains(【8.3..8.6〗)) == true
    expect(self.closedClosedInterval.contains(【8.9..9.9〗)) == false
    expect(self.closedClosedInterval.contains(【6.3..9.9〗)) == false

    expect(self.closedOpenInterval.contains(【7.9..8.0〗)) == true
    expect(self.closedOpenInterval.contains(【6.3..7.9〗)) == false
    expect(self.closedOpenInterval.contains(【8.0..8.0〗)) == false
    expect(self.closedOpenInterval.contains(【8.3..8.5〗)) == true
    expect(self.closedOpenInterval.contains(【8.3..8.6〗)) == true
    expect(self.closedOpenInterval.contains(【8.9..9.9〗)) == false
    expect(self.closedOpenInterval.contains(【6.3..9.9〗)) == false

    expect(self.openClosedInterval.contains(【7.9..8.0〗)) == false
    expect(self.openClosedInterval.contains(【6.3..7.9〗)) == false
    expect(self.openClosedInterval.contains(【8.0..8.0〗)) == false
    expect(self.openClosedInterval.contains(【8.3..8.5〗)) == true
    expect(self.openClosedInterval.contains(【8.3..8.6〗)) == true
    expect(self.openClosedInterval.contains(【8.9..9.9〗)) == false
    expect(self.openClosedInterval.contains(【6.3..9.9〗)) == false

    expect(self.openOpenInterval.contains(【7.9..8.0〗)) == false
    expect(self.openOpenInterval.contains(【6.3..7.9〗)) == false
    expect(self.openOpenInterval.contains(【8.0..8.0〗)) == false
    expect(self.openOpenInterval.contains(【8.3..8.5〗)) == true
    expect(self.openOpenInterval.contains(【8.3..8.6〗)) == true
    expect(self.openOpenInterval.contains(【8.9..9.9〗)) == false
    expect(self.openOpenInterval.contains(【6.3..9.9〗)) == false

    expect(self.degenerateInterval.contains(【7.9..8.0〗)) == false
    expect(self.degenerateInterval.contains(【6.3..7.9〗)) == false
    expect(self.degenerateInterval.contains(【8.0..8.0〗)) == false
    expect(self.degenerateInterval.contains(【8.3..8.5〗)) == false
    expect(self.degenerateInterval.contains(【8.3..8.6〗)) == false
    expect(self.degenerateInterval.contains(【8.9..9.9〗)) == false
    expect(self.degenerateInterval.contains(【6.3..9.9〗)) == false

    expect(self.backwardInterval.contains(【7.9..8.0〗)) == false
    expect(self.backwardInterval.contains(【6.3..7.9〗)) == false
    expect(self.backwardInterval.contains(【8.0..8.0〗)) == false
    expect(self.backwardInterval.contains(【8.3..8.5〗)) == false
    expect(self.backwardInterval.contains(【8.3..8.6〗)) == false
    expect(self.backwardInterval.contains(【8.9..9.9〗)) == false
    expect(self.backwardInterval.contains(【6.3..9.9〗)) == false

    expect(self.emptyInterval.contains(【7.9..8.0〗)) == false
    expect(self.emptyInterval.contains(【6.3..7.9〗)) == false
    expect(self.emptyInterval.contains(【8.0..8.0〗)) == false
    expect(self.emptyInterval.contains(【8.3..8.5〗)) == false
    expect(self.emptyInterval.contains(【8.3..8.6〗)) == false
    expect(self.emptyInterval.contains(【8.9..9.9〗)) == false
    expect(self.emptyInterval.contains(【6.3..9.9〗)) == false

    expect(self.closedClosedInterval.contains(〖7.9..8.0】)) == true
    expect(self.closedClosedInterval.contains(〖6.3..7.9】)) == false
    expect(self.closedClosedInterval.contains(〖8.0..8.0】)) == false
    expect(self.closedClosedInterval.contains(〖8.3..8.5】)) == true
    expect(self.closedClosedInterval.contains(〖8.3..8.6】)) == true
    expect(self.closedClosedInterval.contains(〖8.9..9.9】)) == false
    expect(self.closedClosedInterval.contains(〖6.3..9.9】)) == false

    expect(self.closedOpenInterval.contains(〖7.9..8.0】)) == true
    expect(self.closedOpenInterval.contains(〖6.3..7.9】)) == false
    expect(self.closedOpenInterval.contains(〖8.0..8.0】)) == false
    expect(self.closedOpenInterval.contains(〖8.3..8.5】)) == true
    expect(self.closedOpenInterval.contains(〖8.3..8.6】)) == false
    expect(self.closedOpenInterval.contains(〖8.9..9.9】)) == false
    expect(self.closedOpenInterval.contains(〖6.3..9.9】)) == false

    expect(self.openClosedInterval.contains(〖7.9..8.0】)) == true
    expect(self.openClosedInterval.contains(〖6.3..7.9】)) == false
    expect(self.openClosedInterval.contains(〖8.0..8.0】)) == false
    expect(self.openClosedInterval.contains(〖8.3..8.5】)) == true
    expect(self.openClosedInterval.contains(〖8.3..8.6】)) == true
    expect(self.openClosedInterval.contains(〖8.9..9.9】)) == false
    expect(self.openClosedInterval.contains(〖6.3..9.9】)) == false

    expect(self.openOpenInterval.contains(〖7.9..8.0】)) == true
    expect(self.openOpenInterval.contains(〖6.3..7.9】)) == false
    expect(self.openOpenInterval.contains(〖8.0..8.0】)) == false
    expect(self.openOpenInterval.contains(〖8.3..8.5】)) == true
    expect(self.openOpenInterval.contains(〖8.3..8.6】)) == false
    expect(self.openOpenInterval.contains(〖8.9..9.9】)) == false
    expect(self.openOpenInterval.contains(〖6.3..9.9】)) == false

    expect(self.degenerateInterval.contains(〖7.9..8.0】)) == false
    expect(self.degenerateInterval.contains(〖6.3..7.9】)) == false
    expect(self.degenerateInterval.contains(〖8.0..8.0】)) == false
    expect(self.degenerateInterval.contains(〖8.3..8.5】)) == false
    expect(self.degenerateInterval.contains(〖8.3..8.6】)) == false
    expect(self.degenerateInterval.contains(〖8.9..9.9】)) == false
    expect(self.degenerateInterval.contains(〖6.3..9.9】)) == false

    expect(self.backwardInterval.contains(〖7.9..8.0】)) == false
    expect(self.backwardInterval.contains(〖6.3..7.9】)) == false
    expect(self.backwardInterval.contains(〖8.0..8.0】)) == false
    expect(self.backwardInterval.contains(〖8.3..8.5】)) == false
    expect(self.backwardInterval.contains(〖8.3..8.6】)) == false
    expect(self.backwardInterval.contains(〖8.9..9.9】)) == false
    expect(self.backwardInterval.contains(〖6.3..9.9】)) == false

    expect(self.emptyInterval.contains(〖7.9..8.0】)) == false
    expect(self.emptyInterval.contains(〖6.3..7.9】)) == false
    expect(self.emptyInterval.contains(〖8.0..8.0】)) == false
    expect(self.emptyInterval.contains(〖8.3..8.5】)) == false
    expect(self.emptyInterval.contains(〖8.3..8.6】)) == false
    expect(self.emptyInterval.contains(〖8.9..9.9】)) == false
    expect(self.emptyInterval.contains(〖6.3..9.9】)) == false

    expect(self.closedClosedInterval.contains(〖7.9..8.0〗)) == true
    expect(self.closedClosedInterval.contains(〖6.3..7.9〗)) == false
    expect(self.closedClosedInterval.contains(〖8.0..8.0〗)) == false
    expect(self.closedClosedInterval.contains(〖8.3..8.5〗)) == true
    expect(self.closedClosedInterval.contains(〖8.3..8.6〗)) == true
    expect(self.closedClosedInterval.contains(〖8.9..9.9〗)) == false
    expect(self.closedClosedInterval.contains(〖6.3..9.9〗)) == false

    expect(self.closedOpenInterval.contains(〖7.9..8.0〗)) == true
    expect(self.closedOpenInterval.contains(〖6.3..7.9〗)) == false
    expect(self.closedOpenInterval.contains(〖8.0..8.0〗)) == false
    expect(self.closedOpenInterval.contains(〖8.3..8.5〗)) == true
    expect(self.closedOpenInterval.contains(〖8.3..8.6〗)) == true
    expect(self.closedOpenInterval.contains(〖8.9..9.9〗)) == false
    expect(self.closedOpenInterval.contains(〖6.3..9.9〗)) == false

    expect(self.openClosedInterval.contains(〖7.9..8.0〗)) == true
    expect(self.openClosedInterval.contains(〖6.3..7.9〗)) == false
    expect(self.openClosedInterval.contains(〖8.0..8.0〗)) == false
    expect(self.openClosedInterval.contains(〖8.3..8.5〗)) == true
    expect(self.openClosedInterval.contains(〖8.3..8.6〗)) == true
    expect(self.openClosedInterval.contains(〖8.9..9.9〗)) == false
    expect(self.openClosedInterval.contains(〖6.3..9.9〗)) == false

    expect(self.openOpenInterval.contains(〖7.9..8.0〗)) == true
    expect(self.openOpenInterval.contains(〖6.3..7.9〗)) == false
    expect(self.openOpenInterval.contains(〖8.0..8.0〗)) == false
    expect(self.openOpenInterval.contains(〖8.3..8.5〗)) == true
    expect(self.openOpenInterval.contains(〖8.3..8.6〗)) == true
    expect(self.openOpenInterval.contains(〖8.9..9.9〗)) == false
    expect(self.openOpenInterval.contains(〖6.3..9.9〗)) == false

    expect(self.degenerateInterval.contains(〖7.9..8.0〗)) == false
    expect(self.degenerateInterval.contains(〖6.3..7.9〗)) == false
    expect(self.degenerateInterval.contains(〖8.0..8.0〗)) == false
    expect(self.degenerateInterval.contains(〖8.3..8.5〗)) == false
    expect(self.degenerateInterval.contains(〖8.3..8.6〗)) == false
    expect(self.degenerateInterval.contains(〖8.9..9.9〗)) == false
    expect(self.degenerateInterval.contains(〖6.3..9.9〗)) == false

    expect(self.backwardInterval.contains(〖7.9..8.0〗)) == false
    expect(self.backwardInterval.contains(〖6.3..7.9〗)) == false
    expect(self.backwardInterval.contains(〖8.0..8.0〗)) == false
    expect(self.backwardInterval.contains(〖8.3..8.5〗)) == false
    expect(self.backwardInterval.contains(〖8.3..8.6〗)) == false
    expect(self.backwardInterval.contains(〖8.9..9.9〗)) == false
    expect(self.backwardInterval.contains(〖6.3..9.9〗)) == false

    expect(self.emptyInterval.contains(〖7.9..8.0〗)) == false
    expect(self.emptyInterval.contains(〖6.3..7.9〗)) == false
    expect(self.emptyInterval.contains(〖8.0..8.0〗)) == false
    expect(self.emptyInterval.contains(〖8.3..8.5〗)) == false
    expect(self.emptyInterval.contains(〖8.3..8.6〗)) == false
    expect(self.emptyInterval.contains(〖8.9..9.9〗)) == false
    expect(self.emptyInterval.contains(〖6.3..9.9〗)) == false
  }

  func testOverlaps() {
    expect(self.closedClosedInterval.overlaps(【6.3..6.9】)) == false
    expect(self.closedClosedInterval.overlaps(【6.3..7.9】)) == true
    expect(self.closedClosedInterval.overlaps(【6.3..8.0】)) == true
    expect(self.closedClosedInterval.overlaps(【8.3..9.9】)) == true
    expect(self.closedClosedInterval.overlaps(【8.6..9.9】)) == true
    expect(self.closedClosedInterval.overlaps(【8.9..9.9】)) == false
    expect(self.closedClosedInterval.overlaps(【6.3..9.9】)) == true

    expect(self.closedOpenInterval.overlaps(【6.3..6.9】)) == false
    expect(self.closedOpenInterval.overlaps(【6.3..7.9】)) == true
    expect(self.closedOpenInterval.overlaps(【6.3..8.0】)) == true
    expect(self.closedOpenInterval.overlaps(【8.3..9.9】)) == true
    expect(self.closedOpenInterval.overlaps(【8.6..9.9】)) == false
    expect(self.closedOpenInterval.overlaps(【8.9..9.9】)) == false
    expect(self.closedOpenInterval.overlaps(【6.3..9.9】)) == true

    expect(self.openClosedInterval.overlaps(【6.3..6.9】)) == false
    expect(self.openClosedInterval.overlaps(【6.3..7.9】)) == false
    expect(self.openClosedInterval.overlaps(【6.3..8.0】)) == true
    expect(self.openClosedInterval.overlaps(【8.3..9.9】)) == true
    expect(self.openClosedInterval.overlaps(【8.6..9.9】)) == true
    expect(self.openClosedInterval.overlaps(【8.9..9.9】)) == false
    expect(self.openClosedInterval.overlaps(【6.3..9.9】)) == true

    expect(self.openOpenInterval.overlaps(【6.3..6.9】)) == false
    expect(self.openOpenInterval.overlaps(【6.3..7.9】)) == false
    expect(self.openOpenInterval.overlaps(【6.3..8.0】)) == true
    expect(self.openOpenInterval.overlaps(【8.3..9.9】)) == true
    expect(self.openOpenInterval.overlaps(【8.6..9.9】)) == false
    expect(self.openOpenInterval.overlaps(【8.9..9.9】)) == false
    expect(self.openOpenInterval.overlaps(【6.3..9.9】)) == true

    expect(self.degenerateInterval.overlaps(【6.3..6.9】)) == false
    expect(self.degenerateInterval.overlaps(【6.3..7.9】)) == false
    expect(self.degenerateInterval.overlaps(【6.3..8.0】)) == false
    expect(self.degenerateInterval.overlaps(【8.3..9.9】)) == true
    expect(self.degenerateInterval.overlaps(【8.6..9.9】)) == true
    expect(self.degenerateInterval.overlaps(【8.9..9.9】)) == false
    expect(self.degenerateInterval.overlaps(【6.3..9.9】)) == true

    expect(self.backwardInterval.overlaps(【6.3..6.9】)) == false
    expect(self.backwardInterval.overlaps(【6.3..7.9】)) == false
    expect(self.backwardInterval.overlaps(【6.3..8.0】)) == false
    expect(self.backwardInterval.overlaps(【8.3..9.9】)) == false
    expect(self.backwardInterval.overlaps(【8.6..9.9】)) == false
    expect(self.backwardInterval.overlaps(【8.9..9.9】)) == false
    expect(self.backwardInterval.overlaps(【6.3..9.9】)) == false

    expect(self.emptyInterval.overlaps(【6.3..6.9】)) == false
    expect(self.emptyInterval.overlaps(【6.3..7.9】)) == false
    expect(self.emptyInterval.overlaps(【6.3..8.0】)) == false
    expect(self.emptyInterval.overlaps(【8.3..9.9】)) == false
    expect(self.emptyInterval.overlaps(【8.6..9.9】)) == false
    expect(self.emptyInterval.overlaps(【8.9..9.9】)) == false
    expect(self.emptyInterval.overlaps(【6.3..9.9】)) == false

    expect(self.closedClosedInterval.overlaps(【6.3..6.9〗)) == false
    expect(self.closedClosedInterval.overlaps(【6.3..7.9〗)) == false
    expect(self.closedClosedInterval.overlaps(【6.3..8.0〗)) == true
    expect(self.closedClosedInterval.overlaps(【8.3..9.9〗)) == true
    expect(self.closedClosedInterval.overlaps(【8.6..9.9〗)) == true
    expect(self.closedClosedInterval.overlaps(【8.9..9.9〗)) == false
    expect(self.closedClosedInterval.overlaps(【6.3..9.9〗)) == true

    expect(self.closedOpenInterval.overlaps(【6.3..6.9〗)) == false
    expect(self.closedOpenInterval.overlaps(【6.3..7.9〗)) == false
    expect(self.closedOpenInterval.overlaps(【6.3..8.0〗)) == true
    expect(self.closedOpenInterval.overlaps(【8.3..9.9〗)) == true
    expect(self.closedOpenInterval.overlaps(【8.6..9.9〗)) == false
    expect(self.closedOpenInterval.overlaps(【8.9..9.9〗)) == false
    expect(self.closedOpenInterval.overlaps(【6.3..9.9〗)) == true

    expect(self.openClosedInterval.overlaps(【6.3..6.9〗)) == false
    expect(self.openClosedInterval.overlaps(【6.3..7.9〗)) == false
    expect(self.openClosedInterval.overlaps(【6.3..8.0〗)) == true
    expect(self.openClosedInterval.overlaps(【8.3..9.9〗)) == true
    expect(self.openClosedInterval.overlaps(【8.6..9.9〗)) == true
    expect(self.openClosedInterval.overlaps(【8.9..9.9〗)) == false
    expect(self.openClosedInterval.overlaps(【6.3..9.9〗)) == true

    expect(self.openOpenInterval.overlaps(【6.3..6.9〗)) == false
    expect(self.openOpenInterval.overlaps(【6.3..7.9〗)) == false
    expect(self.openOpenInterval.overlaps(【6.3..8.0〗)) == true
    expect(self.openOpenInterval.overlaps(【8.3..9.9〗)) == true
    expect(self.openOpenInterval.overlaps(【8.6..9.9〗)) == false
    expect(self.openOpenInterval.overlaps(【8.9..9.9〗)) == false
    expect(self.openOpenInterval.overlaps(【6.3..9.9〗)) == true

    expect(self.degenerateInterval.overlaps(【6.3..6.9〗)) == false
    expect(self.degenerateInterval.overlaps(【6.3..7.9〗)) == false
    expect(self.degenerateInterval.overlaps(【6.3..8.0〗)) == false
    expect(self.degenerateInterval.overlaps(【8.3..9.9〗)) == true
    expect(self.degenerateInterval.overlaps(【8.6..9.9〗)) == true
    expect(self.degenerateInterval.overlaps(【8.9..9.9〗)) == false
    expect(self.degenerateInterval.overlaps(【6.3..9.9〗)) == true

    expect(self.backwardInterval.overlaps(【6.3..6.9〗)) == false
    expect(self.backwardInterval.overlaps(【6.3..7.9〗)) == false
    expect(self.backwardInterval.overlaps(【6.3..8.0〗)) == false
    expect(self.backwardInterval.overlaps(【8.3..9.9〗)) == false
    expect(self.backwardInterval.overlaps(【8.6..9.9〗)) == false
    expect(self.backwardInterval.overlaps(【8.9..9.9〗)) == false
    expect(self.backwardInterval.overlaps(【6.3..9.9〗)) == false

    expect(self.emptyInterval.overlaps(【6.3..6.9〗)) == false
    expect(self.emptyInterval.overlaps(【6.3..7.9〗)) == false
    expect(self.emptyInterval.overlaps(【6.3..8.0〗)) == false
    expect(self.emptyInterval.overlaps(【8.3..9.9〗)) == false
    expect(self.emptyInterval.overlaps(【8.6..9.9〗)) == false
    expect(self.emptyInterval.overlaps(【8.9..9.9〗)) == false
    expect(self.emptyInterval.overlaps(【6.3..9.9〗)) == false

    expect(self.closedClosedInterval.overlaps(〖6.3..6.9】)) == false
    expect(self.closedClosedInterval.overlaps(〖6.3..7.9】)) == true
    expect(self.closedClosedInterval.overlaps(〖6.3..8.0】)) == true
    expect(self.closedClosedInterval.overlaps(〖8.3..9.9】)) == true
    expect(self.closedClosedInterval.overlaps(〖8.6..9.9】)) == false
    expect(self.closedClosedInterval.overlaps(〖8.9..9.9】)) == false
    expect(self.closedClosedInterval.overlaps(〖6.3..9.9】)) == true

    expect(self.closedOpenInterval.overlaps(〖6.3..6.9】)) == false
    expect(self.closedOpenInterval.overlaps(〖6.3..7.9】)) == true
    expect(self.closedOpenInterval.overlaps(〖6.3..8.0】)) == true
    expect(self.closedOpenInterval.overlaps(〖8.3..9.9】)) == true
    expect(self.closedOpenInterval.overlaps(〖8.6..9.9】)) == false
    expect(self.closedOpenInterval.overlaps(〖8.9..9.9】)) == false
    expect(self.closedOpenInterval.overlaps(〖6.3..9.9】)) == true

    expect(self.openClosedInterval.overlaps(〖6.3..6.9】)) == false
    expect(self.openClosedInterval.overlaps(〖6.3..7.9】)) == false
    expect(self.openClosedInterval.overlaps(〖6.3..8.0】)) == true
    expect(self.openClosedInterval.overlaps(〖8.3..9.9】)) == true
    expect(self.openClosedInterval.overlaps(〖8.6..9.9】)) == false
    expect(self.openClosedInterval.overlaps(〖8.9..9.9】)) == false
    expect(self.openClosedInterval.overlaps(〖6.3..9.9】)) == true

    expect(self.openOpenInterval.overlaps(〖6.3..6.9】)) == false
    expect(self.openOpenInterval.overlaps(〖6.3..7.9】)) == false
    expect(self.openOpenInterval.overlaps(〖6.3..8.0】)) == true
    expect(self.openOpenInterval.overlaps(〖8.3..9.9】)) == true
    expect(self.openOpenInterval.overlaps(〖8.6..9.9】)) == false
    expect(self.openOpenInterval.overlaps(〖8.9..9.9】)) == false
    expect(self.openOpenInterval.overlaps(〖6.3..9.9】)) == true

    expect(self.degenerateInterval.overlaps(〖6.3..6.9】)) == false
    expect(self.degenerateInterval.overlaps(〖6.3..7.9】)) == false
    expect(self.degenerateInterval.overlaps(〖6.3..8.0】)) == false
    expect(self.degenerateInterval.overlaps(〖8.3..9.9】)) == true
    expect(self.degenerateInterval.overlaps(〖8.6..9.9】)) == false
    expect(self.degenerateInterval.overlaps(〖8.9..9.9】)) == false
    expect(self.degenerateInterval.overlaps(〖6.3..9.9】)) == true

    expect(self.backwardInterval.overlaps(〖6.3..6.9】)) == false
    expect(self.backwardInterval.overlaps(〖6.3..7.9】)) == false
    expect(self.backwardInterval.overlaps(〖6.3..8.0】)) == false
    expect(self.backwardInterval.overlaps(〖8.3..9.9】)) == false
    expect(self.backwardInterval.overlaps(〖8.6..9.9】)) == false
    expect(self.backwardInterval.overlaps(〖8.9..9.9】)) == false
    expect(self.backwardInterval.overlaps(〖6.3..9.9】)) == false

    expect(self.emptyInterval.overlaps(〖6.3..6.9】)) == false
    expect(self.emptyInterval.overlaps(〖6.3..7.9】)) == false
    expect(self.emptyInterval.overlaps(〖6.3..8.0】)) == false
    expect(self.emptyInterval.overlaps(〖8.3..9.9】)) == false
    expect(self.emptyInterval.overlaps(〖8.6..9.9】)) == false
    expect(self.emptyInterval.overlaps(〖8.9..9.9】)) == false
    expect(self.emptyInterval.overlaps(〖6.3..9.9】)) == false

    expect(self.closedClosedInterval.overlaps(〖6.3..6.9〗)) == false
    expect(self.closedClosedInterval.overlaps(〖6.3..7.9〗)) == false
    expect(self.closedClosedInterval.overlaps(〖6.3..8.0〗)) == true
    expect(self.closedClosedInterval.overlaps(〖8.3..9.9〗)) == true
    expect(self.closedClosedInterval.overlaps(〖8.6..9.9〗)) == false
    expect(self.closedClosedInterval.overlaps(〖8.9..9.9〗)) == false
    expect(self.closedClosedInterval.overlaps(〖6.3..9.9〗)) == true

    expect(self.closedOpenInterval.overlaps(〖6.3..6.9〗)) == false
    expect(self.closedOpenInterval.overlaps(〖6.3..7.9〗)) == false
    expect(self.closedOpenInterval.overlaps(〖6.3..8.0〗)) == true
    expect(self.closedOpenInterval.overlaps(〖8.3..9.9〗)) == true
    expect(self.closedOpenInterval.overlaps(〖8.6..9.9〗)) == false
    expect(self.closedOpenInterval.overlaps(〖8.9..9.9〗)) == false
    expect(self.closedOpenInterval.overlaps(〖6.3..9.9〗)) == true

    expect(self.openClosedInterval.overlaps(〖6.3..6.9〗)) == false
    expect(self.openClosedInterval.overlaps(〖6.3..7.9〗)) == false
    expect(self.openClosedInterval.overlaps(〖6.3..8.0〗)) == true
    expect(self.openClosedInterval.overlaps(〖8.3..9.9〗)) == true
    expect(self.openClosedInterval.overlaps(〖8.6..9.9〗)) == false
    expect(self.openClosedInterval.overlaps(〖8.9..9.9〗)) == false
    expect(self.openClosedInterval.overlaps(〖6.3..9.9〗)) == true

    expect(self.openOpenInterval.overlaps(〖6.3..6.9〗)) == false
    expect(self.openOpenInterval.overlaps(〖6.3..7.9〗)) == false
    expect(self.openOpenInterval.overlaps(〖6.3..8.0〗)) == true
    expect(self.openOpenInterval.overlaps(〖8.3..9.9〗)) == true
    expect(self.openOpenInterval.overlaps(〖8.6..9.9〗)) == false
    expect(self.openOpenInterval.overlaps(〖8.9..9.9〗)) == false
    expect(self.openOpenInterval.overlaps(〖6.3..9.9〗)) == true

    expect(self.degenerateInterval.overlaps(〖6.3..6.9〗)) == false
    expect(self.degenerateInterval.overlaps(〖6.3..7.9〗)) == false
    expect(self.degenerateInterval.overlaps(〖6.3..8.0〗)) == false
    expect(self.degenerateInterval.overlaps(〖8.3..9.9〗)) == true
    expect(self.degenerateInterval.overlaps(〖8.6..9.9〗)) == false
    expect(self.degenerateInterval.overlaps(〖8.9..9.9〗)) == false
    expect(self.degenerateInterval.overlaps(〖6.3..9.9〗)) == true

    expect(self.backwardInterval.overlaps(〖6.3..6.9〗)) == false
    expect(self.backwardInterval.overlaps(〖6.3..7.9〗)) == false
    expect(self.backwardInterval.overlaps(〖6.3..8.0〗)) == false
    expect(self.backwardInterval.overlaps(〖8.3..9.9〗)) == false
    expect(self.backwardInterval.overlaps(〖8.6..9.9〗)) == false
    expect(self.backwardInterval.overlaps(〖8.9..9.9〗)) == false
    expect(self.backwardInterval.overlaps(〖6.3..9.9〗)) == false

    expect(self.emptyInterval.overlaps(〖6.3..6.9〗)) == false
    expect(self.emptyInterval.overlaps(〖6.3..7.9〗)) == false
    expect(self.emptyInterval.overlaps(〖6.3..8.0〗)) == false
    expect(self.emptyInterval.overlaps(〖8.3..9.9〗)) == false
    expect(self.emptyInterval.overlaps(〖8.6..9.9〗)) == false
    expect(self.emptyInterval.overlaps(〖8.9..9.9〗)) == false
    expect(self.emptyInterval.overlaps(〖6.3..9.9〗)) == false
  }

  func testEquality() {
    expect(【7.9..8.6】) == Interval(closed: 7.9, closed: 8.6)
    expect(【7.9..8.6〗) == Interval(closed: 7.9, open: 8.6)
    expect(〖7.9..8.6】) == Interval(open: 7.9, closed: 8.6)
    expect(〖7.9..8.6〗) == Interval(open: 7.9, open: 8.6)
    expect(【8.6..8.6】) == Interval(degenerate: 8.6)
    expect(【8.6..7.9】) != Interval(closed: 8.6, closed: 7.9)
    expect(【8.6..8.6〗) != Interval(closed: 8.6, open: 8.6)
  }

  func testUnion() {
    expect(self.closedClosedInterval.union(【7.9..8.0】)) == closedClosedInterval
    expect(self.closedClosedInterval.union(【6.3..7.9】)) == 【6.3..8.6】
    expect(self.closedClosedInterval.union(【8.0..8.0】)) == closedClosedInterval
    expect(self.closedClosedInterval.union(【8.3..8.5】)) == closedClosedInterval
    expect(self.closedClosedInterval.union(【8.3..8.6】)) == closedClosedInterval
    expect(self.closedClosedInterval.union(【8.9..9.9】)).to(beNil())
    expect(self.closedClosedInterval.union(【6.3..9.9】)) == 【6.3..9.9】

    expect(self.closedOpenInterval.union(【7.9..8.0】)) == closedOpenInterval
    expect(self.closedOpenInterval.union(【6.3..7.9】)) == 【6.3..8.6〗
    expect(self.closedOpenInterval.union(【8.0..8.0】)) == closedOpenInterval
    expect(self.closedOpenInterval.union(【8.3..8.5】)) == closedOpenInterval
    expect(self.closedOpenInterval.union(【8.3..8.6】)) == closedClosedInterval
    expect(self.closedOpenInterval.union(【8.9..9.9】)).to(beNil())
    expect(self.closedOpenInterval.union(【6.3..9.9】)) == 【6.3..9.9】

    expect(self.openClosedInterval.union(【7.9..8.0】)) == closedClosedInterval
    expect(self.openClosedInterval.union(【6.3..7.9】)) == 【6.3..8.6】
    expect(self.openClosedInterval.union(【8.0..8.0】)) == openClosedInterval
    expect(self.openClosedInterval.union(【8.3..8.5】)) == openClosedInterval
    expect(self.openClosedInterval.union(【8.3..8.6】)) == openClosedInterval
    expect(self.openClosedInterval.union(【8.9..9.9】)).to(beNil())
    expect(self.openClosedInterval.union(【6.3..9.9】)) == 【6.3..9.9】

    expect(self.openOpenInterval.union(【7.9..8.0】)) == closedOpenInterval
    expect(self.openOpenInterval.union(【6.3..7.9】)) == 【6.3..8.6〗
    expect(self.openOpenInterval.union(【8.0..8.0】)) == openOpenInterval
    expect(self.openOpenInterval.union(【8.3..8.5】)) == openOpenInterval
    expect(self.openOpenInterval.union(【8.3..8.6】)) == openClosedInterval
    expect(self.openOpenInterval.union(【8.9..9.9】)).to(beNil())
    expect(self.openOpenInterval.union(【6.3..9.9】)) == 【6.3..9.9】

    expect(self.degenerateInterval.union(【7.9..8.0】)).to(beNil())
    expect(self.degenerateInterval.union(【6.3..7.9】)).to(beNil())
    expect(self.degenerateInterval.union(【8.0..8.0】)).to(beNil())
    expect(self.degenerateInterval.union(【8.3..8.5】)).to(beNil())
    expect(self.degenerateInterval.union(【8.3..8.6】)) == 【8.3..8.6】
    expect(self.degenerateInterval.union(【8.9..9.9】)).to(beNil())
    expect(self.degenerateInterval.union(【6.3..9.9】)) == 【6.3..9.9】

    expect(self.backwardInterval.union(【7.9..8.0】)).to(beNil())
    expect(self.backwardInterval.union(【6.3..7.9】)).to(beNil())
    expect(self.backwardInterval.union(【8.0..8.0】)).to(beNil())
    expect(self.backwardInterval.union(【8.3..8.5】)).to(beNil())
    expect(self.backwardInterval.union(【8.3..8.6】)).to(beNil())
    expect(self.backwardInterval.union(【8.9..9.9】)).to(beNil())
    expect(self.backwardInterval.union(【6.3..9.9】)).to(beNil())

    expect(self.emptyInterval.union(【7.9..8.0】)).to(beNil())
    expect(self.emptyInterval.union(【6.3..7.9】)).to(beNil())
    expect(self.emptyInterval.union(【8.0..8.0】)).to(beNil())
    expect(self.emptyInterval.union(【8.3..8.5】)).to(beNil())
    expect(self.emptyInterval.union(【8.3..8.6】)).to(beNil())
    expect(self.emptyInterval.union(【8.9..9.9】)).to(beNil())
    expect(self.emptyInterval.union(【6.3..9.9】)).to(beNil())

    expect(self.closedClosedInterval.union(【7.9..8.0〗)) == closedClosedInterval
    expect(self.closedClosedInterval.union(【6.3..7.9〗)) == 【6.3..8.6】
    expect(self.closedClosedInterval.union(【8.0..8.0〗)).to(beNil())
    expect(self.closedClosedInterval.union(【8.3..8.5〗)) == closedClosedInterval
    expect(self.closedClosedInterval.union(【8.3..8.6〗)) == closedClosedInterval
    expect(self.closedClosedInterval.union(【8.9..9.9〗)).to(beNil())
    expect(self.closedClosedInterval.union(【6.3..9.9〗)) == 【6.3..9.9〗

    expect(self.closedOpenInterval.union(【7.9..8.0〗)) == closedOpenInterval
    expect(self.closedOpenInterval.union(【6.3..7.9〗)) == 【6.3..8.6〗
    expect(self.closedOpenInterval.union(【8.0..8.0〗)).to(beNil())
    expect(self.closedOpenInterval.union(【8.3..8.5〗)) == closedOpenInterval
    expect(self.closedOpenInterval.union(【8.3..8.6〗)) == closedOpenInterval
    expect(self.closedOpenInterval.union(【8.9..9.9〗)).to(beNil())
    expect(self.closedOpenInterval.union(【6.3..9.9〗)) == 【6.3..9.9〗

    expect(self.openClosedInterval.union(【7.9..8.0〗)) == closedClosedInterval
    expect(self.openClosedInterval.union(【6.3..7.9〗)).to(beNil())
    expect(self.openClosedInterval.union(【8.0..8.0〗)).to(beNil())
    expect(self.openClosedInterval.union(【8.3..8.5〗)) == openClosedInterval
    expect(self.openClosedInterval.union(【8.3..8.6〗)) == openClosedInterval
    expect(self.openClosedInterval.union(【8.9..9.9〗)).to(beNil())
    expect(self.openClosedInterval.union(【6.3..9.9〗)) == 【6.3..9.9〗

    expect(self.openOpenInterval.union(【7.9..8.0〗)) == closedOpenInterval
    expect(self.openOpenInterval.union(【6.3..7.9〗)).to(beNil())
    expect(self.openOpenInterval.union(【8.0..8.0〗)).to(beNil())
    expect(self.openOpenInterval.union(【8.3..8.5〗)) == openOpenInterval
    expect(self.openOpenInterval.union(【8.3..8.6〗)) == openOpenInterval
    expect(self.openOpenInterval.union(【8.9..9.9〗)).to(beNil())
    expect(self.openOpenInterval.union(【6.3..9.9〗)) == 【6.3..9.9〗

    expect(self.degenerateInterval.union(【7.9..8.0〗)).to(beNil())
    expect(self.degenerateInterval.union(【6.3..7.9〗)).to(beNil())
    expect(self.degenerateInterval.union(【8.0..8.0〗)).to(beNil())
    expect(self.degenerateInterval.union(【8.3..8.5〗)).to(beNil())
    expect(self.degenerateInterval.union(【8.3..8.6〗)) == 【8.3..8.6】
    expect(self.degenerateInterval.union(【8.9..9.9〗)).to(beNil())
    expect(self.degenerateInterval.union(【6.3..9.9〗)) == 【6.3..9.9〗

    expect(self.backwardInterval.union(【7.9..8.0〗)).to(beNil())
    expect(self.backwardInterval.union(【6.3..7.9〗)).to(beNil())
    expect(self.backwardInterval.union(【8.0..8.0〗)).to(beNil())
    expect(self.backwardInterval.union(【8.3..8.5〗)).to(beNil())
    expect(self.backwardInterval.union(【8.3..8.6〗)).to(beNil())
    expect(self.backwardInterval.union(【8.9..9.9〗)).to(beNil())
    expect(self.backwardInterval.union(【6.3..9.9〗)).to(beNil())

    expect(self.emptyInterval.union(【7.9..8.0〗)).to(beNil())
    expect(self.emptyInterval.union(【6.3..7.9〗)).to(beNil())
    expect(self.emptyInterval.union(【8.0..8.0〗)).to(beNil())
    expect(self.emptyInterval.union(【8.3..8.5〗)).to(beNil())
    expect(self.emptyInterval.union(【8.3..8.6〗)).to(beNil())
    expect(self.emptyInterval.union(【8.9..9.9〗)).to(beNil())
    expect(self.emptyInterval.union(【6.3..9.9〗)).to(beNil())

    expect(self.closedClosedInterval.union(〖7.9..8.0】)) == closedClosedInterval
    expect(self.closedClosedInterval.union(〖6.3..7.9】)) == 〖6.3..8.6】
    expect(self.closedClosedInterval.union(〖8.0..8.0】)).to(beNil())
    expect(self.closedClosedInterval.union(〖8.3..8.5】)) == closedClosedInterval
    expect(self.closedClosedInterval.union(〖8.3..8.6】)) == closedClosedInterval
    expect(self.closedClosedInterval.union(〖8.9..9.9】)).to(beNil())
    expect(self.closedClosedInterval.union(〖6.3..9.9】)) == 〖6.3..9.9】

    expect(self.closedOpenInterval.union(〖7.9..8.0】)) == closedOpenInterval
    expect(self.closedOpenInterval.union(〖6.3..7.9】)) == 〖6.3..8.6〗
    expect(self.closedOpenInterval.union(〖8.0..8.0】)).to(beNil())
    expect(self.closedOpenInterval.union(〖8.3..8.5】)) == closedOpenInterval
    expect(self.closedOpenInterval.union(〖8.3..8.6】)) == closedClosedInterval
    expect(self.closedOpenInterval.union(〖8.9..9.9】)).to(beNil())
    expect(self.closedOpenInterval.union(〖6.3..9.9】)) == 〖6.3..9.9】

    expect(self.openClosedInterval.union(〖7.9..8.0】)) == openClosedInterval
    expect(self.openClosedInterval.union(〖6.3..7.9】)) == 〖6.3..8.6】
    expect(self.openClosedInterval.union(〖8.0..8.0】)).to(beNil())
    expect(self.openClosedInterval.union(〖8.3..8.5】)) == openClosedInterval
    expect(self.openClosedInterval.union(〖8.3..8.6】)) == openClosedInterval
    expect(self.openClosedInterval.union(〖8.9..9.9】)).to(beNil())
    expect(self.openClosedInterval.union(〖6.3..9.9】)) == 〖6.3..9.9】

    expect(self.openOpenInterval.union(〖7.9..8.0】)) == openOpenInterval
    expect(self.openOpenInterval.union(〖6.3..7.9】)) == 〖6.3..8.6〗
    expect(self.openOpenInterval.union(〖8.0..8.0】)).to(beNil())
    expect(self.openOpenInterval.union(〖8.3..8.5】)) == openOpenInterval
    expect(self.openOpenInterval.union(〖8.3..8.6】)) == openClosedInterval
    expect(self.openOpenInterval.union(〖8.9..9.9】)).to(beNil())
    expect(self.openOpenInterval.union(〖6.3..9.9】)) == 〖6.3..9.9】

    expect(self.degenerateInterval.union(〖7.9..8.0】)).to(beNil())
    expect(self.degenerateInterval.union(〖6.3..7.9】)).to(beNil())
    expect(self.degenerateInterval.union(〖8.0..8.0】)).to(beNil())
    expect(self.degenerateInterval.union(〖8.3..8.5】)).to(beNil())
    expect(self.degenerateInterval.union(〖8.3..8.6】)) == 〖8.3..8.6】
    expect(self.degenerateInterval.union(〖8.9..9.9】)).to(beNil())
    expect(self.degenerateInterval.union(〖6.3..9.9】)) == 〖6.3..9.9】

    expect(self.backwardInterval.union(〖7.9..8.0】)).to(beNil())
    expect(self.backwardInterval.union(〖6.3..7.9】)).to(beNil())
    expect(self.backwardInterval.union(〖8.0..8.0】)).to(beNil())
    expect(self.backwardInterval.union(〖8.3..8.5】)).to(beNil())
    expect(self.backwardInterval.union(〖8.3..8.6】)).to(beNil())
    expect(self.backwardInterval.union(〖8.9..9.9】)).to(beNil())
    expect(self.backwardInterval.union(〖6.3..9.9】)).to(beNil())

    expect(self.emptyInterval.union(〖7.9..8.0】)).to(beNil())
    expect(self.emptyInterval.union(〖6.3..7.9】)).to(beNil())
    expect(self.emptyInterval.union(〖8.0..8.0】)).to(beNil())
    expect(self.emptyInterval.union(〖8.3..8.5】)).to(beNil())
    expect(self.emptyInterval.union(〖8.3..8.6】)).to(beNil())
    expect(self.emptyInterval.union(〖8.9..9.9】)).to(beNil())
    expect(self.emptyInterval.union(〖6.3..9.9】)).to(beNil())

    expect(self.closedClosedInterval.union(〖7.9..8.0〗)) == closedClosedInterval
    expect(self.closedClosedInterval.union(〖6.3..7.9〗)) == 〖6.3..8.6】
    expect(self.closedClosedInterval.union(〖8.0..8.0〗)).to(beNil())
    expect(self.closedClosedInterval.union(〖8.3..8.5〗)) == closedClosedInterval
    expect(self.closedClosedInterval.union(〖8.3..8.6〗)) == closedClosedInterval
    expect(self.closedClosedInterval.union(〖8.9..9.9〗)).to(beNil())
    expect(self.closedClosedInterval.union(〖6.3..9.9〗)) == 〖6.3..9.9〗

    expect(self.closedOpenInterval.union(〖7.9..8.0〗)) == closedOpenInterval
    expect(self.closedOpenInterval.union(〖6.3..7.9〗)) == 〖6.3..8.6〗
    expect(self.closedOpenInterval.union(〖8.0..8.0〗)).to(beNil())
    expect(self.closedOpenInterval.union(〖8.3..8.5〗)) == closedOpenInterval
    expect(self.closedOpenInterval.union(〖8.3..8.6〗)) == closedOpenInterval
    expect(self.closedOpenInterval.union(〖8.9..9.9〗)).to(beNil())
    expect(self.closedOpenInterval.union(〖6.3..9.9〗)) == 〖6.3..9.9〗

    expect(self.openClosedInterval.union(〖7.9..8.0〗)) == openClosedInterval
    expect(self.openClosedInterval.union(〖6.3..7.9〗)).to(beNil())
    expect(self.openClosedInterval.union(〖8.0..8.0〗)).to(beNil())
    expect(self.openClosedInterval.union(〖8.3..8.5〗)) == openClosedInterval
    expect(self.openClosedInterval.union(〖8.3..8.6〗)) == openClosedInterval
    expect(self.openClosedInterval.union(〖8.9..9.9〗)).to(beNil())
    expect(self.openClosedInterval.union(〖6.3..9.9〗)) == 〖6.3..9.9〗

    expect(self.openOpenInterval.union(〖7.9..8.0〗)) == openOpenInterval
    expect(self.openOpenInterval.union(〖6.3..7.9〗)).to(beNil())
    expect(self.openOpenInterval.union(〖8.0..8.0〗)).to(beNil())
    expect(self.openOpenInterval.union(〖8.3..8.5〗)) == openOpenInterval
    expect(self.openOpenInterval.union(〖8.3..8.6〗)) == openOpenInterval
    expect(self.openOpenInterval.union(〖8.9..9.9〗)).to(beNil())
    expect(self.openOpenInterval.union(〖6.3..9.9〗)) == 〖6.3..9.9〗

    expect(self.degenerateInterval.union(〖7.9..8.0〗)).to(beNil())
    expect(self.degenerateInterval.union(〖6.3..7.9〗)).to(beNil())
    expect(self.degenerateInterval.union(〖8.0..8.0〗)).to(beNil())
    expect(self.degenerateInterval.union(〖8.3..8.5〗)).to(beNil())
    expect(self.degenerateInterval.union(〖8.3..8.6〗)) == 〖8.3..8.6】
    expect(self.degenerateInterval.union(〖8.9..9.9〗)).to(beNil())
    expect(self.degenerateInterval.union(〖6.3..9.9〗)) == 〖6.3..9.9〗

    expect(self.backwardInterval.union(〖7.9..8.0〗)).to(beNil())
    expect(self.backwardInterval.union(〖6.3..7.9〗)).to(beNil())
    expect(self.backwardInterval.union(〖8.0..8.0〗)).to(beNil())
    expect(self.backwardInterval.union(〖8.3..8.5〗)).to(beNil())
    expect(self.backwardInterval.union(〖8.3..8.6〗)).to(beNil())
    expect(self.backwardInterval.union(〖8.9..9.9〗)).to(beNil())
    expect(self.backwardInterval.union(〖6.3..9.9〗)).to(beNil())

    expect(self.emptyInterval.union(〖7.9..8.0〗)).to(beNil())
    expect(self.emptyInterval.union(〖6.3..7.9〗)).to(beNil())
    expect(self.emptyInterval.union(〖8.0..8.0〗)).to(beNil())
    expect(self.emptyInterval.union(〖8.3..8.5〗)).to(beNil())
    expect(self.emptyInterval.union(〖8.3..8.6〗)).to(beNil())
    expect(self.emptyInterval.union(〖8.9..9.9〗)).to(beNil())
    expect(self.emptyInterval.union(〖6.3..9.9〗)).to(beNil())
  }

  func testIntersection() {
    expect(self.closedClosedInterval.intersection(【7.9..8.0】)) == 【7.9..8.0】
    expect(self.closedClosedInterval.intersection(【6.3..7.9】)) == 【7.9..7.9】
    expect(self.closedClosedInterval.intersection(【8.0..8.0】)) == 【8.0..8.0】
    expect(self.closedClosedInterval.intersection(【8.3..8.5】)) == 【8.3..8.5】
    expect(self.closedClosedInterval.intersection(【8.3..8.6】)) == 【8.3..8.6】
    expect(self.closedClosedInterval.intersection(【8.9..9.9】).isEmpty) == true
    expect(self.closedClosedInterval.intersection(【6.3..9.9】)) == closedClosedInterval

    expect(self.closedOpenInterval.intersection(【7.9..8.0】)) == 【7.9..8.0】
    expect(self.closedOpenInterval.intersection(【6.3..7.9】)) == 【7.9..7.9】
    expect(self.closedOpenInterval.intersection(【8.0..8.0】)) == 【8.0..8.0】
    expect(self.closedOpenInterval.intersection(【8.3..8.5】)) == 【8.3..8.5】
    expect(self.closedOpenInterval.intersection(【8.3..8.6】)) == 【8.3..8.6〗
    expect(self.closedOpenInterval.intersection(【8.9..9.9】).isEmpty) == true
    expect(self.closedOpenInterval.intersection(【6.3..9.9】)) == closedOpenInterval

    expect(self.openClosedInterval.intersection(【7.9..8.0】)) == 〖7.9..8.0】
    expect(self.openClosedInterval.intersection(【6.3..7.9】).isEmpty) == true
    expect(self.openClosedInterval.intersection(【8.0..8.0】)) == 【8.0..8.0】
    expect(self.openClosedInterval.intersection(【8.3..8.5】)) == 【8.3..8.5】
    expect(self.openClosedInterval.intersection(【8.3..8.6】)) == 【8.3..8.6】
    expect(self.openClosedInterval.intersection(【8.9..9.9】).isEmpty) == true
    expect(self.openClosedInterval.intersection(【6.3..9.9】)) == openClosedInterval

    expect(self.openOpenInterval.intersection(【7.9..8.0】)) == 〖7.9..8.0】
    expect(self.openOpenInterval.intersection(【6.3..7.9】).isEmpty) == true
    expect(self.openOpenInterval.intersection(【8.0..8.0】)) == 【8.0..8.0】
    expect(self.openOpenInterval.intersection(【8.3..8.5】)) == 【8.3..8.5】
    expect(self.openOpenInterval.intersection(【8.3..8.6】)) == 【8.3..8.6〗
    expect(self.openOpenInterval.intersection(【8.9..9.9】).isEmpty) == true
    expect(self.openOpenInterval.intersection(【6.3..9.9】)) == openOpenInterval

    expect(self.degenerateInterval.intersection(【7.9..8.0】).isEmpty) == true
    expect(self.degenerateInterval.intersection(【6.3..7.9】).isEmpty) == true
    expect(self.degenerateInterval.intersection(【8.0..8.0】).isEmpty) == true
    expect(self.degenerateInterval.intersection(【8.3..8.5】).isEmpty) == true
    expect(self.degenerateInterval.intersection(【8.3..8.6】)) == degenerateInterval
    expect(self.degenerateInterval.intersection(【8.9..9.9】).isEmpty) == true
    expect(self.degenerateInterval.intersection(【6.3..9.9】)) == degenerateInterval

    expect(self.backwardInterval.intersection(【7.9..8.0】).isEmpty) == true
    expect(self.backwardInterval.intersection(【6.3..7.9】).isEmpty) == true
    expect(self.backwardInterval.intersection(【8.0..8.0】).isEmpty) == true
    expect(self.backwardInterval.intersection(【8.3..8.5】).isEmpty) == true
    expect(self.backwardInterval.intersection(【8.3..8.6】).isEmpty) == true
    expect(self.backwardInterval.intersection(【8.9..9.9】).isEmpty) == true
    expect(self.backwardInterval.intersection(【6.3..9.9】).isEmpty) == true

    expect(self.emptyInterval.intersection(【7.9..8.0】).isEmpty) == true
    expect(self.emptyInterval.intersection(【6.3..7.9】).isEmpty) == true
    expect(self.emptyInterval.intersection(【8.0..8.0】).isEmpty) == true
    expect(self.emptyInterval.intersection(【8.3..8.5】).isEmpty) == true
    expect(self.emptyInterval.intersection(【8.3..8.6】).isEmpty) == true
    expect(self.emptyInterval.intersection(【8.9..9.9】).isEmpty) == true
    expect(self.emptyInterval.intersection(【6.3..9.9】).isEmpty) == true

    expect(self.closedClosedInterval.intersection(【7.9..8.0〗)) == 【7.9..8.0〗
    expect(self.closedClosedInterval.intersection(【6.3..7.9〗).isEmpty) == true
    expect(self.closedClosedInterval.intersection(【8.0..8.0〗).isEmpty) == true
    expect(self.closedClosedInterval.intersection(【8.3..8.5〗)) == 【8.3..8.5〗
    expect(self.closedClosedInterval.intersection(【8.3..8.6〗)) == 【8.3..8.6〗
    expect(self.closedClosedInterval.intersection(【8.9..9.9〗).isEmpty) == true
    expect(self.closedClosedInterval.intersection(【6.3..9.9〗)) == closedClosedInterval

    expect(self.closedOpenInterval.intersection(【7.9..8.0〗)) == 【7.9..8.0〗
    expect(self.closedOpenInterval.intersection(【6.3..7.9〗).isEmpty) == true
    expect(self.closedOpenInterval.intersection(【8.0..8.0〗).isEmpty) == true
    expect(self.closedOpenInterval.intersection(【8.3..8.5〗)) == 【8.3..8.5〗
    expect(self.closedOpenInterval.intersection(【8.3..8.6〗)) == 【8.3..8.6〗
    expect(self.closedOpenInterval.intersection(【8.9..9.9〗).isEmpty) == true
    expect(self.closedOpenInterval.intersection(【6.3..9.9〗)) == closedOpenInterval

    expect(self.openClosedInterval.intersection(【7.9..8.0〗)) == 〖7.9..8.0〗
    expect(self.openClosedInterval.intersection(【6.3..7.9〗).isEmpty) == true
    expect(self.openClosedInterval.intersection(【8.0..8.0〗).isEmpty) == true
    expect(self.openClosedInterval.intersection(【8.3..8.5〗)) == 【8.3..8.5〗
    expect(self.openClosedInterval.intersection(【8.3..8.6〗)) == 【8.3..8.6〗
    expect(self.openClosedInterval.intersection(【8.9..9.9〗).isEmpty) == true
    expect(self.openClosedInterval.intersection(【6.3..9.9〗)) == openClosedInterval

    expect(self.openOpenInterval.intersection(【7.9..8.0〗)) == 〖7.9..8.0〗
    expect(self.openOpenInterval.intersection(【6.3..7.9〗).isEmpty) == true
    expect(self.openOpenInterval.intersection(【8.0..8.0〗).isEmpty) == true
    expect(self.openOpenInterval.intersection(【8.3..8.5〗)) == 【8.3..8.5〗
    expect(self.openOpenInterval.intersection(【8.3..8.6〗)) == 【8.3..8.6〗
    expect(self.openOpenInterval.intersection(【8.9..9.9〗).isEmpty) == true
    expect(self.openOpenInterval.intersection(【6.3..9.9〗)) == openOpenInterval

    expect(self.degenerateInterval.intersection(【7.9..8.0〗).isEmpty) == true
    expect(self.degenerateInterval.intersection(【6.3..7.9〗).isEmpty) == true
    expect(self.degenerateInterval.intersection(【8.0..8.0〗).isEmpty) == true
    expect(self.degenerateInterval.intersection(【8.3..8.5〗).isEmpty) == true
    expect(self.degenerateInterval.intersection(【8.3..8.6〗).isEmpty) == true
    expect(self.degenerateInterval.intersection(【8.9..9.9〗).isEmpty) == true
    expect(self.degenerateInterval.intersection(【6.3..9.9〗)) == degenerateInterval

    expect(self.backwardInterval.intersection(【7.9..8.0〗).isEmpty) == true
    expect(self.backwardInterval.intersection(【6.3..7.9〗).isEmpty) == true
    expect(self.backwardInterval.intersection(【8.0..8.0〗).isEmpty) == true
    expect(self.backwardInterval.intersection(【8.3..8.5〗).isEmpty) == true
    expect(self.backwardInterval.intersection(【8.3..8.6〗).isEmpty) == true
    expect(self.backwardInterval.intersection(【8.9..9.9〗).isEmpty) == true
    expect(self.backwardInterval.intersection(【6.3..9.9〗).isEmpty) == true

    expect(self.emptyInterval.intersection(【7.9..8.0〗).isEmpty) == true
    expect(self.emptyInterval.intersection(【6.3..7.9〗).isEmpty) == true
    expect(self.emptyInterval.intersection(【8.0..8.0〗).isEmpty) == true
    expect(self.emptyInterval.intersection(【8.3..8.5〗).isEmpty) == true
    expect(self.emptyInterval.intersection(【8.3..8.6〗).isEmpty) == true
    expect(self.emptyInterval.intersection(【8.9..9.9〗).isEmpty) == true
    expect(self.emptyInterval.intersection(【6.3..9.9〗).isEmpty) == true

    expect(self.closedClosedInterval.intersection(〖7.9..8.0】)) == 〖7.9..8.0】
    expect(self.closedClosedInterval.intersection(〖6.3..7.9】)) == 【7.9..7.9】
    expect(self.closedClosedInterval.intersection(〖8.0..8.0】).isEmpty) == true
    expect(self.closedClosedInterval.intersection(〖8.3..8.5】)) == 〖8.3..8.5】
    expect(self.closedClosedInterval.intersection(〖8.3..8.6】)) == 〖8.3..8.6】
    expect(self.closedClosedInterval.intersection(〖8.9..9.9】).isEmpty) == true
    expect(self.closedClosedInterval.intersection(〖6.3..9.9】)) == closedClosedInterval

    expect(self.closedOpenInterval.intersection(〖7.9..8.0】)) == 〖7.9..8.0】
    expect(self.closedOpenInterval.intersection(〖6.3..7.9】)) == 【7.9..7.9】
    expect(self.closedOpenInterval.intersection(〖8.0..8.0】).isEmpty) == true
    expect(self.closedOpenInterval.intersection(〖8.3..8.5】)) == 〖8.3..8.5】
    expect(self.closedOpenInterval.intersection(〖8.3..8.6】)) == 〖8.3..8.6〗
    expect(self.closedOpenInterval.intersection(〖8.9..9.9】).isEmpty) == true
    expect(self.closedOpenInterval.intersection(〖6.3..9.9】)) == closedOpenInterval

    expect(self.openClosedInterval.intersection(〖7.9..8.0】)) == 〖7.9..8.0】
    expect(self.openClosedInterval.intersection(〖6.3..7.9】).isEmpty) == true
    expect(self.openClosedInterval.intersection(〖8.0..8.0】).isEmpty) == true
    expect(self.openClosedInterval.intersection(〖8.3..8.5】)) == 〖8.3..8.5】
    expect(self.openClosedInterval.intersection(〖8.3..8.6】)) == 〖8.3..8.6】
    expect(self.openClosedInterval.intersection(〖8.9..9.9】).isEmpty) == true
    expect(self.openClosedInterval.intersection(〖6.3..9.9】)) == openClosedInterval

    expect(self.openOpenInterval.intersection(〖7.9..8.0】)) == 〖7.9..8.0】
    expect(self.openOpenInterval.intersection(〖6.3..7.9】).isEmpty) == true
    expect(self.openOpenInterval.intersection(〖8.0..8.0】).isEmpty) == true
    expect(self.openOpenInterval.intersection(〖8.3..8.5】)) == 〖8.3..8.5】
    expect(self.openOpenInterval.intersection(〖8.3..8.6】)) == 〖8.3..8.6〗
    expect(self.openOpenInterval.intersection(〖8.9..9.9】).isEmpty) == true
    expect(self.openOpenInterval.intersection(〖6.3..9.9】)) == openOpenInterval

    expect(self.degenerateInterval.intersection(〖7.9..8.0】).isEmpty) == true
    expect(self.degenerateInterval.intersection(〖6.3..7.9】).isEmpty) == true
    expect(self.degenerateInterval.intersection(〖8.0..8.0】).isEmpty) == true
    expect(self.degenerateInterval.intersection(〖8.3..8.5】).isEmpty) == true
    expect(self.degenerateInterval.intersection(〖8.3..8.6】)) == 【8.6..8.6】
    expect(self.degenerateInterval.intersection(〖8.9..9.9】).isEmpty) == true
    expect(self.degenerateInterval.intersection(〖6.3..9.9】)) == degenerateInterval

    expect(self.backwardInterval.intersection(〖7.9..8.0】).isEmpty) == true
    expect(self.backwardInterval.intersection(〖6.3..7.9】).isEmpty) == true
    expect(self.backwardInterval.intersection(〖8.0..8.0】).isEmpty) == true
    expect(self.backwardInterval.intersection(〖8.3..8.5】).isEmpty) == true
    expect(self.backwardInterval.intersection(〖8.3..8.6】).isEmpty) == true
    expect(self.backwardInterval.intersection(〖8.9..9.9】).isEmpty) == true
    expect(self.backwardInterval.intersection(〖6.3..9.9】).isEmpty) == true

    expect(self.emptyInterval.intersection(〖7.9..8.0】).isEmpty) == true
    expect(self.emptyInterval.intersection(〖6.3..7.9】).isEmpty) == true
    expect(self.emptyInterval.intersection(〖8.0..8.0】).isEmpty) == true
    expect(self.emptyInterval.intersection(〖8.3..8.5】).isEmpty) == true
    expect(self.emptyInterval.intersection(〖8.3..8.6】).isEmpty) == true
    expect(self.emptyInterval.intersection(〖8.9..9.9】).isEmpty) == true
    expect(self.emptyInterval.intersection(〖6.3..9.9】).isEmpty) == true

    expect(self.closedClosedInterval.intersection(〖7.9..8.0〗)) == 〖7.9..8.0〗
    expect(self.closedClosedInterval.intersection(〖6.3..7.9〗).isEmpty) == true
    expect(self.closedClosedInterval.intersection(〖8.0..8.0〗).isEmpty) == true
    expect(self.closedClosedInterval.intersection(〖8.3..8.5〗)) == 〖8.3..8.5〗
    expect(self.closedClosedInterval.intersection(〖8.3..8.6〗)) == 〖8.3..8.6〗
    expect(self.closedClosedInterval.intersection(〖8.9..9.9〗).isEmpty) == true
    expect(self.closedClosedInterval.intersection(〖6.3..9.9〗)) == closedClosedInterval

    expect(self.closedOpenInterval.intersection(〖7.9..8.0〗)) == 〖7.9..8.0〗
    expect(self.closedOpenInterval.intersection(〖6.3..7.9〗).isEmpty) == true
    expect(self.closedOpenInterval.intersection(〖8.0..8.0〗).isEmpty) == true
    expect(self.closedOpenInterval.intersection(〖8.3..8.5〗)) == 〖8.3..8.5〗
    expect(self.closedOpenInterval.intersection(〖8.3..8.6〗)) == 〖8.3..8.6〗
    expect(self.closedOpenInterval.intersection(〖8.9..9.9〗).isEmpty) == true
    expect(self.closedOpenInterval.intersection(〖6.3..9.9〗)) == closedOpenInterval

    expect(self.openClosedInterval.intersection(〖7.9..8.0〗)) == 〖7.9..8.0〗
    expect(self.openClosedInterval.intersection(〖6.3..7.9〗).isEmpty) == true
    expect(self.openClosedInterval.intersection(〖8.0..8.0〗).isEmpty) == true
    expect(self.openClosedInterval.intersection(〖8.3..8.5〗)) == 〖8.3..8.5〗
    expect(self.openClosedInterval.intersection(〖8.3..8.6〗)) == 〖8.3..8.6〗
    expect(self.openClosedInterval.intersection(〖8.9..9.9〗).isEmpty) == true
    expect(self.openClosedInterval.intersection(〖6.3..9.9〗)) == openClosedInterval

    expect(self.openOpenInterval.intersection(〖7.9..8.0〗)) == 〖7.9..8.0〗
    expect(self.openOpenInterval.intersection(〖6.3..7.9〗).isEmpty) == true
    expect(self.openOpenInterval.intersection(〖8.0..8.0〗).isEmpty) == true
    expect(self.openOpenInterval.intersection(〖8.3..8.5〗)) == 〖8.3..8.5〗
    expect(self.openOpenInterval.intersection(〖8.3..8.6〗)) == 〖8.3..8.6〗
    expect(self.openOpenInterval.intersection(〖8.9..9.9〗).isEmpty) == true
    expect(self.openOpenInterval.intersection(〖6.3..9.9〗)) == openOpenInterval

    expect(self.degenerateInterval.intersection(〖7.9..8.0〗).isEmpty) == true
    expect(self.degenerateInterval.intersection(〖6.3..7.9〗).isEmpty) == true
    expect(self.degenerateInterval.intersection(〖8.0..8.0〗).isEmpty) == true
    expect(self.degenerateInterval.intersection(〖8.3..8.5〗).isEmpty) == true
    expect(self.degenerateInterval.intersection(〖8.3..8.6〗).isEmpty) == true
    expect(self.degenerateInterval.intersection(〖8.9..9.9〗).isEmpty) == true
    expect(self.degenerateInterval.intersection(〖6.3..9.9〗)) == degenerateInterval

    expect(self.backwardInterval.intersection(〖7.9..8.0〗).isEmpty) == true
    expect(self.backwardInterval.intersection(〖6.3..7.9〗).isEmpty) == true
    expect(self.backwardInterval.intersection(〖8.0..8.0〗).isEmpty) == true
    expect(self.backwardInterval.intersection(〖8.3..8.5〗).isEmpty) == true
    expect(self.backwardInterval.intersection(〖8.3..8.6〗).isEmpty) == true
    expect(self.backwardInterval.intersection(〖8.9..9.9〗).isEmpty) == true
    expect(self.backwardInterval.intersection(〖6.3..9.9〗).isEmpty) == true

    expect(self.emptyInterval.intersection(〖7.9..8.0〗).isEmpty) == true
    expect(self.emptyInterval.intersection(〖6.3..7.9〗).isEmpty) == true
    expect(self.emptyInterval.intersection(〖8.0..8.0〗).isEmpty) == true
    expect(self.emptyInterval.intersection(〖8.3..8.5〗).isEmpty) == true
    expect(self.emptyInterval.intersection(〖8.3..8.6〗).isEmpty) == true
    expect(self.emptyInterval.intersection(〖8.9..9.9〗).isEmpty) == true
    expect(self.emptyInterval.intersection(〖6.3..9.9〗).isEmpty) == true
  }

  func testFullWidthRangeConversions() {
    expect(Interval(7.9 ... 8.6)) == closedClosedInterval
    expect(Interval(7.9 ..< 8.6)) == closedOpenInterval
    expect(Interval(8.6 ... 8.6)) == degenerateInterval
    expect(Interval(8.6 ..< 8.6).isEmpty) == true
    expect(Interval<Int>(4 ..< 6)) == 【4..6〗
    expect(Interval<Int>(4 ... 6)) == 【4..6】
  }
}
