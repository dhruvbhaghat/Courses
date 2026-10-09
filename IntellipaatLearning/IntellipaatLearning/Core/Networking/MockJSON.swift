import Foundation

enum MockServer {
    static let email = "student@example.com"
    static let password = "Password123"
}

enum MockJSON {
    static let login = """
    {
      "token": "mock-jwt-token",
      "user": { "id": 1, "name": "Alex Morgan", "email": "student@example.com" }
    }
    """

    static let courses = """
    [
      { "id": 1, "title": "Python Programming", "instructor": "John Smith", "progress": 65, "lessons": 20 },
      { "id": 2, "title": "Generative AI", "instructor": "Sarah Williams", "progress": 40, "lessons": 16 },
      { "id": 3, "title": "Full Stack Development", "instructor": "David Brown", "progress": 25, "lessons": 28 }
    ]
    """

    static let emptyCourses = "[]"

    static let completion = #"{ "success": true }"#

    static func lessons(courseId: Int) -> String? {
        guard let entry = catalog[courseId] else { return nil }
        let items: [[String: Any]] = entry.titles.enumerated().map { index, title in
            [
                "id": index + 1,
                "title": title,
                "isCompleted": index < entry.completed
            ]
        }
        guard
            let data = try? JSONSerialization.data(withJSONObject: items),
            let json = String(data: data, encoding: .utf8)
        else { return nil }
        return json
    }

    private struct CatalogEntry {
        let titles: [String]
        let completed: Int
    }

    private static let catalog: [Int: CatalogEntry] = [
        1: CatalogEntry(
            titles: [
                "Introduction", "Variables & Data Types", "Operators", "Control Flow", "Loops",
                "Functions", "Lists & Tuples", "Dictionaries & Sets", "String Handling", "File I/O",
                "Error Handling", "Modules & Packages", "OOP Basics", "Inheritance", "Decorators",
                "Generators", "Virtual Environments", "Testing with pytest", "Working with APIs", "Capstone Project"
            ],
            completed: 13
        ),
        2: CatalogEntry(
            titles: [
                "Introduction to Generative AI", "How LLMs Work", "Tokens & Embeddings", "Prompt Engineering Basics",
                "Advanced Prompting", "Working with Model APIs", "Structured Outputs", "Function Calling",
                "Retrieval-Augmented Generation", "Vector Databases", "Fine-Tuning Basics", "Evaluation & Testing",
                "Safety & Guardrails", "Agents & Tool Use", "Deploying GenAI Apps", "Capstone Project"
            ],
            completed: 6
        ),
        3: CatalogEntry(
            titles: [
                "HTML Fundamentals", "CSS Layouts", "Responsive Design", "JavaScript Essentials", "DOM Manipulation",
                "Async JavaScript", "TypeScript Basics", "React Fundamentals", "React State & Hooks", "Routing",
                "Forms & Validation", "State Management", "Node.js Basics", "Express Servers", "REST API Design",
                "Authentication", "Databases with SQL", "ORMs", "MongoDB Basics", "Testing Strategies",
                "Docker Essentials", "CI/CD Pipelines", "Cloud Deployment", "Caching & Performance",
                "Security Practices", "Monitoring & Logging", "System Design Basics", "Capstone Project"
            ],
            completed: 7
        )
    ]
}
