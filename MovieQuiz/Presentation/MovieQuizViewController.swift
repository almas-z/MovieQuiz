import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    private weak var viewController: MovieQuizViewControllerProtocol?
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
        presenter = MovieQuizPresenter(viewController: self)
        
        showLoadingIndicator()
        imageView.layer.cornerRadius = 20
    }
    // MARK: - UI Update Methods
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.layer.borderColor = UIColor.clear.cgColor
        setButtonsEnabled(true)
    }
    
    func show(quiz result: QuizResultsViewModel) {
        let message = presenter.makeResultsMessage()
        
        let alert = UIAlertController(title: result.title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
            self?.presenter.restartGame()
        }
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    func setButtonsEnabled(_ isEnabled: Bool) {
        noButton.isEnabled = isEnabled
        yesButton.isEnabled = isEnabled
    }
    
    // MARK: - Network & Loading Methods
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Попробовать ещё раз", style: .default) { [weak self] _ in
            self?.presenter.restartGame()
        }
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    // MARK: - IBActions
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.proceedWithAnswer(isCorrect: false)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.proceedWithAnswer(isCorrect: true)
    }
}
