import SwiftUI

@MainActor
struct RootView: View {
    @StateObject private var appViewModel: AppViewModel
    private let container: AppContainer

    init(container: AppContainer) {
        self.container = container
        _appViewModel = StateObject(wrappedValue: container.makeAppViewModel())
    }

    var body: some View {
        Group {
            if appViewModel.session == nil {
                LoginView(
                    viewModel: container.makeLoginViewModel { session in
                        appViewModel.didLogin(session)
                    }
                )
            } else {
                CourseDashboardView(
                    viewModel: container.makeDashboardViewModel(),
                    onLogout: {
                        Task { await appViewModel.logout() }
                    }
                )
            }
        }
        .animation(.default, value: appViewModel.session)
    }
}
