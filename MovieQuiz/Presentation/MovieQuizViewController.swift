import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private var background: UIView!
    
    private var currentQuestionIndex: Int = 0
    private var correctAnswer: Int = 0
    private let questionsAmount: Int = 10
    
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenter?
    private var statisticService: StatisticService?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .ypWhite
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        imageView.layer.borderColor = UIColor.clear.cgColor
        
        questionFactory = QuestionFactory(delegate: self, moviesLoader: MoviesLoader())
        
        alertPresenter = AlertPresenter()
        alertPresenter?.delegate = self
        
        statisticService = StatisticServiceImplementation()
        
        background.isHidden = false
        activityIndicator.startAnimating()
        questionFactory?.loadData()
    }
    
    // MARK: - Actions
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else { return }
        
        let givenAnswer = true
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else { return }
        
        let givenAnswer = false
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.show(quiz: viewModel)
            self.yesButton.isEnabled = true
            self.noButton.isEnabled = true
        }
    }
    
    func didLoadDataFromServer() {
        questionFactory?.reload()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with message: String) {
        showNetworkError(message: message)
    }
    
    func didFailToLoadImage() {
        showImageLoadError()
    }
    
    // MARK: - AlertPresenterDelegate
    
    func showAlert(_ alert: UIAlertController) {
        activityIndicator.stopAnimating()
        background.isHidden = false
        self.present(alert, animated: true)
    }
    
    // MARK: - Private functions
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        activityIndicator.stopAnimating()
        background.isHidden = true
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswer += 1
        }
        
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        yesButton.isEnabled = false
        noButton.isEnabled = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.imageView.layer.borderColor = UIColor.clear.cgColor
            self.background.isHidden = false
            self.activityIndicator.startAnimating()
            self.showNextQuestionOrResult()
        }
    }
    
    private func showNextQuestionOrResult() {
        if currentQuestionIndex == questionsAmount - 1 {
            
            guard let statisticService = statisticService else { return }
            statisticService.store(correct: correctAnswer, total: questionsAmount)
            
            let message = """
            Ваш результат: \(correctAnswer)/\(questionsAmount)
            Количество сыгранных квизов: \(statisticService.gamesCount)
            Рекорд: \(statisticService.bestGame)
            Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
            """
            
            let model = AlertModel(title: "Этот раунд окончен!",
                                   message: message,
                                   buttonText: "Сыграть еще раз") { [weak self] in
                guard let self = self else { return }
                
                self.activityIndicator.startAnimating()
                self.currentQuestionIndex = 0
                self.correctAnswer = 0
                self.questionFactory?.reload()
                self.questionFactory?.requestNextQuestion()
            }
            
            alertPresenter?.show(model: model)
            
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func showNetworkError(message: String) {
        
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            
            self.activityIndicator.startAnimating()
            self.questionFactory?.loadData()
        }
        
        alertPresenter?.show(model: model)
    }
    
    private func showImageLoadError() {
        
        let model = AlertModel(title: "Ошибка",
                               message: "Failed to load image",
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            
            self.activityIndicator.startAnimating()
            self.questionFactory?.requestNextQuestion()
        }
        
        alertPresenter?.show(model: model)
    }
}
