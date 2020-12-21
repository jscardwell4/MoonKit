//
//  UInt128Tests.swift
//  UInt128Tests
//
//  Created by Jason Cardwell on 8/23/16.
//  Copyright © 2016 Jason Cardwell. All rights reserved.
//
@testable import MoonKit
import Nimble
import XCTest

final class UInt128Tests: XCTestCase {
  func testDescription() {
    expect(UInt128(1).description) == "1"
    expect(UInt128(12).description) == "12"
    expect(UInt128(123).description) == "123"
    expect(UInt128(1234).description) == "1234"
    expect(UInt128(12345).description) == "12345"
    expect(UInt128(123456).description) == "123456"
    expect(UInt128(1234567).description) == "1234567"
    expect(UInt128(12345678).description) == "12345678"
    expect(UInt128(123456781).description) == "123456781"
    expect(UInt128(1234567812).description) == "1234567812"
    expect(UInt128(12345678123).description) == "12345678123"
    expect(UInt128(123456781234).description) == "123456781234"
    expect(UInt128(1234567812345).description) == "1234567812345"
    expect(UInt128(12345678123456).description) == "12345678123456"
    expect(UInt128(123456781234567).description) == "123456781234567"
    expect(UInt128(high: 0xcf31029a1b0b213e,
                   low: 0x41a230cc06319617).description) == "275404670447871577180648434354736961047"
    expect(UInt128(high: 0xcf31029a1b0b213e, low: 0x41a230cc06319617).debugDescription) == "275404670447871577180648434354736961047 {high: 0xcf31029a1b0b213e; low: 0x41a230cc06319617}"
  }

  func testAddition() {
    expect(UInt128(17317387770).addingReportingOverflow(95644713)) == (17413032483, false)
    expect(UInt128(157992089).addingReportingOverflow(110807234)) == (268799323, false)
    expect(UInt128(17592290566382).addingReportingOverflow(2199172283062)) == (19791462849444, false)
    expect(UInt128(17592232875943).addingReportingOverflow(2278409876)) == (17594511285819, false)
    expect(UInt128(1125899927981303).addingReportingOverflow(152575985)) == (1125900080557288, false)
    expect(UInt128(8796127282511).addingReportingOverflow(166345501)) == (8796293628012, false)
    expect(UInt128(562949987683944).addingReportingOverflow(35184388735771)) == (598134376419715, false)
    expect(UInt128(17289744515).addingReportingOverflow(137909942)) == (17427654457, false)
    expect(UInt128(161460981).addingReportingOverflow(140805976)) == (302266957, false)
    expect(UInt128(70368832575119).addingReportingOverflow(68856751909)) == (70437689327028, false)
    expect(UInt128(549863367103).addingReportingOverflow(136507454)) == (549999874557, false)
    expect(UInt128(281475003458622).addingReportingOverflow(1099566706172)) == (282574570164794, false)
    expect(UInt128(2251799923124430).addingReportingOverflow(26198162)) == (2251799949322592, false)
    expect(UInt128(2199082992705).addingReportingOverflow(68827427936)) == (2267910420641, false)
    expect(UInt128(4454628945).addingReportingOverflow(70894583)) == (4525523528, false)
    expect(UInt128(1125900014063717).addingReportingOverflow(137461356800)) == (1126037475420517, false)
    expect(UInt128(34510348538).addingReportingOverflow(2193527085)) == (36703875623, false)
    expect(UInt128(8796195360888).addingReportingOverflow(129378430)) == (8796324739318, false)
    expect(UInt128(1217152688).addingReportingOverflow(23466926)) == (1240619614, false)
    expect(UInt128(2287743245).addingReportingOverflow(115580675)) == (2403323920, false)
    expect(UInt128.max.addingReportingOverflow(UInt128.max)) == (UInt128(high: 0xffffffffffffffff, low: 0xfffffffffffffffe), true)
    expect(UInt128(high: 0xcf31029a1b0b213e,
                   low: 0x41a230cc06319617).addingReportingOverflow(UInt128(high: 0x2216a1420bf34521,
                                                                       low: 0x801d64ae10c5361d))) == (UInt128(high: 0xf147a3dc26fe665f,
                                                                                                              low: 0xc1bf957a16f6cc34), false)
  }

