// swift-tools-version: 5.9

import PackageDescription

let PathSurveyor =
    Package(name: "PathSurveyor",
            products: [
              .library(name: "PathSurveyor", targets: ["PathSurveyor"])
            ],
            targets: [
              .target(name: "PathSurveyor"),
              .testTarget(name: "PathSurveyorTests",
                          dependencies: ["PathSurveyor"])
            ])
