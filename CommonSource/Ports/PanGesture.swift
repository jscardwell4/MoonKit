//
//  PanGesture.swift
//  MoonKit
//
//  Created by Jason Cardwell on 10/23/14.
//  Copyright (c) 2014 Jason Cardwell. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
public class PanGesture: ConfiningBlockActionGesture {

  /// Struct to specify upon which axis or axes panning touches are to be tracked
  public struct Axis : OptionSet {

    public let rawValue: Int

    public init(rawValue: Int) { self.rawValue = rawValue & 0b11 }

    public static let none       = Axis([])
    public static let vertical   = Axis(rawValue: 0b01)
    public static let horizontal = Axis(rawValue: 0b10)
    public static let both       = Axis(rawValue: 0b11)

    /// Initialize using a slope to set a single axis when running parallel with the x or y axis and
    /// setting `both` otherwise.
    public init(slope: CGFloat) {
      switch slope {
        case 0:                      self = .horizontal
        case CGFloat.nan:            self = .vertical
        case let m where abs(m) < 1: self = .horizontal
        case let m where abs(m) > 1: self = .vertical
        default:                     self = .both
      }
    }

    /// Returns `source`, as (x, y), with x replaced by `0` when `self ∌ .horizontal` 
    /// and y replaced by `0` when `self ∌ .vertical`.
    public func filter<Source>(_ source: Source) -> Source
      where Source:Unpackable2,
            Source.Unpackable2Element == CGFloat,
            Source:Packable2,
            Source.Packable2Element == CGFloat
    {
      let (x, y) = source.unpack
      return Source.init((self ∋ .horizontal ? x : 0, self ∋ .vertical ? y : 0))
    }

  }

  /// Specifies whether this gesture tracks vertical, horizontal, both, or neither.
  public var axis = Axis.both

  @IBInspectable public var rawAxis: Int {
    get { return axis.rawValue }
    set { axis = Axis(rawValue: newValue) }
  }

  /// A simple structure for holding timestamp, centroid, and velocity data
  private struct TrackingData: CustomStringConvertible {

    let timestamp: TimeInterval
    let centroid: CGPoint
    let velocity: CGVector

    /// True iff `centroid` is non-null.
    var isValid: Bool { return centroid.isNull == false }

    /// Initialize with known values.
    init(timestamp: TimeInterval = 0, centroid: CGPoint = .null, velocity: CGVector = .null) {
      self.timestamp = timestamp
      self.centroid = centroid
      self.velocity = velocity
    }

    /// Initialize with `timestamp` and `centroid`, calculating `velocity` using `previous`.
    init(timestamp: TimeInterval, centroid: CGPoint, previous: TrackingData) {
      self.timestamp = timestamp
      self.centroid = centroid
      velocity = CGVector((centroid - previous.centroid) / CGFloat(timestamp - previous.timestamp))
    }

    var description: String {
      return "{timestamp: \(timestamp); centroid: \(centroid); velocity: \(velocity)}"
    }

  }


  /// A simple structure for holding centroids capable of calculating the slope of a regression line.
  private struct RegressionData: CustomStringConvertible {

    /// The points from which to derive the regression line.
    var points: [CGPoint] = []

    /// The slope of the regression line calculated using `points`.
    var slope: CGFloat {
      guard points.count > 0 else { return 0 }
      let n = CGFloat(points.count)
      let sumX = points.reduce(0) {$0 + $1.x}
      let sumY = points.reduce(0) {$0 + $1.y}
      let sumXX = points.reduce(0) {$0 + pow($1.x, 2)}
      let sumXY = points.reduce(0) {$0 + $1.x * $1.y}
      let numerator = n * sumXY - sumX * sumY
      let denominator = n * sumXX - pow(sumX, 2)
      return numerator / denominator
    }

    var description: String { return "{points: \(points); slope: \(slope)}" }

  }

  /// The minimum number of fingers that can be touching the view for this gesture to be recognized.
  /// The default value is `1`
  @IBInspectable public var minimumNumberOfTouches: Int = 1 {
    didSet {
      minimumNumberOfTouches = max(1, min(10, minimumNumberOfTouches))
    }
  }

  /// The maximum number of fingers that can be touching the view for this gesture to be recognized.
  /// The default value is `10`.
  @IBInspectable public var maximumNumberOfTouches: Int = 10 {
    didSet {
      maximumNumberOfTouches = max(1, min(10, maximumNumberOfTouches))
    }
  }

