// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "DependencyFirebaseSCM",
    products: [
        .library(
            name: "VPrefix",
            targets: ["VPrefix"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", exact: "11.9.0"),
    ],
    targets: [
        .target(
            name: "VPrefix",
            dependencies: [
                .product(name: "FirebaseRemoteConfig", package: "firebase-ios-sdk"),
                .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
                .product(name: "FirebasePerformance", package: "firebase-ios-sdk"),
	        ]
        ),
    ]
)
