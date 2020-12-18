//
//  Math.swift
//  MoonKit
//
//  Created by Jason Cardwell on 8/25/16.
//  Copyright © 2016 Jason Cardwell. All rights reserved.
//

import Foundation


//public func gcd(_ a: UInt128, _ b: UInt128) -> UInt128 {
//  var a = a, b = b; while b != 0 { a = a % b; swap(&a, &b) }; return a
//}
//public func lcm(_ a: UInt128, _ b: UInt128) -> UInt128 { return a / gcd(a, b) * b }


public func gcd(_ a: UInt64, _ b: UInt64) -> UInt64 {
  var a = a, b = b; while b != 0 { a = a % b; swap(&a, &b) }; return a
}
public func lcm(_ a: UInt64, _ b: UInt64) -> UInt64 { return a / gcd(a, b) * b }

public func gcd(_ a: Int64, _ b: Int64) -> Int64 {
  var a = a, b = b; while b != 0 { a = a % b; swap(&a, &b) }; return a
}
public func lcm(_ a: Int64, _ b: Int64) -> Int64 { return a / gcd(a, b) * b }

public func gcd(_ a: UInt32, _ b: UInt32) -> UInt32 {
  var a = a, b = b; while b != 0 { a = a % b; swap(&a, &b) }; return a
}
public func lcm(_ a: UInt32, _ b: UInt32) -> UInt32 { return a / gcd(a, b) * b }

public func gcd(_ a: Int32, _ b: Int32) -> Int32 {
  var a = a, b = b; while b != 0 { a = a % b; swap(&a, &b) }; return a
}
public func lcm(_ a: Int32, _ b: Int32) -> Int32 { return a / gcd(a, b) * b }

public func gcd(_ a: UInt16, _ b: UInt16) -> UInt16 {
  var a = a, b = b; while b != 0 { a = a % b; swap(&a, &b) }; return a
}
public func lcm(_ a: UInt16, _ b: UInt16) -> UInt16 { return a / gcd(a, b) * b }

public func gcd(_ a: Int16, _ b: Int16) -> Int16 {
  var a = a, b = b; while b != 0 { a = a % b; swap(&a, &b) }; return a
}
public func lcm(_ a: Int16, _ b: Int16) -> Int16 { return a / gcd(a, b) * b }

public func gcd(_ a: UInt8, _ b: UInt8) -> UInt8 {
  var a = a, b = b; while b != 0 { a = a % b; swap(&a, &b) }; return a
}
public func lcm(_ a: UInt8, _ b: UInt8) -> UInt8 { return a / gcd(a, b) * b }

public func gcd(_ a: Int8, _ b: Int8) -> Int8 {
  var a = a, b = b; while b != 0 { a = a % b; swap(&a, &b) }; return a
}
public func lcm(_ a: Int8, _ b: Int8) -> Int8 { return a / gcd(a, b) * b }

public func reinterpretCast<T,U>(_ obj: T) -> U { return unsafeBitCast(obj, to: U.self) }


public func odd<I:FixedWidthInteger>(_ n: I) -> Bool { return n & I(1) == I(1) }
public func even<I:FixedWidthInteger>(_ n: I) -> Bool { return !odd(n) }

public func half<T>(_ n: T) -> T
  where T:BitShifting, T:ExpressibleByIntegerLiteral
{
  return n >> 1
}

public func half<T>(_ n: T) -> T
  where T:FixedWidthInteger
{
  return n &>> 1
}


public func remainder<T>(_ a: T, _ b: T) -> T
  where T:Comparable, T:Additive, T:Subtractive
{
  guard a >= b else { return a }
  var a = a, b = b, c = b, tmp: T
  repeat {
    tmp = c
    c = b + c
    b = tmp
  } while a >= c
  repeat {
    if a >= b { a = a - b }
    tmp = c - b
    c = b
    b = tmp
  } while b < c
  return a
}


public func largestDoubling<T>(_ a: T, _ b: T) -> T
  where T:Comparable, T:Additive, T:Subtractive
{
  // precondition: b != 0
  var b = b
  while a - b >= b { b = b + b }
  return b
}

public func largestDoubling<T>(_ a: T, _ b: T) -> T
  where T:FixedWidthInteger
{
  // precondition: b != 0
  var b = b
  while a - b >= b { b = b + b }
  return b
}

public func quotientRemainder<T>(_ a: T, _ b: T) -> (quotient: T, remainder: T)
  where
  T:Comparable, T:Additive, T:Subtractive,
  T:BitShifting, T:ExpressibleByIntegerLiteral
{
  // precondition: b > 0
  guard a >= b else { return (0, a) }
  var c: T = largestDoubling(a, b), a = a - c, n: T = 1
  while c != b {
    c = half(c)
    n = n + n
    if c <= a {
      a = a - c
      n = n + 1
    }
  }
  return (n, a)
}

