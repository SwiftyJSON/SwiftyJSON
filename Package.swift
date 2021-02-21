// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "SwiftyJSON",
    products: [
        .library(name: "SwiftyJSON", targets: ["SwiftyJSON"])
    ],
    targets: [
        .target(name: "SwiftyJSON", dependencies: []),
        .testTarget(name: "SwiftJSONTests", dependencies: ["SwiftyJSON"])
    ],
    swiftLanguageVersions: [.v5]
)
