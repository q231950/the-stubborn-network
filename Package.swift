// swift-tools-version: 5.7.1

import PackageDescription

let package = Package(
    name: "StubbornNetwork",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "StubbornNetwork",
            targets: ["StubbornNetwork"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "StubbornNetwork",
            dependencies: []),
        .testTarget(
            name: "StubbornNetworkTests",
            dependencies: ["StubbornNetwork"]),
    ]
)
