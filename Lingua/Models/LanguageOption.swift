import Foundation

enum LanguageOption: String, CaseIterable, Identifiable, Codable {
    case english = "en"
    case spanish = "es"
    case french = "fr"
    case german = "de"
    case italian = "it"
    case portuguese = "pt"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .english:
            return "English"
        case .spanish:
            return "Spanish"
        case .french:
            return "French"
        case .german:
            return "German"
        case .italian:
            return "Italian"
        case .portuguese:
            return "Portuguese"
        }
    }
}
