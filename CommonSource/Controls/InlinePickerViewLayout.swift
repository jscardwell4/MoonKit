//
//  InlinePickerViewLayout.swift
//  MoonKit
//
//  Created by Jason Cardwell on 7/2/15.
//  Copyright © 2015 Jason Cardwell. All rights reserved.
//

import Foundation
import UIKit

class InlinePickerViewLayout: UICollectionViewLayout {

  /// Overridden to return custom invalidation context.
  override class var invalidationContextClass: AnyClass { return InvalidationContext.self }

  /// Overridden to return custom attributes.
  override class var layoutAttributesClass: AnyClass { return Attributes.self }

  /// The item displayed as the current selection. This is equal to `delegate.selection` unless in motion.
  var activeSelection: Int? {
    guard cacheFlags == [.delegateMask, .metricMask, .attributes] else { return nil }
    return metricCache.selection
  }

  /// Responsible for supplying values necessary to perform layout calculations.
  weak var delegate: InlinePickerView?

  /// Holds all the calculated layout attributes
  fileprivate var attributesCache: OrderedDictionary<IndexPath, Attributes> = [:]

  /// Specifies which cached values are currently valid.
  fileprivate var cacheFlags: CacheFlags = .none

  /// Current set of content metrics.
  fileprivate var metricCache = MetricCache()

  /// Current set of values cached from `delegate`
  fileprivate var delegateCache = DelegateCache()

  /// Whether the `collectionView` is moving as a result of user interaction.
  fileprivate var isCollectionViewInMotion: Bool {
    guard let collectionView = collectionView else { return false }
    return collectionView.isDecelerating || collectionView.isTracking || collectionView.isDragging
  }

  override var description: String {
    var result = super.description + "\n"
    result += "  cacheFlags: \(cacheFlags)\n"
    result += "  delegateCache: {\n\(delegateCache.description.indented(by: 4))\n}\n"
    result += "  metricCache: {\n\(metricCache.description.indented(by: 4))\n}\n"
    result += "  attributesCache: \(attributesCache.prettyDescription.indented(by: 19, preserveFirst: true))\n"
    result += "  delegate: \(delegate?.description ?? "nil")"
    return result
  }

  /// Attempts to obtain from delegate any cached value for which a flag is not present in `cacheFlags`.
  /// - returns: `true` if values could be obtained from `delegate` and `false` otherwise.
  fileprivate func updateDelegateCache() -> Bool {

    
    // Return early if we have all the delegate flags marked as valid.
    guard cacheFlags ⊉ .delegateMask else { return true }

    // Make sure we have delegate from which values may be retrieved.
    guard let delegate = delegate else {
      cacheFlags = .none
      delegateCache = DelegateCache()
      metricCache = MetricCache()
      attributesCache = [:]
      return false
    }

    // Check item count validity.
    if .itemCount ∉ cacheFlags {
      assert(cacheFlags == .none, "How can anything be valid without an item count")
      delegateCache.itemCount = delegate.itemCount
      cacheFlags.insert(.itemCount)
    }

    // Check the validity of the cached item widths.
    if .itemWidths ∉ cacheFlags {
      let itemWidths = delegate.itemWidths
      let itemOffsets = delegate.itemOffsets
      let expectedCount = delegateCache.itemCount
      guard itemWidths.count == expectedCount && itemOffsets.count == expectedCount else {
        logw("Expected `itemWidths` and `itemOffsets` to contain \(expectedCount) items")
        return false
      }
      delegateCache.itemWidths = itemWidths
      delegateCache.itemOffsets = itemOffsets
      cacheFlags.insert(.itemWidths)
    }

    // Check the validity of the selection.
    if .selection ∉ cacheFlags {
      let selection = delegate.selection
      guard (0..<delegateCache.itemCount).contains(selection) else {
        logw("delegate.selection is out of bounds")
        return false
      }
      delegateCache.selection = selection
      cacheFlags.insert(.selection)
    }

    // Check the validity of the item padding.
    if .itemPadding ∉ cacheFlags {
      delegateCache.itemPadding = delegate.itemPadding
      cacheFlags.insert(.itemPadding)
    }

    // Check the validity of the item height.
    if .itemHeight ∉ cacheFlags {
      delegateCache.itemHeight = delegate.itemHeight
      cacheFlags.insert(.itemHeight)
    }

    // Check the validity of the editing status.
    if .editing ∉ cacheFlags {
      delegateCache.editing = delegate.editing
      cacheFlags.insert(.editing)
    }

    return true
  }

