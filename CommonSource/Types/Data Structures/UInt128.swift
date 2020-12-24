//
//  UInt128.swift
//  MoonKit
//
//  Created by Jason Cardwell on 12/21/20.
//  Copyright © 2020 Moondeer Studios. All rights reserved.
//
import Foundation

// MARK: - UInt128

/// An unsigned integer value composed of 128 bits.
public struct UInt128: UnsignedInteger {
  /// The least significant bits.
  public fileprivate(set) var low: UInt64 = 0

  /// The most significant bits.
  public fileprivate(set) var high: UInt64 = 0

  /// Default initializer.
  /// - Parameters:
  ///   - low: The value for the low bits.
  ///   - high: The value for the high bits.
  public init(low: UInt64 = 0, high: UInt64 = 0) { self.low = low; self.high = high }

  /// Initializing by rounding a `Decimal` value.
  /// - Parameter value: The value to be converted via rounding.
  public init(_ value: Decimal) {
    precondition(value.sign == .plus,
                 "Negative values cannot be represented by `UInt128`.")

    let handler = NSDecimalNumberHandler(roundingMode: .down,
                                         scale: 0,
                                         raiseOnExactness: false,
                                         raiseOnOverflow: false,
                                         raiseOnUnderflow: false,
                                         raiseOnDivideByZero: false)
    let value = value as NSDecimalNumber
    let digits = value.rounding(accordingToBehavior: handler).decimalValue.digits()
    self = UInt128(digits: digits)
  }

  /// Returns the value as an array of decimal digits padded with leading zeros to
  /// contain at least `minLength` digits.
  ///
  /// - Parameter minLength: The minimum number of digits to return. Default is `0`.
  /// - Returns: An array with the decimal digits of this value
  ///            along with any leading `0`s
  public func digits(minLength: Int = 0) -> [UInt8] {
    var digits: Stack<UInt8> = []
    var value = self
    var exponent = Swift.max(minLength, Int(log10(Double(self))))
    repeat {
      digits.push(UInt8((value % 10).low))
      value /= 10; exponent -= 1
    } while value > 0
    while exponent > 0 { digits.push(0); exponent -= 1 }
    return Array(digits)
  }

  /// Initialize from an array of decimal digits.
  ///
  /// - Parameter digits: The array of decimal digits composing the value.
  public init(digits: [UInt8]) {
    self = digits.reduce(UInt128()) { $0 * 10 &+ UInt128($1) }
  }
}

// MARK: ExpressibleByIntegerLiteral

/// A type that can be initialized with an integer literal.
///
/// The standard library integer and floating-point types, such as `Int` and
/// `Double`, conform to the `ExpressibleByIntegerLiteral` protocol. You can
/// initialize a variable or constant of any of these types by assigning an
/// integer literal.
///
///     // Type inferred as 'Int'
///     let cookieCount = 12
///
///     // An array of 'Int'
///     let chipsPerCookie = [21, 22, 25, 23, 24, 19]
///
///     // A floating-point value initialized using an integer literal
///     let redPercentage: Double = 1
///     // redPercentage == 1.0
///
/// Conforming to ExpressibleByIntegerLiteral
/// =========================================
///
/// To add `ExpressibleByIntegerLiteral` conformance to your custom type,
/// implement the required initializer.
extension UInt128: ExpressibleByIntegerLiteral {
  /// A type that represents an integer literal.
  ///
  /// The standard library integer and floating-point types are all valid types
  /// for `IntegerLiteralType`.
  public typealias IntegerLiteralType = UInt

  /// Creates an instance initialized to the specified integer value.
  ///
  /// Do not call this initializer directly. Instead, initialize a variable or
  /// constant using an integer literal. For example:
  ///
  ///     let x = 23
  ///
  /// In this example, the assignment to the `x` constant calls this integer
  /// literal initializer behind the scenes.
  ///
  /// - Parameter value: The value to create.
  public init(integerLiteral value: Self.IntegerLiteralType) {
    self.init(low: UInt64(value), high: 0)
  }
}

// MARK: CustomStringConvertible

/// A type with a customized textual representation.
///
/// Types that conform to the `CustomStringConvertible` protocol can provide
/// their own representation to be used when converting an instance to a
/// string. The `String(describing:)` initializer is the preferred way to
/// convert an instance of *any* type to a string. If the passed instance
/// conforms to `CustomStringConvertible`, the `String(describing:)`
/// initializer and the `print(_:)` function use the instance's custom
/// `description` property.
///
/// Accessing a type's `description` property directly or using
/// `CustomStringConvertible` as a generic constraint is discouraged.
///
/// Conforming to the CustomStringConvertible Protocol
/// ==================================================
///
/// Add `CustomStringConvertible` conformance to your custom types by defining
/// a `description` property.
///
/// For example, this custom `Point` struct uses the default representation
/// supplied by the standard library:
///
///     struct Point {
///         let x: Int, y: Int
///     }
///
///     let p = Point(x: 21, y: 30)
///     print(p)
///     // Prints "Point(x: 21, y: 30)"
///
/// After implementing the `description` property and declaring
/// `CustomStringConvertible` conformance, the `Point` type provides its own
/// custom representation.
///
///     extension Point: CustomStringConvertible {
///         var description: String {
///             return "(\(x), \(y))"
///         }
///     }
///
///     print(p)
///     // Prints "(21, 30)"
extension UInt128: CustomStringConvertible {
  /// A textual representation of this instance.
  ///
  /// Calling this property directly is discouraged. Instead, convert an
  /// instance of any type to a string by using the `String(describing:)`
  /// initializer. This initializer works with any type, and uses the custom
  /// `description` property for types that conform to
  /// `CustomStringConvertible`:
  ///
  ///     struct Point: CustomStringConvertible {
  ///         let x: Int, y: Int
  ///
  ///         var description: String {
  ///             return "(\(x), \(y))"
  ///         }
  ///     }
  ///
  ///     let p = Point(x: 21, y: 30)
  ///     let s = String(describing: p)
  ///     print(s)
  ///     // Prints "(21, 30)"
  ///
  /// The conversion of `p` to a string in the assignment to `s` uses the
  /// `Point` type's `description` property.
  public var description: String { String(self, radix: 10) }
}

// MARK: CustomDebugStringConvertible

/// A type with a customized textual representation suitable for debugging
/// purposes.
///
/// Swift provides a default debugging textual representation for any type.
/// That default representation is used by the `String(reflecting:)`
/// initializer and the `debugPrint(_:)` function for types that don't provide
/// their own. To customize that representation, make your type conform to the
/// `CustomDebugStringConvertible` protocol.
///
/// Because the `String(reflecting:)` initializer works for instances of *any*
/// type, returning an instance's `debugDescription` if the value passed
/// conforms to `CustomDebugStringConvertible`, accessing a type's
/// `debugDescription` property directly or using
/// `CustomDebugStringConvertible` as a generic constraint is discouraged.
///
/// - Note: Calling the `dump(_:_:_:_:)` function and printing in the debugger
///   uses both `String(reflecting:)` and `Mirror(reflecting:)` to collect
///   information about an instance. If you implement
///   `CustomDebugStringConvertible` conformance for your custom type, you may
///   want to consider providing a custom mirror by implementing
///   `CustomReflectable` conformance, as well.
///
/// Conforming to the CustomDebugStringConvertible Protocol
/// =======================================================
///
/// Add `CustomDebugStringConvertible` conformance to your custom types by
/// defining a `debugDescription` property.
///
/// For example, this custom `Point` struct uses the default representation
/// supplied by the standard library:
///
///     struct Point {
///         let x: Int, y: Int
///     }
///
///     let p = Point(x: 21, y: 30)
///     print(String(reflecting: p))
///     // Prints "p: Point = {
///     //           x = 21
///     //           y = 30
///     //         }"
///
/// After adding `CustomDebugStringConvertible` conformance by implementing the
/// `debugDescription` property, `Point` provides its own custom debugging
/// representation.
///
///     extension Point: CustomDebugStringConvertible {
///         var debugDescription: String {
///             return "Point(x: \(x), y: \(y))"
///         }
///     }
///
///     print(String(reflecting: p))
///     // Prints "Point(x: 21, y: 30)"
extension UInt128: CustomDebugStringConvertible {
  /// A textual representation of this instance, suitable for debugging.
  ///
  /// Calling this property directly is discouraged. Instead, convert an
  /// instance of any type to a string by using the `String(reflecting:)`
  /// initializer. This initializer works with any type, and uses the custom
  /// `debugDescription` property for types that conform to
  /// `CustomDebugStringConvertible`:
  ///
  ///     struct Point: CustomDebugStringConvertible {
  ///         let x: Int, y: Int
  ///
  ///         var debugDescription: String {
  ///             return "(\(x), \(y))"
  ///         }
  ///     }
  ///
  ///     let p = Point(x: 21, y: 30)
  ///     let s = String(reflecting: p)
  ///     print(s)
  ///     // Prints "(21, 30)"
  ///
  /// The conversion of `p` to a string in the assignment to `s` uses the
  /// `Point` type's `debugDescription` property.
  public var debugDescription: String {
    """
    \(description) \
    {high: 0x\(String(high, radix: 16)); \
    low: 0x\(String(low, radix: 16))}
    """
  }
}

// MARK: LosslessStringConvertible

/// A type that can be represented as a string in a lossless, unambiguous way.
///
/// For example, the integer value 1050 can be represented in its entirety as
/// the string "1050".
///
/// The description property of a conforming type must be a value-preserving
/// representation of the original value. As such, it should be possible to
/// re-create an instance from its string representation.
extension UInt128: LosslessStringConvertible {
  /// Instantiates an instance of the conforming type from a string
  /// representation.
  public init?(_ description: String) {
    guard let value = UInt64(description) else { return nil }
    self.init(low: value, high: 0)
  }
}

// MARK: Strideable

/// A type representing continuous, one-dimensional values that can be offset
/// and measured.
///
/// You can use a type that conforms to the `Strideable` protocol with the
/// `stride(from:to:by:)` and `stride(from:through:by:)` functions. For
/// example, you can use `stride(from:to:by:)` to iterate over an
/// interval of floating-point values:
///
///     for radians in stride(from: 0.0, to: .pi * 2, by: .pi / 2) {
///         let degrees = Int(radians * 180 / .pi)
///         print("Degrees: \(degrees), radians: \(radians)")
///     }
///     // Degrees: 0, radians: 0.0
///     // Degrees: 90, radians: 1.5707963267949
///     // Degrees: 180, radians: 3.14159265358979
///     // Degrees: 270, radians: 4.71238898038469
///
/// The last parameter of these functions is of the associated `Stride`
/// type---the type that represents the distance between any two instances of
/// the `Strideable` type.
///
/// Types that have an integer `Stride` can be used as the boundaries of a
/// countable range or as the lower bound of an iterable one-sided range. For
/// example, you can iterate over a range of `Int` and use sequence and
/// collection methods.
///
///     var sum = 0
///     for x in 1...100 {
///         sum += x
///     }
///     // sum == 5050
///
///     let digits = (0..<10).map(String.init)
///     // ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
///
/// Conforming to the Strideable Protocol
/// =====================================
///
/// To add `Strideable` conformance to a custom type, choose a `Stride` type
/// that can represent the distance between two instances and implement the
/// `advanced(by:)` and `distance(to:)` methods. For example, this
/// hypothetical `Date` type stores its value as the number of days before or
/// after January 1, 2000:
///
///     struct Date: Equatable, CustomStringConvertible {
///         var daysAfterY2K: Int
///
///         var description: String {
///             // ...
///         }
///     }
///
/// The `Stride` type for `Date` is `Int`, inferred from the parameter and
/// return types of `advanced(by:)` and `distance(to:)`:
///
///     extension Date: Strideable {
///         func advanced(by n: Int) -> Date {
///             var result = self
///             result.daysAfterY2K += n
///             return result
///         }
///
///         func distance(to other: Date) -> Int {
///             return other.daysAfterY2K - self.daysAfterY2K
///         }
///     }
///
/// The `Date` type can now be used with the `stride(from:to:by:)` and
/// `stride(from:through:by:)` functions and as the bounds of an iterable
/// range.
///
///     let startDate = Date(daysAfterY2K: 0)   // January 1, 2000
///     let endDate = Date(daysAfterY2K: 15)    // January 16, 2000
///
///     for date in stride(from: startDate, to: endDate, by: 7) {
///         print(date)
///     }
///     // January 1, 2000
///     // January 8, 2000
///     // January 15, 2000
///
/// - Important: The `Strideable` protocol provides default implementations for
///   the equal-to (`==`) and less-than (`<`) operators that depend on the
///   `Stride` type's implementations. If a type conforming to `Strideable` is
///   its own `Stride` type, it must provide concrete implementations of the
///   two operators to avoid infinite recursion.
extension UInt128: Strideable {
  /// A type that represents the distance between two values.
  public typealias Stride = Int

  /// Returns the distance from this value to the given value, expressed as a
  /// stride.
  ///
  /// If this type's `Stride` type conforms to `BinaryInteger`, then for two
  /// values `x` and `y`, and a distance `n = x.distance(to: y)`,
  /// `x.advanced(by: n) == y`. Using this method with types that have a
  /// noninteger `Stride` may result in an approximation.
  ///
  /// - Parameter other: The value to calculate the distance to.
  /// - Returns: The distance from this value to `other`.
  ///
  /// - Complexity: O(1)
  public func distance(to other: Self) -> Self.Stride {
    self > other
      ? Int(truncatingIfNeeded: self - other)
      : Int(truncatingIfNeeded: other - self)
  }

