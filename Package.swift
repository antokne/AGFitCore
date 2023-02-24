// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AGFitCore",
	platforms: [
		.iOS(.v13),
		.tvOS(.v13),
		.macOS(.v10_13),
	],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "AGFitCore",
            targets: ["AGFitCore"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
		.package(url: "https://github.com/antokne/AGCore", branch: "develop"),
		.package(url: "https://github.com/antokne/FitDataProtocol", branch: "feature/event-message-add-auto-generated-fields"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "AGFitCore",
			dependencies: [.product(name: "AGCore", package: "AGCore"),
						   .product(name: "FitDataProtocol", package: "FitDataProtocol")]),
        .testTarget(
            name: "AGFitCoreTests",
            dependencies: ["AGFitCore"]),
    ]
)
