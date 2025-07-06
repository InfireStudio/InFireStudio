// swift-tools-version:6.0

import PackageDescription

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
        .package(
            url: "https://github.com/mixpanel/mixpanel-swift",
            from: "4.0.0"
        ),
        .package(
            url: "https://github.com/firebase/firebase-ios-sdk.git",
            from: "11.0.0"
        ),
        .package(
            url: "https://github.com/RevenueCat/purchases-ios-spm.git",
            from: "5.0.0"
        ),
    ],
    targets: [
        .target(
            name: "InFireStudio",
            dependencies: [
                .product(name: "Supabase", package: "supabase-swift"),
                .product(name: "Mixpanel", package: "mixpanel-swift"),
                .product(name: "FirebaseCore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseStorage", package: "firebase-ios-sdk"),
                .product(name: "FirebaseRemoteConfig", package: "firebase-ios-sdk"),
                .product(name: "FirebaseMessaging", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFunctions", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAppCheck", package: "firebase-ios-sdk"),
                .product(name: "RevenueCat", package: "purchases-ios-spm"),
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
