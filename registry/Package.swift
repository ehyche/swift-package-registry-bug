// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "DependencyFirebaseRegistry",
    products: [
        .library(
            name: "VPrefix",
            targets: ["VPrefix"]
        ),
    ],
    dependencies: [
        .package(id: "firebase.firebase-ios-sdk", exact: "11.9.0"),
    ],
    targets: [
        .target(
            name: "VPrefix",
            dependencies: [
                .product(name: "FirebaseRemoteConfig", package: "firebase.firebase-ios-sdk"),
                .product(name: "FirebaseCrashlytics", package: "firebase.firebase-ios-sdk"),
                .product(name: "FirebasePerformance", package: "firebase.firebase-ios-sdk"),
            ]
        ),
    ]
)