  /// Returns a value that is offset the specified distance from this value.
  ///
  /// Use the `advanced(by:)` method in generic code to offset a value by a
  /// specified distance. If you're working directly with numeric values, use
  /// the addition operator (`+`) instead of this method.
  ///
  ///     func addOne<T: Strideable>(to x: T) -> T
  ///         where T.Stride: ExpressibleByIntegerLiteral
  ///     {
  ///         return x.advanced(by: 1)
  ///     }
  ///
  ///     let x = addOne(to: 5)
  ///     // x == 6
  ///     let y = addOne(to: 3.5)
  ///     // y = 4.5
  ///
  /// If this type's `Stride` type conforms to `BinaryInteger`, then for a
  /// value `x`, a distance `n`, and a value `y = x.advanced(by: n)`,
  /// `x.distance(to: y) == n`. Using this method with types that have a
  /// noninteger `Stride` may result in an approximation.
  ///
  /// - Parameter n: The distance to advance this value.
  /// - Returns: A value that is offset from this value by `n`.
  ///
  /// - Complexity: O(1)
  public func advanced(by n: Self.Stride) -> Self {
    let nʹ = UInt128(low: UInt64(abs(n)), high: 0)
    return n > 0 ? self + nʹ : self - nʹ
  }
}

// MARK: Hashable

/// A type that can be hashed into a `Hasher` to produce an integer hash value.
///
/// You can use any type that conforms to the `Hashable` protocol in a set or as
/// a dictionary key. Many types in the standard library conform to `Hashable`:
/// Strings, integers, floating-point and Boolean values, and even sets are
/// hashable by default. Some other types, such as optionals, arrays and ranges
/// automatically become hashable when their type arguments implement the same.
///
/// Your own custom types can be hashable as well. When you define an
/// enumeration without associated values, it gains `Hashable` conformance
/// automatically, and you can add `Hashable` conformance to your other custom
/// types by implementing the `hash(into:)` method. For structs whose stored
/// properties are all `Hashable`, and for enum types that have all-`Hashable`
/// associated values, the compiler is able to provide an implementation of
/// `hash(into:)` automatically.
///
/// Hashing a value means feeding its essential components into a hash function,
/// represented by the `Hasher` type. Essential components are those that
/// contribute to the type's implementation of `Equatable`. Two instances that
/// are equal must feed the same values to `Hasher` in `hash(into:)`, in the
/// same order.
///
/// Conforming to the Hashable Protocol
/// ===================================
///
/// To use your own custom type in a set or as the key type of a dictionary,
/// add `Hashable` conformance to your type. The `Hashable` protocol inherits
/// from the `Equatable` protocol, so you must also satisfy that protocol's
/// requirements.
///
/// The compiler automatically synthesizes your custom type's `Hashable` and
/// requirements when you declare `Hashable` conformance in the type's original
/// declaration and your type meets these criteria:
///
/// - For a `struct`, all its stored properties must conform to `Hashable`.
/// - For an `enum`, all its associated values must conform to `Hashable`. (An
///   `enum` without associated values has `Hashable` conformance even without
///   the declaration.)
///
/// To customize your type's `Hashable` conformance, to adopt `Hashable` in a
/// type that doesn't meet the criteria listed above, or to extend an existing
/// type to conform to `Hashable`, implement the `hash(into:)` method in your
/// custom type.
///
/// In your `hash(into:)` implementation, call `combine(_:)` on the provided
/// `Hasher` instance with the essential components of your type. To ensure
/// that your type meets the semantic requirements of the `Hashable` and
/// `Equatable` protocols, it's a good idea to also customize your type's
/// `Equatable` conformance to match.
///
/// As an example, consider a `GridPoint` type that describes a location in a
/// grid of buttons. Here's the initial declaration of the `GridPoint` type:
///
///     /// A point in an x-y coordinate system.
///     struct GridPoint {
///         var x: Int
///         var y: Int
///     }
///
/// You'd like to create a set of the grid points where a user has already
/// tapped. Because the `GridPoint` type is not hashable yet, it can't be used
/// in a set. To add `Hashable` conformance, provide an `==` operator function
/// and implement the `hash(into:)` method.
///
///     extension GridPoint: Hashable {
///         static func == (lhs: GridPoint, rhs: GridPoint) -> Bool {
///             return lhs.x == rhs.x && lhs.y == rhs.y
///         }
///
///         func hash(into hasher: inout Hasher) {
///             hasher.combine(x)
///             hasher.combine(y)
///         }
///     }
///
/// The `hash(into:)` method in this example feeds the grid point's `x` and `y`
/// properties into the provided hasher. These properties are the same ones
/// used to test for equality in the `==` operator function.
///
/// Now that `GridPoint` conforms to the `Hashable` protocol, you can create a
/// set of previously tapped grid points.
///
///     var tappedPoints: Set = [GridPoint(x: 2, y: 3), GridPoint(x: 4, y: 1)]
///     let nextTap = GridPoint(x: 0, y: 1)
///     if tappedPoints.contains(nextTap) {
///         print("Already tapped at (\(nextTap.x), \(nextTap.y)).")
///     } else {
///         tappedPoints.insert(nextTap)
///         print("New tap detected at (\(nextTap.x), \(nextTap.y)).")
///     }
///     // Prints "New tap detected at (0, 1).")
extension UInt128: Hashable {
  /// Hashes the essential components of this value by feeding them into the
  /// given hasher.
  ///
  /// Implement this method to conform to the `Hashable` protocol. The
  /// components used for hashing must be the same as the components compared
  /// in your type's `==` operator implementation. Call `hasher.combine(_:)`
  /// with each of these components.
  ///
  /// - Important: Never call `finalize()` on `hasher`. Doing so may become a
  ///   compile-time error in the future.
  ///
  /// - Parameter hasher: The hasher to use when combining the components
  ///   of this instance.
  public func hash(into hasher: inout Hasher) {
    low.hash(into: &hasher)
    high.hash(into: &hasher)
  }
}

// MARK: Comparable

/// A type that can be compared using the relational operators `<`, `<=`, `>=`,
/// and `>`.
///
/// The `Comparable` protocol is used for types that have an inherent order,
/// such as numbers and strings. Many types in the standard library already
/// conform to the `Comparable` protocol. Add `Comparable` conformance to your
/// own custom types when you want to be able to compare instances using
/// relational operators or use standard library methods that are designed for
/// `Comparable` types.
///
/// The most familiar use of relational operators is to compare numbers, as in
/// the following example:
///
///     let currentTemp = 73
///
///     if currentTemp >= 90 {
///         print("It's a scorcher!")
///     } else if currentTemp < 65 {
///         print("Might need a sweater today.")
///     } else {
///         print("Seems like picnic weather!")
///     }
///     // Prints "Seems like picnic weather!"
///
/// You can use special versions of some sequence and collection operations
/// when working with a `Comparable` type. For example, if your array's
/// elements conform to `Comparable`, you can call the `sort()` method without
/// using arguments to sort the elements of your array in ascending order.
///
///     var measurements = [1.1, 1.5, 2.9, 1.2, 1.5, 1.3, 1.2]
///     measurements.sort()
///     print(measurements)
///     // Prints "[1.1, 1.2, 1.2, 1.3, 1.5, 1.5, 2.9]"
///
/// Conforming to the Comparable Protocol
/// =====================================
///
/// Types with Comparable conformance implement the less-than operator (`<`)
/// and the equal-to operator (`==`). These two operations impose a strict
/// total order on the values of a type, in which exactly one of the following
/// must be true for any two values `a` and `b`:
///
/// - `a == b`
/// - `a < b`
/// - `b < a`
///
/// In addition, the following conditions must hold:
///
/// - `a < a` is always `false` (Irreflexivity)
/// - `a < b` implies `!(b < a)` (Asymmetry)
/// - `a < b` and `b < c` implies `a < c` (Transitivity)
///
/// To add `Comparable` conformance to your custom types, define the `<` and
/// `==` operators as static methods of your types. The `==` operator is a
/// requirement of the `Equatable` protocol, which `Comparable` extends---see
/// that protocol's documentation for more information about equality in
/// Swift. Because default implementations of the remainder of the relational
/// operators are provided by the standard library, you'll be able to use
/// `!=`, `>`, `<=`, and `>=` with instances of your type without any further
/// code.
///
/// As an example, here's an implementation of a `Date` structure that stores
/// the year, month, and day of a date:
///
///     struct Date {
///         let year: Int
///         let month: Int
///         let day: Int
///     }
///
/// To add `Comparable` conformance to `Date`, first declare conformance to
/// `Comparable` and implement the `<` operator function.
///
///     extension Date: Comparable {
///         static func < (lhs: Date, rhs: Date) -> Bool {
///             if lhs.year != rhs.year {
///                 return lhs.year < rhs.year
///             } else if lhs.month != rhs.month {
///                 return lhs.month < rhs.month
///             } else {
///                 return lhs.day < rhs.day
///             }
///         }
///
/// This function uses the least specific nonmatching property of the date to
/// determine the result of the comparison. For example, if the two `year`
/// properties are equal but the two `month` properties are not, the date with
/// the lesser value for `month` is the lesser of the two dates.
///
/// Next, implement the `==` operator function, the requirement inherited from
/// the `Equatable` protocol.
///
///         static func == (lhs: Date, rhs: Date) -> Bool {
///             return lhs.year == rhs.year && lhs.month == rhs.month
///                 && lhs.day == rhs.day
///         }
///     }
///
/// Two `Date` instances are equal if each of their corresponding properties is
/// equal.
///
/// Now that `Date` conforms to `Comparable`, you can compare instances of the
/// type with any of the relational operators. The following example compares
/// the date of the first moon landing with the release of David Bowie's song
/// "Space Oddity":
///
///     let spaceOddity = Date(year: 1969, month: 7, day: 11)   // July 11, 1969
///     let moonLanding = Date(year: 1969, month: 7, day: 20)   // July 20, 1969
///     if moonLanding > spaceOddity {
///         print("Major Tom stepped through the door first.")
///     } else {
///         print("David Bowie was following in Neil Armstrong's footsteps.")
///     }
///     // Prints "Major Tom stepped through the door first."
///
/// Note that the `>` operator provided by the standard library is used in this
/// example, not the `<` operator implemented above.
///
/// - Note: A conforming type may contain a subset of values which are treated
///   as exceptional---that is, values that are outside the domain of
///   meaningful arguments for the purposes of the `Comparable` protocol. For
///   example, the special "not a number" value for floating-point types
///   (`FloatingPoint.nan`) compares as neither less than, greater than, nor
///   equal to any normal floating-point value. Exceptional values need not
///   take part in the strict total order.
extension UInt128: Comparable {
  /// Returns a Boolean value indicating whether the value of the first
  /// argument is less than that of the second argument.
  ///
  /// This function is the only requirement of the `Comparable` protocol. The
  /// remainder of the relational operator functions are implemented by the
  /// standard library for any type that conforms to `Comparable`.
  ///
  /// - Parameters:
  ///   - lhs: A value to compare.
  ///   - rhs: Another value to compare.
  public static func < (lhs: Self, rhs: Self) -> Bool { _isLessThan(lhs, rhs) }

  /// Returns a Boolean value indicating whether the value of the first
  /// argument is less than or equal to that of the second argument.
  ///
  /// - Parameters:
  ///   - lhs: A value to compare.
  ///   - rhs: Another value to compare.
  public static func <= (lhs: Self, rhs: Self) -> Bool {
    _isLessThan(lhs, rhs) || _isEqual(lhs, rhs)
  }

  /// Returns a Boolean value indicating whether the value of the first
  /// argument is greater than or equal to that of the second argument.
  ///
  /// - Parameters:
  ///   - lhs: A value to compare.
  ///   - rhs: Another value to compare.
  public static func >= (lhs: Self, rhs: Self) -> Bool {
    _isLessThan(rhs, lhs) || _isEqual(lhs, rhs)
  }

  /// Returns a Boolean value indicating whether the value of the first
  /// argument is greater than that of the second argument.
  ///
  /// - Parameters:
  ///   - lhs: A value to compare.
  ///   - rhs: Another value to compare.
  public static func > (lhs: Self, rhs: Self) -> Bool { _isLessThan(rhs, lhs) }
}

// MARK: Equatable

