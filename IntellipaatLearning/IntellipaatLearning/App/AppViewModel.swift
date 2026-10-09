import Combine
import Foundation

@MainActor
final class AppViewModel: ObservableObject {
    @Published private(set) var session: Session?

    private let authRepository: AuthRepositoryProtocol
    private let courseRepository: CourseRepositoryProtocol

    init(authRepository: AuthRepositoryProtocol, courseRepository: CourseRepositoryProtocol) {
        self.authRepository = authRepository
        self.courseRepository = courseRepository
        self.session = authRepository.restoreSession()
    }

    func didLogin(_ session: Session) {
        self.session = session
    }

    func logout() async {
        authRepository.logout()
        await courseRepository.clearLocalData()
        session = nil
    }
}
