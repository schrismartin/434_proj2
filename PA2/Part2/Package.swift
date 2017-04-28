import PackageDescription

let package = Package(
	name: "Assignment2", 
	targets: [
        Target(name: "Library")
    ],
	dependencies: [ 
		.Package(url: "https://github.com/IBM-Swift/BlueSocket", majorVersion: 0, minor: 12)
	]
)
