// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Features",
    platforms: [
        .iOS(.v18),
        .macOS(.v15)
    ],
    products: [
        .library(name: "MovieList", targets: ["MovieList"]),
        .library(name: "MovieDetails", targets: ["MovieDetails"]),
        .library(name: "FavoriteList", targets: ["FavoriteList"]),
        .library(name: "FavoriteListDetails", targets: ["FavoriteListDetails"]),
        .library(name: "FavoriteListCreate", targets: ["FavoriteListCreate"]),
        .library(name: "FavoriteListPicker", targets: ["FavoriteListPicker"]),
        .library(name: "FavoriteListsManage", targets: ["FavoriteListsManage"]),
        .library(name: "Profile", targets: ["Profile"]),
        .library(name: "Auth", targets: ["Auth"]),
        .library(name: "AuthButton", targets: ["AuthButton"]),
        .library(name: "Router", targets: ["Router"])
    ],
    dependencies: [
        .package(path: "../Domain")
    ],
    targets: [
        .target(
            name: "Router",
            dependencies: [
                .product(name: "DomainModels", package: "Domain"),
                .product(name: "DomainUseCases", package: "Domain")
            ]
        ),
        .target(
            name: "AuthButton",
            dependencies: [
                .product(name: "DomainModels", package: "Domain"),
                .product(name: "DomainUseCases", package: "Domain"),
                "Router",
                .product(name: "DomainMocks", package: "Domain")
            ]
        ),
        .target(
            name: "MovieList",
            dependencies: [
                .product(name: "DomainModels", package: "Domain"),
                .product(name: "DomainUseCases", package: "Domain"),
                "Router",
                "AuthButton",
                .product(name: "DomainMocks", package: "Domain")
            ]
        ),
        .target(
            name: "MovieDetails",
            dependencies: [
                .product(name: "DomainModels", package: "Domain"),
                .product(name: "DomainUseCases", package: "Domain"),
                "Router",
                "AuthButton",
                .product(name: "DomainMocks", package: "Domain")
            ]
        ),
        .target(
            name: "FavoriteList",
            dependencies: [
                .product(name: "DomainModels", package: "Domain"),
                .product(name: "DomainUseCases", package: "Domain"),
                "Router",
                "AuthButton",
                .product(name: "DomainMocks", package: "Domain")
            ]
        ),
        .target(
            name: "FavoriteListDetails",
            dependencies: [
                .product(name: "DomainModels", package: "Domain"),
                .product(name: "DomainUseCases", package: "Domain"),
                "Router",
                "AuthButton"
            ]
        ),
        .target(
            name: "FavoriteListCreate",
            dependencies: [
                .product(name: "DomainModels", package: "Domain"),
                .product(name: "DomainUseCases", package: "Domain"),
                "Router"
            ]
        ),
        .target(
            name: "FavoriteListPicker",
            dependencies: [
                .product(name: "DomainModels", package: "Domain"),
                .product(name: "DomainUseCases", package: "Domain"),
                "Router",
                "AuthButton"
            ]
        ),
        .target(
            name: "FavoriteListsManage",
            dependencies: [
                .product(name: "DomainModels", package: "Domain"),
                .product(name: "DomainUseCases", package: "Domain"),
                "Router"
            ]
        ),
        .target(
            name: "Profile",
            dependencies: [
                .product(name: "DomainModels", package: "Domain"),
                .product(name: "DomainUseCases", package: "Domain"),
                "Router",
                "AuthButton",
                "FavoriteListsManage",
                .product(name: "DomainMocks", package: "Domain")
            ]
        ),
        .target(
            name: "Auth",
            dependencies: [
                .product(name: "DomainModels", package: "Domain"),
                .product(name: "DomainUseCases", package: "Domain"),
                "Router",
                .product(name: "DomainMocks", package: "Domain")
            ]
        ),
        .testTarget(
            name: "FeaturesTests",
            dependencies: [
                .product(name: "DomainModels", package: "Domain"),
                .product(name: "DomainUseCases", package: "Domain"),
                "MovieList",
                "MovieDetails",
                "FavoriteList",
                "FavoriteListDetails",
                "FavoriteListCreate",
                "FavoriteListPicker",
                "FavoriteListsManage",
                "Profile",
                "Auth",
                "AuthButton",
                "Router",
                .product(name: "DomainMocks", package: "Domain")
            ]
        )
    ]
)
