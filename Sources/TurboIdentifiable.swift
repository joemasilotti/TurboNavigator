import UIKit

/// A covenient way to identify view controllers.
public protocol TurboIdentifiable : UIViewController {
    static var viewControllerPathConfigIdentifier: String { get }
}
