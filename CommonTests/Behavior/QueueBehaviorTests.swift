//
//  QueueTests.swift
//  QueueTests
//
//  Created by Jason Cardwell on 7/19/16.
//  Copyright © 2016 Jason Cardwell. All rights reserved.
//
import XCTest
import Nimble
@testable import MoonKit

final class QueueBehaviorTests: XCTestCase {

  func testCreation() {
    var intQueue = Queue<Int>()
    expect(intQueue.count) == 0
    expect(intQueue) == []
    expect(intQueue.underestimatedCount) == intQueue.count
    expect(intQueue.isEmpty) == true

    intQueue = Queue<Int>([])
    expect(intQueue.count) == 0
    expect(intQueue) == []
    expect(intQueue.underestimatedCount) == intQueue.count
    expect(intQueue.isEmpty) == true

    intQueue = Queue<Int>([1, 2, 3, 4])
    expect(intQueue.count) == 4
    expect(intQueue) == [1, 2, 3, 4]
    expect(intQueue.underestimatedCount) == intQueue.count
    expect(intQueue.isEmpty) == false

    intQueue = [1, 2, 3, 4]
    expect(intQueue.count) == 4
    expect(intQueue) == [1, 2, 3, 4]
    expect(intQueue.underestimatedCount) == intQueue.count
    expect(intQueue.isEmpty) == false

    intQueue = Queue<Int>(minimumCapacity: 100)
    expect(intQueue.count) == 0
    expect(intQueue.capacity) >= 100
    expect(intQueue) == []
    expect(intQueue.underestimatedCount) == intQueue.count
    expect(intQueue.isEmpty) == true

    var stringQueue = Queue<String>()
    expect(stringQueue.count) == 0
    expect(stringQueue) == []
    expect(stringQueue.underestimatedCount) == stringQueue.count
    expect(stringQueue.isEmpty) == true

    stringQueue = Queue<String>([])
    expect(stringQueue.count) == 0
    expect(stringQueue) == []
    expect(stringQueue.underestimatedCount) == stringQueue.count
    expect(stringQueue.isEmpty) == true

    stringQueue = Queue<String>(["one", "two", "three", "four"])
    expect(stringQueue.count) == 4
    expect(stringQueue) == ["one", "two", "three", "four"]
    expect(stringQueue.underestimatedCount) == stringQueue.count
    expect(stringQueue.isEmpty) == false

    stringQueue = ["one", "two", "three", "four"]
    expect(stringQueue.count) == 4
    expect(stringQueue) == ["one", "two", "three", "four"]
    expect(stringQueue.underestimatedCount) == stringQueue.count
    expect(stringQueue.isEmpty) == false

    stringQueue = Queue<String>(minimumCapacity: 100)
    expect(stringQueue.count) == 0
    expect(stringQueue.capacity) >= 100
    expect(stringQueue) == []
    expect(stringQueue.underestimatedCount) == stringQueue.count
    expect(stringQueue.isEmpty) == true
  }

