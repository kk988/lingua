import Foundation
import SwiftData

enum SeedData {
    static func ensureDefaults(in modelContext: ModelContext) throws {
        let descriptor = FetchDescriptor<Category>()
        let existing = try modelContext.fetch(descriptor)
        let existingNames = Set(existing.map(\.name))

        for category in BuiltInCategory.allCases where !existingNames.contains(category.rawValue) {
            modelContext.insert(Category(name: category.rawValue, symbolName: category.symbolName))
        }

        try modelContext.save()
    }
}
