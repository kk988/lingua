import XCTest
@testable import Lingua

final class NetworkTranslationProviderTests: XCTestCase {
    override func tearDown() {
        URLProtocolStub.stubResponse = nil
        URLProtocolStub.stubData = nil
        URLProtocolStub.stubError = nil
        super.tearDown()
    }

    func testReturnsTranslationFromServiceResponse() async throws {
        let session = makeSession()
        URLProtocolStub.stubResponse = HTTPURLResponse(
            url: URL(string: "https://example.com/translate")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        URLProtocolStub.stubData = "{\"translatedText\":\"hola\"}".data(using: .utf8)

        let provider = NetworkTranslationProvider(
            endpoint: URL(string: "https://example.com/translate")!,
            session: session
        )

        let result = try await provider.translate(
            TranslationRequest(
                text: "hello",
                sourceLanguage: .english,
                targetLanguage: .spanish
            )
        )

        XCTAssertEqual(result.translatedText, "hola")
    }

    func testReturnsSameTextForSameLanguageWithoutNetwork() async throws {
        let provider = NetworkTranslationProvider(endpoint: URL(string: "https://example.com/translate")!)

        let result = try await provider.translate(
            TranslationRequest(
                text: "Keep this",
                sourceLanguage: .english,
                targetLanguage: .english
            )
        )

        XCTAssertEqual(result.translatedText, "Keep this")
    }

    func testThrowsForEmptyText() async {
        let provider = NetworkTranslationProvider(endpoint: URL(string: "https://example.com/translate")!)

        do {
            _ = try await provider.translate(
                TranslationRequest(
                    text: "   ",
                    sourceLanguage: .english,
                    targetLanguage: .spanish
                )
            )
            XCTFail("Expected emptyText error")
        } catch {
            XCTAssertEqual(error as? TranslationError, .emptyText)
        }
    }

    func testThrowsServerErrorWhenApiReturnsErrorPayload() async {
        let session = makeSession()
        URLProtocolStub.stubResponse = HTTPURLResponse(
            url: URL(string: "https://example.com/translate")!,
            statusCode: 429,
            httpVersion: nil,
            headerFields: nil
        )
        URLProtocolStub.stubData = "{\"error\":\"Rate limit\"}".data(using: .utf8)

        let provider = NetworkTranslationProvider(
            endpoint: URL(string: "https://example.com/translate")!,
            session: session
        )

        do {
            _ = try await provider.translate(
                TranslationRequest(
                    text: "hello",
                    sourceLanguage: .english,
                    targetLanguage: .spanish
                )
            )
            XCTFail("Expected serverError")
        } catch {
            XCTAssertEqual(error as? TranslationError, .serverError("Rate limit"))
        }
    }

    private func makeSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        return URLSession(configuration: configuration)
    }
}

private final class URLProtocolStub: URLProtocol {
    static var stubResponse: URLResponse?
    static var stubData: Data?
    static var stubError: Error?

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        if let stubError = URLProtocolStub.stubError {
            client?.urlProtocol(self, didFailWithError: stubError)
            return
        }

        if let stubResponse = URLProtocolStub.stubResponse {
            client?.urlProtocol(self, didReceive: stubResponse, cacheStoragePolicy: .notAllowed)
        }

        if let stubData = URLProtocolStub.stubData {
            client?.urlProtocol(self, didLoad: stubData)
        }

        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
