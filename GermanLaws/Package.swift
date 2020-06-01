// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GermanLaws",
    platforms: [.iOS(.v13), .macOS(.v10_15)],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "GermanLaws",
            targets: ["GermanLaws", "ReactiveCombine", "CrawlerAPI"]),
        .library(
            name: "LawTextView",
            targets: ["LawTextView"]),
        .executable(name: "GermanLawsServer", targets: ["GermanLawsServer"])
    ],
    dependencies: [
        .package(url: "https://github.com/MaxDesiatov/XMLCoder.git", from: "0.11.1"),
        .package(url: "https://github.com/weichsel/ZIPFoundation.git", from: "0.9.11"),
        .package(url: "https://github.com/ReactiveCocoa/ReactiveSwift.git", from: "6.1.0")
    ],
    targets: [
        .target(
            name: "ReactiveCombine",
            dependencies: ["ReactiveSwift"]),
        .target(
            name: "GermanLawsServer",
            dependencies: ["CrawlerAPI"]),
        .target(
            name: "GermanLaws",
            dependencies: []),
        .target(
            name: "LawTextView",
            dependencies: ["GermanLaws"]),
        .target(
            name: "CrawlerAPI",
            dependencies: ["GermanLaws",
                           "XMLCoder",
                           "ZIPFoundation",
                           "ReactiveSwift"]),
        .testTarget(
            name: "GermanLawsTests",
            dependencies: ["GermanLaws"])
    ]
)
