import Foundation

enum NetworkError: LocalizedError, Equatable {
    case noConnection
    case invalidCredentials
    case serverFailure
    case notFound
    case decoding
    case typeMismatch

    var errorDescription: String? {
        switch self {
        case .noConnection:
            return "You appear to be offline. Check your connection and try again."
        case .invalidCredentials:
            return "Incorrect email or password."
        case .serverFailure:
            return "The server is having trouble right now. Please try again later."
        case .notFound:
            return "The requested resource could not be found."
        case .decoding:
            return "We couldn't read the server response."
        case .typeMismatch:
            return "The server returned an unexpected response."
        }
    }
}
