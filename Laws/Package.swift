// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Laws",
    platforms: [.iOS(.v13), .macOS(.v10_15)],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "LawModel",
            targets: ["LawModel"]),
        .library(
            name: "LawClient",
            targets: ["LawClient"]),
        .library(
            name: "LawTextView",
            targets: ["LawTextView"]),
        .executable(name: "GermanLawsConverter", targets: ["GermanLawsConverter"])
    ],
    dependencies: [
        .package(url: "https://github.com/MaxDesiatov/XMLCoder.git", from: "0.11.1"),
        .package(url: "https://github.com/weichsel/ZIPFoundation.git", from: "0.9.11"),
        .package(url: "https://github.com/ReactiveCocoa/ReactiveSwift.git", from: "6.1.0")
    ],
    targets: [
        .target(
            name: "GermanLawsConverter",
            dependencies: ["LawModel",
                           "XMLCoder",
                           "ZIPFoundation",
                           "ReactiveSwift"]),
        .target(
            name: "LawModel",
            dependencies: []),
        .target(
            name: "LawClient",
            dependencies: ["LawModel"]),
        .target(
            name: "LawTextView",
            dependencies: ["LawModel"]),
        .testTarget(
            name: "LawModelTests",
            dependencies: ["LawModel"])
    ]
)
