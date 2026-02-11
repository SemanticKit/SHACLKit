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
    targets: [
        .target(
            name: "SHACLKit",
            path: "SHACLKit"
        ),
        .testTarget(
            name: "SHACLKitTests",
            dependencies: ["SHACLKit"],
            path: "SHACLKitTests"
        )
    ]
)
