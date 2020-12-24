//
//  FractionTests.swift
//  FractionTests
//
//  Created by Jason Cardwell on 8/5/16.
//  Copyright © 2016 Jason Cardwell. All rights reserved.
//
import XCTest
import Nimble
@testable import MoonKit

private func pow10(_ exponent: Int) -> UInt128 {
  power(value: 10, exponent: exponent, identity: 1, operation: *)
}

final class FractionTests: XCTestCase {

  func testParts() {
    var parts = (4╱5).parts
    expect(parts.integer) == 0
//    expect(parts.nonrepeating) == [8]
//    expect(parts.repeating).to(beEmpty())

    parts = (3╱4).parts
    expect(parts.integer) == 0
//    expect(parts.nonrepeating) == [7, 5]
//    expect(parts.repeating).to(beEmpty())

    parts = (0╱64).parts
    expect(parts.integer) == 0
//    expect(parts.nonrepeating).to(beEmpty())
//    expect(parts.repeating).to(beEmpty())

    parts = (1╱4).parts
    expect(parts.integer) == 0
//    expect(parts.nonrepeating) == [2, 5]
//    expect(parts.repeating).to(beEmpty())

    parts = (3╱8).parts
    expect(parts.integer) == 0
//    expect(parts.nonrepeating) == [3, 7, 5]
//    expect(parts.repeating).to(beEmpty())

    parts = (9╱11).parts
    expect(parts.integer) == 0
//    expect(parts.nonrepeating).to(beEmpty())
//    expect(parts.repeating) == [8, 1]

    parts = (1╱24).parts
    expect(parts.integer) == 0
//    expect(parts.nonrepeating) == [0, 4, 1]
//    expect(parts.repeating) == [6]

    parts = (8╱3).parts
    expect(parts.integer) == 2
//    expect(parts.nonrepeating).to(beEmpty())
//    expect(parts.repeating) == [6]

    parts = (46╱11).parts
    expect(parts.integer) == 4
//    expect(parts.nonrepeating).to(beEmpty())
//    expect(parts.repeating) == [1, 8]

    parts = (1002331╱24).parts
    expect(parts.integer) == 41763
//    expect(parts.nonrepeating) == [7, 9, 1]
//    expect(parts.repeating) == [6]

    parts = (22╱5).parts
    expect(parts.integer) == 4
//    expect(parts.nonrepeating) == [4]
//    expect(parts.repeating).to(beEmpty())

    parts = (98╱4).parts
    expect(parts.integer) == 24
//    expect(parts.nonrepeating) == [5]
//    expect(parts.repeating).to(beEmpty())
    
    parts = (63╱8).parts
    expect(parts.integer) == 7
//    expect(parts.nonrepeating) == [8, 7, 5]
//    expect(parts.repeating).to(beEmpty())
  }
   

  func testDecimalForm() {
    expect(Fraction.infinity.decimalForm) == Fraction.infinity
    expect(Fraction.infinity.negated().decimalForm) == Fraction.infinity.negated()
    expect(Fraction.nan.decimalForm).to(beNaN())
    expect(Fraction.signalingNaN.decimalForm).to(beSignalingNaN())
    expect((3╱4).decimalForm.sign) == FloatingPointSign.plus
    expect((3╱4).negated().decimalForm.sign) == FloatingPointSign.minus

    var f = (0╱64).decimalForm
    expect((f.numerator, f.denominator)) == (0, 1)

    f = (4╱5).decimalForm
    expect((f.numerator, f.denominator)) == (8, 10)

    f = (1╱3).decimalForm
    expect((f.numerator, f.denominator)) == (UInt128(low: 0xadd8b61555555555, high: 0x1913c4381e2cec28), pow10(38))

    f = (1╱4).decimalForm
    expect((f.numerator, f.denominator)) == (25, 100)

    f = (3╱8).decimalForm
    expect((f.numerator, f.denominator)) == (375, 1000)

    f = (9╱11).decimalForm
    expect((f.numerator, f.denominator)) == (UInt128(low: 0xf0884a91745d1745, high: 0x3d8d9bcf8fe2a0c0), pow10(38))

    f = (1╱24).decimalForm
    expect((f.numerator, f.denominator)) == (UInt128(low: 0x15bb16c2aaaaaaaa, high: 0x322788703c59d85), pow10(38))

    f = (8╱3).decimalForm
    expect((f.numerator, f.denominator)) == (UInt128(low: 0x57e091aaaaaaaaaa, high: 0x140fd02ce4f0bced), pow10(37))

    f = (46╱11).decimalForm
    expect((f.numerator, f.denominator)) == (UInt128(low: 0xecb77011745d1745, high: 0x1f75e38c3879855c), pow10(37))

    f = (1002331╱24).decimalForm
    expect((f.numerator, f.denominator)) == (UInt128(low: 0xc1aa8dc5eaaaaaaa, high: 0x1f6b69e7fe7a5dad), pow10(33))

    f = (22╱5).decimalForm
    expect((f.numerator, f.denominator)) == (44, 10)

    f = (98╱4).decimalForm
    expect((f.numerator, f.denominator)) == (245, 10)

    f = (63╱8).decimalForm
    expect((f.numerator, f.denominator)) == (7875, 1000)
  }

