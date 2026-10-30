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
        ),
        .library(
            name: "SHACL",
            targets: ["SHACL", "SHNEX"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/SemanticKit/RDFKit.git", branch: "wp/integration"),
        .package(url: "https://github.com/SemanticKit/IRIKit.git", branch: "main"),
    ],
    targets: [
        // The vocabularies, translated from the documents SHACL 1.2
        // publishes (shacl.ttl, shnex.ttl) on every build.
        .target(
            name: "SHACL",
            dependencies: [
                .product(name: "RDF", package: "RDFKit"),
                .product(name: "OWL", package: "RDFKit"),
            ],
            plugins: [.plugin(name: "RDFTranslatorPlugin", package: "RDFKit")]
        ),
        .target(
            name: "SHNEX",
            dependencies: ["SHACL"],
            plugins: [.plugin(name: "RDFTranslatorPlugin", package: "RDFKit")]
        ),
        .target(
            name: "SHACLKit",
            dependencies: [
                "SHACL",
                "SHNEX",
                .product(name: "IRIKit", package: "IRIKit"),
                .product(name: "RDFCore", package: "RDFKit"),
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