  /// Attempts to derive any metric cached value for which a flag is not present in `cacheFlags`.
  /// - returns: `true` if values could be obtained from `collectionView`; `false` otherwise.
  fileprivate func updateMetricCache() -> Bool {
    
    // Return early if we have all the metric flags marked as valid.
    guard !cacheFlags.isSuperset(of: .metricMask) else { return true }

    // Make sure we have a view to retrieve its bounds.
    guard let collectionView = collectionView else {
      cacheFlags ∩= .delegateMask
      metricCache = MetricCache()
      attributesCache = [:]
      return false
    }

    // Check bounding size validity.
    if .boundingSize ∉ cacheFlags {
      metricCache.boundingSize = collectionView.bounds.size
      cacheFlags.insert(.boundingSize)
    }

    // Check content width validity.
    if .contentWidth ∉ cacheFlags {
      let sumOfWidths = delegateCache.itemWidths.reduce(0, +)
      let sumOfCellPadding = CGFloat(delegateCache.itemCount - 1) * delegateCache.itemPadding
      metricCache.contentWidth = max(sumOfWidths + sumOfCellPadding, metricCache.boundingSize.width)
      cacheFlags.insert(.contentWidth)
    }

    // Check validity of the cached frames.
    if .frames ∉ cacheFlags {

      metricCache.frames.removeAll(keepingCapacity: metricCache.frames.count == delegateCache.itemCount)
      metricCache.frames.reserveCapacity(delegateCache.itemCount)

      var intervals = IntervalMap<CGFloat>(minimumCapacity: delegateCache.itemCount)

      var x = metricCache.contentPadding

      let height = delegateCache.itemHeight
      let y = (metricCache.boundingSize.height - height) * 0.5

      for (width, offset) in zip(delegateCache.itemWidths, delegateCache.itemOffsets) {

        metricCache.frames.append(CGRect(x: x + offset.horizontal, y: y + offset.vertical,
                                         width: width, height: height))
        intervals.insert(【x..(x + width)〗)

        x += width + delegateCache.itemPadding
      }

      metricCache.intervals = intervals

      cacheFlags.insert(.frames)

    }

    // Check the content offset validity.
    if .contentOffset ∉ cacheFlags {

      // Check whether the content offset needs to be properly set.
      if !isCollectionViewInMotion,
        let desiredOffset = offset(forItemAt: delegateCache.selection),
        desiredOffset != collectionView.contentOffset
      {
        metricCache.contentOffset = desiredOffset
        collectionView.contentOffset = desiredOffset
      }

      // Otherwise cache the reported content offset.
      else {
        metricCache.contentOffset = collectionView.contentOffset
      }
      
      cacheFlags.insert(.contentOffset)
    }

    return true

  }

  /// Rebuilds `attributesCache` unless `.attributes ∈ cacheFlags`
  fileprivate func updateAttributesCache() {

    
    switch .attributes ∉ cacheFlags {

      case false:
        // Up to date, just return.
        return

      case true where attributesCache.count == delegateCache.itemCount:
        // Update the attributes in the existing cache.
        for attributes in attributesCache.values { updateAttributes(attributes) }

      case true:
        // Rebuild the cache of attributes.

        let count = delegateCache.itemCount
        var attributesTuples = ContiguousArray<(key: IndexPath, value: Attributes)>(minimumCapacity: count)

        for item in 0 ..< count {
          let index = IndexPath(item: item, section: 0)
          guard let attributes = layoutAttributesForItem(at: index) as? Attributes else { continue }
          attributesTuples.append((key: index, value: attributes))
        }

        attributesCache = OrderedDictionary<IndexPath, Attributes>(attributesTuples)

    }

    cacheFlags.insert(.attributes)
  }