  func testExponent() {
    expect((5╱10).exponent) == -1
    expect((5╱100).exponent) == -2
    expect((5╱1000).exponent) == -3
    expect((5╱10000).exponent) == -4
    expect((5╱100000).exponent) == -5
    expect((5╱1000000).exponent) == -6
    expect((5╱10000000).exponent) == -7
    expect((5╱100000000).exponent) == -8
    expect((4╱5).exponent) == -1
    expect((3╱4).exponent) == -2
    expect((0╱64).exponent) == 0
    expect((1╱4).exponent) == -2
    expect((3╱8).exponent) == -3
    expect((9╱11).exponent) == -38
    expect((1╱24).exponent) == -38
    expect((8╱3).exponent) == -37
    expect((46╱11).exponent) == -37
    expect((1002331╱24).exponent) == -33
    expect((22╱5).exponent) == -1
    expect((98╱4).exponent) == -1
    expect((63╱8).exponent) == -3
    expect(Fraction.infinity.exponent) == Int.max
    expect(Fraction.infinity.negated().exponent) == Int.max
    expect(Fraction.nan.exponent) == Int.max
    expect(Fraction.signalingNaN.exponent) == Int.max
  }

  func testSignificand() {
    expect((4╱5).significand) == 8╱1
    expect((3╱4).significand) == 75╱1
    expect((0╱64).significand) == Fraction.zero
    expect((1╱4).significand) == 25╱1
    expect((3╱8).significand) == 375╱1
    expect((9╱11).significand) == UInt128(low: 0xf0884a91745d1745, high: 0x3d8d9bcf8fe2a0c0)╱1
    expect((1╱24).significand) == UInt128(low: 0x15bb16c2aaaaaaaa, high: 0x322788703c59d85)╱1
    expect((8╱3).significand) == UInt128(low: 0x57e091aaaaaaaaaa, high: 0x140fd02ce4f0bced)╱1
    expect((46╱11).significand) == UInt128(low: 0xecb77011745d1745, high: 0x1f75e38c3879855c)╱1
    expect((1002331╱24).significand) == UInt128(low: 0xc1aa8dc5eaaaaaaa, high: 0x1f6b69e7fe7a5dad)╱1
    expect((22╱5).significand) == 44╱1
    expect((98╱4).significand) == 245╱1
    expect((63╱8).significand) == 7875╱1
    expect(Fraction.infinity.significand) == Fraction.infinity
    expect(Fraction.infinity.negated().significand) == Fraction.infinity
    expect(Fraction.nan.significand).to(beNaN())
    expect(Fraction.signalingNaN.significand).to(beNaN())
  }

  func testAdd() {
    expect(1╱4 + 2╱4) == 3╱4
    expect(1╱8 + 2╱5) == 21╱40
    expect(Fraction.pi + -Fraction.pi) == Fraction.zero
    expect(1╱4 + Fraction.nan).to(beNaN())
    expect(-1╱4 + Fraction.nan).to(beNaN())
    expect(1╱4 + Fraction.zero) == 1╱4
    expect(1╱4 + -Fraction.zero) == 1╱4
    expect(-1╱4 + Fraction.zero) == -1╱4
    expect(-1╱4 + -Fraction.zero) == -1╱4
    expect(Fraction.zero + Fraction.nan).to(beNaN())
    expect(-Fraction.zero + Fraction.nan).to(beNaN())
    expect(Fraction.nan + Fraction.nan).to(beNaN())
    expect(Fraction.signalingNaN + Fraction.nan).to(beNaN())
    expect(1╱4 + Fraction.infinity) == Fraction.infinity
    expect(1╱4 + -Fraction.infinity) == -Fraction.infinity
    expect(Fraction.infinity + Fraction.infinity) == Fraction.infinity
    expect(Fraction.infinity.negated() + Fraction.infinity.negated()) == Fraction.infinity.negated()
    expect(-Fraction.infinity + Fraction.infinity).to(beNaN())
    expect(Fraction.infinity + -Fraction.infinity).to(beNaN())
  }

  func testSubtract() {
    expect(1╱4 - 2╱4) == -1╱4
    expect(1╱8 - 2╱5) == -11╱40
    expect(Fraction.pi - -Fraction.pi) == (Fraction.pi.numerator * 2)╱Fraction.pi.denominator
    expect(1╱2 - Fraction.nan).to(beNaN())
    expect(1╱4 - Fraction.nan).to(beNaN())
    expect(-1╱4 - Fraction.nan).to(beNaN())
    expect(1╱4 - Fraction.zero) == 1╱4
    expect(1╱4 - -Fraction.zero) == 1╱4
    expect(-1╱4 - Fraction.zero) == -1╱4
    expect(-1╱4 - -Fraction.zero) == -1╱4
    expect(Fraction.zero - Fraction.nan).to(beNaN())
    expect(-Fraction.zero - Fraction.nan).to(beNaN())
    expect(Fraction.nan - Fraction.nan).to(beNaN())
    expect(Fraction.signalingNaN - Fraction.nan).to(beNaN())
    expect(1╱4 - Fraction.infinity) == -Fraction.infinity
    expect(1╱4 - -Fraction.infinity) == Fraction.infinity
    expect(Fraction.infinity - -Fraction.infinity) == Fraction.infinity
    expect(-Fraction.infinity - Fraction.infinity) == -Fraction.infinity
    expect(-Fraction.infinity - -Fraction.infinity).to(beNaN())
    expect(Fraction.infinity - Fraction.infinity).to(beNaN())
  }

