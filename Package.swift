// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SwiftSymbols",
    defaultLocalization: "en",
    platforms: [.iOS(.v13), .macOS(.v11), .tvOS(.v13), .watchOS(.v6), .visionOS(.v1)],
    products: [.library(name: "SwiftSymbols", targets: ["SwiftSymbols"])],
    targets: [.target(name: "SwiftSymbols", resources: [.process("Resources")])]
)
