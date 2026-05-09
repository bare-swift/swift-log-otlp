// swift-tools-version: 6.0
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
// Copyright (c) 2026 The bare-swift Project Authors.

import PackageDescription

let package = Package(
    name: "swift-log-otlp",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "LogOTLP", targets: ["LogOTLP"])
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-docc-plugin.git", from: "1.4.0"),
        .package(url: "https://github.com/bare-swift/swift-bytes.git", from: "0.1.0"),
        .package(url: "https://github.com/bare-swift/swift-varint.git", from: "0.1.0"),
        .package(url: "https://github.com/bare-swift/swift-otlp-exporter.git", from: "0.1.0")
    ],
    targets: [
        .target(
            name: "LogOTLP",
            dependencies: [
                .product(name: "Bytes", package: "swift-bytes"),
                .product(name: "Varint", package: "swift-varint"),
                .product(name: "OTLPExporter", package: "swift-otlp-exporter")
            ]
        ),
        .testTarget(
            name: "LogOTLPTests",
            dependencies: ["LogOTLP"]
        )
    ]
)
