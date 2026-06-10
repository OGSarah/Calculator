//
//  AccessibilityUITests.swift
//  CalculatorUITests
//
//  Created by Sarah Clark on 6/9/26.
//

import XCTest

/// UI tests covering VoiceOver labelling and Dynamic Type support.
final class AccessibilityUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        // Stop immediately when a UI failure occurs.
        continueAfterFailure = false
        // The calculator is designed for a portrait layout; pin the
        // orientation so the keypad fits on screen regardless of the
        // simulator's current state. `XCUIDevice.shared` is main actor-isolated;
        // UI test setup runs on the main thread, so assume that isolation here.
        // Each test launches the app itself so Dynamic Type tests can supply
        // their own launch arguments.
        app = MainActor.assumeIsolated {
            XCUIDevice.shared.orientation = .portrait
            return XCUIApplication()
        }
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - VoiceOver

    /// Operator and clear buttons should be announced with human-readable
    /// names instead of their raw symbols (e.g. "Divide", not "÷").
    @MainActor
    func testOperatorButtonsHaveHumanReadableLabels() throws {
        app.launch()

        let expectedLabels: [String: String] = [
            "+": "Plus",
            "−": "Minus",
            "×": "Multiply",
            "÷": "Divide",
            "=": "Equals",
            "AC": "All clear"
        ]

        for (identifier, expectedLabel) in expectedLabels {
            let button = app.buttons[identifier]
            XCTAssertTrue(button.waitForExistence(timeout: 5), "Missing button for \(identifier)")
            XCTAssertEqual(
                button.label,
                expectedLabel,
                "VoiceOver should announce \"\(expectedLabel)\" for the \(identifier) button"
            )
        }
    }

    /// Every digit button must be reachable via the assistive technology tree.
    @MainActor
    func testDigitButtonsAreReachable() throws {
        app.launch()

        for digit in 0...9 {
            let button = app.buttons["\(digit)"]
            XCTAssertTrue(button.waitForExistence(timeout: 5), "Missing digit button \(digit)")
        }
    }

    /// The display should expose a descriptive "Result" label so VoiceOver
    /// announces "Result, 0" rather than a bare number.
    @MainActor
    func testDisplayExposesResultLabel() throws {
        app.launch()

        let display = app.staticTexts["0"]
        XCTAssertTrue(display.waitForExistence(timeout: 5))
        XCTAssertEqual(display.label, "Result", "Display should be announced as the result")
    }

    /// The session button should carry a non-empty accessible label.
    @MainActor
    func testSessionButtonIsAccessible() throws {
        app.launch()

        let sessionButton = app.buttons["View Session Data"]
        XCTAssertTrue(sessionButton.waitForExistence(timeout: 5))
        XCTAssertFalse(sessionButton.label.isEmpty)
    }

    // MARK: - Dynamic Type

    /// At an accessibility text size the core controls must still be present
    /// and hittable — i.e. the keypad must not overflow off-screen.
    @MainActor
    func testInterfaceRemainsUsableAtAccessibilityTextSizes() throws {
        app.launchArguments += [
            "-UIPreferredContentSizeCategoryName",
            "UICTContentSizeCategoryAccessibilityExtraExtraExtraLarge"
        ]
        app.launch()

        XCTAssertTrue(app.staticTexts["0"].waitForExistence(timeout: 5))

        let seven = app.buttons["7"]
        XCTAssertTrue(seven.waitForExistence(timeout: 5))
        XCTAssertTrue(seven.isHittable, "Digit buttons must stay on screen at large text sizes")
        XCTAssertTrue(app.buttons["="].isHittable, "Equals button must stay on screen at large text sizes")
    }

    /// A full calculation should still succeed when the largest accessibility
    /// text size is active.
    @MainActor
    func testCalculationWorksAtAccessibilityTextSizes() throws {
        app.launchArguments += [
            "-UIPreferredContentSizeCategoryName",
            "UICTContentSizeCategoryAccessibilityExtraExtraExtraLarge"
        ]
        app.launch()

        app.buttons["7"].tap()
        app.buttons["+"].tap()
        app.buttons["8"].tap()
        app.buttons["="].tap()

        XCTAssertTrue(app.staticTexts["15"].waitForExistence(timeout: 5))
    }
}
