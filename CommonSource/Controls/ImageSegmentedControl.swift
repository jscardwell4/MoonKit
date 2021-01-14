//
//  ImageSegmentedControl.swift
//  MoonKit
//
//  Created by Jason Cardwell on 11/30/15.
//  Copyright © 2015 Jason Cardwell. All rights reserved.
//

import Foundation
import UIKit

@available(iOS 9.0, *)
@IBDesignable public class ImageSegmentedControl: TintColorControl {

  fileprivate var segments: [ImageButtonView] { return stack?.arrangedSubviews.compactMap { $0 as? ImageButtonView } ?? [] }

  @IBOutlet fileprivate var stack: UIStackView! {
    didSet {
      segments.forEach {
        $0.addTarget(self, action: #selector(ImageSegmentedControl.touchUp(_:)), for: .touchUpInside)
        $0.normalTintColor = normalTintColor
        $0.highlightedTintColor = highlightedTintColor
        $0.disabledTintColor = disabledTintColor
        $0.selectedTintColor = selectedTintColor
      }
    }
  }

  /**
   touchUp:

   - parameter button: ImageButtonView
   */
  @objc fileprivate func touchUp(_ button: ImageButtonView) {
    guard let idx = segments.firstIndex(of: button) else { return }
    guard allowsEmptySelection || idx != selectedSegmentIndex else { return }
    if !momentary { selectedSegmentIndex = idx }
    sendActions(for: .valueChanged)
  }

  override public var normalTintColor: UIColor? {
    didSet { segments.forEach { $0.normalTintColor = normalTintColor } }
  }
  override public var highlightedTintColor: UIColor? {
    didSet { segments.forEach { $0.highlightedTintColor = highlightedTintColor } }
  }
  override public var disabledTintColor: UIColor? {
    didSet { segments.forEach { $0.disabledTintColor = disabledTintColor } }
  }
  override public var selectedTintColor: UIColor? {
    didSet { segments.forEach { $0.selectedTintColor = selectedTintColor } }
  }

  override public class var requiresConstraintBasedLayout: Bool { return true }

  /**
   setEnabled:forSegmentAtIndex:

   - parameter enabled: Bool
   - parameter segment: Int
   */
  public func setEnabled(_ enabled: Bool, forSegmentAtIndex segment: Int) {
    let segments = self.segments
    guard segments.indices.contains(segment) else { fatalError("segment index \(segment) out of bounds") }
    segments[segment].isEnabled = enabled
  }

  /**
   isEnabledForSegmentAtIndex:

   - parameter segment: Int

   - returns: Bool
   */
  public func isEnabledForSegmentAtIndex(_ segment: Int) -> Bool {
    let segments = self.segments
    guard segments.indices.contains(segment) else {
      fatalError("segment index \(segment) out of bounds")
    }
    return segments[segment].isEnabled
  }

  /**
   setImage:forState:forSegmentAtIndex:

   - parameter image: UIImage?
   - parameter state: ImageButtonView.ImageState
   - parameter segment: Int
   */
  public func setImage(_ image: UIImage?,
              forState state: ImageButtonView.ImageState,
     forSegmentAtIndex segment: Int)
  {
    let segments = self.segments
    guard segments.indices.contains(segment) else { fatalError("segment index \(segment) out of bounds") }
    switch state {
      case .Default:     segments[segment].image = image
      case .Highlighted: segments[segment].highlightedImage = image
      case .Disabled:    segments[segment].disabledImage = image
      case .Selected:    segments[segment].selectedImage = image
    }
  }

  /**
   imageForSegmentAtIndex:forState:

   - parameter segment: Int
   - parameter state: ImageButtonView.ImageState

   - returns: UIImage?
   */
  public func imageForSegmentAtIndex(_ segment: Int,
                            forState state: ImageButtonView.ImageState) -> UIImage?
  {
    let segments = self.segments
    guard segments.indices.contains(segment) else { fatalError("segment index \(segment) out of bounds") }
    switch state {
      case .Default:     return segments[segment].image
      case .Highlighted: return segments[segment].highlightedImage
      case .Disabled:    return segments[segment].disabledImage
      case .Selected:    return segments[segment].selectedImage
    }
  }

  /**
   insertSegmentWithImage:atIndex:animated:

   - parameter image: UIImage?
   - parameter segment: Int
   */
  public func insertSegmentWithImage(_ image: UIImage?, atIndex segment: Int) {
    insertSegmentWithImages([.Default: image], atIndex: segment)
  }

  /**
   insertSegmentWithImages:atIndex:

   - parameter images: [ImageButtonView.ImageState
   - parameter segment: Int
   */
  public func insertSegmentWithImages(_ images: [ImageButtonView.ImageState: UIImage?]?,
                              atIndex segment: Int)
  {
    let segments = self.segments
    guard segment <= segments.count else { fatalError("segment index \(segment) out of bounds") }
    let imageButtonView = ImageButtonView(autolayout: true)
    images?.forEach {imageButtonView.setImage($1, forState: $0)}
    imageButtonView.normalTintColor = normalTintColor
    imageButtonView.highlightedTintColor = highlightedTintColor
    imageButtonView.disabledTintColor = disabledTintColor
    imageButtonView.selectedTintColor = selectedTintColor
    if segments.count == stack.arrangedSubviews.count {
      stack.insertArrangedSubview(imageButtonView, at: segment)
    } else if segment == segments.count {
      stack.addArrangedSubview(imageButtonView)
    } else {
      guard let idx = stack.arrangedSubviews.firstIndex(of: segments[segment]) else {
        fatalError("failed to resolve insertion point for new segment")
      }
      stack.insertArrangedSubview(imageButtonView, at: idx)
    }
    if selectedSegmentIndex >= segment { selectedSegmentIndex += 1 }
  }

  /**
   removeSegmentAtIndex:animated:

   - parameter segment: Int
   */
  public func removeSegmentAtIndex(_ segment: Int) {
    let segments = self.segments
    guard segments.indices.contains(segment) else { fatalError("segment index \(segment) out of bounds") }
    let imageButtonView = segments[segment]
    stack.removeArrangedSubview(imageButtonView)
    imageButtonView.removeFromSuperview()
    if selectedSegmentIndex == segment { selectedSegmentIndex = ImageSegmentedControl.NoSegment }
  }

  /** removeAllSegments */
  public func removeAllSegments() {
    segments.forEach {
      stack.removeArrangedSubview($0)
      $0.removeFromSuperview()
    }
    selectedSegmentIndex = ImageSegmentedControl.NoSegment
  }

  public static let NoSegment = UISegmentedControl.noSegment

  @IBInspectable public var allowsEmptySelection: Bool = true

  @IBInspectable public var momentary: Bool = false {
    didSet {
      guard oldValue != momentary
         && momentary
         && selectedSegmentIndex != ImageSegmentedControl.NoSegment else { return }
      segments[selectedSegmentIndex].isSelected = false
    }
  }

  @IBInspectable public var selectedSegmentIndex: Int = ImageSegmentedControl.NoSegment {
    didSet {
      // Make sure we are not momentary
      guard !momentary else { return }

      // Make sure the index has changed
      guard oldValue != selectedSegmentIndex else {
        // If the index is the same, make sure we de-select the segment if flagged appropriately
        if selectedSegmentIndex != ImageSegmentedControl.NoSegment && allowsEmptySelection {
          segments[selectedSegmentIndex].isSelected = false
          selectedSegmentIndex = ImageSegmentedControl.NoSegment
        }
        return
      }

      switch (oldValue, selectedSegmentIndex) {
        case let (ImageSegmentedControl.NoSegment, newIndex) where segments.indices.contains(newIndex):
          segments[newIndex].isSelected = true
        case let (newIndex, ImageSegmentedControl.NoSegment) where segments.indices.contains(newIndex):
          segments[newIndex].isSelected = false
        case let (oldIndex, newIndex) where segments.indices.contains(newIndex):
          segments[oldIndex].isSelected = false
          segments[newIndex].isSelected = true
        default:
          break
      }
    }
  }

  public var numberOfSegments: Int { return segments.count }

  fileprivate func setup() {
    stack = UIStackView(autolayout: true)
    stack.axis = .horizontal
    stack.distribution = .fill
    stack.alignment = .fill
    stack.spacing = 20
    addSubview(stack)
    constrain(𝗩∶|[stack!]|, 𝗛∶|[stack!]|)
  }

  /**
   intrinsicContentSize

   - returns: CGSize
   */
  public override var intrinsicContentSize: CGSize {
    return segments.reduce(CGSize.zero) {
      let size = $1.intrinsicContentSize
      return CGSize(width: $0.width + size.width, height: max($0.height, size.height))
    }
  }

  /**
   initWithFrame:

   - parameter frame: CGRect
   */
  public override init(frame: CGRect) { super.init(frame: frame); setup() }

  /**
   init:

   - parameter aDecoder: NSCoder
   */
  public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

  /** awakeFromNib */
  public override func awakeFromNib() {
    super.awakeFromNib()
    if stack == nil { setup() }
    segments.enumerated().forEach { $1.isSelected = $0 == selectedSegmentIndex }
  }
}
