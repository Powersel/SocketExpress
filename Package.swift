// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let blueSocketIBM: String = "https://github.com/IBM-Swift/BlueSocket.git"
let blueSocketKitura: String = "https://github.com/Kitura/BlueSocket.git"

let package = Package(
    name: "SocketExpress",
    products: [
        .library(
            name: "SocketExpress",
            targets: ["SocketExpress"]),],
    dependencies: [],
    targets: [
        .target(
            name: "SocketExpress",
            dependencies: []),
        .testTarget(
            name: "SocketExpressTests",
            dependencies: ["SocketExpress"]),
    ]
)