  func testMultiply() {
    expect(11╱22 * 1╱1) == 11╱22
    expect(5╱7 * 1╱2) == 5╱14
    expect(4╱2 * Fraction.zero) == Fraction.zero
    expect(Fraction.zero * 9╱32) == Fraction.zero
    expect(Fraction.zero * Fraction.nan).to(beNaN())
    expect(Fraction.nan * 1╱16).to(beNaN())
    expect(Fraction.zero * Fraction.infinity).to(beNaN())
    expect(Fraction.zero * -Fraction.infinity).to(beNaN())
    expect(-Fraction.zero * Fraction.infinity).to(beNaN())
    expect(-Fraction.zero * -Fraction.infinity).to(beNaN())
    expect(1╱2 * Fraction.infinity) == Fraction.infinity
    expect(1╱2 * -Fraction.infinity) == -Fraction.infinity
    expect(-1╱2 * Fraction.infinity) == -Fraction.infinity
    expect(-1╱2 * -Fraction.infinity) == Fraction.infinity
    expect(Fraction.zero * Fraction.zero) == Fraction.zero
    expect(Fraction.zero * -Fraction.zero) == -Fraction.zero
    expect(-Fraction.zero * Fraction.zero) == -Fraction.zero
    expect(-Fraction.zero * -Fraction.zero) == Fraction.zero
  }

  func testAddProduct() {
    expect((11╱22).addingProduct(1╱4, 2╱3)) == 2╱3
    expect((4╱14).addingProduct(4╱2, Fraction.zero)) == 4╱14
    expect((Fraction.zero).addingProduct(-1╱2, 4╱5)) == -2╱5
    expect((2╱3).addingProduct(Fraction.zero, 9╱32)) == 2╱3
    expect((5╱7).addingProduct(Fraction.infinity, 1╱2)) == Fraction.infinity
    expect((5╱7).addingProduct(Fraction.infinity, -1╱2)) == Fraction.infinity.negated()
    expect((5╱7).addingProduct(Fraction.infinity.negated(), 1╱2)) == Fraction.infinity.negated()
    expect((5╱7).negated().addingProduct(Fraction.infinity, 1╱2)) == Fraction.infinity
    expect((1╱2).addingProduct(Fraction.nan, Fraction.zero)).to(beNaN())
    expect((1╱2).addingProduct(Fraction.zero, Fraction.nan)).to(beNaN())
    expect(Fraction.nan.addingProduct(2╱3, 1╱4)).to(beNaN())
    expect((1╱2).addingProduct(Fraction.zero, Fraction.infinity)).to(beNaN())
  }

  func testDivide() {
    expect(11╱22 / 1╱1) == 11╱22
    expect(5╱7 / 1╱2) == 10╱7
    expect(4╱2 / Fraction.zero) == Fraction.infinity
    expect(4╱2 / -Fraction.zero) == -Fraction.infinity
    expect(-4╱2 / Fraction.zero) == -Fraction.infinity
    expect(-4╱2 / -Fraction.zero) == Fraction.infinity
    expect(Fraction.zero / 9╱32) == Fraction.zero
    expect(Fraction.zero / -9╱32) == -Fraction.zero
    expect(-Fraction.zero / 9╱32) == -Fraction.zero
    expect(-Fraction.zero / -9╱32) == Fraction.zero
    expect(Fraction.zero / Fraction.nan).to(beNaN())
    expect(Fraction.nan / 1╱16).to(beNaN())
    expect(Fraction.zero / Fraction.infinity) == Fraction.zero
    expect(Fraction.zero / -Fraction.infinity) == -Fraction.zero
    expect(-Fraction.zero / Fraction.infinity) == -Fraction.zero
    expect(-Fraction.zero / -Fraction.infinity) == Fraction.zero
    expect(1╱2 / Fraction.infinity) == Fraction.zero
    expect(1╱2 / -Fraction.infinity) == -Fraction.zero
    expect(-1╱2 / Fraction.infinity) == -Fraction.zero
    expect(-1╱2 / -Fraction.infinity) == Fraction.zero
    expect(Fraction.zero / Fraction.zero).to(beNaN())
    expect(Fraction.zero / -Fraction.zero).to(beNaN())
    expect(-Fraction.zero / Fraction.zero).to(beNaN())
    expect(-Fraction.zero / -Fraction.zero).to(beNaN())
  }

  func testRemainder() {
    expect((3╱7).remainder(dividingBy: Fraction.infinity)) == 3╱7
    expect((3╱7).remainder(dividingBy: -Fraction.infinity)) == 3╱7
    expect((-3╱7).remainder(dividingBy: Fraction.infinity)) == -3╱7
    expect((-3╱7).remainder(dividingBy: -Fraction.infinity)) == -3╱7
    expect(Fraction.infinity.remainder(dividingBy: 1╱4)).to(beNaN())
    expect(Fraction.infinity.remainder(dividingBy: Fraction.infinity)).to(beNaN())
    expect(Fraction.infinity.remainder(dividingBy: -Fraction.infinity)).to(beNaN())
    expect(Fraction.infinity.negated().remainder(dividingBy: 1╱4)).to(beNaN())
    expect(Fraction.infinity.negated().remainder(dividingBy: Fraction.infinity)).to(beNaN())
    expect(Fraction.infinity.negated().remainder(dividingBy: -Fraction.infinity)).to(beNaN())
    expect(Fraction.infinity.remainder(dividingBy: Fraction.zero)).to(beNaN())
    expect(Fraction.infinity.remainder(dividingBy: -Fraction.zero)).to(beNaN())
    expect(Fraction.infinity.negated().remainder(dividingBy: Fraction.zero)).to(beNaN())
    expect(Fraction.infinity.negated().remainder(dividingBy: -Fraction.zero)).to(beNaN())
    expect(Fraction.zero.remainder(dividingBy: 1╱4)) == Fraction.zero
    expect(Fraction.zero.negated().remainder(dividingBy: 1╱4)) == -Fraction.zero
    expect(Fraction.zero.remainder(dividingBy: Fraction.infinity)) == Fraction.zero
    expect(Fraction.zero.negated().remainder(dividingBy: Fraction.infinity)) == -Fraction.zero
    expect(Fraction.zero.remainder(dividingBy: -Fraction.infinity)) == Fraction.zero
    expect(Fraction.zero.negated().remainder(dividingBy: -Fraction.infinity)) == -Fraction.zero
    expect(Fraction.zero.remainder(dividingBy: Fraction.zero)).to(beNaN())
    expect(Fraction.zero.negated().remainder(dividingBy: Fraction.zero)).to(beNaN())
    expect(Fraction.zero.remainder(dividingBy: -Fraction.zero)).to(beNaN())
    expect(Fraction.zero.negated().remainder(dividingBy: -Fraction.zero)).to(beNaN())

    // 3.6.remainder(dividingBy: 0.6) = 0.00000000000000022204460492503131
    expect((18╱5).remainder(dividingBy: 3╱5)) == Fraction.zero
    // 9.11.remainder(dividingBy: 0.1) = 0.0099999999999989264
    expect((911╱100).remainder(dividingBy: 1╱10)) == 1╱100
    // 3.25.remainder(dividingBy: 1.5) = 0.25
    expect((13╱4).remainder(dividingBy: 3╱2)) == 1╱4
    // 8.625.remainder(dividingBy: 0.75) = -0.375
    expect((69╱8).remainder(dividingBy: 3╱4)) == -3╱8
  }

