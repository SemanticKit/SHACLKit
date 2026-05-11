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
    dependencies: [
        .package(url: "https://github.com/SemanticKit/RDFKit.git", branch: "main"),
        .package(url: "https://github.com/SemanticKit/SemanticKit.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "SHACLKit",
        ),
        .testTarget(
            name: "SHACLKitTests",
            dependencies: [
                "SHACLKit",
                "SemanticKit",
                "RDFKit"
            ],
            resources: [
                .copy("Fixtures")
            ]
        )
    ]
)
