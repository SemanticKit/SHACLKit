// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "SHACLKit",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .visionOS(.v26)
    ],
    products: [
        .library(
            name: "SHACLKit",
            targets: ["SHACLKit"]
        )
    ],
    dependencies: [
        .package(path: "../SemanticKit"),
        .package(path: "../RDFKit")
    ],
    targets: [
        .target(
            name: "SHACLKit",
            path: "SHACLKit"
        ),
        .testTarget(
            name: "SHACLKitTests",
            dependencies: [
                "SHACLKit",
                "SemanticKit",
                "RDFKit"
            ],
            path: "SHACLKitTests",
            resources: [
                .copy("Fixtures")
            ]
        )
    ]
)
