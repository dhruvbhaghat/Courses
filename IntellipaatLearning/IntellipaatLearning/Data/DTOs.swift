import Foundation

struct LoginResponse: Decodable {
    let token: String
    let user: UserDTO
}

struct UserDTO: Decodable {
    let id: Int
    let name: String
    let email: String
}

struct CompletionResponse: Decodable {
    let success: Bool
}