  func testTruncatingRemainder() {
    expect((3╱7).truncatingRemainder(dividingBy: Fraction.infinity)) == 3╱7
    expect((3╱7).truncatingRemainder(dividingBy: -Fraction.infinity)) == 3╱7
    expect((-3╱7).truncatingRemainder(dividingBy: Fraction.infinity)) == -3╱7
    expect((-3╱7).truncatingRemainder(dividingBy: -Fraction.infinity)) == -3╱7
    expect(Fraction.infinity.truncatingRemainder(dividingBy: 1╱4)).to(beNaN())
    expect(Fraction.infinity.truncatingRemainder(dividingBy: Fraction.infinity)).to(beNaN())
    expect(Fraction.infinity.truncatingRemainder(dividingBy: -Fraction.infinity)).to(beNaN())
    expect(Fraction.infinity.negated().truncatingRemainder(dividingBy: 1╱4)).to(beNaN())
    expect(Fraction.infinity.negated().truncatingRemainder(dividingBy: Fraction.infinity)).to(beNaN())
    expect(Fraction.infinity.negated().truncatingRemainder(dividingBy: -Fraction.infinity)).to(beNaN())
    expect(Fraction.infinity.truncatingRemainder(dividingBy: Fraction.zero)).to(beNaN())
    expect(Fraction.infinity.truncatingRemainder(dividingBy: -Fraction.zero)).to(beNaN())
    expect(Fraction.infinity.negated().truncatingRemainder(dividingBy: Fraction.zero)).to(beNaN())
    expect(Fraction.infinity.negated().truncatingRemainder(dividingBy: -Fraction.zero)).to(beNaN())
    expect(Fraction.zero.truncatingRemainder(dividingBy: 1╱4)) == Fraction.zero
    expect(Fraction.zero.negated().truncatingRemainder(dividingBy: 1╱4)) == -Fraction.zero
    expect(Fraction.zero.truncatingRemainder(dividingBy: Fraction.infinity)) == Fraction.zero
    expect(Fraction.zero.negated().truncatingRemainder(dividingBy: Fraction.infinity)) == -Fraction.zero
    expect(Fraction.zero.truncatingRemainder(dividingBy: -Fraction.infinity)) == Fraction.zero
    expect(Fraction.zero.negated().truncatingRemainder(dividingBy: -Fraction.infinity)) == -Fraction.zero
    expect(Fraction.zero.truncatingRemainder(dividingBy: Fraction.zero)).to(beNaN())
    expect(Fraction.zero.negated().truncatingRemainder(dividingBy: Fraction.zero)).to(beNaN())
    expect(Fraction.zero.truncatingRemainder(dividingBy: -Fraction.zero)).to(beNaN())
    expect(Fraction.zero.negated().truncatingRemainder(dividingBy: -Fraction.zero)).to(beNaN())

    // 3.6.truncatingRemainder(dividingBy: 0.6) = 0.00000000000000044408920985006262
    expect((18╱5).truncatingRemainder(dividingBy: 3╱5)) == Fraction.zero
    // 9.11.truncatingRemainder(dividingBy: 0.1) = 0.0099999999999997868
    expect((911╱100).truncatingRemainder(dividingBy: 1╱10)) == 1╱100
    // 3.25.truncatingRemainder(dividingBy: 1.5) = 0.25
    expect((13╱4).truncatingRemainder(dividingBy: 3╱2)) == 1╱4
    // 8.625.truncatingRemainder(dividingBy: 0.75) = 0.375
    expect((69╱8).truncatingRemainder(dividingBy: 3╱4)) == 3╱8
  }

  func testSquareRoot() {
    expect(Fraction.infinity.squareRoot()) == Fraction.infinity
    expect(Fraction.infinity.negated().squareRoot()).to(beNaN())
    expect(Fraction.zero.squareRoot()) == Fraction.zero
    expect(Fraction.zero.negated().squareRoot()) == Fraction.zero.negated()
    expect(Fraction.nan.squareRoot()).to(beNaN())
    expect(Fraction.signalingNaN.squareRoot()).to(beNaN())
    expect(Double((12╱10).squareRoot())).to(equalWithAccuracy(1.2.squareRoot(), 0.00000000000001))
    expect(Double((-12╱10).squareRoot())).to(equalWithAccuracy(-1.2.squareRoot(), 0.00000000000001))
    expect(Double((12525╱100).squareRoot())).to(equalWithAccuracy(125.25.squareRoot(), 0.00000000000001))
    expect(Double((4╱9).squareRoot())).to(equalWithAccuracy((4.0/9.0).squareRoot(), 0.00000000000001))
  }

