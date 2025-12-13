import Foundation

enum NewsCategory: String, CaseIterable, Hashable {
    case business
    case entertainment
    case general
    case health
    case science
    case sports
    case technology
}

enum NewsCountry: String, CaseIterable, Hashable {
    case au
    case us
    case gb
    case ca
    case de
    case fr
}

enum NewsAPIConstants {
    static let defaultAPIKey = "c5669d85cb5c453ca6335bf6ac10108d" // Development API Key
    static let baseURLString = "https://newsapi.org"
    static let topHeadlinesPath = "/v2/top-headlines"
    static let sourcesPath = "/v2/top-headlines/sources"
    static let defaultPageSize = 10
}

extension NewsAPIConstants {
    static func topHeadlinesURL(country: NewsCountry, category: NewsCategory?, apiKey: String) -> URL? {
        var components = URLComponents(string: "\(baseURLString)\(topHeadlinesPath)")
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "country", value: country.rawValue),
            URLQueryItem(name: "apiKey", value: apiKey),
            URLQueryItem(name: "pageSize", value: "\(defaultPageSize)")
        ]

        if let category {
            queryItems.append(URLQueryItem(name: "category", value: category.rawValue))
        }

        components?.queryItems = queryItems
        return components?.url
    }
    
    static func sourcesURL(apiKey: String) -> URL? {
        var components = URLComponents(string: "\(baseURLString)\(sourcesPath)")
        components?.queryItems = [
            URLQueryItem(name: "apiKey", value: apiKey)
        ]
        return components?.url
    }
}
