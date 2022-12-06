// swift-tools-version:5.7.1
import PackageDescription

let package = Package(
    name: "vnvce-vapor",
    platforms: [
       .macOS(.v12)
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.67.4"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.5.0"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.4.0"),
        .package(url: "https://github.com/vapor/apns.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/jwt.git", from: "4.2.1"),
        .package(url: "https://github.com/auth0/JWTDecode.swift.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/leaf.git", from: "4.2.2"),
        .package(url: "https://github.com/vapor/leaf-kit", from: "1.8.0"),
        .package(url: "https://github.com/vapor/redis.git", from: "4.6.0"),
        .package(url: "https://github.com/vapor/queues-redis-driver.git", from: "1.0.3"),
        .package(url: "https://github.com/brokenhandsio/fluent-postgis.git", from: "0.3.0"),
        .package(url: "https://github.com/socialayf/vnvce-core.git", branch: "main"),
        .package(url: "https://github.com/soto-project/soto.git", from: "6.2.0")
    ],
    targets: [
        .target(
            name: "App",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                .product(name: "APNS", package: "apns"),
                .product(name: "JWT", package: "jwt"),
                .product(name: "JWTDecode", package: "JWTDecode.swift"),
                .product(name: "Leaf", package: "leaf"),
                .product(name: "LeafKit", package: "leaf-kit"),
                .product(name: "Redis", package: "redis"),
                .product(name: "QueuesRedisDriver", package: "queues-redis-driver"),
                .product(name: "FluentPostGIS", package: "fluent-postgis"),
                .product(name: "VNVCECore", package: "vnvce-core"),
                .product(name: "SotoS3", package: "soto"),
                .product(name: "SotoSNS", package: "soto"),
                .product(name: "SotoSecretsManager", package: "soto"),
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
