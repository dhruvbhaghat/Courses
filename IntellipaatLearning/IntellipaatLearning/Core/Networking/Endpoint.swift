import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

struct LoginCredentials: Equatable {
    let email: String
    let password: String
}

enum Endpoint {
    case login(LoginCredentials)
    case courses
    case lessons(courseId: Int)
    case completeLesson(courseId: Int, lessonId: Int)

    var method: HTTPMethod {
        switch self {
        case .login, .completeLesson:
            return .post
        case .courses, .lessons:
            return .get
        }
    }

    var path: String {
        switch self {
        case .login:
            return "/auth/login"
        case .courses:
            return "/courses"
        case .lessons(let courseId):
            return "/courses/\(courseId)/lessons"
        case .completeLesson(let courseId, let lessonId):
            return "/courses/\(courseId)/lessons/\(lessonId)/complete"
        }
    }
}
