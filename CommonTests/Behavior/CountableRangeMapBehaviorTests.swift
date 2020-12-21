//
//  CountableRangeMapBehaviorTests.swift
//  CountableRangeMapTests
//
//  Created by Jason Cardwell on 5/31/16.
//  Copyright © 2016 Jason Cardwell. All rights reserved.
//
@testable import MoonKit
import Nimble
import XCTest

final class CountableRangeMapBehaviorTests: XCTestCase {
  static let rangeMap = CountableRangeMap<Int>(CountableRangeMapBehaviorTests.ranges)

  static let integers = [8, 22, 2, 44, 88, 17, 29, 33]

  static let ranges: [ClosedRange<Int>] = [4...17, 29...33, 37...46, 49...53, 64...77]

  func testCreation() {
    let ranges = CountableRangeMapBehaviorTests.ranges
    let integers = CountableRangeMapBehaviorTests.integers

    let rangeMap0 = CountableRangeMap<Int>()
    expect(rangeMap0).to(haveCount(0))
    expect(rangeMap0.coverage).to(beNil())
    expect(rangeMap0.lowerBound).to(beNil())
    expect(rangeMap0.upperBound).to(beNil())
    expect(rangeMap0.min()).to(beNil())
    expect(rangeMap0.max()).to(beNil())

    let rangeMap1 = CountableRangeMap<Int>(ranges)
    expect(rangeMap1).to(haveCount(5))
    expect(rangeMap1[0]) == ranges[0]
    expect(rangeMap1[1]) == ranges[1]
    expect(rangeMap1[2]) == ranges[2]
    expect(rangeMap1[3]) == ranges[3]
    expect(rangeMap1[4]) == ranges[4]
    expect(rangeMap1.coverage) == 4...77
    expect(rangeMap1.lowerBound) == 4
    expect(rangeMap1.upperBound) == 77
    expect(rangeMap1.min()) == 4...17
    expect(rangeMap1.max()) == 64...77

    let rangeMap2 = CountableRangeMap<Int>(ranges[0])
    expect(rangeMap2).to(haveCount(1))
    expect(rangeMap2[0]) == ranges[0]
    expect(rangeMap2.coverage) == 4...17
    expect(rangeMap2.lowerBound) == 4
    expect(rangeMap2.upperBound) == 17
    expect(rangeMap2.min()) == 4...17
    expect(rangeMap2.max()) == 4...17

    let rangeMap2a = CountableRangeMap<Int>(CountableRange(ranges[0]))
    expect(rangeMap2a).to(haveCount(1))
    expect(rangeMap2a[0]) == ranges[0]
    expect(rangeMap2a.coverage) == 4...17
    expect(rangeMap2a.lowerBound) == 4
    expect(rangeMap2a.upperBound) == 17
    expect(rangeMap2a.min()) == 4...17
    expect(rangeMap2a.max()) == 4...17

    let rangeMap2b = CountableRangeMap<Int>(Range(ranges[0]))
    expect(rangeMap2b).to(haveCount(1))
    expect(rangeMap2b[0]) == ranges[0]
    expect(rangeMap2b.coverage) == 4...17
    expect(rangeMap2b.lowerBound) == 4
    expect(rangeMap2b.upperBound) == 17
    expect(rangeMap2b.min()) == 4...17
    expect(rangeMap2b.max()) == 4...17

    let rangeMap2c = CountableRangeMap<Int>(ranges[0])
    expect(rangeMap2c).to(haveCount(1))
    expect(rangeMap2c[0]) == ranges[0]
    expect(rangeMap2c.coverage) == 4...17
    expect(rangeMap2c.lowerBound) == 4
    expect(rangeMap2c.upperBound) == 17
    expect(rangeMap2c.min()) == 4...17
    expect(rangeMap2c.max()) == 4...17

    let rangeMap3 = CountableRangeMap<Int>(integers)
    expect(rangeMap3).to(haveCount(8))
    expect(rangeMap3[0]) == 2...2
    expect(rangeMap3[1]) == 8...8
    expect(rangeMap3[2]) == 17...17
    expect(rangeMap3[3]) == 22...22
    expect(rangeMap3[4]) == 29...29
    expect(rangeMap3[5]) == 33...33
    expect(rangeMap3[6]) == 44...44
    expect(rangeMap3[7]) == 88...88
    expect(rangeMap3.coverage) == 2...88
    expect(rangeMap3.lowerBound) == 2
    expect(rangeMap3.upperBound) == 88
    expect(rangeMap3.min()) == 2...2
    expect(rangeMap3.max()) == 88...88
  }

  func testIndexOfBound() {
    let rangeMap = CountableRangeMapBehaviorTests.rangeMap
    expect(rangeMap.index(of: 4)) == 0
    expect(rangeMap.index(of: 8)) == 0
    expect(rangeMap.index(of: 17)) == 0
    expect(rangeMap.index(of: 29)) == 1
    expect(rangeMap.index(of: 31)) == 1
    expect(rangeMap.index(of: 33)) == 1
    expect(rangeMap.index(of: 37)) == 2
    expect(rangeMap.index(of: 44)) == 2
    expect(rangeMap.index(of: 46)) == 2
    expect(rangeMap.index(of: 49)) == 3
    expect(rangeMap.index(of: 51)) == 3
    expect(rangeMap.index(of: 53)) == 3
    expect(rangeMap.index(of: 64)) == 4
    expect(rangeMap.index(of: 70)) == 4
    expect(rangeMap.index(of: 77)) == 4
    expect(rangeMap.index(of: 3)).to(beNil())
    expect(rangeMap.index(of: 78)).to(beNil())
  }

  func testIndexOfRange() {
    let rangeMap = CountableRangeMapBehaviorTests.rangeMap
    expect(rangeMap.index(of: 4...17)) == 0
    expect(rangeMap.index(of: 4...11)) == 0
    expect(rangeMap.index(of: 8...17)) == 0
    expect(rangeMap.index(of: 8...11)) == 0
    expect(rangeMap.index(of: 29...33)) == 1
    expect(rangeMap.index(of: 29...31)) == 1
    expect(rangeMap.index(of: 30...33)) == 1
    expect(rangeMap.index(of: 30...31)) == 1
    expect(rangeMap.index(of: 37...46)) == 2
    expect(rangeMap.index(of: 37...44)) == 2
    expect(rangeMap.index(of: 40...46)) == 2
    expect(rangeMap.index(of: 37...40)) == 2
    expect(rangeMap.index(of: 49...53)) == 3
    expect(rangeMap.index(of: 49...51)) == 3
    expect(rangeMap.index(of: 50...53)) == 3
    expect(rangeMap.index(of: 50...51)) == 3
    expect(rangeMap.index(of: 64...77)) == 4
    expect(rangeMap.index(of: 64...70)) == 4
    expect(rangeMap.index(of: 68...77)) == 4
    expect(rangeMap.index(of: 68...70)) == 4
    expect(rangeMap.index(of: 0...3)).to(beNil())
    expect(rangeMap.index(of: 70...78)).to(beNil())
  }

  func testContainsBound() {
    let rangeMap = CountableRangeMapBehaviorTests.rangeMap
    expect(rangeMap.contains(4)) == true
    expect(rangeMap.contains(8)) == true
    expect(rangeMap.contains(17)) == true
    expect(rangeMap.contains(29)) == true
    expect(rangeMap.contains(31)) == true
    expect(rangeMap.contains(33)) == true
    expect(rangeMap.contains(37)) == true
    expect(rangeMap.contains(44)) == true
    expect(rangeMap.contains(46)) == true
    expect(rangeMap.contains(49)) == true
    expect(rangeMap.contains(51)) == true
    expect(rangeMap.contains(53)) == true
    expect(rangeMap.contains(64)) == true
    expect(rangeMap.contains(70)) == true
    expect(rangeMap.contains(77)) == true
    expect(rangeMap.contains(3)) == false
    expect(rangeMap.contains(78)) == false
  }

  func testContainsRange() {
    let rangeMap = CountableRangeMapBehaviorTests.rangeMap
    expect(rangeMap.contains(4...17)) == true
    expect(rangeMap.contains(4...11)) == true
    expect(rangeMap.contains(8...17)) == true
    expect(rangeMap.contains(8...11)) == true
    expect(rangeMap.contains(29...33)) == true
    expect(rangeMap.contains(29...31)) == true
    expect(rangeMap.contains(30...33)) == true
    expect(rangeMap.contains(30...31)) == true
    expect(rangeMap.contains(37...46)) == true
    expect(rangeMap.contains(37...44)) == true
    expect(rangeMap.contains(40...46)) == true
    expect(rangeMap.contains(37...40)) == true
    expect(rangeMap.contains(49...53)) == true
    expect(rangeMap.contains(49...51)) == true
    expect(rangeMap.contains(50...53)) == true
    expect(rangeMap.contains(50...51)) == true
    expect(rangeMap.contains(64...77)) == true
    expect(rangeMap.contains(64...70)) == true
    expect(rangeMap.contains(68...77)) == true
    expect(rangeMap.contains(68...70)) == true
    expect(rangeMap.contains(0...3)) == false
    expect(rangeMap.contains(70...78)) == false
  }

  func testRemoveBound() {
    var rangeMap = CountableRangeMapBehaviorTests.rangeMap

    rangeMap.remove(4)
    expect(rangeMap).to(haveCount(5))
    expect(rangeMap[0]) == 5...17
    expect(rangeMap[1]) == 29...33
    expect(rangeMap[2]) == 37...46
    expect(rangeMap[3]) == 49...53
    expect(rangeMap[4]) == 64...77

    rangeMap.remove(17)
    expect(rangeMap).to(haveCount(5))
    expect(rangeMap[0]) == 5...16
    expect(rangeMap[1]) == 29...33
    expect(rangeMap[2]) == 37...46
    expect(rangeMap[3]) == 49...53
    expect(rangeMap[4]) == 64...77

    rangeMap.remove(10)
    expect(rangeMap).to(haveCount(6))
    expect(rangeMap[0]) == 5...9
    expect(rangeMap[1]) == 11...16
    expect(rangeMap[2]) == 29...33
    expect(rangeMap[3]) == 37...46
    expect(rangeMap[4]) == 49...53
    expect(rangeMap[5]) == 64...77

    rangeMap.remove(3)
    expect(rangeMap).to(haveCount(6))
    expect(rangeMap[0]) == 5...9
    expect(rangeMap[1]) == 11...16
    expect(rangeMap[2]) == 29...33
    expect(rangeMap[3]) == 37...46
    expect(rangeMap[4]) == 49...53
    expect(rangeMap[5]) == 64...77
  }

