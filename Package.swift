// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "Uridium",
    products: [
        .library(name: "Uridium",targets: ["Uridium"]),
    ],
    dependencies: [
        .package(url: "https://github.com/aestesis/xcb.git", from:"1.0.0"),
        .package(url: "https://github.com/aestesis/Vulkan.git", from:"1.0.3")
    ],
    targets: [
        .target(name: "Uridium",dependencies: [])
    ]
)