/// A type that can be compared for value equality.
///
/// Types that conform to the `Equatable` protocol can be compared for equality
/// using the equal-to operator (`==`) or inequality using the not-equal-to
/// operator (`!=`). Most basic types in the Swift standard library conform to
/// `Equatable`.
///
/// Some sequence and collection operations can be used more simply when the
/// elements conform to `Equatable`. For example, to check whether an array
/// contains a particular value, you can pass the value itself to the
/// `contains(_:)` method when the array's element conforms to `Equatable`
/// instead of providing a closure that determines equivalence. The following
/// example shows how the `contains(_:)` method can be used with an array of
/// strings.
///
///     let students = ["Kofi", "Abena", "Efua", "Kweku", "Akosua"]
///
///     let nameToCheck = "Kofi"
///     if students.contains(nameToCheck) {
///         print("\(nameToCheck) is signed up!")
///     } else {
///         print("No record of \(nameToCheck).")
///     }
///     // Prints "Kofi is signed up!"
///
/// Conforming to the Equatable Protocol
/// ====================================
///
/// Adding `Equatable` conformance to your custom types means that you can use
/// more convenient APIs when searching for particular instances in a
/// collection. `Equatable` is also the base protocol for the `Hashable` and
/// `Comparable` protocols, which allow more uses of your custom type, such as
/// constructing sets or sorting the elements of a collection.
///
/// You can rely on automatic synthesis of the `Equatable` protocol's
/// requirements for a custom type when you declare `Equatable` conformance in
/// the type's original declaration and your type meets these criteria:
///
/// - For a `struct`, all its stored properties must conform to `Equatable`.
/// - For an `enum`, all its associated values must conform to `Equatable`. (An
///   `enum` without associated values has `Equatable` conformance even
///   without the declaration.)
///
/// To customize your type's `Equatable` conformance, to adopt `Equatable` in a
/// type that doesn't meet the criteria listed above, or to extend an existing
/// type to conform to `Equatable`, implement the equal-to operator (`==`) as
/// a static method of your type. The standard library provides an
/// implementation for the not-equal-to operator (`!=`) for any `Equatable`
/// type, which calls the custom `==` function and negates its result.
///
/// As an example, consider a `StreetAddress` class that holds the parts of a
/// street address: a house or building number, the street name, and an
/// optional unit number. Here's the initial declaration of the
/// `StreetAddress` type:
///
///     class StreetAddress {
///         let number: String
///         let street: String
///         let unit: String?
///
///         init(_ number: String, _ street: String, unit: String? = nil) {
///             self.number = number
///             self.street = street
///             self.unit = unit
///         }
///     }
///
/// Now suppose you have an array of addresses that you need to check for a
/// particular address. To use the `contains(_:)` method without including a
/// closure in each call, extend the `StreetAddress` type to conform to
/// `Equatable`.
///
///     extension StreetAddress: Equatable {
///         static func == (lhs: StreetAddress, rhs: StreetAddress) -> Bool {
///             return
///                 lhs.number == rhs.number &&
///                 lhs.street == rhs.street &&
///                 lhs.unit == rhs.unit
///         }
///     }
///
/// The `StreetAddress` type now conforms to `Equatable`. You can use `==` to
/// check for equality between any two instances or call the
/// `Equatable`-constrained `contains(_:)` method.
///
///     let addresses = [StreetAddress("1490", "Grove Street"),
///                      StreetAddress("2119", "Maple Avenue"),
///                      StreetAddress("1400", "16th Street")]
///     let home = StreetAddress("1400", "16th Street")
///
///     print(addresses[0] == home)
///     // Prints "false"
///     print(addresses.contains(home))
///     // Prints "true"
///
/// Equality implies substitutability---any two instances that compare equally
/// can be used interchangeably in any code that depends on their values. To
/// maintain substitutability, the `==` operator should take into account all
/// visible aspects of an `Equatable` type. Exposing nonvalue aspects of
/// `Equatable` types other than class identity is discouraged, and any that
/// *are* exposed should be explicitly pointed out in documentation.
///
/// Since equality between instances of `Equatable` types is an equivalence
/// relation, any of your custom types that conform to `Equatable` must
/// satisfy three conditions, for any values `a`, `b`, and `c`:
///
/// - `a == a` is always `true` (Reflexivity)
/// - `a == b` implies `b == a` (Symmetry)
/// - `a == b` and `b == c` implies `a == c` (Transitivity)
///
/// Moreover, inequality is the inverse of equality, so any custom
/// implementation of the `!=` operator must guarantee that `a != b` implies
/// `!(a == b)`. The default implementation of the `!=` operator function
/// satisfies this requirement.
///
/// Equality is Separate From Identity
/// ----------------------------------
///
/// The identity of a class instance is not part of an instance's value.
/// Consider a class called `IntegerRef` that wraps an integer value. Here's
/// the definition for `IntegerRef` and the `==` function that makes it
/// conform to `Equatable`:
///
///     class IntegerRef: Equatable {
///         let value: Int
///         init(_ value: Int) {
///             self.value = value
///         }
///
///         static func == (lhs: IntegerRef, rhs: IntegerRef) -> Bool {
///             return lhs.value == rhs.value
///         }
///     }
///
/// The implementation of the `==` function returns the same value whether its
/// two arguments are the same instance or are two different instances with
/// the same integer stored in their `value` properties. For example:
///
///     let a = IntegerRef(100)
///     let b = IntegerRef(100)
///
///     print(a == a, a == b, separator: ", ")
///     // Prints "true, true"
///
/// Class instance identity, on the other hand, is compared using the
/// triple-equals identical-to operator (`===`). For example:
///
///     let c = a
///     print(c === a, c === b, separator: ", ")
///     // Prints "true, false"
extension UInt128: Equatable {
  /// Returns a Boolean value indicating whether two values are equal.
  ///
  /// Equality is the inverse of inequality. For any values `a` and `b`,
  /// `a == b` implies that `a != b` is `false`.
  ///
  /// - Parameters:
  ///   - lhs: A value to compare.
  ///   - rhs: Another value to compare.
  public static func == (lhs: Self, rhs: Self) -> Bool { _isEqual(lhs, rhs) }
}

// MARK: AdditiveArithmetic

/// A type with values that support addition and subtraction.
///
/// The `AdditiveArithmetic` protocol provides a suitable basis for additive
/// arithmetic on scalar values, such as integers and floating-point numbers,
/// or vectors. You can write generic methods that operate on any numeric type
/// in the standard library by using the `AdditiveArithmetic` protocol as a
/// generic constraint.
///
/// The following code declares a method that calculates the total of any
/// sequence with `AdditiveArithmetic` elements.
///
///     extension Sequence where Element: AdditiveArithmetic {
///         func sum() -> Element {
///             return reduce(.zero, +)
///         }
///     }
///
/// The `sum()` method is now available on any sequence with values that
/// conform to `AdditiveArithmetic`, whether it is an array of `Double` or a
/// range of `Int`.
///
///     let arraySum = [1.1, 2.2, 3.3, 4.4, 5.5].sum()
///     // arraySum == 16.5
///
///     let rangeSum = (1..<10).sum()
///     // rangeSum == 45
///
/// Conforming to the AdditiveArithmetic Protocol
/// =============================================
///
/// To add `AdditiveArithmetic` protocol conformance to your own custom type,
/// implement the required operators, and provide a static `zero` property
/// using a type that can represent the magnitude of any value of your custom
/// type.
extension UInt128: AdditiveArithmetic {
  /// The zero value.
  ///
  /// Zero is the identity element for addition. For any value,
  /// `x + .zero == x` and `.zero + x == x`.
  public static var zero: Self { UInt128(low: 0, high: 0) }

  /// Adds two values and produces their sum.
  ///
  /// The addition operator (`+`) calculates the sum of its two arguments. For
  /// example:
  ///
  ///     1 + 2                   // 3
  ///     -10 + 15                // 5
  ///     -15 + -5                // -20
  ///     21.5 + 3.25             // 24.75
  ///
  /// You cannot use `+` with arguments of different types. To add values of
  /// different types, convert one of the values to the other value's type.
  ///
  ///     let x: Int8 = 21
  ///     let y: Int = 1000000
  ///     Int(x) + y              // 1000021
  ///
  /// - Parameters:
  ///   - lhs: The first value to add.
  ///   - rhs: The second value to add.
  public static func + (lhs: Self, rhs: Self) -> Self { _add(lhs, rhs).partialValue }

  /// Adds two values and stores the result in the left-hand-side variable.
  ///
  /// - Parameters:
  ///   - lhs: The first value to add.
  ///   - rhs: The second value to add.
  public static func += (lhs: inout Self, rhs: Self) { lhs = lhs + rhs }

  /// Subtracts one value from another and produces their difference.
  ///
  /// The subtraction operator (`-`) calculates the difference of its two
  /// arguments. For example:
  ///
  ///     8 - 3                   // 5
  ///     -10 - 5                 // -15
  ///     100 - -5                // 105
  ///     10.5 - 100.0            // -89.5
  ///
  /// You cannot use `-` with arguments of different types. To subtract values
  /// of different types, convert one of the values to the other value's type.
  ///
  ///     let x: UInt8 = 21
  ///     let y: UInt = 1000000
  ///     y - UInt(x)             // 999979
  ///
  /// - Parameters:
  ///   - lhs: A numeric value.
  ///   - rhs: The value to subtract from `lhs`.
  public static func - (lhs: Self, rhs: Self) -> Self { _subtract(lhs, rhs).partialValue }

  /// Subtracts the second value from the first and stores the difference in the
  /// left-hand-side variable.
  ///
  /// - Parameters:
  ///   - lhs: A numeric value.
  ///   - rhs: The value to subtract from `lhs`.
  public static func -= (lhs: inout Self, rhs: Self) { lhs = lhs - rhs }
}

// MARK: Numeric

/// A type with values that support multiplication.
///
/// The `Numeric` protocol provides a suitable basis for arithmetic on
/// scalar values, such as integers and floating-point numbers. You can write
/// generic methods that operate on any numeric type in the standard library
/// by using the `Numeric` protocol as a generic constraint.
///
/// The following example extends `Sequence` with a method that returns an
/// array with the sequence's values multiplied by two.
///
///     extension Sequence where Element: Numeric {
///         func doublingAll() -> [Element] {
///             return map { $0 * 2 }
///         }
///     }
///
/// With this extension, any sequence with elements that conform to `Numeric`
/// has the `doublingAll()` method. For example, you can double the elements of
/// an array of doubles or a range of integers:
///
///     let observations = [1.5, 2.0, 3.25, 4.875, 5.5]
///     let doubledObservations = observations.doublingAll()
///     // doubledObservations == [3.0, 4.0, 6.5, 9.75, 11.0]
///
///     let integers = 0..<8
///     let doubledIntegers = integers.doublingAll()
///     // doubledIntegers == [0, 2, 4, 6, 8, 10, 12, 14]
///
/// Conforming to the Numeric Protocol
/// ==================================
///
/// To add `Numeric` protocol conformance to your own custom type, implement
/// the required initializer and operators, and provide a `magnitude` property
/// using a type that can represent the magnitude of any value of your custom
/// type.
extension UInt128: Numeric {
  /// Creates a new instance from the given integer, if it can be represented
  /// exactly.
  ///
  /// If the value passed as `source` is not representable exactly, the result
  /// is `nil`. In the following example, the constant `x` is successfully
  /// created from a value of `100`, while the attempt to initialize the
  /// constant `y` from `1_000` fails because the `Int8` type can represent
  /// `127` at maximum:
  ///
  ///     let x = Int8(exactly: 100)
  ///     // x == Optional(100)
  ///     let y = Int8(exactly: 1_000)
  ///     // y == nil
  ///
  /// - Parameter source: A value to convert to this type.
  public init?<T>(exactly source: T) where T: BinaryInteger {
    switch source {
      case let value as UInt128:
        self.init(low: value.low, high: value.high)
      case let value as UInt64:
        self.init(low: value, high: 0)
      case let value:
        guard let exactValue = UInt64(exactly: value) else { return nil }
        self.init(low: exactValue, high: 0)
    }
  }

  /// A type that can represent the absolute value of any possible value of the
  /// conforming type.
  public typealias Magnitude = Self

  /// The magnitude of this value.
  ///
  /// For any numeric value `x`, `x.magnitude` is the absolute value of `x`.
  /// You can use the `magnitude` property in operations that are simpler to
  /// implement in terms of unsigned values, such as printing the value of an
  /// integer, which is just printing a '-' character in front of an absolute
  /// value.
  ///
  ///     let x = -200
  ///     // x.magnitude == 200
  ///
  /// The global `abs(_:)` function provides more familiar syntax when you need
  /// to find an absolute value. In addition, because `abs(_:)` always returns
  /// a value of the same type, even in a generic context, using the function
  /// instead of the `magnitude` property is encouraged.
  public var magnitude: Self.Magnitude { self }

  /// Multiplies two values and produces their product.
  ///
  /// The multiplication operator (`*`) calculates the product of its two
  /// arguments. For example:
  ///
  ///     2 * 3                   // 6
  ///     100 * 21                // 2100
  ///     -10 * 15                // -150
  ///     3.5 * 2.25              // 7.875
  ///
  /// You cannot use `*` with arguments of different types. To multiply values
  /// of different types, convert one of the values to the other value's type.
  ///
  ///     let x: Int8 = 21
  ///     let y: Int = 1000000
  ///     Int(x) * y              // 21000000
  ///
  /// - Parameters:
  ///   - lhs: The first value to multiply.
  ///   - rhs: The second value to multiply.
  public static func * (lhs: Self, rhs: Self) -> Self { _multiply(lhs, rhs).partialValue }

  /// Multiplies two values and stores the result in the left-hand-side
  /// variable.
  ///
  /// - Parameters:
  ///   - lhs: The first value to multiply.
  ///   - rhs: The second value to multiply.
  public static func *= (lhs: inout Self, rhs: Self) { lhs = lhs * rhs }
}

// MARK: FixedWidthInteger, BinaryInteger

