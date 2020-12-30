//
//  InlinePickerView.swift
//  MoonKit
//
//  Created by Jason Cardwell on 10/14/14.
//  Copyright (c) 2014 Jason Cardwell. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Delegate for InlinePickerView
public protocol InlinePickerDelegate: class {

  /// Returns the number of items to be displayed.
  func numberOfItems(in picker: InlinePickerView) -> Int

  /// Returns the content for `item` as either a `String` or a `UIImage`.
  func inlinePicker(_ picker: InlinePickerView, contentForItem item: Int) -> InlinePickerView.Item

  /// Invoked when a new selection has been made by the user.
  func inlinePicker(_ picker: InlinePickerView, didSelectItem item: Int)

  /// Amount to adjust the position of `item`.
  func inlinePicker(_ picker: InlinePickerView, contentOffsetForItem item: Int) -> UIOffset

}

extension InlinePickerDelegate {

  public func inlinePicker(_ picker: InlinePickerView, didSelectItem item: Int) {}

  public func inlinePicker(_ picker: InlinePickerView, contentOffsetForItem item: Int) -> UIOffset {
    return .zero
  }

}


// MARK: - InlinePickerView declaration
@IBDesignable
open class InlinePickerView: UIControl {

  /// Whether a section should be included for a debug cell.
  internal static let enableDebugCell = false

  /// Use `CATransformLayer` as the backing layer.
  override open class var layerClass: AnyClass { return CATransformLayer.self }

  /// The delegate responsible for the collection's content, appearance, and selection callbacks.
  public weak var delegate: InlinePickerDelegate?

  /// Initialize with a layout style, frame, and, optionally, a delegate.
  public init(flat: Bool, frame: CGRect, delegate: InlinePickerDelegate?) {

    layout = flat ? FlatInlinePickerViewLayout() : CurvedInlinePickerViewLayout()
    collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
    super.init(frame: frame)
    self.delegate = delegate
    setup()
  }

  /// Initialize with a frame.
  override public init(frame: CGRect) {
    layout = FlatInlinePickerViewLayout()
    collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
    super.init(frame: frame)
    setup()
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("\(#function) has not been implemented for InlinePickerView")
  }

  /// Configures the view upon initialization.
  private func setup() {

    // Configure `self`.
    isUserInteractionEnabled = true
    translatesAutoresizingMaskIntoConstraints = false
    identifier = "picker"
    setContentCompressionResistancePriority(UILayoutPriority(rawValue: 750), for: .horizontal)
    setContentCompressionResistancePriority(UILayoutPriority.required, for: .vertical)

    // Configure `baselineView`.
    addSubview(baselineView)
    constrain(𝗛∶|[baselineView]|)
    constrain(baselineView.top == centerY)
    baselineBottomConstraint.constant = itemHeight * 0.5

    // Configure `collectionView`.
    collectionView.identifier = "collectionView"
    collectionView.isScrollEnabled = editing
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.bounces = false
    collectionView.backgroundColor = .clear
    collectionView.decelerationRate = UIScrollView.DecelerationRate.fast
    collectionView.allowsSelection = false
    collectionView.register(InlinePickerViewLabelCell.self, forCellWithReuseIdentifier: "label")
    collectionView.register(InlinePickerViewImageCell.self, forCellWithReuseIdentifier: "image")
    collectionView.register(InlinePickerViewDebugCell.self, forCellWithReuseIdentifier: "debug")


    // Add and constrain `collectionView`.
    addSubview(collectionView)
    constrain(𝗛∶|[collectionView]|, 𝗩∶|[collectionView]|)
    constrain(height >= itemHeight)

    // Set delegates to `self`.
    layout.delegate = self
    collectionView.delegate = self
    collectionView.dataSource = self

  }

  /// The view responsible for displaying all of this view's content.
  fileprivate let collectionView: UICollectionView

  /// The layout assigned to `collectionView`.
  fileprivate var layout: InlinePickerViewLayout

