# swift-package-registry-bug

## Background

This repository provides a reproduction case for a bug in Swift Package Manager when using package registries. The bug is this:

***When the tags of a repository contain a "v" prefix, then package resolution will fail when using a package registry. Package resolution succeeds
if the same repository is referenced via SCM references.***

There are two directories in this repo: `scm` and `registry`. They contain identical packages, except that the `Package.swift` in the `scm` directory contains a reference via SCM, and the `Package.swift` in the `registry` directory contains a reference via a package registry identifier.

Here is the `scm/Package.swift`:

```
// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "VPrefix",
    products: [
        .library(
            name: "VPrefix",
            targets: ["VPrefix"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/google/gtm-session-fetcher.git", from: "4.4.0"),
    ],
    targets: [
        .target(
            name: "VPrefix",
            dependencies: [
                .product(name: "GTMSessionFetcher", package: "gtm-session-fetcher"),
            ]
        ),
    ]
)
```

And here is the `registry/Package.swift`:

```
// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "VPrefix",
    products: [
        .library(
            name: "VPrefix",
            targets: ["VPrefix"]
        ),
    ],
    dependencies: [
        .package(id: "google.gtm-session-fetcher", from: "4.4.0"),
    ],
    targets: [
        .target(
            name: "VPrefix",
            dependencies: [
                .product(name: "GTMSessionFetcher", package: "google.gtm-session-fetcher"),
            ]
        ),
    ]
)
```

Note that `https://github.com/google/gtm-session-fetcher` is a repository where all of the tags have a "v" prefix:

```
$ git clone https://github.com/google/gtm-session-fetcher.git
$ cd gtm-session-fetcher
$ git tag --list
v1.1.0
v1.1.1
v1.1.10
v1.1.11
v1.1.12
v1.1.13
v1.1.14
v1.1.15
v1.1.2
v1.1.3
v1.1.4
v1.1.5
v1.1.6
v1.1.7
v1.1.8
v1.1.9
v1.2.0
v1.2.1
v1.2.2
v1.3.0
v1.3.1
v1.4.0
v1.5.0
v1.6.0
v1.6.1
v1.7.0
v1.7.1
v1.7.2
v2.0.0
v2.1.0
v2.2.0
v2.3.0
v3.0.0
v3.1.0
v3.1.1
v3.2.0
v3.3.0
v3.3.1
v3.3.2
v3.4.0
v3.4.1
v3.5.0
v4.0.0
v4.1.0
v4.2.0
v4.3.0
v4.4.0
$
```

## Reproducing the bug

To verify that package resolution succeeds when using SCM references, do the following:

```
$ cd sm
$ swift package resolve
Fetching https://github.com/google/gtm-session-fetcher.git from cache
Fetched https://github.com/google/gtm-session-fetcher.git from cache (0.45s)
Computing version for https://github.com/google/gtm-session-fetcher.git
Computed https://github.com/google/gtm-session-fetcher.git at 4.4.0 (0.81s)
Creating working copy for https://github.com/google/gtm-session-fetcher.git
Working copy of https://github.com/google/gtm-session-fetcher.git resolved at 4.4.0
$ 
```

