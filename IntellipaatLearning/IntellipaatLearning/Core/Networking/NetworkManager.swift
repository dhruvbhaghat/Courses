import Foundation
import OSLog

protocol NetworkManaging {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
}

final class NetworkManager: NetworkManaging {
    private let connectivity: ConnectivityMonitoring
    private let scenario: MockScenario
    private let latency: Duration
    private let decoder = JSONDecoder()

    init(
        connectivity: ConnectivityMonitoring,
        scenario: MockScenario = .current,
        latency: Duration = .milliseconds(600)
    ) {
        self.connectivity = connectivity
        self.scenario = scenario
        self.latency = latency
    }

    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        AppLogger.network.debug("\(endpoint.method.rawValue, privacy: .public) \(endpoint.path, privacy: .public)")

        guard connectivity.isConnected else { throw NetworkError.noConnection }
        try await Task.sleep(for: latency)

        switch endpoint {
        case .login(let credentials):
            guard
                credentials.email.lowercased() == MockServer.email,
                credentials.password == MockServer.password
            else { throw NetworkError.invalidCredentials }
            return try decode(MockJSON.login, as: LoginResponse.self)

        case .courses:
            switch scenario {
            case .normal:
                return try decode(MockJSON.courses, as: [Course].self)
            case .emptyCourses:
                return try decode(MockJSON.emptyCourses, as: [Course].self)
            case .coursesFailure:
                throw NetworkError.serverFailure
            }

        case .lessons(let courseId):
            guard let json = MockJSON.lessons(courseId: courseId) else { throw NetworkError.notFound }
            return try decode(json, as: [Lesson].self)

        case .completeLesson:
            return try decode(MockJSON.completion, as: CompletionResponse.self)
        }
    }

    private func decode<Model: Decodable, T>(_ json: String, as model: Model.Type) throws -> T {
        let decoded: Model
        do {
            decoded = try decoder.decode(Model.self, from: Data(json.utf8))
        } catch {
            AppLogger.network.error("Decoding \(String(describing: Model.self), privacy: .public) failed: \(error.localizedDescription, privacy: .public)")
            throw NetworkError.decoding
        }
        guard let result = decoded as? T else { throw NetworkError.typeMismatch }
        return result
    }
}
