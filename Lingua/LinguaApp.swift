import SwiftData
import SwiftUI

@main
struct LinguaApp: App {
    private var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Phrase.self,
            Category.self,
        ])

        let configuration = ModelConfiguration(cloudKitDatabase: .automatic)

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootTabView()
        }
        .modelContainer(sharedModelContainer)
    }
}
