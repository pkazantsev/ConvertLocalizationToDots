// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ConvertLocalizationToDots",
    dependencies: [
        .package(url: "https://github.com/kylef/Commander.git", from: "0.9.0"),
    ],
    targets: [
        .target(
            name: "ConvertLocalizationToDots",
            dependencies: ["Commander"]),
    ]
)