  func testRemoveRange() {
    var rangeMap0 = CountableRangeMapBehaviorTests.rangeMap
    rangeMap0.remove(18...28)
    expect(rangeMap0).to(haveCount(5))
    expect(rangeMap0[0]) == 4...17
    expect(rangeMap0[1]) == 29...33
    expect(rangeMap0[2]) == 37...46
    expect(rangeMap0[3]) == 49...53
    expect(rangeMap0[4]) == 64...77

    var rangeMap1 = CountableRangeMapBehaviorTests.rangeMap
    rangeMap1.remove(37...46)
    expect(rangeMap1).to(haveCount(4))
    expect(rangeMap1[0]) == 4...17
    expect(rangeMap1[1]) == 29...33
    expect(rangeMap1[2]) == 49...53
    expect(rangeMap1[3]) == 64...77

    var rangeMap1a = CountableRangeMapBehaviorTests.rangeMap
    rangeMap1a.remove(CountableRange(37...46))
    expect(rangeMap1a).to(haveCount(4))
    expect(rangeMap1a[0]) == 4...17
    expect(rangeMap1a[1]) == 29...33
    expect(rangeMap1a[2]) == 49...53
    expect(rangeMap1a[3]) == 64...77

    var rangeMap1b = CountableRangeMapBehaviorTests.rangeMap
    rangeMap1b.remove(Range(37...46))
    expect(rangeMap1b).to(haveCount(4))
    expect(rangeMap1b[0]) == 4...17
    expect(rangeMap1b[1]) == 29...33
    expect(rangeMap1b[2]) == 49...53
    expect(rangeMap1b[3]) == 64...77

    var rangeMap1c = CountableRangeMapBehaviorTests.rangeMap
    rangeMap1c.remove(37...46)
    expect(rangeMap1c).to(haveCount(4))
    expect(rangeMap1c[0]) == 4...17
    expect(rangeMap1c[1]) == 29...33
    expect(rangeMap1c[2]) == 49...53
    expect(rangeMap1c[3]) == 64...77

    var rangeMap2 = CountableRangeMapBehaviorTests.rangeMap
    rangeMap2.remove(37...40)
    expect(rangeMap2).to(haveCount(5))
    expect(rangeMap2[0]) == 4...17
    expect(rangeMap2[1]) == 29...33
    expect(rangeMap2[2]) == 41...46
    expect(rangeMap2[3]) == 49...53
    expect(rangeMap2[4]) == 64...77

    var rangeMap3 = CountableRangeMapBehaviorTests.rangeMap
    rangeMap3.remove(42...46)
    expect(rangeMap3).to(haveCount(5))
    expect(rangeMap3[0]) == 4...17
    expect(rangeMap3[1]) == 29...33
    expect(rangeMap3[2]) == 37...41
    expect(rangeMap3[3]) == 49...53
    expect(rangeMap3[4]) == 64...77

    var rangeMap4 = CountableRangeMapBehaviorTests.rangeMap
    rangeMap4.remove(40...42)
    expect(rangeMap4).to(haveCount(6))
    expect(rangeMap4[0]) == 4...17
    expect(rangeMap4[1]) == 29...33
    expect(rangeMap4[2]) == 37...39
    expect(rangeMap4[3]) == 43...46
    expect(rangeMap4[4]) == 49...53
    expect(rangeMap4[5]) == 64...77

    var rangeMap5 = CountableRangeMapBehaviorTests.rangeMap
    rangeMap5.remove(35...38)
    expect(rangeMap5).to(haveCount(5))
    expect(rangeMap5[0]) == 4...17
    expect(rangeMap5[1]) == 29...33
    expect(rangeMap5[2]) == 39...46
    expect(rangeMap5[3]) == 49...53
    expect(rangeMap5[4]) == 64...77

    var rangeMap6 = CountableRangeMapBehaviorTests.rangeMap
    rangeMap6.remove(44...48)
    expect(rangeMap6).to(haveCount(5))
    expect(rangeMap6[0]) == 4...17
    expect(rangeMap6[1]) == 29...33
    expect(rangeMap6[2]) == 37...43
    expect(rangeMap6[3]) == 49...53
    expect(rangeMap6[4]) == 64...77

    var rangeMap7 = CountableRangeMapBehaviorTests.rangeMap
    rangeMap7.remove(37...53)
    expect(rangeMap7).to(haveCount(3))
    expect(rangeMap7[0]) == 4...17
    expect(rangeMap7[1]) == 29...33
    expect(rangeMap7[2]) == 64...77

    var rangeMap8 = CountableRangeMapBehaviorTests.rangeMap
    rangeMap8.remove(37...50)
    expect(rangeMap8).to(haveCount(4))
    expect(rangeMap8[0]) == 4...17
    expect(rangeMap8[1]) == 29...33
    expect(rangeMap8[2]) == 51...53
    expect(rangeMap8[3]) == 64...77

    var rangeMap9 = CountableRangeMapBehaviorTests.rangeMap
    rangeMap9.remove(45...53)
    expect(rangeMap9).to(haveCount(4))
    expect(rangeMap9[0]) == 4...17
    expect(rangeMap9[1]) == 29...33
    expect(rangeMap9[2]) == 37...44
    expect(rangeMap9[3]) == 64...77

    var rangeMap10 = CountableRangeMapBehaviorTests.rangeMap
    rangeMap10.remove(39...51)
    expect(rangeMap10).to(haveCount(5))
    expect(rangeMap10[0]) == 4...17
    expect(rangeMap10[1]) == 29...33
    expect(rangeMap10[2]) == 37...38
    expect(rangeMap10[3]) == 52...53
    expect(rangeMap10[4]) == 64...77

    var rangeMap11 = CountableRangeMapBehaviorTests.rangeMap
    rangeMap11.remove(35...51)
    expect(rangeMap11).to(haveCount(4))
    expect(rangeMap11[0]) == 4...17
    expect(rangeMap11[1]) == 29...33
    expect(rangeMap11[2]) == 52...53
    expect(rangeMap11[3]) == 64...77

    var rangeMap12 = CountableRangeMapBehaviorTests.rangeMap
    rangeMap12.remove(42...60)
    expect(rangeMap12).to(haveCount(4))
    expect(rangeMap12[0]) == 4...17
    expect(rangeMap12[1]) == 29...33
    expect(rangeMap12[2]) == 37...41
    expect(rangeMap12[3]) == 64...77

    var rangeMap13 = CountableRangeMapBehaviorTests.rangeMap
    rangeMap13.remove(35...60)
    expect(rangeMap13).to(haveCount(3))
    expect(rangeMap13[0]) == 4...17
    expect(rangeMap13[1]) == 29...33
    expect(rangeMap13[2]) == 64...77

    var rangeMap14 = CountableRangeMapBehaviorTests.rangeMap
    rangeMap14.remove(17...17)
    expect(rangeMap14).to(haveCount(5))
    expect(rangeMap14[0]) == 4...16
    expect(rangeMap14[1]) == 29...33
    expect(rangeMap14[2]) == 37...46
    expect(rangeMap14[3]) == 49...53
    expect(rangeMap14[4]) == 64...77

    var rangeMap15 = CountableRangeMap<Int>([4...17, 29...33, 37...46, 49...53, 64...77])
    rangeMap15.remove(37...47)
    expect(rangeMap15).to(haveCount(4))
    expect(rangeMap15[0]) == 4...17
    expect(rangeMap15[1]) == 29...33
    expect(rangeMap15[2]) == 49...53
    expect(rangeMap15[3]) == 64...77

    var rangeMap16 = CountableRangeMap<Int>([4...17, 29...33, 37...37, 49...53])
    rangeMap16.remove(32...37)
    expect(rangeMap16).to(haveCount(3))
    expect(rangeMap16[0]) == 4...17
    expect(rangeMap16[1]) == 29...31
    expect(rangeMap16[2]) == 49...53

    var rangeMap17 = CountableRangeMap<Int>([4...17, 29...33, 37...46, 49...53, 64...77])
    rangeMap17.remove(38...49)
    expect(rangeMap17).to(haveCount(5))
    expect(rangeMap17[0]) == 4...17
    expect(rangeMap17[1]) == 29...33
    expect(rangeMap17[2]) == 37...37
    expect(rangeMap17[3]) == 50...53
    expect(rangeMap17[4]) == 64...77

    var rangeMap18 = CountableRangeMap<Int>([4...17, 29...33, 37...37, 49...53, 64...77])
    rangeMap18.remove(37...60)
    expect(rangeMap18).to(haveCount(3))
    expect(rangeMap18[0]) == 4...17
    expect(rangeMap18[1]) == 29...33
    expect(rangeMap18[2]) == 64...77

    var rangeMap19 = CountableRangeMap<Int>([4...17, 29...33, 37...46, 49...53, 64...77])
    rangeMap19.remove(46...60)
    expect(rangeMap19).to(haveCount(4))
    expect(rangeMap19[0]) == 4...17
    expect(rangeMap19[1]) == 29...33
    expect(rangeMap19[2]) == 37...45
    expect(rangeMap19[3]) == 64...77

    var rangeMap20 = CountableRangeMap<Int>([4...17, 29...33, 37...46, 49...53, 64...64])
    rangeMap20.remove(48...64)
    expect(rangeMap20).to(haveCount(3))
    expect(rangeMap20[0]) == 4...17
    expect(rangeMap20[1]) == 29...33
    expect(rangeMap20[2]) == 37...46

    var rangeMap21 = CountableRangeMap<Int>([4...17, 29...33, 37...37, 49...53, 64...77])
    rangeMap21.remove(37...52)
    expect(rangeMap21).to(haveCount(4))
    expect(rangeMap21[0]) == 4...17
    expect(rangeMap21[1]) == 29...33
    expect(rangeMap21[2]) == 53...53
    expect(rangeMap21[3]) == 64...77

    var rangeMap22 = CountableRangeMap<Int>([4...17, 29...33, 37...46, 49...53, 64...77])
    rangeMap22.remove(46...52)
    expect(rangeMap22).to(haveCount(5))
    expect(rangeMap22[0]) == 4...17
    expect(rangeMap22[1]) == 29...33
    expect(rangeMap22[2]) == 37...45
    expect(rangeMap22[3]) == 53...53
    expect(rangeMap22[4]) == 64...77

    var rangeMap23 = CountableRangeMap<Int>([4...17, 29...33, 37...46, 49...53, 64...77])
    rangeMap23.remove(48...53)
    expect(rangeMap23).to(haveCount(4))
    expect(rangeMap23[0]) == 4...17
    expect(rangeMap23[1]) == 29...33
    expect(rangeMap23[2]) == 37...46
    expect(rangeMap23[3]) == 64...77

    rangeMap23.remove(4..<4)
    expect(rangeMap23).to(haveCount(4))
    expect(rangeMap23[0]) == 4...17
    expect(rangeMap23[1]) == 29...33
    expect(rangeMap23[2]) == 37...46
    expect(rangeMap23[3]) == 64...77

    rangeMap23.remove(10..<10)
    expect(rangeMap23).to(haveCount(4))
    expect(rangeMap23[0]) == 4...17
    expect(rangeMap23[1]) == 29...33
    expect(rangeMap23[2]) == 37...46
    expect(rangeMap23[3]) == 64...77
  }

