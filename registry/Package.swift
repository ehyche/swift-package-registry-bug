// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "VPrefix",
    products: [
        .library(
            name: "VPrefix",
            targets: ["VPrefix"]
        ),
    ],
    dependencies: [
        .package(id: "google.gtm-session-fetcher", from: "4.4.0"),
    ],
    targets: [
        .target(
	    name: "VPrefix",
	    dependencies: [
	        .product(name: "GTMSessionFetcher", package: "google.gtm-session-fetcher"),
	    ]
	),
    ]
)