  override open class var requiresConstraintBasedLayout: Bool { return true }

  /// Returns the width as would be returned by `UIPickerView` and height equal to `itemHeight`.
  override open var intrinsicContentSize: CGSize { return CGSize(width: 320, height: itemHeight) }

  /// updates `selection`, optionally animating the collection view.
  public func selectItem(_ item: Int, animated: Bool) {
    
    precondition((0 ..< itemCount).contains(item), "Index out of bounds")

    selection = item

    guard animated, let offset = layout.offset(forItemAt: item) else { return }

    collectionView.setContentOffset(offset, animated: true)
  }

  /// The font used for unselected textual items.
  public var font: UIFont = InlinePickerView.defaultFont

  /// Accessors for `font.fontName`. Setter updates `font` with using the current `pointSize`.
  @IBInspectable public var fontName: String  {
    get { return font.fontName }
    set { if let font = UIFont(name: newValue, size: self.font.pointSize) { self.font = font } }
  }

  /// Accessors for `font.pointSize`. Setter updates `font` with using the current `fontName`.
  @IBInspectable public var fontSize: CGFloat  {
    get { return font.pointSize }
    set { font = font.withSize(newValue) }
  }

  /// The font used for a selected textual item.
  public var selectedFont: UIFont = InlinePickerView.defaultFont {
    didSet {
      guard oldValue !== selectedFont && selection < itemCache.expectedCount,
            case .text = itemCache.items[selection]
        else
      {
        return
      }
      updateBaselineView()
    }
  }

  /// Same as `fontName` but for `selectedFont`.
  @IBInspectable public var selectedFontName: String  {
    get { return selectedFont.fontName }
    set { if let font = UIFont(name: newValue, size: selectedFont.pointSize) { selectedFont = font } }
  }

  /// Same as `fontSize` but for `selectedFont`.
  @IBInspectable public var selectedFontSize: CGFloat  {
    get { return selectedFont.pointSize }
    set { selectedFont = selectedFont.withSize(newValue) }
  }

  /// Controls whether the collection view uses a flat or curved layout.
  @IBInspectable public var flat: Bool {
    get { return layout is FlatInlinePickerViewLayout }
    set {
      guard flat != newValue else { return }
      layout = newValue ? FlatInlinePickerViewLayout() : CurvedInlinePickerViewLayout()
      layout.delegate = self
      collectionView.setCollectionViewLayout(layout, animated: true)
    }
  }

  /// Since the view is backed by an transform layer, these accessors are rerouted to the collection view.
  open override var backgroundColor: UIColor? {
    get { return collectionView.backgroundColor }
    set { collectionView.backgroundColor = newValue }
  }

  /// The color to make unselected items.
  @IBInspectable public var itemColor: UIColor = .darkText

  /// The color to make the selected item.
  @IBInspectable public var selectedItemColor: UIColor = .darkText

  /// The font used when none has been provided.
  public static let defaultFont = UIFont.preferredFont(forTextStyle: .body)

  /// Optional image to display in the background. Intended to indicate which item is selected.
  @IBInspectable public var marker: UIImage? {
    get { return (collectionView.backgroundView as? UIImageView)?.image }
    set {
      guard let marker = newValue?.withRenderingMode(.alwaysTemplate) else {
        collectionView.backgroundView = nil
        return
      }

      collectionView.backgroundView = {
        let imageView = UIImageView(image: marker)
        imageView.contentMode = .bottom
        imageView.tintColor = selectedItemColor
        return imageView
      }()
    }
  }

  /// Refreshes the item cache and reloads the collection view.
  public func reloadData() {
    cacheItems()
    collectionView.reloadData()
  }

  /// Updates `_baselineView` for current `selectedFont` value or item type.
  private func updateBaselineView() {

    // Check that we have a valid selection.
    guard itemCache.expectedCount > selection else { return }

    switch itemCache.items[selection] {
      case .image: baselineBottomConstraint.constant = itemHeight * 0.5
      case .text:  baselineBottomConstraint.constant = selectedFont.xHeight * 0.5
    }

  }

