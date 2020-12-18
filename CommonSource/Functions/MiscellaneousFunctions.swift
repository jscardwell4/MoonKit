//
//  MiscellaneousFunctions.swift
//  MoonKit
//
//  Created by Jason Cardwell on 5/8/15.
//  Copyright (c) 2015 Jason Cardwell. All rights reserved.
//

import Foundation
import UIKit

public func repeatWith(initial: Int, shouldContinue: (Int) -> Bool, next: (Int, Int) -> Int, by: Int = 1, block: (Int) -> Void) {
  var i = initial
  repeat {
    block(i)
    i = next(i, by)
  } while shouldContinue(i)
}

public func unreachable(_ message: StaticString? = nil) -> Never {
  fatalError("The impossible happened!!! \(message ?? "")")
}

public func branch(_ tuples: (() -> Bool, () -> Void)...) {
  for (predicate, action) in tuples {
    guard !predicate() else { action(); return }
  }
}

@inline(__always)
public func synchronized<R>(_ lock: AnyObject, block: () -> R) -> R {
  objc_sync_enter(lock)
  defer { objc_sync_exit(lock) }
  return block()
}

/**
nonce

- returns: String
*/
public func nonce() -> String { return Foundation.UUID().uuidString }

public func dumpObjectIntrospection(_ obj: AnyObject, includeInheritance: Bool = false) {
  func descriptionForObject(_ objClass: AnyClass, inherited: Bool) -> String {
    var string = ""

    let objClassName = String(cString: class_getName(objClass))

    string += inherited ? "inherited from \(objClassName):\n" : "Class: \(objClassName)\n"

    if !inherited {
      string += "size: \(class_getInstanceSize(objClass))\n"
      //      if let ivarLayout = String(UTF8String: UnsafePointer(class_getIvarLayout(objClass)))
      //        where !ivarLayout.isEmpty {
      //        string += "ivar layout: \(ivarLayout)\n"
      //      }
      //      if let weakIvarLayout = String(UTF8String: UnsafePointer(class_getWeakIvarLayout(objClass)))
      //        where !weakIvarLayout.isEmpty {
      //        string += "weak ivar layout: \(weakIvarLayout)\n"
      //      }
    }

    var outCount: UInt32 = 0
    let objClassIvars = class_copyIvarList(object_getClass(objClass), &outCount)
    if outCount > 0 {
      string += "class variables:\n"
      for ivar in UnsafeMutableBufferPointer(start: objClassIvars, count: numericCast(outCount)) {
        let ivarName = String(cString: ivar_getName(ivar)!, encoding: String.Encoding.utf8)
        let ivarTypeEncoding = String(cString: ivar_getTypeEncoding(ivar)!,
                                      encoding: String.Encoding.utf8)
        string += "\t\(String(describing: ivarName)) : \(String(describing: ivarTypeEncoding))\n"
      }
    }
    outCount = 0
    let objClassInstanceIvars = class_copyIvarList(objClass, &outCount)
    if outCount > 0 {
      string += "instance variables:\n"
      for ivar in UnsafeMutableBufferPointer(start: objClassInstanceIvars, count: numericCast(outCount)) {
        let ivarName = String(cString: ivar_getName(ivar)!, encoding: String.Encoding.utf8)
        let ivarTypeEncoding = String(cString: ivar_getTypeEncoding(ivar)!,
                                      encoding: String.Encoding.utf8)
        string += "\t\(String(describing: ivarName)) : \(String(describing: ivarTypeEncoding))\n"
      }
    }

    outCount = 0
    let objClassProperties = class_copyPropertyList(objClass, &outCount)
    if outCount > 0 {
      string += "properties:\n"
      for property in UnsafeMutableBufferPointer(start: objClassProperties, count: numericCast(outCount)) {
        let propertyName = String(cString: property_getName(property),
                                  encoding: String.Encoding.utf8)
        let propertyAttributes = String(cString:  property_getAttributes(property)!,
                                        encoding: String.Encoding.utf8)
        string += "\t\(String(describing: propertyName)) : \(String(describing: propertyAttributes))\n"
      }
    }

    outCount = 0
    let objClassMethods = class_copyMethodList(object_getClass(objClass), &outCount)
    if outCount > 0 {
      string += "class methods:\n"
      for method in UnsafeMutableBufferPointer(start: objClassMethods, count: numericCast(outCount)) {
        let methodDescription = method_getDescription(method).pointee
        let returnType = String(validatingUTF8: method_copyReturnType(method))!
        let allTypes = String(validatingUTF8: methodDescription.types!)!
        let argumentTypes = allTypes[allTypes.index(allTypes.startIndex, offsetBy: returnType.count) ..< allTypes.endIndex]
        string += "\t\(String(describing: methodDescription.name))  -> \(returnType)  arguments (\(method_getNumberOfArguments(method))): \(argumentTypes)\n"
      }
    }

    outCount = 0
    let objClassInstanceMethods = class_copyMethodList(objClass, &outCount)
    if outCount > 0 {
      string += "instance methods:\n"
      for method in UnsafeMutableBufferPointer(start: objClassInstanceMethods, count: numericCast(outCount)) {
        let methodDescription = method_getDescription(method).pointee
        let returnType = String(validatingUTF8: method_copyReturnType(method))!
        let allTypes = String(validatingUTF8: methodDescription.types!)!
        let argumentTypes = allTypes[allTypes.index(allTypes.startIndex, offsetBy: returnType.count) ..< allTypes.endIndex]
        string += "\t\(String(describing: methodDescription.name))  -> \(returnType)  arguments (\(method_getNumberOfArguments(method))): \(argumentTypes)\n"
      }
    }

    outCount = 0
    let objClassProtocols = class_copyPropertyList(objClass, &outCount)
    if outCount > 0 {
      string += "conforms to:\n"
      for `protocol` in UnsafeMutableBufferPointer(start: objClassProtocols, count: numericCast(outCount)) {
        let protocolName = String(cString: property_getName(`protocol`),
                                        encoding: String.Encoding.utf8)
        let protocolAttributes = String(cString:  property_getAttributes(`protocol`)!,
                                        encoding: String.Encoding.utf8)
        string += "\t\(String(describing: protocolName)) : \(String(describing: protocolAttributes))\n"
      }
    }

    return string
  }

  var currentClass: AnyClass = type(of: obj).self

  // dump the object's class
  print(descriptionForObject(currentClass, inherited: false))

  guard includeInheritance else { return }

  while let superclass = class_getSuperclass(currentClass) {
    print(descriptionForObject(superclass, inherited: true))
    currentClass = superclass
  }
  
}

