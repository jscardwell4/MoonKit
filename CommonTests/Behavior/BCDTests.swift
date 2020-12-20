// //  BCDTests.swift
//  BCDTests
//
//  Created by Jason Cardwell on 8/14/16.
//  Copyright © 2016 Jason Cardwell. All rights reserved.
//

import XCTest
import MoonKitTest
import MoonKit


final class BCDTests: XCTestCase {

  func testBCD8() {
    expect(BCD8( 1).description) == "1"
    expect(BCD8(12).description) == "12"
    expect(BCD8(99).description) == "99"
    expect(BCD8.max.description) == "159"

    expect(BCD8(24).addingWithOverflow(53)) == ( 77, .none)
    expect(BCD8( 1).addingWithOverflow( 3)) == (  4, .none)
    expect(BCD8(19).addingWithOverflow(69)) == ( 88, .none)
    expect(BCD8(98).addingWithOverflow( 1)) == ( 99, .none)
    expect(BCD8(56).addingWithOverflow(45)) == (101, .none)
    expect(BCD8(56).addingWithOverflow(56)) == (112, .none)
    expect(BCD8(56).addingWithOverflow(66)) == (122, .none)
    expect(BCD8(66).addingWithOverflow(96)) == ( 62, .overflow)

    expect(BCD8(53).subtractingWithOverflow(43)) == (10, .none)
    expect(BCD8( 3).subtractingWithOverflow( 0)) == ( 3, .none)
    expect(BCD8(69).subtractingWithOverflow(19)) == (50, .none)
    expect(BCD8(98).subtractingWithOverflow( 1)) == (97, .none)
    expect(BCD8(56).subtractingWithOverflow(45)) == (11, .none)
    expect(BCD8(56).subtractingWithOverflow(56)) == ( 0, .none)
    expect(BCD8(66).subtractingWithOverflow(56)) == (10, .none)
    expect(BCD8(96).subtractingWithOverflow(66)) == (30, .none)

    expect(BCD8(27).multipliedWithOverflow(by: 8)) == ( 16, .overflow)
    expect(BCD8( 7).multipliedWithOverflow(by: 6)) == ( 42, .none)
    expect(BCD8( 2).multipliedWithOverflow(by: 8)) == ( 16, .none)
    expect(BCD8(22).multipliedWithOverflow(by: 5)) == (110, .none)
    expect(BCD8(11).multipliedWithOverflow(by: 0)) == (  0, .none)

    expect(BCD8( 11).dividedWithOverflow(by: 1)) == (11, .none)
    expect(BCD8.max .dividedWithOverflow(by:99)) == ( 1, .none)
    expect(BCD8( 16).dividedWithOverflow(by: 4)) == ( 4, .none)
    expect(BCD8( 99).dividedWithOverflow(by:33)) == ( 3, .none)
    expect(BCD8( 11).dividedWithOverflow(by:16)) == ( 0, .none)
    expect(BCD8( 14).dividedWithOverflow(by: 7)) == ( 2, .none)

  }

