// Copyright 2023 Saleem Abdulrasool <compnerd@compnerd.org>
// SPDX-License-Identifier: BSD-3-Clause

import Foundation

public var kDefaultSearchPath: [String] {
  #if os(Windows)
  ProcessInfo.processInfo.environment["Path"]?.split(separator: ";").map(String.init) ?? []
  #else
  ProcessInfo.processInfo.environment["PATH"]?.split(separator: ":").map(String.init) ?? []
  #endif
}

public var kDefaultSearchExtensions: [String] {
  #if os(Windows)
  ProcessInfo.processInfo.environment["PATHEXT"]?.split(separator: ";").map(String.init) ?? []
  #else
  []
  #endif
}

/// A surveyor for executables.
///
/// This type provides a mechanism for searching for an executable in a set of
/// paths.
public struct Surveyor {
  let executable: String
  let paths: [String]
  let extensions: [String]

  public func makeIterator() -> SurveyorIterator {
    SurveyorIterator(self)
  }
}

extension Surveyor {
  public struct SurveyorIterator: IteratorProtocol {
    let surveyor: Surveyor
    let locations: [URL]
    var index: Array<URL>.Index

    init(_ surveyor: Surveyor) {
      self.surveyor = surveyor

      var locations: [URL] = []
      for path in [FileManager.default.currentDirectoryPath] + surveyor.paths {
        let dir = URL(fileURLWithPath: path, isDirectory: true)
        locations.append(dir.appendingPathComponent(surveyor.executable))
        for ext in surveyor.extensions {
          locations.append(dir.appendingPathComponent("\(surveyor.executable)\(ext)"))
        }
      }

      self.locations = locations
      self.index = locations.startIndex
    }

    public mutating func next() -> String? {
      guard index < locations.endIndex else { return nil }
      defer {
        if index < locations.endIndex {
          index = locations.index(after: index)
        }
      }

      while index < locations.endIndex {
        let location = locations[index]
        if FileManager.default.isExecutableFile(atPath: location.path) {
          return location.path
        }
        index = locations.index(after: index)
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
public func find(_ executable: String,
                 in paths: [String] = kDefaultSearchPath,
                 extensions: [String] = kDefaultSearchExtensions) -> String? {
  var iterator =
        Surveyor(executable: executable, paths: paths, extensions: extensions)
                .makeIterator()
  return iterator.next()
}
