# CHANGELOG

## March 12, 2023

* Option to customize `VisitableViewController`

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
