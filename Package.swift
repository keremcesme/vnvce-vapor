// swift-tools-version:5.8
import PackageDescription

let package = Package(
    name: "vnvce-vapor",
    platforms: [
       .macOS(.v12)
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.76.0"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.8.0"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.6.0"),
        .package(url: "https://github.com/vapor/apns.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/jwt.git", from: "4.2.2"),
        .package(url: "https://github.com/vapor/jwt-kit.git", branch: "jws-spike"),
        .package(url: "https://github.com/vapor/leaf.git", from: "4.2.4"),
        .package(url: "https://github.com/vapor/leaf-kit", from: "1.10.2"),
        .package(url: "https://github.com/vapor/redis.git", from: "4.8.0"),
        .package(url: "https://github.com/vapor/queues-redis-driver.git", from: "1.0.4"),
        .package(url: "https://github.com/brokenhandsio/fluent-postgis.git", from: "0.3.0"),
        .package(url: "https://github.com/socialayf/vnvce-core.git", branch: "main"),
        .package(url: "https://github.com/soto-project/soto.git", from: "6.6.0")
    ],
    targets: [
        .target(
            name: "App",
            dependencies: [
                // Vapor Official Packages
                .product(name: "Vapor", package: "vapor"),
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                .product(name: "APNS", package: "apns"),
                .product(name: "JWT", package: "jwt"),
                .product(name: "JWTKit", package: "jwt-kit"),
                .product(name: "Leaf", package: "leaf"),
                .product(name: "LeafKit", package: "leaf-kit"),
                .product(name: "Redis", package: "redis"),
                .product(name: "QueuesRedisDriver", package: "queues-redis-driver"),
                
                // PostGIS Extension
                .product(name: "FluentPostGIS", package: "fluent-postgis"),
                
                // VNVCE Official Package
                .product(name: "VNVCECore", package: "vnvce-core"),
                
                // A community-supported Swift SDK for AWS
                .product(name: "SotoS3", package: "soto"),
                .product(name: "SotoSNS", package: "soto"),
                .product(name: "SotoSecretsManager", package: "soto"),
                .product(name: "SotoElastiCache", package: "soto")
            ],
            swiftSettings: [
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
