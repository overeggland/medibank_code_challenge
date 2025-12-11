import Foundation

protocol NewsServicing {
    func fetchTopHeadlines(country: String) async throws -> [Article]
}

struct NewsService: NewsServicing {
    private let apiKey: String?
    private let session: URLSession

    init(apiKey: String? = nil, session: URLSession = .shared) {
        self.apiKey = apiKey ?? ProcessInfo.processInfo.environment["NEWS_API_KEY"]
        self.session = session
    }

    func fetchTopHeadlines(country: String = "au") async throws -> [Article] {
        guard let apiKey else {
            // Provide offline preview data when no key is set.
            return Article.previews
        }

        var components = URLComponents(string: "https://newsapi.org/v2/top-headlines")!
        components.queryItems = [
            URLQueryItem(name: "country", value: country),
            URLQueryItem(name: "apiKey", value: apiKey)
        ]

        let (data, response) = try await session.data(from: components.url!)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let payload = try decoder.decode(NewsAPIResponse.self, from: data)
        return payload.articles
    }
}

// MARK: - DTOs

private struct NewsAPIResponse: Codable {
    let status: String
    let totalResults: Int
    let articles: [Article]
}
