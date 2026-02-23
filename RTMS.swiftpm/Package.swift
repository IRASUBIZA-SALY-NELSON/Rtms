// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "RTMS",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(name: "RTMS", targets: ["RTMS"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "RTMS",
            dependencies: [],
            path: "Sources/RTMS"
        )
    ]
)
