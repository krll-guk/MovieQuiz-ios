import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    private weak var viewController: MovieQuizViewControllerProtocol?
    private var questionFactory: QuestionFactoryProtocol?
    private var statisticService: StatisticService?
    private var currentQuestion: QuizQuestion?
    var alertPresenter: AlertPresenter?
    
    private let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0

    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        
        alertPresenter = AlertPresenter()
        statisticService = StatisticServiceImplementation()
        
        questionFactory = QuestionFactory(delegate: self, moviesLoader: MoviesLoader())
        questionFactory?.loadData()
    }
    
    // MARK: - QuestionFactoryDelegate
    
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
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.viewController?.show(quiz: viewModel)
        }
    }
    
    // MARK: - ButtonClicked
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        
        let givenAnswer = isYes
        
        proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    // MARK: - Private functions
    
    private func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    private func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        viewController?.checkLoadingIndicator(isAnimating: true)
        questionFactory?.reload()
        questionFactory?.requestNextQuestion()
    }
    
    private func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    
    private func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            correctAnswers += 1
        }
    }
    
    private func proceedWithAnswer(isCorrect: Bool) {
        didAnswer(isCorrectAnswer: isCorrect)
        
        viewController?.highlightImageBorder(isActive: true, isCorrectAnswer: isCorrect)
        viewController?.checkActionButtons(isEnabled: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.viewController?.highlightImageBorder(isActive: false, isCorrectAnswer: isCorrect)
            self.viewController?.checkLoadingIndicator(isAnimating: true)
            self.proceedToNextQuestionOrResult()
        }
    }
    
    // MARK: - Alerts
    
    private func proceedToNextQuestionOrResult() {
        if isLastQuestion() {
            guard let statisticService = statisticService else { return }
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            
            let message = """
            Ваш результат: \(correctAnswers)/\(questionsAmount)
            Количество сыгранных квизов: \(statisticService.gamesCount)
            Рекорд: \(statisticService.bestGame)
            Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
            """
            
            let model = AlertModel(title: "Этот раунд окончен!",
                                   message: message,
                                   buttonText: "Сыграть еще раз") { [weak self] in
                guard let self = self else { return }
                
                self.restartGame()
            }
            
            alertPresenter?.show(model: model, identifier: "Game result")
            
        } else {
            switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func showNetworkError(message: String) {
        let model = AlertModel(title: "Что-то пошло не так(",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            
            self.viewController?.checkLoadingIndicator(isAnimating: true)
            self.questionFactory?.loadData()
        }
        
        alertPresenter?.show(model: model, identifier: "Network error")
    }
    
    private func showImageLoadError() {
        let model = AlertModel(title: "Что-то пошло не так(",
                               message: "Failed to load image",
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            
            self.viewController?.checkLoadingIndicator(isAnimating: true)
            self.questionFactory?.requestNextQuestion()
        }
        
        alertPresenter?.show(model: model, identifier: "Image load error")
    }
}
