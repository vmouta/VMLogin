import PackageDescription

let package = Package(
    name: "VMLogin",
    dependencies: [
        .Package(url: "https://github.com/Alamofire/Alamofire.git",
                 majorVersion: 4)
    ],
    exclude: ["Example"]
)
