//
//  JSONIncludeDirective.swift
//  MoonKit
//
//  Created by Jason Cardwell on 4/17/15.
//  Copyright (c) 2015 Jason Cardwell. All rights reserved.
//

import Foundation

internal class JSONIncludeDirective {
  let location: Range<String.Index>
  let file: IncludeFile!

  fileprivate let _parameters: String?

  var parameters: [String:String]? {
    if let p = _parameters {
      return Dictionary(",".split(p).map({disperse2("=".split($0))}))
    } else { return nil }
  }

  static func emptyCache() { cache = [:] }

  static var cacheSize: Int { return cache.count }

  fileprivate static var cache: [String:String] = [:]

  let subdirectives: [JSONIncludeDirective]

  init?(_ string: String, location loc: Range<String.Index>, directory: String) {
    location = loc
    let regex = ~/"<@include\\s+([^>]+\\.json)(?:,([^>]+))?>"
    let match = regex.firstMatch(in: string)

    assert(match?.captures.count == 3, "unexpected number of capture groups for regular expression")

    let possibleParameters = match?.captures[2]?.substring
    _parameters = possibleParameters == nil ? nil : String(possibleParameters!)
    if let fileName = match?.captures[1]?.substring, let includeFile = IncludeFile(URL(fileURLWithPath: "\(directory)/\(fileName)")) {
      file = includeFile
      subdirectives = JSONIncludeDirective._parseDirectives(in: file.content, directory: directory)
    } else { return nil }
  }

  static func parseDirectives(in url: URL) throws -> String {
    let string = try String(contentsOf: url)
    let directory = url.deletingLastPathComponent().path
    
    var result = ""
    var i = string.startIndex
    for directive in _parseDirectives(in: string, directory: directory) {
      result += string[i..<directive.location.lowerBound]
      result += directive.content
      i = directive.location.upperBound
    }
    if i < string.endIndex { result += string[i..<string.endIndex] }
    return result
  }

  fileprivate static func _parseDirectives(in string: String,
                                          directory: String) -> [JSONIncludeDirective]
  {
    let regex = ~/"(<@include[^>]+>)"
    let matches = regex.match(string: string)
    let ranges = matches.compactMap { $0.captures[1]?.range }
    let directives: [JSONIncludeDirective] = ranges.compactMap {
      let start = $0.lowerBound.samePosition(in: string)!
      let end = $0.upperBound.samePosition(in: string)!
      let subrange = start ..< end
      return JSONIncludeDirective(String(string[subrange]), location: subrange, directory: directory)
    }
    return directives
  }

  var description: String {
    var result = "\n".join(
      "location: \(location)",
      "parameters: \(parameters?.description ?? "nil")",
      "file: \(file.url.lastPathComponent)"
    )
    if subdirectives.count == 0 { result += "\nsubdirectives: []" }
    else {
      result += "\nsubdirectives: {\n" + "\n\n".join(subdirectives.map({$0.description})).indented(by: 4) + "\n}"
    }
    return result
  }

  var content: String {
    if let cachedContent = JSONIncludeDirective.cache["\(file.url.path),\(_parameters ?? "nil")"] {
      return cachedContent
    }
    var result: String = ""
    let fileContent = file.content
    if subdirectives.count == 0 { result = fileContent }
    else {
      var i = fileContent.startIndex
      for subdirective in subdirectives.sorted(by: {$0.location.lowerBound < $1.location.lowerBound}) {
        result += fileContent[i..<subdirective.location.lowerBound]
        result += subdirective.content
        i = subdirective.location.upperBound
      }
      if i < fileContent.endIndex { result += fileContent[i..<fileContent.endIndex] }
    }
    if let p = parameters {
      result = p.reduce(result, {$0.replacingOccurrences(of: "<#\($1.0)#>", with: $1.1)})
    }
    JSONIncludeDirective.cache["\(file.url.path),\(_parameters ?? "nil")"] = result
    return result
  }

//  struct IncludeFile {
//
//    let path: String
//    let content: String
//
//    fileprivate(set) lazy var parameters: Set<String> = {
//      let regex = ~/"<#([A-Z]+)#>"
//      let matches = regex.match(string: self.content)
//      let strings = matches.flatMap { match in match.captures.flatMap { $0?.string } }
//      return Set(strings)
//      }()
//
//    init?(_ p: String) {
//      if let cached = IncludeFile.cache[p] { self = cached }
//      else if FileManager.default.isReadableFile(atPath: p) {
//        do {
//        let c = try String(contentsOfFile: p, encoding: String.Encoding.utf8)
//        path = p; content = c; IncludeFile.cache[p] = self
//        } catch {
//          return nil
//        }
//      } else { return nil }
//    }
//
//    fileprivate static var cache: [String:IncludeFile] = [:]
//  }

  struct IncludeFile {

    let url: URL
    let content: String

    fileprivate(set) lazy var parameters: Set<String> = {
      let regex = ~/"([A-Z]+)"
      let matches = regex.match(string: self.content)
      let strings = matches.compactMap { (match: RegularExpression.Match) -> [String]? in
        match.captures.compactMap { (capture:RegularExpression.Capture?) -> String? in
          if let substring = capture?.substring {
            return String(substring)
          } else {
            return nil
          }
        }
      }


      return Set(strings.joined())
    }()

    init?(_ url: URL) {
      if let cached = IncludeFile.cache[url] { self = cached; return }
      guard let content = try? String(contentsOf: url) else { return nil }
      self.url = url
      self.content = content
    }

    fileprivate static var cache: [URL:IncludeFile] = [:]
  }

}