/// An integer type with a binary representation.
///
/// The `BinaryInteger` protocol is the basis for all the integer types
/// provided by the standard library. All of the standard library's integer
/// types, such as `Int` and `UInt32`, conform to `BinaryInteger`.
///
/// Converting Between Numeric Types
/// ================================
///
/// You can create new instances of a type that conforms to the `BinaryInteger`
/// protocol from a floating-point number or another binary integer of any
/// type. The `BinaryInteger` protocol provides initializers for four
/// different kinds of conversion.
///
/// Range-Checked Conversion
/// ------------------------
///
/// You use the default `init(_:)` initializer to create a new instance when
/// you're sure that the value passed is representable in the new type. For
/// example, an instance of `Int16` can represent the value `500`, so the
/// first conversion in the code sample below succeeds. That same value is too
/// large to represent as an `Int8` instance, so the second conversion fails,
/// triggering a runtime error.
///
///     let x: Int = 500
///     let y = Int16(x)
///     // y == 500
///
///     let z = Int8(x)
///     // Error: Not enough bits to represent...
///
/// When you create a binary integer from a floating-point value using the
/// default initializer, the value is rounded toward zero before the range is
/// checked. In the following example, the value `127.75` is rounded to `127`,
/// which is representable by the `Int8` type.  `128.25` is rounded to `128`,
/// which is not representable as an `Int8` instance, triggering a runtime
/// error.
///
///     let e = Int8(127.75)
///     // e == 127
///
///     let f = Int8(128.25)
///     // Error: Double value cannot be converted...
///
///
/// Exact Conversion
/// ----------------
///
/// Use the `init?(exactly:)` initializer to create a new instance after
/// checking whether the passed value is representable. Instead of trapping on
/// out-of-range values, using the failable `init?(exactly:)`
/// initializer results in `nil`.
///
///     let x = Int16(exactly: 500)
///     // x == Optional(500)
///
///     let y = Int8(exactly: 500)
///     // y == nil
///
/// When converting floating-point values, the `init?(exactly:)` initializer
/// checks both that the passed value has no fractional part and that the
/// value is representable in the resulting type.
///
///     let e = Int8(exactly: 23.0)       // integral value, representable
///     // e == Optional(23)
///
///     let f = Int8(exactly: 23.75)      // fractional value, representable
///     // f == nil
///
///     let g = Int8(exactly: 500.0)      // integral value, nonrepresentable
///     // g == nil
///
/// Clamping Conversion
/// -------------------
///
/// Use the `init(clamping:)` initializer to create a new instance of a binary
/// integer type where out-of-range values are clamped to the representable
/// range of the type. For a type `T`, the resulting value is in the range
/// `T.min...T.max`.
///
///     let x = Int16(clamping: 500)
///     // x == 500
///
///     let y = Int8(clamping: 500)
///     // y == 127
///
///     let z = UInt8(clamping: -500)
///     // z == 0
///
/// Bit Pattern Conversion
/// ----------------------
///
/// Use the `init(truncatingIfNeeded:)` initializer to create a new instance
/// with the same bit pattern as the passed value, extending or truncating the
/// value's representation as necessary. Note that the value may not be
/// preserved, particularly when converting between signed to unsigned integer
/// types or when the destination type has a smaller bit width than the source
/// type. The following example shows how extending and truncating work for
/// nonnegative integers:
///
///     let q: Int16 = 850
///     // q == 0b00000011_01010010
///
///     let r = Int8(truncatingIfNeeded: q)      // truncate 'q' to fit in 8 bits
///     // r == 82
///     //   == 0b01010010
///
///     let s = Int16(truncatingIfNeeded: r)     // extend 'r' to fill 16 bits
///     // s == 82
///     //   == 0b00000000_01010010
///
/// Any padding is performed by *sign-extending* the passed value. When
/// nonnegative integers are extended, the result is padded with zeroes. When
/// negative integers are extended, the result is padded with ones. This
/// example shows several extending conversions of a negative value---note
/// that negative values are sign-extended even when converting to an unsigned
/// type.
///
///     let t: Int8 = -100
///     // t == -100
///     // t's binary representation == 0b10011100
///
///     let u = UInt8(truncatingIfNeeded: t)
///     // u == 156
///     // u's binary representation == 0b10011100
///
///     let v = Int16(truncatingIfNeeded: t)
///     // v == -100
///     // v's binary representation == 0b11111111_10011100
///
///     let w = UInt16(truncatingIfNeeded: t)
///     // w == 65436
///     // w's binary representation == 0b11111111_10011100
///
///
/// Comparing Across Integer Types
/// ==============================
///
/// You can use relational operators, such as the less-than and equal-to
/// operators (`<` and `==`), to compare instances of different binary integer
/// types. The following example compares instances of the `Int`, `UInt`, and
/// `UInt8` types:
///
///     let x: Int = -23
///     let y: UInt = 1_000
///     let z: UInt8 = 23
///
///     if x < y {
///         print("\(x) is less than \(y).")
///     }
///     // Prints "-23 is less than 1000."
///
///     if z > x {
///         print("\(z) is greater than \(x).")
///     }
///     // Prints "23 is greater than -23."
/// An integer type that uses a fixed size for every instance.
///
/// The `FixedWidthInteger` protocol adds binary bitwise operations, bit
/// shifts, and overflow handling to the operations supported by the
/// `BinaryInteger` protocol.
///
/// Use the `FixedWidthInteger` protocol as a constraint or extension point
/// when writing operations that depend on bit shifting, performing bitwise
/// operations, catching overflows, or having access to the maximum or minimum
/// representable value of a type. For example, the following code provides a
/// `binaryString` property on every fixed-width integer that represents the
/// number's binary representation, split into 8-bit chunks.
///
///     extension FixedWidthInteger {
///         var binaryString: String {
///             var result: [String] = []
///             for i in 0..<(Self.bitWidth / 8) {
///                 let byte = UInt8(truncatingIfNeeded: self >> (i * 8))
///                 let byteString = String(byte, radix: 2)
///                 let padding = String(repeating: "0",
///                                      count: 8 - byteString.count)
///                 result.append(padding + byteString)
///             }
///             return "0b" + result.reversed().joined(separator: "_")
///         }
///     }
///
///     print(Int16.max.binaryString)
///     // Prints "0b01111111_11111111"
///     print((101 as UInt8).binaryString)
///     // Prints "0b11001001"
///
/// The `binaryString` implementation uses the static `bitWidth` property and
/// the right shift operator (`>>`), both of which are available to any type
/// that conforms to the `FixedWidthInteger` protocol.
///
/// The next example declares a generic `squared` function, which accepts an
/// instance `x` of any fixed-width integer type. The function uses the
/// `multipliedReportingOverflow(by:)` method to multiply `x` by itself and
/// check whether the result is too large to represent in the same type.
///
///     func squared<T: FixedWidthInteger>(_ x: T) -> T? {
///         let (result, overflow) = x.multipliedReportingOverflow(by: x)
///         if overflow {
///             return nil
///         }
///         return result
///     }
///
///     let (x, y): (Int8, Int8) = (9, 123)
///     print(squared(x))
///     // Prints "Optional(81)"
///     print(squared(y))
///     // Prints "nil"
///
/// Conforming to the FixedWidthInteger Protocol
/// ============================================
///
/// To make your own custom type conform to the `FixedWidthInteger` protocol,
/// declare the required initializers, properties, and methods. The required
/// methods that are suffixed with `ReportingOverflow` serve as the
/// customization points for arithmetic operations. When you provide just those
/// methods, the standard library provides default implementations for all
/// other arithmetic methods and operators.
extension UInt128: FixedWidthInteger, BinaryInteger {
  // MARK: Initializers

  /// Initializing from an unsigned integer.
  /// - Parameter bits: The bits with which to initialize.
  public init(_truncatingBits bits: UInt) { low = UInt64(bits) }

  /// Creates an integer from the given floating-point value, if it can be
  /// represented exactly.
  ///
  /// If the value passed as `source` is not representable exactly, the result
  /// is `nil`. In the following example, the constant `x` is successfully
  /// created from a value of `21.0`, while the attempt to initialize the
  /// constant `y` from `21.5` fails:
  ///
  ///     let x = Int(exactly: 21.0)
  ///     // x == Optional(21)
  ///     let y = Int(exactly: 21.5)
  ///     // y == nil
  ///
  /// - Parameter source: A floating-point value to convert to an integer.
  public init?<T>(exactly source: T) where T: BinaryFloatingPoint {
    let (value, isExact) = _convertFloatingPoint(source)
    guard isExact else { return nil }
    self = value
  }

  /// Creates an integer from the given floating-point value, rounding toward
  /// zero.
  ///
  /// Any fractional part of the value passed as `source` is removed, rounding
  /// the value toward zero.
  ///
  ///     let x = Int(21.5)
  ///     // x == 21
  ///     let y = Int(-21.5)
  ///     // y == -21
  ///
  /// If `source` is outside the bounds of this type after rounding toward
  /// zero, a runtime error may occur.
  ///
  ///     let z = UInt(-21.5)
  ///     // Error: ...the result would be less than UInt.min
  ///
  /// - Parameter source: A floating-point value to convert to an integer.
  ///   `source` must be representable in this type after rounding toward
  ///   zero.
  public init<T>(_ source: T) where T: BinaryFloatingPoint {
    self = _convertFloatingPoint(source).value
  }

  /// Creates a new instance from the given integer.
  ///
  /// If the value passed as `source` is not representable in this type, a
  /// runtime error may occur.
  ///
  ///     let x = -500 as Int
  ///     let y = Int32(x)
  ///     // y == -500
  ///
  ///     // -500 is not representable as a 'UInt32' instance
  ///     let z = UInt32(x)
  ///     // Error
  ///
  /// - Parameter source: An integer to convert. `source` must be representable
  ///   in this type.
  public init<T>(_ source: T) where T: BinaryInteger {
    switch source {
      case let value as UInt128:
        self = value
      case let value as UInt64:
        low = value
      case let value:
        low = UInt64(value)
    }
  }

  /// Creates a new instance from the bit pattern of the given instance by
  /// sign-extending or truncating to fit this type.
  ///
  /// When the bit width of `T` (the type of `source`) is equal to or greater
  /// than this type's bit width, the result is the truncated
  /// least-significant bits of `source`. For example, when converting a
  /// 16-bit value to an 8-bit type, only the lower 8 bits of `source` are
  /// used.
  ///
  ///     let p: Int16 = -500
  ///     // 'p' has a binary representation of 11111110_00001100
  ///     let q = Int8(truncatingIfNeeded: p)
  ///     // q == 12
  ///     // 'q' has a binary representation of 00001100
  ///
  /// When the bit width of `T` is less than this type's bit width, the result
  /// is *sign-extended* to fill the remaining bits. That is, if `source` is
  /// negative, the result is padded with ones; otherwise, the result is
  /// padded with zeros.
  ///
  ///     let u: Int8 = 21
  ///     // 'u' has a binary representation of 00010101
  ///     let v = Int16(truncatingIfNeeded: u)
  ///     // v == 21
  ///     // 'v' has a binary representation of 00000000_00010101
  ///
  ///     let w: Int8 = -21
  ///     // 'w' has a binary representation of 11101011
  ///     let x = Int16(truncatingIfNeeded: w)
  ///     // x == -21
  ///     // 'x' has a binary representation of 11111111_11101011
  ///     let y = UInt16(truncatingIfNeeded: w)
  ///     // y == 65515
  ///     // 'y' has a binary representation of 11111111_11101011
  ///
  /// - Parameter source: An integer to convert to this type.
  public init<T>(truncatingIfNeeded source: T) where T: BinaryInteger {
    switch source {
      case let value as UInt128:
        self = value
      case let value as UInt64:
        low = value
      case let value:
        low = UInt64(truncatingIfNeeded: value)
    }
  }

  /// Creates a new instance with the representable value that's closest to the
  /// given integer.
  ///
  /// If the value passed as `source` is greater than the maximum representable
  /// value in this type, the result is the type's `max` value. If `source` is
  /// less than the smallest representable value in this type, the result is
  /// the type's `min` value.
  ///
  /// In this example, `x` is initialized as an `Int8` instance by clamping
  /// `500` to the range `-128...127`, and `y` is initialized as a `UInt`
  /// instance by clamping `-500` to the range `0...UInt.max`.
  ///
  ///     let x = Int8(clamping: 500)
  ///     // x == 127
  ///     // x == Int8.max
  ///
  ///     let y = UInt(clamping: -500)
  ///     // y == 0
  ///
  /// - Parameter source: An integer to convert to this type.
  public init<T>(clamping source: T) where T: BinaryInteger {
    switch source {
      case let value as UInt128:
        self = value
      case let value as UInt64:
        low = value
      case let value:
        low = UInt64(value)
    }
  }

  /// Creates an integer from its big-endian representation, changing the byte
  /// order if necessary.
  ///
  /// - Parameter value: A value to use as the big-endian representation of the
  ///   new integer.
  public init(bigEndian value: Self) {
    if CFByteOrderGetCurrent() == Int(CFByteOrderLittleEndian.rawValue) {
      self = value.byteSwapped
    } else {
      self = value
    }
  }

  /// Creates an integer from its little-endian representation, changing the
  /// byte order if necessary.
  ///
  /// - Parameter value: A value to use as the little-endian representation of
  ///   the new integer.
  public init(littleEndian value: Self) {
    if CFByteOrderGetCurrent() == Int(CFByteOrderLittleEndian.rawValue) {
      self = value
    } else {
      self = value.byteSwapped
    }
  }

  // MARK: Sign

