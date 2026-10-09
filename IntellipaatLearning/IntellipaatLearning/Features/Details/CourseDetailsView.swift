import SwiftUI

@MainActor
struct CourseDetailsView: View {
    @StateObject private var viewModel: CourseDetailsViewModel

    init(viewModel: @autoclosure @escaping () -> CourseDetailsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        content
            .navigationTitle(viewModel.course.title)
            .task { await viewModel.loadIfNeeded() }
            .alert("Couldn't Update Lesson", isPresented: alertBinding) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.alertMessage ?? "")
            }
    }

    private var alertBinding: Binding<Bool> {
        Binding(
            get: { viewModel.alertMessage != nil },
            set: { isPresented in
                if !isPresented { viewModel.dismissAlert() }
            }
        )
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView("Loading lessons…")
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .empty:
            ContentUnavailableView(
                "No Lessons",
                systemImage: "list.bullet",
                description: Text("This course doesn't have any lessons yet.")
            )

        case .failed(let message):
            ContentUnavailableView {
                Label("Couldn't Load Lessons", systemImage: "exclamationmark.triangle")
            } description: {
                Text(message)
            } actions: {
                Button("Try Again") { Task { await viewModel.load() } }
            }

        case .loaded:
            lessonList
        }
    }

    private var lessonList: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(viewModel.progress)% complete")
                        .font(.title2.bold())
                    ProgressView(value: Double(viewModel.progress), total: 100)
                    Text("\(viewModel.completedCount) of \(viewModel.lessons.count) lessons completed")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }

            Section("Lessons") {
                ForEach(viewModel.lessons) { lesson in
                    LessonRow(
                        lesson: lesson,
                        isUpdating: viewModel.updatingLessonIds.contains(lesson.id)
                    ) {
                        Task { await viewModel.complete(lesson) }
                    }
                }
            }
        }
    }
}

private struct LessonRow: View {
    let lesson: Lesson
    let isUpdating: Bool
    let onComplete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Text(lesson.title)
                .foregroundStyle(lesson.isCompleted ? .secondary : .primary)
            Spacer()
            trailing
        }
        .font(.subheadline)
    }

    @ViewBuilder
    private var trailing: some View {
        if lesson.isCompleted {
            Label("Completed", systemImage: "checkmark.circle.fill")
                .foregroundStyle(.green)
        } else if isUpdating {
            ProgressView()
        } else {
            Button(action: onComplete) {
                Label("Mark Complete", systemImage: "circle")
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
    }
}