  /// The height each item should be.
  @IBInspectable public var itemHeight: CGFloat = 36 {
    didSet {
      guard itemHeight != oldValue else { return }

      updateBaselineView()

      let context = InlinePickerViewLayout.InvalidationContext()
      context.itemHeightAdjustment = oldValue - itemHeight
      layout.invalidateLayout(with: context)
    }
  }

  /// The padding added between items.
  @IBInspectable public var itemPadding: CGFloat = 8.0 {
    didSet {
      guard itemPadding != oldValue else { return }
      let context = InlinePickerViewLayout.InvalidationContext()
      context.itemPaddingAdjustment = oldValue - itemPadding
      layout.invalidateLayout(with: context)
    }
  }

  /// Cache of data received from `delegate` to provide the collection view layout.
  fileprivate var itemCache = ItemCache()

  /// Refreshes the item cache if the number of items reported by `delegate` doesn't match the cached count.
  private func checkItemCache() {
    guard let delegate = delegate, delegate.numberOfItems(in: self) != itemCache.expectedCount else { return }
    cacheItems()
  }

  /// Queries the `delegate` for the collection's items to keep in `itemCache`. Existing cache is cleared
  /// regardless of whether `delegate` continues to be valid.
  private func cacheItems() {
    guard let delegate = delegate else {
      itemCache.removeAll(keepingCapacity: false)
      return
    }

    let count = delegate.numberOfItems(in: self)

    itemCache.removeAll(keepingCapacity: itemCache.expectedCount == count)
    itemCache.expectedCount = count

    let fontAttributes = [NSAttributedString.Key.font: font]
    let selectedFontAttributes = [NSAttributedString.Key.font: selectedFont]

    for index in 0 ..< count {

      let item = delegate.inlinePicker(self, contentForItem: index)

      itemCache.items.append(item)
      itemCache.offsets.append(delegate.inlinePicker(self, contentOffsetForItem: index))

      switch item {

        case .text(let text):
          itemCache.widths.append(max(text.size(withAttributes: fontAttributes).width.rounded(.up),
                                      text.size(withAttributes: selectedFontAttributes).width.rounded(.up)))

        case .image(let image):
          itemCache.widths.append(image.size.height > itemHeight
                                  ? ((image.size.width / image.size.height) * itemHeight).rounded(.up)
                                  : image.size.width.rounded(.up))

      }

    }

    updateBaselineView()
  }

  /// The number of items
  var itemCount: Int { checkItemCache(); return itemCache.expectedCount }

  /// The width of each item in the collection.
  var itemWidths: [CGFloat] {
    checkItemCache()
    return itemCache.widths
  }

  /// The content offset of each item in the collection.
  var itemOffsets: [UIOffset] {
    checkItemCache()
    return itemCache.offsets
  }

  /// The index of the currently selected item.
  @IBInspectable public var selection: Int = 0 {
    didSet {
      // Check that value is new and valid.
      guard selection != oldValue && (0..<itemCount).contains(selection) else { return }

      let context = InlinePickerViewLayout.InvalidationContext()
      context.invalidateSelection = true
      layout.invalidateLayout(with: context)

      // Handle possible change in the type of item selected when items have already been cached.
      guard max(oldValue, selection, itemCache.expectedCount) == itemCache.expectedCount else { return }

      switch (itemCache.items[oldValue], itemCache.items[selection]) {
        case (.text, .image), (.image, .text): updateBaselineView()
        case (.text, .text), (.image, .image): break
      }
    }
  }

  /// Returns the frame of the cell for the currently selected item with the origin adjusted for 
  /// the content offset of the collection view.
  public var selectedItemFrame: CGRect? {
    guard selection > -1,
      let cell = collectionView.cellForItem(at: IndexPath(item: selection, section: 0)),
      cell.isSelected
      else
    {
      return nil
    }

    var frame = cell.frame
    frame.origin = frame.origin - collectionView.contentOffset
    return frame
  }