  /// A Boolean value indicating whether this type is a signed integer type.
  ///
  /// *Signed* integer types can represent both positive and negative values.
  /// *Unsigned* integer types can represent only nonnegative values.
  public static var isSigned: Bool { false }

  /// Returns `-1` if this value is negative and `1` if it's positive;
  /// otherwise, `0`.
  ///
  /// - Returns: The sign of this number, expressed as an integer of the same
  ///   type.
  public func signum() -> Self { low == 0 && high == 0 ? UInt128() : UInt128(low: 1) }

  // MARK: Max and min

  /// The maximum representable integer in this type.
  ///
  /// For unsigned integer types, this value is `(2 ** bitWidth) - 1`, where
  /// `**` is exponentiation. For signed integer types, this value is
  /// `(2 ** (bitWidth - 1)) - 1`.
  public static var max: Self { UInt128(low: UInt64.max, high: UInt64.max) }

  /// The minimum representable integer in this type.
  ///
  /// For unsigned integer types, this value is always `0`. For signed integer
  /// types, this value is `-(2 ** (bitWidth - 1))`, where `**` is
  /// exponentiation.
  public static var min: Self { UInt128(low: UInt64.min, high: UInt64.min) }

  // MARK: Bits and words

  /// A type that represents the words of a binary integer.
  ///
  /// The `Words` type must conform to the `RandomAccessCollection` protocol
  /// with an `Element` type of `UInt` and `Index` type of `Int`.
  public struct Words: RandomAccessCollection {
    public typealias Element = UInt
    public typealias Index = Int
    public typealias SubSequence = Slice<UInt128.Words>
    public typealias Indices = Range<Int>

    public var count: Int { 2 }
    public var startIndex: Int { 0 }
    public var endIndex: Int { count }
    public var indices: Range<Int> { startIndex ..< endIndex }
    public func index(after i: Int) -> Int { i + 1 }
    public func index(before i: Int) -> Int { i - 1 }

    var _low: UInt
    var _high: UInt

    init(_ value: UInt128) { _low = UInt(value.low); _high = UInt(value.high) }

    public subscript(position: Int) -> UInt { position == 0 ? _low : _high }
  }

  /// A collection containing the words of this value's binary
  /// representation, in order from the least significant to most significant.
  ///
  /// Negative values are returned in two's complement representation,
  /// regardless of the type's underlying implementation.
  public var words: Self.Words { Words(self) }

  /// The number of bits in the current binary representation of this value.
  ///
  /// This property is a constant for instances of fixed-width integer
  /// types.
  public var bitWidth: Int { 128 }

  /// The number of bits used for the underlying binary representation of
  /// values of this type.
  ///
  /// An unsigned, fixed-width integer type can represent values from 0 through
  /// `(2 ** bitWidth) - 1`, where `**` is exponentiation. A signed,
  /// fixed-width integer type can represent values from
  /// `-(2 ** (bitWidth - 1))` through `(2 ** (bitWidth - 1)) - 1`. For example,
  /// the `Int8` type has a `bitWidth` value of 8 and can store any integer in
  /// the range `-128...127`.
  public static var bitWidth: Int { UInt64.bitWidth * 2 }

  /// The number of trailing zeros in this value's binary representation.
  ///
  /// For example, in a fixed-width integer type with a `bitWidth` value of 8,
  /// the number -8 has three trailing zeros.
  ///
  ///     let x = Int8(bitPattern: 0b1111_1000)
  ///     // x == -8
  ///     // x.trailingZeroBitCount == 3
  ///
  /// If the value is zero, then `trailingZeroBitCount` is equal to `bitWidth`.
  public var trailingZeroBitCount: Int {
    low.trailingZeroBitCount + (low == 0 ? high.trailingZeroBitCount : 0)
  }

  /// The number of bits equal to 1 in this value's binary representation.
  ///
  /// For example, in a fixed-width integer type with a `bitWidth` value of 8,
  /// the number *31* has five bits equal to *1*.
  ///
  ///     let x: Int8 = 0b0001_1111
  ///     // x == 31
  ///     // x.nonzeroBitCount == 5
  public var nonzeroBitCount: Int { low.nonzeroBitCount + high.nonzeroBitCount }

  /// The number of leading zeros in this value's binary representation.
  ///
  /// For example, in a fixed-width integer type with a `bitWidth` value of 8,
  /// the number *31* has three leading zeros.
  ///
  ///     let x: Int8 = 0b0001_1111
  ///     // x == 31
  ///     // x.leadingZeroBitCount == 3
  ///
  /// If the value is zero, then `leadingZeroBitCount` is equal to `bitWidth`.
  public var leadingZeroBitCount: Int {
    high.leadingZeroBitCount + (high == 0 ? low.leadingZeroBitCount : 0)
  }

  /// The big-endian representation of this integer.
  ///
  /// If necessary, the byte order of this value is reversed from the typical
  /// byte order of this integer type. On a big-endian platform, for any
  /// integer `x`, `x == x.bigEndian`.
  public var bigEndian: Self {
    CFByteOrderGetCurrent() == Int(CFByteOrderLittleEndian.rawValue)
      ? byteSwapped
      : self
  }

  /// The little-endian representation of this integer.
  ///
  /// If necessary, the byte order of this value is reversed from the typical
  /// byte order of this integer type. On a little-endian platform, for any
  /// integer `x`, `x == x.littleEndian`.
  public var littleEndian: Self {
    CFByteOrderGetCurrent() == Int(CFByteOrderLittleEndian.rawValue)
      ? self
      : byteSwapped
  }

  /// A representation of this integer with the byte order swapped.
  public var byteSwapped: Self { UInt128(low: high.byteSwapped, high: low.byteSwapped) }

  // MARK: Operations

  /// Returns the sum of this value and the given value, along with a Boolean
  /// value indicating whether overflow occurred in the operation.
  ///
  /// - Parameter rhs: The value to add to this value.
  /// - Returns: A tuple containing the result of the addition along with a
  ///   Boolean value indicating whether overflow occurred. If the `overflow`
  ///   component is `false`, the `partialValue` component contains the entire
  ///   sum. If the `overflow` component is `true`, an overflow occurred and
  ///   the `partialValue` component contains the truncated sum of this value
  ///   and `rhs`.
  public func addingReportingOverflow(_ rhs: Self) -> (partialValue: Self,
                                                       overflow: Bool)
  {
    _add(self, rhs)
  }

  /// Returns the difference obtained by subtracting the given value from this
  /// value, along with a Boolean value indicating whether overflow occurred in
  /// the operation.
  ///
  /// - Parameter rhs: The value to subtract from this value.
  /// - Returns: A tuple containing the result of the subtraction along with a
  ///   Boolean value indicating whether overflow occurred. If the `overflow`
  ///   component is `false`, the `partialValue` component contains the entire
  ///   difference. If the `overflow` component is `true`, an overflow occurred
  ///   and the `partialValue` component contains the truncated result of `rhs`
  ///   subtracted from this value.
  public func subtractingReportingOverflow(_ rhs: Self) -> (partialValue: Self,
                                                            overflow: Bool)
  {
    _subtract(self, rhs)
  }

  /// Returns the quotient and remainder of this value divided by the given
  /// value.
  ///
  /// Use this method to calculate the quotient and remainder of a division at
  /// the same time.
  ///
  ///     let x = 1_000_000
  ///     let (q, r) = x.quotientAndRemainder(dividingBy: 933)
  ///     // q == 1071
  ///     // r == 757
  ///
  /// - Parameter rhs: The value to divide this value by.
  /// - Returns: A tuple containing the quotient and remainder of this value
  ///   divided by `rhs`. The remainder has the same sign as `rhs`.
  public func quotientAndRemainder(dividingBy rhs: Self) -> (quotient: Self,
                                                             remainder: Self)
  {
    _quotientAndRemainder(self, rhs)
  }

  /// Returns `true` if this value is a multiple of the given value, and `false`
  /// otherwise.
  ///
  /// For two integers *a* and *b*, *a* is a multiple of *b* if there exists a
  /// third integer *q* such that _a = q*b_. For example, *6* is a multiple of
  /// *3* because _6 = 2*3_. Zero is a multiple of everything because _0 = 0*x_
  /// for any integer *x*.
  ///
  /// Two edge cases are worth particular attention:
  /// - `x.isMultiple(of: 0)` is `true` if `x` is zero and `false` otherwise.
  /// - `T.min.isMultiple(of: -1)` is `true` for signed integer `T`, even
  ///   though the quotient `T.min / -1` isn't representable in type `T`.
  ///
  /// - Parameter other: The value to test.
  public func isMultiple(of other: Self) -> Bool {
    _quotientAndRemainder(self, other).remainder == 0
  }

  /// Returns the product of this value and the given value, along with a
  /// Boolean value indicating whether overflow occurred in the operation.
  ///
  /// - Parameter rhs: The value to multiply by this value.
  /// - Returns: A tuple containing the result of the multiplication along with
  ///   a Boolean value indicating whether overflow occurred. If the `overflow`
  ///   component is `false`, the `partialValue` component contains the entire
  ///   product. If the `overflow` component is `true`, an overflow occurred and
  ///   the `partialValue` component contains the truncated product of this
  ///   value and `rhs`.
  public func multipliedReportingOverflow(by rhs: Self) -> (partialValue: Self,
                                                            overflow: Bool)
  {
    _multiply(self, rhs)
  }

  /// Returns the quotient obtained by dividing this value by the given value,
  /// along with a Boolean value indicating whether overflow occurred in the
  /// operation.
  ///
  /// Dividing by zero is not an error when using this method. For a value `x`,
  /// the result of `x.dividedReportingOverflow(by: 0)` is `(x, true)`.
  ///
  /// - Parameter rhs: The value to divide this value by.
  /// - Returns: A tuple containing the result of the division along with a
  ///   Boolean value indicating whether overflow occurred. If the `overflow`
  ///   component is `false`, the `partialValue` component contains the entire
  ///   quotient. If the `overflow` component is `true`, an overflow occurred
  ///   and the `partialValue` component contains either the truncated quotient
  ///   or, if the quotient is undefined, the dividend.
  public func dividedReportingOverflow(by rhs: Self) -> (partialValue: Self,
                                                         overflow: Bool)
  {
    _divide(self, rhs)
  }

  /// Returns the remainder after dividing this value by the given value, along
  /// with a Boolean value indicating whether overflow occurred during division.
  ///
  /// Dividing by zero is not an error when using this method. For a value `x`,
  /// the result of `x.remainderReportingOverflow(dividingBy: 0)` is
  /// `(x, true)`.
  ///
  /// - Parameter rhs: The value to divide this value by.
  /// - Returns: A tuple containing the result of the operation along with a
  ///   Boolean value indicating whether overflow occurred. If the `overflow`
  ///   component is `false`, the `partialValue` component contains the entire
  ///   remainder. If the `overflow` component is `true`, an overflow occurred
  ///   during division and the `partialValue` component contains either the
  ///   entire remainder or, if the remainder is undefined, the dividend.
  public func remainderReportingOverflow(dividingBy rhs: Self) -> (partialValue: Self,
                                                                   overflow: Bool)
  {
    _remainder(self, rhs)
  }

  /// Returns a tuple containing the high and low parts of the result of
  /// multiplying this value by the given value.
  ///
  /// Use this method to calculate the full result of a product that would
  /// otherwise overflow. Unlike traditional truncating multiplication, the
  /// `multipliedFullWidth(by:)` method returns a tuple containing both the
  /// `high` and `low` parts of the product of this value and `other`. The
  /// following example uses this method to multiply two `Int8` values that
  /// normally overflow when multiplied:
  ///
  ///     let x: Int8 = 48
  ///     let y: Int8 = -40
  ///     let result = x.multipliedFullWidth(by: y)
  ///     // result.high == -8
  ///     // result.low  == 128
  ///
  /// The product of `x` and `y` is `-1920`, which is too large to represent in
  /// an `Int8` instance. The `high` and `low` compnents of the `result` value
  /// represent `-1920` when concatenated to form a double-width integer; that
  /// is, using `result.high` as the high byte and `result.low` as the low byte
  /// of an `Int16` instance.
  ///
  ///     let z = Int16(result.high) << 8 | Int16(result.low)
  ///     // z == -1920
  ///
  /// - Parameter other: The value to multiply this value by.
  /// - Returns: A tuple containing the high and low parts of the result of
  ///   multiplying this value and `other`.
  public func multipliedFullWidth(by other: Self) -> (high: Self, low: Self.Magnitude) {
    doubleWidthMultiply(self, other)
  }

  /// Returns a tuple containing the quotient and remainder obtained by dividing
  /// the given value by this value.
  ///
  /// - Warning: Not yet implemented.
  ///
  /// The resulting quotient must be representable within the bounds of the
  /// type. If the quotient is too large to represent in the type, a runtime
  /// error may occur.
  ///
  /// The following example divides a value that is too large to be represented
  /// using a single `Int` instance by another `Int` value. Because the quotient
  /// is representable as an `Int`, the division succeeds.
  ///
  ///     // 'dividend' represents the value 0x506f70652053616e74612049494949
  ///     let dividend = (22640526660490081, 7959093232766896457 as UInt)
  ///     let divisor = 2241543570477705381
  ///
  ///     let (quotient, remainder) = divisor.dividingFullWidth(dividend)
  ///     // quotient == 186319822866995413
  ///     // remainder == 0
  ///
  ///
  /// - Parameters:
  ///   - dividend: A tuple containing the high and low parts of a double-width integer.
  /// - Returns: A tuple containing the quotient and remainder obtained by
  ///           dividing `dividend` by this value.
  public func dividingFullWidth(_ dividend: (high: Self,
                                             low: Self.Magnitude)) -> (quotient: Self,
                                                                       remainder: Self)
  {
    fatalError("\(#fileID) \(#function) Not yet implemented.")
  }