  func testBCD16() {
    expect(BCD16(1).description) == "1"
    expect(BCD16(12).description) == "12"
    expect(BCD16(123).description) == "123"
    expect(BCD16(1234).description) == "1234"
    expect(BCD16(9999).description) == "9999"

    expect(BCD16(2431).addingWithOverflow(5334)) == ( 7765, .none)
    expect(BCD16( 112).addingWithOverflow( 323)) == (  435, .none)
    expect(BCD16(1901).addingWithOverflow(6469)) == ( 8370, .none)
    expect(BCD16(9889).addingWithOverflow( 165)) == (10054, .none)
    expect(BCD16(5653).addingWithOverflow(4534)) == (10187, .none)
    expect(BCD16(5652).addingWithOverflow(5676)) == (11328, .none)
    expect(BCD16(5634).addingWithOverflow(6634)) == (12268, .none)
    expect(BCD16(6622).addingWithOverflow(9886)) == ( 6508, .overflow)

    expect(BCD16(5323).subtractingWithOverflow(4333)) == ( 990, .none)
    expect(BCD16( 301).subtractingWithOverflow(   0)) == ( 301, .none)
    expect(BCD16(6943).subtractingWithOverflow(1129)) == (5814, .none)
    expect(BCD16(9825).subtractingWithOverflow( 145)) == (9680, .none)
    expect(BCD16(5689).subtractingWithOverflow(4512)) == (1177, .none)
    expect(BCD16(5623).subtractingWithOverflow(4654)) == ( 969, .none)
    expect(BCD16(6656).subtractingWithOverflow(5634)) == (1022, .none)
    expect(BCD16(9665).subtractingWithOverflow(6664)) == (3001, .none)

    expect(BCD16(272).multipliedWithOverflow(by: 8)) == ( 2176, .none)
    expect(BCD16( 75).multipliedWithOverflow(by: 6)) == ( 450, .none)
    expect(BCD16( 26).multipliedWithOverflow(by: 8)) == ( 208, .none)
    expect(BCD16(222).multipliedWithOverflow(by: 5)) == (1110, .none)
    expect(BCD16(117).multipliedWithOverflow(by: 0)) == (  0, .none)

    expect(BCD16( 113).dividedWithOverflow(by:   1)) == (113, .none)
    expect(BCD16.max  .dividedWithOverflow(by:9999)) == ( 1, .none)
    expect(BCD16(1634).dividedWithOverflow(by:   4)) == (408, .none)
    expect(BCD16(9964).dividedWithOverflow(by: 343)) == ( 29, .none)
    expect(BCD16(1123).dividedWithOverflow(by: 167)) == ( 6, .none)
    expect(BCD16(1464).dividedWithOverflow(by:  75)) == ( 19, .none)
  }