  func testRangeInsertionsLoaded() {
    // Insertions with inner lower and upper

    // LU-1
    var rangeMap1 = CountableRangeMapBehaviorTests.rangeMap
    rangeMap1.insert(40...43)
    expect(rangeMap1).to(haveCount(5))
    expect(rangeMap1[0]) == 4...17
    expect(rangeMap1[1]) == 29...33
    expect(rangeMap1[2]) == 37...46
    expect(rangeMap1[3]) == 49...53
    expect(rangeMap1[4]) == 64...77

    // LU-2
    var rangeMap2 = CountableRangeMapBehaviorTests.rangeMap
    rangeMap2.insert(30...40)
    expect(rangeMap2).to(haveCount(4))
    expect(rangeMap2[0]) == 4...17
    expect(rangeMap2[1]) == 29...46
    expect(rangeMap2[2]) == 49...53
    expect(rangeMap2[3]) == 64...77

    // LU-3
    var rangeMap3 = CountableRangeMapBehaviorTests.rangeMap
    rangeMap3.insert(31...51)
    expect(rangeMap3).to(haveCount(3))
    expect(rangeMap3[0]) == 4...17
    expect(rangeMap3[1]) == 29...53
    expect(rangeMap3[2]) == 64...77

    // LL-1
    var rangeMap4 = CountableRangeMapBehaviorTests.rangeMap
    rangeMap4.insert(32...34)
    expect(rangeMap4).to(haveCount(5))
    expect(rangeMap4[0]) == 4...17
    expect(rangeMap4[1]) == 29...34
    expect(rangeMap4[2]) == 37...46
    expect(rangeMap4[3]) == 49...53
    expect(rangeMap4[4]) == 64...77

    // LL-2
    var rangeMap5 = CountableRangeMapBehaviorTests.rangeMap
    rangeMap5.insert(30...47)
    expect(rangeMap5).to(haveCount(4))
    expect(rangeMap5[0]) == 4...17
    expect(rangeMap5[1]) == 29...47
    expect(rangeMap5[2]) == 49...53
    expect(rangeMap5[3]) == 64...77

    // LL-3
    var rangeMap6 = CountableRangeMapBehaviorTests.rangeMap
    rangeMap6.insert(31...59)
    expect(rangeMap6).to(haveCount(3))
    expect(rangeMap6[0]) == 4...17
    expect(rangeMap6[1]) == 29...59
    expect(rangeMap6[2]) == 64...77

    // UL-1
    var rangeMap7 = CountableRangeMapBehaviorTests.rangeMap
    rangeMap7.insert(47...48)
    expect(rangeMap7).to(haveCount(4))
    expect(rangeMap7[0]) == 4...17
    expect(rangeMap7[1]) == 29...33
    expect(rangeMap7[2]) == 37...53
    expect(rangeMap7[3]) == 64...77

    // UL-2
    var rangeMap8 = CountableRangeMapBehaviorTests.rangeMap
    rangeMap8.insert(25...35)
    expect(rangeMap8).to(haveCount(5))
    expect(rangeMap8[0]) == 4...17
    expect(rangeMap8[1]) == 25...35
    expect(rangeMap8[2]) == 37...46
    expect(rangeMap8[3]) == 49...53
    expect(rangeMap8[4]) == 64...77

    // UL-3
    var rangeMap9 = CountableRangeMapBehaviorTests.rangeMap
    rangeMap9.insert(19...47)
    expect(rangeMap9).to(haveCount(4))
    expect(rangeMap9[0]) == 4...17
    expect(rangeMap9[1]) == 19...47
    expect(rangeMap9[2]) == 49...53
    expect(rangeMap9[3]) == 64...77

    // UU-1
    var rangeMap10 = CountableRangeMapBehaviorTests.rangeMap
    rangeMap10.insert(34...40)
    expect(rangeMap10).to(haveCount(4))
    expect(rangeMap10[0]) == 4...17
    expect(rangeMap10[1]) == 29...46
    expect(rangeMap10[2]) == 49...53
    expect(rangeMap10[3]) == 64...77

    // UU-2
    var rangeMap11 = CountableRangeMapBehaviorTests.rangeMap
    rangeMap11.insert(28...41)
    expect(rangeMap11).to(haveCount(4))
    expect(rangeMap11[0]) == 4...17
    expect(rangeMap11[1]) == 28...46
    expect(rangeMap11[2]) == 49...53
    expect(rangeMap11[3]) == 64...77

    // UU-3
    var rangeMap12 = CountableRangeMapBehaviorTests.rangeMap
    rangeMap12.insert(25...51)
    expect(rangeMap12).to(haveCount(3))
    expect(rangeMap12[0]) == 4...17
    expect(rangeMap12[1]) == 25...53
    expect(rangeMap12[2]) == 64...77

    // Insetions with inner lower and exact upper

    // LU-1
    var rangeMap13 = CountableRangeMapBehaviorTests.rangeMap
    rangeMap13.insert(40...46)
    expect(rangeMap13).to(haveCount(5))
    expect(rangeMap13[0]) == 4...17
    expect(rangeMap13[1]) == 29...33
    expect(rangeMap13[2]) == 37...46
    expect(rangeMap13[3]) == 49...53
    expect(rangeMap13[4]) == 64...77

    // LU-2
    var rangeMap14 = CountableRangeMapBehaviorTests.rangeMap
    rangeMap14.insert(30...46)
    expect(rangeMap14).to(haveCount(4))
    expect(rangeMap14[0]) == 4...17
    expect(rangeMap14[1]) == 29...46
    expect(rangeMap14[2]) == 49...53
    expect(rangeMap14[3]) == 64...77

    // LU-3
    var rangeMap15 = CountableRangeMapBehaviorTests.rangeMap
    rangeMap15.insert(31...53)
    expect(rangeMap15).to(haveCount(3))
    expect(rangeMap15[0]) == 4...17
    expect(rangeMap15[1]) == 29...53
    expect(rangeMap15[2]) == 64...77

    // LL-1
    var rangeMap16 = CountableRangeMapBehaviorTests.rangeMap
    rangeMap16.insert(32...37)
    expect(rangeMap16).to(haveCount(4))
    expect(rangeMap16[0]) == 4...17
    expect(rangeMap16[1]) == 29...46
    expect(rangeMap16[2]) == 49...53
    expect(rangeMap16[3]) == 64...77

    // LL-2
    var rangeMap17 = CountableRangeMapBehaviorTests.rangeMap
    rangeMap17.insert(30...49)
    expect(rangeMap17).to(haveCount(3))
    expect(rangeMap17[0]) == 4...17
    expect(rangeMap17[1]) == 29...53
    expect(rangeMap17[2]) == 64...77

    // LL-3
    var rangeMap18 = CountableRangeMapBehaviorTests.rangeMap
    rangeMap18.insert(31...64)
    expect(rangeMap18).to(haveCount(2))
    expect(rangeMap18[0]) == 4...17
    expect(rangeMap18[1]) == 29...77

    // UL-1
    var rangeMap19 = CountableRangeMapBehaviorTests.rangeMap
    rangeMap19.insert(47...49)
    expect(rangeMap19).to(haveCount(4))
    expect(rangeMap19[0]) == 4...17
    expect(rangeMap19[1]) == 29...33
    expect(rangeMap19[2]) == 37...53
    expect(rangeMap19[3]) == 64...77

    // UL-2
    var rangeMap20 = CountableRangeMapBehaviorTests.rangeMap
    rangeMap20.insert(25...37)
    expect(rangeMap20).to(haveCount(4))
    expect(rangeMap20[0]) == 4...17
    expect(rangeMap20[1]) == 25...46
    expect(rangeMap20[2]) == 49...53
    expect(rangeMap20[3]) == 64...77

    // UL-3
    var rangeMap21 = CountableRangeMapBehaviorTests.rangeMap
    rangeMap21.insert(19...49)
    expect(rangeMap21).to(haveCount(3))
    expect(rangeMap21[0]) == 4...17
    expect(rangeMap21[1]) == 19...53
    expect(rangeMap21[2]) == 64...77

    // UU-1
    var rangeMap22 = CountableRangeMapBehaviorTests.rangeMap
    rangeMap22.insert(34...46)
    expect(rangeMap22).to(haveCount(4))
    expect(rangeMap22[0]) == 4...17
    expect(rangeMap22[1]) == 29...46
    expect(rangeMap22[2]) == 49...53
    expect(rangeMap22[3]) == 64...77

    // UU-2
    var rangeMap23 = CountableRangeMapBehaviorTests.rangeMap
    rangeMap23.insert(28...46)
    expect(rangeMap23).to(haveCount(4))
    expect(rangeMap23[0]) == 4...17
    expect(rangeMap23[1]) == 28...46
    expect(rangeMap23[2]) == 49...53
    expect(rangeMap23[3]) == 64...77

    // UU-3
    var rangeMap24 = CountableRangeMapBehaviorTests.rangeMap
    rangeMap24.insert(25...53)
    expect(rangeMap24).to(haveCount(3))
    expect(rangeMap24[0]) == 4...17
    expect(rangeMap24[1]) == 25...53
    expect(rangeMap24[2]) == 64...77

    // Insertions with exact lower and inner upper

    // LU-1
    var rangeMap25 = CountableRangeMapBehaviorTests.rangeMap
    rangeMap25.insert(37...43)
    expect(rangeMap25).to(haveCount(5))
    expect(rangeMap25[0]) == 4...17
    expect(rangeMap25[1]) == 29...33
    expect(rangeMap25[2]) == 37...46
    expect(rangeMap25[3]) == 49...53
    expect(rangeMap25[4]) == 64...77

    // LU-2
    var rangeMap26 = CountableRangeMapBehaviorTests.rangeMap
    rangeMap26.insert(29...40)
    expect(rangeMap26).to(haveCount(4))
    expect(rangeMap26[0]) == 4...17
    expect(rangeMap26[1]) == 29...46
    expect(rangeMap26[2]) == 49...53
    expect(rangeMap26[3]) == 64...77

    // LU-3
    var rangeMap27 = CountableRangeMapBehaviorTests.rangeMap
    rangeMap27.insert(29...51)
    expect(rangeMap27).to(haveCount(3))
    expect(rangeMap27[0]) == 4...17
    expect(rangeMap27[1]) == 29...53
    expect(rangeMap27[2]) == 64...77

    // LL-1
    var rangeMap28 = CountableRangeMapBehaviorTests.rangeMap
    rangeMap28.insert(29...34)
    expect(rangeMap28).to(haveCount(5))
    expect(rangeMap28[0]) == 4...17
    expect(rangeMap28[1]) == 29...34
    expect(rangeMap28[2]) == 37...46
    expect(rangeMap28[3]) == 49...53
    expect(rangeMap28[4]) == 64...77

    // LL-2
    var rangeMap29 = CountableRangeMapBehaviorTests.rangeMap
    rangeMap29.insert(29...47)
    expect(rangeMap29).to(haveCount(4))
    expect(rangeMap29[0]) == 4...17
    expect(rangeMap29[1]) == 29...47
    expect(rangeMap29[2]) == 49...53
    expect(rangeMap29[3]) == 64...77

    // LL-3
    var rangeMap30 = CountableRangeMapBehaviorTests.rangeMap
    rangeMap30.insert(29...59)
    expect(rangeMap30).to(haveCount(3))
    expect(rangeMap30[0]) == 4...17
    expect(rangeMap30[1]) == 29...59
    expect(rangeMap30[2]) == 64...77

    // UL-1
    var rangeMap31 = CountableRangeMapBehaviorTests.rangeMap
    rangeMap31.insert(46...48)
    expect(rangeMap31).to(haveCount(4))
    expect(rangeMap31[0]) == 4...17
    expect(rangeMap31[1]) == 29...33
    expect(rangeMap31[2]) == 37...53
    expect(rangeMap31[3]) == 64...77

    // UL-2
    var rangeMap32 = CountableRangeMapBehaviorTests.rangeMap
    rangeMap32.insert(17...35)
    expect(rangeMap32).to(haveCount(4))
    expect(rangeMap32[0]) == 4...35
    expect(rangeMap32[1]) == 37...46
    expect(rangeMap32[2]) == 49...53
    expect(rangeMap32[3]) == 64...77

    // UL-3
    var rangeMap33 = CountableRangeMapBehaviorTests.rangeMap
    rangeMap33.insert(17...47)
    expect(rangeMap33).to(haveCount(3))
    expect(rangeMap33[0]) == 4...47
    expect(rangeMap33[1]) == 49...53
    expect(rangeMap33[2]) == 64...77

    // UU-1
    var rangeMap34 = CountableRangeMapBehaviorTests.rangeMap
    rangeMap34.insert(33...40)
    expect(rangeMap34).to(haveCount(4))
    expect(rangeMap34[0]) == 4...17
    expect(rangeMap34[1]) == 29...46
    expect(rangeMap34[2]) == 49...53
    expect(rangeMap34[3]) == 64...77

    // UU-2
    var rangeMap35 = CountableRangeMapBehaviorTests.rangeMap
    rangeMap35.insert(17...41)
    expect(rangeMap35).to(haveCount(3))
    expect(rangeMap35[0]) == 4...46
    expect(rangeMap35[1]) == 49...53
    expect(rangeMap35[2]) == 64...77

    // UU-3
    var rangeMap36 = CountableRangeMapBehaviorTests.rangeMap
    rangeMap36.insert(17...51)
    expect(rangeMap36).to(haveCount(2))
    expect(rangeMap36[0]) == 4...53
    expect(rangeMap36[1]) == 64...77

    var rangeMap37 = CountableRangeMapBehaviorTests.rangeMap
    rangeMap37.insert(1..<1)
    expect(rangeMap37 == CountableRangeMapBehaviorTests.rangeMap) == true
    rangeMap37.insert(1..<1)
    expect(rangeMap37 == CountableRangeMapBehaviorTests.rangeMap) == true
  }

