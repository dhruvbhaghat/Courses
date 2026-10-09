import Combine
import Foundation

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published private(set) var emailError: String?
    @Published private(set) var passwordError: String?
    @Published private(set) var isFormValid = false
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let authRepository: AuthRepositoryProtocol
    private let validator: InputValidating
    private let onLogin: (Session) -> Void
    private var cancellables = Set<AnyCancellable>()

    init(
        authRepository: AuthRepositoryProtocol,
        validator: InputValidating = InputValidator(),
        onLogin: @escaping (Session) -> Void
    ) {
        self.authRepository = authRepository
        self.validator = validator
        self.onLogin = onLogin
        bind()
    }

    func login() async {
        guard !isLoading else { return }

        emailError = validator.validateEmail(email)
        passwordError = validator.validatePassword(password)
        guard emailError == nil, passwordError == nil else { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
            let session = try await authRepository.login(email: trimmedEmail, password: password)
            onLogin(session)
        } catch is CancellationError {
            return
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func bind() {
        Publishers.CombineLatest($email, $password)
            .map { [validator] email, password in
                validator.validateEmail(email) == nil && validator.validatePassword(password) == nil
            }
            .removeDuplicates()
            .assign(to: &$isFormValid)

        $email
            .dropFirst()
            .debounce(for: .milliseconds(400), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .map { [validator] in validator.validateEmail($0) }
            .assign(to: &$emailError)

        $password
            .dropFirst()
            .debounce(for: .milliseconds(400), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .map { [validator] in validator.validatePassword($0) }
            .assign(to: &$passwordError)

        Publishers.Merge($email, $password)
            .dropFirst(2)
            .sink { [weak self] _ in
                self?.errorMessage = nil
            }
            .store(in: &cancellables)
    }
}
