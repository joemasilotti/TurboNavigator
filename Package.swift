// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "TurboNavigator",
    platforms: [
        .iOS(.v14),
    ],
    products: [
        .library(
            name: "TurboNavigator",
            targets: ["TurboNavigator"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/hotwired/turbo-ios", .upToNextMajor(from: "7.0.0")),
        .package(url: "https://github.com/hotwired/strada-ios", branch: "main"),
    ],
    targets: [
        .target(
            name: "TurboNavigator",
            dependencies: [
                .product(name: "Turbo", package: "turbo-ios"),
                .product(name: "Strada", package: "strada-ios"),
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "TurboNavigatorTests",
            dependencies: ["TurboNavigator"],
            path: "Tests"
        ),
    ]
)
