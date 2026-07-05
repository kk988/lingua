import Foundation

struct CategorySuggestionService {
    func suggestCategories(for text: String) -> [BuiltInCategory] {
        let normalized = text.lowercased()
        var suggestions: [BuiltInCategory] = []

        if containsAny(of: ["study", "learn", "grammar", "homework", "class"], in: normalized) {
            suggestions.append(.study)
        }

        if containsAny(of: ["airport", "station", "hotel", "passport", "ticket", "travel"], in: normalized) {
            suggestions.append(.travel)
        }

        if containsAny(of: ["menu", "water", "restaurant", "dinner", "breakfast", "bill"], in: normalized) {
            suggestions.append(.dining)
        }

        if containsAny(of: ["help", "doctor", "emergency", "police", "hospital"], in: normalized) {
            suggestions.append(.emergency)
        }

        if suggestions.isEmpty {
            suggestions.append(.casual)
        }

        return suggestions
    }

    private func containsAny(of words: [String], in text: String) -> Bool {
        words.contains(where: { text.contains($0) })
    }
}
