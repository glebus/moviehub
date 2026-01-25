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
        .library(name: "Auth", targets: ["Auth"])
    ],
    dependencies: [
        .package(path: "../Domain")
    ],
    targets: [
        .target(name: "MovieList", dependencies: ["Domain"]),
        .target(name: "MovieDetails", dependencies: ["Domain"]),
        .target(name: "FavoriteList", dependencies: ["Domain"]),
        .target(name: "Profile", dependencies: ["Domain"]),
        .target(name: "Auth", dependencies: ["Domain"])
    ]
)
