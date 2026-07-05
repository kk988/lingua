import Foundation
import SwiftData

@MainActor
final class TranslateViewModel: ObservableObject {
    @Published var sourceText = ""
    @Published var translatedText = ""
    @Published var sourceLanguage: LanguageOption = .english
    @Published var targetLanguage: LanguageOption = .spanish
    @Published var suggestedCategories: [BuiltInCategory] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let provider: TranslationProvider
    private let categorizer: CategorySuggestionService

    init(provider: TranslationProvider, categorizer: CategorySuggestionService) {
        self.provider = provider
        self.categorizer = categorizer
    }

    func translate() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let result = try await provider.translate(
                TranslationRequest(
                    text: sourceText,
                    sourceLanguage: sourceLanguage,
                    targetLanguage: targetLanguage
                )
            )
            translatedText = result.translatedText
            suggestedCategories = categorizer.suggestCategories(for: sourceText + " " + result.translatedText)
        } catch {
            translatedText = ""
            suggestedCategories = []
            errorMessage = error.localizedDescription
        }
    }

    func swapLanguages() {
        let previousSource = sourceLanguage
        sourceLanguage = targetLanguage
        targetLanguage = previousSource

        let previousText = sourceText
        sourceText = translatedText
        translatedText = previousText
    }

    func save(in modelContext: ModelContext) throws {
        let phrase = Phrase(
            sourceText: sourceText.trimmingCharacters(in: .whitespacesAndNewlines),
            translatedText: translatedText.trimmingCharacters(in: .whitespacesAndNewlines),
            sourceLanguageCode: sourceLanguage.rawValue,
            targetLanguageCode: targetLanguage.rawValue,
            categories: try categories(in: modelContext)
        )

        modelContext.insert(phrase)
        try modelContext.save()
    }

    private func categories(in modelContext: ModelContext) throws -> [Category] {
        let existing = try modelContext.fetch(FetchDescriptor<Category>())
        return suggestedCategories.map { suggestion in
            if let matched = existing.first(where: { $0.name.caseInsensitiveCompare(suggestion.rawValue) == .orderedSame }) {
                return matched
            }

            let category = Category(name: suggestion.rawValue, symbolName: suggestion.symbolName)
            modelContext.insert(category)
            return category
        }
    }
}
