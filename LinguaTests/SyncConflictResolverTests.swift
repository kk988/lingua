import XCTest
@testable import Lingua

final class SyncConflictResolverTests: XCTestCase {
    func testKeepsNewestTextAndLanguagePair() {
        let local = PhraseSyncRecord(
            sourceText: "Need help",
            translatedText: "Necesito ayuda",
            sourceLanguageCode: "en",
            targetLanguageCode: "es",
            updatedAt: Date(timeIntervalSince1970: 100),
            isFavorite: false,
            categoryNames: ["Emergency"]
        )

        let remote = PhraseSyncRecord(
            sourceText: "Need urgent help",
            translatedText: "Necesito ayuda urgente",
            sourceLanguageCode: "en",
            targetLanguageCode: "es",
            updatedAt: Date(timeIntervalSince1970: 200),
            isFavorite: false,
            categoryNames: ["Travel"]
        )

        let merged = SyncConflictResolver.merge(local: local, remote: remote)

        XCTAssertEqual(merged.sourceText, "Need urgent help")
        XCTAssertEqual(merged.translatedText, "Necesito ayuda urgente")
        XCTAssertEqual(merged.updatedAt, Date(timeIntervalSince1970: 200))
    }

    func testPreservesFavoriteIfEitherSideIsFavorite() {
        let local = PhraseSyncRecord(
            sourceText: "Hello",
            translatedText: "Hola",
            sourceLanguageCode: "en",
            targetLanguageCode: "es",
            updatedAt: Date(timeIntervalSince1970: 100),
            isFavorite: true,
            categoryNames: []
        )

        let remote = PhraseSyncRecord(
            sourceText: "Hello",
            translatedText: "Hola",
            sourceLanguageCode: "en",
            targetLanguageCode: "es",
            updatedAt: Date(timeIntervalSince1970: 110),
            isFavorite: false,
            categoryNames: []
        )

        let merged = SyncConflictResolver.merge(local: local, remote: remote)

        XCTAssertTrue(merged.isFavorite)
    }

    func testUnionsCategoriesAcrossDevices() {
        let local = PhraseSyncRecord(
            sourceText: "Water",
            translatedText: "Agua",
            sourceLanguageCode: "en",
            targetLanguageCode: "es",
            updatedAt: Date(timeIntervalSince1970: 100),
            isFavorite: false,
            categoryNames: ["Dining", "Travel"]
        )

        let remote = PhraseSyncRecord(
            sourceText: "Water",
            translatedText: "Agua",
            sourceLanguageCode: "en",
            targetLanguageCode: "es",
            updatedAt: Date(timeIntervalSince1970: 90),
            isFavorite: false,
            categoryNames: ["Emergency"]
        )

        let merged = SyncConflictResolver.merge(local: local, remote: remote)

        XCTAssertEqual(merged.categoryNames, ["Dining", "Travel", "Emergency"])
    }
}