  func testBCD32() {
    expect(BCD32(1).description) == "1"
    expect(BCD32(12).description) == "12"
    expect(BCD32(123).description) == "123"
    expect(BCD32(1234).description) == "1234"
    expect(BCD32(12345).description) == "12345"
    expect(BCD32(123456).description) == "123456"
    expect(BCD32(1234567).description) == "1234567"
    expect(BCD32(12345678).description) == "12345678"
    expect(BCD32(99999999).description) == "99999999"

    expect(BCD32(110108334).addingWithOverflow( 86822517)) == ( 96930851, .overflow)
    expect(BCD32( 78151204).addingWithOverflow( 15037140)) == ( 93188344, .none)
    expect(BCD32( 42913023).addingWithOverflow( 21096493)) == ( 64009516, .none)
    expect(BCD32( 37106142).addingWithOverflow( 26438680)) == ( 63544822, .none)
    expect(BCD32(128908000).addingWithOverflow( 86027444)) == ( 14935444, .overflow)
    expect(BCD32( 42148307).addingWithOverflow( 26627950)) == ( 68776257, .none)
    expect(BCD32(111282007).addingWithOverflow( 92927136)) == ( 04209143, .overflow)
    expect(BCD32( 72541025).addingWithOverflow( 46346777)) == (118887802, .none)
    expect(BCD32(120501545).addingWithOverflow(  5953673)) == (126455218, .none)
    expect(BCD32( 89540541).addingWithOverflow( 64699027)) == (154239568, .none)
    expect(BCD32(105784487).addingWithOverflow( 71399377)) == ( 77183864, .overflow)
    expect(BCD32( 88019555).addingWithOverflow( 61281377)) == (149300932, .none)
    expect(BCD32(125641135).addingWithOverflow( 41147949)) == ( 66789084, .overflow)
    expect(BCD32( 87585172).addingWithOverflow( 78083498)) == ( 65668670, .overflow)
    expect(BCD32(146103853).addingWithOverflow(115924646)) == ( 62028499, .overflow)
    expect(BCD32(142921127).addingWithOverflow(133548299)) == ( 76469426, .overflow)
    expect(BCD32(133040023).addingWithOverflow( 58698103)) == ( 91738126, .overflow)
    expect(BCD32(154959799).addingWithOverflow(146366682)) == ( 01326481, .overflow)
    expect(BCD32(102715329).addingWithOverflow( 43966054)) == (146681383, .none)
    expect(BCD32(150280620).addingWithOverflow( 73763722)) == ( 24044342, .overflow)

    expect(BCD32(110108334).subtractingWithOverflow( 86822517)) == ( 23285817, .none)
    expect(BCD32( 78151204).subtractingWithOverflow( 15037140)) == ( 63114064, .none)
    expect(BCD32( 42913023).subtractingWithOverflow( 21096493)) == ( 21816530, .none)
    expect(BCD32( 37106142).subtractingWithOverflow( 26438680)) == ( 10667462, .none)
    expect(BCD32(128908000).subtractingWithOverflow( 86027444)) == ( 42880556, .none)
    expect(BCD32( 42148307).subtractingWithOverflow( 26627950)) == ( 15520357, .none)
    expect(BCD32(111282007).subtractingWithOverflow( 92927136)) == ( 18354871, .none)
    expect(BCD32( 72541025).subtractingWithOverflow( 46346777)) == ( 26194248, .none)
    expect(BCD32(120501545).subtractingWithOverflow(  5953673)) == (114547872, .none)
    expect(BCD32( 89540541).subtractingWithOverflow( 64699027)) == ( 24841514, .none)
    expect(BCD32(105784487).subtractingWithOverflow( 71399377)) == ( 34385110, .none)
    expect(BCD32( 88019555).subtractingWithOverflow( 61281377)) == ( 26738178, .none)
    expect(BCD32(125641135).subtractingWithOverflow( 41147949)) == ( 84493186, .none)
    expect(BCD32( 87585172).subtractingWithOverflow( 78083498)) == (  9501674, .none)
    expect(BCD32(146103853).subtractingWithOverflow(115924646)) == ( 30179207, .none)
    expect(BCD32(142921127).subtractingWithOverflow(133548299)) == (  9372828, .none)
    expect(BCD32(133040023).subtractingWithOverflow( 58698103)) == ( 74341920, .none)
    expect(BCD32(154959799).subtractingWithOverflow(146366682)) == (  8593117, .none)
    expect(BCD32(102715329).subtractingWithOverflow( 43966054)) == ( 58749275, .none)
    expect(BCD32(150280620).subtractingWithOverflow( 73763722)) == ( 76516898, .none)

    expect(BCD32(9345).multipliedWithOverflow(by: 1200)) == (11214000, .none)
    expect(BCD32(9019).multipliedWithOverflow(by: 8643)) == (77951217, .none)
    expect(BCD32(7314).multipliedWithOverflow(by: 8602)) == (62915028, .none)
    expect(BCD32(9852).multipliedWithOverflow(by: 1324)) == (13044048, .none)
    expect(BCD32( 892).multipliedWithOverflow(by: 6047)) == ( 5393924, .none)
    expect(BCD32(2522).multipliedWithOverflow(by:  613)) == ( 1545986, .none)
    expect(BCD32(3136).multipliedWithOverflow(by: 6429)) == (20161344, .none)
    expect(BCD32(8279).multipliedWithOverflow(by: 1412)) == (11689948, .none)
    expect(BCD32(3596).multipliedWithOverflow(by: 4268)) == (15347728, .none)
    expect(BCD32(9495).multipliedWithOverflow(by: 5497)) == (52194015, .none)
    expect(BCD32(5066).multipliedWithOverflow(by: 6517)) == (33015122, .none)
    expect(BCD32(8357).multipliedWithOverflow(by: 7505)) == (62719285, .none)
    expect(BCD32(3700).multipliedWithOverflow(by: 2064)) == ( 7636800, .none)
    expect(BCD32(3931).multipliedWithOverflow(by: 1307)) == ( 5137817, .none)
    expect(BCD32(8464).multipliedWithOverflow(by: 6239)) == (52806896, .none)
    expect(BCD32(5420).multipliedWithOverflow(by: 1655)) == ( 8970100, .none)
    expect(BCD32(3328).multipliedWithOverflow(by: 3973)) == (13222144, .none)
    expect(BCD32(5296).multipliedWithOverflow(by: 1320)) == ( 6990720, .none)
    expect(BCD32(5601).multipliedWithOverflow(by:  451)) == ( 2526051, .none)
    expect(BCD32(5649).multipliedWithOverflow(by: 1099)) == ( 6208251, .none)

    expect(BCD32(9345).dividedWithOverflow(by: 1200)) == ( 7, .none)
    expect(BCD32(9019).dividedWithOverflow(by: 8643)) == ( 1, .none)
    expect(BCD32(7314).dividedWithOverflow(by: 8602)) == ( 0, .none)
    expect(BCD32(9852).dividedWithOverflow(by: 1324)) == ( 7, .none)
    expect(BCD32( 892).dividedWithOverflow(by: 6047)) == ( 0, .none)
    expect(BCD32(2522).dividedWithOverflow(by:  613)) == ( 4, .none)
    expect(BCD32(3136).dividedWithOverflow(by: 6429)) == ( 0, .none)
    expect(BCD32(8279).dividedWithOverflow(by: 1412)) == ( 5, .none)
    expect(BCD32(3596).dividedWithOverflow(by: 4268)) == ( 0, .none)
    expect(BCD32(9495).dividedWithOverflow(by: 5497)) == ( 1, .none)
    expect(BCD32(5066).dividedWithOverflow(by: 6517)) == ( 0, .none)
    expect(BCD32(8357).dividedWithOverflow(by: 7505)) == ( 1, .none)
    expect(BCD32(3700).dividedWithOverflow(by: 2064)) == ( 1, .none)
    expect(BCD32(3931).dividedWithOverflow(by: 1307)) == ( 3, .none)
    expect(BCD32(8464).dividedWithOverflow(by: 6239)) == ( 1, .none)
    expect(BCD32(5420).dividedWithOverflow(by: 1655)) == ( 3, .none)
    expect(BCD32(3328).dividedWithOverflow(by: 3973)) == ( 0, .none)
    expect(BCD32(5296).dividedWithOverflow(by: 1320)) == ( 4, .none)
    expect(BCD32(5601).dividedWithOverflow(by:  451)) == (12, .none)
    expect(BCD32(5649).dividedWithOverflow(by: 1099)) == ( 5, .none)

  }

