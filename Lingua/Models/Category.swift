import Foundation
import SwiftData

@Model
final class Category {
    @Attribute(.unique) var name: String
    var symbolName: String
    var createdAt: Date

    @Relationship(inverse: \Phrase.categories)
    var phrases: [Phrase]

    init(name: String, symbolName: String, createdAt: Date = .now) {
        self.name = name
        self.symbolName = symbolName
        self.createdAt = createdAt
        self.phrases = []
    }
}

enum BuiltInCategory: String, CaseIterable {
    case study = "Study"
    case travel = "Travel"
    case dining = "Dining"
    case emergency = "Emergency"
    case casual = "Casual"

    var symbolName: String {
        switch self {
        case .study:
            return "book.closed"
        case .travel:
            return "airplane"
        case .dining:
            return "fork.knife"
        case .emergency:
            return "cross.case"
        case .casual:
            return "bubble.left.and.bubble.right"
        }
    }
}
