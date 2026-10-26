// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "iOSChatApp",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "iOSChatAppCore",
            targets: ["iOSChatAppCore"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/firebase/firebase-ios-sdk.git",
            from: "10.20.0"
        )
    ],
    targets: [
        .target(
            name: "iOSChatAppCore",
            dependencies: [
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseStorage", package: "firebase-ios-sdk")
            ],
            path: "Sources",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "iOSChatAppUITests",
            dependencies: ["iOSChatAppCore"],
            path: "iOSChatAppUITests"
        )
    ]
)
