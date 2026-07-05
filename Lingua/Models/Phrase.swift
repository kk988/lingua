import Foundation
import SwiftData

@Model
final class Phrase {
    var sourceText: String
    var translatedText: String
    var sourceLanguageCode: String
    var targetLanguageCode: String
    var createdAt: Date
    var updatedAt: Date
    var isFavorite: Bool

    @Relationship
    var categories: [Category]

    init(
        sourceText: String,
        translatedText: String,
        sourceLanguageCode: String,
        targetLanguageCode: String,
        createdAt: Date = .now,
        updatedAt: Date = .now,
        isFavorite: Bool = false,
        categories: [Category] = []
    ) {
        self.sourceText = sourceText
        self.translatedText = translatedText
        self.sourceLanguageCode = sourceLanguageCode
        self.targetLanguageCode = targetLanguageCode
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isFavorite = isFavorite
        self.categories = categories
    }

    var sourceLanguage: LanguageOption {
        LanguageOption(rawValue: sourceLanguageCode) ?? .english
    }

    var targetLanguage: LanguageOption {
        LanguageOption(rawValue: targetLanguageCode) ?? .spanish
    }
}
