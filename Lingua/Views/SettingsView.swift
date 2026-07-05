import SwiftUI

struct SettingsView: View {
    var body: some View {
        Form {
            Section("App") {
                LabeledContent("Project", value: "Lingua")
                LabeledContent("Target Devices", value: "iPhone and iPad")
                LabeledContent("Persistence", value: "SwiftData + CloudKit")
            }

            Section("Translation") {
                Text("Translations now use a network-backed provider.")
                Text("Set TranslationAPIEndpoint and TranslationAPIKey in Info.plist for your production translation vendor.")
                    .foregroundStyle(.secondary)
            }

            Section("Categorization") {
                Text("Suggestions are rule-based in this scaffold. Users can refine category assignments later as you expand the app.")
            }

            Section("Sync") {
                Text("CloudKit merge behavior prefers the most recently edited phrase text, keeps favorites, and unions category tags to reduce cross-device data loss.")
            }
        }
        .navigationTitle("Settings")
    }
}
