# CHANGELOG

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
