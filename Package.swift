// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "SystemMonitor",
    platforms: [.iOS(.v15)],
    targets: [
        .executableTarget(
            name: "SystemMonitor",
            path: "Sources"
        )
    ]
)
