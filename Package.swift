// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "TurboNavigator",
    platforms: [
        .iOS(.v12),
    ],
    products: [
        .library(
            name: "TurboNavigator",
            targets: ["TurboNavigator"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/hotwired/turbo-ios", revision: "2ace9ebe01fe3bce3e7e8df38cb82df052493663"),
    ],
    targets: [
        .target(
            name: "TurboNavigator",
            dependencies: [
                .product(name: "Turbo", package: "turbo-ios"),
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "TurboNavigatorTests",
            dependencies: ["TurboNavigator"],
            path: "Tests"
        )
    ]
)
