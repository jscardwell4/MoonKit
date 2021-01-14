//
//  UIImage+MoonKitAdditions.swift
//  MoonKit
//
//  Created by Jason Cardwell on 5/26/15.
//  Copyright (c) 2015 Jason Cardwell. All rights reserved.
//

import Foundation
import UIKit
import CoreImage
import class CoreImage.CIImage

extension UIImage.Orientation: CustomStringConvertible {
  public var description: String {
    switch self {
      case .up:            return "Up"
      case .down:          return "Down"
      case .left:          return "Left"
      case .right:         return "Right"
      case .upMirrored:    return "UpMirrored"
      case .downMirrored:  return "DownMirrored"
      case .leftMirrored:  return "LeftMirrored"
      case .rightMirrored: return "RightMirrored"
      @unknown default:
        fatalError("\(#fileID) \(#function) Unexpected value.")
    }
  }
}

fileprivate func imageFromImage(_ image: UIImage, color: UIColor) -> UIImage {
  guard let img = CIImage(image: image) else { return image }
  let context = CIContext(options: nil)
  let parameters = ["inputImage": CIImage(color: CIColor(color: color)), "inputBackgroundImage": img]
  guard let filter = CIFilter(name: "CISourceInCompositing", parameters: parameters),
            let outputImage = filter.outputImage else { return image }
  return UIImage(cgImage: context.createCGImage(outputImage, from: img.extent)!,
                 scale: image.scale,
                 orientation: image.imageOrientation)
}

fileprivate func invertImage(_ image: UIImage) -> UIImage {
  guard let img = CIImage(image: image) else { return image }
  let context = CIContext(options: nil)
  let parameters = ["inputImage": img]
  guard let filter = CIFilter(name: "CIColorInvert", parameters: parameters),
            let outputImage = filter.outputImage else { return image }
  return UIImage(cgImage: context.createCGImage(outputImage, from: img.extent)!,
                scale: image.scale,
                orientation: image.imageOrientation)
}

fileprivate func imageByAddingBackgroundColor(_ image: UIImage, color: UIColor) -> UIImage {
  guard let img = CIImage(image: image) else { return image }
  let context = CIContext(options: nil)
  let parameters = ["inputBackgroundImage": CIImage(color: CIColor(color: color)), "inputImage": img]
  guard let filter = CIFilter(name: "CISourceAtopCompositing", parameters: parameters),
            let outputImage = filter.outputImage else { return image }
  return UIImage(cgImage: context.createCGImage(outputImage, from: img.extent)!,
                 scale: image.scale,
                 orientation: image.imageOrientation)
}

fileprivate func imageMaskToAlpha(_ image: UIImage) -> UIImage {
  guard let img = CIImage(image: image) else { return image }
  let context = CIContext(options: nil)
  let parameters = ["inputImage": img]
  guard let filter = CIFilter(name: "CIMaskToAlpha", parameters: parameters),
            let outputImage = filter.outputImage else { return image }
  return UIImage(cgImage: context.createCGImage(outputImage, from: img.extent)!,
                scale: image.scale,
                orientation: image.imageOrientation)
}

public extension UIImage {
  func heightScaledToWidth(_ width: CGFloat) -> CGFloat {
    fatalError("fix me after dust settles on Ratio")
    /*let (w, h) = size.unpack
    let ratio = Ratio(w / h)
    return ratio.denominatorForNumerator(width)*/
  }

  func image(withBackgroundColor color: UIColor) -> UIImage {
    return imageByAddingBackgroundColor(self, color: color)
  }
  func image(withColor color: UIColor) -> UIImage {
    return imageFromImage(self, color: color)
  }
  var inverted: UIImage { return invertImage(self) }
  var maskToAlpha: UIImage { return imageMaskToAlpha(self) }
  var mask: UIImage { return imageByAddingBackgroundColor(self, color: UIColor.black) }
  func addClip() {
    guard let context = UIGraphicsGetCurrentContext() else { return }
    let boundingBox = context.boundingBoxOfClipPath
    let transform = context.ctm
    context.scaleBy(x: 1, y: -1)
    context.translateBy(x: 0, y: transform.ty / transform.d)
    context.clip(to: boundingBox, mask: cgImage!)
    context.scaleBy(x: 1, y: -1)
    context.translateBy(x: 0, y: transform.ty / transform.d)
  }
}