public func quotientRemainder<T>(_ a: T, _ b: T) -> (quotient: T, remainder: T)
  where
  T:FixedWidthInteger
{
  // precondition: b > 0
  guard a >= b else { return (0, a) }
  var c: T = largestDoubling(a, b), a = a - c, n: T = 1
  while c != b {
    c = half(c)
    n = n + n
    if c <= a {
      a = a - c
      n = n + 1
    }
  }
  return (n, a)
}

public func gcm_remainder<T>(_ a: T, _ b: T) -> T
  where T:Comparable, T:Additive, T:Subtractive, T:ExpressibleByIntegerLiteral
{
  var a = a, b = b
  while b != 0 {
    a = remainder(a, b)
    swap(&a, &b)
  }
  return a
}


public func power<T>(_ x: T, _ n: Int, op: (T, T) -> T) -> T {
  guard n != 0 else { return x }
  var x = x, n = n
  while n & 0b1 != 0b1 { x = op(x, x); n = n >> 1 }
  guard n != 1 else { return x }
  var r = x
  x = op(x, x)
  n = (n - 1) >> 1
  while true {
    if n & 0b1 == 0b1 {
      r = op(r, x)
      guard n != 1 else { return r }
    }
    n = n >> 1
    x = op(x, x)
  }
}

public func power<T>(_ x: T, _ n: Int, identity: T, op: (T, T) -> T) -> T {
  guard n != 0 else { return identity }
  var x = x, n = abs(n)
  while n & 0b1 != 0b1 { x = op(x, x); n = n >> 1 }
  guard n != 1 else { return x }
  var r = x
  x = op(x, x)
  n = (n - 1) >> 1
  while true {
    if n & 0b1 == 0b1 {
      r = op(r, x)
      guard n != 1 else { return r }
    }
    n = n >> 1
    x = op(x, x)
  }
}

public func power<T>(_ x: T, _ n: Int, identity: T, inverse: (T) -> T, op: (T, T) -> T) -> T {
  guard n != 0 else { return identity }
  var x = n < 0 ? inverse(x) : x, n = abs(n)
  while n & 0b1 != 0b1 { x = op(x, x); n = n >> 1 }
  guard n != 1 else { return x }
  var r = x
  x = op(x, x)
  n = (n - 1) >> 1
  while true {
    if n & 0b1 == 0b1 {
      r = op(r, x)
      guard n != 1 else { return r }
    }
    n = n >> 1
    x = op(x, x)
  }
}

//public func log<T>(_ x: T, _ y: T, op: (T, T) -> T, stop: (T) -> Bool) -> (Int, T) {
//  var x = x, n = 0
//  while !stop(x) {
//    x = op(x, y)
//    n = n &+ 1
//  }
//  return (n, x)
//}

//public func log10(_ value: UInt128) -> (value: Int, isExact: Bool) {
//  let exponent = log10(Double(value))
//  let isExact = exponent.rounded(.towardZero) == exponent
//  return (Int(exponent), isExact)
////  let (value, remainder) = log(value, UInt128(10), op: /, stop: {$0 < 10})
////  return (value, remainder == 0)
//}

//public func log<T>(_ x: T, _ n: Int, identity: T, op: (T, T) -> T) -> T {
//  guard n != 0 else { return identity }
//  var x = x, n = abs(n)
//  while n & 0b1 != 0b1 { x = op(x, x); n = n >> 1 }
//  guard n != 1 else { return x }
//  var r = x
//  x = op(x, x)
//  n = (n - 1) >> 1
//  while true {
//    if n & 0b1 == 0b1 {
//      r = op(r, x)
//      guard n != 1 else { return r }
//    }
//    n = n >> 1
//    x = op(x, x)
//  }
//}
//
//public func log<T>(_ x: T, _ n: Int, identity: T, inverse: (T) -> T, op: (T, T) -> T) -> T {
//  guard n != 0 else { return identity }
//  var x = n < 0 ? inverse(x) : x, n = abs(n)
//  while n & 0b1 != 0b1 { x = op(x, x); n = n >> 1 }
//  guard n != 1 else { return x }
//  var r = x
//  x = op(x, x)
//  n = (n - 1) >> 1
//  while true {
//    if n & 0b1 == 0b1 {
//      r = op(r, x)
//      guard n != 1 else { return r }
//    }
//    n = n >> 1
//    x = op(x, x)
//  }
//}

public func pow<I:SignedInteger>(_ lhs: I, _ rhs: I) -> I {
  var i = rhs
  var result = lhs
  while i > 1 {
    result *= lhs
    i = i - 1
  }
  return result
}

