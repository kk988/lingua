import SwiftData
import SwiftUI

struct CategoriesView: View {
    @Query(sort: \Category.name) private var categories: [Category]

    var body: some View {
        NavigationSplitView {
            List(categories) { category in
                NavigationLink {
                    CategoryDetailView(category: category)
                } label: {
                    HStack {
                        Label(category.name, systemImage: category.symbolName)
                        Spacer()
                        Text("\(category.phrases.count)")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Categories")
        } detail: {
            ContentUnavailableView(
                "Select a Category",
                systemImage: "square.grid.2x2",
                description: Text("Browse saved phrases by the situations where you use them.")
            )
        }
    }
}

private struct CategoryDetailView: View {
    let category: Category

    var body: some View {
        List(category.phrases) { phrase in
            VStack(alignment: .leading, spacing: 6) {
                Text(phrase.sourceText)
                    .font(.headline)
                Text(phrase.translatedText)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle(category.name)
    }
}
