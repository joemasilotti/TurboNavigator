import UIKit

/// Manipulate a navigation controller under test.
/// Ensures `viewControllers` is updated synchronously.
/// Use `dismissWasCalled` instead of checking if `presentedViewController` is nil.
class TestableNavigationController: UINavigationController {
    /// Use instead of checking if `presentedViewController` is nil.
    private(set) var dismissWasCalled = false

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: false)
    }

    override func popViewController(animated: Bool) -> UIViewController? {
        super.popViewController(animated: false)
    }

    override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        super.popToRootViewController(animated: false)
    }

    override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        super.setViewControllers(viewControllers, animated: false)
    }

    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        super.present(viewControllerToPresent, animated: false, completion: completion)
    }

    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        // Even dismissing without animation doesn't correctly set presentedViewController to nil.
        dismissWasCalled = true
        super.dismiss(animated: false, completion: completion)
    }
}