  func testSubtraction() {
    expect(UInt128(17317387770).subtractingReportingOverflow(95644713)) == (17221743057, false)
    expect(UInt128(157992089).subtractingReportingOverflow(110807234)) == (47184855, false)
    expect(UInt128(17592290566382).subtractingReportingOverflow(2199172283062)) == (15393118283320, false)
    expect(UInt128(17592232875943).subtractingReportingOverflow(2278409876)) == (17589954466067, false)
    expect(UInt128(1125899927981303).subtractingReportingOverflow(152575985)) == (1125899775405318, false)
    expect(UInt128(8796127282511).subtractingReportingOverflow(166345501)) == (8795960937010, false)
    expect(UInt128(562949987683944).subtractingReportingOverflow(35184388735771)) == (527765598948173, false)
    expect(UInt128(17289744515).subtractingReportingOverflow(137909942)) == (17151834573, false)
    expect(UInt128(161460981).subtractingReportingOverflow(140805976)) == (20655005, false)
    expect(UInt128(70368832575119).subtractingReportingOverflow(68856751909)) == (70299975823210, false)
    expect(UInt128(549863367103).subtractingReportingOverflow(136507454)) == (549726859649, false)
    expect(UInt128(281475003458622).subtractingReportingOverflow(1099566706172)) == (280375436752450, false)
    expect(UInt128(2251799923124430).subtractingReportingOverflow(26198162)) == (2251799896926268, false)
    expect(UInt128(2199082992705).subtractingReportingOverflow(68827427936)) == (2130255564769, false)
    expect(UInt128(4454628945).subtractingReportingOverflow(70894583)) == (4383734362, false)
    expect(UInt128(1125900014063717).subtractingReportingOverflow(137461356800)) == (1125762552706917, false)
    expect(UInt128(34510348538).subtractingReportingOverflow(2193527085)) == (32316821453, false)
    expect(UInt128(8796195360888).subtractingReportingOverflow(129378430)) == (8796065982458, false)
    expect(UInt128(1217152688).subtractingReportingOverflow(23466926)) == (1193685762, false)
    expect(UInt128(2287743245).subtractingReportingOverflow(115580675)) == (2172162570, false)
    expect(UInt128(high: 0xcf31029a1b0b213e,
                   low: 0x41a230cc06319617).subtractingReportingOverflow(UInt128(high: 0x2216a1420bf34521,
                                                                            low: 0x801d64ae10c5361d))) == (UInt128(high: 0xad1a61580f17dc1c,
                                                                                                                   low: 0xc184cc1df56c5ffa), false)
  }

  func testMultiplication() {
    expect(UInt128(137518590).multipliedReportingOverflow(by: 11758638)) == (1617031318080420, false)
    expect(UInt128(157992089).multipliedReportingOverflow(by: 10143944)) == (1602662903259016, false)
    expect(UInt128(104526062).multipliedReportingOverflow(by: 14940862)) == (1561709467745444, false)
    expect(UInt128(46835623).multipliedReportingOverflow(by: 13485851)) == (631618233270173, false)
    expect(UInt128(21400823).multipliedReportingOverflow(by: 1581050)) == (33835771204150, false)
    expect(UInt128(34262351).multipliedReportingOverflow(by: 15350566)) == (525946480340666, false)
    expect(UInt128(34393704).multipliedReportingOverflow(by: 1966876)) == (67648150948704, false)
    expect(UInt128(109875335).multipliedReportingOverflow(by: 3692222)) == (405684129144370, false)
    expect(UInt128(161460981).multipliedReportingOverflow(by: 6588256)) == (1063746276839136, false)
    expect(UInt128(88413839).multipliedReportingOverflow(by: 3061549)) == (270683300376611, false)
    expect(UInt128(107553343).multipliedReportingOverflow(by: 2289734)) == (246268546280762, false)
    expect(UInt128(26813502).multipliedReportingOverflow(by: 4812287)) == (129034267099074, false)
    expect(UInt128(109963470).multipliedReportingOverflow(by: 9420947)) == (1035960022806090, false)
    expect(UInt128(59737665).multipliedReportingOverflow(by: 7292006)) == (435607411605990, false)
    expect(UInt128(159661650).multipliedReportingOverflow(by: 3785723)) == (604434780622950, false)
    expect(UInt128(107483237).multipliedReportingOverflow(by: 5634305)) == (605593339645285, false)
    expect(UInt128(150610178).multipliedReportingOverflow(by: 12489135)) == (1880990845416030, false)
    expect(UInt128(102340728).multipliedReportingOverflow(by: 11937925)) == (1221735935309400, false)
    expect(UInt128(1217152688).multipliedReportingOverflow(by: 6689711)) == (8142399725593168, false)
    expect(UInt128(2287743245).multipliedReportingOverflow(by: 14917385)) == (34127146766814325, false)
    expect(UInt128.doubleWidthMultiply(UInt128(high: 0xcf31029a1b0b213e, low: 0x41a230cc06319617),
                                       UInt128(high: 0x2216a1420bf34521, low: 0x801d64ae10c5361d))) == (high: UInt128(high: 0x1b96d311f7c762b1,
                                                                                                                      low: 0x82fe383b4d0c9d52),
                                                                                                        low: UInt128(high: 0x0ff133f20278727a,
                                                                                                                     low: 0x07fe6d9718f9da9b))
    expect(UInt128.max.multipliedReportingOverflow(by: UInt128.max)) == (1, true)
  }

