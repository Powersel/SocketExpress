// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let blueSocketKitura: String = "https://github.com/Kitura/BlueSocket.git"
let socketDepName: String = "Socket"

let package = Package(
    name: "SocketExpress",
    platforms: [.iOS(.v10)],
//    products: [
//        .library(name: "YourPackageName", targets: ["YourPackageTarget"])
//      ],
    
    dependencies: [.package(name: socketDepName,
                            url: blueSocketKitura,
                            from: "1.0.0")],
    targets: [
        .target(
            name: "SocketExpress",
            dependencies: [.product(name: socketDepName,
                                    package: socketDepName)]),
        .testTarget(
            name: "SocketExpressTests",
            dependencies: ["SocketExpress"]),
    ]
)