//public func pow(_ lhs: UInt128, _ rhs: Int) -> UInt128 {
//  return power(lhs, abs(rhs), identity: UInt128(1), op: *)
//}
//
//public func pow10(_ exponent: Int) -> UInt128 {
//  return power(UInt128(10), exponent, identity: UInt128(1), op: *)
//}

public func div10(_ value: UInt8) -> (quotient: UInt8, remainder: UInt8) {
  var q: UInt16, r: UInt16 = 0
  let value = UInt16(value)
  q = ((value >> 2) + value) >> 1
  q = (q + value) >> 1
  q = ((q >> 2) + value) >> 1
  q = (q + value) >> 4

  r = ((q << 2) + q) << 1
  r = value - r

  return (UInt8(q), UInt8(r))
}

public func mul10(_ value: UInt8) -> UInt16 {
  let value = UInt16(value)
  return ((value << 2) + value) << 1
}

public func doubleWidthMultiply(_ a: UInt8, _ b: UInt8) -> (high: UInt8, low: UInt8) {
  let pᴸᴸ = (a & 0xf) * (b & 0xf)
  let pᴸᴴ = (a & 0xf) * (b >> 4)
  let pᴴᴸ = (a >> 4) * (b & 0xf)
  let pᴴᴴ = (a >> 4) * (b >> 4)
  var low = pᴸᴸ & 0xf
  var carry = (pᴸᴸ >> 4) &+ (pᴸᴴ & 0xf)
  var high = carry >> 4
  carry = (carry & 0xf) &+ (pᴴᴸ & 0xf)
  high = high &+ (carry >> 4)
  low |= carry << 4
  high = high &+ (pᴸᴴ >> 4)
  carry = high >> 4
  high &= 0xf
  high = high &+ (pᴴᴸ >> 4) &+ pᴴᴴ &+ carry
  return (high, low)
}

public func doubleWidthMultiply(_ a: UInt16, _ b: UInt16) -> (high: UInt16, low: UInt16) {
  let pᴸᴸ = (a & 0xff) * (b & 0xff)
  let pᴸᴴ = (a & 0xff) * (b >> 8)
  let pᴴᴸ = (a >> 8) * (b & 0xff)
  let pᴴᴴ = (a >> 8) * (b >> 8)
  var low = pᴸᴸ & 0xff
  var carry = (pᴸᴸ >> 8) &+ (pᴸᴴ & 0xff)
  var high = carry >> 8
  carry = (carry & 0xff) &+ (pᴴᴸ & 0xff)
  high = high &+ (carry >> 8)
  low |= carry << 8
  high = high &+ (pᴸᴴ >> 8)
  carry = high >> 8
  high &= 0xff
  high = high &+ (pᴴᴸ >> 8) &+ pᴴᴴ &+ carry
  return (high, low)
}

public func doubleWidthMultiply(_ a: UInt32, _ b: UInt32) -> (high: UInt32, low: UInt32) {
  let pᴸᴸ = (a & 0xffff) * (b & 0xffff)
  let pᴸᴴ = (a & 0xffff) * (b >> 16)
  let pᴴᴸ = (a >> 16) * (b & 0xffff)
  let pᴴᴴ = (a >> 16) * (b >> 16)
  var low = pᴸᴸ & 0xffff
  var carry = (pᴸᴸ >> 16) &+ (pᴸᴴ & 0xffff)
  var high = carry >> 16
  carry = (carry & 0xffff) &+ (pᴴᴸ & 0xffff)
  high = high &+ (carry >> 16)
  low |= carry << 16
  high = high &+ (pᴸᴴ >> 16)
  carry = high >> 16
  high &= 0xffff
  high = high &+ (pᴴᴸ >> 16) &+ pᴴᴴ &+ carry
  return (high, low)
}

public func doubleWidthMultiply(_ a: UInt64, _ b: UInt64) -> (high: UInt64, low: UInt64) {
  let pᴸᴸ = (a & 0xffffffff) * (b & 0xffffffff)
  let pᴸᴴ = (a & 0xffffffff) * (b >> 32)
  let pᴴᴸ = (a >> 32) * (b & 0xffffffff)
  let pᴴᴴ = (a >> 32) * (b >> 32)
  var low = pᴸᴸ & 0xffffffff
  var carry = (pᴸᴸ >> 32) &+ (pᴸᴴ & 0xffffffff)
  var high = carry >> 32
  carry = (carry & 0xffffffff) &+ (pᴴᴸ & 0xffffffff)
  high = high &+ (carry >> 32)
  low |= carry << 32
  high = high &+ (pᴸᴴ >> 32)
  carry = high >> 32
  high &= 0xffffffff
  high = high &+ (pᴴᴸ >> 32) &+ pᴴᴴ &+ carry
  return (high, low)
}
