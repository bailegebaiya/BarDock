// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "BarDock",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "BarDock", targets: ["BarDock"])
    ],
    targets: [
        .executableTarget(name: "BarDock")
    ]
)
