# CHANGELOG

## August 31, 2023

* Update to turbo-ios v7.0.0 and bump min to iOS 14 [#44](https://github.com/joemasilotti/TurboNavigator/pull/44)
* Pass a configuration to the web view create block by @seanpdoyle [#41](https://github.com/joemasilotti/TurboNavigator/pull/41)
* Option to override `sessionDidLoadWebView(_:)` by @yanshiyason [#35](https://github.com/joemasilotti/TurboNavigator/pull/35)
* Handle `/resume_historical_location` route [#38](https://github.com/joemasilotti/TurboNavigator/pull/38)
* Automatically handle errors with option to override [#45](https://github.com/joemasilotti/TurboNavigator/pull/45)

### Breaking changes

* Minimum iOS support is now iOS 14
* `makeCustomWebView()` configurations should be updated to take a `WKWebViewConfiguration`

```swift
TurboConfig.shared.makeCustomWebView = { (configuration: WKWebViewConfiguration) in
    // Customize the WKWebViewConfiguration instance
    // ...
    return WKWebView(frame: .zero, configuration: configuration)
}
```

## May 22, 2023

* Add new optional delegate callback to handle when the web view process dies [5800f54](https://github.com/joemasilotti/TurboNavigator/commit/5800f541ed0d437956b8b52163348987da06332c)

## March 12, 2023

* External URLs are presented via `SFSafariViewController` but can be customized [#18](https://github.com/joemasilotti/TurboNavigator/pull/18)
* Option to customize web view and configuration [#17](https://github.com/joemasilotti/TurboNavigator/pull/17)
* `Navigation` is now public [#16](https://github.com/joemasilotti/TurboNavigator/pull/16)
* Option to customize `VisitableViewController` [#14](https://github.com/joemasilotti/TurboNavigator/pull/14)

### Breaking changes

* `TurboNavigationDelegate.shouldRoute(_:)` was removed
* `TurboNavigationDelegate.customController(for:) -> UIViewController?`
    * Renamed to `controller(_:forProposal:) -> UIViewController?`
    * Returning `nil` now stops default navigation

## March 8, 2023

* Rename project to Turbo Navigator
* Add option to pass in custom `UINavigationController` subclasses
* Add tests to handle most of the navigation flows
* Add error handling example to Demo project from turbo-ios

### Breaking changes

* `TurboNavigationController` was renamed to `TurboNavigator`
* `TurboNavigator.rootViewController` now exposes the main navigation controller

## March 6, 2023

* Initial project launch!
