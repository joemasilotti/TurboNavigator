import UIKit

/// A covenient way to identify view controllers.
public protocol PathConfigurationIdentifiable : UIViewController {
    static var pathConfigurationIdentifier: String { get }
}
