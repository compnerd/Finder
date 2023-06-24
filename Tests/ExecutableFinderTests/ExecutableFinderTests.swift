// Copyright 2023 Saleem Abdulrasool <compnerd@compnerd.org>
// SPDX-License-Identifier: BSD-3-Clause

import ExecutableFinder
import Foundation
import XCTest

class ExecutableFinderTests: XCTestCase {
  #if os(Windows)
  func testWhich() throws {
    let cmd = try XCTUnwrap(which("cmd"))
    let comspec = try XCTUnwrap(ProcessInfo.processInfo.environment["ComSpec"])
    XCTAssertEqual(cmd, URL(fileURLWithPath: comspec).path)
  }
  #endif
}
