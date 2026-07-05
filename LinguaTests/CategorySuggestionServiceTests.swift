import XCTest
@testable import Lingua

final class CategorySuggestionServiceTests: XCTestCase {
    func testSuggestsEmergencyCategoryForHelpPhrase() {
        let service = CategorySuggestionService()

        let categories = service.suggestCategories(for: "I need help at the hospital")

        XCTAssertTrue(categories.contains(.emergency))
    }

    func testFallsBackToCasualWhenNoSignalsMatch() {
        let service = CategorySuggestionService()

        let categories = service.suggestCategories(for: "Nice to meet you")

        XCTAssertEqual(categories, [.casual])
    }
}
