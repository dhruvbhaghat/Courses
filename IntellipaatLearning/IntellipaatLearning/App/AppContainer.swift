import Foundation

final class AppContainer {
    private let authRepository: AuthRepositoryProtocol
    private let courseRepository: CourseRepositoryProtocol

    init(scenario: MockScenario = .current) {
        let connectivity = ConnectivityMonitor()
        let network = NetworkManager(connectivity: connectivity, scenario: scenario)
        authRepository = AuthRepository(network: network, sessionStore: KeychainSessionStore())
        courseRepository = CourseRepository(network: network, store: FileCourseStore())
    }

    @MainActor
    func makeAppViewModel() -> AppViewModel {
        AppViewModel(authRepository: authRepository, courseRepository: courseRepository)
    }

    @MainActor
    func makeLoginViewModel(onLogin: @escaping (Session) -> Void) -> LoginViewModel {
        LoginViewModel(authRepository: authRepository, onLogin: onLogin)
    }

    @MainActor
    func makeDashboardViewModel() -> CourseDashboardViewModel {
        CourseDashboardViewModel(repository: courseRepository)
    }
}
