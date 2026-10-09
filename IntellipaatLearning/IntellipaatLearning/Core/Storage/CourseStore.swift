import Foundation

protocol CourseStoring {
    func loadCourses() async throws -> [Course]?
    func saveCourses(_ courses: [Course]) async throws
    func loadLessons(courseId: Int) async throws -> [Lesson]?
    func saveLessons(_ lessons: [Lesson], courseId: Int) async throws
    func updateProgress(courseId: Int, progress: Int) async throws
    func removeAll() async throws
}

actor FileCourseStore: CourseStoring {
    private let directory: URL
    private let fileManager: FileManager
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(directory: URL? = nil, fileManager: FileManager = .default) {
        self.fileManager = fileManager
        self.directory = directory ?? fileManager
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("LearningDashboard", isDirectory: true)
    }

    func loadCourses() async throws -> [Course]? {
        try read([Course].self, from: coursesURL)
    }

    func saveCourses(_ courses: [Course]) async throws {
        try write(courses, to: coursesURL)
    }

    func loadLessons(courseId: Int) async throws -> [Lesson]? {
        try read([Lesson].self, from: lessonsURL(courseId))
    }

    func saveLessons(_ lessons: [Lesson], courseId: Int) async throws {
        try write(lessons, to: lessonsURL(courseId))
    }

    func updateProgress(courseId: Int, progress: Int) async throws {
        guard var courses = try read([Course].self, from: coursesURL) else { return }
        guard let index = courses.firstIndex(where: { $0.id == courseId }) else { return }
        courses[index].progress = progress
        try write(courses, to: coursesURL)
    }

    func removeAll() async throws {
        guard fileManager.fileExists(atPath: directory.path) else { return }
        try fileManager.removeItem(at: directory)
    }

    private var coursesURL: URL {
        directory.appendingPathComponent("courses.json")
    }

    private func lessonsURL(_ courseId: Int) -> URL {
        directory.appendingPathComponent("lessons_\(courseId).json")
    }

    private func read<Value: Decodable>(_ type: Value.Type, from url: URL) throws -> Value? {
        guard fileManager.fileExists(atPath: url.path) else { return nil }
        let data = try Data(contentsOf: url)
        do {
            return try decoder.decode(Value.self, from: data)
        } catch is DecodingError {
            try? fileManager.removeItem(at: url)
            return nil
        }
    }

    private func write<Value: Encodable>(_ value: Value, to url: URL) throws {
        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        let data = try encoder.encode(value)
        try data.write(to: url, options: .atomic)
    }
}
