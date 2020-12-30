//
//  NSURL+MoonKitAdditions.swift
//  MoonKit
//
//  Created by Jason Cardwell on 9/28/15.
//  Copyright © 2015 Jason Cardwell. All rights reserved.
//

import Foundation

public func +(lhs: Optional<URL>, rhs: String) -> Optional<URL> {
  guard let url = lhs else { return nil }
  return Optional(url + rhs)
}
public func +(lhs: URL, rhs: String) -> URL { return lhs.appendingPathComponent(rhs) }
public func +=(lhs: inout URL, rhs: String) { lhs = lhs + rhs }
public func +<S:Sequence>(lhs: URL, rhs: S) -> URL where S.Iterator.Element == String {
  guard var urlComponents = URLComponents(url: lhs, resolvingAgainstBaseURL: false) else { return lhs }
  var path = urlComponents.path 
  for string in rhs { path += "/\(string)" }
  urlComponents.path = path
  guard let url = urlComponents.url else { return lhs }
  return url
}

extension URL {
  public func isEqualToFileURL(_ other: URL) -> Bool {
    assert(isFileURL, "\(#function) requires that `self` is a file URL")
    assert(other.isFileURL, "\(#function) requires that `other` is a file URL")

    let url1 = standardizedFileURL, url2 = other.standardizedFileURL

    var reference1: AnyObject?, reference2: AnyObject?
    do {
      let resourceValues1 = try url1.promisedItemResourceValues(forKeys: [.fileResourceIdentifierKey])
      let resourceValues2 = try url2.promisedItemResourceValues(forKeys: [.fileResourceIdentifierKey])
      reference1 = resourceValues1.fileResourceIdentifier
      reference2 = resourceValues2.fileResourceIdentifier
    } catch {
      loge("\(error)")
      return false
    }
    guard reference1 != nil && reference2 != nil else { return false }
    return reference1!.isEqual(reference2!)
  }

  public var pathBaseName: String? {
    let extensionCount = pathExtension.count
    let result = lastPathComponent
    guard extensionCount > 0 else { return result }
    let index = result.index(result.endIndex, offsetBy: -(extensionCount + 1))
    let substring = result[..<index]
    return String(substring)
  }
  
}
