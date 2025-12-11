enum NewsAPIConstants {
    static let defaultAPIKey = "c5669d85cb5c453ca6335bf6ac10108d"
    static let baseURLString = "https://newsapi.org"
    static let defaultPageSize = 10
    static let topHeadlinesPath = "/v2/top-headlines"

}

extension NewsAPIConstants {
    static func topHeadlinesURL(country: NewsCountry, category: NewsCategory?) -> URL? {
        var components = URLComponents(string: "\(baseURLString)\(topHeadlinesPath)")
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "country", value: country.rawValue),
            URLQueryItem(name: "apiKey", value: defaultAPIKey),
            URLQueryItem(name: "pageSize", value: "\(defaultPageSize)")
        ]

        if let category {
            queryItems.append(URLQueryItem(name: "category", value: category.rawValue))
        }

        components?.queryItems = queryItems
        return components?.url
    }
}
