//
//  HostTimeBase.swift
//  MoonKit
//
//  Created by Jason Cardwell on 1/25/18.
//  Copyright © 2018 Moondeer Studios. All rights reserved.
//
import Foundation

public final class HostTimeBase {

  public static let shared = HostTimeBase()

  public let frequency: Float64
  public let inverseFrequency: Float64
  public let minimumDelta: UInt32

  private let sToNanosNumerator: UInt32
  private let sToNanosDenominator: UInt32

  private init() {

    let timeBaseInfo = mach_timebase_info()
    minimumDelta = 1
    sToNanosNumerator = timeBaseInfo.numer
    sToNanosDenominator = timeBaseInfo.denom

    frequency = Float64(sToNanosDenominator) / Float64(sToNanosNumerator) * 1e9
    inverseFrequency = 1 / frequency
  }

  public func convertToNanos(hostTime: UInt64) -> UInt64 {
    return multiplyByRatio(multiplicand: hostTime,
                           numerator: sToNanosNumerator,
                           denominator: sToNanosDenominator)
  }

  public func convertFromNanos(nanos: UInt64) -> UInt64 {
    return multiplyByRatio(multiplicand: nanos,
                           numerator: sToNanosDenominator,
                           denominator: sToNanosNumerator)
  }

  public var currentTime: UInt64 { return mach_absolute_time() }

  public var currentTimeInNanos: UInt64 { return convertToNanos(hostTime: currentTime) }

  public func absoluteHostDeltaToNanos(startTime: UInt64, endTime: UInt64) -> UInt64 {
    return convertToNanos(hostTime: startTime <= endTime
                                      ? endTime - startTime
                                      : startTime - endTime)
  }

  public func hostDeltaToNanos(startTime: UInt64, endTime: UInt64) -> Int64 {
    let result = absoluteHostDeltaToNanos(startTime: startTime, endTime: endTime)
    return startTime <= endTime ? Int64(result) : -Int64(result)
  }

  public func multiplyByRatio(multiplicand: UInt64,
                              numerator: UInt32,
                              denominator: UInt32) -> UInt64
  {
    guard numerator != denominator else { return multiplicand }
    return UInt64(Float64(multiplicand) * Float64(numerator) / Float64(denominator))
  }

}
