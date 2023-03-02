// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "TurboNavigationController",
    platforms: [
        .iOS(.v12),
    ],
    products: [
        .library(
            name: "TurboNavigationController",
            targets: ["TurboNavigationController"]),
    ],
    dependencies: [
        .package(url: "https://github.com/hotwired/turbo-ios", revision: "2ace9ebe01fe3bce3e7e8df38cb82df052493663"),
    ],
    targets: [
        .target(
            name: "TurboNavigationController",
            dependencies: [
                .product(name: "Turbo", package: "turbo-ios"),
            ]),
        .testTarget(
            name: "TurboNavigationControllerTests",
            dependencies: ["TurboNavigationController"]),
    ])