  func testRangeInsertionsEmpty() {
    var rangeMap = CountableRangeMap<Int>()

    rangeMap.insert(26...28)
    expect(rangeMap).to(haveCount(1))
    expect(rangeMap[0]) == 26...28

    rangeMap.insert(41...43)
    expect(rangeMap).to(haveCount(2))
    expect(rangeMap[0]) == 26...28
    expect(rangeMap[1]) == 41...43

    rangeMap.insert(96...98)
    expect(rangeMap).to(haveCount(3))
    expect(rangeMap[0]) == 26...28
    expect(rangeMap[1]) == 41...43
    expect(rangeMap[2]) == 96...98

    rangeMap.insert(Range(66...68))
    expect(rangeMap).to(haveCount(4))
    expect(rangeMap[0]) == 26...28
    expect(rangeMap[1]) == 41...43
    expect(rangeMap[2]) == 66...68
    expect(rangeMap[3]) == 96...98

    rangeMap.insert(54...56)
    expect(rangeMap).to(haveCount(5))
    expect(rangeMap[0]) == 26...28
    expect(rangeMap[1]) == 41...43
    expect(rangeMap[2]) == 54...56
    expect(rangeMap[3]) == 66...68
    expect(rangeMap[4]) == 96...98

    rangeMap.insert(22...24)
    expect(rangeMap).to(haveCount(6))
    expect(rangeMap[0]) == 22...24
    expect(rangeMap[1]) == 26...28
    expect(rangeMap[2]) == 41...43
    expect(rangeMap[3]) == 54...56
    expect(rangeMap[4]) == 66...68
    expect(rangeMap[5]) == 96...98

    rangeMap.insert(1...3)
    expect(rangeMap).to(haveCount(7))
    expect(rangeMap[0]) == 1...3
    expect(rangeMap[1]) == 22...24
    expect(rangeMap[2]) == 26...28
    expect(rangeMap[3]) == 41...43
    expect(rangeMap[4]) == 54...56
    expect(rangeMap[5]) == 66...68
    expect(rangeMap[6]) == 96...98

    rangeMap.insert(47...49)
    expect(rangeMap).to(haveCount(8))
    expect(rangeMap[0]) == 1...3
    expect(rangeMap[1]) == 22...24
    expect(rangeMap[2]) == 26...28
    expect(rangeMap[3]) == 41...43
    expect(rangeMap[4]) == 47...49
    expect(rangeMap[5]) == 54...56
    expect(rangeMap[6]) == 66...68
    expect(rangeMap[7]) == 96...98

    rangeMap.insert(13...15)
    expect(rangeMap).to(haveCount(9))
    expect(rangeMap[0]) == 1...3
    expect(rangeMap[1]) == 13...15
    expect(rangeMap[2]) == 22...24
    expect(rangeMap[3]) == 26...28
    expect(rangeMap[4]) == 41...43
    expect(rangeMap[5]) == 47...49
    expect(rangeMap[6]) == 54...56
    expect(rangeMap[7]) == 66...68
    expect(rangeMap[8]) == 96...98

    rangeMap.insert(82...84)
    expect(rangeMap).to(haveCount(10))
    expect(rangeMap[0]) == 1...3
    expect(rangeMap[1]) == 13...15
    expect(rangeMap[2]) == 22...24
    expect(rangeMap[3]) == 26...28
    expect(rangeMap[4]) == 41...43
    expect(rangeMap[5]) == 47...49
    expect(rangeMap[6]) == 54...56
    expect(rangeMap[7]) == 66...68
    expect(rangeMap[8]) == 82...84
    expect(rangeMap[9]) == 96...98

    rangeMap.insert(93...95)
    expect(rangeMap).to(haveCount(10))
    expect(rangeMap[0]) == 1...3
    expect(rangeMap[1]) == 13...15
    expect(rangeMap[2]) == 22...24
    expect(rangeMap[3]) == 26...28
    expect(rangeMap[4]) == 41...43
    expect(rangeMap[5]) == 47...49
    expect(rangeMap[6]) == 54...56
    expect(rangeMap[7]) == 66...68
    expect(rangeMap[8]) == 82...84
    expect(rangeMap[9]) == 93...98

    rangeMap.insert(5...7)
    expect(rangeMap).to(haveCount(11))
    expect(rangeMap[0]) == 1...3
    expect(rangeMap[1]) == 5...7
    expect(rangeMap[2]) == 13...15
    expect(rangeMap[3]) == 22...24
    expect(rangeMap[4]) == 26...28
    expect(rangeMap[5]) == 41...43
    expect(rangeMap[6]) == 47...49
    expect(rangeMap[7]) == 54...56
    expect(rangeMap[8]) == 66...68
    expect(rangeMap[9]) == 82...84
    expect(rangeMap[10]) == 93...98

    rangeMap.insert(90...92)
    expect(rangeMap).to(haveCount(11))
    expect(rangeMap[0]) == 1...3
    expect(rangeMap[1]) == 5...7
    expect(rangeMap[2]) == 13...15
    expect(rangeMap[3]) == 22...24
    expect(rangeMap[4]) == 26...28
    expect(rangeMap[5]) == 41...43
    expect(rangeMap[6]) == 47...49
    expect(rangeMap[7]) == 54...56
    expect(rangeMap[8]) == 66...68
    expect(rangeMap[9]) == 82...84
    expect(rangeMap[10]) == 90...98

    rangeMap.insert(59...61)
    expect(rangeMap).to(haveCount(12))
    expect(rangeMap[0]) == 1...3
    expect(rangeMap[1]) == 5...7
    expect(rangeMap[2]) == 13...15
    expect(rangeMap[3]) == 22...24
    expect(rangeMap[4]) == 26...28
    expect(rangeMap[5]) == 41...43
    expect(rangeMap[6]) == 47...49
    expect(rangeMap[7]) == 54...56
    expect(rangeMap[8]) == 59...61
    expect(rangeMap[9]) == 66...68
    expect(rangeMap[10]) == 82...84
    expect(rangeMap[11]) == 90...98

    rangeMap.insert(64...66)
    expect(rangeMap).to(haveCount(12))
    expect(rangeMap[0]) == 1...3
    expect(rangeMap[1]) == 5...7
    expect(rangeMap[2]) == 13...15
    expect(rangeMap[3]) == 22...24
    expect(rangeMap[4]) == 26...28
    expect(rangeMap[5]) == 41...43
    expect(rangeMap[6]) == 47...49
    expect(rangeMap[7]) == 54...56
    expect(rangeMap[8]) == 59...61
    expect(rangeMap[9]) == 64...68
    expect(rangeMap[10]) == 82...84
    expect(rangeMap[11]) == 90...98

    rangeMap.insert(2...4)
    expect(rangeMap).to(haveCount(11))
    expect(rangeMap[0]) == 1...7
    expect(rangeMap[1]) == 13...15
    expect(rangeMap[2]) == 22...24
    expect(rangeMap[3]) == 26...28
    expect(rangeMap[4]) == 41...43
    expect(rangeMap[5]) == 47...49
    expect(rangeMap[6]) == 54...56
    expect(rangeMap[7]) == 59...61
    expect(rangeMap[8]) == 64...68
    expect(rangeMap[9]) == 82...84
    expect(rangeMap[10]) == 90...98

    rangeMap.insert(68...70)
    expect(rangeMap).to(haveCount(11))
    expect(rangeMap[0]) == 1...7
    expect(rangeMap[1]) == 13...15
    expect(rangeMap[2]) == 22...24
    expect(rangeMap[3]) == 26...28
    expect(rangeMap[4]) == 41...43
    expect(rangeMap[5]) == 47...49
    expect(rangeMap[6]) == 54...56
    expect(rangeMap[7]) == 59...61
    expect(rangeMap[8]) == 64...70
    expect(rangeMap[9]) == 82...84
    expect(rangeMap[10]) == 90...98

    rangeMap.insert(62...64)
    expect(rangeMap).to(haveCount(10))
    expect(rangeMap[0]) == 1...7
    expect(rangeMap[1]) == 13...15
    expect(rangeMap[2]) == 22...24
    expect(rangeMap[3]) == 26...28
    expect(rangeMap[4]) == 41...43
    expect(rangeMap[5]) == 47...49
    expect(rangeMap[6]) == 54...56
    expect(rangeMap[7]) == 59...70
    expect(rangeMap[8]) == 82...84
    expect(rangeMap[9]) == 90...98

    rangeMap.insert(44...46)
    expect(rangeMap).to(haveCount(9))
    expect(rangeMap[0]) == 1...7
    expect(rangeMap[1]) == 13...15
    expect(rangeMap[2]) == 22...24
    expect(rangeMap[3]) == 26...28
    expect(rangeMap[4]) == 41...49
    expect(rangeMap[5]) == 54...56
    expect(rangeMap[6]) == 59...70
    expect(rangeMap[7]) == 82...84
    expect(rangeMap[8]) == 90...98

    rangeMap.insert(75...77)
    expect(rangeMap).to(haveCount(10))
    expect(rangeMap[0]) == 1...7
    expect(rangeMap[1]) == 13...15
    expect(rangeMap[2]) == 22...24
    expect(rangeMap[3]) == 26...28
    expect(rangeMap[4]) == 41...49
    expect(rangeMap[5]) == 54...56
    expect(rangeMap[6]) == 59...70
    expect(rangeMap[7]) == 75...77
    expect(rangeMap[8]) == 82...84
    expect(rangeMap[9]) == 90...98

    rangeMap.insert(40...42)
    expect(rangeMap).to(haveCount(10))
    expect(rangeMap[0]) == 1...7
    expect(rangeMap[1]) == 13...15
    expect(rangeMap[2]) == 22...24
    expect(rangeMap[3]) == 26...28
    expect(rangeMap[4]) == 40...49
    expect(rangeMap[5]) == 54...56
    expect(rangeMap[6]) == 59...70
    expect(rangeMap[7]) == 75...77
    expect(rangeMap[8]) == 82...84
    expect(rangeMap[9]) == 90...98

    rangeMap.insert(56...58)
    expect(rangeMap).to(haveCount(9))
    expect(rangeMap[0]) == 1...7
    expect(rangeMap[1]) == 13...15
    expect(rangeMap[2]) == 22...24
    expect(rangeMap[3]) == 26...28
    expect(rangeMap[4]) == 40...49
    expect(rangeMap[5]) == 54...70
    expect(rangeMap[6]) == 75...77
    expect(rangeMap[7]) == 82...84
    expect(rangeMap[8]) == 90...98

    rangeMap.insert(49...51)
    expect(rangeMap).to(haveCount(9))
    expect(rangeMap[0]) == 1...7
    expect(rangeMap[1]) == 13...15
    expect(rangeMap[2]) == 22...24
    expect(rangeMap[3]) == 26...28
    expect(rangeMap[4]) == 40...51
    expect(rangeMap[5]) == 54...70
    expect(rangeMap[6]) == 75...77
    expect(rangeMap[7]) == 82...84
    expect(rangeMap[8]) == 90...98

    rangeMap.insert(77...79)
    expect(rangeMap).to(haveCount(9))
    expect(rangeMap[0]) == 1...7
    expect(rangeMap[1]) == 13...15
    expect(rangeMap[2]) == 22...24
    expect(rangeMap[3]) == 26...28
    expect(rangeMap[4]) == 40...51
    expect(rangeMap[5]) == 54...70
    expect(rangeMap[6]) == 75...79
    expect(rangeMap[7]) == 82...84
    expect(rangeMap[8]) == 90...98

    rangeMap.insert(43...45)
    expect(rangeMap).to(haveCount(9))
    expect(rangeMap[0]) == 1...7
    expect(rangeMap[1]) == 13...15
    expect(rangeMap[2]) == 22...24
    expect(rangeMap[3]) == 26...28
    expect(rangeMap[4]) == 40...51
    expect(rangeMap[5]) == 54...70
    expect(rangeMap[6]) == 75...79
    expect(rangeMap[7]) == 82...84
    expect(rangeMap[8]) == 90...98

    rangeMap.insert(53...55)
    expect(rangeMap).to(haveCount(9))
    expect(rangeMap[0]) == 1...7
    expect(rangeMap[1]) == 13...15
    expect(rangeMap[2]) == 22...24
    expect(rangeMap[3]) == 26...28
    expect(rangeMap[4]) == 40...51
    expect(rangeMap[5]) == 53...70
    expect(rangeMap[6]) == 75...79
    expect(rangeMap[7]) == 82...84
    expect(rangeMap[8]) == 90...98

    rangeMap.insert(69...71)
    expect(rangeMap).to(haveCount(9))
    expect(rangeMap[0]) == 1...7
    expect(rangeMap[1]) == 13...15
    expect(rangeMap[2]) == 22...24
    expect(rangeMap[3]) == 26...28
    expect(rangeMap[4]) == 40...51
    expect(rangeMap[5]) == 53...71
    expect(rangeMap[6]) == 75...79
    expect(rangeMap[7]) == 82...84
    expect(rangeMap[8]) == 90...98

    rangeMap.insert(65...67)
    expect(rangeMap).to(haveCount(9))
    expect(rangeMap[0]) == 1...7
    expect(rangeMap[1]) == 13...15
    expect(rangeMap[2]) == 22...24
    expect(rangeMap[3]) == 26...28
    expect(rangeMap[4]) == 40...51
    expect(rangeMap[5]) == 53...71
    expect(rangeMap[6]) == 75...79
    expect(rangeMap[7]) == 82...84
    expect(rangeMap[8]) == 90...98

    rangeMap.insert(89...91)
    expect(rangeMap).to(haveCount(9))
    expect(rangeMap[0]) == 1...7
    expect(rangeMap[1]) == 13...15
    expect(rangeMap[2]) == 22...24
    expect(rangeMap[3]) == 26...28
    expect(rangeMap[4]) == 40...51
    expect(rangeMap[5]) == 53...71
    expect(rangeMap[6]) == 75...79
    expect(rangeMap[7]) == 82...84
    expect(rangeMap[8]) == 89...98

    rangeMap.insert(45...47)
    expect(rangeMap).to(haveCount(9))
    expect(rangeMap[0]) == 1...7
    expect(rangeMap[1]) == 13...15
    expect(rangeMap[2]) == 22...24
    expect(rangeMap[3]) == 26...28
    expect(rangeMap[4]) == 40...51
    expect(rangeMap[5]) == 53...71
    expect(rangeMap[6]) == 75...79
    expect(rangeMap[7]) == 82...84
    expect(rangeMap[8]) == 89...98

    rangeMap.insert(60...62)
    expect(rangeMap).to(haveCount(9))
    expect(rangeMap[0]) == 1...7
    expect(rangeMap[1]) == 13...15
    expect(rangeMap[2]) == 22...24
    expect(rangeMap[3]) == 26...28
    expect(rangeMap[4]) == 40...51
    expect(rangeMap[5]) == 53...71
    expect(rangeMap[6]) == 75...79
    expect(rangeMap[7]) == 82...84
    expect(rangeMap[8]) == 89...98

    rangeMap.insert(38...40)
    expect(rangeMap).to(haveCount(9))
    expect(rangeMap[0]) == 1...7
    expect(rangeMap[1]) == 13...15
    expect(rangeMap[2]) == 22...24
    expect(rangeMap[3]) == 26...28
    expect(rangeMap[4]) == 38...51
    expect(rangeMap[5]) == 53...71
    expect(rangeMap[6]) == 75...79
    expect(rangeMap[7]) == 82...84
    expect(rangeMap[8]) == 89...98

    rangeMap.insert(84...86)
    expect(rangeMap).to(haveCount(9))
    expect(rangeMap[0]) == 1...7
    expect(rangeMap[1]) == 13...15
    expect(rangeMap[2]) == 22...24
    expect(rangeMap[3]) == 26...28
    expect(rangeMap[4]) == 38...51
    expect(rangeMap[5]) == 53...71
    expect(rangeMap[6]) == 75...79
    expect(rangeMap[7]) == 82...86
    expect(rangeMap[8]) == 89...98

    rangeMap.insert(73...75)
    expect(rangeMap).to(haveCount(9))
    expect(rangeMap[0]) == 1...7
    expect(rangeMap[1]) == 13...15
    expect(rangeMap[2]) == 22...24
    expect(rangeMap[3]) == 26...28
    expect(rangeMap[4]) == 38...51
    expect(rangeMap[5]) == 53...71
    expect(rangeMap[6]) == 73...79
    expect(rangeMap[7]) == 82...86
    expect(rangeMap[8]) == 89...98

    rangeMap.insert(40...42)
    expect(rangeMap).to(haveCount(9))
    expect(rangeMap[0]) == 1...7
    expect(rangeMap[1]) == 13...15
    expect(rangeMap[2]) == 22...24
    expect(rangeMap[3]) == 26...28
    expect(rangeMap[4]) == 38...51
    expect(rangeMap[5]) == 53...71
    expect(rangeMap[6]) == 73...79
    expect(rangeMap[7]) == 82...86
    expect(rangeMap[8]) == 89...98

    rangeMap.insert(14...16)
    expect(rangeMap).to(haveCount(9))
    expect(rangeMap[0]) == 1...7
    expect(rangeMap[1]) == 13...16
    expect(rangeMap[2]) == 22...24
    expect(rangeMap[3]) == 26...28
    expect(rangeMap[4]) == 38...51
    expect(rangeMap[5]) == 53...71
    expect(rangeMap[6]) == 73...79
    expect(rangeMap[7]) == 82...86
    expect(rangeMap[8]) == 89...98

    rangeMap.insert(76...78)
    expect(rangeMap).to(haveCount(9))
    expect(rangeMap[0]) == 1...7
    expect(rangeMap[1]) == 13...16
    expect(rangeMap[2]) == 22...24
    expect(rangeMap[3]) == 26...28
    expect(rangeMap[4]) == 38...51
    expect(rangeMap[5]) == 53...71
    expect(rangeMap[6]) == 73...79
    expect(rangeMap[7]) == 82...86
    expect(rangeMap[8]) == 89...98

    rangeMap.insert(18...20)
    expect(rangeMap).to(haveCount(10))
    expect(rangeMap[0]) == 1...7
    expect(rangeMap[1]) == 13...16
    expect(rangeMap[2]) == 18...20
    expect(rangeMap[3]) == 22...24
    expect(rangeMap[4]) == 26...28
    expect(rangeMap[5]) == 38...51
    expect(rangeMap[6]) == 53...71
    expect(rangeMap[7]) == 73...79
    expect(rangeMap[8]) == 82...86
    expect(rangeMap[9]) == 89...98

    rangeMap.insert(23...25)
    expect(rangeMap).to(haveCount(9))
    expect(rangeMap[0]) == 1...7
    expect(rangeMap[1]) == 13...16
    expect(rangeMap[2]) == 18...20
    expect(rangeMap[3]) == 22...28
    expect(rangeMap[4]) == 38...51
    expect(rangeMap[5]) == 53...71
    expect(rangeMap[6]) == 73...79
    expect(rangeMap[7]) == 82...86
    expect(rangeMap[8]) == 89...98

    rangeMap.insert(10...12)
    expect(rangeMap).to(haveCount(9))
    expect(rangeMap[0]) == 1...7
    expect(rangeMap[1]) == 10...16
    expect(rangeMap[2]) == 18...20
    expect(rangeMap[3]) == 22...28
    expect(rangeMap[4]) == 38...51
    expect(rangeMap[5]) == 53...71
    expect(rangeMap[6]) == 73...79
    expect(rangeMap[7]) == 82...86
    expect(rangeMap[8]) == 89...98

    let ranges = CountableRangeMapBehaviorTests.ranges
    rangeMap = CountableRangeMap<Int>()
    rangeMap.insert(contentsOf: ranges)
    expect(rangeMap).to(haveCount(5))
    expect(rangeMap[0]) == 4...17
    expect(rangeMap[1]) == 29...33
    expect(rangeMap[2]) == 37...46
    expect(rangeMap[3]) == 49...53
    expect(rangeMap[4]) == 64...77
  }

