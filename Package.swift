// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "SHACLKit",
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