  /// The translation of the pan gesture in the coordinate system of the specified view.
  /// The x and y values report the total translation over time. They are not delta values from the last
  /// time that the translation was reported. Apply the translation value to the state of the view when 
  /// the gesture is first recognized — do not concatenate the value each time the handler is called.
  /// - parameter view: UIView? = nil The view in whose coordinate system the translation of the pan
  ///                                 gesture should be computed. If you want to adjust a view's location
  ///                                 to keep it under the user's finger, request the translation in that 
  ///                                 view's superview's coordinate system.
  public func translation(in view: UIView? = nil) -> CGPoint {

    switch view ?? self.view {

      case let view? where view === self.view:
        return axis.filter(currentData.centroid - initialData.centroid)

      case let view?:
        let current = view.convert(currentData.centroid, from: self.view)
        let initial = view.convert(initialData.centroid, from: self.view)
        return axis.filter(current - initial)

      default:
        return .null

    }

  }

  /// The velocity of the pan gesture in the coordinate system of the specified view.
  /// - parameter view: UIView Provides the coordinate system in calculating the velocity.
  /// - returns: CGVector The velocity expressed in points per second as horizontal and vertical components.
  public func velocity(in view: UIView) -> CGVector {
    return axis.filter(currentData.velocity)
  }

  /// Distance in points that are required before a change is recognized.
  @IBInspectable public var requiredMovement: CGFloat = 10.0

  /// The touches being tracked.
  private var panningTouches: Set<UITouch> = []

  /// The initial calculations performed with the currently tracked touches.
  private var initialData  = TrackingData()

  /// The most recent calculations performed with the currently tracked touches.
  private var currentData  = TrackingData()

  /// The previous calculations performed with the currently tracked touches.
  private var previousData = TrackingData()

  /// Holds all the centroids calculated for the currently tracked touches.
  private var regressionData = RegressionData()

  /// Updates data-related properties and gesture state according to values obtained from `panningTouches`.
  private func updateData() {

    // Make sure when can grab a timestamp from the panning touches
    guard let timestamp = panningTouches.map({$0.timestamp}).max() else { return }

    // Calculate the centroid for the new data.
    let centroid = centroidForTouches(panningTouches)

    // Append the new centroid to our regression data
    regressionData.points.append(centroid)

    // Check if pan is moving along a compatible axis
    guard regressionData.points.count < 2 || axis.isSuperset(of: Axis(slope: regressionData.slope)) else {
      state = .failed
      return
    }

    // Switch on the current state to update data structures appropriately
    switch state {

      case .possible where initialData.isValid:
        // Second update: Check that location delta qualifies as movement,
        // copy `initialData` to `previousData`, update `currentData`, and set state to `began`.

        guard axis.filter(initialData.centroid - centroid).absolute.max >= requiredMovement else {
          break
        }

        previousData = initialData
        currentData = TrackingData(timestamp: timestamp, centroid: centroid, previous: previousData)
        state = .began

      case .possible:
        // First update: capture initial data.

        initialData = TrackingData(timestamp: timestamp, centroid: centroid)

      case .began, .changed:
        // Third or greater update: Push `currentData` into `previousData`, generate new `currentData`,
        // and update `state` if current velocity indicates movement.

        previousData = currentData
        currentData = TrackingData(timestamp: timestamp, centroid: centroid, previous: previousData)

        guard axis.filter(currentData.velocity).absolute.max > 0 else { break }

        state = .changed

      case .ended, .failed, .cancelled:
        break

      @unknown default:
        break
    }

  }

  /// Resets state and clears data.
  public override func reset() {

    state = .possible

    panningTouches.removeAll()

    initialData    = TrackingData()
    currentData    = TrackingData()
    previousData   = TrackingData()
    regressionData = RegressionData()

  }

  public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {

    // Check that no touches are being tracked, the number of touches is within accepected range,
    // and all the touches are inside.
    guard panningTouches.isEmpty
      && (minimumNumberOfTouches ... maximumNumberOfTouches).contains(touches.count)
      && validateTouchLocations(touches, withEvent: event)
      else
    {
      state = .failed
      return
    }

    // Store touches and update.
    panningTouches = touches
    updateData()
  }

  public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {

    // Check that touches being tracked have moved.
    guard panningTouches.isSubset(of: touches) else { return }

    // Check that all the touches being tracked remain valid.
    guard validateTouchLocations(panningTouches, withEvent: event) else {
      state = .failed
      return
    }

    // Update for new locations.
    updateData()

    // TODO: move to failed state if movement is in the wrong direction

  }

  public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {

    // Check that at least one of the touches being tracked has been cancelled.
    guard panningTouches.intersection(touches).count > 0 else { return }

    // Update state
    state = .cancelled

  }

  public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {

    // Check that at least one of the touches being tracked has ended.
    guard panningTouches.intersection(touches).count > 0 else { return }

    // Check that all the touches being tracked remain valid.
    guard validateTouchLocations(panningTouches, withEvent: event) else {
      state = .failed
      return
    }

    // Update if location has changed since the last update.
    if centroidForTouches(panningTouches) != currentData.centroid { updateData() }

    assert(state != .failed, "Where was this set to `failed`?")

    // Update state
    state = .ended

  }

}
