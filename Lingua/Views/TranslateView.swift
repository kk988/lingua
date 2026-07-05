import SwiftData
import SwiftUI

struct TranslateView: View {
    @Environment(\.modelContext) private var modelContext
    @ObservedObject var viewModel: TranslateViewModel
    @State private var saveMessage: String?

    var body: some View {
        Form {
            Section("Languages") {
                Picker("From", selection: $viewModel.sourceLanguage) {
                    ForEach(LanguageOption.allCases) { language in
                        Text(language.displayName).tag(language)
                    }
                }

                Picker("To", selection: $viewModel.targetLanguage) {
                    ForEach(LanguageOption.allCases) { language in
                        Text(language.displayName).tag(language)
                    }
                }

                Button("Swap Languages") {
                    viewModel.swapLanguages()
                }
            }

            Section("Phrase") {
                TextField("Enter a phrase", text: $viewModel.sourceText, axis: .vertical)
                    .lineLimit(3...6)

                Button {
                    Task {
                        await viewModel.translate()
                    }
                } label: {
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        Text("Translate")
                    }
                }
                .disabled(viewModel.sourceText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isLoading)
            }

            if !viewModel.translatedText.isEmpty {
                Section("Translation") {
                    Text(viewModel.translatedText)
                        .font(.title3)
                        .textSelection(.enabled)
                }
            }

            if !viewModel.suggestedCategories.isEmpty {
                Section("Suggested Categories") {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(viewModel.suggestedCategories, id: \.rawValue) { category in
                                Label(category.rawValue, systemImage: category.symbolName)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(.thinMaterial, in: Capsule())
                            }
                        }
                    }
                }
            }

            if !viewModel.translatedText.isEmpty {
                Section {
                    Button("Save Phrase") {
                        do {
                            try viewModel.save(in: modelContext)
                            saveMessage = "Phrase saved."
                        } catch {
                            saveMessage = error.localizedDescription
                        }
                    }
                }
            }
        }
        .navigationTitle("Translate")
        .alert("Status", isPresented: Binding(
            get: { saveMessage != nil || viewModel.errorMessage != nil },
            set: { if !$0 { saveMessage = nil; viewModel.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(saveMessage ?? viewModel.errorMessage ?? "")
        }
    }
}
