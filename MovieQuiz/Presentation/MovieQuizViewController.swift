import UIKit

//MARK: - MovieQuizViewController
final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    //MARK: - Services
    private var statisticService: StatisticServiceProtocol!
    private var questionFactory: QuestionFactoryProtocol?
    private var alertPresenter: AlertPresenter?
    private var presenter: MovieQuizPresenter!
    
    //MARK: - IBOutlets
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var imageView: UIImageView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        statisticService = StatisticServiceImplementation()
        
        presenter = MovieQuizPresenter()
        presenter.viewController = self
        
        let questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory.loadData()
        self.questionFactory = questionFactory
        presenter.questionFactory = questionFactory
        
        showLoadingIndicator()
        imageView.layer.cornerRadius = 20
        alertPresenter = AlertPresenter(viewController: self)
        showFirstQuestion()
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        presenter.didReceiveNextQuestion(question: question)
    }
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    // MARK: - UI Update Methods
    private func showFirstQuestion() {
        setButtonsEnabled(true)
        questionFactory?.requestNextQuestion()
    }
    func showAlert(model: AlertModel) {
        alertPresenter?.showAlert(model: model)
    }
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.layer.borderColor = UIColor.clear.cgColor
        
        setButtonsEnabled(true)
    }
    
    func show(quiz result: QuizResultsViewModel) {
        let message = """
                                Ваш результат: \(result.text)
                                Рекорд: \(statisticService.bestGame.correct) из \(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))
                                Количество сыгранных квизов: \(statisticService.gamesCount)
                                Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
                                """
        
        let alertModel = AlertModel(
            title: result.title,
            message: message,
            buttonText: result.buttonText,
            completion: { [weak self] in
                self?.restartGame()
            }
        )
        
        alertPresenter?.showAlert(model: alertModel)
    }
    
    private func setButtonsEnabled(_ isEnabled: Bool) {
        noButton.isEnabled = isEnabled
        yesButton.isEnabled = isEnabled
    }
    
    // MARK: - Loading Indicator
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз"
        ) { [weak self] in
            guard let self = self else { return }
            self.presenter.resetQuestionIndex()
            self.questionFactory?.requestNextQuestion()
        }
        
        alertPresenter?.showAlert(model: model)
    }
    
    // MARK: - Game Logic
    func showAnswerResult(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        setButtonsEnabled(false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.presenter.questionFactory = self.questionFactory
            self.presenter.showNextQuestionOrResults()
        }
    }
    
    private func restartGame() {
        setButtonsEnabled(true)
        presenter.correctAnswers = 0
        presenter.resetQuestionIndex()
        questionFactory?.requestNextQuestion()
    }
    
    // MARK: - IBActions
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
}
