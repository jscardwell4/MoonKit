//
//  StackBehaviorTests.swift
//  StackBehaviorTests
//
//  Created by Jason Cardwell on 6/13/16.
//  Copyright © 2016 Jason Cardwell. All rights reserved.
//
import XCTest
import Nimble
@testable import MoonKit

final class StackBehaviorTests: XCTestCase {

  func testCreation() {
    let stack1 = Stack<Int>()
    expect(stack1.count) == 0
    expect(stack1.underestimatedCount) == 0
    expect(stack1.capacity) == 0
    expect(stack1.isEmpty) == true
    expect(stack1) == []

    let stack2 = Stack<Int>([1, 2, 3, 4])
    expect(stack2.count) == 4
    expect(stack2.underestimatedCount) == 4
    expect(stack2.capacity) == 4
    expect(stack2.isEmpty) == false
    expect(stack2) == [4, 3, 2, 1]

    let stack3 = Stack<Int>(minimumCapacity: 100)
    expect(stack3.count) == 0
    expect(stack3.underestimatedCount) == 0
    expect(stack3.capacity) == 100
    expect(stack3.isEmpty) == true
    expect(stack3) == []

    let stack4 = Stack<String>()
    expect(stack4.count) == 0
    expect(stack4.underestimatedCount) == 0
    expect(stack4.capacity) == 0
    expect(stack4.isEmpty) == true
    expect(stack4) == []

    let stack5: Stack<String> = ["one", "two", "three", "four"]
    expect(stack5.count) == 4
    expect(stack5.underestimatedCount) == 4
    expect(stack5.capacity) == 4
    expect(stack5.isEmpty) == false
    expect(stack5) == ["four", "three", "two", "one"]

    let stack6 = Stack<String>(minimumCapacity: 100)
    expect(stack6.count) == 0
    expect(stack6.underestimatedCount) == 0
    expect(stack6.capacity) >= 100
    expect(stack6.isEmpty) == true
    expect(stack6) == []
  }

  func testPushAndCow() {
    var stack1 = Stack<Int>(minimumCapacity: 4)
    expect(stack1.count) == 0
    expect(stack1.capacity) == 4
    expect(stack1) == []

    stack1.push(1)
    expect(stack1.count) == 1
    expect(stack1.capacity) == 4
    expect(stack1) == [1]

    stack1.push(2)
    expect(stack1.count) == 2
    expect(stack1.capacity) == 4
    expect(stack1) == [2, 1]

    stack1.push(3)
    expect(stack1.count) == 3
    expect(stack1.capacity) == 4
    expect(stack1) == [3, 2, 1]

    stack1.push(4)
    expect(stack1.count) == 4
    expect(stack1.capacity) == 4
    expect(stack1) == [4, 3, 2, 1]

    stack1.push(5)
    expect(stack1.count) == 5
    expect(stack1.capacity) == 8
    expect(stack1) == [5, 4, 3, 2, 1]

    var stack2 = stack1
    expect(stack2.count) == stack1.count
    expect(stack2.capacity) == stack1.capacity
    expect(stack2) == stack1

    stack2.push(6)
    expect(stack2.count) == 6
    expect(stack2.capacity) == 10
    expect(stack2) == [6, 5, 4, 3, 2, 1]
    expect(stack1.count) == 5
    expect(stack1.capacity) == 8
    expect(stack1) == [5, 4, 3, 2, 1]

    var stack3 = Stack<String>(minimumCapacity: 4)
    expect(stack3.count) == 0
    expect(stack3.capacity) == 4
    expect(stack3) == []

    stack3.push("one")
    expect(stack3.count) == 1
    expect(stack3.capacity) == 4
    expect(stack3) == ["one"]

    stack3.push("two")
    expect(stack3.count) == 2
    expect(stack3.capacity) == 4
    expect(stack3) == ["two", "one"]

    stack3.push("three")
    expect(stack3.count) == 3
    expect(stack3.capacity) == 4
    expect(stack3) == ["three", "two", "one"]

    stack3.push("four")
    expect(stack3.count) == 4
    expect(stack3.capacity) == 4
    expect(stack3) == ["four", "three", "two", "one"]

    stack3.push("five")
    expect(stack3.count) == 5
    expect(stack3.capacity) == 8
    expect(stack3) == ["five", "four", "three", "two", "one"]

    var stack4 = stack3
    expect(stack4.count) == stack3.count
    expect(stack4.capacity) == stack3.capacity
    expect(stack4) == stack3

    stack4.push("six")
    expect(stack4.count) == 6
    expect(stack4.capacity) == 10
    expect(stack4) == ["six", "five", "four", "three", "two", "one"]
    expect(stack3.count) == 5
    expect(stack3.capacity) == 8
    expect(stack3) == ["five", "four", "three", "two", "one"]
  }