  func testDivision() {
    expect(UInt128(137518590).dividedReportingOverflow(by: 11758638)) == (11, false)
    expect(UInt128(157992089).dividedReportingOverflow(by: 10143944)) == (15, false)
    expect(UInt128(104526062).dividedReportingOverflow(by: 14940862)) == (6, false)
    expect(UInt128(46835623).dividedReportingOverflow(by: 13485851)) == (3, false)
    expect(UInt128(21400823).dividedReportingOverflow(by: 1581050)) == (13, false)
    expect(UInt128(34262351).dividedReportingOverflow(by: 15350566)) == (2, false)
    expect(UInt128(34393704).dividedReportingOverflow(by: 1966876)) == (17, false)
    expect(UInt128(109875335).dividedReportingOverflow(by: 3692222)) == (29, false)
    expect(UInt128(161460981).dividedReportingOverflow(by: 6588256)) == (24, false)
    expect(UInt128(88413839).dividedReportingOverflow(by: 3061549)) == (28, false)
    expect(UInt128(107553343).dividedReportingOverflow(by: 2289734)) == (46, false)
    expect(UInt128(26813502).dividedReportingOverflow(by: 4812287)) == (5, false)
    expect(UInt128(109963470).dividedReportingOverflow(by: 9420947)) == (11, false)
    expect(UInt128(59737665).dividedReportingOverflow(by: 7292006)) == (8, false)
    expect(UInt128(159661650).dividedReportingOverflow(by: 3785723)) == (42, false)
    expect(UInt128(107483237).dividedReportingOverflow(by: 5634305)) == (19, false)
    expect(UInt128(150610178).dividedReportingOverflow(by: 12489135)) == (12, false)
    expect(UInt128(102340728).dividedReportingOverflow(by: 11937925)) == (8, false)
    expect(UInt128(1217152688).dividedReportingOverflow(by: 6689711)) == (181, false)
    expect(UInt128(2287743245).dividedReportingOverflow(by: 14917385)) == (153, false)
    expect(UInt128(2287743245).remainderReportingOverflow(dividingBy: 14917385)) == (5383340, false)
  }

  func testStaticVariables() {
    expect(UInt128.min) == 0
    expect(UInt128.max) == UInt128(high: UInt64.max, low: UInt64.max)
    expect(UInt128.bitWidth) == 128
    expect(UInt128.isSigned) == false
    expect(UInt128.max.magnitude) == UInt128.max
    expect(UInt128.min.minimumSignedRepresentationBitWidth) == 128
    expect(UInt128().signum()) == 1
  }

  func asBinaryInteger<T>(_ value: T) -> T where T: BinaryInteger {
    return value
  }

  func testBitwiseOr() {
    expect(UInt128(high: 0x15a0213be95279b4,
                   low: 0x4797a3617eb8b808).bitwiseOr(UInt128(high: 0xacdc3a1f1ea7ffc3,
                                                              low: 0xca1ca51eb646f945))) == UInt128(high: 0xbdfc3b3ffff7fff7,
                                                                                                    low: 0xcf9fa77ffefef94d)
    expect(UInt128(high: 0x1d107d9678d0d4f8,
                   low: 0xec0ca5fc919029c6).bitwiseOr(UInt128(high: 0x8c8c509b742d039a,
                                                              low: 0xa6951ea6fec91922))) == UInt128(high: 0x9d9c7d9f7cfdd7fa,
                                                                                                    low: 0xee9dbffeffd939e6)
  }

  func testBitwiseAnd() {
    expect(UInt128(high: 0x15a0213be95279b4,
                   low: 0x4797a3617eb8b808).bitwiseAnd(UInt128(high: 0xacdc3a1f1ea7ffc3,
                                                               low: 0xca1ca51eb646f945))) == UInt128(high: 0x480201b08027980,
                                                                                                     low: 0x4214a1003600b800)
    expect(UInt128(high: 0x1d107d9678d0d4f8,
                   low: 0xec0ca5fc919029c6).bitwiseAnd(UInt128(high: 0x8c8c509b742d039a,
                                                               low: 0xa6951ea6fec91922))) == UInt128(high: 0xc00509270000098,
                                                                                                     low: 0xa40404a490800902)
  }

