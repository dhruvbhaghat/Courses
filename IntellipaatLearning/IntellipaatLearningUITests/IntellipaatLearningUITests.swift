//
//  IntellipaatLearningUITests.swift
//  IntellipaatLearningUITests
//
//  Created by Dhruv Bhaghat on 09/10/26.
//

import XCTest

final class IntellipaatLearningUITests: XCTestCase {

    override func setUpWithError() throws {

        continueAfterFailure = false

        
    }

    override func tearDownWithError() throws {
       
    }

    @MainActor
    func testExample() throws {
       
        let app = XCUIApplication()
        app.launch()

    }

    @MainActor
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
           
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