  func testRounding() {
    expect((1╱2).rounded(.awayFromZero)) == 1
    expect((1╱2).rounded(.down)) == 0
    expect((1╱2).rounded(.toNearestOrAwayFromZero)) == 1
    expect((1╱2).rounded(.toNearestOrEven)) == 0
    expect((1╱2).rounded(.towardZero)) == 0
    expect((1╱2).rounded(.up)) == 1

    expect((1╱2).negated().rounded(.awayFromZero)) == -1
    expect((1╱2).negated().rounded(.down)) == -1
    expect((1╱2).negated().rounded(.toNearestOrAwayFromZero)) == -1
    expect((1╱2).negated().rounded(.toNearestOrEven)) == Fraction.zero.negated()
    expect((1╱2).negated().rounded(.towardZero)) == Fraction.zero.negated()
    expect((1╱2).negated().rounded(.up)) == Fraction.zero.negated()

    expect((3╱2).rounded(.awayFromZero)) == 2
    expect((3╱2).rounded(.down)) == 1
    expect((3╱2).rounded(.toNearestOrAwayFromZero)) == 2
    expect((3╱2).rounded(.toNearestOrEven)) == 2
    expect((3╱2).rounded(.towardZero)) == 1
    expect((3╱2).rounded(.up)) == 2

    expect((3╱2).negated().rounded(.awayFromZero)) == -2
    expect((3╱2).negated().rounded(.down)) == -2
    expect((3╱2).negated().rounded(.toNearestOrAwayFromZero)) == -2
    expect((3╱2).negated().rounded(.toNearestOrEven)) == -2
    expect((3╱2).negated().rounded(.towardZero)) == -1
    expect((3╱2).negated().rounded(.up)) == -1

    expect((1╱3).rounded(.awayFromZero)) == 1
    expect((1╱3).rounded(.down)) == 0
    expect((1╱3).rounded(.toNearestOrAwayFromZero)) == 0
    expect((1╱3).rounded(.toNearestOrEven)) == 0
    expect((1╱3).rounded(.towardZero)) == 0
    expect((1╱3).rounded(.up)) == 1

    expect((1╱3).negated().rounded(.awayFromZero)) == -1
    expect((1╱3).negated().rounded(.down)) == -1
    expect((1╱3).negated().rounded(.toNearestOrAwayFromZero)) == Fraction.zero.negated()
    expect((1╱3).negated().rounded(.toNearestOrEven)) == Fraction.zero.negated()
    expect((1╱3).negated().rounded(.towardZero)) == Fraction.zero.negated()
    expect((1╱3).negated().rounded(.up)) == Fraction.zero.negated()

    expect((4╱5).rounded(.awayFromZero)) == 1
    expect((4╱5).rounded(.down)) == 0
    expect((4╱5).rounded(.toNearestOrAwayFromZero)) == 1
    expect((4╱5).rounded(.toNearestOrEven)) == 1
    expect((4╱5).rounded(.towardZero)) == 0
    expect((4╱5).rounded(.up)) == 1

    expect((4╱5).negated().rounded(.awayFromZero)) == -1
    expect((4╱5).negated().rounded(.down)) == -1
    expect((4╱5).negated().rounded(.toNearestOrAwayFromZero)) == -1
    expect((4╱5).negated().rounded(.toNearestOrEven)) == -1
    expect((4╱5).negated().rounded(.towardZero)) == Fraction.zero.negated()
    expect((4╱5).negated().rounded(.up)) == Fraction.zero.negated()

    expect(Fraction.zero.rounded(.awayFromZero)) == 0
    expect(Fraction.zero.rounded(.down)) == 0
    expect(Fraction.zero.rounded(.toNearestOrAwayFromZero)) == 0
    expect(Fraction.zero.rounded(.toNearestOrEven)) == 0
    expect(Fraction.zero.rounded(.towardZero)) == 0
    expect(Fraction.zero.rounded(.up)) == 0

    expect(Fraction.zero.negated().rounded(.awayFromZero)) == Fraction.zero.negated()
    expect(Fraction.zero.negated().rounded(.down)) == Fraction.zero.negated()
    expect(Fraction.zero.negated().rounded(.toNearestOrAwayFromZero)) == Fraction.zero.negated()
    expect(Fraction.zero.negated().rounded(.toNearestOrEven)) == Fraction.zero.negated()
    expect(Fraction.zero.negated().rounded(.towardZero)) == Fraction.zero.negated()
    expect(Fraction.zero.negated().rounded(.up)) == Fraction.zero.negated()

    expect(Fraction.infinity.rounded(.awayFromZero)) == Fraction.infinity
    expect(Fraction.infinity.rounded(.down)) == Fraction.infinity
    expect(Fraction.infinity.rounded(.toNearestOrAwayFromZero)) == Fraction.infinity
    expect(Fraction.infinity.rounded(.toNearestOrEven)) == Fraction.infinity
    expect(Fraction.infinity.rounded(.towardZero)) == Fraction.infinity
    expect(Fraction.infinity.rounded(.up)) == Fraction.infinity

    expect(Fraction.infinity.negated().rounded(.awayFromZero)) == Fraction.infinity.negated()
    expect(Fraction.infinity.negated().rounded(.down)) == Fraction.infinity.negated()
    expect(Fraction.infinity.negated().rounded(.toNearestOrAwayFromZero)) == Fraction.infinity.negated()
    expect(Fraction.infinity.negated().rounded(.toNearestOrEven)) == Fraction.infinity.negated()
    expect(Fraction.infinity.negated().rounded(.towardZero)) == Fraction.infinity.negated()
    expect(Fraction.infinity.negated().rounded(.up)) == Fraction.infinity.negated()
  }

