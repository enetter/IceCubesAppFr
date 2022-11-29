// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Timeline",
  platforms: [
    .iOS(.v16),
  ],
  products: [
    .library(
      name: "Timeline",
      targets: ["Timeline"]),
  ],
  dependencies: [
    .package(name: "Network", path: "../Network"),
    .package(name: "Models", path: "../Models"),
    .package(name: "Routeur", path: "../Routeur"),
  ],
  targets: [
    .target(
      name: "Timeline",
      dependencies: [
        .product(name: "Network", package: "Network"),
        .product(name: "Models", package: "Models"),
        .product(name: "Routeur", package: "Routeur")
      ]),
    .testTarget(
      name: "TimelineTests",
      dependencies: ["Timeline"]),
  ]
)