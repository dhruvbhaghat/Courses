import Combine
import Foundation

@MainActor
final class CourseDashboardViewModel: ObservableObject {
    @Published private(set) var courses: [Course] = []
    @Published private(set) var state: LoadState = .idle
    @Published private(set) var isShowingCachedData = false

    private let repository: CourseRepositoryProtocol
    private var isRefreshing = false

    init(repository: CourseRepositoryProtocol) {
        self.repository = repository
    }

    func loadIfNeeded() async {
        guard state == .idle else { return }
        await refresh()
    }

    func refresh() async {
        guard !isRefreshing else { return }
        isRefreshing = true
        defer { isRefreshing = false }

        if courses.isEmpty {
            state = .loading
        }

        do {
            let result = try await repository.loadCourses()
            courses = result.courses
            isShowingCachedData = result.source == .cache
            state = result.courses.isEmpty ? .empty : .loaded
        } catch is CancellationError {
            if courses.isEmpty { state = .idle }
        } catch {
            if courses.isEmpty { state = .failed(error.localizedDescription) }
        }
    }

    func makeDetailsViewModel(for course: Course) -> CourseDetailsViewModel {
        CourseDetailsViewModel(course: course, repository: repository) { [weak self] courseId, progress in
            self?.updateProgress(courseId: courseId, progress: progress)
        }
    }

    private func updateProgress(courseId: Int, progress: Int) {
        guard let index = courses.firstIndex(where: { $0.id == courseId }) else { return }
        courses[index].progress = progress
    }
}
