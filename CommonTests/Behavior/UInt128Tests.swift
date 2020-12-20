//
//  UInt128Tests.swift
//  UInt128Tests
//
//  Created by Jason Cardwell on 8/23/16.
//  Copyright © 2016 Jason Cardwell. All rights reserved.
//
import XCTest
import MoonKitTest
import MoonKit

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
    expect(UInt128(     17317387770).addingWithOverflow(      95644713)) == (     17413032483, .none)
    expect(UInt128(       157992089).addingWithOverflow(     110807234)) == (       268799323, .none)
    expect(UInt128(  17592290566382).addingWithOverflow( 2199172283062)) == (  19791462849444, .none)
    expect(UInt128(  17592232875943).addingWithOverflow(    2278409876)) == (  17594511285819, .none)
    expect(UInt128(1125899927981303).addingWithOverflow(     152575985)) == (1125900080557288, .none)
    expect(UInt128(   8796127282511).addingWithOverflow(     166345501)) == (   8796293628012, .none)
    expect(UInt128( 562949987683944).addingWithOverflow(35184388735771)) == ( 598134376419715, .none)
    expect(UInt128(     17289744515).addingWithOverflow(     137909942)) == (     17427654457, .none)
    expect(UInt128(       161460981).addingWithOverflow(     140805976)) == (       302266957, .none)
    expect(UInt128(  70368832575119).addingWithOverflow(   68856751909)) == (  70437689327028, .none)
    expect(UInt128(    549863367103).addingWithOverflow(     136507454)) == (    549999874557, .none)
    expect(UInt128( 281475003458622).addingWithOverflow( 1099566706172)) == ( 282574570164794, .none)
    expect(UInt128(2251799923124430).addingWithOverflow(      26198162)) == (2251799949322592, .none)
    expect(UInt128(   2199082992705).addingWithOverflow(   68827427936)) == (   2267910420641, .none)
    expect(UInt128(      4454628945).addingWithOverflow(      70894583)) == (      4525523528, .none)
    expect(UInt128(1125900014063717).addingWithOverflow(  137461356800)) == (1126037475420517, .none)
    expect(UInt128(     34510348538).addingWithOverflow(    2193527085)) == (     36703875623, .none)
    expect(UInt128(   8796195360888).addingWithOverflow(     129378430)) == (   8796324739318, .none)
    expect(UInt128(      1217152688).addingWithOverflow(      23466926)) == (      1240619614, .none)
    expect(UInt128(      2287743245).addingWithOverflow(     115580675)) == (      2403323920, .none)
    expect(UInt128.max.addingWithOverflow(UInt128.max)) == (UInt128(high: 0xffffffffffffffff, low: 0xfffffffffffffffe), .overflow)
    expect(UInt128(high: 0xcf31029a1b0b213e,
                   low: 0x41a230cc06319617).addingWithOverflow(UInt128(high: 0x2216a1420bf34521,
                                                                       low: 0x801d64ae10c5361d))) == (UInt128(high: 0xf147a3dc26fe665f,
                                                                                                              low: 0xc1bf957a16f6cc34), .none)
  }

  func testSubtraction() {
    expect(UInt128(     17317387770).subtractingWithOverflow(      95644713)) == (     17221743057, .none)
    expect(UInt128(       157992089).subtractingWithOverflow(     110807234)) == (        47184855, .none)
    expect(UInt128(  17592290566382).subtractingWithOverflow( 2199172283062)) == (  15393118283320, .none)
    expect(UInt128(  17592232875943).subtractingWithOverflow(    2278409876)) == (  17589954466067, .none)
    expect(UInt128(1125899927981303).subtractingWithOverflow(     152575985)) == (1125899775405318, .none)
    expect(UInt128(   8796127282511).subtractingWithOverflow(     166345501)) == (   8795960937010, .none)
    expect(UInt128( 562949987683944).subtractingWithOverflow(35184388735771)) == ( 527765598948173, .none)
    expect(UInt128(     17289744515).subtractingWithOverflow(     137909942)) == (     17151834573, .none)
    expect(UInt128(       161460981).subtractingWithOverflow(     140805976)) == (        20655005, .none)
    expect(UInt128(  70368832575119).subtractingWithOverflow(   68856751909)) == (  70299975823210, .none)
    expect(UInt128(    549863367103).subtractingWithOverflow(     136507454)) == (    549726859649, .none)
    expect(UInt128( 281475003458622).subtractingWithOverflow( 1099566706172)) == ( 280375436752450, .none)
    expect(UInt128(2251799923124430).subtractingWithOverflow(      26198162)) == (2251799896926268, .none)
    expect(UInt128(   2199082992705).subtractingWithOverflow(   68827427936)) == (   2130255564769, .none)
    expect(UInt128(      4454628945).subtractingWithOverflow(      70894583)) == (      4383734362, .none)
    expect(UInt128(1125900014063717).subtractingWithOverflow(  137461356800)) == (1125762552706917, .none)
    expect(UInt128(     34510348538).subtractingWithOverflow(    2193527085)) == (     32316821453, .none)
    expect(UInt128(   8796195360888).subtractingWithOverflow(     129378430)) == (   8796065982458, .none)
    expect(UInt128(      1217152688).subtractingWithOverflow(      23466926)) == (      1193685762, .none)
    expect(UInt128(      2287743245).subtractingWithOverflow(     115580675)) == (      2172162570, .none)
    expect(UInt128(high: 0xcf31029a1b0b213e,
                   low: 0x41a230cc06319617).subtractingWithOverflow(UInt128(high: 0x2216a1420bf34521,
                                                                            low: 0x801d64ae10c5361d))) == (UInt128(high: 0xad1a61580f17dc1c,
                                                                                                                   low: 0xc184cc1df56c5ffa), .none)
  }

  func testMultiplication() {
    expect(UInt128( 137518590).multipliedWithOverflow(by: 11758638)) == (  1617031318080420, .none)
    expect(UInt128( 157992089).multipliedWithOverflow(by: 10143944)) == (  1602662903259016, .none)
    expect(UInt128( 104526062).multipliedWithOverflow(by: 14940862)) == (  1561709467745444, .none)
    expect(UInt128(  46835623).multipliedWithOverflow(by: 13485851)) == (   631618233270173, .none)
    expect(UInt128(  21400823).multipliedWithOverflow(by:  1581050)) == (    33835771204150, .none)
    expect(UInt128(  34262351).multipliedWithOverflow(by: 15350566)) == (   525946480340666, .none)
    expect(UInt128(  34393704).multipliedWithOverflow(by:  1966876)) == (    67648150948704, .none)
    expect(UInt128( 109875335).multipliedWithOverflow(by:  3692222)) == (   405684129144370, .none)
    expect(UInt128( 161460981).multipliedWithOverflow(by:  6588256)) == (  1063746276839136, .none)
    expect(UInt128(  88413839).multipliedWithOverflow(by:  3061549)) == (   270683300376611, .none)
    expect(UInt128( 107553343).multipliedWithOverflow(by:  2289734)) == (   246268546280762, .none)
    expect(UInt128(  26813502).multipliedWithOverflow(by:  4812287)) == (   129034267099074, .none)
    expect(UInt128( 109963470).multipliedWithOverflow(by:  9420947)) == (  1035960022806090, .none)
    expect(UInt128(  59737665).multipliedWithOverflow(by:  7292006)) == (   435607411605990, .none)
    expect(UInt128( 159661650).multipliedWithOverflow(by:  3785723)) == (   604434780622950, .none)
    expect(UInt128( 107483237).multipliedWithOverflow(by:  5634305)) == (   605593339645285, .none)
    expect(UInt128( 150610178).multipliedWithOverflow(by: 12489135)) == (  1880990845416030, .none)
    expect(UInt128( 102340728).multipliedWithOverflow(by: 11937925)) == (  1221735935309400, .none)
    expect(UInt128(1217152688).multipliedWithOverflow(by:  6689711)) == (  8142399725593168, .none)
    expect(UInt128(2287743245).multipliedWithOverflow(by: 14917385)) == ( 34127146766814325, .none)
    expect(UInt128.doubleWidthMultiply(UInt128(high: 0xcf31029a1b0b213e, low: 0x41a230cc06319617),
                                       UInt128(high: 0x2216a1420bf34521, low: 0x801d64ae10c5361d))) == (high: UInt128(high: 0x1b96d311f7c762b1,
                                                                                                                      low: 0x82fe383b4d0c9d52),
                                                                                                        low: UInt128(high: 0x0ff133f20278727a,
                                                                                                                     low: 0x07fe6d9718f9da9b))
    expect(UInt128.max.multipliedWithOverflow(by: UInt128.max)) == (1, .overflow)
  }

  func testDivision() {
    expect(UInt128( 137518590).dividedWithOverflow(by: 11758638)) == ( 11, .none)
    expect(UInt128( 157992089).dividedWithOverflow(by: 10143944)) == ( 15, .none)
    expect(UInt128( 104526062).dividedWithOverflow(by: 14940862)) == (  6, .none)
    expect(UInt128(  46835623).dividedWithOverflow(by: 13485851)) == (  3, .none)
    expect(UInt128(  21400823).dividedWithOverflow(by:  1581050)) == ( 13, .none)
    expect(UInt128(  34262351).dividedWithOverflow(by: 15350566)) == (  2, .none)
    expect(UInt128(  34393704).dividedWithOverflow(by:  1966876)) == ( 17, .none)
    expect(UInt128( 109875335).dividedWithOverflow(by:  3692222)) == ( 29, .none)
    expect(UInt128( 161460981).dividedWithOverflow(by:  6588256)) == ( 24, .none)
    expect(UInt128(  88413839).dividedWithOverflow(by:  3061549)) == ( 28, .none)
    expect(UInt128( 107553343).dividedWithOverflow(by:  2289734)) == ( 46, .none)
    expect(UInt128(  26813502).dividedWithOverflow(by:  4812287)) == (  5, .none)
    expect(UInt128( 109963470).dividedWithOverflow(by:  9420947)) == ( 11, .none)
    expect(UInt128(  59737665).dividedWithOverflow(by:  7292006)) == (  8, .none)
    expect(UInt128( 159661650).dividedWithOverflow(by:  3785723)) == ( 42, .none)
    expect(UInt128( 107483237).dividedWithOverflow(by:  5634305)) == ( 19, .none)
    expect(UInt128( 150610178).dividedWithOverflow(by: 12489135)) == ( 12, .none)
    expect(UInt128( 102340728).dividedWithOverflow(by: 11937925)) == (  8, .none)
    expect(UInt128(1217152688).dividedWithOverflow(by:  6689711)) == (181, .none)
    expect(UInt128(2287743245).dividedWithOverflow(by: 14917385)) == (153, .none)
    expect(UInt128(2287743245).remainder(dividingBy: 14917385))   == 5383340
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

  func asBinaryInteger<T>(_ value: T) -> T where T:BinaryInteger {
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
    expect(UInt128(low:  0xdd5b5aee8ebb7051).leadingZeros) == 64
    expect(UInt128(low:  0x005b5aee8ebb7051).leadingZeros) == 73
    expect(UInt128(low:  0x0000000e8ebb7051).leadingZeros) == 92

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
    expect(x.word(at: 0)) == 0x41a230cc06319617
    expect(x.word(at: 1)) == 0xcf31029a1b0b213e
    let y = UInt128(high: 0x2216a1420bf34521, low: 0x801d64ae10c5361d)
    expect(y.word(at: 0)) == 0x801d64ae10c5361d
    expect(y.word(at: 1)) == 0x2216a1420bf34521
  }

}