  // MARK: Operator support

  /// Returns the quotient of dividing the first value by the second.
  ///
  /// For integer types, any remainder of the division is discarded.
  ///
  ///     let x = 21 / 5
  ///     // x == 4
  ///
  /// - Parameters:
  ///   - lhs: The value to divide.
  ///   - rhs: The value to divide `lhs` by. `rhs` must not be zero.
  public static func / (lhs: Self, rhs: Self) -> Self { _divide(lhs, rhs).partialValue }

  /// Divides the first value by the second and stores the quotient in the
  /// left-hand-side variable.
  ///
  /// For integer types, any remainder of the division is discarded.
  ///
  ///     var x = 21
  ///     x /= 5
  ///     // x == 4
  ///
  /// - Parameters:
  ///   - lhs: The value to divide.
  ///   - rhs: The value to divide `lhs` by. `rhs` must not be zero.
  public static func /= (lhs: inout Self, rhs: Self) { lhs = lhs / rhs }

  /// Returns the remainder of dividing the first value by the second.
  ///
  /// The result of the remainder operator (`%`) has the same sign as `lhs` and
  /// has a magnitude less than `rhs.magnitude`.
  ///
  ///     let x = 22 % 5
  ///     // x == 2
  ///     let y = 22 % -5
  ///     // y == 2
  ///     let z = -22 % -5
  ///     // z == -2
  ///
  /// For any two integers `a` and `b`, their quotient `q`, and their remainder
  /// `r`, `a == b * q + r`.
  ///
  /// - Parameters:
  ///   - lhs: The value to divide.
  ///   - rhs: The value to divide `lhs` by. `rhs` must not be zero.
  public static func % (lhs: Self, rhs: Self) -> Self {
    _remainder(lhs, rhs).partialValue
  }

  /// Divides the first value by the second and stores the remainder in the
  /// left-hand-side variable.
  ///
  /// The result has the same sign as `lhs` and has a magnitude less than
  /// `rhs.magnitude`.
  ///
  ///     var x = 22
  ///     x %= 5
  ///     // x == 2
  ///
  ///     var y = 22
  ///     y %= -5
  ///     // y == 2
  ///
  ///     var z = -22
  ///     z %= -5
  ///     // z == -2
  ///
  /// - Parameters:
  ///   - lhs: The value to divide.
  ///   - rhs: The value to divide `lhs` by. `rhs` must not be zero.
  public static func %= (lhs: inout Self, rhs: Self) { lhs = lhs % rhs }

  /// Returns the inverse of the bits set in the argument.
  ///
  /// The bitwise NOT operator (`~`) is a prefix operator that returns a value
  /// in which all the bits of its argument are flipped: Bits that are `1` in
  /// the argument are `0` in the result, and bits that are `0` in the argument
  /// are `1` in the result. This is equivalent to the inverse of a set. For
  /// example:
  ///
  ///     let x: UInt8 = 5        // 0b00000101
  ///     let notX = ~x           // 0b11111010
  ///
  /// Performing a bitwise NOT operation on 0 returns a value with every bit
  /// set to `1`.
  ///
  ///     let allOnes = ~UInt8.min   // 0b11111111
  ///
  /// - Complexity: O(1).
  public static prefix func ~ (x: Self) -> Self { _bitwiseNot(x) }

  /// Returns the result of performing a bitwise AND operation on the two given
  /// values.
  ///
  /// A bitwise AND operation results in a value that has each bit set to `1`
  /// where *both* of its arguments have that bit set to `1`. For example:
  ///
  ///     let x: UInt8 = 5          // 0b00000101
  ///     let y: UInt8 = 14         // 0b00001110
  ///     let z = x & y             // 0b00000100
  ///     // z == 4
  ///
  /// - Parameters:
  ///   - lhs: An integer value.
  ///   - rhs: Another integer value.
  public static func & (lhs: Self, rhs: Self) -> Self { _bitwiseAnd(lhs, rhs) }

  /// Stores the result of performing a bitwise AND operation on the two given
  /// values in the left-hand-side variable.
  ///
  /// A bitwise AND operation results in a value that has each bit set to `1`
  /// where *both* of its arguments have that bit set to `1`. For example:
  ///
  ///     var x: UInt8 = 5          // 0b00000101
  ///     let y: UInt8 = 14         // 0b00001110
  ///     x &= y                    // 0b00000100
  ///
  /// - Parameters:
  ///   - lhs: An integer value.
  ///   - rhs: Another integer value.
  public static func &= (lhs: inout Self, rhs: Self) { lhs = lhs & rhs }

  /// Returns the result of performing a bitwise OR operation on the two given
  /// values.
  ///
  /// A bitwise OR operation results in a value that has each bit set to `1`
  /// where *one or both* of its arguments have that bit set to `1`. For
  /// example:
  ///
  ///     let x: UInt8 = 5          // 0b00000101
  ///     let y: UInt8 = 14         // 0b00001110
  ///     let z = x | y             // 0b00001111
  ///     // z == 15
  ///
  /// - Parameters:
  ///   - lhs: An integer value.
  ///   - rhs: Another integer value.
  public static func | (lhs: Self, rhs: Self) -> Self { _bitwiseOr(lhs, rhs) }

  /// Stores the result of performing a bitwise OR operation on the two given
  /// values in the left-hand-side variable.
  ///
  /// A bitwise OR operation results in a value that has each bit set to `1`
  /// where *one or both* of its arguments have that bit set to `1`. For
  /// example:
  ///
  ///     var x: UInt8 = 5          // 0b00000101
  ///     let y: UInt8 = 14         // 0b00001110
  ///     x |= y                    // 0b00001111
  ///
  /// - Parameters:
  ///   - lhs: An integer value.
  ///   - rhs: Another integer value.
  public static func |= (lhs: inout Self, rhs: Self) { lhs = lhs | rhs }

  /// Returns the result of performing a bitwise XOR operation on the two given
  /// values.
  ///
  /// A bitwise XOR operation, also known as an exclusive OR operation, results
  /// in a value that has each bit set to `1` where *one or the other but not
  /// both* of its arguments had that bit set to `1`. For example:
  ///
  ///     let x: UInt8 = 5          // 0b00000101
  ///     let y: UInt8 = 14         // 0b00001110
  ///     let z = x ^ y             // 0b00001011
  ///     // z == 11
  ///
  /// - Parameters:
  ///   - lhs: An integer value.
  ///   - rhs: Another integer value.
  public static func ^ (lhs: Self, rhs: Self) -> Self { _bitwiseXor(lhs, rhs) }

  /// Stores the result of performing a bitwise XOR operation on the two given
  /// values in the left-hand-side variable.
  ///
  /// A bitwise XOR operation, also known as an exclusive OR operation, results
  /// in a value that has each bit set to `1` where *one or the other but not
  /// both* of its arguments had that bit set to `1`. For example:
  ///
  ///     var x: UInt8 = 5          // 0b00000101
  ///     let y: UInt8 = 14         // 0b00001110
  ///     x ^= y                    // 0b00001011
  ///
  /// - Parameters:
  ///   - lhs: An integer value.
  ///   - rhs: Another integer value.
  public static func ^= (lhs: inout Self, rhs: Self) { lhs = lhs ^ rhs }

  /// Returns the result of shifting a value's binary representation the
  /// specified number of digits to the right.
  ///
  /// The `>>` operator performs a *smart shift*, which defines a result for a
  /// shift of any value.
  ///
  /// - Using a negative value for `rhs` performs a left shift using
  ///   `abs(rhs)`.
  /// - Using a value for `rhs` that is greater than or equal to the bit width
  ///   of `lhs` is an *overshift*. An overshift results in `-1` for a
  ///   negative value of `lhs` or `0` for a nonnegative value.
  /// - Using any other value for `rhs` performs a right shift on `lhs` by that
  ///   amount.
  ///
  /// The following example defines `x` as an instance of `UInt8`, an 8-bit,
  /// unsigned integer type. If you use `2` as the right-hand-side value in an
  /// operation on `x`, the value is shifted right by two bits.
  ///
  ///     let x: UInt8 = 30                 // 0b00011110
  ///     let y = x >> 2
  ///     // y == 7                         // 0b00000111
  ///
  /// If you use `11` as `rhs`, `x` is overshifted such that all of its bits
  /// are set to zero.
  ///
  ///     let z = x >> 11
  ///     // z == 0                         // 0b00000000
  ///
  /// Using a negative value as `rhs` is the same as performing a left shift
  /// using `abs(rhs)`.
  ///
  ///     let a = x >> -3
  ///     // a == 240                       // 0b11110000
  ///     let b = x << 3
  ///     // b == 240                       // 0b11110000
  ///
  /// Right shift operations on negative values "fill in" the high bits with
  /// ones instead of zeros.
  ///
  ///     let q: Int8 = -30                 // 0b11100010
  ///     let r = q >> 2
  ///     // r == -8                        // 0b11111000
  ///
  ///     let s = q >> 11
  ///     // s == -1                        // 0b11111111
  ///
  /// - Parameters:
  ///   - lhs: The value to shift.
  ///   - rhs: The number of bits to shift `lhs` to the right.
  public static func >> <RHS>(lhs: Self, rhs: RHS) -> Self where RHS: BinaryInteger {
    _bitwiseRightShift(lhs, rhs)
  }

  /// Stores the result of shifting a value's binary representation the
  /// specified number of digits to the right in the left-hand-side variable.
  ///
  /// The `>>=` operator performs a *smart shift*, which defines a result for a
  /// shift of any value.
  ///
  /// - Using a negative value for `rhs` performs a left shift using
  ///   `abs(rhs)`.
  /// - Using a value for `rhs` that is greater than or equal to the bit width
  ///   of `lhs` is an *overshift*. An overshift results in `-1` for a
  ///   negative value of `lhs` or `0` for a nonnegative value.
  /// - Using any other value for `rhs` performs a right shift on `lhs` by that
  ///   amount.
  ///
  /// The following example defines `x` as an instance of `UInt8`, an 8-bit,
  /// unsigned integer type. If you use `2` as the right-hand-side value in an
  /// operation on `x`, the value is shifted right by two bits.
  ///
  ///     var x: UInt8 = 30                 // 0b00011110
  ///     x >>= 2
  ///     // x == 7                         // 0b00000111
  ///
  /// If you use `11` as `rhs`, `x` is overshifted such that all of its bits
  /// are set to zero.
  ///
  ///     var y: UInt8 = 30                 // 0b00011110
  ///     y >>= 11
  ///     // y == 0                         // 0b00000000
  ///
  /// Using a negative value as `rhs` is the same as performing a left shift
  /// using `abs(rhs)`.
  ///
  ///     var a: UInt8 = 30                 // 0b00011110
  ///     a >>= -3
  ///     // a == 240                       // 0b11110000
  ///
  ///     var b: UInt8 = 30                 // 0b00011110
  ///     b <<= 3
  ///     // b == 240                       // 0b11110000
  ///
  /// Right shift operations on negative values "fill in" the high bits with
  /// ones instead of zeros.
  ///
  ///     var q: Int8 = -30                 // 0b11100010
  ///     q >>= 2
  ///     // q == -8                        // 0b11111000
  ///
  ///     var r: Int8 = -30                 // 0b11100010
  ///     r >>= 11
  ///     // r == -1                        // 0b11111111
  ///
  /// - Parameters:
  ///   - lhs: The value to shift.
  ///   - rhs: The number of bits to shift `lhs` to the right.
  public static func >>= <RHS>(lhs: inout Self, rhs: RHS) where RHS: BinaryInteger {
    lhs = lhs >> rhs
  }

  /// Returns the result of shifting a value's binary representation the
  /// specified number of digits to the left.
  ///
  /// The `<<` operator performs a *smart shift*, which defines a result for a
  /// shift of any value.
  ///
  /// - Using a negative value for `rhs` performs a right shift using
  ///   `abs(rhs)`.
  /// - Using a value for `rhs` that is greater than or equal to the bit width
  ///   of `lhs` is an *overshift*, resulting in zero.
  /// - Using any other value for `rhs` performs a left shift on `lhs` by that
  ///   amount.
  ///
  /// The following example defines `x` as an instance of `UInt8`, an 8-bit,
  /// unsigned integer type. If you use `2` as the right-hand-side value in an
  /// operation on `x`, the value is shifted left by two bits.
  ///
  ///     let x: UInt8 = 30                 // 0b00011110
  ///     let y = x << 2
  ///     // y == 120                       // 0b01111000
  ///
  /// If you use `11` as `rhs`, `x` is overshifted such that all of its bits
  /// are set to zero.
  ///
  ///     let z = x << 11
  ///     // z == 0                         // 0b00000000
  ///
  /// Using a negative value as `rhs` is the same as performing a right shift
  /// with `abs(rhs)`.
  ///
  ///     let a = x << -3
  ///     // a == 3                         // 0b00000011
  ///     let b = x >> 3
  ///     // b == 3                         // 0b00000011
  ///
  /// - Parameters:
  ///   - lhs: The value to shift.
  ///   - rhs: The number of bits to shift `lhs` to the left.
  public static func << <RHS>(lhs: Self, rhs: RHS) -> Self where RHS: BinaryInteger {
    _bitwiseLeftShift(lhs, rhs)
  }

