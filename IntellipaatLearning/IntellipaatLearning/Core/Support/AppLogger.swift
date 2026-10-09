import Foundation
import OSLog

enum AppLogger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "LearningDashboard"

    static let network = Logger(subsystem: subsystem, category: "network")
    static let repository = Logger(subsystem: subsystem, category: "repository")
}
