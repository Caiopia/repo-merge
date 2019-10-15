// swift-tools-version:5.1
import PackageDescription

let package = Package(
  name: "AppAuth",
  platforms: [
    //      .macOS(.v10_9),
    .iOS(.v8),
    //      .tvOS(.v9),
    //      .watchOS(.v2)
  ],
  products: [
    .library(name: "AppAuth-iOS", targets: ["AppAuth-iOS"]),
    .library(name: "AppAuth_iOS", targets: ["AppAuth_iOS"]),
  ],
  targets: [
    .target(name: "AppAuth-iOS", dependencies: [], path: "Source"),
    .testTarget(name: "AppAuth-iOSTests", dependencies: ["AppAuth-iOS"], path: "UnitTests"),
    .target(name: "AppAuth_iOS", dependencies: [], path: "Source"),
    .testTarget(name: "AppAuth_iOSTests", dependencies: ["AppAuth_iOS"], path: "UnitTests"),
  ]
)