  func testEnqueueAndCow() {
    var intQueue1 = Queue<Int>(minimumCapacity: 4)
    expect(intQueue1.count) == 0
    expect(intQueue1) == []

    intQueue1.enqueue(1)
    expect(intQueue1.count) == 1
    expect(intQueue1).to(equal([1]))

    intQueue1.enqueue(2)
    expect(intQueue1.count) == 2
    expect(intQueue1) == [1, 2]

    intQueue1.enqueue(3)
    expect(intQueue1.count) == 3
    expect(intQueue1) == [1, 2, 3]

    intQueue1.enqueue(4)
    expect(intQueue1.count) == 4
    expect(intQueue1) == [1, 2, 3, 4]

    intQueue1.enqueue(5)
    expect(intQueue1.count) == 5
    expect(intQueue1) == [1, 2, 3, 4, 5]

    var intQueue2 = intQueue1
    expect(intQueue2.count) == intQueue1.count
    expect(intQueue2.capacity) == intQueue1.capacity
    expect(intQueue2) == intQueue1

    intQueue2.enqueue(6)
    expect(intQueue2.count) == 6
    expect(intQueue2) == [1, 2, 3, 4, 5, 6]
    expect(intQueue1.count) == 5
    expect(intQueue1) == [1, 2, 3, 4, 5]

    var intQueue3 = Queue<Int>()
    intQueue3.enqueue(1)

    let intQueue4 = intQueue3
    expect(intQueue3) == [1]
    expect(intQueue4 == intQueue3) == true

    intQueue3.enqueue(2)
    expect(intQueue3) == [1, 2]
    expect(intQueue3 == intQueue4) == false

    var stringQueue1 = Queue<String>(minimumCapacity: 4)
    expect(stringQueue1.count) == 0
    expect(stringQueue1) == []

    stringQueue1.enqueue("one")
    expect(stringQueue1.count) == 1
    expect(stringQueue1) == ["one"]

    stringQueue1.enqueue("two")
    expect(stringQueue1.count) == 2
    expect(stringQueue1) == ["one", "two"]

    stringQueue1.enqueue("three")
    expect(stringQueue1.count) == 3
    expect(stringQueue1) == ["one", "two", "three"]

    stringQueue1.enqueue("four")
    expect(stringQueue1.count) == 4
    expect(stringQueue1) == ["one", "two", "three", "four"]

    stringQueue1.enqueue("five")
    expect(stringQueue1.count) == 5
    expect(stringQueue1) == ["one", "two", "three", "four", "five"]

    var stringQueue2 = stringQueue1
    expect(stringQueue2.count) == stringQueue1.count
    expect(stringQueue2.capacity) == stringQueue1.capacity
    expect(stringQueue2) == stringQueue1

    stringQueue2.enqueue("six")
    expect(stringQueue2.count) == 6
    expect(stringQueue2) == ["one", "two", "three", "four", "five", "six"]
    expect(stringQueue1.count) == 5
    expect(stringQueue1) == ["one", "two", "three", "four", "five"]

    var stringQueue3 = Queue<String>()
    stringQueue3.enqueue("one")

    let stringQueue4 = stringQueue3
    expect(stringQueue3) == ["one"]
    expect(stringQueue4 == stringQueue3) == true

    stringQueue3.enqueue("two")
    expect(stringQueue3) == ["one", "two"]
    expect(stringQueue3 == stringQueue4) == false
    
  }

  func testDequeueAndPeekAndCow() {
    var intQueue1 = Queue<Int>([1, 2, 3, 4, 5])
    expect(intQueue1.count) == 5
    expect(intQueue1) == [1, 2, 3, 4, 5]
    expect(intQueue1.peek) == 1

    expect(intQueue1.dequeue()) == 1
    expect(intQueue1.count) == 4
    expect(intQueue1) == [2, 3, 4, 5]
    expect(intQueue1.peek) == 2

    expect(intQueue1.dequeue()) == 2
    expect(intQueue1.count) == 3
    expect(intQueue1) == [3, 4, 5]
    expect(intQueue1.peek) == 3

    expect(intQueue1.dequeue()) == 3
    expect(intQueue1.count) == 2
    expect(intQueue1) == [4, 5]
    expect(intQueue1.peek) == 4

    var intQueue2 = intQueue1

    expect(intQueue2.dequeue()) == 4
    expect(intQueue2.count) == 1
    expect(intQueue2) == [5]
    expect(intQueue2.peek) == 5

    expect(intQueue2.dequeue()) == 5
    expect(intQueue2.count) == 0
    expect(intQueue2) == []
    expect(intQueue2.peek).to(beNil())

    expect(intQueue2.dequeue()).to(beNil())
    expect(intQueue2.count) == 0
    expect(intQueue2) == []
    expect(intQueue2.peek).to(beNil())

    expect(intQueue1.count) == 2
    expect(intQueue1) == [4, 5]
    expect(intQueue1.peek) == 4

    var stringQueue1 = Queue<String>(["one", "two", "three", "four", "five"])
    expect(stringQueue1.count) == 5
    expect(stringQueue1) == ["one", "two", "three", "four", "five"]
    expect(stringQueue1.peek) == "one"

    expect(stringQueue1.dequeue()) == "one"
    expect(stringQueue1.count) == 4
    expect(stringQueue1) == ["two", "three", "four", "five"]
    expect(stringQueue1.peek) == "two"

    expect(stringQueue1.dequeue()) == "two"
    expect(stringQueue1.count) == 3
    expect(stringQueue1) == ["three", "four", "five"]
    expect(stringQueue1.peek) == "three"

    expect(stringQueue1.dequeue()) == "three"
    expect(stringQueue1.count) == 2
    expect(stringQueue1) == ["four", "five"]
    expect(stringQueue1.peek) == "four"

    var stringQueue2 = stringQueue1

    expect(stringQueue2.dequeue()) == "four"
    expect(stringQueue2.count) == 1
    expect(stringQueue2) == ["five"]
    expect(stringQueue2.peek) == "five"

    expect(stringQueue2.dequeue()) == "five"
    expect(stringQueue2.count) == 0
    expect(stringQueue2) == []
    expect(stringQueue2.peek).to(beNil())

    expect(stringQueue2.dequeue()).to(beNil())
    expect(stringQueue2.count) == 0
    expect(stringQueue2) == []
    expect(stringQueue2.peek).to(beNil())

    expect(stringQueue1.count) == 2
    expect(stringQueue1) == ["four", "five"]
    expect(stringQueue1.peek) == "four"
 }

