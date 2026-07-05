import Foundation

struct TranslationRequest {
    let text: String
    let sourceLanguage: LanguageOption
    let targetLanguage: LanguageOption
}

struct TranslationResult {
    let translatedText: String
}

enum TranslationError: LocalizedError {
    case emptyText
    case invalidResponse
    case serverError(String)
    case networkFailure(String)
    case decodingFailed

    var errorDescription: String? {
        switch self {
        case .emptyText:
            return "Enter a phrase to translate."
        case .invalidResponse:
            return "The translation service returned an invalid response."
        case .serverError(let message):
            return "Translation failed: \(message)"
        case .networkFailure(let message):
            return "Network error: \(message)"
        case .decodingFailed:
            return "Could not read the translation response."
        }
    }
}

protocol TranslationProvider {
    func translate(_ request: TranslationRequest) async throws -> TranslationResult
}

struct NetworkTranslationProvider: TranslationProvider {
    private let endpoint: URL
    private let apiKey: String?
    private let session: URLSession

    init(endpoint: URL, apiKey: String? = nil, session: URLSession = .shared) {
        self.endpoint = endpoint
        self.apiKey = apiKey?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.session = session
    }

    func translate(_ request: TranslationRequest) async throws -> TranslationResult {
        let text = request.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else {
            throw TranslationError.emptyText
        }

        if request.sourceLanguage == request.targetLanguage {
            return TranslationResult(translatedText: text)
        }

        var urlRequest = URLRequest(url: endpoint)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload = LibreTranslateRequest(
            q: text,
            source: request.sourceLanguage.rawValue,
            target: request.targetLanguage.rawValue,
            format: "text",
            api_key: apiKey
        )

        do {
            urlRequest.httpBody = try JSONEncoder().encode(payload)
            let (data, response) = try await session.data(for: urlRequest)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw TranslationError.invalidResponse
            }

            let decoded = try JSONDecoder().decode(LibreTranslateResponse.self, from: data)

            guard (200 ... 299).contains(httpResponse.statusCode) else {
                throw TranslationError.serverError(decoded.error ?? "Status \(httpResponse.statusCode)")
            }

            guard let translated = decoded.translatedText, !translated.isEmpty else {
                if let message = decoded.error {
                    throw TranslationError.serverError(message)
                }
                throw TranslationError.decodingFailed
            }

            return TranslationResult(translatedText: translated)
        } catch let error as TranslationError {
            throw error
        } catch let error as URLError {
            throw TranslationError.networkFailure(error.localizedDescription)
        } catch is DecodingError {
            throw TranslationError.decodingFailed
        } catch {
            throw TranslationError.networkFailure(error.localizedDescription)
        }
    }
}

enum TranslationProviderFactory {
    private static let defaultEndpoint = "https://libretranslate.com/translate"

    static func make(bundle: Bundle = .main, session: URLSession = .shared) -> TranslationProvider {
        let endpointString = (bundle.object(forInfoDictionaryKey: "TranslationAPIEndpoint") as? String)
            ?.trimmingCharacters(in: .whitespacesAndNewlines)
        let apiKey = (bundle.object(forInfoDictionaryKey: "TranslationAPIKey") as? String)
            ?.trimmingCharacters(in: .whitespacesAndNewlines)

        let endpoint = URL(string: endpointString?.isEmpty == false ? endpointString! : defaultEndpoint)
            ?? URL(string: defaultEndpoint)!

        return NetworkTranslationProvider(
            endpoint: endpoint,
            apiKey: apiKey?.isEmpty == true ? nil : apiKey,
            session: session
        )
    }
}

private struct LibreTranslateRequest: Encodable {
    let q: String
    let source: String
    let target: String
    let format: String
    let api_key: String?
}

private struct LibreTranslateResponse: Decodable {
    let translatedText: String?
    let error: String?
}