public func pointerCast<T, U>(_ pointer: UnsafeMutablePointer<T>) -> UnsafeMutablePointer<U> {
  return UnsafeMutablePointer<U>(pointer._rawValue)
}

public func pointerCast<T, U>(_ pointer: UnsafePointer<T>) -> UnsafePointer<U> {
  return UnsafePointer<U>(pointer._rawValue)
}

//public func pointerCast<T>(_ pointer: UnsafeMutablePointer<T>) -> UnsafePointer<T> {
//  return UnsafePointer<T>(pointer._rawValue)
//}

//public func pointerCast<T>(_ pointer: UnsafePointer<T>) -> UnsafeMutablePointer<T> {
//  return UnsafeMutablePointer<T>(pointer._rawValue)
//}


public func <<- <T,U,R>(_ lhs: (T) throws -> R, rhs: (T,U)) rethrows -> U {
  _ = try lhs(rhs.0)
  return rhs.1
}

/**
 No-op function intended to be used as a more noticeable way to force instantiation of lazy properties

 - parameter t: T
*/
@inline(never)
public func touch<T>(_ t: T) {}


//@inline(__always) public prefix func |<T:SignedNumber>(_ value: T) -> T { return value }
//public postfix func |<T:SignedNumber>(_ value: T) -> T { return abs(value) }

/**
typeName:

- parameter object: Any

- returns: String
*/
public func typeName(_ object: Any) -> String { return "\(type(of: object))" }

/** Ticks since last device reboot */
public var hostTicks: UInt64 { return mach_absolute_time() }

/** Nanoseconds since last reboot */
//public var hostTime: UInt64 {
//  let ratio = nanosecondsPerHostTick
//  return hostTicks * ratio.numerator.low / ratio.denominator.low
//}

/** Ratio that represents the number of nanoseconds per host tick */
//public var nanosecondsPerHostTick: Ratio {
//  var info = mach_timebase_info()
//  mach_timebase_info(&info)
//  return Int64(info.numer)∶Int64(info.denom)
//}


