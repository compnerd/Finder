// Copyright 2023 Saleem Abdulrasool <compnerd@compnerd.org>
// SPDX-License-Identifier: BSD-3-Clause

import Foundation
import PathSurveyor
import XCTest

class PathSurveyorTests: XCTestCase {
  #if os(Windows)
  func testFindExecutable() throws {
    let cmd = try XCTUnwrap(find("cmd"))
    let comspec = try XCTUnwrap(ProcessInfo.processInfo.environment["ComSpec"])
    XCTAssertEqual(cmd.caseInsensitiveCompare(URL(fileURLWithPath: comspec).path), .orderedSame)
  }
  #endif
}
