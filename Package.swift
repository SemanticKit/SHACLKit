// swift-tools-version: 6.4
import PackageDescription

let package = Package(
    name: "SHACLKit",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(
            name: "SHACLKit",
            targets: ["SHACLKit"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/SemanticKit/RDFKit.git", branch: "wp/integration"),
        .package(url: "https://github.com/SemanticKit/IRIKit.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "SHACLKit",
            dependencies: [
                .product(name: "IRIKit", package: "IRIKit"),
                .product(name: "RDFCore", package: "RDFKit"),
                .product(name: "RDFKit", package: "RDFKit"),
            ]
        ),
        .testTarget(
            name: "SHACLKitTests",
            dependencies: [
                "SHACLKit",
                .product(name: "IRIKit", package: "IRIKit"),
                .product(name: "RDFCore", package: "RDFKit"),
                .product(name: "RDFFormats", package: "RDFKit"),
                .product(name: "RDFKit", package: "RDFKit"),
            ],
            resources: [
                .copy("Fixtures")
            ]
        )
    ]
)
