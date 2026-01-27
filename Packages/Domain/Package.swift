// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Domain",
    platforms: [
        .iOS(.v17),
        .macOS(.v15)
    ],
    products: [
        .library(name: "Domain", targets: ["Domain"]),
        .library(name: "DomainMocks", targets: ["DomainMocks"])
    ],
    targets: [
        .target(name: "Domain"),
        .target(name: "DomainMocks", dependencies: ["Domain"]),
        .testTarget(name: "DomainTests", dependencies: ["Domain", "DomainMocks"])
    ]
)
