import XCTest

class MovieQuizUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app.terminate()
        app = nil
    }
    
    func testYesButton() {
        let firstPoster = app.images["Poster"]
        
        app.buttons["Yes"].tap()
        
        let secondPoster = app.images["Poster"]
        
        XCTAssertFalse(firstPoster == secondPoster)
    }
    
    func testNoButton() {
        let firstPoster = app.images["Poster"]
        XCTAssertTrue(firstPoster.waitForExistence(timeout: 3))
        
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        app.buttons["No"].tap()
        
        XCTAssertTrue(firstPoster.waitForExistence(timeout: 3))
        let secondPosterData = firstPoster.screenshot().pngRepresentation
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
    }
    
    func testGameFinish() {
        for _ in 1...10 {
            app.buttons["Yes"].tap()
            _ = app.alerts.firstMatch.waitForExistence(timeout: 3)
        }
        
        let alert = app.alerts.firstMatch
        XCTAssertTrue(alert.waitForExistence(timeout: 5))
        XCTAssertEqual(alert.label, "Этот раунд окончен!")
        XCTAssertTrue(alert.buttons["Сыграть ещё раз"].exists)
    }
    
    func testAlertDismiss() {
        for _ in 1...10 {
            app.buttons["No"].tap()
            _ = app.alerts.firstMatch.waitForExistence(timeout: 3)
        }
        
        let alert = app.alerts.firstMatch
        XCTAssertTrue(alert.waitForExistence(timeout: 5))
        
        alert.buttons["Сыграть ещё раз"].tap()
        XCTAssertFalse(alert.waitForExistence(timeout: 3))
        
        XCTAssertEqual(app.staticTexts["Index"].label, "1/10")
    }
}
