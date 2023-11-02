import SafariServices
import Turbo
import WebKit

/// Implement to be notified when certain navigations are performed
/// or to render a native controller instead of a Turbo web visit.
public protocol TurboNavigationHierarchyControllerDelegate: AnyObject {
    func visit(_ : UIViewController,
               on: TurboNavigationHierarchyController.NavigationStackType,
               with: VisitOptions)
    
    func refresh(navigationStack: TurboNavigationHierarchyController.NavigationStackType)
}
