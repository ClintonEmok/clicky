//
//  ReadingVocabularyStore.swift
//  leanring-buddy
//

import Foundation

struct ReadingVocabularyItem: Identifiable, Codable, Equatable {
    let lookupID: String
    let originalText: String
    let translatedText: String
    let explanation: String?
    let sourceAppName: String
    let sourceContext: String
    let capturedAt: Date

    var id: String { lookupID }
}

@MainActor
final class ReadingVocabularyStore: ObservableObject {
    @Published private(set) var items: [ReadingVocabularyItem] = []

    private let storageKey = "readingVocabularyItems"

    init() {
        loadItems()
    }

    func add(_ item: ReadingVocabularyItem) {
        items.removeAll { $0.lookupID == item.lookupID }
        items.insert(item, at: 0)
        if items.count > 100 {
            items = Array(items.prefix(100))
        }
        persistItems()
    }

    func remove(id: String) {
        items.removeAll { $0.lookupID == id }
        persistItems()
    }

    func clear() {
        items = []
        persistItems()
    }

    private func loadItems() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decodedItems = try? JSONDecoder().decode([ReadingVocabularyItem].self, from: data) else {
            items = []
            return
        }

        items = decodedItems
    }

    private func persistItems() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}