  /// Controls whether the selection is locked.
  @IBInspectable public var editing: Bool = true {
    didSet {
      guard editing != oldValue else { return }
      collectionView.isScrollEnabled = editing
      let context = InlinePickerViewLayout.InvalidationContext()
      context.invalidateEditingStatus = true
      layout.invalidateLayout(with: context)
    }
  }

  /// View from which a baseline value may be retrieved for autolayout.
  private let baselineView = UIView(autolayout: true)

  /// Constraint used to modify baseline values calculated by autolayout.
  private lazy var baselineBottomConstraint: NSLayoutConstraint = {
    guard let result = ($0 == $1 --> Identifier(for: self, tags: "Baseline")).constraint else {
      fatalError("Failed to create baseline constraint")
    }
    result.isActive = true
    return result
  }(self.baselineView.bottom, self.centerY)

  /// Returns the value of this property for the selected item's cell or of the collection view
  /// if the cell is unavailable.
  open override var forLastBaselineLayout: UIView { return baselineView }

}

extension InlinePickerView: UICollectionViewDelegate, UICollectionViewDataSource {

  public func collectionView(_ collectionView: UICollectionView,
                             numberOfItemsInSection section: Int) -> Int
  {

    guard section == 0 else { return section == 1 && InlinePickerView.enableDebugCell ? 1 : 0 }
    return itemCount
  }

  public func numberOfSections(in collectionView: UICollectionView) -> Int {
    
    return InlinePickerView.enableDebugCell ? 2 : 1
  }

  public func collectionView(_ collectionView: UICollectionView,
                             cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
  {
    

    guard indexPath.section == 0 else {
      guard indexPath.section == 1 && InlinePickerView.enableDebugCell else {
        fatalError("Internal inconsistency: unexpected section - \(indexPath.section)")
      }
      return collectionView.dequeueReusableCell(withReuseIdentifier: "debug", for: indexPath)
    }

    let cell: InlinePickerViewCell

    switch itemCache.items[indexPath.item] {

      case .image(let image):
        let imageCell = collectionView.dequeueReusableCell(withReuseIdentifier: "image",
                                                           for: indexPath) as! InlinePickerViewImageCell
        imageCell.image = image
        imageCell.imageColor = itemColor
        imageCell.imageSelectedColor = selectedItemColor
        cell = imageCell

      case .text(let label):
        let labelCell = collectionView.dequeueReusableCell(withReuseIdentifier: "label",
                                                           for: indexPath) as! InlinePickerViewLabelCell
        labelCell.text = label ¶| [font, itemColor]
        labelCell.selectedText = label ¶| [selectedFont, selectedItemColor]
        cell = labelCell

    }

    cell.contentOffset = itemCache.offsets[indexPath.item]

    return cell

  }

}

extension InlinePickerView: UIScrollViewDelegate {

  public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    sendActions(for: .valueChanged)
    delegate?.inlinePicker(self, didSelectItem: selection)
  }

  public func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                        withVelocity velocity: CGPoint,
                                        targetContentOffset: UnsafeMutablePointer<CGPoint>)
  {
    guard let activeSelection = layout.activeSelection else {
      logv("<\(String(addressOf: self))> failed to get active selection from layout")
      return
    }

    selection = activeSelection

  }
  
}

extension InlinePickerView {

  public enum Item {
    case text(String)
    case image(UIImage)
  }

}

extension InlinePickerView {

  fileprivate struct ItemCache {
    var items: ContiguousArray<Item> = []
    var widths: [CGFloat] = []
    var offsets: [UIOffset] = []
    var expectedCount: Int = 0

    mutating func removeAll(keepingCapacity: Bool) {
      items.removeAll(keepingCapacity: keepingCapacity)
      widths.removeAll(keepingCapacity: keepingCapacity)
      offsets.removeAll(keepingCapacity: keepingCapacity)
      expectedCount = 0
    }
  }

}

