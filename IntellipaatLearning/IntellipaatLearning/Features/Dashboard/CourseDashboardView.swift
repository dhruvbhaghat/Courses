import SwiftUI

@MainActor
struct CourseDashboardView: View {
    @StateObject private var viewModel: CourseDashboardViewModel
    @State private var path: [Course] = []
    private let onLogout: () -> Void

    init(viewModel: @autoclosure @escaping () -> CourseDashboardViewModel, onLogout: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: viewModel())
        self.onLogout = onLogout
    }

    var body: some View {
        NavigationStack(path: $path) {
            content
                .navigationTitle("My Courses")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Log Out", role: .destructive, action: onLogout)
                    }
                }
                .navigationDestination(for: Course.self) { course in
                    CourseDetailsView(viewModel: viewModel.makeDetailsViewModel(for: course))
                }
        }
        .task { await viewModel.loadIfNeeded() }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView("Loading courses…")
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .empty:
            ContentUnavailableView {
                Label("No Courses Yet", systemImage: "books.vertical")
            } description: {
                Text("Courses you enroll in will appear here.")
            } actions: {
                Button("Reload") { Task { await viewModel.refresh() } }
            }

        case .failed(let message):
            ContentUnavailableView {
                Label("Couldn't Load Courses", systemImage: "exclamationmark.triangle")
            } description: {
                Text(message)
            } actions: {
                Button("Try Again") { Task { await viewModel.refresh() } }
            }

        case .loaded:
            courseList
        }
    }

    private var courseList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if viewModel.isShowingCachedData {
                    offlineBanner
                }
                ForEach(viewModel.courses) { course in
                    CourseCardView(course: course) {
                        path.append(course)
                    }
                }
            }
            .padding(16)
        }
        .refreshable { await viewModel.refresh() }
    }

    private var offlineBanner: some View {
        Label("Showing saved courses. Pull down to refresh.", systemImage: "wifi.slash")
            .font(.footnote)
            .foregroundStyle(.orange)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(Color.orange.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
            .accessibilityElement(children: .combine)
    }
}