  /// Overridden to always return `true`.
  override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
    return true
  }

  /// Overridden to ensure the context contains the content adjustment values.
  override func invalidationContext(forBoundsChange newBounds: CGRect)
    -> UICollectionViewLayoutInvalidationContext
  {
    
    let context = super.invalidationContext(forBoundsChange: newBounds) as! InvalidationContext
    context.invalidateContentOffset = newBounds.origin != metricCache.contentOffset
    context.invalidateBoundingSize = newBounds.size != metricCache.boundingSize
    return context
  }

  /// Overridden to update `cacheFlags` appropriately in response to `context`.
  override func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
    

    super.invalidateLayout(with: context)

    // Make sure we have an instance of our custom context
    guard let invalidationContext = context as? InvalidationContext else {
      fatalError("Unexpected context type: \(type(of: context))")
    }

    switch invalidationContext.kind {

      case .everything, .data:
        cacheFlags = .none
        delegateCache = DelegateCache()
        metricCache = MetricCache()
        attributesCache = [:]

      case .editing:
        cacheFlags.remove([.editing, .attributes])

      case .selection:
        guard cacheFlags ∋ [.selection, .itemCount],
          let newSelection = delegate?.selection,
          (0..<delegateCache.itemCount).contains(newSelection)
        else
        {
          break
        }

        delegateCache.selection = newSelection
        guard metricCache.selection != newSelection else { break }
        attributesCache[IndexPath(item: metricCache.selection, section: 0)]?.isSelected = false
        attributesCache[IndexPath(item: newSelection, section: 0)]?.isSelected = true
        metricCache.selection = newSelection

      case .padding:
        delegateCache.itemPadding += invalidationContext.itemPaddingAdjustment
        metricCache = MetricCache()
        cacheFlags ∩= .delegateMask

      case .height:
        delegateCache.itemHeight += invalidationContext.itemHeightAdjustment
        metricCache = MetricCache()
        cacheFlags ∩= .delegateMask

      case .size, .bounds:
        metricCache = MetricCache()
        cacheFlags ∩= .delegateMask

      case .offset:
        cacheFlags.remove([.contentOffset, .attributes])
        guard updateMetricCache() else {
          fatalError("Internal inconsistency - unable to update metric cache")
        }
        updateAttributesCache()

      case .unspecified:
        break

    }

  }

  override func prepare() {
    
    guard updateDelegateCache() else { return }
    guard updateMetricCache()   else { return }
    updateAttributesCache()
  }

  /*override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
    super.prepare(forCollectionViewUpdates: updateItems)
    verbose("")
  }*/

  /*override func prepare(forAnimatedBoundsChange oldBounds: CGRect) {
    super.prepare(forAnimatedBoundsChange: oldBounds)
    verbose("")
  }*/

  /*override func finalizeAnimatedBoundsChange() {
    super.finalizeAnimatedBoundsChange()
    verbose("")
  }*/

  /*override func finalizeCollectionViewUpdates() {
    super.finalizeCollectionViewUpdates()
    verbose("")
  }*/

  final override var collectionViewContentSize: CGSize {
    
    guard [.itemHeight, .contentWidth] ⊆ cacheFlags else { return .zero }
    return CGSize(width: metricCache.contentWidth * 2, height: delegateCache.itemHeight)
  }

  override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    
    guard metricCache.boundingSize.area != 0 else { return [] }
    let attributes = Array(attributesCache.values.filter { $0.frame.intersects(rect) })
    return attributes.count > 0 ? attributes : nil
  }

  fileprivate func updateAttributes(_ attributes: Attributes) { }

  private func offset(forProposedOffset offset: CGPoint) -> CGPoint {

    guard let idx = index(ofItemAt: offset) else {
      logv("failed to get an index for offset, returning proposed value: \(offset)")
      return offset
    }

    guard let calculatedOffset = self.offset(forItemAt: idx) else {
      logv("failed to calculate an offset for item at index \(idx), returning proposed value: \(offset)")
      return offset
    }

    return calculatedOffset

  }

  /// Returns the content offset for the center of a given cell
  func offset(forItemAt index: Int) -> CGPoint? {
    
    guard cacheFlags ⊇ [.frames, .boundingSize, .itemCount]
       && (0..<delegateCache.itemCount).contains(index)
      else
    {
      logv("cannot generate an offset without having preformed calculations.")
      return nil
    }
    return CGPoint(x: metricCache.frames[index].midX - metricCache.boundingSize.width * 0.5, y: 0)
  }

  /// Returns the index for the item associated with the specified location, or nil if no such item exists.
  func index(ofItemAt offset: CGPoint) -> Int? {
    guard cacheFlags == [.delegateMask, .metricMask, .attributes] else { return nil }
    return metricCache.intervals.nearest(to: offset.x + metricCache.bounds.width * 0.5)
  }

  final override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
    
    return offset(forProposedOffset: proposedContentOffset)
  }

  final override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint,
                                      withScrollingVelocity velocity: CGPoint) -> CGPoint
  {
    
    return offset(forProposedOffset: proposedContentOffset)
  }

}

