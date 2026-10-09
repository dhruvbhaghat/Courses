//
//  IntellipaatLearningApp.swift
//  IntellipaatLearning
//
//  Created by Dhruv Bhaghat on 09/10/26.
//

import SwiftUI

@main
struct IntellipaatLearningApp: App {
    private let container = AppContainer()

    var body: some Scene {
        WindowGroup {
            RootView(container: container)
        }
    }
}
