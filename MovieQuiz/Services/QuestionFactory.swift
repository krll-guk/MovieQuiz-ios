import Foundation

final class QuestionFactory: QuestionFactoryProtocol {
    private let moviesLoader: MoviesLoading
    weak var delegate: QuestionFactoryDelegate?
    
    init(delegate: QuestionFactoryDelegate? = nil, moviesLoader: MoviesLoading) {
        self.delegate = delegate
        self.moviesLoader = moviesLoader
    }
    
    private var movies: [MostPopularMovie] = []
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    if !mostPopularMovies.errorMessage.isEmpty {
                        self.delegate?.didFailToLoadData(with: mostPopularMovies.errorMessage)
                    }
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error.localizedDescription)
                }
            }
        }
    }
    
    private var shuffle: [MostPopularMovie] = []
    
    func reload() {
        self.shuffle = movies.shuffled()
    }
    
    func requestNextQuestion() {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            guard let self = self else { return }
            
            guard let movie = self.shuffle.popLast() else { return }
            
            var imageData = Data()
            
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.delegate?.didFailToLoadImage()
                }
                print("Failed to load image")
            }
            
            let rating = Float(movie.rating) ?? 0
            
            let randomNumber: Int = (5...9).randomElement() ?? 0
            let text = "Рейтинг этого фильма больше чем \(randomNumber)?"
            let correctAnswer = rating > Float(randomNumber)
            
            let question = QuizQuestion(image: imageData,
                                        text: text,
                                        correctAnswer: correctAnswer)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didRecieveNextQuestion(question: question)
            }
        }
    }
}
