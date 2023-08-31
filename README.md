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
    "/edit$"
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
    "presentation": "refresh"
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
