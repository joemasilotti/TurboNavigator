import Strada
import UIKit

final class FormComponent: BridgeComponent {
    override class var name: String { "form" }

    override func onReceive(message: Message) {
        if message.event == "connect" {
            addSubmitButton(message: message)
        }
    }

    private var viewController: UIViewController? {
        delegate.destination as? UIViewController
    }

    private func addSubmitButton(message: Message) {
        guard let data: MessageData = message.data(), let viewController else { return }

        let action = UIAction(title: data.title) { _ in
            self.reply(to: "connect")
        }

        viewController.navigationItem.rightBarButtonItem = UIBarButtonItem(primaryAction: action)
    }
}

private extension FormComponent {
    struct MessageData: Decodable {
        let title: String
    }
}