  func testSingleValueInsertions() {
    let integers = CountableRangeMapBehaviorTests.integers

    var rangeMap1 = CountableRangeMapBehaviorTests.rangeMap
    rangeMap1.insert(integers[0])
    expect(rangeMap1).to(haveCount(5))
    expect(rangeMap1[0]) == 4...17
    expect(rangeMap1[1]) == 29...33
    expect(rangeMap1[2]) == 37...46
    expect(rangeMap1[3]) == 49...53
    expect(rangeMap1[4]) == 64...77

    var rangeMap2 = CountableRangeMapBehaviorTests.rangeMap
    rangeMap2.insert(integers[1])
    expect(rangeMap2).to(haveCount(6))
    expect(rangeMap2[0]) == 4...17
    expect(rangeMap2[1]) == 22...22
    expect(rangeMap2[2]) == 29...33
    expect(rangeMap2[3]) == 37...46
    expect(rangeMap2[4]) == 49...53
    expect(rangeMap2[5]) == 64...77

    var rangeMap3 = CountableRangeMapBehaviorTests.rangeMap
    rangeMap3.insert(integers[2])
    expect(rangeMap3).to(haveCount(6))
    expect(rangeMap3[0]) == 2...2
    expect(rangeMap3[1]) == 4...17
    expect(rangeMap3[2]) == 29...33
    expect(rangeMap3[3]) == 37...46
    expect(rangeMap3[4]) == 49...53
    expect(rangeMap3[5]) == 64...77

    var rangeMap4 = CountableRangeMapBehaviorTests.rangeMap
    rangeMap4.insert(integers[3])
    expect(rangeMap4).to(haveCount(5))
    expect(rangeMap4[0]) == 4...17
    expect(rangeMap4[1]) == 29...33
    expect(rangeMap4[2]) == 37...46
    expect(rangeMap4[3]) == 49...53
    expect(rangeMap4[4]) == 64...77

    var rangeMap5 = CountableRangeMapBehaviorTests.rangeMap
    rangeMap5.insert(integers[4])
    expect(rangeMap5).to(haveCount(6))
    expect(rangeMap5[0]) == 4...17
    expect(rangeMap5[1]) == 29...33
    expect(rangeMap5[2]) == 37...46
    expect(rangeMap5[3]) == 49...53
    expect(rangeMap5[4]) == 64...77
    expect(rangeMap5[5]) == 88...88

    var rangeMap6 = CountableRangeMapBehaviorTests.rangeMap
    rangeMap6.insert(integers[5])
    expect(rangeMap6).to(haveCount(5))
    expect(rangeMap6[0]) == 4...17
    expect(rangeMap6[1]) == 29...33
    expect(rangeMap6[2]) == 37...46
    expect(rangeMap6[3]) == 49...53
    expect(rangeMap6[4]) == 64...77

    var rangeMap7 = CountableRangeMapBehaviorTests.rangeMap
    rangeMap7.insert(integers[6])
    expect(rangeMap7).to(haveCount(5))
    expect(rangeMap7[0]) == 4...17
    expect(rangeMap7[1]) == 29...33
    expect(rangeMap7[2]) == 37...46
    expect(rangeMap7[3]) == 49...53
    expect(rangeMap7[4]) == 64...77

    var rangeMap8 = CountableRangeMapBehaviorTests.rangeMap
    rangeMap8.insert(integers[7])
    expect(rangeMap8).to(haveCount(5))
    expect(rangeMap8[0]) == 4...17
    expect(rangeMap8[1]) == 29...33
    expect(rangeMap8[2]) == 37...46
    expect(rangeMap8[3]) == 49...53
    expect(rangeMap8[4]) == 64...77

    var rangeMap9 = CountableRangeMapBehaviorTests.rangeMap
    rangeMap9.insert(integers)
    expect(rangeMap9).to(haveCount(8))
    expect(rangeMap9[0]) == 2...2
    expect(rangeMap9[1]) == 4...17
    expect(rangeMap9[2]) == 22...22
    expect(rangeMap9[3]) == 29...33
    expect(rangeMap9[4]) == 37...46
    expect(rangeMap9[5]) == 49...53
    expect(rangeMap9[6]) == 64...77
    expect(rangeMap9[7]) == 88...88
  }

