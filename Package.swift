// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "Uridium",
    products: [
        .library(name: "Uridium",targets: ["Uridium"]),
    ],
    dependencies: [
        .package(url: "https://github.com/aestesis/xcb.git", from:"1.0.1"),
        .package(url: "https://github.com/aestesis/Vulkan.git", from:"1.0.6")
    ],
    targets: [
        .target(name: "Uridium",dependencies: ["xcb","Vulkan"])
    ]
)