  func testBitwiseXor() {
    expect(UInt128(high: 0x15a0213be95279b4,
                   low: 0x4797a3617eb8b808).bitwiseXor(UInt128(high: 0xacdc3a1f1ea7ffc3,
                                                               low: 0xca1ca51eb646f945))) == UInt128(high: 0xb97c1b24f7f58677,
                                                                                                     low: 0x8d8b067fc8fe414d)
    expect(UInt128(high: 0x1d107d9678d0d4f8,
                   low: 0xec0ca5fc919029c6).bitwiseXor(UInt128(high: 0x8c8c509b742d039a,
                                                               low: 0xa6951ea6fec91922))) == UInt128(high: 0x919c2d0d0cfdd762,
                                                                                                     low: 0x4a99bb5a6f5930e4)
  }

  func testMaskingShiftLeft() {
    expect(UInt128(high: 0x914b165e0272e2a0, low: 0x6befc7e45b009df5).maskingShiftLeft(64)) == UInt128(high: 0x6befc7e45b009df5)
    expect(UInt128(high: 0x914b165e0272e2a0, low: 0x6befc7e45b009df5).maskingShiftLeft(4)) == UInt128(high: 0x14b165e0272e2a06, low: 0xbefc7e45b009df50)
    expect(UInt128(high: 0x914b165e0272e2a0, low: 0x6befc7e45b009df5).maskingShiftLeft(0)) == UInt128(high: 0x914b165e0272e2a0, low: 0x6befc7e45b009df5)
  }

  func testMaskingShiftRight() {
    expect(UInt128(high: 0xa2799ee3f8945555, low: 0x2e64af845590fa4a).maskingShiftRight(64)) == UInt128(low: 0xa2799ee3f8945555)
    expect(UInt128(high: 0xa2799ee3f8945555, low: 0x2e64af845590fa4a).maskingShiftRight(4)) == UInt128(high: 0x0a2799ee3f894555, low: 0x52e64af845590fa4)
  }

  func testLeadingZerosAndPopcount() {
    expect(UInt128(high: 0x371cdc61db600552, low: 0xdd5b5aee8ebb7051).leadingZeros) == 2
    expect(UInt128(high: 0x071cdc61db600552, low: 0xdd5b5aee8ebb7051).leadingZeros) == 5
    expect(UInt128(high: 0x00000061db600552, low: 0xdd5b5aee8ebb7051).leadingZeros) == 25
    expect(UInt128(low: 0xdd5b5aee8ebb7051).leadingZeros) == 64
    expect(UInt128(low: 0x005b5aee8ebb7051).leadingZeros) == 73
    expect(UInt128(low: 0x0000000e8ebb7051).leadingZeros) == 92

    expect(UInt128(high: 0x371cdc61db600552, low: 0x305d38128a857e8).popcount) == 54
    expect(UInt128(high: 0x177e4942eb8821c7, low: 0x8f2b1de818d1cd9).popcount) == 60
  }

  func testInitializers() {
    expect(UInt128(self.asBinaryInteger(UInt128(high: 234, low: 1245)))) == UInt128(high: 234, low: 1245)
    expect(UInt128(clamping: self.asBinaryInteger(UInt128(high: 234, low: 1245)))) == UInt128(high: 234, low: 1245)
    expect(UInt128(Double(3.402823669209384e38))) == UInt128(high: 0xfffffffffffff000, low: 0x0000000000000000)
    expect(UInt128(exactly: Double(3.402823669209384e38))) == UInt128(high: 0xfffffffffffff000, low: 0x0000000000000000)
    expect(UInt128(exactly: Double(3.25))).to(beNil())
    expect(UInt128(Float(3.4028236))) == UInt128(high: 0x0000000000000000, low: 0x0000000000000003)
    expect(UInt128(_truncatingBits: UInt(12345678))) == 12345678
  }

  func testWordAt() {
    let x = UInt128(high: 0xcf31029a1b0b213e, low: 0x41a230cc06319617)
    expect(x.words[0]) == 0x41a230cc06319617
    expect(x.words[1]) == 0xcf31029a1b0b213e
    let y = UInt128(high: 0x2216a1420bf34521, low: 0x801d64ae10c5361d)
    expect(y.words[0]) == 0x801d64ae10c5361d
    expect(y.words[1]) == 0x2216a1420bf34521
  }
}
