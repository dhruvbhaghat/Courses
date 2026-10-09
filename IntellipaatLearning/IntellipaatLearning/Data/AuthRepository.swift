import Foundation

protocol AuthRepositoryProtocol {
    func login(email: String, password: String) async throws -> Session
    func restoreSession() -> Session?
    func logout()
}

final class AuthRepository: AuthRepositoryProtocol {
    private let network: NetworkManaging
    private let sessionStore: SessionStoring

    init(network: NetworkManaging, sessionStore: SessionStoring) {
        self.network = network
        self.sessionStore = sessionStore
    }

    func login(email: String, password: String) async throws -> Session {
        let credentials = LoginCredentials(email: email, password: password)
        let response: LoginResponse = try await network.request(.login(credentials))
        let session = Session(token: response.token, name: response.user.name, email: response.user.email)
        try sessionStore.save(session)
        return session
    }

    func restoreSession() -> Session? {
        sessionStore.load()
    }

    func logout() {
        sessionStore.clear()
    }
}
