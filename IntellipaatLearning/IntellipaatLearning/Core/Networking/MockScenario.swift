import Foundation

enum MockScenario {
    case normal
    case emptyCourses
    case coursesFailure

    static var current: MockScenario {
        #if DEBUG
        let arguments = ProcessInfo.processInfo.arguments
        if arguments.contains("-mockEmptyCourses") { return .emptyCourses }
        if arguments.contains("-mockCoursesFailure") { return .coursesFailure }
        #endif
        return .normal
    }
}
