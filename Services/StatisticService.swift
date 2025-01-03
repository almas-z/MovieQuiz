import Foundation

final class StatisticServiceImplementation: StatisticServiceProtocol {
    private let storage: UserDefaults = .standard

    private enum Keys: String {
        case correctAnswers
        case totalQuestions
        case gamesCount
        case bestGame
    }

    var gamesCount: Int {
        get {
            return storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }

    var totalAccuracy: Double {
        let correctAnswers = storage.integer(forKey: Keys.correctAnswers.rawValue)
        let totalQuestions = storage.integer(forKey: Keys.totalQuestions.rawValue)
        guard totalQuestions > 0 else { return 0.0 }
        return (Double(correctAnswers) / Double(totalQuestions)) * 100.0
    }

    var bestGame: GameResult {
        get {
            let correct = storage.integer(forKey: "\(Keys.bestGame.rawValue).correct")
            let total = storage.integer(forKey: "\(Keys.bestGame.rawValue).total")
            let date = storage.object(forKey: "\(Keys.bestGame.rawValue).date") as? Date ?? Date()
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            storage.set(newValue.correct, forKey: "\(Keys.bestGame.rawValue).correct")
            storage.set(newValue.total, forKey: "\(Keys.bestGame.rawValue).total")
            storage.set(newValue.date, forKey: "\(Keys.bestGame.rawValue).date") //
        }
    }

    func store(correct count: Int, total amount: Int) {
        let currentCorrectAnswers = storage.integer(forKey: Keys.correctAnswers.rawValue)
        storage.set(currentCorrectAnswers + count, forKey: Keys.correctAnswers.rawValue)
        
        let currentTotalQuestions = storage.integer(forKey: Keys.totalQuestions.rawValue)
        storage.set(currentTotalQuestions + amount, forKey: Keys.totalQuestions.rawValue)
        
        gamesCount += 1
        
        let newGameResult = GameResult(correct: count, total: amount, date: Date())
        if newGameResult.isBetterThan(bestGame) {
            bestGame = newGameResult
        }
    }
}
