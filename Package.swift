// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "vnvce-vapor",
    platforms: [
       .macOS(.v12)
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.57.0"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.4.0"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.2.6"),
        .package(url: "https://github.com/SwifQL/VaporBridges.git", from:"1.0.0-rc"),
        .package(url: "https://github.com/SwifQL/PostgresBridge.git", from:"1.0.0-rc"),
        .package(url: "https://github.com/vapor/apns.git", from: "2.2.0"),
        .package(url: "https://github.com/vapor/jwt.git", from: "4.1.0"),
        .package(name: "AWSSDKSwift", url: "https://github.com/soto-project/soto.git", from: "4.8.0")
    ],
    targets: [
        .target(
            name: "App",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                .product(name: "VaporBridges", package: "VaporBridges"),
                    .product(name: "PostgresBridge", package: "PostgresBridge"),
                .product(name: "APNS", package: "apns"),
                .product(name: "JWT", package: "jwt"),
                .product(name: "SNS", package: "AWSSDKSwift")
            ],
            swiftSettings: [
                // Enable better optimizations when building in Release configuration. Despite the use of
                // the `.unsafeFlags` construct required by SwiftPM, this flag is recommended for Release
                // builds. See <https://github.com/swift-server/guides/blob/main/docs/building.md#building-for-production> for details.
                .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release))
            ]
        ),
        .executableTarget(name: "Run", dependencies: [.target(name: "App")]),
        .testTarget(name: "AppTests", dependencies: [
            .target(name: "App"),
            .product(name: "XCTVapor", package: "vapor"),
        ])
    ]
)
