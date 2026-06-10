//
//  CalculatorUITests.swift
//  CalculatorUITests
//
//  Created by Sarah Clark on 2/26/25.
//

import XCTest

final class CalculatorUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        // Stop immediately when a UI failure occurs.
        continueAfterFailure = false
        // XCTest runs setUp on the main thread, so it's safe to assume main-actor
        // isolation for the main actor-isolated XCUIApplication APIs.
        app = MainActor.assumeIsolated {
            let app = XCUIApplication()
            app.launch()
            return app
        }
    }

    override func tearDownWithError() throws {
        app = nil
    }

    @MainActor
    func testInitialDisplayShowsZero() throws {
        XCTAssertTrue(app.staticTexts["0"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testAddition() throws {
        app.buttons["7"].tap()
        app.buttons["+"].tap()
        app.buttons["8"].tap()
        app.buttons["="].tap()
        XCTAssertTrue(app.staticTexts["15"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testSubtraction() throws {
        app.buttons["9"].tap()
        app.buttons["−"].tap()
        app.buttons["4"].tap()
        app.buttons["="].tap()
        XCTAssertTrue(app.staticTexts["5"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testMultiplication() throws {
        app.buttons["6"].tap()
        app.buttons["×"].tap()
        app.buttons["7"].tap()
        app.buttons["="].tap()
        XCTAssertTrue(app.staticTexts["42"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testDivision() throws {
        app.buttons["8"].tap()
        app.buttons["÷"].tap()
        app.buttons["2"].tap()
        app.buttons["="].tap()
        XCTAssertTrue(app.staticTexts["4"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testClearResetsDisplay() throws {
        app.buttons["5"].tap()
        app.buttons["AC"].tap()
        XCTAssertTrue(app.staticTexts["0"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testSessionHistorySheetOpensAndCloses() throws {
        app.buttons["View Session Data"].tap()
        XCTAssertTrue(app.navigationBars["Calculator Session History"].waitForExistence(timeout: 5))
        app.buttons["Done"].tap()
        XCTAssertTrue(app.buttons["View Session Data"].waitForExistence(timeout: 5))
    }
}