extension InlinePickerViewLayout: UIAccessibilityIdentification {

  var accessibilityIdentifier: String? {
    get { return collectionView?.accessibilityIdentifier }
    set { collectionView?.accessibilityIdentifier = newValue }
  }

}

extension InlinePickerViewLayout {

  /// A private struct for use as a cache of the values provided by the delegate.
  fileprivate struct DelegateCache: CustomStringConvertible {

    static let defaultItemPadding: CGFloat = 8
    static let defaultItemHeight: CGFloat = 36

    /// Caches `itemHeight` provided by `delegate` or the default value
    var itemHeight: CGFloat = DelegateCache.defaultItemHeight

    /// Padding value provided by `delegate` or the default value
    var itemPadding: CGFloat = DelegateCache.defaultItemPadding

    /// Caches the `selection` property of `delegate`
    var selection = 0

    /// The total item count
    var itemCount = 0

    /// The widths of each item.
    var itemWidths: [CGFloat] = []

    /// The content offset of each item.
    var itemOffsets: [UIOffset] = []

    /// Whether to allow for editing the selection.
    var editing = false

    var description: String {
      var result = ""
      result += "itemHeight: \(itemHeight)\n"
      result += "itemPadding: \(itemPadding)\n"
      result += "selection: \(selection)\n"
      result += "itemCount: \(itemCount)\n"
      result += "itemWidths: \(itemWidths)\n"
      result += "itemOffsets: \(itemOffsets)\n"
      result += "editing: \(editing)"
      return result
    }

  }

}

extension InlinePickerViewLayout {

  /// A private struct for use as a cache of the values relating to the size of the content.
  fileprivate struct MetricCache: CustomStringConvertible {

    /// Width calculated for the content
    var contentWidth: CGFloat = 0

    /// Space before and after the first and last cells
    var contentPadding: CGFloat { return contentWidth * 0.5 }

    /// Corresponds to the scroll view property of the same name.
    var contentOffset = CGPoint.zero

    /// The visible size of the collection.
    var boundingSize = CGSize.zero

    /// Stores the index of the actively selected item.
    var selection = 0

    /// Stores the x value interval for each item.
    var intervals: IntervalMap<CGFloat> = []

    /// Derived property that creates a rect from the `contentOffset` and `boundingSize`.
    var bounds: CGRect { return CGRect(origin: contentOffset, size: boundingSize) }

    /// Cache of cell frames without any transforms applied
    var frames: [CGRect] = []

    var description: String {
      var result = ""
      result += "contentWidth: \(contentWidth)\n"
      result += "contentOffset: \(contentOffset)\n"
      result += "boundingSize: \(boundingSize)\n"
      result += "selection: \(selection)\n"
      result += "frames: \(frames.prettyDescription.indented(by: 7, preserveFirst: true))"
      result += "intervals: \(Array(intervals).prettyDescription.indented(by: 7, preserveFirst: true))"
      return result
    }

  }

}

