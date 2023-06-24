// swift-tools-version: 5.8

import PackageDescription

let ExecutableFinder =
    Package(name: "ExecutableFinder",
            products: [
              .library(name: "ExecutableFinder", targets: ["ExecutableFinder"])
            ],
            targets: [
              .target(name: "ExecutableFinder"),
              .testTarget(name: "ExecutableFinderTests",
                          dependencies: ["ExecutableFinder"])
            ])
