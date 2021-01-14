//
//  InlinePickerViewCell.swift
//  MoonKit
//
//  Created by Jason Cardwell on 7/2/15.
//  Copyright © 2015 Jason Cardwell. All rights reserved.
//

import Foundation
import UIKit

class InlinePickerViewCell: UICollectionViewCell {

  override init(frame: CGRect) { super.init(frame: frame); setup() }

  required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder); setup() }

  override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
    super.apply(layoutAttributes)

    guard let attributes = layoutAttributes as? InlinePickerViewLayout.Attributes else { return }
    isSelected = attributes.isSelected
  }


  var contentOffset: UIOffset = .zero {
    didSet {
      contentCenterXConstraint?.constant = contentOffset.horizontal
      contentCenterYConstraint?.constant = contentOffset.vertical
    }
  }

  fileprivate var contentCenterXConstraint: NSLayoutConstraint?
  fileprivate var contentCenterYConstraint: NSLayoutConstraint?

  fileprivate func setup() {
    layer.isDoubleSided = false
    layer.shouldRasterize = true
    layer.rasterizationScale = UIScreen.main.scale

    translatesAutoresizingMaskIntoConstraints = false
    contentView.translatesAutoresizingMaskIntoConstraints = false
    constrain(𝗛∶|[contentView]|, 𝗩∶|[contentView]|)

  }

  override class var requiresConstraintBasedLayout: Bool { return true }

}

final class InlinePickerViewLabelCell: InlinePickerViewCell {

  private let label = UILabel(autolayout: true, attributedText: nil)

  var text: NSAttributedString? {
    didSet {
      guard !isSelected else { return }
      label.attributedText = text
      label.sizeToFit()
    }
  }

  var selectedText: NSAttributedString? {
    didSet {
      guard isSelected else { return }
      label.attributedText = selectedText
      label.sizeToFit()
    }
  }

  override var isSelected: Bool {
    didSet {
      switch isSelected {
        case true where selectedText != nil:
          label.attributedText = selectedText
        default:
          label.attributedText = text
      }
      label.sizeToFit()
    }
  }

  fileprivate override func setup() {
    super.setup()

    label.adjustsFontSizeToFitWidth = false//true
    label.numberOfLines = 1
    label.lineBreakMode = .byTruncatingTail
    label.attributedText = isSelected ? selectedText : text
    contentView.addSubview(label)

    contentCenterXConstraint = (label.centerX == centerX).constraint
    contentCenterYConstraint = (label.centerY == centerY).constraint

    contentCenterXConstraint?.isActive = true
    contentCenterYConstraint?.isActive = true
  }

  override var description: String {
    var result = String(super.description.dropLast())
    result.append("; text = " + (text != nil ? "'\(text!.string)'" : "nil") + ">")
    return result
  }

  override var forLastBaselineLayout: UIView { return label.forLastBaselineLayout }

}

class InlinePickerViewImageCell: InlinePickerViewCell {

  fileprivate let imageView = UIImageView(autolayout: true)

  final var image: UIImage? {
    didSet {
      imageView.image = image
    }
  }

  final var imageColor: UIColor? {
    didSet {
      guard !isSelected else { return }
      imageView.tintColor = imageColor
    }
  }

  final var imageSelectedColor: UIColor? {
    didSet {
      guard isSelected else { return }
      imageView.tintColor = imageSelectedColor
    }
  }

  fileprivate override func setup() {
    super.setup()

    imageView.contentMode = .scaleAspectFit
//    imageView.backgroundColor = UIColor(red: 0, green: 1, blue: 0, alpha: 0.75)
    imageView.setContentHuggingPriority(UILayoutPriority.required, for: .horizontal)
    imageView.setContentHuggingPriority(UILayoutPriority.required, for: .vertical)
    contentView.addSubview(imageView)

    contentCenterXConstraint = (imageView.centerX == centerX).constraint
    contentCenterYConstraint = (imageView.centerY == centerY).constraint

    contentCenterXConstraint?.isActive = true
    contentCenterYConstraint?.isActive = true

    constrain(imageView.width <= width, imageView.height <= height)
  }

  final override var isSelected: Bool {
    didSet {
      imageView.tintColor = isSelected ? imageSelectedColor : imageColor
    }
  }

  final override var forLastBaselineLayout: UIView { return imageView.forLastBaselineLayout }

}

final class InlinePickerViewDebugCell: InlinePickerViewImageCell {

  fileprivate override func setup() {
    super.setup()

    let size = CGSize(square: UIScreen.main.bounds.width)
    UIGraphicsBeginImageContextWithOptions(size, false, 0)
    let circle = UIBezierPath(ovalIn: CGRect(size: size))
    UIColor.lightGray.withAlphaComponent(0.25).setFill()
    circle.fill()
    imageView.image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    imageView.contentMode = .scaleToFill
  }
}

