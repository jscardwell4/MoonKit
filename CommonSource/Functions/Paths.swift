//
//  Paths.swift
//  MoonKit_Mac
//
//  Created by Jason Cardwell on 12/21/17.
//  Copyright © 2017 Moondeer Studios. All rights reserved.
//
import Foundation

/// Checks whether a directory exists. If it does not exist and `createDirectories == true`,
/// the directory and any intermediate directories will be created.
///
/// - Parameters:
///    - url: The URL for the directory to check.
///    - createDirectories: Whether to create the directory, and any intermediates, if `url`
///                         does not exist.
/// - Throws: Any error thrown by `FileManager` while creating the directory.
public func checkDirectory(url: URL, createDirectories: Bool = false) throws -> Bool {

  var isDirectory: ObjCBool = false
  let exists = FileManager.`default`.fileExists(atPath: url.path, isDirectory: &isDirectory)

  switch (exists, isDirectory.boolValue) {
    case (true, true):
      return true
    case (true, false),
         (false, _) where !createDirectories:
      return false
    default:
      try FileManager.`default`.createDirectory(at: url, withIntermediateDirectories: true)
      return true
  }

}

#if os(macOS)

/// Performs glob expansion using the specified shell and arguments on the provided list of
/// file paths.
///
/// - Parameters:
///   - paths: The paths for which glob expansion is to be performed.
///   - shell: The path to the shell executable. Default is `"/bin/zsh"`.
///   - arguments: The arguments to pass to `shell` minus the `paths` element. This should
///                expand glob patterns into a newline-delimited list for expanded paths to
///                appear as separate elements in the returned array. Default is `["-c",
///                "print -l --"]
/// - Returns: `paths` with glob patterns expanded into individual elements.
/// - Note: May return an empty array if `shell` and `arguments` aren't set correctly.
public func expandGlobPatterns(in paths: [String],
                               shell: String = "/bin/zsh",
                               arguments: [String] = ["-c", "print -l --"]) -> [String]
{

  var fileList: [String] = []

  let leadingArguments = Array(arguments.dropLast())
  guard let lastArgument = arguments.last else {
    fatalError("\(#function) At least one argument must be present in `arguments`.")
  }

  for path in paths {

    let path = (path as NSString).replacingOccurrences(of: "(", with: "\\(")
                                 .replacingOccurrences(of: ")", with: "\\)")
    let process = Process()
    process.launchPath = shell
    process.arguments = leadingArguments + ["\(lastArgument) \(path)"]

    let pipe = Pipe()
    process.standardOutput = pipe
    process.launch()

    let expandedPath = String(data: pipe.fileHandleForReading.readDataToEndOfFile(),
                              encoding: .utf8)!

    fileList.append(contentsOf: expandedPath.split(separator: "\n").map(String.init))

  }

  return fileList

}

#endif