  func testPopAndPeekAndCow() {
    var stack1 = Stack<Int>([1, 2, 3, 4, 5])
    expect(stack1.count) == 5
    expect(stack1.capacity) == 6
    expect(stack1) == [5, 4, 3, 2, 1]
    expect(stack1.peek) == 5

    expect(stack1.pop()) == 5
    expect(stack1.count) == 4
    expect(stack1.capacity) == 6
    expect(stack1) == [4, 3, 2, 1]
    expect(stack1.peek) == 4

    expect(stack1.pop()) == 4
    expect(stack1.count) == 3
    expect(stack1.capacity) == 6
    expect(stack1) == [3, 2, 1]
    expect(stack1.peek) == 3

    expect(stack1.pop()) == 3
    expect(stack1.count) == 2
    expect(stack1.capacity) == 6
    expect(stack1) == [2, 1]
    expect(stack1.peek) == 2

    var stack2 = stack1

    expect(stack2.pop()) == 2
    expect(stack2.count) == 1
    expect(stack2.capacity) == 6
    expect(stack2) == [1]
    expect(stack2.peek) == 1

    expect(stack2.pop()) == 1
    expect(stack2.count) == 0
    expect(stack2.capacity) == 6
    expect(stack2) == []
    expect(stack2.peek).to(beNil())

    expect(stack2.pop()).to(beNil())
    expect(stack2.count) == 0
    expect(stack2.capacity) == 6
    expect(stack2) == []
    expect(stack2.peek).to(beNil())

    expect(stack1.count) == 2
    expect(stack1.capacity) == 6
    expect(stack1) == [2, 1]
    expect(stack1.peek) == 2

    var stack3 = Stack<String>(["one", "two", "three", "four", "five"])
    expect(stack3.count) == 5
    expect(stack3.capacity) == 5
    expect(stack3) == ["five", "four", "three", "two", "one"]
    expect(stack3.peek) == "five"

    expect(stack3.pop()) == "five"
    expect(stack3.count) == 4
    expect(stack3.capacity) == 5
    expect(stack3) == ["four", "three", "two", "one"]
    expect(stack3.peek) == "four"

    expect(stack3.pop()) == "four"
    expect(stack3.count) == 3
    expect(stack3.capacity) == 5
    expect(stack3) == ["three", "two", "one"]
    expect(stack3.peek) == "three"

    expect(stack3.pop()) == "three"
    expect(stack3.count) == 2
    expect(stack3.capacity) == 5
    expect(stack3) == ["two", "one"]
    expect(stack3.peek) == "two"

    var stack4 = stack3

    expect(stack4.pop()) == "two"
    expect(stack4.count) == 1
    expect(stack4.capacity) == 5
    expect(stack4) == ["one"]
    expect(stack4.peek) == "one"

    expect(stack4.pop()) == "one"
    expect(stack4.count) == 0
    expect(stack4.capacity) == 5
    expect(stack4) == []
    expect(stack4.peek).to(beNil())

    expect(stack4.pop()).to(beNil())
    expect(stack4.count) == 0
    expect(stack4.capacity) == 5
    expect(stack4) == []
    expect(stack4.peek).to(beNil())

    expect(stack3.count) == 2
    expect(stack3.capacity) == 5
    expect(stack3) == ["two", "one"]
    expect(stack3.peek) == "two"
 }

  func testEquatable() {
    let stack1 = Stack<Int>([1, 2, 3, 4, 5])
    let stack2 = Stack<Int>([1, 2, 3, 4, 5])
    let stack3 = Stack<Int>([5, 4, 3, 2, 1])
    let stack4 = Stack<Int>()
    let stack5 = Stack<Int>([22, 11, 00])

    expect(stack1 == stack2) == true
    expect(stack1 == stack3) == false
    expect(stack1 == stack4) == false
    expect(stack1 == stack5) == false
    expect(stack1 == stack1) == true
    expect(stack2 == stack1) == true
  }

  func testReverseAndCow() {
    let stack1 = Stack<Int>([1, 2, 3, 4, 5])
    expect(stack1) == [5, 4, 3, 2, 1]

    let stack2 = stack1.reversed()
    expect(stack2) == [1, 2, 3, 4, 5]

    var stack3 = stack2
    expect(stack3) == [1, 2, 3, 4, 5]

    stack3.reverse()
    expect(stack3) == [5, 4, 3, 2, 1]
    expect(stack2) == [1, 2, 3, 4, 5]

    let stack4 = Stack<String>(["one", "two", "three", "four", "five"])
    expect(stack4) == ["five", "four", "three", "two", "one"]

    let stack5 = stack4.reversed()
    expect(stack5) == ["one", "two", "three", "four", "five"]

    var stack6 = stack5
    expect(stack6) == ["one", "two", "three", "four", "five"]

    stack6.reverse()
    expect(stack6) == ["five", "four", "three", "two", "one"]
    expect(stack5) == ["one", "two", "three", "four", "five"]

    var stack7 = Stack<Int>([1])
    stack7.reverse()
    expect(stack7) == [1]
  }

}
