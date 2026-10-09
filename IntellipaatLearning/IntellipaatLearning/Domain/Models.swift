import Foundation

struct Course: Codable, Identifiable, Hashable {
    let id: Int
    let title: String
    let instructor: String
    var progress: Int
    let lessons: Int
}

struct Lesson: Codable, Identifiable, Hashable {
    let id: Int
    let title: String
    var isCompleted: Bool
}

struct Session: Codable, Equatable {
    let token: String
    let name: String
    let email: String
}

enum DataSource: Equatable {
    case network
    case cache
}

struct CoursesResult: Equatable {
    let courses: [Course]
    let source: DataSource
}

struct LessonsSnapshot: Equatable {
    let lessons: [Lesson]
    let progress: Int
}
