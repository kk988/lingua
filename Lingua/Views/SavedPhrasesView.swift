import SwiftData
import SwiftUI

struct SavedPhrasesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Phrase.createdAt, order: .reverse) private var phrases: [Phrase]
    @Query(sort: \Category.name) private var categories: [Category]
    @State private var searchText = ""
    @State private var selectedPair: LanguagePair?
    @State private var selectedCategoryName: String?
    @State private var editingPhrase: Phrase?

    private var availablePairs: [LanguagePair] {
        let pairs = Set(phrases.map { phrase in
            LanguagePair(
                source: phrase.sourceLanguage,
                target: phrase.targetLanguage
            )
        })

        return pairs.sorted { $0.displayLabel < $1.displayLabel }
    }

    private var filteredPhrases: [Phrase] {
        return phrases.filter {
            matchesSearch($0)
                && matchesPair($0)
                && matchesCategory($0)
        }
    }

    var body: some View {
        List {
            ForEach(filteredPhrases) { phrase in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(phrase.sourceText)
                            .font(.headline)
                        Spacer()
                        if phrase.isFavorite {
                            Image(systemName: "star.fill")
                                .foregroundStyle(.yellow)
                        }
                    }

                    Text(phrase.translatedText)
                        .font(.body)
                        .foregroundStyle(.secondary)

                    Text("\(phrase.sourceLanguage.displayName) -> \(phrase.targetLanguage.displayName)")
                        .font(.caption)
                        .foregroundStyle(.tertiary)

                    if !phrase.categories.isEmpty {
                        Text(phrase.categories.map(\.name).joined(separator: ", "))
                            .font(.caption)
                    }
                }
                .swipeActions {
                    Button("Edit") {
                        editingPhrase = phrase
                    }
                    .tint(.blue)

                    Button(phrase.isFavorite ? "Unfavorite" : "Favorite") {
                        phrase.isFavorite.toggle()
                        phrase.updatedAt = .now
                        try? modelContext.save()
                    }
                    .tint(.yellow)

                    Button("Delete", role: .destructive) {
                        modelContext.delete(phrase)
                        try? modelContext.save()
                    }
                }
            }
        }
        .safeAreaInset(edge: .top) {
            filterBar
        }
        .searchable(text: $searchText)
        .navigationTitle("Saved Phrases")
        .sheet(item: $editingPhrase) { phrase in
            NavigationStack {
                PhraseEditorView(phrase: phrase)
            }
        }
        .overlay {
            if phrases.isEmpty {
                ContentUnavailableView(
                    "No Saved Phrases",
                    systemImage: "tray",
                    description: Text("Translate a phrase and save it to build your personal phrasebook.")
                )
            } else if filteredPhrases.isEmpty {
                ContentUnavailableView(
                    "No Matches",
                    systemImage: "line.3.horizontal.decrease.circle",
                    description: Text("Try changing search text or clearing filters.")
                )
            }
        }
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                Menu {
                    Button("All Language Pairs") {
                        selectedPair = nil
                    }

                    ForEach(availablePairs) { pair in
                        Button(pair.displayLabel) {
                            selectedPair = pair
                        }
                    }
                } label: {
                    Label(
                        selectedPair?.displayLabel ?? "All Pairs",
                        systemImage: "globe"
                    )
                }

                Menu {
                    Button("All Categories") {
                        selectedCategoryName = nil
                    }

                    ForEach(categories) { category in
                        Button(category.name) {
                            selectedCategoryName = category.name
                        }
                    }
                } label: {
                    Label(
                        selectedCategoryName ?? "All Categories",
                        systemImage: "tag"
                    )
                }

                if selectedPair != nil || selectedCategoryName != nil {
                    Button("Clear") {
                        selectedPair = nil
                        selectedCategoryName = nil
                    }
                }
            }
            .buttonStyle(.bordered)
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 4)
        }
        .background(.thinMaterial)
    }

    private func matchesSearch(_ phrase: Phrase) -> Bool {
        guard !searchText.isEmpty else {
            return true
        }

        return phrase.sourceText.localizedCaseInsensitiveContains(searchText)
            || phrase.translatedText.localizedCaseInsensitiveContains(searchText)
            || phrase.categories.contains(where: { $0.name.localizedCaseInsensitiveContains(searchText) })
    }

    private func matchesPair(_ phrase: Phrase) -> Bool {
        guard let selectedPair else {
            return true
        }

        return phrase.sourceLanguage == selectedPair.source
            && phrase.targetLanguage == selectedPair.target
    }

    private func matchesCategory(_ phrase: Phrase) -> Bool {
        guard let selectedCategoryName else {
            return true
        }

        return phrase.categories.contains {
            $0.name.caseInsensitiveCompare(selectedCategoryName) == .orderedSame
        }
    }
}