  func testSingleValueCoalescing() {
    var rangeMap = CountableRangeMap<Int>()
    rangeMap.insert(17)
    expect(rangeMap).to(haveCount(1))
    expect(rangeMap[0]) == 17...17

    rangeMap.insert(21)
    expect(rangeMap).to(haveCount(2))
    expect(rangeMap[0]) == 17...17
    expect(rangeMap[1]) == 21...21

    rangeMap.insert(4)
    expect(rangeMap).to(haveCount(3))
    expect(rangeMap[0]) == 4...4
    expect(rangeMap[1]) == 17...17
    expect(rangeMap[2]) == 21...21

    rangeMap.insert(39)
    expect(rangeMap).to(haveCount(4))
    expect(rangeMap[0]) == 4...4
    expect(rangeMap[1]) == 17...17
    expect(rangeMap[2]) == 21...21
    expect(rangeMap[3]) == 39...39

    rangeMap.insert(19)
    expect(rangeMap).to(haveCount(5))
    expect(rangeMap[0]) == 4...4
    expect(rangeMap[1]) == 17...17
    expect(rangeMap[2]) == 19...19
    expect(rangeMap[3]) == 21...21
    expect(rangeMap[4]) == 39...39

    rangeMap.insert(21)
    expect(rangeMap).to(haveCount(5))
    expect(rangeMap[0]) == 4...4
    expect(rangeMap[1]) == 17...17
    expect(rangeMap[2]) == 19...19
    expect(rangeMap[3]) == 21...21
    expect(rangeMap[4]) == 39...39

    rangeMap.insert(2)
    expect(rangeMap).to(haveCount(6))
    expect(rangeMap[0]) == 2...2
    expect(rangeMap[1]) == 4...4
    expect(rangeMap[2]) == 17...17
    expect(rangeMap[3]) == 19...19
    expect(rangeMap[4]) == 21...21
    expect(rangeMap[5]) == 39...39

    rangeMap.insert(37)
    expect(rangeMap).to(haveCount(7))
    expect(rangeMap[0]) == 2...2
    expect(rangeMap[1]) == 4...4
    expect(rangeMap[2]) == 17...17
    expect(rangeMap[3]) == 19...19
    expect(rangeMap[4]) == 21...21
    expect(rangeMap[5]) == 37...37
    expect(rangeMap[6]) == 39...39

    rangeMap.insert(24)
    expect(rangeMap).to(haveCount(8))
    expect(rangeMap[0]) == 2...2
    expect(rangeMap[1]) == 4...4
    expect(rangeMap[2]) == 17...17
    expect(rangeMap[3]) == 19...19
    expect(rangeMap[4]) == 21...21
    expect(rangeMap[5]) == 24...24
    expect(rangeMap[6]) == 37...37
    expect(rangeMap[7]) == 39...39

    rangeMap.insert(36)
    expect(rangeMap).to(haveCount(8))
    expect(rangeMap[0]) == 2...2
    expect(rangeMap[1]) == 4...4
    expect(rangeMap[2]) == 17...17
    expect(rangeMap[3]) == 19...19
    expect(rangeMap[4]) == 21...21
    expect(rangeMap[5]) == 24...24
    expect(rangeMap[6]) == 36...37
    expect(rangeMap[7]) == 39...39

    rangeMap.insert(11)
    expect(rangeMap).to(haveCount(9))
    expect(rangeMap[0]) == 2...2
    expect(rangeMap[1]) == 4...4
    expect(rangeMap[2]) == 11...11
    expect(rangeMap[3]) == 17...17
    expect(rangeMap[4]) == 19...19
    expect(rangeMap[5]) == 21...21
    expect(rangeMap[6]) == 24...24
    expect(rangeMap[7]) == 36...37
    expect(rangeMap[8]) == 39...39

    rangeMap.insert(16)
    expect(rangeMap).to(haveCount(9))
    expect(rangeMap[0]) == 2...2
    expect(rangeMap[1]) == 4...4
    expect(rangeMap[2]) == 11...11
    expect(rangeMap[3]) == 16...17
    expect(rangeMap[4]) == 19...19
    expect(rangeMap[5]) == 21...21
    expect(rangeMap[6]) == 24...24
    expect(rangeMap[7]) == 36...37
    expect(rangeMap[8]) == 39...39

    rangeMap.insert(29)
    expect(rangeMap).to(haveCount(10))
    expect(rangeMap[0]) == 2...2
    expect(rangeMap[1]) == 4...4
    expect(rangeMap[2]) == 11...11
    expect(rangeMap[3]) == 16...17
    expect(rangeMap[4]) == 19...19
    expect(rangeMap[5]) == 21...21
    expect(rangeMap[6]) == 24...24
    expect(rangeMap[7]) == 29...29
    expect(rangeMap[8]) == 36...37
    expect(rangeMap[9]) == 39...39

    rangeMap.insert(44)
    expect(rangeMap).to(haveCount(11))
    expect(rangeMap[0]) == 2...2
    expect(rangeMap[1]) == 4...4
    expect(rangeMap[2]) == 11...11
    expect(rangeMap[3]) == 16...17
    expect(rangeMap[4]) == 19...19
    expect(rangeMap[5]) == 21...21
    expect(rangeMap[6]) == 24...24
    expect(rangeMap[7]) == 29...29
    expect(rangeMap[8]) == 36...37
    expect(rangeMap[9]) == 39...39
    expect(rangeMap[10]) == 44...44

    rangeMap.insert(0)
    expect(rangeMap).to(haveCount(12))
    expect(rangeMap[0]) == 0...0
    expect(rangeMap[1]) == 2...2
    expect(rangeMap[2]) == 4...4
    expect(rangeMap[3]) == 11...11
    expect(rangeMap[4]) == 16...17
    expect(rangeMap[5]) == 19...19
    expect(rangeMap[6]) == 21...21
    expect(rangeMap[7]) == 24...24
    expect(rangeMap[8]) == 29...29
    expect(rangeMap[9]) == 36...37
    expect(rangeMap[10]) == 39...39
    expect(rangeMap[11]) == 44...44

    rangeMap.insert(21)
    expect(rangeMap).to(haveCount(12))
    expect(rangeMap[0]) == 0...0
    expect(rangeMap[1]) == 2...2
    expect(rangeMap[2]) == 4...4
    expect(rangeMap[3]) == 11...11
    expect(rangeMap[4]) == 16...17
    expect(rangeMap[5]) == 19...19
    expect(rangeMap[6]) == 21...21
    expect(rangeMap[7]) == 24...24
    expect(rangeMap[8]) == 29...29
    expect(rangeMap[9]) == 36...37
    expect(rangeMap[10]) == 39...39
    expect(rangeMap[11]) == 44...44

    rangeMap.insert(7)
    expect(rangeMap).to(haveCount(13))
    expect(rangeMap[0]) == 0...0
    expect(rangeMap[1]) == 2...2
    expect(rangeMap[2]) == 4...4
    expect(rangeMap[3]) == 7...7
    expect(rangeMap[4]) == 11...11
    expect(rangeMap[5]) == 16...17
    expect(rangeMap[6]) == 19...19
    expect(rangeMap[7]) == 21...21
    expect(rangeMap[8]) == 24...24
    expect(rangeMap[9]) == 29...29
    expect(rangeMap[10]) == 36...37
    expect(rangeMap[11]) == 39...39
    expect(rangeMap[12]) == 44...44

    rangeMap.insert(30)
    expect(rangeMap).to(haveCount(13))
    expect(rangeMap[0]) == 0...0
    expect(rangeMap[1]) == 2...2
    expect(rangeMap[2]) == 4...4
    expect(rangeMap[3]) == 7...7
    expect(rangeMap[4]) == 11...11
    expect(rangeMap[5]) == 16...17
    expect(rangeMap[6]) == 19...19
    expect(rangeMap[7]) == 21...21
    expect(rangeMap[8]) == 24...24
    expect(rangeMap[9]) == 29...30
    expect(rangeMap[10]) == 36...37
    expect(rangeMap[11]) == 39...39
    expect(rangeMap[12]) == 44...44

    rangeMap.insert(2)
    expect(rangeMap).to(haveCount(13))
    expect(rangeMap[0]) == 0...0
    expect(rangeMap[1]) == 2...2
    expect(rangeMap[2]) == 4...4
    expect(rangeMap[3]) == 7...7
    expect(rangeMap[4]) == 11...11
    expect(rangeMap[5]) == 16...17
    expect(rangeMap[6]) == 19...19
    expect(rangeMap[7]) == 21...21
    expect(rangeMap[8]) == 24...24
    expect(rangeMap[9]) == 29...30
    expect(rangeMap[10]) == 36...37
    expect(rangeMap[11]) == 39...39
    expect(rangeMap[12]) == 44...44

    rangeMap.insert(0)
    expect(rangeMap).to(haveCount(13))
    expect(rangeMap[0]) == 0...0
    expect(rangeMap[1]) == 2...2
    expect(rangeMap[2]) == 4...4
    expect(rangeMap[3]) == 7...7
    expect(rangeMap[4]) == 11...11
    expect(rangeMap[5]) == 16...17
    expect(rangeMap[6]) == 19...19
    expect(rangeMap[7]) == 21...21
    expect(rangeMap[8]) == 24...24
    expect(rangeMap[9]) == 29...30
    expect(rangeMap[10]) == 36...37
    expect(rangeMap[11]) == 39...39
    expect(rangeMap[12]) == 44...44

    rangeMap.insert(13)
    expect(rangeMap).to(haveCount(14))
    expect(rangeMap[0]) == 0...0
    expect(rangeMap[1]) == 2...2
    expect(rangeMap[2]) == 4...4
    expect(rangeMap[3]) == 7...7
    expect(rangeMap[4]) == 11...11
    expect(rangeMap[5]) == 13...13
    expect(rangeMap[6]) == 16...17
    expect(rangeMap[7]) == 19...19
    expect(rangeMap[8]) == 21...21
    expect(rangeMap[9]) == 24...24
    expect(rangeMap[10]) == 29...30
    expect(rangeMap[11]) == 36...37
    expect(rangeMap[12]) == 39...39
    expect(rangeMap[13]) == 44...44

    rangeMap.insert(43)
    expect(rangeMap).to(haveCount(14))
    expect(rangeMap[0]) == 0...0
    expect(rangeMap[1]) == 2...2
    expect(rangeMap[2]) == 4...4
    expect(rangeMap[3]) == 7...7
    expect(rangeMap[4]) == 11...11
    expect(rangeMap[5]) == 13...13
    expect(rangeMap[6]) == 16...17
    expect(rangeMap[7]) == 19...19
    expect(rangeMap[8]) == 21...21
    expect(rangeMap[9]) == 24...24
    expect(rangeMap[10]) == 29...30
    expect(rangeMap[11]) == 36...37
    expect(rangeMap[12]) == 39...39
    expect(rangeMap[13]) == 43...44

    rangeMap.insert(8)
    expect(rangeMap).to(haveCount(14))
    expect(rangeMap[0]) == 0...0
    expect(rangeMap[1]) == 2...2
    expect(rangeMap[2]) == 4...4
    expect(rangeMap[3]) == 7...8
    expect(rangeMap[4]) == 11...11
    expect(rangeMap[5]) == 13...13
    expect(rangeMap[6]) == 16...17
    expect(rangeMap[7]) == 19...19
    expect(rangeMap[8]) == 21...21
    expect(rangeMap[9]) == 24...24
    expect(rangeMap[10]) == 29...30
    expect(rangeMap[11]) == 36...37
    expect(rangeMap[12]) == 39...39
    expect(rangeMap[13]) == 43...44

    rangeMap.insert(38)
    expect(rangeMap).to(haveCount(13))
    expect(rangeMap[0]) == 0...0
    expect(rangeMap[1]) == 2...2
    expect(rangeMap[2]) == 4...4
    expect(rangeMap[3]) == 7...8
    expect(rangeMap[4]) == 11...11
    expect(rangeMap[5]) == 13...13
    expect(rangeMap[6]) == 16...17
    expect(rangeMap[7]) == 19...19
    expect(rangeMap[8]) == 21...21
    expect(rangeMap[9]) == 24...24
    expect(rangeMap[10]) == 29...30
    expect(rangeMap[11]) == 36...39
    expect(rangeMap[12]) == 43...44

    rangeMap.insert(34)
    expect(rangeMap).to(haveCount(14))
    expect(rangeMap[0]) == 0...0
    expect(rangeMap[1]) == 2...2
    expect(rangeMap[2]) == 4...4
    expect(rangeMap[3]) == 7...8
    expect(rangeMap[4]) == 11...11
    expect(rangeMap[5]) == 13...13
    expect(rangeMap[6]) == 16...17
    expect(rangeMap[7]) == 19...19
    expect(rangeMap[8]) == 21...21
    expect(rangeMap[9]) == 24...24
    expect(rangeMap[10]) == 29...30
    expect(rangeMap[11]) == 34...34
    expect(rangeMap[12]) == 36...39
    expect(rangeMap[13]) == 43...44

    rangeMap.insert(45)
    expect(rangeMap).to(haveCount(14))
    expect(rangeMap[0]) == 0...0
    expect(rangeMap[1]) == 2...2
    expect(rangeMap[2]) == 4...4
    expect(rangeMap[3]) == 7...8
    expect(rangeMap[4]) == 11...11
    expect(rangeMap[5]) == 13...13
    expect(rangeMap[6]) == 16...17
    expect(rangeMap[7]) == 19...19
    expect(rangeMap[8]) == 21...21
    expect(rangeMap[9]) == 24...24
    expect(rangeMap[10]) == 29...30
    expect(rangeMap[11]) == 34...34
    expect(rangeMap[12]) == 36...39
    expect(rangeMap[13]) == 43...45

    rangeMap.insert(24)
    expect(rangeMap).to(haveCount(14))
    expect(rangeMap[0]) == 0...0
    expect(rangeMap[1]) == 2...2
    expect(rangeMap[2]) == 4...4
    expect(rangeMap[3]) == 7...8
    expect(rangeMap[4]) == 11...11
    expect(rangeMap[5]) == 13...13
    expect(rangeMap[6]) == 16...17
    expect(rangeMap[7]) == 19...19
    expect(rangeMap[8]) == 21...21
    expect(rangeMap[9]) == 24...24
    expect(rangeMap[10]) == 29...30
    expect(rangeMap[11]) == 34...34
    expect(rangeMap[12]) == 36...39
    expect(rangeMap[13]) == 43...45

    rangeMap.insert(13)
    expect(rangeMap).to(haveCount(14))
    expect(rangeMap[0]) == 0...0
    expect(rangeMap[1]) == 2...2
    expect(rangeMap[2]) == 4...4
    expect(rangeMap[3]) == 7...8
    expect(rangeMap[4]) == 11...11
    expect(rangeMap[5]) == 13...13
    expect(rangeMap[6]) == 16...17
    expect(rangeMap[7]) == 19...19
    expect(rangeMap[8]) == 21...21
    expect(rangeMap[9]) == 24...24
    expect(rangeMap[10]) == 29...30
    expect(rangeMap[11]) == 34...34
    expect(rangeMap[12]) == 36...39
    expect(rangeMap[13]) == 43...45

    rangeMap.insert(33)
    expect(rangeMap).to(haveCount(14))
    expect(rangeMap[0]) == 0...0
    expect(rangeMap[1]) == 2...2
    expect(rangeMap[2]) == 4...4
    expect(rangeMap[3]) == 7...8
    expect(rangeMap[4]) == 11...11
    expect(rangeMap[5]) == 13...13
    expect(rangeMap[6]) == 16...17
    expect(rangeMap[7]) == 19...19
    expect(rangeMap[8]) == 21...21
    expect(rangeMap[9]) == 24...24
    expect(rangeMap[10]) == 29...30
    expect(rangeMap[11]) == 33...34
    expect(rangeMap[12]) == 36...39
    expect(rangeMap[13]) == 43...45

    rangeMap.insert(33)
    expect(rangeMap).to(haveCount(14))
    expect(rangeMap[0]) == 0...0
    expect(rangeMap[1]) == 2...2
    expect(rangeMap[2]) == 4...4
    expect(rangeMap[3]) == 7...8
    expect(rangeMap[4]) == 11...11
    expect(rangeMap[5]) == 13...13
    expect(rangeMap[6]) == 16...17
    expect(rangeMap[7]) == 19...19
    expect(rangeMap[8]) == 21...21
    expect(rangeMap[9]) == 24...24
    expect(rangeMap[10]) == 29...30
    expect(rangeMap[11]) == 33...34
    expect(rangeMap[12]) == 36...39
    expect(rangeMap[13]) == 43...45

    rangeMap.insert(29)
    expect(rangeMap).to(haveCount(14))
    expect(rangeMap[0]) == 0...0
    expect(rangeMap[1]) == 2...2
    expect(rangeMap[2]) == 4...4
    expect(rangeMap[3]) == 7...8
    expect(rangeMap[4]) == 11...11
    expect(rangeMap[5]) == 13...13
    expect(rangeMap[6]) == 16...17
    expect(rangeMap[7]) == 19...19
    expect(rangeMap[8]) == 21...21
    expect(rangeMap[9]) == 24...24
    expect(rangeMap[10]) == 29...30
    expect(rangeMap[11]) == 33...34
    expect(rangeMap[12]) == 36...39
    expect(rangeMap[13]) == 43...45

    rangeMap.insert(44)
    expect(rangeMap).to(haveCount(14))
    expect(rangeMap[0]) == 0...0
    expect(rangeMap[1]) == 2...2
    expect(rangeMap[2]) == 4...4
    expect(rangeMap[3]) == 7...8
    expect(rangeMap[4]) == 11...11
    expect(rangeMap[5]) == 13...13
    expect(rangeMap[6]) == 16...17
    expect(rangeMap[7]) == 19...19
    expect(rangeMap[8]) == 21...21
    expect(rangeMap[9]) == 24...24
    expect(rangeMap[10]) == 29...30
    expect(rangeMap[11]) == 33...34
    expect(rangeMap[12]) == 36...39
    expect(rangeMap[13]) == 43...45

    rangeMap.insert(2)
    expect(rangeMap).to(haveCount(14))
    expect(rangeMap[0]) == 0...0
    expect(rangeMap[1]) == 2...2
    expect(rangeMap[2]) == 4...4
    expect(rangeMap[3]) == 7...8
    expect(rangeMap[4]) == 11...11
    expect(rangeMap[5]) == 13...13
    expect(rangeMap[6]) == 16...17
    expect(rangeMap[7]) == 19...19
    expect(rangeMap[8]) == 21...21
    expect(rangeMap[9]) == 24...24
    expect(rangeMap[10]) == 29...30
    expect(rangeMap[11]) == 33...34
    expect(rangeMap[12]) == 36...39
    expect(rangeMap[13]) == 43...45

    rangeMap.insert(38)
    expect(rangeMap).to(haveCount(14))
    expect(rangeMap[0]) == 0...0
    expect(rangeMap[1]) == 2...2
    expect(rangeMap[2]) == 4...4
    expect(rangeMap[3]) == 7...8
    expect(rangeMap[4]) == 11...11
    expect(rangeMap[5]) == 13...13
    expect(rangeMap[6]) == 16...17
    expect(rangeMap[7]) == 19...19
    expect(rangeMap[8]) == 21...21
    expect(rangeMap[9]) == 24...24
    expect(rangeMap[10]) == 29...30
    expect(rangeMap[11]) == 33...34
    expect(rangeMap[12]) == 36...39
    expect(rangeMap[13]) == 43...45

    rangeMap.insert(43)
    expect(rangeMap).to(haveCount(14))
    expect(rangeMap[0]) == 0...0
    expect(rangeMap[1]) == 2...2
    expect(rangeMap[2]) == 4...4
    expect(rangeMap[3]) == 7...8
    expect(rangeMap[4]) == 11...11
    expect(rangeMap[5]) == 13...13
    expect(rangeMap[6]) == 16...17
    expect(rangeMap[7]) == 19...19
    expect(rangeMap[8]) == 21...21
    expect(rangeMap[9]) == 24...24
    expect(rangeMap[10]) == 29...30
    expect(rangeMap[11]) == 33...34
    expect(rangeMap[12]) == 36...39
    expect(rangeMap[13]) == 43...45

    rangeMap.insert(31)
    expect(rangeMap).to(haveCount(14))
    expect(rangeMap[0]) == 0...0
    expect(rangeMap[1]) == 2...2
    expect(rangeMap[2]) == 4...4
    expect(rangeMap[3]) == 7...8
    expect(rangeMap[4]) == 11...11
    expect(rangeMap[5]) == 13...13
    expect(rangeMap[6]) == 16...17
    expect(rangeMap[7]) == 19...19
    expect(rangeMap[8]) == 21...21
    expect(rangeMap[9]) == 24...24
    expect(rangeMap[10]) == 29...31
    expect(rangeMap[11]) == 33...34
    expect(rangeMap[12]) == 36...39
    expect(rangeMap[13]) == 43...45

    rangeMap.insert(36)
    expect(rangeMap).to(haveCount(14))
    expect(rangeMap[0]) == 0...0
    expect(rangeMap[1]) == 2...2
    expect(rangeMap[2]) == 4...4
    expect(rangeMap[3]) == 7...8
    expect(rangeMap[4]) == 11...11
    expect(rangeMap[5]) == 13...13
    expect(rangeMap[6]) == 16...17
    expect(rangeMap[7]) == 19...19
    expect(rangeMap[8]) == 21...21
    expect(rangeMap[9]) == 24...24
    expect(rangeMap[10]) == 29...31
    expect(rangeMap[11]) == 33...34
    expect(rangeMap[12]) == 36...39
    expect(rangeMap[13]) == 43...45

    rangeMap.insert(19)
    expect(rangeMap).to(haveCount(14))
    expect(rangeMap[0]) == 0...0
    expect(rangeMap[1]) == 2...2
    expect(rangeMap[2]) == 4...4
    expect(rangeMap[3]) == 7...8
    expect(rangeMap[4]) == 11...11
    expect(rangeMap[5]) == 13...13
    expect(rangeMap[6]) == 16...17
    expect(rangeMap[7]) == 19...19
    expect(rangeMap[8]) == 21...21
    expect(rangeMap[9]) == 24...24
    expect(rangeMap[10]) == 29...31
    expect(rangeMap[11]) == 33...34
    expect(rangeMap[12]) == 36...39
    expect(rangeMap[13]) == 43...45

    rangeMap.insert(44)
    expect(rangeMap).to(haveCount(14))
    expect(rangeMap[0]) == 0...0
    expect(rangeMap[1]) == 2...2
    expect(rangeMap[2]) == 4...4
    expect(rangeMap[3]) == 7...8
    expect(rangeMap[4]) == 11...11
    expect(rangeMap[5]) == 13...13
    expect(rangeMap[6]) == 16...17
    expect(rangeMap[7]) == 19...19
    expect(rangeMap[8]) == 21...21
    expect(rangeMap[9]) == 24...24
    expect(rangeMap[10]) == 29...31
    expect(rangeMap[11]) == 33...34
    expect(rangeMap[12]) == 36...39
    expect(rangeMap[13]) == 43...45

    rangeMap.insert(7)
    expect(rangeMap).to(haveCount(14))
    expect(rangeMap[0]) == 0...0
    expect(rangeMap[1]) == 2...2
    expect(rangeMap[2]) == 4...4
    expect(rangeMap[3]) == 7...8
    expect(rangeMap[4]) == 11...11
    expect(rangeMap[5]) == 13...13
    expect(rangeMap[6]) == 16...17
    expect(rangeMap[7]) == 19...19
    expect(rangeMap[8]) == 21...21
    expect(rangeMap[9]) == 24...24
    expect(rangeMap[10]) == 29...31
    expect(rangeMap[11]) == 33...34
    expect(rangeMap[12]) == 36...39
    expect(rangeMap[13]) == 43...45

    rangeMap.insert(22)
    expect(rangeMap).to(haveCount(14))
    expect(rangeMap[0]) == 0...0
    expect(rangeMap[1]) == 2...2
    expect(rangeMap[2]) == 4...4
    expect(rangeMap[3]) == 7...8
    expect(rangeMap[4]) == 11...11
    expect(rangeMap[5]) == 13...13
    expect(rangeMap[6]) == 16...17
    expect(rangeMap[7]) == 19...19
    expect(rangeMap[8]) == 21...22
    expect(rangeMap[9]) == 24...24
    expect(rangeMap[10]) == 29...31
    expect(rangeMap[11]) == 33...34
    expect(rangeMap[12]) == 36...39
    expect(rangeMap[13]) == 43...45

    rangeMap.insert(34)
    expect(rangeMap).to(haveCount(14))
    expect(rangeMap[0]) == 0...0
    expect(rangeMap[1]) == 2...2
    expect(rangeMap[2]) == 4...4
    expect(rangeMap[3]) == 7...8
    expect(rangeMap[4]) == 11...11
    expect(rangeMap[5]) == 13...13
    expect(rangeMap[6]) == 16...17
    expect(rangeMap[7]) == 19...19
    expect(rangeMap[8]) == 21...22
    expect(rangeMap[9]) == 24...24
    expect(rangeMap[10]) == 29...31
    expect(rangeMap[11]) == 33...34
    expect(rangeMap[12]) == 36...39
    expect(rangeMap[13]) == 43...45

    rangeMap.insert(41)
    expect(rangeMap).to(haveCount(15))
    expect(rangeMap[0]) == 0...0
    expect(rangeMap[1]) == 2...2
    expect(rangeMap[2]) == 4...4
    expect(rangeMap[3]) == 7...8
    expect(rangeMap[4]) == 11...11
    expect(rangeMap[5]) == 13...13
    expect(rangeMap[6]) == 16...17
    expect(rangeMap[7]) == 19...19
    expect(rangeMap[8]) == 21...22
    expect(rangeMap[9]) == 24...24
    expect(rangeMap[10]) == 29...31
    expect(rangeMap[11]) == 33...34
    expect(rangeMap[12]) == 36...39
    expect(rangeMap[13]) == 41...41
    expect(rangeMap[14]) == 43...45

    rangeMap.insert(29)
    expect(rangeMap).to(haveCount(15))
    expect(rangeMap[0]) == 0...0
    expect(rangeMap[1]) == 2...2
    expect(rangeMap[2]) == 4...4
    expect(rangeMap[3]) == 7...8
    expect(rangeMap[4]) == 11...11
    expect(rangeMap[5]) == 13...13
    expect(rangeMap[6]) == 16...17
    expect(rangeMap[7]) == 19...19
    expect(rangeMap[8]) == 21...22
    expect(rangeMap[9]) == 24...24
    expect(rangeMap[10]) == 29...31
    expect(rangeMap[11]) == 33...34
    expect(rangeMap[12]) == 36...39
    expect(rangeMap[13]) == 41...41
    expect(rangeMap[14]) == 43...45

    rangeMap.insert(4)
    expect(rangeMap).to(haveCount(15))
    expect(rangeMap[0]) == 0...0
    expect(rangeMap[1]) == 2...2
    expect(rangeMap[2]) == 4...4
    expect(rangeMap[3]) == 7...8
    expect(rangeMap[4]) == 11...11
    expect(rangeMap[5]) == 13...13
    expect(rangeMap[6]) == 16...17
    expect(rangeMap[7]) == 19...19
    expect(rangeMap[8]) == 21...22
    expect(rangeMap[9]) == 24...24
    expect(rangeMap[10]) == 29...31
    expect(rangeMap[11]) == 33...34
    expect(rangeMap[12]) == 36...39
    expect(rangeMap[13]) == 41...41
    expect(rangeMap[14]) == 43...45

    rangeMap.insert(23)
    expect(rangeMap).to(haveCount(14))
    expect(rangeMap[0]) == 0...0
    expect(rangeMap[1]) == 2...2
    expect(rangeMap[2]) == 4...4
    expect(rangeMap[3]) == 7...8
    expect(rangeMap[4]) == 11...11
    expect(rangeMap[5]) == 13...13
    expect(rangeMap[6]) == 16...17
    expect(rangeMap[7]) == 19...19
    expect(rangeMap[8]) == 21...24
    expect(rangeMap[9]) == 29...31
    expect(rangeMap[10]) == 33...34
    expect(rangeMap[11]) == 36...39
    expect(rangeMap[12]) == 41...41
    expect(rangeMap[13]) == 43...45

    rangeMap.insert(7)
    expect(rangeMap).to(haveCount(14))
    expect(rangeMap[0]) == 0...0
    expect(rangeMap[1]) == 2...2
    expect(rangeMap[2]) == 4...4
    expect(rangeMap[3]) == 7...8
    expect(rangeMap[4]) == 11...11
    expect(rangeMap[5]) == 13...13
    expect(rangeMap[6]) == 16...17
    expect(rangeMap[7]) == 19...19
    expect(rangeMap[8]) == 21...24
    expect(rangeMap[9]) == 29...31
    expect(rangeMap[10]) == 33...34
    expect(rangeMap[11]) == 36...39
    expect(rangeMap[12]) == 41...41
    expect(rangeMap[13]) == 43...45

    rangeMap.insert(6)
    expect(rangeMap).to(haveCount(14))
    expect(rangeMap[0]) == 0...0
    expect(rangeMap[1]) == 2...2
    expect(rangeMap[2]) == 4...4
    expect(rangeMap[3]) == 6...8
    expect(rangeMap[4]) == 11...11
    expect(rangeMap[5]) == 13...13
    expect(rangeMap[6]) == 16...17
    expect(rangeMap[7]) == 19...19
    expect(rangeMap[8]) == 21...24
    expect(rangeMap[9]) == 29...31
    expect(rangeMap[10]) == 33...34
    expect(rangeMap[11]) == 36...39
    expect(rangeMap[12]) == 41...41
    expect(rangeMap[13]) == 43...45

    rangeMap.insert(15)
    expect(rangeMap).to(haveCount(14))
    expect(rangeMap[0]) == 0...0
    expect(rangeMap[1]) == 2...2
    expect(rangeMap[2]) == 4...4
    expect(rangeMap[3]) == 6...8
    expect(rangeMap[4]) == 11...11
    expect(rangeMap[5]) == 13...13
    expect(rangeMap[6]) == 15...17
    expect(rangeMap[7]) == 19...19
    expect(rangeMap[8]) == 21...24
    expect(rangeMap[9]) == 29...31
    expect(rangeMap[10]) == 33...34
    expect(rangeMap[11]) == 36...39
    expect(rangeMap[12]) == 41...41
    expect(rangeMap[13]) == 43...45

    rangeMap.insert(29)
    expect(rangeMap).to(haveCount(14))
    expect(rangeMap[0]) == 0...0
    expect(rangeMap[1]) == 2...2
    expect(rangeMap[2]) == 4...4
    expect(rangeMap[3]) == 6...8
    expect(rangeMap[4]) == 11...11
    expect(rangeMap[5]) == 13...13
    expect(rangeMap[6]) == 15...17
    expect(rangeMap[7]) == 19...19
    expect(rangeMap[8]) == 21...24
    expect(rangeMap[9]) == 29...31
    expect(rangeMap[10]) == 33...34
    expect(rangeMap[11]) == 36...39
    expect(rangeMap[12]) == 41...41
    expect(rangeMap[13]) == 43...45
  }

