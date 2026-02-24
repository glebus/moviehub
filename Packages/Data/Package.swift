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
        .package(path: "../Domain")
    ],
    targets: [
        .target(
            name: "Data",
            dependencies: [
                .product(name: "DomainModels", package: "Domain"),
                .product(name: "DomainRepositories", package: "Domain")
            ]
        ),
        .testTarget(
            name: "DataTests",
            dependencies: ["Data", .product(name: "DomainModels", package: "Domain")]
        )
    ]
)
