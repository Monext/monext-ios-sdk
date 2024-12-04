// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Monext",
    defaultLocalization: "en",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "Monext",
            type: .dynamic,
            targets: ["Monext"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/nalexn/ViewInspector.git", from: "0.9.0"),
        .package(url: "https://github.com/ios-3ds-sdk/SPM.git", from: "2.5.30")
    ],
    targets: [
        .target(
            name: "Monext",
            dependencies: [
                .product(name: "ThreeDS_SDK", package: "SPM"),
            ],
            path: "Sources",
            resources: [
               .process("Monext/AppMetadata.plist"),
               .process("Monext/Resources/Images.xcassets"),
               .process("Monext/Resources/Localizable.xcstrings")
           ]
        ),
        .testTarget(
            name: "MonextTests",
            dependencies: [
                "Monext",
                .product(name: "ViewInspector", package: "ViewInspector")
            ],
            resources: [
               .process("API/TestResources")
           ]
        ),
    ]
)
