//
//  LetsStretchUITests.swift
//  LetsStretchUITests
//

import XCTest

class LetsStretchUITests: XCTestCase {
    let app = XCUIApplication()
    let outDir = URL(fileURLWithPath: "/tmp/asc-captures/letsstretch")

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        try? FileManager.default.createDirectory(at: outDir, withIntermediateDirectories: true)
        app.launch()
    }

    func testCaptureAppStoreScreens() {
        // Home
        Thread.sleep(forTimeInterval: 2.0)
        save("01-home")

        // Open a routine — prefer Full Body / Morning / Back
        let preferred = ["Full Body", "Morning Stretches", "Back Stretches", "Leg Stretches", "Desk Reset"]
        var opened = false
        for name in preferred {
            let row = app.staticTexts[name].firstMatch
            if row.waitForExistence(timeout: 3) {
                row.tap()
                opened = true
                break
            }
        }
        if !opened {
            // First table/cell fallback
            let cell = app.cells.firstMatch
            if cell.waitForExistence(timeout: 5) {
                cell.tap()
            } else {
                app.otherElements.containing(.staticText, identifier: "Back Stretches").element.tap()
            }
        }

        Thread.sleep(forTimeInterval: 3.5)
        save("02-stretch")

        // Wait a bit for illustration / timer UI
        Thread.sleep(forTimeInterval: 2.0)
        save("03-stretch-active")

        // Back to home
        if app.navigationBars.buttons.firstMatch.exists {
            app.navigationBars.buttons.firstMatch.tap()
            Thread.sleep(forTimeInterval: 1.2)
        }

        // Settings gear
        let settings = app.buttons["Settings"].firstMatch
        let gear = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'setting' OR label CONTAINS[c] 'gear'")).firstMatch
        if settings.waitForExistence(timeout: 3) {
            settings.tap()
        } else if gear.waitForExistence(timeout: 2) {
            gear.tap()
        } else {
            // Top-right gear often accessibility-labeled as button without text — tap via coordinate near top-right of home
            let home = app
            // Try navigation bar buttons
            let navButtons = home.navigationBars.buttons
            if navButtons.count > 0 {
                navButtons.element(boundBy: navButtons.count - 1).tap()
            }
        }
        Thread.sleep(forTimeInterval: 1.5)
        save("04-settings")

        // Another routine for variety if still on home
        if app.staticTexts["Calf & Achilles"].waitForExistence(timeout: 2) {
            app.staticTexts["Calf & Achilles"].tap()
            Thread.sleep(forTimeInterval: 3.0)
            save("05-stretch-calf")
        }
    }

    private func save(_ name: String) {
        let shot = XCUIScreen.main.screenshot()
        let path = outDir.appendingPathComponent("\(name).png")
        do {
            try shot.pngRepresentation.write(to: path)
            print("📸 wrote \(path.path)")
        } catch {
            XCTFail("Failed to write \(name): \(error)")
        }
    }
}
