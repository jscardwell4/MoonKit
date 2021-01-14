//
//  Named.swift
//  MoonKit
//
//  Created by Jason Cardwell on 1/14/21.
//  Copyright © 2021 Moondeer Studios. All rights reserved.
//
import Foundation

// MARK: - Named

/** Protocol for an object guaranteed to have a name */
public protocol Named
{
  var name: String { get }
}

// MARK: - DynamicallyNamed

public protocol DynamicallyNamed: Named
{
  var name: String { get set }
}

// MARK: - Nameable

/** Protocol for an object that may have a name */
public protocol Nameable
{
  var name: String? { get }
}

// MARK: - Renameable

/** Protocol for an object that may have a name and for which a name may be set */
public protocol Renameable: Nameable
{
  var name: String? { get set }
}

