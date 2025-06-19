import PackageDescription

// swift-tools-version:6.0
let package = Package(
    name: "InFireStudio",
    platforms: [
        .iOS(.v13),
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "InFireStudio",
            targets: ["InFireStudio"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/supabase/supabase-swift.git",
            from: "2.0.0"
        ),
    ],
    targets: [
        .target(
            name: "InFireStudio",
            dependencies: [
                .product(name: "Supabase", package: "supabase-swift")
            ],
            path: "Sources/InFireStudio",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "InFireStudioTests",
            dependencies: ["InFireStudio"],
            path: "Tests/InFireStudioTests"
        ),
    ]
)

