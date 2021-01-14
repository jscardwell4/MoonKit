//
//  Bytes.swift
//  MoonKit
//
//  Created by Jason Cardwell on 11/8/15.
//  Copyright © 2015 Jason Cardwell. All rights reserved.
//
import Foundation

// MARK: - ByteArrayConvertible

public protocol ByteArrayConvertible: Equatable, DataConvertible {
  var bytes: [UInt8] { get }
  init(bytes: [UInt8])
  init<S: Sequence>(bytes: S) where S.Iterator.Element == UInt8
}

public extension ByteArrayConvertible {
  var data: Data {
    return bytes.withUnsafeBufferPointer { Data(bytes: $0.baseAddress!, count: $0.count) }
  }

  init?(data: Data) {
    self.init(bytes: data)
  }

  init?(coder: NSCoder) {
    guard let bytes = coder.decodeData() else { return nil }
    self.init(bytes: bytes)
  }

  func encodeWithCoder(_ coder: NSCoder) {
    bytes.withUnsafeBufferPointer { coder.encode(Data(buffer: $0)) }
  }

  init<S: Sequence>(bytes: S) where S.Iterator.Element == UInt8 {
    self.init(bytes: Array(bytes))
  }
}

public func == <B: ByteArrayConvertible>(lhs: B, rhs: B) -> Bool {
  let leftBytes = lhs.bytes, rightBytes = rhs.bytes
  guard leftBytes.count == rightBytes.count else { return false }
  for (leftByte, rightByte) in zip(leftBytes, rightBytes) {
    guard leftByte == rightByte else { return false }
  }
  return true
}

private func _bytes<T>(_ value: T) -> [UInt8] {
  var value = value
  return withUnsafeBytes(of: &value) { Array($0.reversed()) }
}

// MARK: - UInt + ByteArrayConvertible

extension UInt: ByteArrayConvertible {
  public var bytes: [UInt8] { return _bytes(self) }
  public init(bytes: [UInt8]) {
    self = MemoryLayout<UInt>.size == 8 ? UInt(UInt64(bytes: bytes)) : UInt(UInt32(bytes: bytes))
  }
}

// MARK: - Int + ByteArrayConvertible

extension Int: ByteArrayConvertible {
  public var bytes: [UInt8] { return _bytes(self) }
  public init<S: Sequence>(bytes: S) where S.Iterator.Element == UInt8 { self = Int(UInt(bytes: bytes)) }
}

// MARK: - UInt8 + ByteArrayConvertible

extension UInt8: ByteArrayConvertible {
  public var bytes: [UInt8] { return _bytes(self) }
  public init(bytes: [UInt8]) {
    guard let byte = bytes.first else { self = 0; return }
    self = byte
  }
}

// MARK: - Int8 + ByteArrayConvertible

extension Int8: ByteArrayConvertible {
  public var bytes: [UInt8] { return _bytes(self) }
  public init(bytes: [UInt8]) { self = Int8(UInt8(bytes: bytes)) }
}

// MARK: - UInt16 + ByteArrayConvertible

extension UInt16: ByteArrayConvertible {
  public var bytes: [UInt8] { return _bytes(self) }
  public init(bytes: [UInt8]) {
    let count = bytes.count
    guard count < 3 else { self = UInt16(bytes: bytes[count - 2 ..< count]); return }
    switch bytes.count {
    case 2:
      self = UInt16(bytes[0]) << 8 | UInt16(bytes[1])
    case 1:
      self = UInt16(bytes[0])
    default:
      self = 0
    }
  }
}

// MARK: - Int16 + ByteArrayConvertible

extension Int16: ByteArrayConvertible {
  public var bytes: [UInt8] { return _bytes(self) }
  public init(bytes: [UInt8]) { self = Int16(UInt16(bytes: bytes)) }
}

// MARK: - UInt32 + ByteArrayConvertible

extension UInt32: ByteArrayConvertible {
  public var bytes: [UInt8] { return _bytes(self) }
  public init(bytes: [UInt8]) {
    let count = bytes.count
    guard count > 2 else { self = UInt32(UInt16(bytes: bytes)); return }

    let upper = UInt32(UInt16(bytes: bytes[0 ..< (count - 2)])) << 16
    let lower = UInt32(bytes: bytes[(count - 2) ..< count])

    self = upper | lower
  }
}

// MARK: - Int32 + ByteArrayConvertible

extension Int32: ByteArrayConvertible {
  public var bytes: [UInt8] { return _bytes(self) }
  public init(bytes: [UInt8]) { self = Int32(UInt32(bytes: bytes)) }
}

// MARK: - UInt64 + ByteArrayConvertible

extension UInt64: ByteArrayConvertible {
  public var bytes: [UInt8] { return _bytes(self) }
  public init(bytes: [UInt8]) {
    let count = bytes.count
    guard count > 4 else { self = UInt64(UInt32(bytes: bytes)); return }
    self = UInt64(UInt32(bytes: bytes[0 ..< count - 4])) << 32
      | UInt64(UInt32(bytes: bytes[count - 4 ..< count]))
  }
}

// MARK: - Int64 + ByteArrayConvertible

extension Int64: ByteArrayConvertible {
  public var bytes: [UInt8] { _bytes(self) }
  public init(bytes: [UInt8]) { self = Int64(UInt64(bytes: bytes)) }
}

// MARK: - String + ByteArrayConvertible

extension String: ByteArrayConvertible {
  public var bytes: [UInt8] {
    return Array(utf8)
  }


  public init(bytes: [UInt8]) {
    let endIndex = bytes.firstIndex(of: 0) ?? bytes.endIndex
    let scalars = String.UnicodeScalarView(bytes[..<endIndex].map(UnicodeScalar.init))
    self = String(scalars)
  }
}
