// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SlatePDF",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "SlatePDF",
            targets: ["SlatePDF"]
        )
    ],
    targets: [
        .executableTarget(
            name: "SlatePDF",
            path: "Sources/SlatePDF"
        ),
        .testTarget(
            name: "SlatePDFTests",
            dependencies: ["SlatePDF"],
            path: "Tests/SlatePDFTests"
        )
    ]
)