extension InlinePickerViewLayout {

  final class InvalidationContext: UICollectionViewLayoutInvalidationContext {

    /// Whether editing status has changed.
    var invalidateEditingStatus = false

    /// Whether the selected item has changed.
    var invalidateSelection = false

    /// Whether the view's content offset has changed.
    var invalidateContentOffset = false

    /// Whether the visible content's size has changed.
    var invalidateBoundingSize = false

    /// Amount by which item padding has changed.
    var itemPaddingAdjustment: CGFloat = 0

    /// Amount by which item height has changed
    var itemHeightAdjustment: CGFloat = 0

    /// The kind of change indicated by this context.
    var kind: Kind {
      guard !invalidateEverything else { return .everything }
      guard !invalidateDataSourceCounts else { return .data }
      guard !invalidateEditingStatus else { return .editing }
      guard !invalidateSelection else { return .selection }
      guard itemPaddingAdjustment == 0 else { return .padding }
      guard itemHeightAdjustment == 0 else { return .height }
      guard !(invalidateContentOffset && invalidateBoundingSize) else { return .bounds }
      guard !invalidateContentOffset else { return .offset }
      guard !invalidateBoundingSize else { return .size }
      return .unspecified
    }

    override var description: String { return kind.rawValue }
    
    override var debugDescription: String {
      var result = ""
      result += "invalidateEverything: \(invalidateEverything)\n"
      result += "invalidateDataSourceCounts: \(invalidateDataSourceCounts)\n"
      result += "contentOffsetAdjustment: \(contentOffsetAdjustment)\n"
      result += "contentSizeAdjustment: \(contentSizeAdjustment)\n"
      result += "invalidateContentOffset: \(invalidateContentOffset)\n"
      result += "invalidateBoundingSize: \(invalidateBoundingSize)\n"
      result += "invalidateEditingStatus: \(invalidateEditingStatus)\n"
      result += "invalidateSelection: \(invalidateSelection)\n"
      result += "itemPaddingAdjustment: \(itemPaddingAdjustment)\n"
      result += "itemHeightAdjustment: \(itemHeightAdjustment)"
      return result
    }

  }

}

extension InlinePickerViewLayout.InvalidationContext {

  enum Kind: String {
    case unspecified, everything, data, editing, selection, padding, height, offset, size, bounds
  }

}

extension InlinePickerViewLayout {

  final class Attributes: UICollectionViewLayoutAttributes {

    fileprivate(set) var isSelected: Bool = false

    override func isEqual(_ object: Any?) -> Bool {
      guard let other = object as? Attributes else { return false }
      return super.isEqual(other) && other.isSelected == isSelected
    }

    override func copy(with zone: NSZone? = nil) -> Any {
      let result: Attributes = super.copy(with: zone) as! Attributes
      result.isSelected = isSelected
      return result
    }

    override var description: String {
      var result = "{\n  "
      result += "item: \(indexPath.item)\n"
      result += "frame: \(frame)\n"
      result += "transform3D: \(transform3D.graphicDescription.indented(by: 15, preserveFirst: true, useTabs: false))\n"
      result += "alpha: \(alpha)\n"
      result += "hidden: \(isHidden)\n"
      result +=  "isSelected: \(isSelected)\n"
      result += "\n}"
      return result
    }
  }

}

extension InlinePickerViewLayout {

  struct CacheFlags: OptionSet, CustomStringConvertible {
    let rawValue: Int

    static let none           = CacheFlags([])

    // delegate cache properties
    static let itemHeight     = CacheFlags(rawValue: 0b00000000001)
    static let itemPadding    = CacheFlags(rawValue: 0b00000000010)
    static let selection      = CacheFlags(rawValue: 0b00000000100)
    static let itemCount      = CacheFlags(rawValue: 0b00000001000)
    static let itemWidths     = CacheFlags(rawValue: 0b00000010000)
    static let editing        = CacheFlags(rawValue: 0b00000100000)
    static let delegateMask   = CacheFlags(rawValue: 0b00000111111)

