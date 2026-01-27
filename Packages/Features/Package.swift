// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Features",
    platforms: [
        .iOS(.v17),
        .macOS(.v15)
    ],
    products: [
        .library(name: "MovieList", targets: ["MovieList"]),
        .library(name: "MovieDetails", targets: ["MovieDetails"]),
        .library(name: "FavoriteList", targets: ["FavoriteList"]),
        .library(name: "Profile", targets: ["Profile"]),
        .library(name: "Auth", targets: ["Auth"]),
        .library(name: "AuthButton", targets: ["AuthButton"]),
        .library(name: "Router", targets: ["Router"])
    ],
    dependencies: [
        .package(path: "../Domain")
    ],
    targets: [
        .target(name: "Router", dependencies: ["Domain"]),
        .target(
            name: "AuthButton",
            dependencies: ["Domain", "Router", .product(name: "DomainMocks", package: "Domain")]
        ),
        .target(
            name: "MovieList",
            dependencies: ["Domain", "Router", "AuthButton", .product(name: "DomainMocks", package: "Domain")]
        ),
        .target(
            name: "MovieDetails",
            dependencies: ["Domain", "Router", "AuthButton", .product(name: "DomainMocks", package: "Domain")]
        ),
        .target(
            name: "FavoriteList",
            dependencies: ["Domain", "Router", "AuthButton", .product(name: "DomainMocks", package: "Domain")]
        ),
        .target(
            name: "Profile",
            dependencies: ["Domain", "Router", "AuthButton", .product(name: "DomainMocks", package: "Domain")]
        ),
        .target(
            name: "Auth",
            dependencies: ["Domain", "Router", .product(name: "DomainMocks", package: "Domain")]
        ),
        .testTarget(
            name: "FeaturesTests",
            dependencies: [
                "MovieList",
                "MovieDetails",
                "FavoriteList",
                "Profile",
                "Auth",
                "AuthButton",
                "Router",
                .product(name: "DomainMocks", package: "Domain")
            ]
        )
    ]
)
