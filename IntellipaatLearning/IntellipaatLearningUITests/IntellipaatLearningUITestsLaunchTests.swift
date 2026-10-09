//
//  IntellipaatLearningUITestsLaunchTests.swift
//  IntellipaatLearningUITests
//
//  Created by Dhruv Bhaghat on 09/10/26.
//

import XCTest

final class IntellipaatLearningUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()



        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
