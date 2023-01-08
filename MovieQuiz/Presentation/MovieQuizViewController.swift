import UIKit

final class MovieQuizViewController: UIViewController, AlertPresenterDelegate, MovieQuizViewControllerProtocol {
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private var background: UIView!
     
    private var presenter: MovieQuizPresenter!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        imageView.layer.borderColor = UIColor.clear.cgColor
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .ypWhite
        background.backgroundColor = .ypBlack
        checkLoadingIndicator(isAnimating: true)
        
        presenter = MovieQuizPresenter(viewController: self)
        presenter.alertPresenter?.delegate = self
    }
    
    // MARK: - Actions
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    // MARK: - AlertPresenterDelegate
    
    func showAlert(_ alert: UIAlertController) {
        checkLoadingIndicator(isAnimating: false)
        background.isHidden = false
        self.present(alert, animated: true)
    }
    
    // MARK: - Functions
    
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        background.backgroundColor = .ypBackground
        checkLoadingIndicator(isAnimating: false)
        background.isHidden = true
        checkActionButtons(isEnabled: true)
    }
    
    func checkActionButtons(isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }
    
    func checkLoadingIndicator(isAnimating: Bool) {
        if isAnimating {
            activityIndicator.startAnimating()
            background.isHidden = false
        } else {
            activityIndicator.stopAnimating()
        }
    }
    
    func highlightImageBorder(isActive: Bool, isCorrectAnswer: Bool) {
        if isActive {
            imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        } else {
            imageView.layer.borderColor = UIColor.clear.cgColor
        }
    }
}