  /// Stores the result of shifting a value's binary representation the
  /// specified number of digits to the left in the left-hand-side variable.
  ///
  /// The `<<` operator performs a *smart shift*, which defines a result for a
  /// shift of any value.
  ///
  /// - Using a negative value for `rhs` performs a right shift using
  ///   `abs(rhs)`.
  /// - Using a value for `rhs` that is greater than or equal to the bit width
  ///   of `lhs` is an *overshift*, resulting in zero.
  /// - Using any other value for `rhs` performs a left shift on `lhs` by that
  ///   amount.
  ///
  /// The following example defines `x` as an instance of `UInt8`, an 8-bit,
  /// unsigned integer type. If you use `2` as the right-hand-side value in an
  /// operation on `x`, the value is shifted left by two bits.
  ///
  ///     var x: UInt8 = 30                 // 0b00011110
  ///     x <<= 2
  ///     // x == 120                       // 0b01111000
  ///
  /// If you use `11` as `rhs`, `x` is overshifted such that all of its bits
  /// are set to zero.
  ///
  ///     var y: UInt8 = 30                 // 0b00011110
  ///     y <<= 11
  ///     // y == 0                         // 0b00000000
  ///
  /// Using a negative value as `rhs` is the same as performing a right shift
  /// with `abs(rhs)`.
  ///
  ///     var a: UInt8 = 30                 // 0b00011110
  ///     a <<= -3
  ///     // a == 3                         // 0b00000011
  ///
  ///     var b: UInt8 = 30                 // 0b00011110
  ///     b >>= 3
  ///     // b == 3                         // 0b00000011
  ///
  /// - Parameters:
  ///   - lhs: The value to shift.
  ///   - rhs: The number of bits to shift `lhs` to the left.
  public static func <<= <RHS>(lhs: inout Self, rhs: RHS) where RHS: BinaryInteger {
    lhs = lhs << rhs
  }

  /// Returns the result of shifting a value's binary representation the
  /// specified number of digits to the right, masking the shift amount to the
  /// type's bit width.
  ///
  /// Use the masking right shift operator (`&>>`) when you need to perform a
  /// shift and are sure that the shift amount is in the range
  /// `0..<lhs.bitWidth`. Before shifting, the masking right shift operator
  /// masks the shift to this range. The shift is performed using this masked
  /// value.
  ///
  /// The following example defines `x` as an instance of `UInt8`, an 8-bit,
  /// unsigned integer type. If you use `2` as the right-hand-side value in an
  /// operation on `x`, the shift amount requires no masking.
  ///
  ///     let x: UInt8 = 30                 // 0b00011110
  ///     let y = x &>> 2
  ///     // y == 7                         // 0b00000111
  ///
  /// However, if you use `8` as the shift amount, the method first masks the
  /// shift amount to zero, and then performs the shift, resulting in no change
  /// to the original value.
  ///
  ///     let z = x &>> 8
  ///     // z == 30                        // 0b00011110
  ///
  /// If the bit width of the shifted integer type is a power of two, masking
  /// is performed using a bitmask; otherwise, masking is performed using a
  /// modulo operation.
  ///
  /// - Parameters:
  ///   - lhs: The value to shift.
  ///   - rhs: The number of bits to shift `lhs` to the right. If `rhs` is
  ///     outside the range `0..<lhs.bitWidth`, it is masked to produce a
  ///     value within that range.
  public static func &>> (lhs: Self, rhs: Self) -> Self {
    _bitwiseMaskingRightShift(lhs, rhs)
  }

  /// Calculates the result of shifting a value's binary representation the
  /// specified number of digits to the right, masking the shift amount to the
  /// type's bit width, and stores the result in the left-hand-side variable.
  ///
  /// The `&>>=` operator performs a *masking shift*, where the value passed as
  /// `rhs` is masked to produce a value in the range `0..<lhs.bitWidth`. The
  /// shift is performed using this masked value.
  ///
  /// The following example defines `x` as an instance of `UInt8`, an 8-bit,
  /// unsigned integer type. If you use `2` as the right-hand-side value in an
  /// operation on `x`, the shift amount requires no masking.
  ///
  ///     var x: UInt8 = 30                 // 0b00011110
  ///     x &>>= 2
  ///     // x == 7                         // 0b00000111
  ///
  /// However, if you use `19` as `rhs`, the operation first bitmasks `rhs` to
  /// `3`, and then uses that masked value as the number of bits to shift `lhs`.
  ///
  ///     var y: UInt8 = 30                 // 0b00011110
  ///     y &>>= 19
  ///     // y == 3                         // 0b00000011
  ///
  /// - Parameters:
  ///   - lhs: The value to shift.
  ///   - rhs: The number of bits to shift `lhs` to the right. If `rhs` is
  ///     outside the range `0..<lhs.bitWidth`, it is masked to produce a
  ///     value within that range.
  public static func &>>= (lhs: inout Self, rhs: Self) { lhs = lhs &>> rhs }

  /// Returns the result of shifting a value's binary representation the
  /// specified number of digits to the left, masking the shift amount to the
  /// type's bit width.
  ///
  /// Use the masking left shift operator (`&<<`) when you need to perform a
  /// shift and are sure that the shift amount is in the range
  /// `0..<lhs.bitWidth`. Before shifting, the masking left shift operator
  /// masks the shift to this range. The shift is performed using this masked
  /// value.
  ///
  /// The following example defines `x` as an instance of `UInt8`, an 8-bit,
  /// unsigned integer type. If you use `2` as the right-hand-side value in an
  /// operation on `x`, the shift amount requires no masking.
  ///
  ///     let x: UInt8 = 30                 // 0b00011110
  ///     let y = x &<< 2
  ///     // y == 120                       // 0b01111000
  ///
  /// However, if you use `8` as the shift amount, the method first masks the
  /// shift amount to zero, and then performs the shift, resulting in no change
  /// to the original value.
  ///
  ///     let z = x &<< 8
  ///     // z == 30                        // 0b00011110
  ///
  /// If the bit width of the shifted integer type is a power of two, masking
  /// is performed using a bitmask; otherwise, masking is performed using a
  /// modulo operation.
  ///
  /// - Parameters:
  ///   - lhs: The value to shift.
  ///   - rhs: The number of bits to shift `lhs` to the left. If `rhs` is
  ///     outside the range `0..<lhs.bitWidth`, it is masked to produce a
  ///     value within that range.
  public static func &<< (lhs: Self, rhs: Self) -> Self {
    _bitwiseMaskingLeftShift(lhs, rhs)
  }

  /// Returns the result of shifting a value's binary representation the
  /// specified number of digits to the left, masking the shift amount to the
  /// type's bit width, and stores the result in the left-hand-side variable.
  ///
  /// The `&<<=` operator performs a *masking shift*, where the value used as
  /// `rhs` is masked to produce a value in the range `0..<lhs.bitWidth`. The
  /// shift is performed using this masked value.
  ///
  /// The following example defines `x` as an instance of `UInt8`, an 8-bit,
  /// unsigned integer type. If you use `2` as the right-hand-side value in an
  /// operation on `x`, the shift amount requires no masking.
  ///
  ///     var x: UInt8 = 30                 // 0b00011110
  ///     x &<<= 2
  ///     // x == 120                       // 0b01111000
  ///
  /// However, if you pass `19` as `rhs`, the method first bitmasks `rhs` to
  /// `3`, and then uses that masked value as the number of bits to shift `lhs`.
  ///
  ///     var y: UInt8 = 30                 // 0b00011110
  ///     y &<<= 19
  ///     // y == 240                       // 0b11110000
  ///
  /// - Parameters:
  ///   - lhs: The value to shift.
  ///   - rhs: The number of bits to shift `lhs` to the left. If `rhs` is
  ///     outside the range `0..<lhs.bitWidth`, it is masked to produce a
  ///     value within that range.
  public static func &<<= (lhs: inout Self, rhs: Self) { lhs = lhs &<< rhs }
}

// MARK: - Supporting Functions

// MARK: Floating point conversions

/// Initializes an instance of `UInt128` from a binary floating point value.
/// - Parameter source: The floating point value
/// - Returns: The nearest approximation for the value of `source` as `UInt128`
private func _convertFloatingPoint<T>(_ source: T) -> (value: UInt128, isExact: Bool)
  where T: BinaryFloatingPoint
{
  var source = source
  var value = UInt128()
  var shift = UInt64()
  let base: T = 65536
  let exact = source - source.truncatingRemainder(dividingBy: 10) == source
  while source > 0, shift < 128 {
    let remainder = source.truncatingRemainder(dividingBy: base).rounded(.towardZero)
    let bits: UInt64
    let exponent = UInt(remainder.exponentBitPattern)
    switch MemoryLayout<T>.size {
      case 4:
        let significand = UInt32(remainder.significandBitPattern)
        let float = Float(sign: .plus,
                          exponentBitPattern: exponent,
                          significandBitPattern: significand)
        bits = UInt64(float)
      default:
        let significand = UInt64(remainder.significandBitPattern)
        let double = Double(sign: .plus,
                            exponentBitPattern: exponent,
                            significandBitPattern: significand)
        bits = UInt64(double)
    }
    
    switch shift {
      case 0...63: value.low |= bits << shift
      case 64...127: value.high |= bits << (shift &- 64)
      default: unreachable()
    }
    shift = shift &+ 16
    source /= base
    source.round(.towardZero)
  }
  return (value, exact)
}

// MARK: Addition and subtraction

/// Adds together two `UInt128` values.
/// - Parameters:
///   - lhs: The first summand.
///   - rhs: The second summand.
/// - Returns: The result of adding `lhs` to `rhs` and whether there was overflow.
private func _add(_ lhs: UInt128, _ rhs: UInt128) -> (partialValue: UInt128,
                                                      overflow: Bool)
{
  var partialValue = UInt128()

  // Split lows into two 32 bit numbers stored in two 64 bit numbers
  var x = lhs.low & 0xFFFFFFFF
  var y = rhs.low & 0xFFFFFFFF

  var sum = x &+ y
  var carry = sum >> 32

  partialValue.low = sum & 0xFFFFFFFF

  x = lhs.low >> 32
  y = rhs.low >> 32

  sum = x &+ y &+ carry
  carry = sum >> 32

  partialValue.low |= sum << 32

  x = lhs.high & 0xFFFFFFFF
  y = rhs.high & 0xFFFFFFFF

  sum = x &+ y &+ carry
  carry = sum >> 32

  partialValue.high = sum & 0xFFFFFFFF

  x = lhs.high >> 32
  y = rhs.high >> 32

  sum = x &+ y &+ carry
  carry = sum >> 32

  partialValue.high |= sum << 32

  return (partialValue, carry > 0)
}

/// Subtracts one value from the other.
/// - Parameters:
///   - lhs: The quantity from which to subtract.
///   - rhs: The amount to be subtracted.
/// - Returns: The result of subtracting `rhs` from `lhs`and whether there was overflow.
private func _subtract(_ lhs: UInt128, _ rhs: UInt128) -> (partialValue: UInt128,
                                                           overflow: Bool)
{
  var partialValue = UInt128()

  var (result, overflow) = lhs.low.subtractingReportingOverflow(rhs.low)
  partialValue.low = result

  (result, overflow) = (overflow && lhs.high == 0
    ? UInt64.max
    : (overflow
      ? lhs.high &- 1
      : lhs.high)).subtractingReportingOverflow(rhs.high)

  partialValue.high = result

  return (partialValue, overflow)
}

// MARK: - Division and multiplication

/// Calculates the quotient and remainder when dividing one value by another.
/// - Parameters:
///   - lhs: The dividend.
///   - rhs: The devisor.
/// - Returns: The result of dividing `lhs` by `rhs`.
private func _quotientAndRemainder(_ lhs: UInt128,
                                   _ rhs: UInt128) -> (quotient: UInt128,
                                                       remainder: UInt128)
{
  // Check that the result isn't all remainder.
  guard lhs >= rhs else { return (0, lhs) }

  // Capture the two values in some mutable variables.
  var remainder = lhs, α = rhs

  // Calculate the largest doubling, storing the result in `α`.
  while remainder - α >= α { α += α }

  // Subtract the largest doubling.
  remainder = remainder - α

  // Initialize a variable for accumulating the quotient.
  var quotient: UInt128 = 1

  // Iterate while `α` remains greater than the divisor.
  while α != rhs {
    // Divide `α` in half.
    α >>= 1

    // Double `quotient`.
    quotient += quotient

    // Check whether `remainder` is greater than the value remaining in `α`.
    if α <= remainder {
      remainder -= α // Take `α` out of the remainder.
      quotient += 1 // And increment `quotient`.
    }
  }

  return (quotient, remainder)
}

/// Calculates the quotient when dividing one value by another.
/// - Warning: Overflow detection not yet implemented.
/// - Parameters:
///   - lhs: The dividend.
///   - rhs: The devisor.
/// - Returns: The quotient when dividing `lhs` by `rhs` and whether there was overflow.
private func _divide(_ lhs: UInt128, _ rhs: UInt128) -> (partialValue: UInt128,
                                                         overflow: Bool)
{
  (_quotientAndRemainder(lhs, rhs).quotient, false)
}

