import Foundation
import OSLog

enum RepositoryError: LocalizedError, Equatable {
    case lessonsUnavailable
    case lessonNotFound

    var errorDescription: String? {
        switch self {
        case .lessonsUnavailable:
            return "Lessons aren't available yet. Please reopen the course."
        case .lessonNotFound:
            return "That lesson no longer exists."
        }
    }
}

protocol CourseRepositoryProtocol {
    func loadCourses() async throws -> CoursesResult
    func loadLessons(for course: Course) async throws -> [Lesson]
    func completeLesson(_ lessonId: Int, in course: Course) async throws -> LessonsSnapshot
    func clearLocalData() async
}

final class CourseRepository: CourseRepositoryProtocol {
    private let network: NetworkManaging
    private let store: CourseStoring

    init(network: NetworkManaging, store: CourseStoring) {
        self.network = network
        self.store = store
    }

    func loadCourses() async throws -> CoursesResult {
        let remote: [Course]
        do {
            remote = try await network.request(.courses)
        } catch let cancellation as CancellationError {
            throw cancellation
        } catch {
            AppLogger.repository.error("Course fetch failed: \(error.localizedDescription, privacy: .public)")
            guard let cached = try? await store.loadCourses() else { throw error }
            return CoursesResult(courses: cached, source: .cache)
        }

        let merged = await applyingLocalProgress(to: remote)
        do {
            try await store.saveCourses(merged)
        } catch {
            AppLogger.repository.error("Course cache write failed: \(error.localizedDescription, privacy: .public)")
        }
        return CoursesResult(courses: merged, source: .network)
    }

    func loadLessons(for course: Course) async throws -> [Lesson] {
        if let local = try? await store.loadLessons(courseId: course.id) {
            return local
        }
        let remote: [Lesson] = try await network.request(.lessons(courseId: course.id))
        do {
            try await store.saveLessons(remote, courseId: course.id)
        } catch {
            AppLogger.repository.error("Lesson cache write failed: \(error.localizedDescription, privacy: .public)")
        }
        return remote
    }

    func completeLesson(_ lessonId: Int, in course: Course) async throws -> LessonsSnapshot {
        guard var lessons = try await store.loadLessons(courseId: course.id) else {
            throw RepositoryError.lessonsUnavailable
        }
        guard let index = lessons.firstIndex(where: { $0.id == lessonId }) else {
            throw RepositoryError.lessonNotFound
        }
        guard !lessons[index].isCompleted else {
            return LessonsSnapshot(lessons: lessons, progress: ProgressCalculator.percentage(of: lessons))
        }

        lessons[index].isCompleted = true
        let progress = ProgressCalculator.percentage(of: lessons)

        try await store.saveLessons(lessons, courseId: course.id)
        try await store.updateProgress(courseId: course.id, progress: progress)
        syncCompletion(courseId: course.id, lessonId: lessonId)

        return LessonsSnapshot(lessons: lessons, progress: progress)
    }

    func clearLocalData() async {
        do {
            try await store.removeAll()
        } catch {
            AppLogger.repository.error("Clearing local data failed: \(error.localizedDescription, privacy: .public)")
        }
    }

    private func applyingLocalProgress(to courses: [Course]) async -> [Course] {
        var result: [Course] = []
        for course in courses {
            var updated = course
            if let lessons = try? await store.loadLessons(courseId: course.id), !lessons.isEmpty {
                updated.progress = max(course.progress, ProgressCalculator.percentage(of: lessons))
            }
            result.append(updated)
        }
        return result
    }

    private func syncCompletion(courseId: Int, lessonId: Int) {
        Task { [network] in
            do {
                let _: CompletionResponse = try await network.request(
                    .completeLesson(courseId: courseId, lessonId: lessonId)
                )
            } catch {
                AppLogger.repository.error("Lesson sync failed: \(error.localizedDescription, privacy: .public)")
            }
        }
    }
}
