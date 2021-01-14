//
//  LiteralTypes.swift
//  MoonKit
//
//  Created by Jason Cardwell on 1/14/21.
//  Copyright © 2021 Moondeer Studios. All rights reserved.
//
import Foundation

#if os(iOS)

import class UIKit.UIImage

public protocol ImageAssetLiteralType
{
  var image: UIImage { get }
}

public extension ImageAssetLiteralType where Self: RawRepresentable,
                                             Self.RawValue == String
{
  var image: UIImage { return UIImage(named: rawValue)! }
}

public extension ImageAssetLiteralType where Self: CaseIterable
{
  static var allImages: [UIImage] { return allCases.map { $0.image } }
}

import class SpriteKit.SKTexture
import class SpriteKit.SKTextureAtlas
public protocol TextureAssetLiteralType
{
  static var atlas: SKTextureAtlas { get }
  var texture: SKTexture { get }
}

public extension TextureAssetLiteralType where Self: RawRepresentable,
                                               Self.RawValue == String
{
  var texture: SKTexture { return Self.atlas.textureNamed(rawValue) }
}

public extension TextureAssetLiteralType where Self: CaseIterable
{
  static var allTextures: [SKTexture] { return allCases.map { $0.texture } }
}

#endif
