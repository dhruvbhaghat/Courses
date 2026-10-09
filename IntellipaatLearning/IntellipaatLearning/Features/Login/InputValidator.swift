import Foundation

protocol InputValidating {
    func validateEmail(_ email: String) -> String?
    func validatePassword(_ password: String) -> String?
}

struct InputValidator: InputValidating {
    private let emailPattern = #"^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$"#
    private let minimumPasswordLength = 8

    func validateEmail(_ email: String) -> String? {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "Email is required." }
        guard trimmed.range(of: emailPattern, options: .regularExpression) != nil else {
            return "Enter a valid email address."
        }
        return nil
    }

    func validatePassword(_ password: String) -> String? {
        guard !password.isEmpty else { return "Password is required." }
        guard password.count >= minimumPasswordLength else {
            return "Password must be at least \(minimumPasswordLength) characters."
        }
        return nil
    }
}
