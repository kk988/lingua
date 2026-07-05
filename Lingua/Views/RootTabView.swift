import SwiftData
import SwiftUI

struct RootTabView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = TranslateViewModel(
        provider: TranslationProviderFactory.make(),
        categorizer: CategorySuggestionService()
    )

    var body: some View {
        TabView {
            NavigationStack {
                TranslateView(viewModel: viewModel)
            }
            .tabItem {
                Label("Translate", systemImage: "globe")
            }

            NavigationStack {
                SavedPhrasesView()
            }
            .tabItem {
                Label("Saved", systemImage: "tray.full")
            }

            CategoriesView()
                .tabItem {
                    Label("Categories", systemImage: "square.grid.2x2")
                }

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape")
            }
        }
        .task {
            try? SeedData.ensureDefaults(in: modelContext)
        }
    }
}
