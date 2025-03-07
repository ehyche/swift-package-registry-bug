# swift-package-registry-bug

## Background

I am developing a Github-API-proxy-based Swift Package Registry service. I was testing it against a repo that has a dependency on [firebase-ios-sdk](https://github.com/firebase/firebase-ios-sdk). The package was failing to resolve. However, when I change it to use only SCM references instead of package registry references, then it resolves correctly.

**So I am trying to understand why this occurs. Is this a bug in SPM, or a bug in my package registry service implementation?**

To simplify things, I created this very simple repo which provides two Packages: one in the `scm` subdirectory, and one in the `registry` subdirectory.

* The package in the `registry` subdirectory is the one that will not resolve. It has a dependency on version `11.9.0` of `firebase-ios-sdk`. I attempted to resolve this using `swift package resolve --replace-scm-with-registry --very-verbose`. 
* The package in the `scm` subdirectory also has a dependency on version `11.9.0` of `firebase-ios-sdk`. But it uses only SCM references. I resolved this using `swift package resolve --very-verbose`.


