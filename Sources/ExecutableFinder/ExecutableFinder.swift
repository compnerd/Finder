// Copyright 2023 Saleem Abdulrasool <compnerd@compnerd.org>
// SPDX-License-Identifier: BSD-3-Clause

import Foundation

public var kDefaultSearchPath: [String] {
  var paths: [String] = [FileManager.default.currentDirectoryPath]
  #if os(Windows)
  paths.append(contentsOf: ProcessInfo.processInfo.environment["Path"]?.split(separator: ";").map(String.init) ?? [])
  #else
  paths.append(contentsOf: ProcessInfo.processInfo.environment["PATH"]?.split(separator: ":").map(String.init) ?? [])
  #endif
  return paths
}

public var kDefaultSearchExtensions: [String] {
  var extensions: [String] = [""]
  #if os(Windows)
  extensions.append(contentsOf: ProcessInfo.processInfo.environment["PATHEXT"]?.split(separator: ";").map(String.init) ?? [])
  #endif
  return extensions
}

/// An iterator over paths to an executable.
///
/// This type provides a mechanism for searching for an executable in a set of
/// paths.
public struct ExecutableFinder {
  let executable: String
  let paths: [String]
  let extensions: [String]

  public func makeIterator() -> Iterator {
    Iterator(self)
  }
}

extension ExecutableFinder {
  public struct Iterator: IteratorProtocol {
    let finder: ExecutableFinder
    var indicies: (Array<String>.Index, Array<String>.Index)

    init(_ finder: ExecutableFinder) {
      self.finder = finder
      self.indicies = (finder.paths.startIndex, finder.extensions.startIndex)
    }

    public mutating func next() -> String? {
      guard indicies.0 < finder.paths.endIndex,
          indicies.1 < finder.extensions.endIndex else { return nil }

      defer {
        indicies.1 = finder.extensions.index(after: indicies.1)
        if indicies.1 == finder.extensions.endIndex {
          indicies.0 = finder.paths.index(after: indicies.0)
          indicies.1 = finder.extensions.startIndex
        }
      }

      let executable = finder.executable
      while indicies.0 < finder.paths.endIndex {
        let path = URL(fileURLWithPath: finder.paths[indicies.0], isDirectory: true)
        while indicies.1 < finder.extensions.endIndex {
          let ext = finder.extensions[indicies.1].lowercased()
          let location = path.appendingPathComponent("\(executable)\(ext)")
          if FileManager.default.isExecutableFile(atPath: location.path) {
            return location.path
          }
          indicies.1 = finder.extensions.index(after: indicies.1)
        }
        indicies.0 = finder.extensions.index(after: indicies.0)
        if indicies.0 == finder.paths.endIndex { break }
        indicies.1 = finder.extensions.startIndex
      }

      return nil
    }
  }
}

/// Find an executable in the search path.
///
/// This function searches the platform specific path environment variable for
/// the executable and returns the first match. If no match is found, `nil` is
/// returned. The search is performed in the following order:
///   1. The current working directory.
///   2. The directories listed in the platform specific path environment
///      variable.
/// On Windows, the `PATHEXT` environment variable is used to determine the
/// extensions to append to the executable name when searching.
///
/// - Parameters:
///   - executable: the executable to search for
///   - paths: the paths to search (defaults to the contents of the platform
///            specific path environment variable)
///   - extensions: the extensions to append to the executable name (defaults to
///                 the contents of the `PATHEXT` environment variable on
///                 Windows)
/// - Returns: the path to the executable or `nil` if not found
public func which(_ executable: String,
                  in paths: [String] = kDefaultSearchPath,
                  extensions: [String] = kDefaultSearchExtensions) -> String? {
  var iterator =
        ExecutableFinder(executable: executable, paths: paths, extensions: extensions)
                .makeIterator()
  return iterator.next()
}
