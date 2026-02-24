// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Domain",
    platforms: [
        .iOS(.v18),
        .macOS(.v15)
    ],
    products: [
        .library(name: "DomainModels", targets: ["DomainModels"]),
        .library(name: "DomainUseCases", targets: ["DomainUseCases"]),
        .library(name: "DomainRepositories", targets: ["DomainRepositories"]),
        .library(name: "DomainMocks", targets: ["DomainMocks"])
    ],
    targets: [
        .target(name: "DomainModels"),
        .target(name: "DomainRepositories", dependencies: ["DomainModels"]),
        .target(name: "DomainUseCases", dependencies: ["DomainModels", "DomainRepositories"]),
        .target(
            name: "DomainMocks",
            dependencies: ["DomainModels", "DomainUseCases", "DomainRepositories"]
        ),
        .testTarget(
            name: "DomainTests",
            dependencies: ["DomainModels", "DomainUseCases", "DomainRepositories", "DomainMocks"]
        )
    ]
)