  func testFloatingPointClass() {
    expect(Fraction.nan.floatingPointClass) == FloatingPointClassification.quietNaN
    expect(Fraction.signalingNaN.floatingPointClass) == FloatingPointClassification.signalingNaN
    expect(Fraction.zero.floatingPointClass) == FloatingPointClassification.positiveZero
    expect(Fraction.zero.negated().floatingPointClass) == FloatingPointClassification.negativeZero
    expect(Fraction.infinity.floatingPointClass) == FloatingPointClassification.positiveInfinity
    expect(Fraction.infinity.negated().floatingPointClass) == FloatingPointClassification.negativeInfinity
    expect(Fraction(sign: .plus, numerator: 1, denominator: 34).floatingPointClass) == FloatingPointClassification.positiveNormal
    expect(Fraction(sign: .minus, numerator: 1, denominator: 34).floatingPointClass) == FloatingPointClassification.negativeNormal
  }

  func testInitializeWithSignExponentSignificand() {
    expect(Fraction(sign: .plus, exponent:  -1, significand: 8╱1)) == 4╱5
    expect(Fraction(sign: .plus, exponent:  -2, significand: 75╱1)) == 3╱4
    expect(Fraction(sign: .plus, exponent:   0, significand: Fraction.zero)) == 0╱64
    expect(Fraction(sign: .plus, exponent:  -2, significand: 25╱1)) == 1╱4
    expect(Fraction(sign: .plus, exponent:  -3, significand: 375╱1)) == 3╱8
    expect(Fraction(sign: .plus, exponent: -38, significand: UInt128(low: 0xf0884a91745d1745, high: 0x3d8d9bcf8fe2a0c0)╱1)) == 9╱11
    expect(Fraction(sign: .plus, exponent: -38, significand: UInt128(low: 0x15bb16c2aaaaaaaa, high: 0x322788703c59d85)╱1)) == 1╱24
    expect(Fraction(sign: .plus, exponent: -37, significand: UInt128(low: 0x57e091aaaaaaaaaa, high: 0x140fd02ce4f0bced)╱1)) == 8╱3
    expect(Fraction(sign: .plus, exponent: -37, significand: UInt128(low: 0xecb77011745d1745, high: 0x1f75e38c3879855c)╱1)) == 46╱11
    expect(Fraction(sign: .plus, exponent: -33, significand: UInt128(low: 0xc1aa8dc5eaaaaaaa, high: 0x1f6b69e7fe7a5dad)╱1)) == 1002331╱24
    expect(Fraction(sign: .plus, exponent:  -1, significand: 44╱1)) == 22╱5
    expect(Fraction(sign: .plus, exponent:  -1, significand: 245╱1)) == 98╱4
    expect(Fraction(sign: .plus, exponent:  -3, significand: 7875╱1)) == 63╱8

    expect(Fraction(sign: .minus, exponent:  -1, significand: 8╱1)) == (4╱5).negated()
    expect(Fraction(sign: .minus, exponent:  -2, significand: 75╱1)) == (3╱4).negated()
    expect(Fraction(sign: .minus, exponent:   0, significand: Fraction.zero)) == (0╱64).negated()
    expect(Fraction(sign: .minus, exponent:  -2, significand: 25╱1)) == (1╱4).negated()
    expect(Fraction(sign: .minus, exponent:  -3, significand: 375╱1)) == (3╱8).negated()
    expect(Fraction(sign: .minus, exponent: -38, significand: UInt128(low: 0xf0884a91745d1745, high: 0x3d8d9bcf8fe2a0c0)╱1)) == (9╱11).negated()
    expect(Fraction(sign: .minus, exponent: -38, significand: UInt128(low: 0x15bb16c2aaaaaaaa, high: 0x322788703c59d85)╱1)) == (1╱24).negated()
    expect(Fraction(sign: .minus, exponent: -37, significand: UInt128(low: 0x57e091aaaaaaaaaa, high: 0x140fd02ce4f0bced)╱1)) == (8╱3).negated()
    expect(Fraction(sign: .minus, exponent: -37, significand: UInt128(low: 0xecb77011745d1745, high: 0x1f75e38c3879855c)╱1)) == (46╱11).negated()
    expect(Fraction(sign: .minus, exponent: -33, significand: UInt128(low: 0xc1aa8dc5eaaaaaaa, high: 0x1f6b69e7fe7a5dad)╱1)) == (1002331╱24).negated()
    expect(Fraction(sign: .minus, exponent:  -1, significand: 44╱1)) == (22╱5).negated()
    expect(Fraction(sign: .minus, exponent:  -1, significand: 245╱1)) == (98╱4).negated()
    expect(Fraction(sign: .minus, exponent:  -3, significand: 7875╱1)) == (63╱8).negated()

    expect(Fraction(sign: .plus, exponent: 1, significand: Fraction.infinity)) == Fraction.infinity
    expect(Fraction(sign: .minus, exponent: 1, significand: Fraction.infinity)) == Fraction.infinity.negated()
    expect(Fraction(sign: .plus, exponent: 1, significand: Fraction.nan)).to(beNaN())
    expect(Fraction(sign: .minus, exponent: 1, significand: Fraction.nan)).to(beNaN())
  }

