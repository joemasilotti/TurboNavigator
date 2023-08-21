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
        .package(url: "https://github.com/hotwired/turbo-ios", revision: "312f36977959a14f5cee3c658d92633162b9177d"),
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
