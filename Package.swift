// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Monext",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "Monext",
            type: .dynamic,
            targets: ["Monext"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/nalexn/ViewInspector.git", from: "0.10.3"),
        .package(url: "https://github.com/ios-3ds-sdk/SPM.git", exact: "2.6.00")
    ],
    targets: [

        // MARK: - Executable du plugin
        .executableTarget(
            name: "InjectSecretsExecutable"
        ),

        // MARK: - Build plugin
        .plugin(
            name: "InjectSecrets",
            capability: .buildTool(),
            dependencies: ["InjectSecretsExecutable"]
        ),

        // MARK: - SDK principal
        .target(
            name: "Monext",
            dependencies: [
                .product(name: "ThreeDS_SDK", package: "SPM"),
            ],
            path: "Sources/Monext",
            resources: [
                .process("AppMetadata.plist"),
                .process("Resources/Images.xcassets"),
                .process("Resources/Localizable.xcstrings")
            ],
            plugins: [
                "InjectSecrets"
            ]
        ),

        // MARK: - Tests
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