  func testInitializeWithSignMagnitude() {
    expect(Fraction(sign: .plus, magnitude: 1╱3)) == 1╱3
    expect(Fraction(sign: .minus, magnitude: 1╱3)) == (1╱3).negated()
    expect(Fraction(sign: .plus, magnitude: (1╱3).negated())) == 1╱3
    expect(Fraction(sign: .minus, magnitude: (1╱3).negated())) == (1╱3).negated()
    expect(Fraction(sign: .plus, magnitude: Fraction.infinity)) == Fraction.infinity
    expect(Fraction(sign: .minus, magnitude: Fraction.infinity)) == Fraction.infinity.negated()
    expect(Fraction(sign: .plus, magnitude: Fraction.infinity.negated())) == Fraction.infinity
    expect(Fraction(sign: .minus, magnitude: Fraction.infinity.negated())) == Fraction.infinity.negated()
    expect(Fraction(sign: .plus, magnitude: Fraction.zero)) == Fraction.zero
    expect(Fraction(sign: .minus, magnitude: Fraction.zero)) == Fraction.zero.negated()
    expect(Fraction(sign: .plus, magnitude: Fraction.zero.negated())) == Fraction.zero
    expect(Fraction(sign: .minus, magnitude: Fraction.zero.negated())) == Fraction.zero.negated()
    expect(Fraction(sign: .plus, magnitude: Fraction.nan)).to(beNaN())
    expect(Fraction(sign: .minus, magnitude: Fraction.nan)).to(beNaN())
    expect(Fraction(sign: .plus, magnitude: Fraction.signalingNaN)).to(beNaN())
    expect(Fraction(sign: .minus, magnitude: Fraction.signalingNaN)).to(beNaN())
  }

  func testReduce() {
    expect((42824╱99900).reduced()) == 10706╱24975
    expect((-2╱8).reduced()) == -1╱4
    expect(Fraction.zero.reduced()) == Fraction.zero
    expect(Fraction.zero.negated().reduced()) == -Fraction.zero
    expect(Fraction.infinity.reduced()) == Fraction.infinity
    expect(Fraction.infinity.negated().reduced()) == -Fraction.infinity
    expect(Fraction.nan.reduced()).to(beNaN())
    expect(Fraction.signalingNaN.reduced()).to(beSignalingNaN())

    expect((4╱5).decimalForm.reduced()) == 4╱5
    expect((3╱4).decimalForm.reduced()) == 3╱4
    expect((0╱64).decimalForm.reduced()) == 0╱64
    expect((1╱4).decimalForm.reduced()) == 1╱4
    expect((3╱8).decimalForm.reduced()) == 3╱8
    expect((9╱11).decimalForm.reduced()) == 9╱11
    expect((1╱24).decimalForm.reduced()) == 1╱24
    expect((8╱3).decimalForm.reduced()) == 8╱3
    expect((46╱11).decimalForm.reduced()) == 46╱11
    expect((1002331╱24).decimalForm.reduced()) == 1002331╱24
    expect((22╱5).decimalForm.reduced()) == 22╱5
    expect((98╱4).decimalForm.reduced()) == 98╱4
    expect((63╱8).decimalForm.reduced()) == 63╱8
  }

  func testEqualities() {
    // -nan, -snan, -inf, -⅔, -⅓, -0, 0, ⅓, ⅔, inf, snan, nan
    let a = Fraction.nan.negated()
    let b = Fraction.signalingNaN.negated()
    let c = Fraction.infinity.negated()
    let d = -2╱3
    let e = -1╱3
    let f = Fraction.zero.negated()
    let g = Fraction.zero
    let h = 1╱3
    let i = 2╱3
    let j = Fraction.infinity
    let k = Fraction.signalingNaN
    let l = Fraction.nan

    let fractions = [a, b, c, d, e, f, g, h, i, j, k, l]
    for (i, x) in fractions.enumerated() {
      for y in fractions[i+1..<fractions.endIndex] {
        expect(x.isLessThanOrEqualTo(y)) == Bool(!(x.isNaN || y.isNaN))
      }
    }
  }

  func testTotalOrder() {
    // -nan, -snan, -inf, -⅔, -⅓, -0, 0, ⅓, ⅔, inf, snan, nan
    let a = Fraction.nan.negated()
    let b = Fraction.signalingNaN.negated()
    let c = Fraction.infinity.negated()
    let d = -2╱3
    let e = -1╱3
    let f = Fraction.zero.negated()
    let g = Fraction.zero
    let h = 1╱3
    let i = 2╱3
    let j = Fraction.infinity
    let k = Fraction.signalingNaN
    let l = Fraction.nan

    let fractions = [a, b, c, d, e, f, g, h, i, j, k, l]
    for (i, x) in fractions.enumerated() {
      for y in fractions[i+1..<fractions.endIndex] {
        expect(x.isTotallyOrdered(belowOrEqualTo: y)) == true
      }
    }
  }

  func testReciprocal() {
    expect((1╱3).reciprocal) == 3╱1
    expect((-1╱3).reciprocal) == -3╱1
    expect(Fraction.pi.reciprocal) == Fraction.pi.denominator╱Fraction.pi.numerator
    expect(Fraction.infinity.reciprocal) == Fraction.zero
    expect(Fraction.infinity.negated().reciprocal) == -Fraction.zero
    expect(Fraction.zero.reciprocal) == Fraction.infinity
    expect(Fraction.zero.negated().reciprocal) == -Fraction.infinity
  }