  func testBCD64() {
    expect(BCD64(1).description) == "1"
    expect(BCD64(12).description) == "12"
    expect(BCD64(123).description) == "123"
    expect(BCD64(1234).description) == "1234"
    expect(BCD64(12345).description) == "12345"
    expect(BCD64(123456).description) == "123456"
    expect(BCD64(1234567).description) == "1234567"
    expect(BCD64(12345678).description) == "12345678"
    expect(BCD64(123456781).description) == "123456781"
    expect(BCD64(1234567812).description) == "1234567812"
    expect(BCD64(12345678123).description) == "12345678123"
    expect(BCD64(123456781234).description) == "123456781234"
    expect(BCD64(1234567812345).description) == "1234567812345"
    expect(BCD64(12345678123456).description) == "12345678123456"
    expect(BCD64(123456781234567).description) == "123456781234567"

    expect(BCD64(     17317387770).addingWithOverflow(      95644713)) == (     17413032483, .none)
    expect(BCD64(       157992089).addingWithOverflow(     110807234)) == (       268799323, .none)
    expect(BCD64(  17592290566382).addingWithOverflow( 2199172283062)) == (  19791462849444, .none)
    expect(BCD64(  17592232875943).addingWithOverflow(    2278409876)) == (  17594511285819, .none)
    expect(BCD64(1125899927981303).addingWithOverflow(     152575985)) == (1125900080557288, .none)
    expect(BCD64(   8796127282511).addingWithOverflow(     166345501)) == (   8796293628012, .none)
    expect(BCD64( 562949987683944).addingWithOverflow(35184388735771)) == ( 598134376419715, .none)
    expect(BCD64(     17289744515).addingWithOverflow(     137909942)) == (     17427654457, .none)
    expect(BCD64(       161460981).addingWithOverflow(     140805976)) == (       302266957, .none)
    expect(BCD64(  70368832575119).addingWithOverflow(   68856751909)) == (  70437689327028, .none)
    expect(BCD64(    549863367103).addingWithOverflow(     136507454)) == (    549999874557, .none)
    expect(BCD64( 281475003458622).addingWithOverflow( 1099566706172)) == ( 282574570164794, .none)
    expect(BCD64(2251799923124430).addingWithOverflow(      26198162)) == (2251799949322592, .none)
    expect(BCD64(   2199082992705).addingWithOverflow(   68827427936)) == (   2267910420641, .none)
    expect(BCD64(      4454628945).addingWithOverflow(      70894583)) == (      4525523528, .none)
    expect(BCD64(1125900014063717).addingWithOverflow(  137461356800)) == (1126037475420517, .none)
    expect(BCD64(     34510348538).addingWithOverflow(    2193527085)) == (     36703875623, .none)
    expect(BCD64(   8796195360888).addingWithOverflow(     129378430)) == (   8796324739318, .none)
    expect(BCD64(      1217152688).addingWithOverflow(      23466926)) == (      1240619614, .none)
    expect(BCD64(      2287743245).addingWithOverflow(     115580675)) == (      2403323920, .none)

    expect(BCD64(     17317387770).subtractingWithOverflow(      95644713)) == (     17221743057, .none)
    expect(BCD64(       157992089).subtractingWithOverflow(     110807234)) == (        47184855, .none)
    expect(BCD64(  17592290566382).subtractingWithOverflow( 2199172283062)) == (  15393118283320, .none)
    expect(BCD64(  17592232875943).subtractingWithOverflow(    2278409876)) == (  17589954466067, .none)
    expect(BCD64(1125899927981303).subtractingWithOverflow(     152575985)) == (1125899775405318, .none)
    expect(BCD64(   8796127282511).subtractingWithOverflow(     166345501)) == (   8795960937010, .none)
    expect(BCD64( 562949987683944).subtractingWithOverflow(35184388735771)) == ( 527765598948173, .none)
    expect(BCD64(     17289744515).subtractingWithOverflow(     137909942)) == (     17151834573, .none)
    expect(BCD64(       161460981).subtractingWithOverflow(     140805976)) == (        20655005, .none)
    expect(BCD64(  70368832575119).subtractingWithOverflow(   68856751909)) == (  70299975823210, .none)
    expect(BCD64(    549863367103).subtractingWithOverflow(     136507454)) == (    549726859649, .none)
    expect(BCD64( 281475003458622).subtractingWithOverflow( 1099566706172)) == ( 280375436752450, .none)
    expect(BCD64(2251799923124430).subtractingWithOverflow(      26198162)) == (2251799896926268, .none)
    expect(BCD64(   2199082992705).subtractingWithOverflow(   68827427936)) == (   2130255564769, .none)
    expect(BCD64(      4454628945).subtractingWithOverflow(      70894583)) == (      4383734362, .none)
    expect(BCD64(1125900014063717).subtractingWithOverflow(  137461356800)) == (1125762552706917, .none)
    expect(BCD64(     34510348538).subtractingWithOverflow(    2193527085)) == (     32316821453, .none)
    expect(BCD64(   8796195360888).subtractingWithOverflow(     129378430)) == (   8796065982458, .none)
    expect(BCD64(      1217152688).subtractingWithOverflow(      23466926)) == (      1193685762, .none)
    expect(BCD64(      2287743245).subtractingWithOverflow(     115580675)) == (      2172162570, .none)

    expect(BCD64( 137518590).multipliedWithOverflow(by: 11758638)) == ( 1617031318080420, .none)
    expect(BCD64( 157992089).multipliedWithOverflow(by: 10143944)) == ( 1602662903259016, .none)
    expect(BCD64( 104526062).multipliedWithOverflow(by: 14940862)) == ( 1561709467745444, .none)
    expect(BCD64(  46835623).multipliedWithOverflow(by: 13485851)) == (  631618233270173, .none)
    expect(BCD64(  21400823).multipliedWithOverflow(by:  1581050)) == (   33835771204150, .none)
    expect(BCD64(  34262351).multipliedWithOverflow(by: 15350566)) == (  525946480340666, .none)
    expect(BCD64(  34393704).multipliedWithOverflow(by:  1966876)) == (   67648150948704, .none)
    expect(BCD64( 109875335).multipliedWithOverflow(by:  3692222)) == (  405684129144370, .none)
    expect(BCD64( 161460981).multipliedWithOverflow(by:  6588256)) == ( 1063746276839136, .none)
    expect(BCD64(  88413839).multipliedWithOverflow(by:  3061549)) == (  270683300376611, .none)
    expect(BCD64( 107553343).multipliedWithOverflow(by:  2289734)) == (  246268546280762, .none)
    expect(BCD64(  26813502).multipliedWithOverflow(by:  4812287)) == (  129034267099074, .none)
    expect(BCD64( 109963470).multipliedWithOverflow(by:  9420947)) == ( 1035960022806090, .none)
    expect(BCD64(  59737665).multipliedWithOverflow(by:  7292006)) == (  435607411605990, .none)
    expect(BCD64( 159661650).multipliedWithOverflow(by:  3785723)) == (  604434780622950, .none)
    expect(BCD64( 107483237).multipliedWithOverflow(by:  5634305)) == (  605593339645285, .none)
    expect(BCD64( 150610178).multipliedWithOverflow(by: 12489135)) == ( 1880990845416030, .none)
    expect(BCD64( 102340728).multipliedWithOverflow(by: 11937925)) == ( 1221735935309400, .none)
    expect(BCD64(1217152688).multipliedWithOverflow(by:  6689711)) == ( 8142399725593168, .none)
    expect(BCD64(2287743245).multipliedWithOverflow(by: 14917385)) == ( 4127146766814325, .overflow)

    expect(BCD64( 137518590).dividedWithOverflow(by: 11758638)) == ( 11, .none)
    expect(BCD64( 157992089).dividedWithOverflow(by: 10143944)) == ( 15, .none)
    expect(BCD64( 104526062).dividedWithOverflow(by: 14940862)) == (  6, .none)
    expect(BCD64(  46835623).dividedWithOverflow(by: 13485851)) == (  3, .none)
    expect(BCD64(  21400823).dividedWithOverflow(by:  1581050)) == ( 13, .none)
    expect(BCD64(  34262351).dividedWithOverflow(by: 15350566)) == (  2, .none)
    expect(BCD64(  34393704).dividedWithOverflow(by:  1966876)) == ( 17, .none)
    expect(BCD64( 109875335).dividedWithOverflow(by:  3692222)) == ( 29, .none)
    expect(BCD64( 161460981).dividedWithOverflow(by:  6588256)) == ( 24, .none)
    expect(BCD64(  88413839).dividedWithOverflow(by:  3061549)) == ( 28, .none)
    expect(BCD64( 107553343).dividedWithOverflow(by:  2289734)) == ( 46, .none)
    expect(BCD64(  26813502).dividedWithOverflow(by:  4812287)) == (  5, .none)
    expect(BCD64( 109963470).dividedWithOverflow(by:  9420947)) == ( 11, .none)
    expect(BCD64(  59737665).dividedWithOverflow(by:  7292006)) == (  8, .none)
    expect(BCD64( 159661650).dividedWithOverflow(by:  3785723)) == ( 42, .none)
    expect(BCD64( 107483237).dividedWithOverflow(by:  5634305)) == ( 19, .none)
    expect(BCD64( 150610178).dividedWithOverflow(by: 12489135)) == ( 12, .none)
    expect(BCD64( 102340728).dividedWithOverflow(by: 11937925)) == (  8, .none)
    expect(BCD64(1217152688).dividedWithOverflow(by:  6689711)) == (181, .none)
    expect(BCD64(2287743245).dividedWithOverflow(by: 14917385)) == (153, .none)
  }

}
