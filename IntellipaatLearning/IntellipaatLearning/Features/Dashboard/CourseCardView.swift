import SwiftUI

struct CourseCardView: View {
    let course: Course
    let onContinue: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text(course.title)
                    .font(.headline)
                Text(course.instructor)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 6) {
                ProgressView(value: Double(course.progress), total: 100)
                HStack {
                    Text("\(course.progress)% complete")
                    Spacer()
                    Text("\(course.lessons) lessons")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Button(action: onContinue) {
                Text("Continue")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(16)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
        .contentShape(RoundedRectangle(cornerRadius: 16))
        .onTapGesture(perform: onContinue)
    }
}
