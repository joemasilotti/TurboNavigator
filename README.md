# Turbo Navigator

A drop-in class for [Turbo Native](https://github.com/hotwired/turbo-ios) apps to handle common navigation flows.

> Note: This package is still being actively developed and subject to breaking changes without warning.

![Artboard](https://user-images.githubusercontent.com/2092156/222941287-a7695d4a-b99c-4740-8b55-a20c1c777f9d.png)

## Why use this?

Turbo Native apps require a fair amount of navigation handling to create a decent experience.

Unfortunately, not much of this is built into turbo-ios. A lot of boilerplate is required to have anything more than basic pushing/popping of screens.

This package abstracts that boilerplate into a single class. You can drop it into your app and not worry about handling every flow manually.

I've been using something a version of this on the [dozens of Turbo Native apps](https://masilotti.com/services/) I've built over the years.

## Handled flows

When a link is tapped, turbo-ios sends a `VisitProposal` to your application code. Based on the [Path Configuration](https://github.com/hotwired/turbo-ios/blob/main/Docs/PathConfiguration.md), different `PathProperties` will be set.

* **Current context** - What state the app is in.
    * `modal` - a modal is currently presented 
    * `default` - otherwise
* **Given context** - Value of `context` on the requested link.
    * `modal` or `default`/blank
* **Given presentation** - Value of `presentation` on the proposal.
    * `replace`, `pop`, `refresh`, `clear_all`, `replace_root`, `none`, `default`/blank
* **Navigation** - The behavior that the navigation controller provides.

<table>
  <thead>
    <tr>
      <th>Current Context</th>
      <th>Given Context</th>
      <th>Given Presentation</th>
      <th>New Presentation</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code>default</code></td>
      <td><code>default</code></td>
      <td><code>default</code></td>
      <td>Push on main stack (or)<br>
        Replace if visiting same page (or)<br>
        Pop (and visit) if previous controller is same URL
      </td>
    </tr>
    <tr>
      <td><code>default</code></td>
      <td><code>default</code></td>
      <td><code>replace</code></td>
      <td>Replace controller on main stack</td>
    </tr>
    <tr>
      <td><code>default</code></td>
      <td><code>modal</code></td>
      <td><code>default</code></td>
      <td>Present a modal with only this controller</td>
    </tr>
    <tr>
      <td><code>default</code></td>
      <td><code>modal</code></td>
      <td><code>replace</code></td>
      <td>Present a modal with only this controller</td>
    </tr>
    <tr>
      <td><code>modal</code></td>
      <td><code>default</code></td>
      <td><code>default</code></td>
      <td>Dismiss then Push on main stack</td>
    </tr>
    <tr>
      <td><code>modal</code></td>
      <td><code>default</code></td>
      <td><code>replace</code></td>
      <td>Dismiss then Replace on main stack</td>
    </tr>
    <tr>
      <td><code>modal</code></td>
      <td><code>modal</code></td>
      <td><code>default</code></td>
      <td>Push on the modal stack</td>
    </tr>
    <tr>
      <td><code>modal</code> </td>
      <td><code>modal</code></td>
      <td><code>replace</code></td>
      <td>Replace controller on modal stack</td>
    </tr>
    <tr>
      <td><code>default</code></td>
      <td>(any)</td>
      <td><code>pop</code></td>
      <td>Pop controller off main stack</td>
    </tr>
    <tr>
      <td><code>default</code></td>
      <td>(any)</td>
      <td><code>refresh</code></td>
      <td>Pop on main stack then</td>
    </tr>
    <tr>
      <td><code>modal</code></td>
      <td>(any)</td>
      <td><code>pop</code></td>
      <td>Pop controller off modal stack (or)<br>
        Dismiss if one modal controller
      </td>
    </tr>
    <tr>
      <td><code>modal</code></td>
      <td>(any)</td>
      <td><code>refresh</code></td>
      <td>Pop controller off modal stack then<br>
        Refresh last controller on modal stack<br>
        (or)<br>
        Dismiss if one modal controller then<br>
        Refresh last controller on main stack
      </td>
    </tr>
    <tr>
      <td>(any)</td>
      <td>(any)</td>
      <td><code>clearAll</code></td>
      <td>Dismiss if modal controller then<br>
        Pop to root then<br>
        Refresh root controller on main stack
      </td>
    </tr>
    <tr>
      <td>(any)</td>
      <td>(any)</td>
      <td><code>replaceRoot</code></td>
      <td>Dismiss if modal controller then<br>
        Pop to root then<br>
        Replace root controller on main stack
      </td>
    </tr>
    <tr>
      <td>(any)</td>
      <td>(any)</td>
      <td><code>none</code></td>
      <td>Nothing</td>
    </tr>
  </tbody>
</table>

### Examples

To present forms (URLs ending in `/new` or `/edit`) as a modal, add the following to the `rules` key of your Path Configuration.

```json
{
  "patterns": [
    "/new$",
    "/edi$"
  ],
  "properties": {
    "context": "modal"
  }
}
```

To hook into the "refresh" [turbo-rails native route](https://github.com/hotwired/turbo-rails/blob/main/app/controllers/turbo/native/navigation.rb), add the following to the `rules` key of your Path Configuration. You can then call `refresh_or_redirect_to` in your controller to handle Turbo Native and web-based navigation.

```json
{
  "patterns": [
    "/refresh_historical_location"
  ],
  "properties": {
    "prsentation": "refresh"
  }
}
```

## Getting started

Check out the Demo app for an example on how to use Turbo Navigator.

More detailed instructions are coming soon. [PRs are welcome](https://github.com/joemasilotti/TurboNavigator/issues/1)!

## Demo project

The `Demo/` directory includes an iOS app and Ruby on Rails server to demo the package.

It shows off most of the navigation flows outlined above. There is also an example CRUD resource for more real world applications of each.

## Custom controller and routing overrides

You can also implement an optional method on the `TurboNavigationDelegate` to handle custom routing.

This is useful to break out of the default behavior and/or render a native screen.

```swift
class MyCustomClass: TurboNavigationDelegate {
    let navigator = TurboNavigator(delegate: self)

    func controller(_ controller: VisitableViewController, forProposal proposal: VisitProposal) -> UIViewController? {
        if proposal.url.path == "/numbers" {
            // Let Turbo Navigator route this custom controller.
            return NumbersViewController()
        } else if proposal.presentation == .clearAll {
            // Return nil to tell Turbo Navigator stop processing the request.
            return nil
        } else {
            // Return the given controller to continue with default behavior.
            // Optionally customize the given controller.
            controller.view.backgroundColor = .orange
            return controller
        }
    }
}
```

## Custom configuration

Customize the configuration via `TurboConfig`.

### Override the user agent

Keep "Turbo Native" to use `turbo_native_app?` on your Rails server.

```swift
TurboConfig.shared.userAgent = "Custom (Turbo Native)"
```

### Customize the web view and web view configuration

A block is used because a new instance is needed for each web view.

Don't forget to set user agent and use a shared process pool on the configuration.

```swift
TurboConfig.shared.makeCustomWebView = {
    let configuration = WKWebViewConfiguration()
    // Customize configuration.

    let webView = WKWebView(frame: .zero, configuration: configuration)
    // Customize web view.

    return webView
}
```

### Customize behavior for external URLs

Turbo cannot navigate across domains because page visits are done via JavaScript. A clicked link that points to a different domain is considered external.

By default, a `SFSafariViewController` is presented. This can be overridden by implementing the following delegate method.

```swift
class MyCustomClass: TurboNavigationDelegate {
    func openExternalURL(_ url: URL, from controller: UIViewController) {
        // Do something custom with the external URL.
        // The controller is provided to present on top of.
    }
}
```

## Cookbook

- [How to add new properties to path configuration rules](#how-to-add-new-properties-to-path-configuration-rules)
- [How to display a full-screen modal](#how-to-display-a-full-screen-modal)
- [How to display a full-screen modal and remove the "close" button](#how-to-display-a-full-screen-modal-and-remove-the-close-button)

### How to add new properties to path configuration rules

Here is what a typical rule looks like:

```json
{
  "patterns": ["/users/sign_in"],
  "properties": {
    "context": "modal"
  },
  "comment": "Present the web login screen in a modal"
}
```

By default, the `properties` property can take the following two configuration options:

- `context`
- `presentation`

The permitted values for each are defined here: [Navigation.swift](https://github.com/joemasilotti/TurboNavigator/blob/main/Sources/TurboNavigator/Navigation.swift)

Let's say we wanted to use specific view controllers for certain routes. We might want to add a new `controller` property.

```json
{
  "patterns": ["/users/sign_in"],
  "properties": {
    "context": "modal",
    "controller": "new_session"
  },
  "comment": "Present a native authentication controller when signing in."
}
```

Now that we added this new property to the path configuration, we should extend the `VisitProposal` struct to give it type-safe access.

1. Let's start by creating a new `enum` for it.

```swift
// NavigationExtension.swift
import TurboNavigator

enum Navigation {
    enum Controller: String {
        case `default`
        case newSession = "new_session"
        case newUser = "new_user"
        case loading
        case signOut
    }
}
```

2. Then let's extend the `VisitProposal`

```swift
// VisitProposalExtension.swift
import Turbo

extension VisitProposal {
    var controller: Navigation.Controller {
        if let rawValue = properties["controller"] as? String {
            return Navigation.Controller(rawValue: rawValue) ?? .default
        }
        return .default
    }
}
```

3. You can now access the new property. Here is an example:

```swift
func controller(_ controller: VisitableViewController, forProposal proposal: VisitProposal) -> UIViewController? {
  if proposal.controller == .newSession {
    // ... return a custom native view controller
  }
}
```

### How to display a full-screen modal

By default, modals use "pageSheet" presentation, occupying a 3rd of the screen and allowing swipe-down dismissal. To display a full-screen modal, add an option to your path configuration and set the presentation style within the `controller` function. This function can be used to configure the modal presentation for a specific route before returning the controller.

1. Add a new property to the path configuration

```json
{
  "patterns": ["/very_long_form/new"],
  "properties": {
    "context": "modal",
    "modalPresentationStyle": "full_screen"
  },
  "comment": "Present the very long form in a full-screen modal"
}
```

2. Configure access to the `modalPresentationStyle` on the `VisitProposal`:

```swift
// NavigationExtension.swift
import TurboNavigator

extension Navigation {
  enum ModalPresentationStyle: String {
    case `default`
    case fullScreen = "full_screen"
  }
}
// VisitProposalExtension.swift
import Turbo

extension VisitProposal {
  var modalPresentationStyle: Navigation.ModalPresentationStyle {
    if let rawValue = properties["modalPresentationStyle"] as? String {
      return Navigation.ModalPresentationStyle(rawValue: rawValue) ?? .default
    }
    return .default
  }
}
```

3. Set the `modalNavigationController.modalPresentationStyle` based on the path configuration.

```swift
extension TurboTabBarController: TurboNavigationDelegate {
    func controller(_ controller: VisitableViewController, forProposal proposal: VisitProposal) -> UIViewController? {
        modalNavigationController.modalPresentationStyle = {
        switch proposal.modalPresentationStyle {
        case .fullScreen:
          return UIModalPresentationStyle.fullScreen
        case .default:
          return UIModalPresentationStyle.automatic
        }
      }()

      return controller
    }
}
```

### How to display a full-screen modal and remove the "close" button

The native modal shows a "Done" button in the top left corner. If you want to prevent the user from dismissing the modal, you can set the `isNavigationBarHidden` property on the `modalNavigationController`.

Here is an example of how you would configure this through the path configuration.

1. Add a new property to the path configuration

```json
{
  "patterns": ["/users/sign_in"],
  "properties": {
    "context": "modal",
    "modalPresentationStyle": "full_screen",
    "isModalNavigationBarHidden": true
  },
  "comment": "Present the login screen in full-screen modal that cannot be dismissed"
}
```

2. Configure access to the `modalPresentationStyle` on the `VisitProposal`:

```swift
// VisitProposalExtension.swift
import Turbo

extension VisitProposal {
  var isModalNavigationBarHidden: Bool {
    if let value = properties["isModalNavigationBarHidden"] as? Bool {
      return value
    }
    return false
  }
}
```

3. Set the `modalNavigationController.modalPresentationStyle` based on the path configuration.

```swift
extension TurboTabBarController: TurboNavigationDelegate {
    func controller(_ controller: VisitableViewController, forProposal proposal: VisitProposal) -> UIViewController? {

      modalNavigationController.isNavigationBarHidden = proposal.isModalNavigationBarHidden

      return controller
    }
}
```
