import Combine
import Foundation

@MainActor
final class CourseDetailsViewModel: ObservableObject {
    let course: Course

    @Published private(set) var lessons: [Lesson] = []
    @Published private(set) var progress: Int
    @Published private(set) var state: LoadState = .idle
    @Published private(set) var updatingLessonIds: Set<Int> = []
    @Published private(set) var alertMessage: String?

    private let repository: CourseRepositoryProtocol
    private let onProgressChange: (Int, Int) -> Void

    var completedCount: Int {
        lessons.filter(\.isCompleted).count
    }

    init(
        course: Course,
        repository: CourseRepositoryProtocol,
        onProgressChange: @escaping (Int, Int) -> Void = { _, _ in }
    ) {
        self.course = course
        self.repository = repository
        self.onProgressChange = onProgressChange
        self.progress = course.progress
    }

    func loadIfNeeded() async {
        guard state == .idle else { return }
        await load()
    }

    func load() async {
        state = .loading
        do {
            let loaded = try await repository.loadLessons(for: course)
            lessons = loaded
            progress = max(progress, ProgressCalculator.percentage(of: loaded))
            state = loaded.isEmpty ? .empty : .loaded
        } catch is CancellationError {
            state = .idle
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    func complete(_ lesson: Lesson) async {
        guard !lesson.isCompleted, !updatingLessonIds.contains(lesson.id) else { return }

        updatingLessonIds.insert(lesson.id)
        defer { updatingLessonIds.remove(lesson.id) }

        do {
            let snapshot = try await repository.completeLesson(lesson.id, in: course)
            lessons = snapshot.lessons
            progress = snapshot.progress
            onProgressChange(course.id, snapshot.progress)
        } catch is CancellationError {
            return
        } catch {
            alertMessage = error.localizedDescription
        }
    }

    func dismissAlert() {
        alertMessage = nil
    }
}