    // metric cache properties
    static let contentWidth   = CacheFlags(rawValue: 0b00001000000)
    static let contentOffset  = CacheFlags(rawValue: 0b00010000000)
    static let boundingSize   = CacheFlags(rawValue: 0b00100000000)
    static let frames         = CacheFlags(rawValue: 0b01000000000)
    static let metricMask     = CacheFlags(rawValue: 0b01111000000)

    // attributes
    static let attributes     = CacheFlags(rawValue: 0b10000000000)

    static let all            = CacheFlags(rawValue: 0b11111111111)

    var description: String {
      var result = "["
      var flagStrings: [String] = []
      switch rawValue {
        case 0b00000000000: flagStrings.append("none")
        case 0b11111111111: flagStrings.append("all")
        default:
          if contains(.itemHeight)      { flagStrings.append("itemHeight")     }
          if contains(.itemPadding)     { flagStrings.append("itemPadding")    }
          if contains(.selection)       { flagStrings.append("selection")      }
          if contains(.itemCount)       { flagStrings.append("itemCount")      }
          if contains(.itemWidths)      { flagStrings.append("itemWidths")     }
          if contains(.editing)         { flagStrings.append("editing")        }
          if contains(.contentWidth)    { flagStrings.append("contentWidth")   }
          if contains(.contentOffset)   { flagStrings.append("contentOffset")  }
          if contains(.boundingSize)    { flagStrings.append("boundingSize")   }
          if contains(.frames)          { flagStrings.append("frames")         }
          if contains(.attributes)      { flagStrings.append("attributes")     }
      }
      result += ", ".join(flagStrings)
      result += "]"
      return result
    }
  }

}

final class FlatInlinePickerViewLayout: InlinePickerViewLayout {

  override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    guard indexPath.item < metricCache.frames.count else {
      logw("invalid index path: \(indexPath)")
      return nil
    }

    let attributes = Attributes(forCellWith: indexPath)
    updateAttributes(attributes)
    return attributes
  }

  fileprivate override func updateAttributes(_ attributes: Attributes) {

    let rawFrame = metricCache.frames[attributes.indexPath.item]
    let midX = metricCache.contentOffset.x + metricCache.boundingSize.width * 0.5
    let center = CGPoint(x: midX, y: attributes.frame.origin.y)
    let paddedFrame = rawFrame.insetBy(dx: delegateCache.itemPadding * -0.5, dy: 0)

    attributes.frame = rawFrame
    attributes.isSelected = paddedFrame.contains(center)

    if attributes.isSelected { metricCache.selection = attributes.indexPath.item }
  }

}

final class CurvedInlinePickerViewLayout: InlinePickerViewLayout {

  private func canLayoutItem(at indexPath: IndexPath) -> Bool {
    

    switch (delegateCache.itemCount, metricCache.frames.count) {
      case (_, _) where indexPath.section == 1:
        // The debug cell section
        return metricCache.boundingSize.area != 0
      case let (count1, count2) where count1 != count2:
        logw("lacking or invalid cached values and metrics for calculations")
        return false

      case let (count, _) where indexPath.item >= count:
        logw("invalid index path: \(indexPath)")
        return false

      default:
        return metricCache.boundingSize.area != 0
    }

  }

  override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {

    guard var attributes = super.layoutAttributesForElements(in: rect) else { return nil }
    guard InlinePickerView.enableDebugCell else { return attributes }

    guard let layoutAttributes = layoutAttributesForItem(at: IndexPath(item: 0, section: 1)) else {
      return attributes
    }

    attributes.append(layoutAttributes)
    
    return attributes
  }

