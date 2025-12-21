// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "AnyLanguageModelKit",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
        .visionOS(.v1),
    ],
    products: [
        .library(
            name: "AnyLanguageModelKit",
            targets: ["AnyLanguageModelKit"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/mattt/AnyLanguageModel",
            from: "0.5.1",
            traits: [
                .trait(name: "MLX"),
            ]
        ),
        .package(
            url: "https://github.com/ml-explore/mlx-swift-lm",
            branch: "main"
        )
    ],
    targets: [
        .target(
            name: "AnyLanguageModelKit",
            dependencies: [
                .product(name: "AnyLanguageModel", package: "AnyLanguageModel"),
                .product(
                    name: "MLXLLM",
                    package: "mlx-swift-lm",
                    condition: .when(platforms: [.macOS, .iOS, .visionOS])
                ),
                .product(
                    name: "MLXVLM",
                    package: "mlx-swift-lm",
                    condition: .when(platforms: [.macOS, .iOS, .visionOS])
                ),
                .product(
                    name: "MLXLMCommon",
                    package: "mlx-swift-lm",
                    condition: .when(platforms: [.macOS, .iOS, .visionOS])
                )
            ]
        )
    ]
)