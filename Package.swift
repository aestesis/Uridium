// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "Uridium",
    products: [
        .library(name: "Uridium",targets: ["Uridium"]),
    ],
    dependencies: [
        .package(url: "https://github.com/aestesis/X11.git", .exact("1.0.2")),
        .package(url: "https://github.com/aestesis/Vulkan.git", .exact("1.0.2"))
    ],
    targets: [
        .target(name: "Uridium",dependencies: [])
    ]
)