/// Calculates the remainder when dividing one value by another.
/// - Warning: Overflow detection not yet implemented.
/// - Parameters:
///   - lhs: The dividend.
///   - rhs: The devisor.
/// - Returns: The remainder when dividing `lhs` by `rhs` and whether there was overflow.
private func _remainder(_ lhs: UInt128, _ rhs: UInt128) -> (partialValue: UInt128,
                                                            overflow: Bool)
{
  (_quotientAndRemainder(lhs, rhs).remainder, false)
}

/// Calculates the product when multiplying one value by another.
/// - Warning: Overflow detection not yet implemented.
/// - Parameters:
///   - lhs: The first multiplicand.
///   - rhs: The second multiplicand.
/// - Returns: The product when multiplying `lhs` by `rhs` and whether there was overflow.
private func _multiply(_ lhs: UInt128, _ rhs: UInt128) -> (partialValue: UInt128,
                                                           overflow: Bool)
{
  let pLL = (lhs.low & 0xFFFFFFFF) * (rhs.low & 0xFFFFFFFF)
  var pLH = (lhs.low & 0xFFFFFFFF) * (rhs.low >> 32)
  var pHL = (lhs.low >> 32) * (rhs.low & 0xFFFFFFFF)
  let pHH = (lhs.low >> 32) * (rhs.low >> 32)

  var lowpLL = pLL & 0xFFFFFFFF
  var carry = (pLL >> 32) &+ (pLH & 0xFFFFFFFF)

  var highpLL = carry >> 32
  carry = (carry & 0xFFFFFFFF) &+ (pHL & 0xFFFFFFFF)

  highpLL = highpLL &+ (carry >> 32)
  lowpLL |= carry << 32

  highpLL = highpLL &+ (pLH >> 32)
  carry = highpLL >> 32

  highpLL &= 0xFFFFFFFF
  highpLL = highpLL &+ (pHL >> 32) &+ pHH &+ carry

  var overflow: Bool = false
  var didOverflow = false

  (pLH, didOverflow) = lhs.low.multipliedReportingOverflow(by: rhs.high)
  if didOverflow { overflow = true }

  (pHL, didOverflow) = lhs.high.multipliedReportingOverflow(by: rhs.low)
  if didOverflow { overflow = true }

  var partialValue = UInt128(low: lowpLL, high: 0)
  let mask: UInt64 = 0xFFFFFFFF

  var s = (highpLL & mask) &+ (pLH & mask) &+ (pHL & mask)
  var c = s >> 32

  partialValue.high |= s & mask
  s = (highpLL >> 32) &+ (pLH >> 32) &+ (pHL >> 32) &+ c
  c = s >> 32

  partialValue.high |= s << 32

  overflow = overflow || c > 0

  return (partialValue, overflow)
}

// MARK: Bitwise arithmetic

/// Performs a bitwise not `~` operation on the specified value.
/// - Parameter value: The value to invert.
/// - Returns: `value` with its bits inverted.
private func _bitwiseNot(_ value: UInt128) -> UInt128 {
  UInt128(low: ~value.low, high: ~value.high)
}

/// Performs a bitwise and `&` operation on two values.
/// - Parameters:
///   - lhs: The first summand.
///   - rhs: The second summand.
/// - Returns: The bitwise and of `lhs` with `rhs`.
private func _bitwiseAnd(_ lhs: UInt128, _ rhs: UInt128) -> UInt128 {
  UInt128(low: lhs.low & rhs.low, high: lhs.high & rhs.high)
}

/// Performs a bitwise or `|` operation on two values.
/// - Parameters:
///   - lhs: The first value.
///   - rhs: The second value.
/// - Returns: The bitwise or of `lhs` with `rhs`.
private func _bitwiseOr(_ lhs: UInt128, _ rhs: UInt128) -> UInt128 {
  UInt128(low: lhs.low | rhs.low, high: lhs.high | rhs.high)
}

/// Performs a bitwise xor `^` operation on two values.
/// - Parameters:
///   - lhs: The first value.
///   - rhs: The second value.
/// - Returns: The bitwise xor of `lhs` with `rhs`.
private func _bitwiseXor(_ lhs: UInt128, _ rhs: UInt128) -> UInt128 {
  UInt128(low: lhs.low ^ rhs.low, high: lhs.high ^ rhs.high)
}

// MARK: Bitwise shifting

/// Performs a bitwise right shift `>>`.
/// - Parameters:
///   - lhs: The value to shift.
///   - rhs: The amount by which to shift `lhs`.
/// - Returns: The result of shifting `lhs` by `rhs`.
private func _bitwiseRightShift<T>(_ lhs: UInt128, _ rhs: T) -> UInt128
  where T: BinaryInteger
{
  let low: UInt64, high: UInt64
  switch Int(rhs) {
    case 0:
      low = lhs.low
      high = lhs.high
    case let shift where (64 ..< 128).contains(shift):
      low = lhs.high >> (shift &- 64)
      high = 0
    case let shift:
      low = (lhs.low >> shift) | (lhs.high << (64 &- shift))
      high = lhs.high >> shift
  }
  return UInt128(low: low, high: high)
}

/// Performs a bitwise left shift `<<`.
/// - Parameters:
///   - lhs: The value to shift.
///   - rhs: The amount by which to shift `lhs`.
/// - Returns: The result of shifting `lhs` by `rhs`.
private func _bitwiseLeftShift<T>(_ lhs: UInt128, _ rhs: T) -> UInt128
  where T: BinaryInteger
{
  let low: UInt64, high: UInt64
  switch Int(rhs) {
    case 0:
      low = lhs.low
      high = lhs.high
    case let shift where (64 ..< 128).contains(shift):
      low = 0
      high = lhs.low << (shift &- 64)
    case let shift:
      low = lhs.low << shift
      high = (lhs.high << shift) | lhs.low >> (64 &- shift)
  }
  return UInt128(low: low, high: high)
}

/// Performs a masking bitwise right shift `&>>`.
/// - Warning: Not currently masking.
/// - Parameters:
///   - lhs: The value to shift.
///   - rhs: The amount by which to shift `lhs`.
/// - Returns: The result of shifting `lhs` by `rhs`.
private func _bitwiseMaskingRightShift<T>(_ lhs: UInt128, _ rhs: T) -> UInt128
  where T: BinaryInteger
{
  _bitwiseRightShift(lhs, rhs)
}

/// Performs a masking bitwise left shift `<<`.
/// - Warning: Not currently masking.
/// - Parameters:
///   - lhs: The value to shift.
///   - rhs: The amount by which to shift `lhs`.
/// - Returns: The result of shifting `lhs` by `rhs`.
private func _bitwiseMaskingLeftShift<T>(_ lhs: UInt128, _ rhs: T) -> UInt128
  where T: BinaryInteger
{
  _bitwiseLeftShift(lhs, rhs)
}

// MARK: Comparisons

/// Performs a `<` comparison for two values.
/// - Parameters:
///   - lhs: The left hand side of the equation.
///   - rhs: The right hand side of the equation.
/// - Returns: `true` if `lhs < rhs` and `false` otherwise.
private func _isLessThan(_ lhs: UInt128, _ rhs: UInt128) -> Bool {
  lhs.high < rhs.high || lhs.high == rhs.high && lhs.low < rhs.low
}

/// Performs an equality comparison for two values.
/// - Parameters:
///   - lhs: The first value.
///   - rhs: The second value.
/// - Returns: `true` if `lhs == rhs` and `false` otherwise.
private func _isEqual(_ lhs: UInt128, _ rhs: UInt128) -> Bool {
  lhs.high == rhs.high && lhs.low == rhs.low
}

// MARK: - Extending other types

public extension String {
  /// Initializing a string with the textual representation of an `UInt128` value.
  /// - Parameters:
  ///   - value: The value to be described by the string.
  ///   - radix: The numeric base the description should employ. Supported values for
  ///            `radix` include 2, 8, 4, 10, and 16
  ///   - uppercase: Whether any letters that appear should be uppercase.
  init(_ value: UInt128, radix: Int, uppercase: Bool = false) {
    guard value.high > 0 else {
      self = String(value.low, radix: radix, uppercase: uppercase)
      return
    }
    switch radix {
      case 32:
        let high = String(value.high, radix: radix, uppercase: uppercase)
        let leadingZeros = String(repeating: "0", count: countLeadingZeros(value.low) / 16)
        let low = String(value.low, radix: radix, uppercase: uppercase)
        self = "\(high)\(leadingZeros)\(low)"

      case 16:
        let high = String(value.high, radix: radix, uppercase: uppercase)
        let leadingZeros = String(repeating: "0", count: countLeadingZeros(value.low) / 8)
        let low = String(value.low, radix: radix, uppercase: uppercase)
        self = "\(high)\(leadingZeros)\(low)"

      case 8:
        let high = String(value.high, radix: radix, uppercase: uppercase)
        let leadingZeros = String(repeating: "0", count: countLeadingZeros(value.low) / 4)
        let low = String(value.low, radix: radix, uppercase: uppercase)
        self = "\(high)\(leadingZeros)\(low)"

      case 4:
        let high = String(value.high, radix: radix, uppercase: uppercase)
        let leadingZeros = String(repeating: "0", count: countLeadingZeros(value.low) / 2)
        let low = String(value.low, radix: radix, uppercase: uppercase)
        self = "\(high)\(leadingZeros)\(low)"

      case 2:
        let high = String(value.high, radix: radix, uppercase: uppercase)
        let leadingZeros = String(repeating: "0", count: countLeadingZeros(value.low))
        let low = String(value.low, radix: radix, uppercase: uppercase)
        self = "\(high)\(leadingZeros)\(low)"

      case 10:
        let n7 = value.high >> 48
        let n6 = (value.high >> 32) & 0xFFFF
        let n5 = (value.high >> 16) & 0xFFFF
        let n4 = value.high & 0xFFFF
        let n3 = value.low >> 48
        let n2 = (value.low >> 32) & 0xFFFF
        let n1 = (value.low >> 16) & 0xFFFF
        let n0 = value.low & 0xFFFF

        var d8 = n7 * 51
        var d7 = n7 * 9229
        d7 = d7 &+ n6 * 7
        var d6 = n7 * 6858
        d6 = d6 &+ n6 * 9228
        d6 = d6 &+ n5
        var d5 = n7 * 5348
        d5 = d5 &+ n6 * 1625
        d5 = d5 &+ n5 * 2089
        var d4 = n7 * 2762
        d4 = d4 &+ n6 * 1426
        d4 = d4 &+ n5 * 2581
        d4 = d4 &+ n4 * 1844
        var d3 = n7 * 8530
        d3 = d3 &+ n6 * 4337
        d3 = d3 &+ n5 * 9614
        d3 = d3 &+ n4 * 6744
        d3 = d3 &+ n3 * 281
        var d2 = n7 * 4963
        d2 = d2 &+ n6 * 5935
        d2 = d2 &+ n5 * 6291
        d2 = d2 &+ n4 * 737
        d2 = d2 &+ n3 * 4749
        d2 = d2 &+ n2 * 42
        var d1 = n7 * 2922
        d1 = d1 &+ n6 * 4395
        d1 = d1 &+ n5 * 7470
        d1 = d1 &+ n4 * 955
        d1 = d1 &+ n3 * 7671
        d1 = d1 &+ n2 * 9496
        d1 = d1 &+ n1 * 6
        var d0 = n7 * 96
        d0 = d0 &+ n6 * 336
        d0 = d0 &+ n5 * 6176
        d0 = d0 &+ n4 * 1616
        d0 = d0 &+ n3 * 656
        d0 = d0 &+ n2 * 7296
        d0 = d0 &+ n1 * 5536
        d0 = d0 &+ n0

        var carry = d0 / 10000
        d0 %= 10000

        d1 = d1 &+ carry
        carry = d1 / 10000
        d1 %= 10000

        d2 = d2 &+ carry
        carry = d2 / 10000
        d2 %= 10000

        d3 = d3 &+ carry
        carry = d3 / 10000
        d3 %= 10000

        d4 = d4 &+ carry
        carry = d4 / 10000
        d4 %= 10000

        d5 = d5 &+ carry
        carry = d5 / 10000
        d5 %= 10000

        d6 = d6 &+ carry
        carry = d6 / 10000
        d6 %= 10000

        d7 = d7 &+ carry
        carry = d7 / 10000
        d7 %= 10000

        d8 = d8 &+ carry

        var foundFirstNonZero = false
        var strings: [String] = []

        for digit in [d8, d7, d6, d5, d4, d3, d2, d1, d0] {
          switch digit {
            case 0:
              strings.append(foundFirstNonZero ? "0000" : "")
            default:
              switch foundFirstNonZero {
                case true:
                  strings.append(String(format: "%04u", digit))
                case false:
                  foundFirstNonZero = true
                  strings.append(digit.description)
              }
          }
        }

        guard strings.last?.isEmpty != true else { self = "0"; return }
        self = strings.joined(separator: "")

      default:
        // TODO: Fill in the gaps for bases 3 through 32
        fatalError("\(#function) not yet implemented for bases other than 2, 8, 4, 10, and 16")
    }
  }
}

public extension Double {
  /// Initializing with a `UInt128` value.
  /// - Parameter value: The value with which to initialize the `Double`.
  init(_ value: UInt128) { self = Double(value.high) * exp2(64.0) + Double(value.low) }
}
