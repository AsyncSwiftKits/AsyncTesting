// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AsyncTesting",
    platforms: [.macOS(.v12), .iOS(.v13), .tvOS(.v13), .watchOS(.v6)],
    products: [
        .library(
            name: "AsyncTesting",
            targets: ["AsyncTesting"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "AsyncTesting",
            dependencies: [],
            linkerSettings: [.linkedFramework("XCTest")]
        ),
        .testTarget(
            name: "AsyncTestingTests",
            dependencies: ["AsyncTesting"]),
    ]
)
