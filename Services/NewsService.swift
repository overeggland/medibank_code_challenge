import Foundation

protocol NewsServicing {
    func fetchTopHeadlines(country: NewsCountry, category: NewsCategory?) async throws -> [Article]
}

struct NewsService: NewsServicing {
    private let apiKey: String?
    private let session: URLSession

    init(apiKey: String? = nil, session: URLSession = .shared) {
        self.apiKey = apiKey ?? NewsAPIConstants.defaultAPIKey
        self.session = session
    }

    func fetchTopHeadlines(country: NewsCountry = .us, category: NewsCategory? = .business) async throws -> [Article] {
        guard let apiKey else {
            // Provide offline preview data when no key is set.
            return Article.previews
        }

        var components = URLComponents(string: "\(NewsAPIConstants.baseURLString)\(NewsAPIConstants.topHeadlinesPath)")!
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "country", value: country.rawValue),
            URLQueryItem(name: "apiKey", value: apiKey),
            URLQueryItem(name: "pageSize", value: "\(NewsAPIConstants.defaultPageSize)")
        ]

        if let category {
            queryItems.append(URLQueryItem(name: "category", value: category.rawValue))
        }

        components.queryItems = queryItems

        guard let url = components.url else {
            throw NewsAPIError.invalidResponse
        }

#if DEBUG
        print("Fetching headlines: \(url.absoluteString)")
#endif

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw NewsAPIError.invalidResponse
        }

        guard (200..<300).contains(http.statusCode) else {
            throw NewsAPIError.httpStatus(http.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        do {
            let payload = try decoder.decode(NewsAPIResponse.self, from: data)
            return payload.articles
        } catch {
            throw NewsAPIError.decoding(error)
        }
    }
}

enum NewsAPIError: LocalizedError {
    case invalidResponse
    case httpStatus(Int)
    case decoding(Error)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "The server returned an invalid response."
        case .httpStatus(let code):
            return "The server responded with status code \(code)."
        case .decoding:
            return "Unable to decode the response."
        }
    }
}

// MARK: - DTOs

private struct NewsAPIResponse: Codable {
    let status: String
    let totalResults: Int
    let articles: [Article]
}