private struct LanguagePair: Identifiable, Hashable {
    let source: LanguageOption
    let target: LanguageOption

    var id: String {
        "\(source.rawValue)->\(target.rawValue)"
    }

    var displayLabel: String {
        "\(source.displayName) -> \(target.displayName)"
    }
}

private struct PhraseEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Category.name) private var allCategories: [Category]

    let phrase: Phrase

    @State private var sourceText: String
    @State private var translatedText: String
    @State private var sourceLanguage: LanguageOption
    @State private var targetLanguage: LanguageOption
    @State private var selectedCategoryNames: Set<String>
    @State private var newCategoryName = ""
    @State private var errorMessage: String?

    init(phrase: Phrase) {
        self.phrase = phrase
        _sourceText = State(initialValue: phrase.sourceText)
        _translatedText = State(initialValue: phrase.translatedText)
        _sourceLanguage = State(initialValue: phrase.sourceLanguage)
        _targetLanguage = State(initialValue: phrase.targetLanguage)
        _selectedCategoryNames = State(initialValue: Set(phrase.categories.map(\.name)))
    }

    var body: some View {
        Form {
            Section("Languages") {
                Picker("From", selection: $sourceLanguage) {
                    ForEach(LanguageOption.allCases) { language in
                        Text(language.displayName).tag(language)
                    }
                }

                Picker("To", selection: $targetLanguage) {
                    ForEach(LanguageOption.allCases) { language in
                        Text(language.displayName).tag(language)
                    }
                }
            }

            Section("Phrase") {
                TextField("Original phrase", text: $sourceText, axis: .vertical)
                    .lineLimit(2 ... 5)

                TextField("Translated phrase", text: $translatedText, axis: .vertical)
                    .lineLimit(2 ... 5)
            }

            Section("Categories") {
                ForEach(allCategories) { category in
                    Toggle(category.name, isOn: binding(for: category.name))
                }

                HStack {
                    TextField("New category", text: $newCategoryName)
                    Button("Add") {
                        let trimmed = newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else {
                            return
                        }

                        selectedCategoryNames.insert(trimmed)
                        newCategoryName = ""
                    }
                }
            }
        }
        .navigationTitle("Edit Phrase")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    saveChanges()
                }
            }
        }
        .alert("Could Not Save", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "")
        }
    }

    private func binding(for categoryName: String) -> Binding<Bool> {
        Binding(
            get: { selectedCategoryNames.contains(categoryName) },
            set: { isSelected in
                if isSelected {
                    selectedCategoryNames.insert(categoryName)
                } else {
                    selectedCategoryNames.remove(categoryName)
                }
            }
        )
    }

    private func saveChanges() {
        let trimmedSource = sourceText.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedTranslation = translatedText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedSource.isEmpty, !trimmedTranslation.isEmpty else {
            errorMessage = "Both source and translated text are required."
            return
        }

        do {
            phrase.sourceText = trimmedSource
            phrase.translatedText = trimmedTranslation
            phrase.sourceLanguageCode = sourceLanguage.rawValue
            phrase.targetLanguageCode = targetLanguage.rawValue
            phrase.categories = try resolveCategories()
            phrase.updatedAt = .now

            try modelContext.save()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func resolveCategories() throws -> [Category] {
        let existing = try modelContext.fetch(FetchDescriptor<Category>())

        return selectedCategoryNames
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .map { categoryName in
                if let match = existing.first(where: {
                    $0.name.caseInsensitiveCompare(categoryName) == .orderedSame
                }) {
                    return match
                }

                let builtIn = BuiltInCategory.allCases.first {
                    $0.rawValue.caseInsensitiveCompare(categoryName) == .orderedSame
                }

                let category = Category(
                    name: categoryName,
                    symbolName: builtIn?.symbolName ?? "tag"
                )
                modelContext.insert(category)
                return category
            }
    }
}
