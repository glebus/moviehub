// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Data",
    platforms: [
        .iOS(.v18),
        .macOS(.v15)
    ],
    products: [
        .library(name: "Data", targets: ["Data"])
    ],
    dependencies: [
        .package(path: "../Domain"),
        .package(url: "https://github.com/apple/swift-async-algorithms.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "Data",
            dependencies: [
                .product(name: "DomainModels", package: "Domain"),
                .product(name: "DomainRepositories", package: "Domain"),
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms")
            ]
        ),
        .testTarget(
            name: "DataTests",
            dependencies: ["Data", .product(name: "DomainModels", package: "Domain")]
        )
    ]
)
