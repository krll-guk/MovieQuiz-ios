import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func checkActionButtons(isEnabled: Bool)
    func checkLoadingIndicator(isAnimating: Bool)
    func highlightImageBorder(isActive: Bool, isCorrectAnswer: Bool)
}
