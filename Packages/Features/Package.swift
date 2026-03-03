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
        .library(name: "MovieDetailsFavoriteButton", targets: ["MovieDetailsFavoriteButton"]),
        .library(name: "FavoriteList", targets: ["FavoriteList"]),
        .library(name: "FavoriteListDetails", targets: ["FavoriteListDetails"]),
        .library(name: "FavoriteListCreate", targets: ["FavoriteListCreate"]),
        .library(name: "FavoriteListAddMovies", targets: ["FavoriteListAddMovies"]),
        .library(name: "FavoriteListPicker", targets: ["FavoriteListPicker"]),
        .library(name: "FavoriteListsManage", targets: ["FavoriteListsManage"]),
        .library(name: "Profile", targets: ["Profile"]),
        .library(name: "Auth", targets: ["Auth"]),
        .library(name: "AuthButton", targets: ["AuthButton"]),
        .library(name: "Coordinator", targets: ["Coordinator"])
    ],
    dependencies: [
        .package(path: "../Domain")
    ],
    targets: [
        .target(
            name: "Coordinator",
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
                "Coordinator",
                .product(name: "DomainMocks", package: "Domain")
            ]
        ),
        .target(
            name: "MovieList",
            dependencies: [
                .product(name: "DomainModels", package: "Domain"),
                .product(name: "DomainUseCases", package: "Domain"),
                "Coordinator",
                "AuthButton",
                .product(name: "DomainMocks", package: "Domain")
            ]
        ),
        .target(
            name: "MovieDetails",
            dependencies: [
                .product(name: "DomainModels", package: "Domain"),
                .product(name: "DomainUseCases", package: "Domain"),
                "Coordinator",
                "AuthButton",
                "MovieDetailsFavoriteButton",
                .product(name: "DomainMocks", package: "Domain")
            ]
        ),
        .target(
            name: "MovieDetailsFavoriteButton",
            dependencies: [
                .product(name: "DomainModels", package: "Domain"),
                .product(name: "DomainUseCases", package: "Domain"),
                "Coordinator",
                .product(name: "DomainMocks", package: "Domain")
            ]
        ),
        .target(
            name: "FavoriteList",
            dependencies: [
                .product(name: "DomainModels", package: "Domain"),
                .product(name: "DomainUseCases", package: "Domain"),
                "Coordinator",
                "AuthButton",
                .product(name: "DomainMocks", package: "Domain")
            ]
        ),
        .target(
            name: "FavoriteListDetails",
            dependencies: [
                .product(name: "DomainModels", package: "Domain"),
                .product(name: "DomainUseCases", package: "Domain"),
                "Coordinator",
                "AuthButton"
            ]
        ),
        .target(
            name: "FavoriteListCreate",
            dependencies: [
                .product(name: "DomainModels", package: "Domain"),
                .product(name: "DomainUseCases", package: "Domain"),
                "Coordinator"
            ]
        ),
        .target(
            name: "FavoriteListAddMovies",
            dependencies: [
                .product(name: "DomainModels", package: "Domain"),
                .product(name: "DomainUseCases", package: "Domain"),
                "Coordinator"
            ]
        ),
        .target(
            name: "FavoriteListPicker",
            dependencies: [
                .product(name: "DomainModels", package: "Domain"),
                .product(name: "DomainUseCases", package: "Domain"),
                "Coordinator",
                "AuthButton"
            ]
        ),
        .target(
            name: "FavoriteListsManage",
            dependencies: [
                .product(name: "DomainModels", package: "Domain"),
                .product(name: "DomainUseCases", package: "Domain"),
                "Coordinator"
            ]
        ),
        .target(
            name: "Profile",
            dependencies: [
                .product(name: "DomainModels", package: "Domain"),
                .product(name: "DomainUseCases", package: "Domain"),
                "Coordinator",
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
                "Coordinator",
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
                "MovieDetailsFavoriteButton",
                "FavoriteList",
                "FavoriteListDetails",
                "FavoriteListCreate",
                "FavoriteListAddMovies",
                "FavoriteListPicker",
                "FavoriteListsManage",
                "Profile",
                "Auth",
                "AuthButton",
                "Coordinator",
                .product(name: "DomainMocks", package: "Domain")
            ]
        )
    ]
)
