//
//  Packing.swift
//  MoonKit
//
//  Created by Jason Cardwell on 8/20/16.
//  Copyright © 2016 Jason Cardwell. All rights reserved.
//

import Foundation

public protocol Unpackable2 {
  associatedtype Unpackable2Element
  var unpack: (Unpackable2Element, Unpackable2Element) { get }
}

public protocol Packable2 {
  associatedtype Packable2Element
  init(_ elements: (Packable2Element, Packable2Element))
}

public extension Unpackable2 {
  var unpackArray: [Unpackable2Element] { let tuple = unpack; return [tuple.0, tuple.1] }
}

public protocol Unpackable3 {
  associatedtype Unpackable3Element
  var unpack: (Unpackable3Element, Unpackable3Element, Unpackable3Element) { get }
}

public protocol Packable3 {
  associatedtype Packable3Element
  init(_ elements: (Packable3Element, Packable3Element, Packable3Element))
}

public extension Unpackable3 {
  var unpackArray: [Unpackable3Element] { let tuple = unpack; return [tuple.0, tuple.1, tuple.2] }
}

public protocol Unpackable4 {
  associatedtype Unpackable4Element
  var unpack4: (Unpackable4Element, Unpackable4Element, Unpackable4Element, Unpackable4Element) { get }
}

public extension Unpackable4 {
  var unpackArray: [Unpackable4Element] { let tuple = unpack4; return [tuple.0, tuple.1, tuple.2, tuple.3] }
}

public protocol Packable4 {
  associatedtype Packable4Element
  init(_ elements: (Packable4Element, Packable4Element, Packable4Element, Packable4Element))
}

public protocol NonHomogeneousUnpackable2 {
  associatedtype Type1
  associatedtype Type2
  var unpack2: (Type1, Type2) { get }
}


extension Unpackable2 {
  public static prefix func *(value: Self) -> (Unpackable2Element, Unpackable2Element) {
    return value.unpack
  }
}

extension Unpackable3 {

  public static prefix func *(value: Self)
    -> (Unpackable3Element, Unpackable3Element, Unpackable3Element)
  {
    return value.unpack
  }

}

extension Unpackable4 {

  public static prefix func *(value: Self)
    -> (Unpackable4Element, Unpackable4Element, Unpackable4Element, Unpackable4Element)
  {
    return value.unpack4
  }

}

