//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Kirill Guk on 7/12/22.
//

import UIKit

protocol ViewInput: AnyObject {
    func showAlert(_ alert: UIAlertController)
    func didTapActionButton()
}

final class AlertPresenter {
    weak var alertController: ViewInput?
    
    func didFinishGame(result: AlertModel) {
        let alert = UIAlertController(title: result.title,
                                      message: result.message,
                                      preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.alertController?.didTapActionButton()
        }
        
        alert.addAction(action)
        alertController?.showAlert(alert)
    }
}