  func testDoubleRoundTrip() {
    expect(Fraction(Double(1╱2))) == 1╱2
    expect(Fraction(Double(1╱3))) == 1╱3
    expect(Fraction(Double(2╱3))) == 2╱3
    expect(Fraction(Double(1╱4))) == 1╱4
    expect(Fraction(Double(2╱4))) == 2╱4
    expect(Fraction(Double(3╱4))) == 3╱4
    expect(Fraction(Double(1╱5))) == 1╱5
    expect(Fraction(Double(2╱5))) == 2╱5
    expect(Fraction(Double(3╱5))) == 3╱5
    expect(Fraction(Double(4╱5))) == 4╱5
    expect(Fraction(Double(1╱6))) == 1╱6
    expect(Fraction(Double(2╱6))) == 2╱6
    expect(Fraction(Double(3╱6))) == 3╱6
    expect(Fraction(Double(4╱6))) == 4╱6
    expect(Fraction(Double(5╱6))) == 5╱6
    expect(Fraction(Double(1╱7))) == 1╱7
    expect(Fraction(Double(2╱7))) == 2╱7
    expect(Fraction(Double(3╱7))) == 3╱7
    expect(Fraction(Double(4╱7))) == 4╱7
    expect(Fraction(Double(5╱7))) == 5╱7
    expect(Fraction(Double(6╱7))) == 6╱7
    expect(Fraction(Double(1╱8))) == 1╱8
    expect(Fraction(Double(2╱8))) == 2╱8
    expect(Fraction(Double(3╱8))) == 3╱8
    expect(Fraction(Double(4╱8))) == 4╱8
    expect(Fraction(Double(5╱8))) == 5╱8
    expect(Fraction(Double(6╱8))) == 6╱8
    expect(Fraction(Double(7╱8))) == 7╱8
    expect(Fraction(Double(1╱9))) == 1╱9
    expect(Fraction(Double(2╱9))) == 2╱9
    expect(Fraction(Double(3╱9))) == 3╱9
    expect(Fraction(Double(4╱9))) == 4╱9
    expect(Fraction(Double(5╱9))) == 5╱9
    expect(Fraction(Double(6╱9))) == 6╱9
    expect(Fraction(Double(7╱9))) == 7╱9
    expect(Fraction(Double(8╱9))) == 8╱9
    expect(Fraction(Double(1╱10))) == 1╱10
    expect(Fraction(Double(2╱10))) == 2╱10
    expect(Fraction(Double(3╱10))) == 3╱10
    expect(Fraction(Double(4╱10))) == 4╱10
    expect(Fraction(Double(5╱10))) == 5╱10
    expect(Fraction(Double(6╱10))) == 6╱10
    expect(Fraction(Double(7╱10))) == 7╱10
    expect(Fraction(Double(8╱10))) == 8╱10
    expect(Fraction(Double(9╱10))) == 9╱10
  }

  func testInitializeWithDouble() {
    let nan = Fraction(Double.nan)
    expect(nan).to(beNaN())
    expect(nan).toNot(beSignalingNaN())
    expect(nan.numerator) == 0
    expect(nan.denominator) == 1

    let snan = Fraction(Double.signalingNaN)
    expect(snan).to(beNaN())
    expect(snan).to(beSignalingNaN())
    expect(snan.numerator) == 0
    expect(snan.denominator) == 1

    let inf = Fraction(Double.infinity)
    expect(inf) == Fraction.infinity

    let negativeInf = Fraction(-Double.infinity)
    expect(negativeInf) == -Fraction.infinity

    expect(Fraction(Double.pi)).to(equalWithAccuracy(Fraction.pi, 1╱1000000000000000))
    expect(Fraction(-Double.pi)).to(equalWithAccuracy(Fraction.pi.negated(), (1╱1000000000000000)))
  }

  func testConversionToDouble() {
    expect(Double(1╱2)) == 0.5
    expect(Double(1╱3)) == 0.33333333333333333
    expect(Double(2╱3)) == 0.66666666666666666
    expect(Double(1╱4)) == 0.25
    expect(Double(2╱4)) == 0.5
    expect(Double(3╱4)) == 0.75
    expect(Double(1╱5)) == 0.2
    expect(Double(2╱5)) == 0.4
    expect(Double(3╱5)) == 0.6
    expect(Double(4╱5)) == 0.8
    expect(Double(1╱6)) == 0.16666666666666666
    expect(Double(2╱6)) == 0.33333333333333333
    expect(Double(3╱6)) == 0.5
    expect(Double(4╱6)) == 0.66666666666666666
    expect(Double(5╱6)) == 0.83333333333333333
    expect(Double(1╱7)) == 0.14285714285714285
    expect(Double(2╱7)) == 0.28571428571428571
    expect(Double(3╱7)) == 0.42857142857142857
    expect(Double(4╱7)) == 0.57142857142857142
    expect(Double(5╱7)) == 0.71428571428571428
    expect(Double(6╱7)) == 0.85714285714285714
    expect(Double(1╱8)) == 0.125
    expect(Double(2╱8)) == 0.25
    expect(Double(3╱8)) == 0.375
    expect(Double(4╱8)) == 0.5
    expect(Double(5╱8)) == 0.625
    expect(Double(6╱8)) == 0.75
    expect(Double(7╱8)) == 0.875
    expect(Double(1╱9)) == 0.11111111111111111
    expect(Double(2╱9)) == 0.22222222222222222
    expect(Double(3╱9)) == 0.33333333333333333
    expect(Double(4╱9)) == 0.44444444444444444
    expect(Double(5╱9)) == 0.55555555555555555
    expect(Double(6╱9)) == 0.66666666666666666
    expect(Double(7╱9)) == 0.77777777777777777
    expect(Double(8╱9)) == 0.88888888888888888
    expect(Double(1╱10)) == 0.1
    expect(Double(2╱10)) == 0.2
    expect(Double(3╱10)) == 0.3
    expect(Double(4╱10)) == 0.4
    expect(Double(5╱10)) == 0.5
    expect(Double(6╱10)) == 0.6
    expect(Double(7╱10)) == 0.7
    expect(Double(8╱10)) == 0.8
    expect(Double(9╱10)) == 0.9
  }

}
