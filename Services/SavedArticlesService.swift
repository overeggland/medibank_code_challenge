import Foundation

protocol SavedArticlesServicing {
    func saveArticle(_ article: Article) throws
    func removeArticle(_ article: Article) throws
    func isArticleSaved(_ article: Article) -> Bool
    func getAllSavedArticles() -> [Article]
}

final class SavedArticlesService: SavedArticlesServicing {
    private let userDefaults: UserDefaults
    private let savedArticlesKey = "savedArticles"
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func saveArticle(_ article: Article) throws {
        var savedArticles = getAllSavedArticles()
        
        // Check if article is already saved
        if !savedArticles.contains(where: { $0.id == article.id }) {
            savedArticles.append(article)
            try saveArticles(savedArticles)
        }
    }
    
    func removeArticle(_ article: Article) throws {
        var savedArticles = getAllSavedArticles()
        savedArticles.removeAll { $0.id == article.id }
        try saveArticles(savedArticles)
    }
    
    func isArticleSaved(_ article: Article) -> Bool {
        let savedArticles = getAllSavedArticles()
        return savedArticles.contains(where: { $0.id == article.id })
    }
    
    func getAllSavedArticles() -> [Article] {
        guard let data = userDefaults.data(forKey: savedArticlesKey) else {
            AppLogger.logCacheMiss(key: savedArticlesKey)
            return []
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let articles = try? decoder.decode([Article].self, from: data) else {
            AppLogger.logCacheError(key: savedArticlesKey, error: NSError(domain: "Cache", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to decode saved articles"]))
            return []
        }
        // Only log on initial load or when explicitly requested, not on every internal check
        // Logging is handled by the ViewModel when it calls loadSavedArticles()
        return articles
    }
    
    private func saveArticles(_ articles: [Article]) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(articles)
        userDefaults.set(data, forKey: savedArticlesKey)
        AppLogger.logCacheSave(key: savedArticlesKey, itemCount: articles.count)
    }
}
