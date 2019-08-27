// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "Bugsnag",
    platforms: [
        .macOS(.v10_10),
        .tvOS(.v9),
        .iOS(.v9),
    ],
    products: [
        .library(name: "Bugsnag", targets: ["Bugsnag"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "Bugsnag", 
                dependencies: [], 
                path: "Source",
                publicHeadersPath: "Source",
                cSettings: [
                  .headerSearchPath("KSCrash/Source/KSCrash/Reporting/Filters"),
                  .headerSearchPath("KSCrash/Source/KSCrash/Recording/Tools"),
                  .headerSearchPath("KSCrash/Source/KSCrash/Recording"),
                  .headerSearchPath("KSCrash/Source/KSCrash/Recording/Sentry"),
                  .headerSearchPath("."),
                ]),
    ]
)