  private func layoutAttributesForDebugCell(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes {
    
    let attributes = Attributes(forCellWith: indexPath)

    let bounds = metricCache.bounds
    let height = delegateCache.itemHeight
    let frame = CGRect(x: bounds.origin.x,
                       y: bounds.origin.y - bounds.width - height * 0.5,
                       width: bounds.width,
                       height: bounds.width)

    attributes.frame = frame
    attributes.zIndex = -1
    let translation = CATransform3D(tx: 0, ty: (height * 0.5) - 0.01, tz: -frame.height * 0.5)
    let rotation = CATransform3D(angle: .pi * 0.5, x: 1, y: 0, z: 0)
    attributes.transform3D = rotation.concatenated(translation)

    return attributes
  }

  override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {

    
    guard canLayoutItem(at: indexPath) else { return nil }

    // Ensure path leads to default section.
    guard indexPath.section == 0 else {
      return indexPath.section == 1 ? layoutAttributesForDebugCell(at: indexPath) : nil
    }

    let attributes = Attributes(forCellWith: indexPath)
    updateAttributes(attributes)

    return attributes

  }

  /// Returns a transform appropriate for the provided parameters and whether the cell should be hidden.
  ///
  /// - Parameters:
  ///   - diameter: The diameter for the circle around which the transforms place the cells.
  ///   - center: The center of the circle.
  ///   - offset: The horizontal offset for the cell relative to the content offset.
  private func transform(withDiameter diameter: CGFloat,
                         center: CGFloat,
                         offset: CGFloat) -> (transform: CATransform3D, isHidden: Bool)
  {
    
    // Central angle of radii with endpoints located along x-axis at `offset` and `center`
    let θ = (offset - center) / (diameter * 0.5)

    // The chord length derived from `θ`.
    let c = diameter * sin(θ * 0.5)

    // The base angle of the isosceles triangle formed by the chord and two radii
    let α = (.pi - θ) * 0.5

    // Consider the triangle formed by connecting point along circle with x = `offset` to the radius
    // parallel with the z-axis. This creates a right triangle with hypotenuse = `c` and sides whose
    // lengths are equal to the 𝝙x and 𝝙z values we are looking for. We know the angle connecting `c`
    // to the radius = α.

    // The z-axis translation is the length of the side of the triangle parallel with the z-axis; but,
    // negated to move backward.
    let 𝝙z = -(cos(α) * c)

    // The x-axis translation is the length of the side of the triangle parallel with the x-axis adjusted
    // to be the difference between the x value for the point on the circle and the original x value.
    let 𝝙x = (sin(α) * c + center) - offset

    // Create a rotating/translating transform.
    let transform = CATransform3D(
      m11: cos(θ), m12: 0, m13: -sin(θ),  m14: 0,
      m21: 0,      m22: 1, m23: 0,        m24: 0,
      m31: sin(θ), m32: 0, m33: cos(θ),   m34: 0,
      m41: 𝝙x,     m42: 0, m43: 𝝙z,      m44: 1
    )

    // Cells should be hidden when their angle turns them away from view.
    let isHidden = !(0 ..< .pi).contains(abs(θ))

    return (transform, isHidden)
  }

  fileprivate override func updateAttributes(_ attributes: Attributes) {
    

    let rawFrame = metricCache.frames[attributes.indexPath.item]
    attributes.frame = rawFrame

    let midX = metricCache.contentOffset.x + metricCache.boundingSize.width * 0.5

    guard delegateCache.editing else {
      if delegateCache.selection == attributes.indexPath.item {
        let maxX = metricCache.contentOffset.x + metricCache.boundingSize.width
        attributes.transform3D = CATransform3D(tx: maxX - rawFrame.maxX, ty: 0, tz: 0)
        attributes.isHidden = false
      } else {
        attributes.isHidden = true
      }
      return
    }

    (attributes.transform3D, attributes.isHidden) = transform(withDiameter: metricCache.boundingSize.width,
                                                              center: midX,
                                                              offset: rawFrame.midX)

    let center = CGPoint(x: midX, y: attributes.frame.origin.y)
    let paddedFrame = attributes.frame.insetBy(dx: delegateCache.itemPadding * -0.5, dy: 0)

    attributes.isSelected =    paddedFrame.contains(center)
                            || ( paddedFrame.midX > center.x
                              && attributes.indexPath.item == 0)
                            || ( paddedFrame.midX < center.x
                              && attributes.indexPath.item == delegateCache.itemCount &- 1)

    if attributes.isSelected { metricCache.selection = attributes.indexPath.item }

  }

}
