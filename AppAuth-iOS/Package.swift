// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "AppAuth",
    platforms: [
        .macOS(.v10_10),
        .iOS(.v8),
        .tvOS(.v9),
        .watchOS(.v2)
    ],
    products: [
        .library(
            name: "AppAuth",
            targets: ["AppAuth"]),
        .library(
            name: "AppAuthCore",
            targets: ["Core"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Core",
            dependencies: [],
            path: ".",
            sources: ["Source/Core"],
            publicHeadersPath: "Source/Core",
            cSettings: [
                .headerSearchPath("Source/Core")
            ]
        ),
        .testTarget(
            name: "AppAuthCoreTests", 
            dependencies: ["Core"],
            path: ".", 
            exclude: ["UnitTests/OIDSwiftTests.swift"], 
            sources: ["UnitTests"]
        ),
        .target(
            name: "AppAuth",
            dependencies: ["Core"],
            path: ".",
            sources: ["Source/iOS"]
        )
    ]
)
