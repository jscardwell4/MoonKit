//
//  Protocols.swift
//  MoonKit
//
//  Created by Jason Cardwell on 11/17/14.
//  Copyright (c) 2014 Jason Cardwell. All rights reserved.
//

import Foundation
// import SpriteKit
import Swift
import UIKit

// MARK: - PrettyPrint

public protocol PrettyPrint { var prettyDescription: String { get } }

// MARK: - Valued

public protocol Valued
{
  associatedtype ValueType
  var value: ValueType { get }
}

// MARK: - IntValued

public protocol IntValued
{
  var value: Int { get }
}

public func withWeakReferenceToObject<T: AnyObject, U, R>(
  _ object: T?,
  body: @escaping (T?, U) -> R
) -> (U) -> R
{
  return { [weak object] in body(object, $0) }
}

public extension NSObject
{
  func withWeakReference<T: NSObject, U, R>(_ body: @escaping (T?, U) -> R) -> (U) -> R
  {
    return withWeakReferenceToObject(self as? T, body: body)
  }
}

// MARK: - JSONExport

// extension GCDAsyncUdpSocketError: Error {}

// public protocol ArithmeticType {
//  static func +(lhs: Self, rhs: Self) -> Self
//  static func -(lhs: Self, rhs: Self) -> Self
//  static func *(lhs: Self, rhs: Self) -> Self
//  static func /(lhs: Self, rhs: Self) -> Self
//  static func %(lhs: Self, rhs: Self) -> Self
//  static func %=(lhs: inout Self, rhs: Self)
////  func toIntMax() -> IntMax
////  init(intMax: IntMax)
//  init()
//  var isZero: Bool { get }
// }
//
// extension ArithmeticType where Self:BitwiseOperations, Self:Equatable {
//  public var isZero: Bool { return self == Self.allZeros }
// }

public protocol JSONExport
{
  var jsonString: String { get }
}

// MARK: - KeyValueCollectionType

public protocol KeyValueCollectionType: Collection
{
  associatedtype Key: Hashable
  associatedtype Value
  subscript(key: Key) -> Value? { get }
  associatedtype KeysType: Collection
  associatedtype ValuesType: Collection
  var keys: KeysType { get }
  var values: ValuesType { get }
}

// MARK: - KeyedContainer

public protocol KeyedContainer
{
  associatedtype Key: Hashable
  func hasKey(_ key: Key) -> Bool
  func valueForKey(_ key: Key) -> Any?
}

// MARK: - KeySearchable

public protocol KeySearchable
{
  var allValues: [Any] { get }
}

// MARK: - NestingContainer

public protocol NestingContainer
{
  var topLevelObjects: [Any] { get }
  func topLevelObjects<T>(_ type: T.Type) -> [T]
  var allObjects: [Any] { get }
  func allObjects<T>(_ type: T.Type) -> [T]
}

// MARK: - Dictionary + KeyValueCollectionType

extension Dictionary: KeyValueCollectionType {}

// MARK: - Presentable

public protocol Presentable
{
  var title: String { get }
}

// MARK: - EnumerableType

public protocol EnumerableType
{
  static var allCases: [Self] { get }
}

public extension EnumerableType
{
  static subscript(position: Int) -> Self { allCases[position] }
}

public extension EnumerableType where Self: Equatable
{
  var index: Int
  {
    guard let index = Self.allCases.firstIndex(of: self)
    else { fatalError("`allCases` does not contain \(self)") }
    return index
  }

  init(index: Int)
  {
    guard Self.allCases.indices.contains(index) else { fatalError("index out of bounds") }
    self = Self.allCases[index]
  }
}

public extension CaseIterable where Self.AllCases == [Self], Self: Equatable
{
  var index: Int
  {
    guard let index = Self.allCases.firstIndex(of: self)
    else { fatalError("`allCases` does not contain \(self)") }
    return index
  }

  init(index: Int)
  {
    guard Self.allCases.indices.contains(index) else { fatalError("index out of bounds") }
    self = Self.allCases[index]
  }
}

// MARK: - KeyType

public protocol KeyType: RawRepresentable, Hashable
{
  var key: String { get }
}

public extension KeyType where Self.RawValue == String
{
  var key: String { return rawValue }
  var hashValue: Int { return rawValue.hashValue }
}

public func == <K: KeyType>(lhs: K, rhs: K) -> Bool { return lhs.key == rhs.key }

public extension EnumerableType
{
  static func enumerate(_ block: (Self) -> Void) { allCases.forEach(block) }
}

#if os(iOS)
public protocol ImageAssetLiteralType
{
  var image: UIImage { get }
}

public extension ImageAssetLiteralType where Self: RawRepresentable,
                                             Self.RawValue == String
{
  var image: UIImage { return UIImage(named: rawValue)! }
}

public extension ImageAssetLiteralType where Self: EnumerableType
{
  static var allImages: [UIImage] { return allCases.map { $0.image } }
}

import class SpriteKit.SKTexture
import class SpriteKit.SKTextureAtlas
public protocol TextureAssetLiteralType
{
  static var atlas: SKTextureAtlas { get }
  var texture: SKTexture { get }
}

public extension TextureAssetLiteralType where Self: RawRepresentable,
                                               Self.RawValue == String
{
  var texture: SKTexture { return Self.atlas.textureNamed(rawValue) }
}

public extension TextureAssetLiteralType where Self: EnumerableType
{
  static var allTextures: [SKTexture] { return allCases.map { $0.texture } }
}

#endif

// MARK: - IntegerDivisible

// causes ambiguity
public protocol IntegerDivisible
{
  static func / (lhs: Self, rhs: Int) -> Self
}

// MARK: - Additive

public protocol Additive
{
  static func + (lhs: Self, rhs: Self) -> Self
  static func += (lhs: inout Self, rhs: Self)
}

// MARK: - Subtractive

public protocol Subtractive
{
  static func - (lhs: Self, rhs: Self) -> Self
  static func -= (lhs: inout Self, rhs: Self)
}

// MARK: - Multiplicative

public protocol Multiplicative
{
  static func * (lhs: Self, rhs: Self) -> Self
  static func *= (lhs: inout Self, rhs: Self)
}

// MARK: - Divisive

public protocol Divisive
{
  static func / (lhs: Self, rhs: Self) -> Self
  static func /= (lhs: inout Self, rhs: Self)
}

// MARK: - BitShifting

public protocol BitShifting
{
  static func >> (lhs: Self, rhs: Self) -> Self
  static func >>= (lhs: inout Self, rhs: Self)
  static func << (lhs: Self, rhs: Self) -> Self
  static func <<= (lhs: inout Self, rhs: Self)
}

// MARK: - OptionalSubscriptingCollectionType

public protocol OptionalSubscriptingCollectionType: Collection
{
  subscript(position: Self.Index?) -> Self.Iterator.Element? { get }
}

// MARK: - Named

/** Protocol for an object guaranteed to have a name */
public protocol Named
{
  var name: String { get }
}

// MARK: - DynamicallyNamed

public protocol DynamicallyNamed: Named
{
  var name: String { get set }
}

// MARK: - Nameable

/** Protocol for an object that may have a name */
public protocol Nameable
{
  var name: String? { get }
}

// MARK: - Renameable

/** Protocol for an object that may have a name and for which a name may be set */
public protocol Renameable: Nameable
{
  var name: String? { get set }
}

// MARK: - StringValueConvertible

public protocol StringValueConvertible
{
  var stringValue: String { get }
}
