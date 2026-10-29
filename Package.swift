// swift-tools-version: 6.3
import PackageDescription

let package = Package(
    name: "SHACLKit",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .visionOS(.v26),
    ],
    products: [
        .library(
            name: "SHACLKit",
            targets: ["SHACLKit"]
        )
    ],
    targets: [
        .target(
            name: "SHACLKit"
        ),
        .testTarget(
            name: "SHACLKitTests",
            dependencies: ["SHACLKit"],
            resources: [
                .copy("Fixtures")
            ]
        )
    ]
)
