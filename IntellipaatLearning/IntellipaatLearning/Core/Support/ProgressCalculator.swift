import Foundation

enum ProgressCalculator {
    static func percentage(completed: Int, total: Int) -> Int {
        guard total > 0 else { return 0 }
        let clamped = min(max(completed, 0), total)
        return Int((Double(clamped) / Double(total) * 100).rounded())
    }

    static func percentage(of lessons: [Lesson]) -> Int {
        percentage(completed: lessons.filter(\.isCompleted).count, total: lessons.count)
    }
}