  func testEquality() {
    let intQueue1 = Queue<Int>([1, 2, 3])
    let intQueue2 = Queue<Int>([1, 2])
    let intQueue3 = Queue<Int>([1, 2, 3])

    expect(intQueue1 == intQueue1) == true
    expect(intQueue1 == intQueue2) == false
    expect(intQueue1 == intQueue3) == true

    let stringQueue1 = Queue<String>(["one", "two", "three"])
    let stringQueue2 = Queue<String>(["one", "two"])
    let stringQueue3 = Queue<String>(["one", "two", "three"])

    expect(stringQueue1 == stringQueue1) == true
    expect(stringQueue1 == stringQueue2) == false
    expect(stringQueue1 == stringQueue3) == true

  }

  func testReverseAndCow() {
    let intQueue1 = Queue<Int>([1, 2, 3, 4, 5])
    expect(intQueue1) == [1, 2, 3, 4, 5]

    let intQueue2 = intQueue1.reversed()
    expect(intQueue2) == [5, 4, 3, 2, 1]

    var intQueue3 = intQueue2
    expect(intQueue3) == [5, 4, 3, 2, 1]

    intQueue3.reverse()
    expect(intQueue3) == [1, 2, 3, 4, 5]
    expect(intQueue2) == [5, 4, 3, 2, 1]

    // dequeue and enqueue to force tail to wrap around such that tail < head

    expect(intQueue3.dequeue()) == 1
    expect(intQueue3.dequeue()) == 2
    expect(intQueue3.dequeue()) == 3
    intQueue3.enqueue(1)
    intQueue3.enqueue(2)
    intQueue3.enqueue(3)
    expect(intQueue3) == [4, 5, 1, 2, 3]
    intQueue3.reverse()
    expect(intQueue3) == [3, 2, 1, 5, 4]

    var intQueue4 = intQueue3
    intQueue4.reverse()
    expect(intQueue4) == [4, 5, 1, 2, 3]
    expect(intQueue3) == [3, 2, 1, 5, 4]

    intQueue4.reserveCapacity(minimumCapacity: 20)
    intQueue4.reverse()
    expect(intQueue4 == intQueue3) == true

    var intQueue5 = Queue<Int>([1])
    intQueue5.reverse()
    expect(intQueue5) == [1]

    let stringQueue1 = Queue<String>(["one", "two", "three", "four", "five"])
    expect(stringQueue1) == ["one", "two", "three", "four", "five"]

    let stringQueue2 = stringQueue1.reversed()
    expect(stringQueue2) == ["five", "four", "three", "two", "one"]

    var stringQueue3 = stringQueue2
    expect(stringQueue3) == ["five", "four", "three", "two", "one"]

    stringQueue3.reverse()
    expect(stringQueue3) == ["one", "two", "three", "four", "five"]
    expect(stringQueue2) == ["five", "four", "three", "two", "one"]

    // dequeue and enqueue to force tail to wrap around such that tail < head

    expect(stringQueue3.dequeue()) == "one"
    expect(stringQueue3.dequeue()) == "two"
    expect(stringQueue3.dequeue()) == "three"
    stringQueue3.enqueue("one")
    stringQueue3.enqueue("two")
    stringQueue3.enqueue("three")
    expect(stringQueue3) == ["four", "five", "one", "two", "three"]
    stringQueue3.reverse()
    expect(stringQueue3) == ["three", "two", "one", "five", "four"]

    var stringQueue4 = stringQueue3
    stringQueue4.reverse()
    expect(stringQueue4) == ["four", "five", "one", "two", "three"]
    expect(stringQueue3) == ["three", "two", "one", "five", "four"]

    stringQueue4.reserveCapacity(minimumCapacity: 20)
    stringQueue4.reverse()
    expect(stringQueue4 == stringQueue3) == true

    var stringQueue5 = Queue<String>(["one"])
    stringQueue5.reverse()
    expect(stringQueue5) == ["one"]
  }

  func testDescription() {
    expect(Queue([1, 2, 3]).description) == "[1, 2, 3]"
    expect(Queue([1, 2, 3]).debugDescription) == "[1, 2, 3]"
    expect(Queue<Int>().description) == "[]"
    expect(Queue<Int>().debugDescription) == "[]"
  }

}
