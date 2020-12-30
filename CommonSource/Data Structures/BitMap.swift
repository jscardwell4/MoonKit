//
//  BitMap.swift
//  MoonKit
//
//  Created by Jason Cardwell on 2/19/16.
//  Copyright © 2016 Jason Cardwell. All rights reserved.
//

import Foundation

/// A wrapper around a bitmap storage with room for at least bitCount bits.
/// This is a modified version of the `_BitMap` struct found in the swift stdlib source code
public struct BitMap: Collection {
  public typealias Element = Bool
  public typealias _Element = Element

  public let buffer: UnsafeMutableBufferPointer<UInt>
  public static func wordIndex(_ i: Int) -> Int { return i / Int(UInt.bitWidth) }

  public static func bitIndex(_ i: Int) -> Int { return i % Int(UInt.bitWidth) }

  public static func wordsFor(_ bitCount: Int) -> Int {
    let totalWords = (bitCount + Int.bitWidth - 1) / Int.bitWidth
    return totalWords
  }

  public let count: Int

  public var nonZeroCount: Int {
    defer { _fixLifetime(self) }
    var result = 0
    for word in buffer where word > 0 {
      for bit in 0 ..< UInt.bitWidth where word & (1 << bit) != 0 {
        result += 1
      }
    }
    return result
  }

  public init(initializedStorage storage: UnsafeMutablePointer<UInt>, bitCount: Int) {
    count = bitCount
    buffer = UnsafeMutableBufferPointer(start: storage, count: BitMap.wordsFor(bitCount))
  }

  public init(uninitializedStorage storage: UnsafeMutablePointer<UInt>, bitCount: Int) {
    count = bitCount
    buffer = UnsafeMutableBufferPointer(start: storage, count: BitMap.wordsFor(bitCount))
    initializeToZero()
  }

  public var numberOfWords: Int { return buffer.count }

  public func initializeToZero() { for i in 0 ..< numberOfWords { buffer[i] = 0 } }
  public func initializeToOne() { for i in 0 ..< numberOfWords { buffer[i] = UInt.max } }

  public var firstSetBit: Int? { return nextSetBit(-1) }

  public func nextSetBit(_ start: Int) -> Int? {
    defer { _fixLifetime(self) }
    let numberOfWords = self.numberOfWords
    let bitsPerWord = Int(UInt.bitWidth)
    var bitIndex: Int, wordIndex: Int

    switch start {
      case let s where s < 0: bitIndex = 0; wordIndex = 0
      case let s where s == bitsPerWord - 1: bitIndex = 0; wordIndex = BitMap.wordIndex(s) + 1
      default: bitIndex = BitMap.bitIndex(start + 1); wordIndex = BitMap.wordIndex(start + 1)
    }

    while wordIndex < numberOfWords {
      let word = buffer[wordIndex]
      guard word > 0 else {
        wordIndex += 1
        bitIndex = 0
        continue
      }
      let bitRange = bitIndex ..< (bitsPerWord - word.leadingZeroBitCount)
      for i in bitRange where word & (1 << UInt(i)) != 0 {
        return wordIndex * bitsPerWord + i
      }
      wordIndex += 1
      bitIndex = 0
    }

    return nil
  }

  public var lastSetBit: Int? { return previousSetBit(count) }

  public func previousSetBit(_ start: Int) -> Int? {
    defer { _fixLifetime(self) }
    let bitsPerWord = Int(UInt.bitWidth)
    var bitIndex: Int, wordIndex: Int

    switch start {
      case count: bitIndex = bitsPerWord - 1; wordIndex = numberOfWords - 1
      case let s where BitMap.bitIndex(s) == 0: bitIndex = bitsPerWord - 1; wordIndex = BitMap.wordIndex(s) - 1
      default: bitIndex = BitMap.bitIndex(start - 1); wordIndex = BitMap.wordIndex(start - 1)
    }

    while wordIndex > -1 {
      let word = buffer[wordIndex]
      guard word > 0 else {
        wordIndex -= 1
        bitIndex = bitsPerWord - 1
        continue
      }
      
      for i in (0 ... bitIndex).reversed() where word & (1 << UInt(i)) != 0 {
        return wordIndex * bitsPerWord + i
      }
      wordIndex -= 1
      bitIndex = bitsPerWord - 1
    }

    return nil
  }

  public var nonZeroBits: [Int] {
    defer { _fixLifetime(self) }
    var result: [Int] = []
    let bitsPerWord = Int(UInt.bitWidth)
    for (wordIndex, word) in buffer.enumerated() where word > 0 {
      let bitRange = 0 ..< (bitsPerWord - word.leadingZeroBitCount)
      for bitIndex in bitRange where self[wordIndex * bitsPerWord + bitIndex] {
        result.append(wordIndex * bitsPerWord + bitIndex)
      }
    }
    return result
  }

  public typealias Index = Int

  public var startIndex: Index { return 0 }
  public var endIndex: Index { return count }

  public subscript(position: Index) -> _Element {
    get {
      defer { _fixLifetime(self) }
      precondition(position < count && position >= 0, "invalid offset: \(position)")
      return buffer[BitMap.wordIndex(position)] & (1 << UInt(BitMap.bitIndex(position))) != 0
    }
    nonmutating set {
      defer { _fixLifetime(self) }
      precondition(position < count && position >= 0, "invalid offset: \(position)")
      let wordIndex = BitMap.wordIndex(position)
      let bitIndex = UInt(BitMap.bitIndex(position))
      let word = buffer[wordIndex]
      buffer[wordIndex] = newValue ? word | (1 << bitIndex) : word & ~(1 << bitIndex)
    }
  }

  public func index(after i: Index) -> Index {
    return i + 1
  }

  public func formIndex(after i: inout Index) {
    i += 1
  }

  public typealias IndexDistance = Int

  public func index(_ i: Index, offsetBy n: IndexDistance) -> Index {
    return i + n
  }

  public func index(_ i: Index, offsetBy n: IndexDistance, limitedBy limit: Index) -> Index? {
    let possibleIndex = i + n
    return possibleIndex < limit ? possibleIndex : nil
  }

  public func formIndex(_ i: inout Index, offsetBy n: IndexDistance) {
    i += n
  }

  public func formIndex(_ i: inout Index, offsetBy n: IndexDistance, limitedBy limit: Index) -> Bool {
    let possibleIndex = i + n
    if possibleIndex < limit { i = possibleIndex; return true }
    else { return false }
  }

  public func distance(from start: Index, to end: Index) -> IndexDistance {
    return end - start
  }
}

extension BitMap: CustomStringConvertible {
  public var description: String {
    var result = "(total words: \(numberOfWords); total bits: \(count))\n"
    result += buffer.enumerated().map({
      "word \($0): \("0" * $1.leadingZeroBitCount)\(String($1, radix: 2))"
    }).joined(separator: "\n")

    return result
  }
}
