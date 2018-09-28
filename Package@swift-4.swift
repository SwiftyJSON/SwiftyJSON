// swift-tools-version:4.0

import PackageDescription

let package = Package(
        name: "SwiftyJSON",
        products: [
            .library(name: "SwiftyJSON", targets: ["SwiftyJSON"])
        ],
        targets: [
            .target(name: "SwiftyJSON",
                    path: "Source"),
            .testTarget(name: "SwiftyJSONTests",
                    dependencies: ["SwiftyJSON"],
                    path: "Tests"),
        ]
)
