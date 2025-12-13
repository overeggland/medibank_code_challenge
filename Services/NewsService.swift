import Foundation

protocol NewsServicing {
    func fetchTopHeadlines(country: NewsCountry?, category: NewsCategory?, sources: String?, pageSize: Int) async throws -> [Article]
    func fetchSources(country: NewsCountry?) async throws -> [Article.Source]
    func loadCachedSources() -> [Article.Source]
}

struct NewsService: NewsServicing {
    private let apiKey: String
    private let session: URLSession
    private let userDefaults: UserDefaults
    private let savedSourcesKey = "savedEnglishSources"
    
    init(apiKey: String = NewsAPIConstants.defaultAPIKey, session: URLSession = .shared, userDefaults: UserDefaults = .standard) {
        self.apiKey = apiKey
        self.session = session
        self.userDefaults = userDefaults
    }

    func fetchTopHeadlines(country: NewsCountry? = .us, category: NewsCategory? = .business, sources: String? = nil, pageSize: Int = NewsAPIConstants.defaultPageSize) async throws -> [Article] {
        // Determine which parameters to use
        // If sources is provided and non-empty, use only sources and ignore country/category
        let hasSources = sources != nil && !sources!.isEmpty
        let finalCountry: NewsCountry?
        let finalCategory: NewsCategory?
        let finalSources: String?
        
        if hasSources {
            // When sources is provided, ignore country and category
            finalCountry = nil
            finalCategory = nil
            finalSources = sources
        } else {
            // Use country and category (with defaults)
            finalCountry = country
            finalCategory = category
            finalSources = nil
        }
        
        // If API key is empty, return preview data (for testing/preview mode)
        guard !apiKey.isEmpty else {
            return Article.previews
        }

        guard let url = NewsAPIConstants.topHeadlinesURL(country: finalCountry, category: finalCategory, sources: finalSources, pageSize: pageSize, apiKey: apiKey) else {
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
    
    func fetchSources(country: NewsCountry? = nil) async throws -> [Article.Source] {
        // If API key is empty, return preview data (for testing/preview mode)
        guard !apiKey.isEmpty else {
            let previewSources = [
                Article.Source(id: "abc-news", name: "ABC News"),
                Article.Source(id: "bbc-news", name: "BBC News"),
                Article.Source(id: "cnn", name: "CNN")
            ]
            try? saveSources(previewSources)
            return previewSources
        }
        
        guard let url = NewsAPIConstants.sourcesURL(country: country, apiKey: apiKey) else {
            // If URL creation fails, try to load from storage
            return loadSavedSources()
        }
        
#if DEBUG
        print("Fetching sources: \(url.absoluteString)")
#endif
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse else {
                // If response is invalid, try to load from storage
                return loadSavedSources()
            }
            
            guard (200..<300).contains(http.statusCode) else {
                // If HTTP status is not OK, try to load from storage
                return loadSavedSources()
            }
            
            let decoder = JSONDecoder()
            let payload = try decoder.decode(SourcesAPIResponse.self, from: data)
            // Filter to only English sources (if country filter wasn't applied)
            // If country was specified, the API already filtered by country
            let filteredSources = payload.sources
                .filter { $0.language == "en" }
                .compactMap { sourceResponse -> Article.Source? in
                    guard let id = sourceResponse.id else { return nil }
                    return Article.Source(id: id, name: sourceResponse.name)
                }
            
            // Save successfully fetched sources
            try? saveSources(filteredSources)
            
            return filteredSources
        } catch {
            // If fetch fails, try to load from storage
            return loadSavedSources()
        }
    }
    
    private func saveSources(_ sources: [Article.Source]) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(sources)
        userDefaults.set(data, forKey: savedSourcesKey)
    }
    
    func loadCachedSources() -> [Article.Source] {
        return loadSavedSources()
    }
    
    private func loadSavedSources() -> [Article.Source] {
        guard let data = userDefaults.data(forKey: savedSourcesKey) else {
            return []
        }
        let decoder = JSONDecoder()
        guard let sources = try? decoder.decode([Article.Source].self, from: data) else {
            return []
        }
        return sources
    }
}

enum NewsAPIError: LocalizedError {
    case invalidResponse
    case httpStatus(Int)
    case decoding(Error)
    case invalidParameters(String)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "The server returned an invalid response."
        case .httpStatus(let code):
            return "The server responded with status code \(code)."
        case .decoding:
            return "Unable to decode the response."
        case .invalidParameters(let message):
            return message
        }
    }
}

// MARK: - DTOs

private struct NewsAPIResponse: Codable {
    let status: String
    let totalResults: Int
    let articles: [Article]
}

private struct SourcesAPIResponse: Codable {
    let status: String
    let sources: [SourceResponse]
}

private struct SourceResponse: Codable {
    let id: String?
    let name: String
    let description: String?
    let url: String?
    let category: String?
    let language: String?
    let country: String?
}