  func testLowerUpperBound() {
    let rangeMap1 = CountableRangeMapBehaviorTests.rangeMap
    expect(rangeMap1.lowerBound) == 4
    expect(rangeMap1.upperBound) == 77

    let rangeMap2 = CountableRangeMap<Int>()
    expect(rangeMap2.lowerBound).to(beNil())
    expect(rangeMap2.upperBound).to(beNil())
  }

  func testSubSequence() {
    let rangeMap = CountableRangeMapBehaviorTests.rangeMap
    let slice1 = rangeMap[1...3]
    expect(slice1).to(haveCount(3))
    expect(slice1.indices) == 1..<4
    expect(slice1[slice1.startIndex]) == 29...33
    expect(slice1[slice1.startIndex + 1]) == 37...46
    expect(slice1[slice1.startIndex + 2]) == 49...53
    expect(slice1.lowerBound) == 29
    expect(slice1.upperBound) == 53
    expect(slice1.min()) == 29...33
    expect(slice1.max()) == 49...53
    expect(slice1.coverage) == 29...53
    expect(slice1.flattenedCount) == 20
    expect(slice1.index(of: 30...31)) == slice1.startIndex
    expect(slice1.index(of: 4)).to(beNil())
    expect(slice1.contains(50)) == true
    expect(slice1.contains(38...44)) == true
    expect(slice1.contains(4...17)) == false

    let slice2 = slice1[2...3]
    expect(slice2).to(haveCount(2))
    expect(slice2.indices) == 2..<4
    expect(slice2[slice2.startIndex]) == 37...46
    expect(slice2[slice2.index(after: slice2.startIndex)]) == 49...53
    expect(slice2.lowerBound) == 37
    expect(slice2.upperBound) == 53
    expect(slice2.min()) == 37...46
    expect(slice2.max()) == 49...53
    expect(slice2.coverage) == 37...53
    expect(slice2.flattenedCount) == 15
    expect(slice2.index(of: 30...31)).to(beNil())
    expect(slice2.index(of: 38...40)) == slice2.startIndex
    expect(slice2.index(of: 4)).to(beNil())
    expect(slice2.contains(50)) == true
    expect(slice2.contains(38...44)) == true
    expect(slice2.contains(4...17)) == false
  }

