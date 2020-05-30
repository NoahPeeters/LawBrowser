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
            targets: ["GermanLaws", "GermanLawsApi"]),
        .executable(name: "GermanLawsServer", targets: ["GermanLawsServer"])
    ],
    dependencies: [
        .package(url: "https://github.com/MaxDesiatov/XMLCoder.git", from: "0.11.1"),
        .package(url: "https://github.com/weichsel/ZIPFoundation.git", from: "0.9.11")
    ],
    targets: [
        .target(
            name: "GermanLawsServer",
            dependencies: []),
        .target(
            name: "GermanLaws",
            dependencies: []),
        .target(
            name: "GermanLawsApi",
            dependencies: ["GermanLaws", "XMLCoder", "ZIPFoundation"]),
        .testTarget(
            name: "GermanLawsTests",
            dependencies: ["GermanLaws"])
    ]
)
