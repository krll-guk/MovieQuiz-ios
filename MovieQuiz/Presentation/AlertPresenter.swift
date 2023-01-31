import UIKit

protocol AlertPresenterDelegate: AnyObject {
    func showAlert(_ alert: UIAlertController)
}

final class AlertPresenter {
    weak var delegate: AlertPresenterDelegate?
    
    func show(model: AlertModel, identifier: String) {
        let alert = UIAlertController(title: model.title,
                                      message: model.message,
                                      preferredStyle: .alert)
        
        alert.view.accessibilityIdentifier = identifier
        
        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in model.completion() }
        
        alert.addAction(action)
        delegate?.showAlert(alert)
    }
}