Now to reproduce the bug, you must first set up a package registry service. I recommend using [this open-source implementation](https://github.com/hollyoops/swiftPM-registry-service). I am working on a Vapor-based implementation, but it is not ready to be open-sourced yet.

First, set up the package registry service:

```
$ git clone https://github.com/hollyoops/swiftPM-registry-service.git
$ cd swiftPM-registry-service
$ pnpm install
$ export GITHUB_ACCESS_TOKEN="<your-Github-PAT>"
$ pnpm start
```

Now, set up the registry.

```
$ cd registry
$ swift package-registry set --global http://127.0.0.1:3001
```

Note that this will give you an error, since http://127.0.0.1:3001 is not prefixed with "https". So you can first do this:

```
$ cd registry
$ swift package-registry set --global https://127.0.0.1:3001
```

and then go edit `~/.swiftpm/configuration/registries.json`:

```
{
  "authentication" : {

  },
  "registries" : {
    "[default]" : {
      "supportsAvailability" : false,
      "url" : "https://127.0.0.1:3001"
    }
  },
  "version" : 1
}
```

Change "https://127.0.0.1:3001" to "http://127.0.0.1:3001".

Now you can reproduce the bug:

```
$ cd registry
$ swift package resolve --verbose --replace-scm-with-registry
warning: 'registry': /Applications/Xcode-16.2.0.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-frontend -frontend -c -primary-file /Users/ehyche/src/none/TestApps/SPMRegistryBug/registry/Package.swift -target arm64-apple-macosx13.0 -Xllvm -aarch64-use-tbi -enable-objc-interop -stack-check -sdk /Applications/Xcode-16.2.0.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX15.2.sdk -I /Applications/Xcode-16.2.0.app/Contents/Developer/Platforms/MacOSX.platform/Developer/usr/lib -I /Applications/Xcode-16.2.0.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/pm/ManifestAPI -F /Applications/Xcode-16.2.0.app/Contents/Developer/Platforms/MacOSX.platform/Developer/Library/Frameworks -vfsoverlay /var/folders/k7/xs91gbms6ss13kbnh3641qhc0000gn/T/TemporaryDirectory.AMo3AE/vfs.yaml -swift-version 6 -package-description-version 6.0.0 -new-driver-path /Applications/Xcode-16.2.0.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-driver -empty-abi-descriptor -resource-dir /Applications/Xcode-16.2.0.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift -module-name main -disable-clang-spi -target-sdk-version 15.2 -target-sdk-name macosx15.2 -external-plugin-path '/Applications/Xcode-16.2.0.app/Contents/Developer/Platforms/MacOSX.platform/Developer/usr/lib/swift/host/plugins#/Applications/Xcode-16.2.0.app/Contents/Developer/Platforms/MacOSX.platform/Developer/usr/bin/swift-plugin-server' -external-plugin-path '/Applications/Xcode-16.2.0.app/Contents/Developer/Platforms/MacOSX.platform/Developer/usr/local/lib/swift/host/plugins#/Applications/Xcode-16.2.0.app/Contents/Developer/Platforms/MacOSX.platform/Developer/usr/bin/swift-plugin-server' -plugin-path /Applications/Xcode-16.2.0.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/host/plugins -plugin-path /Applications/Xcode-16.2.0.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/local/lib/swift/host/plugins -o /var/folders/k7/xs91gbms6ss13kbnh3641qhc0000gn/T/TemporaryDirectory.zVWDD2/Package-1.o
/Applications/Xcode-16.2.0.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang /var/folders/k7/xs91gbms6ss13kbnh3641qhc0000gn/T/TemporaryDirectory.zVWDD2/Package-1.o -F /Applications/Xcode-16.2.0.app/Contents/Developer/Platforms/MacOSX.platform/Developer/Library/Frameworks --sysroot /Applications/Xcode-16.2.0.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX15.2.sdk --target=arm64-apple-macosx13.0 /Applications/Xcode-16.2.0.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/macosx/libswiftCompatibilityPacks.a -L /Applications/Xcode-16.2.0.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/macosx -L /Applications/Xcode-16.2.0.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX15.2.sdk/usr/lib/swift -L /Applications/Xcode-16.2.0.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/pm/ManifestAPI -L /Applications/Xcode-16.2.0.app/Contents/Developer/Platforms/MacOSX.platform/Developer/usr/lib -lPackageDescription -Xlinker -rpath -Xlinker /Applications/Xcode-16.2.0.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/pm/ManifestAPI -o /var/folders/k7/xs91gbms6ss13kbnh3641qhc0000gn/T/TemporaryDirectory.dmmjE4/registry-manifest
Apple Swift version 6.0.3 (swiftlang-6.0.3.1.10 clang-1600.0.30.1)
Target: arm64-apple-macosx13.0
Running resolver because the following dependencies were added: 'google.gtm-session-fetcher' (google.gtm-session-fetcher)
info: 'google.gtm-session-fetcher': retrieving google.gtm-session-fetcher metadata from http://127.0.0.1:3001/google/gtm-session-fetcher
Computing version for google.gtm-session-fetcher
error: Dependencies could not be resolved because no versions of 'google.gtm-session-fetcher' match the requirement 4.4.0..<5.0.0 and root depends on 'google.gtm-session-fetcher' 4.4.0..<5.0.0.
$
```

