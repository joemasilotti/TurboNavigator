import Turbo
import UIKit

public extension VisitProposal {
    var context: Navigation.Context {
        if let rawValue = properties["context"] as? String {
            return Navigation.Context(rawValue: rawValue) ?? .default
        }
        return .default
    }

    var presentation: Navigation.Presentation {
        if let rawValue = properties["presentation"] as? String {
            return Navigation.Presentation(rawValue: rawValue) ?? .default
        }
        return .default
    }
}
