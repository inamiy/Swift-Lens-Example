// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Lens",
    products: [
        .library(name: "Helpers", targets: ["Helpers"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-prelude.git", .revision("5d5005d")),
    ],
    targets: [
        .target(
            name: "Helpers",
            dependencies: ["Prelude"]
        ),
        .target(
            name: "Lens-pointfreeco",
            dependencies: ["Helpers", "Optics"]
        ),
        .target(
            name: "Lens-brandonw",
            dependencies: ["Helpers"]
        ),
    ]
)
