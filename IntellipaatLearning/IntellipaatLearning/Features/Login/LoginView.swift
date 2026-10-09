import SwiftUI

@MainActor
struct LoginView: View {
    @StateObject private var viewModel: LoginViewModel
    @FocusState private var focusedField: Field?

    private enum Field {
        case email
        case password
    }

    init(viewModel: @autoclosure @escaping () -> LoginViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                header
                VStack(spacing: 16) {
                    emailField
                    passwordField
                }
                if let message = viewModel.errorMessage {
                    errorBanner(message)
                }
                loginButton
                Text("Demo: \(MockServer.email) / \(MockServer.password)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding(24)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private var header: some View {
        VStack(spacing: 8) {
            Image(systemName: "graduationcap.fill")
                .font(.system(size: 48))
                .foregroundStyle(.tint)
            Text("Learning Dashboard")
                .font(.title.bold())
            Text("Sign in to continue")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 48)
    }

    private var emailField: some View {
        FormField(title: "Email", error: viewModel.emailError) {
            TextField("you@example.com", text: $viewModel.email)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.next)
                .focused($focusedField, equals: .email)
                .onSubmit { focusedField = .password }
        }
    }

    private var passwordField: some View {
        FormField(title: "Password", error: viewModel.passwordError) {
            SecureField("At least 8 characters", text: $viewModel.password)
                .textContentType(.password)
                .submitLabel(.go)
                .focused($focusedField, equals: .password)
                .onSubmit { submit() }
        }
    }

    private var loginButton: some View {
        Button(action: submit) {
            ZStack {
                Text("Log In")
                    .opacity(viewModel.isLoading ? 0 : 1)
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 22)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .disabled(!viewModel.isFormValid || viewModel.isLoading)
    }

    private func errorBanner(_ message: String) -> some View {
        Label(message, systemImage: "exclamationmark.triangle.fill")
            .font(.subheadline)
            .foregroundStyle(.red)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(Color.red.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
            .accessibilityElement(children: .combine)
    }

    private func submit() {
        focusedField = nil
        Task { await viewModel.login() }
    }
}

private struct FormField<Content: View>: View {
    let title: String
    let error: String?
    private let content: Content

    init(title: String, error: String?, @ViewBuilder content: () -> Content) {
        self.title = title
        self.error = error
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline.weight(.medium))
            content
                .padding(12)
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(error == nil ? Color.clear : Color.red, lineWidth: 1)
                )
            if let error {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
    }
}
