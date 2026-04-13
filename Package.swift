// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MiyeonSlap",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "MiyeonSlap",
            targets: ["MiyeonSlap"]
        ),
        .executable(
            name: "LovaSlapPET",
            targets: ["LovaSlapPET"]
        )
    ],
    targets: [
        .executableTarget(
            name: "MiyeonSlap"
        ),
        .executableTarget(
            name: "LovaSlapPET"
        )
    ]
)
