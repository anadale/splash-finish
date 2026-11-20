// swift-tools-version: 5.10
import PackageDescription

let kit = { (name: String) in Target.Dependency.product(name: name, package: "BobukKit") }

let package = Package(
    name: "SplashFinish",
    platforms: [.macOS(.v14)],
    products: [.executable(name: "SplashFinish", targets: ["SplashFinish"])],
    dependencies: [
        .package(path: "Vendor/BobukKit"),
        .package(url: "https://github.com/sparkle-project/Sparkle", exact: "2.10.1"),
    ],
    targets: [
        .target(name: "SplashFinishCore", dependencies: [kit("BobukCore")]),
        .executableTarget(name: "SplashFinish",
                          dependencies: ["SplashFinishCore", .product(name: "Sparkle", package: "Sparkle"),
                                         kit("BobukCore"), kit("BobukSystem"), kit("BobukUI"), kit("BobukUpdates")],
                          resources: [.copy("Resources/Integrations"), .copy("Resources/Orca")]),
        .testTarget(name: "SplashFinishCoreTests", dependencies: ["SplashFinishCore", kit("BobukCore")]),
        .testTarget(name: "SplashFinishTests", dependencies: ["SplashFinish", kit("BobukCore"), kit("BobukSystem"),
                                                              kit("BobukUI"), kit("BobukUpdates")])
    ]
)