  func testInvert() {
    var rangeMap1 = CountableRangeMapBehaviorTests.rangeMap
    rangeMap1.invert(coverage: 0...100)
    expect(rangeMap1).to(haveCount(6))
    expect(rangeMap1[0]) == 0...3
    expect(rangeMap1[1]) == 18...28
    expect(rangeMap1[2]) == 34...36
    expect(rangeMap1[3]) == 47...48
    expect(rangeMap1[4]) == 54...63
    expect(rangeMap1[5]) == 78...100

    var rangeMap1a = CountableRangeMapBehaviorTests.rangeMap
    rangeMap1a.invert(coverage: CountableRange(0...100))
    expect(rangeMap1a).to(haveCount(6))
    expect(rangeMap1a[0]) == 0...3
    expect(rangeMap1a[1]) == 18...28
    expect(rangeMap1a[2]) == 34...36
    expect(rangeMap1a[3]) == 47...48
    expect(rangeMap1a[4]) == 54...63
    expect(rangeMap1a[5]) == 78...100

    var rangeMap1b = CountableRangeMapBehaviorTests.rangeMap
    rangeMap1b.invert(coverage: Range(0...100))
    expect(rangeMap1b).to(haveCount(6))
    expect(rangeMap1b[0]) == 0...3
    expect(rangeMap1b[1]) == 18...28
    expect(rangeMap1b[2]) == 34...36
    expect(rangeMap1b[3]) == 47...48
    expect(rangeMap1b[4]) == 54...63
    expect(rangeMap1b[5]) == 78...100

    var rangeMap1c = CountableRangeMapBehaviorTests.rangeMap
    rangeMap1c.invert(coverage: 0...100)
    expect(rangeMap1c).to(haveCount(6))
    expect(rangeMap1c[0]) == 0...3
    expect(rangeMap1c[1]) == 18...28
    expect(rangeMap1c[2]) == 34...36
    expect(rangeMap1c[3]) == 47...48
    expect(rangeMap1c[4]) == 54...63
    expect(rangeMap1c[5]) == 78...100

    var rangeMap2 = CountableRangeMapBehaviorTests.rangeMap
    rangeMap2.invert(coverage: 4...100)
    expect(rangeMap2).to(haveCount(5))
    expect(rangeMap2[0]) == 18...28
    expect(rangeMap2[1]) == 34...36
    expect(rangeMap2[2]) == 47...48
    expect(rangeMap2[3]) == 54...63
    expect(rangeMap2[4]) == 78...100

    var rangeMap3 = CountableRangeMapBehaviorTests.rangeMap
    rangeMap3.invert(coverage: 0...77)
    expect(rangeMap3).to(haveCount(5))
    expect(rangeMap3[0]) == 0...3
    expect(rangeMap3[1]) == 18...28
    expect(rangeMap3[2]) == 34...36
    expect(rangeMap3[3]) == 47...48
    expect(rangeMap3[4]) == 54...63

    var rangeMap4 = CountableRangeMapBehaviorTests.rangeMap
    rangeMap4.invert(coverage: 4...77)
    expect(rangeMap4).to(haveCount(4))
    expect(rangeMap4[0]) == 18...28
    expect(rangeMap4[1]) == 34...36
    expect(rangeMap4[2]) == 47...48
    expect(rangeMap4[3]) == 54...63

    let rangeMap5 = CountableRangeMap<Int>().inverted(coverage: 4...16)
    expect(rangeMap5).to(haveCount(1))
    expect(rangeMap5[0]) == 4...16

    let rangeMap5a = CountableRangeMap<Int>().inverted(coverage: CountableRange(4...16))
    expect(rangeMap5a).to(haveCount(1))
    expect(rangeMap5a[0]) == 4...16

    let rangeMap5b = CountableRangeMap<Int>().inverted(coverage: Range(4...16))
    expect(rangeMap5b).to(haveCount(1))
    expect(rangeMap5b[0]) == 4...16

    let rangeMap5c = CountableRangeMap<Int>().inverted(coverage: 4...16)
    expect(rangeMap5c).to(haveCount(1))
    expect(rangeMap5c[0]) == 4...16
  }

  func testFlattenedCount() {
    let expectedCount = CountableRangeMapBehaviorTests.ranges.map { $0.count }.reduce(0) { $0 + $1 }
    let rangeMap = CountableRangeMapBehaviorTests.rangeMap
    expect(rangeMap.flattenedCount) == expectedCount
  }

  func testEquatable() {
    let rangeMap1 = CountableRangeMap<Int>([4...17, 29...33, 37...46, 49...53, 64...77])
    let rangeMap2 = CountableRangeMapBehaviorTests.rangeMap
    expect(rangeMap1 == rangeMap2) == true
    let rangeMap3 = CountableRangeMap<Int>([4...17, 29...33, 37...46, 49...53, 64...76])
    expect(rangeMap1 == rangeMap3) == false
  }
}
